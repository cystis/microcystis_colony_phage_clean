# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# === Define dataset parameters ===
dataset_name <- "Cyanobacteriota"  # For selecting the input file
study_object <- "noMicrocystis"    # For naming the output

# === Define file paths ===
file_name <- paste0("kegg_", dataset_name, "_baseMean_ge10.txt")
file_path <- file.path("rawdata/kegg/2023", file_name)
output_prefix <- paste0(dataset_name, "_", study_object)
output_path <- "results"

# === Load required libraries ===
library(data.table)
library(clusterProfiler)
library(dplyr)
library(ggplot2)
library(tidyr)

# === Load data ===
data <- fread(file_path, header = TRUE, sep = "\t")

# === Optional: remove Microcystis from Cyanobacteriota only ===
if (dataset_name == "Cyanobacteriota") {
  data <- data[Genus != "g__Microcystis"]
}

# === Extract KO terms ===
all_ko <- unlist(strsplit(data$KEGG_ko, split = ","))
all_ko <- gsub("ko:", "", all_ko)

# === Perform KEGG enrichment analysis ===
all_enrich <- enrichKEGG(gene = all_ko, organism = "ko", keyType = "kegg", pvalueCutoff = 0.05)
top20_enrich <- head(as.data.frame(all_enrich), 15)

# === Build enrichment table ===
top20_enrich_df <- top20_enrich %>%
  dplyr::select(ID, Description, geneID, GeneRatio) %>%
  dplyr::rename(KO_ID = ID, Pathway_Name = Description, Homologous_Genes = geneID)

# === Assign up/down regulation ===
data$trend <- ifelse(data$log2FoldChange > 0, "Upregulated", "Downregulated")

# === Count up/down for each pathway ===
top20_enrich_df <- top20_enrich_df %>%
  rowwise() %>%
  mutate(
    Upregulated_Count = sum(sapply(unlist(strsplit(Homologous_Genes, "/")), function(ko_id) {
      any(grepl(ko_id, data$KEGG_ko[data$trend == "Upregulated"]))
    })),
    Downregulated_Count = -sum(sapply(unlist(strsplit(Homologous_Genes, "/")), function(ko_id) {
      any(grepl(ko_id, data$KEGG_ko[data$trend == "Downregulated"]))
    }))
  ) %>%
  ungroup() %>%
  arrange(desc(GeneRatio))  # Order by enrichment strength

# === Reshape for plotting ===
enrichment_long <- top20_enrich_df %>%
  select(Pathway_Name, Upregulated_Count, Downregulated_Count, GeneRatio) %>%
  pivot_longer(cols = c("Upregulated_Count", "Downregulated_Count"),
               names_to = "Regulation", values_to = "Count") %>%
  mutate(GeneRatio_Numerator = as.numeric(sub("/.*", "", GeneRatio))) %>%
  arrange(GeneRatio_Numerator)

# Set plotting order
enrichment_long$Pathway_Name <- factor(enrichment_long$Pathway_Name, levels = unique(enrichment_long$Pathway_Name))

# === Plot version 1: With y-axis text ===
pdf(file = file.path(output_path, paste0(output_prefix, "_Top20_Enrichment_Lollipop_Plot.pdf")), width = 7, height = 4)

ggplot(enrichment_long, aes(x = Pathway_Name, y = Count, color = Regulation)) +
  geom_segment(aes(x = Pathway_Name, xend = Pathway_Name, y = 0, yend = Count), size = 0.6) +
  geom_point(size = 3) +
  coord_flip() +
  scale_color_manual(values = c("Upregulated_Count" = "#E5A092", "Downregulated_Count" = "#87A7E0"),
                     labels = c("Upregulated_Count" = "Upregulated", "Downregulated_Count" = "Downregulated")) +
  labs(x = "KEGG Pathways", y = "Gene Count",
       title = paste("Top 20 KEGG Pathways with Diverging Genes in", study_object)) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(hjust = 1),
    axis.text.x = element_text(color = "black", size = 10),
    axis.line.x = element_line(color = "black"),
    panel.grid = element_blank(),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5)
  )

dev.off()

# === Plot version 2: No y-axis text ===
pdf(file = file.path(output_path, paste0(output_prefix, "_Top20_Enrichment_Lollipop_Plot_No_Y_Text.pdf")), width = 3, height = 4)

ggplot(enrichment_long, aes(x = Pathway_Name, y = Count, color = Regulation)) +
  geom_segment(aes(x = Pathway_Name, xend = Pathway_Name, y = 0, yend = Count), size = 0.6) +
  geom_point(size = 3) +
  coord_flip() +
  scale_color_manual(values = c("Upregulated_Count" = "#E5A092", "Downregulated_Count" = "#87A7E0"),
                     labels = c("Upregulated_Count" = "Upregulated", "Downregulated_Count" = "Downregulated")) +
  labs(x = NULL, y = "Gene Count",
       title = paste("Top 20 KEGG Pathways with Diverging Genes in", study_object)) +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    axis.text.x = element_text(color = "black", size = 10),
    axis.line.x = element_line(color = "black"),
    panel.grid = element_blank(),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5)
  )

dev.off()