# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J FCunMicrocystis_LT2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=50GB
#SBATCH --time=24:00:00
#SBATCH --error=LT_FC_results1.error
#SBATCH --output=LT_FC_results1.out
#SBATCH --mail-user=
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"

conda activate /lustre/isaac/proj/UTK0002/conda/envs/Featurecounts

# Define input and output directories:

INPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/meta_SAM"

OUTPUT_DIR="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/meta_FC"

# Run FeatureCounts, write the results into one file

featureCounts -a /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/LT_2024_all.gff3 -p -t gene -g ID -o "$OUTPUT_DIR/TAIHU_all_featurecounts1.txt" /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/meta_SAM/*.sam

