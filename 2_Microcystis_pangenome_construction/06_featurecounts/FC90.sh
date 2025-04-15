# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J FC90Microcystis_LT2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=50GB
#SBATCH --time=12:00:00
#SBATCH --error=LT_FC_results90.error
#SBATCH --output=LT_FC_results90.out
#SBATCH --mail-user=[your_email]
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"

conda activate /lustre/isaac/proj/UTK0002/conda/envs/Featurecounts

# Define input and output directories:

#INPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/new_m_sam2"

OUTPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/new_m_fc2"

# Run FeatureCounts, write the results into one file

featureCounts -a /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/newfrank2/Frank_microcystis_0.95_2024.gff3 \
 -p -t gene -g ID -o "$OUTPUT_DIR/TAIHU_microcystis_featurecounts90.txt" \
/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/new_m_sam2/*.sam

