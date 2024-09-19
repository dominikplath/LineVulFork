log_file_path=../output/test/sanity_check_train_eval.log 

cd linevul
python -u linevul_main.py \
  --model_name=sanity_check_train_eval.bin \
  --output_dir=./saved_models \
  --model_type=roberta \
  --tokenizer_name=microsoft/codebert-base \
  --model_name_or_path=microsoft/codebert-base \
  --do_train \
  --do_test \
  --train_data_file ../data/big-vul_dataset/val_small.csv \
  --eval_data_file ../data/big-vul_dataset/val_small.csv \
  --test_data_file ../data/big-vul_dataset/val_small.csv \
  --epochs 2 \
  --block_size 512 \
  --train_batch_size 16 \
  --eval_batch_size 16 \
  --learning_rate 2e-5 \
  --max_grad_norm 1.0 \
  --evaluate_during_training \
  --seed 123456 > $log_file_path 2>&1 
