# Raw Read Preprocessing

This directory contains scripts and information for preprocessing raw metatranscriptomic reads, including quality trimming, merging paired-end reads, and removing residual rRNA.

---

## 🧬 Workflow Steps

### Step 1: `00_trimming/`
- `fastp.sh`: Performs adapter trimming and quality filtering using **fastp**.

---

### Step 2: `01_merge_R1_R2/`
- `MERGE.sh`: Merges paired-end reads into interleaved format using `reformat.sh` from **BBTools**.

---

### Step 3: `02_rRNA_removal/`
- `rRNA_remove.sh`: Removes residual rRNA by mapping reads to a reference rRNA database using `bbmap.sh` from **BBTools**.

---

## 📎 Notes

- These preprocessing steps are essential before metatranscriptome assembly and gene quantification.
- Scripts were run on a Linux-based HPC system.
- Sample-specific paths and file names may need to be adapted to local environments.

---

## 👤 Author

**Xuhui Huang**

---

📌 *This README was generated with the assistance of ChatGPT. Content has been verified by the author.  
If any error is found, please contact the author directly.*
