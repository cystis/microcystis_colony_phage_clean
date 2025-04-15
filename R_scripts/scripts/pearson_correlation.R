# === Load required libraries ===
library(ggplot2)
library(ggExtra)
library(scales)
library(grid)
library(gridExtra)
library(ggsignif)

# === Set working directory to project root (if running from R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# === Load DESeq2 results from 2018 and 2023 ===
data_2018 <- read.csv("intermediate/DE_2018_microcystispangenome_all.csv")
data_2023 <- read.csv("intermediate/DE_2023_microcystispangenome_all.csv")

# === Filter genes with baseMean > 10 ===
data_2018 <- subset(data_2018, baseMean > 10)
data_2023 <- subset(data_2023, baseMean > 10)

# === Merge data by Gene ID ===
merged_data <- merge(
  data_2018[, c("Gene", "baseMean", "log2FoldChange", "padj")], 
  data_2023[, c("Gene", "baseMean", "log2FoldChange", "padj")], 
  by = "Gene", suffixes = c("_2018", "_2023")
)

# === Log10 transform baseMean values ===
merged_data$log_baseMean_2018 <- log10(merged_data$baseMean_2018 + 1)
merged_data$log_baseMean_2023 <- log10(merged_data$baseMean_2023 + 1)

# === Annotate differential expression patterns ===
merged_data$category <- with(merged_data, ifelse(
  padj_2018 > 0.05 | padj_2023 > 0.05, "Not significant",
  ifelse(log2FoldChange_2018 > 0 & log2FoldChange_2023 > 0, "Both Upregulated",
         ifelse(log2FoldChange_2018 < 0 & log2FoldChange_2023 < 0, "Both Downregulated",
                "Mixed Regulation"
         )
  )
))

# === Keep only significant comparisons ===
significant_data <- subset(merged_data, category != "Not significant")

# === Count number of genes per category for labeling ===
category_counts <- as.data.frame(table(significant_data$category))
names(category_counts) <- c("category", "count")

# === Update category labels to include counts ===
significant_data$category <- factor(significant_data$category, levels = category_counts$category)
levels(significant_data$category) <- paste0(levels(significant_data$category), " (N=", category_counts$count, ")")

# === Pearson correlation analysis ===
pearson_result <- cor.test(
  significant_data$log_baseMean_2018, 
  significant_data$log_baseMean_2023, 
  method = "pearson"
)

# Extract Pearson stats
pearson_correlation <- pearson_result$estimate
pearson_p_value <- pearson_result$p.value

# === Spearman correlation analysis ===
spearman_result <- cor.test(
  significant_data$log_baseMean_2018, 
  significant_data$log_baseMean_2023, 
  method = "spearman"
)

spearman_correlation <- spearman_result$estimate
spearman_p_value <- spearman_result$p.value

# === Main scatter plot with regression line ===
p1 <- ggplot(significant_data, aes(x = log_baseMean_2023, y = log_baseMean_2018, color = category)) +
  geom_point(size = 2.5, alpha = 0.9) +
  geom_smooth(method = "lm", color = "black", linetype = "dashed", size = 0.8) +
  scale_color_manual(values = setNames(c("#87A7E0", "#E5A092", "#999999"), levels(significant_data$category))) +
  labs(x = "log10(baseMean) in the 2023 database", y = "log10(baseMean) in the 2018 database") +
  guides(color = guide_legend(override.aes = list(alpha = 1, size = 4))) +
  annotation_logticks(outside = TRUE, short = unit(1.5, "mm"), mid = unit(2, "mm"), long = unit(2.5, "mm")) +
  coord_cartesian(clip = "off") +
  theme_classic(base_size = 16) +
  theme(
    axis.title = element_text(size = 14), 
    axis.text = element_text(color = "black", size = 12),
    legend.title = element_blank(), 
    legend.text = element_text(size = 10),
    legend.position = c(0.03, 0.97), 
    legend.justification = c(0, 1),
    legend.background = element_rect(fill = 'white', colour = '#D6D6D6', linewidth = 0.8)
  )

# === Add marginal histograms ===
p1_with_marginal <- ggMarginal(
  p1, 
  type = "histogram", 
  margins = "both", 
  size = 10, 
  groupColour = TRUE, 
  groupFill = TRUE, 
  binwidth = 0.08
)

# === Save to PDF ===
pdf("results/correlation_plot_pearson.pdf", width = 6, height = 6)
grid.newpage()
print(p1_with_marginal)
dev.off()

# === Print correlation results ===
cat("==== Pearson Correlation ====\n")
cat("Correlation Coefficient (r):", round(pearson_correlation, 4), "\n")
cat("P-value:", format.pval(pearson_p_value, digits = 5, scientific = TRUE), "\n\n")

cat("==== Spearman Correlation ====\n")
cat("Correlation Coefficient (rho):", round(spearman_correlation, 4), "\n")
cat("P-value:", format.pval(spearman_p_value, digits = 5, scientific = TRUE), "\n")