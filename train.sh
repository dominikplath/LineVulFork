#!/bin/zsh

cd linevul
python linevul_main.py \
	--output_dir=./saved_models \
	--model_type=roberta \
	--tokenizer_name=microsoft/codebert-base \
	--model_name_or_path=microsoft/codebert-base \
	--do_train \
	--train_data_file=../../llm-based-vulnerability-synthesis/data/processed/codellama/data_gen_v2.csv \
	--eval_data_file=../../llm-based-vulnerability-synthesis/data/processed/codellama/data_gen_v2.csv \
	--epochs 10 \
	--block_size 512 \
	--train_batch_size 16 \
	--eval_batch_size 16 \
	--learning_rate 2e-5 \
	--max_grad_norm 1.0 \
	--evaluate_during_training \
	--seed 123456  2>&1 | tee train.log

