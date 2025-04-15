# === Load required libraries ===
library(vegan)      # For ecological ordination (metaMDS, adonis)
library(ggplot2)    # For plotting
library(ggpubr)     # For enhanced ggplot2 tools (ggsave, stat_ellipse)

# === Define file paths and dataset ===
study_object <- "2023_microcystispangenome"
path_input <- "intermediate/"
path_output <- "results/"

# === Read expression matrix (TPM) ===
df <- read.csv(paste0(path_input, "TPM_", study_object, ".csv"), row.names = 1)

# === Transpose matrix (genes as columns) and log-transform expression data ===
df_transposed <- t(df)
log_df <- log(df_transposed + 1)

# === Create community matrix ===
m_com <- as.matrix(log_df)

# === Run non-metric multidimensional scaling (nMDS) using Bray-Curtis distance ===
set.seed(123)  # For reproducibility
nmds <- metaMDS(m_com, distance = "bray")

# === Extract NMDS coordinates (site scores) ===
nmds_scores <- as.data.frame(scores(nmds)$sites)

# === Read metadata (first 24 samples only) ===
metadata <- read.csv("rawdata/metadata.csv", header = TRUE, row.names = 1)
metadata <- metadata[1:24, ]

# === Merge NMDS coordinates with metadata ===
nmds_scores$Sample <- rownames(nmds_scores)
data_scores <- merge(nmds_scores, metadata, by.x = "Sample", by.y = "row.names")

# Ensure factors are correctly set
data_scores$Morphology <- as.factor(data_scores$Morphology)
data_scores$Site <- as.factor(data_scores$Site)

# === Plot NMDS with 68% confidence ellipse ===
p <- ggplot(data_scores, aes(x = NMDS1, y = NMDS2, color = Morphology)) +
  geom_point(alpha = 0.7, size = 2) +
  stat_ellipse(level = 0.68) +
  scale_color_manual(values = c("Colonial" = "#73b84c", "Single-cell" = "#245892")) +
  labs(x = "NMDS 1", y = "NMDS 2", title = "NMDS of Microcystis Pangenome") +
  theme_classic(base_size = 10) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold")
  )

# === Display NMDS plot ===
print(p)

# === Save plot to PDF ===
ggsave(filename = paste0(path_output, "NMDS_", study_object, "_bray_curtis.pdf"),
       plot = p, width = 5, height = 3)

# === PERMANOVA test using Bray-Curtis distance ===
bray_dist <- vegdist(m_com, method = "bray")

adonis_result <- adonis(bray_dist ~ Morphology, data = metadata)

# === Print PERMANOVA results ===
print(adonis_result)

# === Extract F, R² and P values ===
F_value <- adonis_result$aov.tab[1, "F.Model"]
R_squared <- adonis_result$aov.tab[1, "R2"]
P_value <- adonis_result$aov.tab[1, "Pr(>F)"]

cat("PERMANOVA Results:\n")
cat("  F-value     :", round(F_value, 4), "\n")
cat("  R-squared   :", round(R_squared, 4), "\n")
cat("  P-value     :", P_value, "\n\n")

# === Report NMDS stress value ===
cat("NMDS Stress value:", nmds$stress, "\n")