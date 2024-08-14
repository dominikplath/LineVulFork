import unittest
from unittest.mock import patch
import os
import logging
from argparse import Namespace
from transformers import RobertaTokenizer

from linevul_main import TextDataset

def print_logged_strings(mocked_logger_info):
    for call in mocked_logger_info.call_args_list:
        print(call[0][0])

class TestTextDataset(unittest.TestCase):
    @patch.object(logging.Logger, "info")
    def test_constructor_collects_augmented_samples(self, mocked_logger_info):
        tokenizer = RobertaTokenizer.from_pretrained("microsoft/codebert-base")
        args = Namespace(train_data_file=os.path.join("..", "data", "test_dataset", "train.csv"),
                         aug_train_data_files=[os.path.join("..", "data", "test_dataset", "aug_vul.csv"),
                                               os.path.join("..", "data", "test_dataset", "aug_nonvul.csv")],
                         use_word_level_tokenizer=False,
                         block_size=512)

        train_dataset = TextDataset(tokenizer=tokenizer,
                                    args=args,
                                    file_type="train")

        print_logged_strings(mocked_logger_info)

        # Expect 3 train samples, 1 augmented positive and 1 augmented negative sample
        expected_n_examples = 3 + 1 + 1
        self.assertEqual(expected_n_examples, len(train_dataset))

if __name__ == "__main__":
    unittest.main()
