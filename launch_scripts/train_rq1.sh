#!/bin/bash -l
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dominik.plath@tuhh.de

#SBATCH --time 5-23:00:00
#SBATCH --gres gpu:4
#SBATCH --mem-per-gpu 75000
#SBATCH --output output/rq1_repl.txt

# Load anaconda
module load anaconda/2023.07-1
conda activate vuln-synth

nproc_per_node=4

cd linevul
torchrun --nproc-per-node $nproc_per_node linevul_main.py \
	--output_dir=./saved_models \
	--model_type=roberta \
	--tokenizer_name=microsoft/codebert-base \
	--model_name_or_path=microsoft/codebert-base \
	--do_train \
	--do_test \
	--train_data_file=../data/big-vul_dataset/train.csv \
	--eval_data_file=../data/big-vul_dataset/val.csv \
	--test_data_file=../data/big-vul_dataset/test.csv \
	--epochs 10 \
	--block_size 512 \
	--train_batch_size 16 \
	--eval_batch_size 16 \
	--learning_rate 2e-5 \
	--max_grad_norm 1.0 \
	--evaluate_during_training \
	--seed 123456  2>&1

