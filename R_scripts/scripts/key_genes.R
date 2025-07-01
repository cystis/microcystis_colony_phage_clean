# === Set working directory to project root (if running from R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# Define keywords to search for
save_path <- "results/"
study_object <- "2023_PEP-CTERM"
search_keywords <- c("PEP-CTERM")

# Read CSV file
merged_df2 <- read.csv("rawdata/annotation/2023_base10_annotation.csv")

# Initialize empty dataframe to store matched results
all_matches <- data.frame()

# Initialize a dataframe to store match count for each keyword
keyword_count <- data.frame(Keyword = character(), Count = integer(), stringsAsFactors = FALSE)

# Search for each keyword
for (keyword in search_keywords) {
  # Search for entries matching the keyword
  new_df <- merged_df2[
    grepl(keyword, merged_df2$protein, ignore.case = TRUE) |
      grepl(keyword, merged_df2$Description, ignore.case = TRUE) |
      grepl(keyword, merged_df2$manual, ignore.case = TRUE) |
      grepl(keyword, merged_df2$KEGG_Pathway, ignore.case = TRUE),
  ]
  
  # Record number of matches for current keyword
  keyword_count <- rbind(keyword_count, data.frame(Keyword = keyword, Count = nrow(new_df), stringsAsFactors = FALSE))
  
  # Add result to total match dataframe
  all_matches <- rbind(all_matches, new_df)
}

# Remove duplicate entries
unique_matches <- unique(all_matches)

# Print match count for each keyword
print(keyword_count)

# Print total number of unique matches
cat("Total unique matches after removing duplicates:", nrow(unique_matches), "\n")

library(ggplot2)

# Use deduplicated result
df <- unique_matches

# Remove rows with missing values
df <- df[!is.na(df$padj) & !is.na(df$log2FoldChange), ]

# Add a column indicating gene regulation status
df$threshold <- as.factor(ifelse(df$padj < 0.05 & df$log2FoldChange > 1, "Up-regulated",
                                 ifelse(df$padj < 0.05 & df$log2FoldChange < -1, "Down-regulated", "Not significant")))

# Filter up-regulated and down-regulated genes
selected_genes <- df[df$threshold %in% c("Up-regulated", "Down-regulated"), ]

# Select top 10 genes with highest absolute log2FoldChange
top_genes <- selected_genes[order(-abs(selected_genes$log2FoldChange)), ][1:10, ]

library(ggrepel)

# Plot volcano plot
volcano_plot <- ggplot(df, aes(x = log2FoldChange, y = -log10(padj), color = threshold)) +
  geom_point(alpha = 0.8, size = 1) +  # Set point transparency and size
  scale_color_manual(values = c("Up-regulated" = "#E5A092", "Down-regulated" = "#87A7E0", "Not significant" = "#A6A6A6"), 
                     name = NULL) +  # Remove legend title
  geom_text_repel(data = top_genes, aes(label = gene_name), size = 2.7, color = "black", segment.color = "black", max.overlaps = Inf, force = 1, box.padding = 0.5, point.padding = 0.5) +  # Label top 10 genes
  # Add significance threshold lines
  geom_vline(xintercept = c(-1, 1), linetype = "dotted", color = "#A6A6A6", size = 0.5) +  # Fold change thresholds
  geom_hline(yintercept = -log10(0.05), linetype = "dotted", color = "#A6A6A6", size = 0.5) +  # p-value threshold
  
  # Customize Y-axis ticks to highlight -log10(0.05)
  scale_y_continuous(breaks = c(0, 5, 10, 15), labels = c("0", "5", "10", "15")) +
  
  scale_x_continuous(limits = c(-6, 6), breaks = seq(-6, 6, by = 2)) +  # Set symmetric X-axis
  
  labs(x = "Fold change (log2)", y = "Adjusted P-value (-log10)") +
  
  theme_minimal() +  # Remove default background
  
  theme(
    # Set legend text and position
    legend.position = "bottom",
    legend.text = element_text(size = 7),
    legend.spacing.x = unit(0, "mm"),
    legend.spacing.y = unit(0, "mm"),
    legend.margin = margin(t = 0, b = 0, l = 0, r = 0),
    
    # Set axis title font size
    axis.title.x = element_text(margin = margin(t = 5), size = 10),
    axis.title.y = element_text(margin = margin(r = 5), size = 10),
    
    # Set tick length
    axis.ticks.length = unit(0.15, "cm"),
    
    # Set plot margins
    plot.margin = margin(2, 2, 2, 2, "mm"),
    panel.border = element_rect(color = "black", fill = NA, size = 0.5),
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    aspect.ratio = 1,
    
    axis.line = element_line(color = "black"),
    axis.ticks = element_line(color = "black")
  ) +
  
  coord_cartesian(clip = "off")  # Ensure all points are visible within plot area

print(volcano_plot)

# Count the number of genes in each category
table(df$threshold)

# Save plot as PDF
ggsave(paste0(save_path, "volcano_", study_object, ".pdf"), volcano_plot, width = 4, height = 4, units = "in")