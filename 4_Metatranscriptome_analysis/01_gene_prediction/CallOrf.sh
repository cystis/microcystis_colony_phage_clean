# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J MetaGeneMark2_LT2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=20GB
#SBATCH --time=12:00:00
#SBATCH --error=LT_2024_MetaGeneMark_results.error
#SBATCH --output=LT_2024_MetaGeneMark_results.out
#SBATCH --mail-user=
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module purge

eval "$(conda shell.bash hook)"

# Run MetaGeneMark with the specified parameters
 /lustre/isaac/proj/UTK0002/SOFTWARES/MetaGeneMark_linux_64/./gmhmmp \
  -m /lustre/isaac/proj/UTK0002/SOFTWARES/MetaGeneMark_linux_64/MetaGeneMark_v1.mod \
  -o /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/LT_2024_all.gff3 \
  -f 3 \
  -a \
  -A /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/LT_2024_all_proteins.faa \
  -d \
  -D /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/LT_2024_all_nucleic.fna \
  /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/headers_Removed_LT_2024_coassembly
