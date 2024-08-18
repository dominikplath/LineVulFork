#!/bin/bash -l
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dominik.plath@tuhh.de

#SBATCH --time 5-23:00:00
#SBATCH --gres gpu:h100:4
#SBATCH --mem-per-gpu 75000
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
#SBATCH --output output/aug-codellama-34b/balanced_codellama-based_nonvul.log

# Load anaconda
module load anaconda/2023.07-1
conda activate vuln-synth

train_data_file=../data/big-vul_dataset/processed_data.csv
test_data_file=../data/vgx/test.csv
aug_train_data_files='
../../llm-based-vulnerability-synthesis/data/enhanced/codellama-34b/proc_and_label_only/15038_sized/15038_data_gen_v2.csv 
../../llm-based-vulnerability-synthesis/data/enhanced/codellama-34b/proc_and_label_only/15038_sized/15038_data_gen_non_vulnerable.csv'
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
model_name=aug-codellama-34b/balanced_codellama-based_nonvul.bin

echo "Using a balanced dataset generated with CodeLlama-34b to fine-tune LineVul"

echo "========================= LAUNCH SCRIPT: ==========================="
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
cat launch_scripts/aug-codellama-34b/balanced_codellama-based_nonvul.sh
echo "===================================================================="

cd linevul
python linevul_main.py \
	--model_name=$model_name \
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
	--train_batch_size 16 \
	--eval_batch_size 16 \
	--learning_rate 2e-5 \
	--max_grad_norm 1.0 \
	--evaluate_during_training \
	--seed 123456  2>&1

