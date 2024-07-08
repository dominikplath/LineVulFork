#!/bin/zsh

cd linevul
python linevul_main.py \
	--model_name=data_v2_finetuned_linevul.bin \
	--output_dir=./finetuned_models \
	--finetune_base_model=./saved_models/checkpoint-best-f1/12heads_linevul_model.bin \
	--model_type=roberta \
	--tokenizer_name=microsoft/codebert-base \
	--model_name_or_path=microsoft/codebert-base \
	--do_finetune \
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

# 
