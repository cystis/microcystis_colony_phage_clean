# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J eggNOG_BACT_2024
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=condo-ut-genomics
#SBATCH --qos=genomics
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=200GB
#SBATCH --time=48:00:00
#SBATCH --error=LT_2024_eggNOG.error
#SBATCH --output=LT_2024_eggNOG.out
#SBATCH --mail-user=
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"
cd /lustre/isaac/proj/UTK0002/SOFTWARES/eggnog-mapper-2.1.12/

./emapper.py --cpu 10 \
             -i /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/LT_2024_all_proteins.faa \
             --output /lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/metatranscript/eggnog_output \
             -m diamond --evalue 1e-10 --excel --pfam_realign denovo
