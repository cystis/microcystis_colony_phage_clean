# === Load required libraries ===
library(ggplot2)
library(dplyr)

# === Set working directory to project root (if in R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# === Define input/output paths ===
input_file <- "rawdata/cog/2023_1fold_cogcount.csv"
output_file <- "results/barbell_cog.pdf"

# === Read input data ===
data <- read.csv(input_file)

# === Sort data within each function_class based on total_number ===
data <- data %>%
  arrange(function_class, total_number)

# === Set factor level order for plotting ===
data$COG_category <- factor(data$COG_category, levels = unique(data$COG_category))

# === Compute category boundaries for dashed lines ===
class_boundaries <- cumsum(table(data$function_class))

# === Create barbell plot ===
p <- ggplot(data) +
  geom_segment(aes(x = downregulated, xend = upregulated, y = COG_category, yend = COG_category),
               color = "gray", size = 1) +
  geom_point(aes(x = downregulated, y = COG_category), color = "#87A7E0", size = 3) +
  geom_point(aes(x = upregulated, y = COG_category), color = "#E5A092", size = 3) +
  labs(x = "Number of DE Genes", y = "COG Category") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    axis.line = element_blank()
  ) +
  geom_hline(yintercept = class_boundaries[-length(class_boundaries)] + 0.5, 
             linetype = "dashed", color = "black")

# === Add function class annotations ===
p <- p + 
  annotate("text", x = 125, y = class_boundaries[1] + 0.5,
           label = "Information storage and processing", hjust = 1, vjust = -0.5, size = 3.5) +
  annotate("text", x = 125, y = class_boundaries[2] + 0.5,
           label = "Metabolism", hjust = 1, vjust = -0.5, size = 3.5) +
  annotate("text", x = 125, y = 0.2,
           label = "Cellular processes and signaling", hjust = 1, vjust = -0.5, size = 3.5) +
  coord_cartesian(xlim = c(0, 125))

# === Save to PDF ===
ggsave(output_file, plot = p, width = 5, height = 5)

# === Output path confirmation ===
cat("Plot saved to:", output_file, "\n")