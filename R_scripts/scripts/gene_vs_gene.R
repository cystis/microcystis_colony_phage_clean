# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)
  setwd(file.path(script_path, ".."))
}

# === Load required libraries ===
library(tidyverse)
library(stats)

# === Read TPM data ===
data <- read.csv("intermediate/TPM_2023_phagepangenome.csv", row.names = 1, check.names = FALSE)

# === Define target genes ===
gene91 <- "lcl|NC_008562.1_cds_YP_851105.1_91"
gene135 <- "lcl|NC_008562.1_cds_YP_851149.1_135"
gene136 <- "lcl|NC_008562.1_cds_YP_851150.1_136"

# === Colony group (first 12 samples) ===
expr_91 <- as.numeric(data[gene91, 1:12])
expr_135 <- as.numeric(data[gene135, 1:12])
expr_136 <- as.numeric(data[gene136, 1:12])

# --- ORF135 vs ORF91 ---
diff_135_91 <- expr_135 - expr_91
shapiro_135_91 <- shapiro.test(diff_135_91)

if (shapiro_135_91$p.value > 0.05) {
  test_135_91 <- t.test(expr_135, expr_91, paired = TRUE)
  test_name_135 <- "Paired t-test"
} else {
  test_135_91 <- wilcox.test(expr_135, expr_91, paired = TRUE)
  test_name_135 <- "Wilcoxon signed-rank test"
}
fold_135_91 <- expr_135 / expr_91
mean_fc_135 <- mean(fold_135_91)
sd_fc_135 <- sd(fold_135_91)

# --- ORF136 vs ORF91 ---
diff_136_91 <- expr_136 - expr_91
shapiro_136_91 <- shapiro.test(diff_136_91)

if (shapiro_136_91$p.value > 0.05) {
  test_136_91 <- t.test(expr_136, expr_91, paired = TRUE)
  test_name_136 <- "Paired t-test"
} else {
  test_136_91 <- wilcox.test(expr_136, expr_91, paired = TRUE)
  test_name_136 <- "Wilcoxon signed-rank test"
}
fold_136_91 <- expr_136 / expr_91
mean_fc_136 <- mean(fold_136_91)
sd_fc_136 <- sd(fold_136_91)

# --- Output for colony ---
cat("===== ORF135 vs ORF91 in colony samples =====\n")
cat("Shapiro-Wilk test P =", round(shapiro_135_91$p.value, 3), "\n")
cat("Test used:", test_name_135, "\n")
print(test_135_91)
cat("Fold change (135/91):", round(mean_fc_135, 2), "±", round(sd_fc_135, 2), "SD\n\n")

cat("===== ORF136 vs ORF91 in colony samples =====\n")
cat("Shapiro-Wilk test P =", round(shapiro_136_91$p.value, 3), "\n")
cat("Test used:", test_name_136, "\n")
print(test_136_91)
cat("Fold change (136/91):", round(mean_fc_136, 2), "±", round(sd_fc_136, 2), "SD\n")

# === Single-cell group (last 12 samples) ===
expr_91_s <- as.numeric(data[gene91, 13:24])
expr_135_s <- as.numeric(data[gene135, 13:24])
expr_136_s <- as.numeric(data[gene136, 13:24])

# --- ORF91 vs ORF135 ---
diff_91_135 <- expr_91_s - expr_135_s
shapiro_91_135 <- shapiro.test(diff_91_135)

if (shapiro_91_135$p.value > 0.05) {
  test_91_135 <- t.test(expr_91_s, expr_135_s, paired = TRUE)
  test_name_91_135 <- "Paired t-test"
} else {
  test_91_135 <- wilcox.test(expr_91_s, expr_135_s, paired = TRUE)
  test_name_91_135 <- "Wilcoxon signed-rank test"
}
fold_91_135 <- expr_91_s / expr_135_s
mean_fc_91_135 <- mean(fold_91_135)
sd_fc_91_135 <- sd(fold_91_135)

# --- ORF91 vs ORF136 ---
diff_91_136 <- expr_91_s - expr_136_s
shapiro_91_136 <- shapiro.test(diff_91_136)

if (shapiro_91_136$p.value > 0.05) {
  test_91_136 <- t.test(expr_91_s, expr_136_s, paired = TRUE)
  test_name_91_136 <- "Paired t-test"
} else {
  test_91_136 <- wilcox.test(expr_91_s, expr_136_s, paired = TRUE)
  test_name_91_136 <- "Wilcoxon signed-rank test"
}
fold_91_136 <- expr_91_s / expr_136_s
mean_fc_91_136 <- mean(fold_91_136)
sd_fc_91_136 <- sd(fold_91_136)

# --- Output for single-cell ---
cat("===== ORF91 vs ORF135 in single-cell samples =====\n")
cat("Shapiro-Wilk test P =", round(shapiro_91_135$p.value, 3), "\n")
cat("Test used:", test_name_91_135, "\n")
print(test_91_135)
cat("Fold change (91/135):", round(mean_fc_91_135, 2), "±", round(sd_fc_91_135, 2), "SD\n\n")

cat("===== ORF91 vs ORF136 in single-cell samples =====\n")
cat("Shapiro-Wilk test P =", round(shapiro_91_136$p.value, 3), "\n")
cat("Test used:", test_name_91_136, "\n")
print(test_91_136)
cat("Fold change (91/136):", round(mean_fc_91_136, 2), "±", round(sd_fc_91_136, 2), "SD\n")

# === Shapiro test for fold change distributions ===
fold_list <- list(
  "fold_135_91" = fold_135_91,
  "fold_136_91" = fold_136_91,
  "fold_91_135" = fold_91_135,
  "fold_91_136" = fold_91_136
)

for (name in names(fold_list)) {
  cat("====", name, "====\n")
  result <- shapiro.test(fold_list[[name]])
  print(result)
  cat("\n")
}