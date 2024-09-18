#!/bin/bash -l
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dominik.plath@tuhh.de

#SBATCH --time 5-23:00:00
#SBATCH --gres gpu:2
#SBATCH --mem-per-gpu 75000
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
#SBATCH --output output/aug-gpt-4o/vgx-based_nonvuln_clean_15039.log

# Load anaconda
module load anaconda/2023.07-1
conda activate vuln-synth

train_data_file=../data/big-vul_dataset/processed_data.csv
test_data_file=../data/vgx/test.csv
aug_train_data_files='
../../llm-based-vulnerability-synthesis/data/enhanced/gpt-4o/security-extended_enhancement/15039_gpt-4o_vuln.csv
../data/vgx/wild_funcs_neg.csv'
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
model_name=aug-gpt-4o_vgx-based_nonvuln_clean_15039.bin

echo "Using positive samples from GPT-4o and negative samples from VGX to fine-tune LineVul"

echo "========================= LAUNCH SCRIPT: ==========================="
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
cat launch_scripts/aug-gpt-4o/vgx-based_nonvuln_clean_15039.sh
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

