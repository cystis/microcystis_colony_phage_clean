# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

library(ggplot2)

# === Input data: Phylum-level average composition in Colonial samples ===
data <- data.frame(
  Phylum = c(
    "Cyanobacteriota", "Pseudomonadota", "Bacteroidota", 
    "Actinomycetota", "Streptophyta", "Bacillota", "Low_abundance"
  ),
  
  Colonial_Avg = c(
    94.70016711110580, 1.8530879963626900, 0.7767039786457550,
    0.2483818442092770, 0.5925376534356840, 0.1728741675482530,
    100 - (94.70016711110580 + 1.8530879963626900 + 0.7767039786457550 +
             0.2483818442092770 + 0.5925376534356840 + 0.1728741675482530)
  )
)

# === Reverse the plotting order for all Phyla except the first ===
data[2:7, ] <- data[2:7, ][nrow(data[2:7, ]):1, ]

# === Define fill colors ===
colors <- c("#b2df8a", "#bbb8d8", "#c8ddf6", "#8fbff6", "#549ffb", "#5757f7", "#3a3fef")

# === Create outer ring by amplifying non-dominant phyla ===
data_outer <- data
data_outer$Colonial_Avg[2:7] <- data_outer$Colonial_Avg[2:7] * 6.28950648673911
data_outer$Colonial_Avg[1] <- 100 - sum(data_outer$Colonial_Avg[2:7])

# === Add a new column to distinguish between inner and outer rings ===
data$Ring <- "Inner"
data_outer$Ring <- "Outer"

# === Combine the inner and outer ring data ===
data_combined <- rbind(data, data_outer)

# === Set plotting order for Phylum ===
data_combined$Phylum <- factor(data_combined$Phylum, levels = unique(data$Phylum))

# === Plot the double-ring donut chart ===
p <- ggplot(data_combined, aes(x = ifelse(Ring == "Inner", 1.5, 3), y = Colonial_Avg, fill = Phylum)) +
  geom_col(data = data_combined[data_combined$Ring == "Inner", ], width = 1) +  # Inner ring
  geom_col(data = data_combined[data_combined$Ring == "Outer", ], width = 1) +  # Outer ring
  coord_polar(theta = "y") +                                                   # Convert to polar coordinates
  xlim(0.5, 4.5) +                                                              # Control width of the ring space
  theme_void() +                                                                # Remove axes and background
  labs(title = "Phylum-level Composition (Inner: Raw, Outer: Amplified)") +     # Plot title
  scale_fill_manual(values = colors) +                                          # Use custom colors
  theme(plot.title = element_text(hjust = 0.5))                                 # Center the title

# === Save the plot to results folder ===
ggsave("results/double_ring_chart_colonial_120.pdf", plot = p, width = 8, height = 8)

# === Output message ===
cat("Plot saved to: results/double_ring_chart_colonial_120.pdf\n")