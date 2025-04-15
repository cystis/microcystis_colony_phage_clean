# === Load required library ===
library(DESeq2)

# === Set working directory to project root (R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# === Define object name and standardized paths ===
study_object <- "2023_microcystispangenome"   # Change to match dataset
input_dir <- "rawdata/rawcounts/"
output_dir <- "intermediate/"

# === Load featureCounts matrix (.txt) ===
count_file <- paste0(input_dir, study_object, "_featurecounts.txt")
countdata <- read.table(count_file, header = TRUE, sep = "\t", row.names = 1, check.names = FALSE)
countdata <- countdata[, 6:29]  # Keep only count columns (adjust if needed)
countdata <- as.matrix(countdata)

# === Load metadata ===
metadata <- read.csv(paste0("rawdata/metadata.csv"), header = TRUE, row.names = 1)
metadata <- metadata[1:24, ]  # Use first 24 samples if needed

# === Prepare DESeq2 input ===
coldata <- data.frame(row.names = colnames(countdata), metadata)
coldata$Morphology <- factor(coldata$Morphology, levels = c("Single-cell", "Colonial"))

# === Run DESeq2 analysis ===
dds <- DESeqDataSetFromMatrix(countData = countdata, colData = coldata, design = ~Morphology)
dds <- DESeq(dds)

# === Get results and merge with normalized counts ===
res <- results(dds)
res <- res[order(res$padj), ]
resdata <- merge(as.data.frame(res), as.data.frame(counts(dds, normalized = TRUE)),
                 by = "row.names", sort = FALSE)
names(resdata)[1] <- "Gene"

# === Save full results ===
write.csv(resdata, file = paste0(output_dir, "DE_", study_object, "_all.csv"))

# === Filter padj ≤ 0.05 ===
resdata <- resdata[complete.cases(resdata$padj, resdata$log2FoldChange), ]
filtered_padj_data <- resdata[resdata$padj <= 0.05, ]
write.csv(filtered_padj_data, paste0(output_dir, "DE_", study_object, "_0.05.csv"), row.names = FALSE)

# === Count log2FC direction for padj ≤ 0.05 ===
positive_count <- sum(filtered_padj_data$log2FoldChange > 0)
negative_count <- sum(filtered_padj_data$log2FoldChange < 0)
cat("padj ≤ 0.05:\n")
cat("  Upregulated :", positive_count, "\n")
cat("  Downregulated :", negative_count, "\n")

# === Filter |log2FC| ≥ 1 ===
filtered_1folddata <- filtered_padj_data[abs(filtered_padj_data$log2FoldChange) >= 1, ]
write.csv(filtered_1folddata, paste0(output_dir, "DE_", study_object, "_1fold.csv"), row.names = FALSE)

positive_count <- sum(filtered_1folddata$log2FoldChange > 0)
negative_count <- sum(filtered_1folddata$log2FoldChange < 0)
cat("|log2FC| ≥ 1:\n")
cat("  Upregulated :", positive_count, "\n")
cat("  Downregulated :", negative_count, "\n")

# === Filter |log2FC| ≥ 2 ===
filtered_data <- filtered_padj_data[abs(filtered_padj_data$log2FoldChange) >= 2, ]
final_data <- filtered_data[order(filtered_data$log2FoldChange, decreasing = TRUE), ]
write.csv(final_data, paste0(output_dir, "DE_", study_object, "_2fold.csv"), row.names = FALSE)

positive_count <- sum(filtered_data$log2FoldChange > 0)
negative_count <- sum(filtered_data$log2FoldChange < 0)
cat("|log2FC| ≥ 2:\n")
cat("  Upregulated :", positive_count, "\n")
cat("  Downregulated :", negative_count, "\n")