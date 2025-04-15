# Microcystis Pangenome Construction

This directory contains scripts and data for building the **Microcystis** pangenome and performing gene-level quantification using metatranscriptomic data.

---

## 🧬 Workflow Steps

### Step 1: `00_input_genomes/`
- `total15genome.fna`: Combined FASTA file of 15 *Microcystis* genomes downloaded from NCBI.

---

### Step 2: `01_cdhit_clustering/`
- `cdhit.sh`: CD-HIT-EST script to cluster **nucleotide** gene sequences at 95% identity.
- Output files:
  - `Frankenstein_microcystis_0.95_2024.fna`: Clustered pangenome reference (nucleotide).
  - `Frankenstein_microcystis_0.95_2024.fna.clstr`: Cluster membership info.

---

### Step 3: `02_clean_headers/`
- `remove.py`: Removes long headers in FASTA file (needed for bbmap compatibility).
- Output:
  - [`headers_Removed_new_Frank.fasta`](./02_clean_headers/headers_Removed_new_Frank.fasta): Cleaned reference genome for read mapping and quantification.

---

### Step 4: `03_annotation/`
- `eggnog.sh`: Annotate clustered genes using EggNOG-mapper.
- Output:
  - [`eggnog_15protein.emapper.annotations.txt`](./03_annotation/eggnog_15protein.emapper.annotations.txt): Functional annotation file for downstream interpretation.

---

### Step 5: `04_mapping/`
- `SAM90.sh`: Map rRNA-filtered reads to the cleaned pangenome using `bbmap` (minid = 0.90).

---

### Step 6: `05_generate_gff3/`
- `get_gff3.py`: Converts gene predictions into a valid GFF3 file for use with featureCounts.
- Output:
  - `Frank_microcystis_0.95_2024.gff3`: GFF3 annotation file.

---

### Step 7: `06_featurecounts/`
- `FC90.sh`: Quantify reads mapped to genes using `featureCounts`.
- Output:
  - `TAIHU_microcystis_featurecounts90.txt`: Raw gene-level count table.

---

## 📎 Notes

- You can directly use:
  - [`headers_Removed_new_Frank.fasta`](./02_clean_headers/headers_Removed_new_Frank.fasta) as the reference for mapping and counting.
  - [`eggnog_15protein.emapper.annotations.txt`](./03_annotation/eggnog_15protein.emapper.annotations.txt) as the functional annotation file.

---

## 👤 Author

**Xuhui Huang**

---

📌 *This README was generated with the assistance of ChatGPT. Content has been verified by the author.  
If any error is found, please contact the author directly.*
