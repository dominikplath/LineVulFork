#!/bin/bash -l
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dominik.plath@tuhh.de

#SBATCH --time 6-23:00:00
#SBATCH --gres gpu:2
#SBATCH --mem-per-gpu 75000
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
#SBATCH --output output/aug-codellama-34b/test/test_on_gpt-4o.log

echo "========================= LAUNCH SCRIPT: ==========================="
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
cat launch_scripts/aug-codellama-34b/test/test_comparison_on_gpt-4o.sh
echo "===================================================================="

# Load anaconda
module load anaconda/2023.07-1
conda activate vuln-synth

gpt_4o_full=../data/gpt-4o/full.csv

model_name=model.bin

# Define W&B names
wandb_names=(
	"big-vul"
	"vgx"
	"codellama-34b"
	"big-vul_vgx"
	"big-vul_codellama-34b"
	"vgx_codellama-34b"
	"big-vul_vgx_codellama-34b"
)

# Thresholds of the respective models
thresholds=(
	0.8611069917678833
	0.99999737739563
	0.404173880815506
	0.9943479895591736
	0.2426611036062241
	0.6036250591278076
	0.39572638273239136
)

# Define base output directory
base_output_dir=../artefacts/aug-codellama-34b/comparison

# Define base name of W&B runs
base_wandb_name="comparison/gpt-4o-test"

# Define W&B notes
wandb_note="One of the test runs on the full GPT-4o dataset of a model that resulted from the CodeLlama augmentation."

cd linevul

for (( idx=0 ; idx < ${#wandb_names[@]} ; idx++ ))
do
	full_wandb_name="${base_wandb_name}/${wandb_names[idx]}"
	output_dir="${base_output_dir}/${wandb_names[idx]}"
	threshold="${thresholds[idx]}"

	python linevul_main.py \
		--model_name=$model_name \
		--output_dir=$output_dir \
		--model_type=roberta \
		--tokenizer_name=microsoft/codebert-base \
		--model_name_or_path=microsoft/codebert-base \
		--do_test \
		--test_data_file ${gpt_4o_full} \
		--epochs 10 \
		--block_size 512 \
		--train_batch_size 16 \
		--eval_batch_size 16 \
		--learning_rate 2e-5 \
		--max_grad_norm 1.0 \
		--evaluate_during_training \
		--threshold_for_testing ${threshold} \
		--wandb_name "${full_wandb_name}" \
		--wandb_notes "${wandb_note}" \
		--seed 123456  2>&1

	done
