from pathlib import Path
import itertools
from snakemake.utils import min_version

min_version("5.4.0")

# ======================================================
# Config files
# ======================================================
configfile: "config.yaml"

# ======================================================
# Functions
# ======================================================


# ======================================================
# Variables
# ======================================================
sample_data_dir = config["sample_data_dir"]
msas_dir = config["msas_dir"]
prgs_dir = config["prgs_dir"]
analysis_output_dir = config["analysis_output_dir"]
msas_csv = config["msas_csv"]
samples = config["samples"]


output_files = []
for technology, sample, coverage, strategy in itertools.product(
                                                    config["technologies"],
                                                    config["samples"],
                                                    config["coverages"],
                                                    config["subsample"]["strategies"]):
    output_files.extend([
        f"{analysis_output_dir}/{technology}/{coverage}x/{strategy}/{sample}/map_with_discovery",
        f"{analysis_output_dir}/{technology}/{coverage}x/{strategy}/prgs/denovo_updated.prg.fa",
        f"{analysis_output_dir}/{technology}/{coverage}x/{strategy}/compare_no_denovo/pandora_multisample_genotyped.vcf",
        f"{analysis_output_dir}/{technology}/{coverage}x/{strategy}/compare_with_denovo/pandora_multisample_genotyped.vcf",
    ])


# deduplicate
output_files = list(set(output_files))

# ======================================================
# Rules
# ======================================================
rule all:
    input:
         output_files

rules_dir = Path("rules/")
include: str(rules_dir / "subsample.smk")
include: str(rules_dir / "index.smk")
include: str(rules_dir / "map.smk")
include: str(rules_dir / "create_new_prg.smk")
include: str(rules_dir / "compare.smk")
