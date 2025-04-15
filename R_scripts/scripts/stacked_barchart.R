# === Load required libraries ===
library(ggplot2)
library(dplyr)
library(tidyr)

# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# === Define input/output paths and research object ===
research_object <- "Phylum"  # or "Genus"
input_file <- file.path("rawdata/taxonomy", paste0("2023_percentage_", research_object, ".csv"))
annotation_file <- "rawdata/metadata.csv"
output_file <- file.path("results", paste0(research_object, "_filtered_stacked_barplot_with_transparency.pdf"))

# === Read input files ===
data <- read.csv(input_file, sep = ",")
annotation <- read.csv(annotation_file)

# === Filter and order samples by Morphology ===
annotation <- annotation[1:24, ]
annotation <- annotation %>%
  arrange(factor(Morphology, levels = c("Colonial", "Single-cell")))
sample_order <- annotation$Sample

#
colnames(data)[1] <- "Taxon"

data_long <- data %>%
  pivot_longer(cols = -Taxon, names_to = "Sample", values_to = "Percentage")

# === Define selected taxa ===
selected_taxa <- c("p__Cyanobacteriota", "p__Pseudomonadota", "p__Bacteroidota",
                   "p__Actinomycetota", "p__Streptophyta", "p__Bacillota")
# If you're plotting Genus, use this instead:
# selected_taxa <- c("g__Microcystis", "g__Planktothricoides", ...)

# === Merge low-abundance taxa ===
data_long <- data_long %>%
  mutate(Taxon = if_else(Taxon %in% selected_taxa, Taxon, "Low abundance"))

data_low <- data_long %>%
  filter(Taxon == "Low abundance") %>%
  group_by(Sample) %>%
  summarise(Percentage = sum(Percentage)) %>%
  mutate(Taxon = "Low abundance")

data_long <- data_long %>%
  filter(Taxon != "Low abundance") %>%
  bind_rows(data_low)

# === Factor levels for plotting ===
data_long$Taxon <- factor(data_long$Taxon, levels = rev(c(selected_taxa, "Low abundance")))
data_long$Sample <- factor(data_long$Sample, levels = sample_order)

# === Rename samples ===
new_sample_names <- c(
  "C_S1_1", "C_S1_2", "C_S1_3", "C_S2_1", "C_S2_2", "C_S2_3",
  "C_S3_1", "C_S3_2", "C_S3_3", "C_S4_1", "C_S4_2", "C_S4_3",
  "S_S1_1", "S_S1_2", "S_S1_3", "S_S2_1", "S_S2_2", "S_S2_3",
  "S_S3_1", "S_S3_2", "S_S3_3", "S_S4_1", "S_S4_2", "S_S4_3"
)
if (length(sample_order) != length(new_sample_names)) {
  stop("Mismatch in sample name count.")
}
names(new_sample_names) <- sample_order
data_long$Sample <- factor(data_long$Sample, levels = sample_order, labels = new_sample_names)

# === Define color palette ===
custom_colors <- c(
  "#4575b4", "#8e44ad", "#e67e22", "#f1c40f",
  "#95a5a6", "#b15928", "#73b84c"
)

# === Plot stacked barplot with transparency and borders ===
plot <- ggplot(data_long, aes(x = Sample, y = Percentage, fill = Taxon)) +
  geom_bar(stat = "identity", width = 0.7, color = "black", size = 0.5, alpha = 0.7) +
  scale_fill_manual(values = custom_colors) +
  labs(
    title = paste("Relative Abundance of Selected", research_object, "per Sample"),
    y = "Percentage", x = "Sample"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title.y = element_blank(),
    plot.title = element_text(hjust = 0.5)
  ) +
  annotate("rect", xmin = 0.5, xmax = 12.5, ymin = 0, ymax = 100,
           color = "black", fill = NA, size = 1) +
  annotate("rect", xmin = 12.5, xmax = 24.5, ymin = 0, ymax = 100,
           color = "black", fill = NA, size = 1)

# === Save plot as PDF ===
ggsave(output_file, plot, width = 10, height = 6)

# === Report path ===
cat("Plot saved to:", output_file, "\n")