#!/bin/bash -l
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dominik.plath@tuhh.de
#SBATCH --time 6-23:00:00

#SBATCH --gres gpu:1
#SBATCH --mem-per-gpu 75000
#SBATCH --output output/batch_size_test.log

# Load anaconda
module load anaconda/2023.07-1
conda activate vuln-synth

nproc_per_node=1
batch_sizes=(16 32 64 128)

cd linevul

for batch_size in ${batch_sizes[@]}
do
	echo \*\* Testing Batch Size $batch_size \*\*
	echo

	torchrun --nproc_per_node $nproc_per_node linevul_main.py \
	  --output_dir=./saved_models \
	  --model_type=roberta \
	  --tokenizer_name=microsoft/codebert-base \
	  --model_name_or_path=microsoft/codebert-base \
	  --do_train \
	  --do_test \
	  --train_data_file=../data/big-vul_dataset/train.csv \
	  --eval_data_file=../data/big-vul_dataset/val.csv \
	  --test_data_file=../data/big-vul_dataset/test.csv \
	  --epochs 1 \
	  --block_size 512 \
	  --train_batch_size $batch_size \
	  --eval_batch_size $batch_size \
	  --learning_rate 2e-5 \
	  --max_grad_norm 1.0 \
	  --evaluate_during_training \
	  --seed 123456 2>&1 
done	
