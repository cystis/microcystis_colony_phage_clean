# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J bbmap1_META_LT2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=50GB
#SBATCH --time=12:00:00
#SBATCH --error=LT_meta_results1.error
#SBATCH --output=LT_meta_results1.out
#SBATCH --mail-user=
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"

conda activate /lustre/isaac/proj/UTK0002/conda/envs/TAIHU

# Define input and output directories:

INPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/rRNA_REMOVED"

OUTPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/meta_SAM"

# Loop through each file

for LT_FILE in "$INPUT_DIR"/A_*.fastq.gz; do

# Extract the sample name from R1 file name

SAMPLE_NAME=$(basename "$LT_FILE" .mRNA.fastq.gz)

bbmap.sh \
    in="$LT_FILE" \
    ref="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/headers_Removed_LT_2024_coassembly" \
    out="$OUTPUT_DIR/${SAMPLE_NAME}.sam" \
    nodisk=true \
    interleaved=true \
    ambiguous=random \
    fastareadlen=500 \
    threads=auto \
    maxindel=20 minid=0.90 \
    covstats="$OUTPUT_DIR/covstats/${SAMPLE_NAME}.mapped.txt"
done
