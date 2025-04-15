# === Load required libraries ===
library(dplyr)
library(tidyr)
library(ggplot2)
library(gghalves)
library(ggpubr)
library(tibble)

# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# === File paths ===
tpm_file <- "intermediate/TPM_2023_phagepangenome.csv"  # or "TPM_2023_phagepangenome.csv"
meta_file <- "rawdata/metadata.csv"

# === Read input files ===
tpm_data <- read.csv(tpm_file, row.names = 1, check.names = FALSE)
metadata <- read.csv(meta_file)

# === Target gene IDs ===
target_genes <- c(
  "lcl|NC_008562.1_cds_YP_851150.1_136.1", 
  "lcl|NC_008562.1_cds_YP_851149.1_135.1", 
  "lcl|NC_008562.1_cds_YP_851105.1_91.1"
)

# === Extract expression data ===
tpm_filtered <- tpm_data %>%
  rownames_to_column("Gene") %>%
  filter(Gene %in% target_genes) %>%
  pivot_longer(cols = -Gene, names_to = "Sample", values_to = "TPM") %>%
  left_join(metadata, by = "Sample")

# === Assign short gene names and facet order ===
tpm_filtered$gene_name <- recode(tpm_filtered$Gene,
                                 "lcl|NC_008562.1_cds_YP_851150.1_136.1" = "ORF136",
                                 "lcl|NC_008562.1_cds_YP_851149.1_135.1" = "ORF135",
                                 "lcl|NC_008562.1_cds_YP_851105.1_91.1"  = "ORF91")
tpm_filtered$gene_name <- factor(tpm_filtered$gene_name, levels = c("ORF91", "ORF135", "ORF136"))

# === Custom color palette ===
Custom.color <- c("#73b84c", "#245892")

# === Generate base plot ===
p <- ggplot(tpm_filtered, aes(x = Morphology, y = TPM, fill = Morphology)) +
  geom_boxplot(width = 0.12, size = 0.5, outlier.shape = NA, alpha = 0.5,
               position = position_nudge(x = 0.1)) +
  geom_jitter(width = 0.2, aes(color = Morphology), alpha = 0.6, size = 1.5) +
  scale_fill_manual(values = Custom.color) +
  scale_color_manual(values = Custom.color) +
  facet_wrap(~ gene_name, scales = "fixed") +
  stat_compare_means(
    comparisons = list(c("Colonial", "Single-cell")),
    label = "p",
    method = "t.test",
    # paired = TRUE,  # Not supported by stat_compare_means; can leave or remove
    step_increase = 0.05,
    vjust = 0.2,
    hjust = -0.5,
    size = 2.8
  ) +
  theme_classic(base_size = 8) +
  labs(y = "TPM", x = basename(tpm_file)) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    axis.text.y = element_blank(),  # y-axis hidden here
    axis.title.y = element_text(size = 10),
    axis.line = element_line(size = 0),
    axis.ticks = element_line(size = 0.8),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    strip.background = element_rect(color = "black", size = 1, fill = NA),
    strip.text = element_text(size = 8),
    legend.position = "none"
  )

# === Save plot without y-axis ===
ggsave(
  filename = paste0("results/box_plot_", sub(".csv", "", basename(tpm_file)), ".pdf"),
  plot = p,
  device = "pdf",
  width = 5,
  height = 4,
  units = "in"
)

# === Save plot with y-axis labels ===
p_with_y <- p + theme(axis.text.y = element_text(size = 8))
ggsave(
  filename = paste0("results/box_plot_", sub(".csv", "", basename(tpm_file)), "_withY.pdf"),
  plot = p_with_y,
  device = "pdf",
  width = 5,
  height = 4,
  units = "in"
)