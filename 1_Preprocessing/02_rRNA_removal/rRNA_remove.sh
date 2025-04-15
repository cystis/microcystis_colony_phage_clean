# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J rRNA_remove_LT2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=condo-ut-genomics
#SBATCH --qos=genomics
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=50GB
#SBATCH --time=48:00:00
#SBATCH --error=LT_rrna_results.error
#SBATCH --output=LT_rrna_results.out
#SBATCH --mail-user=[your_email]
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"

conda activate /lustre/isaac/proj/UTK0002/conda/envs/TAIHU

# Define input and output directories:

INPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/MERGED_READS"

OUTPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/rRNA_REMOVED"

# Loop through each file

for LT_FILE in "$INPUT_DIR"/A_*.fastq.gz; do

# Extract the sample name from R1 file name

SAMPLE_NAME=$(basename "$LT_FILE" .fastq.gz)

# Run bbmap

bbmap.sh in="$LT_FILE" ref=/lustre/isaac/proj/UTK0002/ERIE_2023_METS/rRNA_REMOVED/rrna_contam_concat_refs.fa outu="$OUTPUT_DIR/${SAMPLE_NAME}.mRNA.fastq.gz" nodisk maxindel=20 minid=0.93 threads=10

done
