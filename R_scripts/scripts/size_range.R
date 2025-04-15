# Load required packages
library(ggplot2)
library(stringr)
library(scales)
library(dplyr)
# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}


# Define the folder where your CSV files are located (assumed in "SizeRange")
data_folder1 <- "rawdata/size_range"
data_folder2 <- "results"
files <- list.files(data_folder1, pattern = "^Colony_S\\d+_\\d+\\.csv$", full.names = TRUE)

# Function to compute the midpoint of a size range (e.g., "0.5-1")
get_midpoint <- function(range_str) {
  parts <- strsplit(range_str, "-")[[1]]
  return(mean(as.numeric(parts)))
}

# Initialize a data frame to store the biomass-based expanded data
all_data <- data.frame()

# Process each file (each file represents one sample)
for (file in files) {
  # Extract sample info from filename, e.g., "S1_1"
  sample_name <- str_extract(basename(file), "S\\d+_\\d+")
  
  # Read the CSV file (assume first column is "粒径μm" and second is "累计%")
  df <- read.csv(file, stringsAsFactors = FALSE)
  
  # Rename columns to English names (adjust if your names differ)
  names(df)[names(df) == "粒径μm"] <- "SizeRange"
  names(df)[names(df) == "累计%"] <- "Cumulative"
  
  # Add Sample column
  df$Sample <- sample_name
  
  # Compute the midpoint for each size interval
  df$Midpoint <- sapply(df$SizeRange, get_midpoint)
  
  # Calculate interval percentages:
  # The first interval is taken directly from the cumulative value,
  # subsequent intervals are the differences between consecutive cumulative values.
  df$Interval <- c(df$Cumulative[1], diff(df$Cumulative))
  
  # Compute biomass for each interval using the cube of the midpoint
  df$Biomass <- (df$Midpoint)^1 * df$Interval
  
  # Allocate ~1000 points per sample based on biomass proportions
  total_biomass <- sum(df$Biomass)
  df$BCount <- (df$Biomass / total_biomass) * 1000
  
  # Expand the data: for each interval, replicate the row BCount times,
  # keeping only Sample and Midpoint
  if(nrow(df) > 0) {
    expanded <- df[rep(1:nrow(df), df$BCount), c("Sample", "Midpoint")]
    all_data <- rbind(all_data, expanded)
  }
}

# Convert Sample to a factor to maintain consistent order
all_data$Sample <- factor(all_data$Sample, levels = unique(all_data$Sample))

# Create scatter plot using biomass-based expanded data:
# - x-axis: Sample (categorical)
# - y-axis: Particle size (Midpoint) on a log scale
# p <- ggplot(all_data, aes(x = factor(Sample), y = Midpoint, color = Sample)) +
#   geom_jitter(width = 0.2, alpha = 0.4) +  # Draw jittered scatter points
#   scale_y_log10(breaks = c(0.1, 1, 10, 100, 1000),
#                 labels = function(x) format(x, scientific = FALSE)) +
#   labs(x = "Sample", 
#        y = expression("Particle size (" * mu * "m)"),
#        title = "Combined Particle Size Distribution\n(Biomass-based)") +
#   theme_classic() +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 创建散点图（统一颜色）
p <- ggplot(all_data, aes(x = factor(Sample), y = Midpoint)) +
  geom_jitter(width = 0.2, alpha = 0.4, color = "#73b84c") +  # 统一颜色，例如蓝色
  scale_y_log10(limits = c(4, 1000),
                breaks = c(5, 10, 20, 100, 1000),
                labels = function(x) format(x, scientific = FALSE)) +
  labs(x = "Sample", 
       y = expression("Particle size (" * mu * "m)"),
       title = "Combined Particle Size Distribution\n(Volume Percentage)") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Display the plot
print(p)

# Save the plot as a PDF file
ggsave(filename = file.path(data_folder2, "Combined_Scatter_Plot_Volum_percentage.pdf"),
       plot = p, width = 6, height = 4)