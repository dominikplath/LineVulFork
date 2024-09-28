#!/bin/bash -l
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dominik.plath@tuhh.de

#SBATCH --time 6-23:00:00
#SBATCH --gres gpu:2
#SBATCH --mem-per-gpu 75000
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
#SBATCH --output output/aug-gpt-4o/gpt-4o_comparison.log

echo "========================= LAUNCH SCRIPT: ==========================="
# TODO: CHANGE BEFORE RUNNING COPY-PASTED LAUNCH SCRIPT
cat launch_scripts/aug-gpt-4o/gpt-4o_comparison.sh
echo "===================================================================="

# Load anaconda
module load anaconda/2023.07-1
conda activate vuln-synth

# Directories containing the respective datasets
big_vul_dir=../data/big-vul_dataset
vgx_dir=../data/vgx
ours_dir=../data/gpt-4o
reveal_dir=../data/ReVeal

# Names of the CSV files within the directory of any given dataset
train_csv_name=train.csv
val_csv_name=val.csv
test_csv_name=test.csv
full_csv_name=full.csv

# Paths to all Big-Vul data files
big_vul_train=${big_vul_dir}/${train_csv_name}
big_vul_val=${big_vul_dir}/${val_csv_name}
big_vul_test=${big_vul_dir}/${test_csv_name}
big_vul_full=${big_vul_dir}/${full_csv_name}

# Paths to all VGX data files
vgx_train=${vgx_dir}/${train_csv_name}
vgx_val=${vgx_dir}/${val_csv_name}
vgx_test=${vgx_dir}/${test_csv_name}
vgx_full=${vgx_dir}/${full_csv_name}

# Paths to all files generated by us
ours_train=${ours_dir}/${train_csv_name}
ours_val=${ours_dir}/${val_csv_name}
ours_test=${ours_dir}/${test_csv_name}
ours_full=${ours_dir}/${full_csv_name}

# Path to the ReVeal test file
reveal_test=${reveal_dir}/${test_csv_name}

train_datasets=(
	"${ours_train}"

	"${big_vul_train}
	${ours_train}"

	"${vgx_train}
	${ours_train}"

	"${big_vul_train}
	${vgx_train}
	${ours_train}"
)

val_datasets=(
	"${ours_val}"

	"${big_vul_val}
	${ours_val}"

	"${vgx_val}
	${ours_val}"

	"${big_vul_val}
	${vgx_val}
	${ours_val}"
)

test_datasets=(
	"${big_vul_full}
	${vgx_full}
	${ours_test}"

	"${big_vul_test}
	${vgx_full}
	${ours_test}"

	"${big_vul_full}
	${vgx_test}
	${ours_test}"

	"${big_vul_test}
	${vgx_test}
	${ours_test}"
)

model_name=model.bin

# Define W&B names
wandb_names=(
	"gpt-4o"
	"big-vul_gpt-4o"
	"vgx_gpt-4o"
	"big-vul_vgx_gpt-4o"
)

# Define base output directory
base_output_dir=../artefacts/aug-gpt-4o/comparison

# Define base name of W&B runs
base_wandb_name="comparison"

# Define W&B notes
wandb_note="One of the runs that train LineVul with various training sets. Dynamically determines the decision threshold on the validation set. Tested on independent data, using a split-off portion for those datasets that are contained in training, and the full dataset for those that are not. Also tests on the VGX-provided ReVeal test set. Refer to the run name for the datasets included in the training set."

cd linevul

for (( idx=0 ; idx < ${#train_datasets[@]} ; idx++ ))
do
	full_wandb_name="${base_wandb_name}/${wandb_names[idx]}"
	output_dir="${base_output_dir}/${wandb_names[idx]}"

	python linevul_main.py \
		--model_name=$model_name \
		--output_dir=$output_dir \
		--model_type=roberta \
		--tokenizer_name=microsoft/codebert-base \
		--model_name_or_path=microsoft/codebert-base \
		--do_train \
		--do_eval \
		--do_test \
		--train_data_file ${train_datasets[idx]} \
		--eval_data_file ${val_datasets[idx]} \
		--test_data_file ${test_datasets[idx]} ${reveal_test} \
		--epochs 10 \
		--block_size 512 \
		--train_batch_size 16 \
		--eval_batch_size 16 \
		--learning_rate 2e-5 \
		--max_grad_norm 1.0 \
		--evaluate_during_training \
		--wandb_name "${full_wandb_name}" \
		--wandb_notes "${wandb_note}" \
		--seed 123456  2>&1

	done
