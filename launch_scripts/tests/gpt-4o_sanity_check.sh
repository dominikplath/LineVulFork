#!/bin/bash

output_dir=../artefacts/gpt-4o_sanity_check
model_name=gpt-4o_sanity_check.bin

log_file_path=../output/test/gpt-4o_sanity_check.log 
# log_file_path=../output/test/new_gpt-4o_sanity_check.log 

train_data_file='../data/gpt-4o/vuln/val.csv ../data/big-vul_dataset/val_small.csv'
test_data_file='../data/big-vul_dataset/val_small.csv ../data/big-vul_dataset/val_small.csv'

epochs=1

# W&B Config
wandb_notes="This is a sanity check, using a small subset of data."

cd linevul
python -u linevul_main.py \
  --model_name=$model_name \
  --output_dir=$output_dir \
  --model_type=roberta \
  --tokenizer_name=microsoft/codebert-base \
  --model_name_or_path=microsoft/codebert-base \
  --do_train \
  --do_test \
  --train_data_file $train_data_file \
  --eval_data_file $train_data_file \
  --test_data_file $test_data_file \
  --epochs $epochs \
  --block_size 512 \
  --train_batch_size 16 \
  --eval_batch_size 16 \
  --learning_rate 2e-5 \
  --max_grad_norm 1.0 \
  --evaluate_during_training \
  --wandb_notes "$wandb_notes" \
  --seed 123456 > $log_file_path 2>&1 
