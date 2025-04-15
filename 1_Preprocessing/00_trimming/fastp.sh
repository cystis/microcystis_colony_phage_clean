# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J fastp_2024LT
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=condo-ut-genomics
#SBATCH --qos=genomics
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=100GB
#SBATCH --time=24:00:00
#SBATCH --error=LT_fastp_results.error
#SBATCH --output=LT_fastp_results.out
#SBATCH --mail-user=[your_email]
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Activate Conda environment
eval "$(conda shell.bash hook)"
conda activate /lustre/isaac/proj/UTK0002/conda/envs/TAIHU/

# Define input and output directories
INPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/RENAMED_RAW_READS"
OUTPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/TRIM_TEST3"

for R1_FILE in "$INPUT_DIR"/A*.R1.raw.fastq.gz; do
    # Extract the sample name from R1 file name
    SAMPLE_NAME=$(basename "$R1_FILE" .R1.raw.fastq.gz)

    # Construct corresponding R2 file path
    R2_FILE="$INPUT_DIR/${SAMPLE_NAME}.R2.raw.fastq.gz"

    # Run fastp with automatic adapter removal for paired-end sequencing
    fastp \
        -i "$R1_FILE" \
        -I "$R2_FILE" \
        -o "$OUTPUT_DIR/${SAMPLE_NAME}_R1.trimmed.fastq.gz" \
        -O "$OUTPUT_DIR/${SAMPLE_NAME}_R2.trimmed.fastq.gz" \
        --detect_adapter_for_pe \
        --thread 10 \
        --qualified_quality_phred 20 \
        --length_required 36 \
        --html "$OUTPUT_DIR/${SAMPLE_NAME}_fastp_report.html" \
        --json "$OUTPUT_DIR/${SAMPLE_NAME}_fastp_report.json"

done

