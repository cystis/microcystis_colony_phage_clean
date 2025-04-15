# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)
  setwd(file.path(script_path, ".."))
  cat("Working directory set to:", getwd(), "\n")
}

# === Load required libraries ===
library(tidyverse)

# === Define folders ===
intermediate_dir <- "intermediate/"

# === Read TPM expression matrix ===
tpm_file <- paste0(intermediate_dir, "TPM_2023_phagepangenome.csv")
data <- read.csv(tpm_file, row.names = 1, check.names = FALSE)

# === Define genes of interest ===
genes <- c(
  "lcl|NC_008562.1_cds_YP_851105.1_91",   # ORF91
  "lcl|NC_008562.1_cds_YP_851149.1_135",  # ORF135
  "lcl|NC_008562.1_cds_YP_851150.1_136"   # ORF136
)

# === Paired comparison: colonial vs single-cell (first 12 vs last 12 samples) ===
for (gene in genes) {
  cat("====== Gene:", gene, "======\n")
  
  # Extract TPM values
  values <- as.numeric(data[gene, ])
  colony <- values[1:12]
  single_cell <- values[13:24]
  diff_values <- single_cell - colony
  
  # Test for normality of differences
  shapiro_res <- shapiro.test(diff_values)
  print(shapiro_res)
  
  # Choose appropriate test
  if (shapiro_res$p.value > 0.05) {
    test_used <- "Paired t-test"
    test_res <- t.test(single_cell, colony, paired = TRUE)
  } else {
    test_used <- "Wilcoxon signed-rank test"
    test_res <- wilcox.test(single_cell, colony, paired = TRUE)
  }
  
  # Calculate fold change stats
  fold_change <- single_cell / colony
  fc_mean <- mean(fold_change)
  fc_sd <- sd(fold_change)
  
  # Report results
  cat("Test used:", test_used, "\n")
  print(test_res)
  cat("Fold change (mean ± SD):", round(fc_mean, 2), "±", round(fc_sd, 2), "\n\n")
}