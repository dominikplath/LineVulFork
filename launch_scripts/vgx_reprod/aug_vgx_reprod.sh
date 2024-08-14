#!/bin/bash -l
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dominik.plath@tuhh.de

#SBATCH --time 5-23:00:00
#SBATCH --gres gpu:3
#SBATCH --mem-per-gpu 75000
#SBATCH --output output/vgx_reprod/aug_vgx/aug_vgx_reprod.log

# Load anaconda
module load anaconda/2023.07-1
conda activate vuln-synth

nproc_per_node=3
batch_size=24
train_data_file=../data/big-vul_dataset/processed_data.csv
test_data_file=../data/vgx/test.csv
aug_train_data_files=../data/vgx/wild_funcs_gen_linevul.csv

echo "Trying to reproduce the F1 score reported in the VGX Paper for LineVul-aug-VGX using the whole BigVul dataset and the VGX-generated data for training"

cd linevul
python linevul_main.py \
	--model_name=model_aug_vgx_reprod.bin \
	--output_dir=./saved_models \
	--model_type=roberta \
	--tokenizer_name=microsoft/codebert-base \
	--model_name_or_path=microsoft/codebert-base \
	--do_train \
	--do_eval \
	--do_test \
	--train_data_file=$train_data_file \
	--eval_data_file=$test_data_file \
	--test_data_file=$test_data_file \
	--aug_train_data_files $aug_train_data_files \
	--epochs 10 \
	--block_size 512 \
	--train_batch_size $batch_size \
	--eval_batch_size $batch_size \
	--learning_rate 2e-5 \
	--max_grad_norm 1.0 \
	--evaluate_during_training \
	--seed 123456  2>&1

