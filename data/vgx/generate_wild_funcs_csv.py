import pandas as pd
import os
import sys
import re

def main():

    wild_funcs_dir = "wild_funcs_gen_linevul"

    src_file_names = []
    processed_funcs = []
    targets = []

    for file_name in os.listdir("wild_funcs_gen_linevul"):
        file_path = os.path.join(wild_funcs_dir, file_name)

        file_name_ending = file_name[-3:]

        if file_name_ending == ".py":
            continue

        with open(file_path, "r") as f:
            processed_func = f.read()

        processed_funcs.append(processed_func)
        src_file_names.append(file_name)

        if file_name[-3:] == "0.c":
            targets.append(0)
        elif file_name[-3:] == "1.c":
            targets.append(1)

    wild_funcs_df = pd.DataFrame({
        "file": src_file_names,
        "processed_func": processed_funcs,
        "target": targets
        })

    wild_funcs_df.to_csv("wild_funcs_gen_linevul.csv", index=False)

if __name__ == "__main__":
    sys.exit(main())
