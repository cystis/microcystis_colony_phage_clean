# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.#!/bin/bash
#SBATCH -J MEGAHIT_BACT_LT2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=condo-ut-genomics
#SBATCH --qos=genomics
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=400GB
#SBATCH --time=24:00:00
#SBATCH --error=LT_bact_coassembly_results.error
#SBATCH --output=LT_bact_coassembly_results.out
#SBATCH --mail-user=
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"

# Navigate to the directory containing MEGAHIT
cd /lustre/isaac/proj/UTK0002/SOFTWARES/MEGAHIT/MEGAHIT-1.2.9-Linux-x86_64-static/bin

# Run MEGAHIT with corrected parameters
./megahit --12 /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/rRNA_REMOVED/TAIHU_2024_all.fastq.gz \
 -o /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/TAIHU_2024_coassembly.megahit\
 --k-min 23 \
 --k-step 10 \
 --k-max 123 \
 -t 24

