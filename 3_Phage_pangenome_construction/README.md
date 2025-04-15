# Phage Pangenome Construction

This folder contains the final files and outputs from the construction of the phage **nucleotide-based pangenome**, used for mapping and downstream gene expression analysis.

The workflow is similar to Microcystis pangenome construction, except that **nucleotide sequences**  were used for CD-HIT clustering at 95% identity. After clustering, headers were simplified for compatibility with `bbmap`, and a custom GFF3 file was generated for quantification using `featureCounts`.

---

## 📁 Key Files and Their Descriptions

| File Name | Description |
|-----------|-------------|
| **phage_pangenome_0.95_2024.fna** | Clustered phage gene **nucleotide** sequences (output from `cd-hit-est`, identity = 0.95). |
| **phage_pangenome_0.95_2024.fna.clstr** | Cluster information from CD-HIT, showing which genes were grouped together. |
| **headers_Removed_phage_pangenome** | FASTA file with simplified headers, used as reference for mapping (required by `bbmap`). |
| **phage_pangenome.gff3** | Gene annotation file (GFF3 format) for use with `featureCounts`. Coordinates match the cleaned FASTA. |
| **TAIHU_all_featurecounts.txt** | Gene-level read count matrix from mapping 24 rRNA-removed metatranscriptome samples to the phage pangenome.

---

## 🧬 Notes

- CD-HIT clustering was performed on nucleotide sequences using `cd-hit-est` with 95% identity.
- `headers_Removed_phage_pangenome` is the recommended reference for mapping with `bbmap` or similar tools.
- The GFF3 file was generated to match this reference and is compatible with `featureCounts`.
- If needed, `.clstr` can be parsed to explore shared gene content among phage genomes.

---

## 👤 Author

**Xuhui Huang**


---

📌 *This README was generated with the assistance of ChatGPT. Content has been verified by the author.  
If any error is found, please contact the author directly.*
