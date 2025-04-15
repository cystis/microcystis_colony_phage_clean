# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J cdhit_frankenstein
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=20GB
#SBATCH --time=12:00:00
#SBATCH --error=cdhit.error
#SBATCH --output=cdhit.out
#SBATCH --mail-user=[your_e-mail]
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"

cd /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/cd-hit/cdhit

./cd-hit-est -i /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/newfrank2/total15genome.fna \
-o /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/newfrank2/Frankenstein_microcystis_0.95_2024.fna -c 0.95 -M 20000 -T 10 -d 0 -G 1
