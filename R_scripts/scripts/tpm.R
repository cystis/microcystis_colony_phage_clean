# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)
  setwd(file.path(script_path, ".."))  
  cat("Working directory set to:", getwd(), "\n")
}

# === Define folders ===
input_dir <- "rawdata/rawcounts/"
intermediate_dir <- "intermediate/"

# === List of study objects (file prefixes without extension) ===
study_objects <- c(
  "2018_microcystispangenome",
  "2018_phagepangenome",
  "2023_microcystispangenome",
  "2023_phagepangenome"
)

# === TPM calculation function ===
TPM <- function(read_counts, gene_length) {
  rpk <- sweep(read_counts, 1, gene_length / 1000, `/`)        # Reads per kilobase
  total_rpk <- colSums(rpk)                                    # Total RPK per sample
  tpm <- sweep(rpk, 2, total_rpk, `/`) * 1e6                   # TPM normalization
  return(tpm)
}

# === Process each study object ===
for (study_object in study_objects) {
  
  # Define input/output file paths
  input_file <- paste0(input_dir, study_object, "_featurecounts.txt")
  output_file <- paste0(intermediate_dir, "TPM_", study_object, ".csv")
  
  # Read input count matrix from featureCounts
  TPM_raw <- read.table(input_file, header = TRUE, sep = "\t",
                        row.names = 1, check.names = FALSE, quote = "")
  
  # Extract gene length and raw read count matrix
  gene_length <- as.numeric(TPM_raw[, 5])            # 5th column = gene length
  read_counts <- as.matrix(TPM_raw[, 6:ncol(TPM_raw)])  # 6th column onward = counts
  
  # Calculate TPM
  tpm_data <- TPM(read_counts, gene_length)
  
  # Write TPM matrix to intermediate folder
  write.csv(tpm_data, output_file, row.names = TRUE)
  
  # Print progress
  cat("Processed:", study_object, "\n")
}