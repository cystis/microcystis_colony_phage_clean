# NOTE: This SLURM batch script was used on the ISAAC cluster at UTK.
# Adjust paths and job settings as needed for your own environment.
#!/bin/bash
#SBATCH -J Merge_2024_LT
#SBATCH -A ISAAC-UTK0002
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=50GB
#SBATCH --time=24:00:00
#SBATCH --error=Merge_2024_LT.error
#SBATCH --output=Merge_2024_LT.out
#SBATCH --mail-user=[your_email]
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval "$(conda shell.bash hook)"

input_path="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/TRIM_TEST3/"
output_path="/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/MERGED_READS/"

conda activate /lustre/isaac/proj/UTK0002/conda/envs/TAIHU

for r1_file in ${input_path}*_R1.trimmed.fastq.gz
do
  sample_name=$(basename $r1_file | sed 's/_R1\.trimmed\.fastq\.gz//')

  r2_file=${input_path}${sample_name}_R2.trimmed.fastq.gz

  reformat.sh in1=$r1_file in2=$r2_file out=${output_path}${sample_name}.fastq.gz
done

