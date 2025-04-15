# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J Kraken2_lt2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=condo-ut-genomics
#SBATCH --qos=genomics
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=400GB
#SBATCH --time=12:00:00
#SBATCH --error=LT_2024_KRAKEN2.error
#SBATCH --output=LT_2024_KRAKEN2.out
#SBATCH --mail-user=
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/KRAKEN2/kraken2-2.1.3/kraken2\
 --db /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/kraken2_database\
 /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/LT_2024_all_nucleic.fna\
 --report /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/Kraken2_LT_2024_full_classification_new.txt --use-names --use-mpa-style --threads 24
