# Metatranscriptome Assembly and Annotation

This directory contains scripts and steps for assembling and annotating the metatranscriptomic co-assembly from 24 RNA-seq samples.

---

## 🧬 Workflow Steps

### Step 1: `00_megahit_assembly/`
- `Coassembly.sh`: Runs `MEGAHIT` to generate the metatranscriptomic **co-assembly**.
- Input reads were concatenated using the `cat` command from 24 rRNA-filtered FASTQ files.

---

### Step 2: `01_gene_prediction/`
- `CallOrf.sh`: Uses **MetaGeneMark** to predict genes from the co-assembly.

---

### Step 3: `02_clean_coassembly_headers/`
- `Remove.py`: Cleans and simplifies FASTA headers in the co-assembly file.
- This step ensures compatibility with mapping tools such as `bbmap`.

---

### Step 4: `03_mapping_to_coassembly/`
- Maps each cleaned sample back to the co-assembly using `bbmap.sh`.
- Output: individual `.sam` files per sample.

---

### Step 5: `04_featurecount/`
- Runs `featureCounts` to generate gene count matrix using `.gff` from gene prediction.

---

### Step 6: `05_functional_annotation/`
- `EggNog.sh`: Annotates predicted proteins using **EggNOG-mapper**.

---

### Step 7: `06_taxonomic_annotation/`
- `KRAKEN1.sh` and `KRAKEN2.sh`: Performs taxonomic annotation using **Kraken2**.
- `merge_kraken.py`: Merges taxonomic annotation outputs.

---

## 📎 Notes

- Co-assembly allows gene-centric quantification across samples.
- All input reads were preprocessed for quality control and rRNA removal prior to assembly.
- Scripts and output may require adaptation for local environments.

---

## 👤 Author

**Xuhui Huang**

---

📌 *This README was generated with the assistance of ChatGPT. Content has been verified by the author.  
If any error is found, please contact the author directly.*
