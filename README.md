<img src="https://github.com/AnantharamanLab/METABOLIC/blob/master/METABOLIC.jpg" width="85%">


# METABOLIC (maintained fork)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](https://bioconda.github.io/recipes/metabolic-cg/README.html)
[![bioconda version](https://img.shields.io/conda/vn/bioconda/metabolic-cg.svg)](https://anaconda.org/bioconda/metabolic-cg)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
 
**MET**abolic **A**nd **B**ioge**O**chemistry ana**L**yses **I**n mi**C**robes
Current version: **4.1.1** (based on upstream METABOLIC v4.0)
 
> **About this repository**
>
> METABOLIC was developed by Zhichao Zhou, Patricia Q. Tran, Karthik Anantharaman and colleagues in the
> [Anantharaman Lab](https://github.com/AnantharamanLab) (University of Wisconsin–Madison). The original
> source code is at **[AnantharamanLab/METABOLIC](https://github.com/AnantharamanLab/METABOLIC)**, and the
> method is described in [Zhou et al., *Microbiome* 2022](https://doi.org/10.1186/s40168-021-01213-8).
> All scientific credit for METABOLIC belongs to the original authors — **if you use it, please cite their
> paper** (see [Citation](#citation)).
> >
> This fork is maintained by Andreea Mlesniță ([@AndaMM](https://github.com/AndaMM)), with the agreement of the
> original developers, to keep METABOLIC installable and runnable on current systems. It is the source of the
> Bioconda package [`metabolic-cg`](https://bioconda.github.io/recipes/metabolic-cg/README.html).
> The analyses and outputs are those of the original METABOLIC; the changes concern installation, database
> handling and a few bug fixes:
>
> - one-command installation from Bioconda (`metabolic-cg`);
> - databases can live anywhere on disk (`-db-dir` or `METABOLIC_DB_DIR`) and are set up with `-download-db`;
> - GTDB-Tk is no longer run inside METABOLIC-C — you run it separately and pass its output with `-gtdbtk-dir`;
> - updated, unpinned Perl dependencies; fixes for silent failures (see [CHANGELOG.md](CHANGELOG.md)).
>
> Please report problems with this version in the [issues of this repository](https://github.com/AndaMM/METABOLIC/issues),
> not upstream.


## What METABOLIC does

This software enables the prediction of metabolic and biogeochemical functional trait profiles to any given genome datasets. These genome datasets can either be metagenome-assembled genomes (MAGs), single-cell amplified genomes (SAGs) or isolated strain sequenced genomes. METABOLIC has two main implementations, which are METABOLIC-G and METABOLIC-C. METABOLIC-G.pl allows for generation of metabolic profiles and biogeochemical cycling diagrams of input genomes and does not require input of sequencing reads. METABOLIC-C.pl generates the same output as METABOLIC-G.pl, but as it allows for the input of metagenomic read data, it will generate information pertaining to community metabolism. It can also calculate the genome coverage. The information is parsed and diagrams for elemental/biogeochemical cycling pathways (currently Nitrogen, Carbon, Sulfur and "other") are produced.  

| Program Name|Program Description |
|---|---|
|METABOLIC-G.pl|Allows for classification of the metabolic capabilities of input genomes. |
|METABOLIC-C.pl|Allows for classification of the metabolic capabilities of input genomes, <br />calculation of genome coverage, creation of biogeochemical cycling diagrams,<br /> and visualization of community metabolic interactions and contribution to biogeochemical processes by each microbial group. |
<br>

Slides of introducing METABOLIC (for a C-DEBI series meeting presentation) were provided here: (https://github.com/AnantharamanLab/METABOLIC/blob/master/METABOLIC_C-DEBI_slides.pdf) 

## Quick start
 
### 1. Install
 
**Option A — Bioconda (recommended)**
 
```bash
conda create -n metabolic -c conda-forge -c bioconda metabolic-cg
conda activate metabolic
METABOLIC-G.pl -v
```
 
The scripts (`METABOLIC-G.pl`, `METABOLIC-C.pl`, `METABOLIC-C.2nd_run.pl`) are on your `PATH`, so call them
directly, without `perl` in front.
 
**Option B — from source**
 
```bash
git clone https://github.com/AndaMM/METABOLIC.git
cd METABOLIC
conda env create -f env.yml
conda activate metabolic_env
perl METABOLIC-G.pl -v
```
 
GTDB-Tk is **not** included in either option. It is only needed for METABOLIC-C; install it in a separate
environment (see step 3.2).
 
### 2. Set up the databases (once)
 
The databases (KOfam, dbCAN2, MEROPS and METABOLIC's own HMMs) take several GB. Choose a location outside
the conda environment and download them there:
 
```bash
export METABOLIC_DB_DIR=/path/to/metabolic_db
METABOLIC-C.pl -db-dir "$METABOLIC_DB_DIR" -download-db
```
 
`-download-db` exits after setup and is safe to re-run; it skips databases that are already present.
To avoid typing `-db-dir` every time, store the variable in the environment:
 
```bash
conda env config vars set METABOLIC_DB_DIR=/path/to/metabolic_db
conda activate metabolic   # re-activate so the variable is loaded
```
 
> **Bioconda users:** always set `-db-dir` or `METABOLIC_DB_DIR`. Without it, METABOLIC uses the directory the
> script is in, which for a conda install is the environment's `bin/` folder.
 
### 3. Run
 
**3.1 Genomes only (`METABOLIC-G.pl`)**
 
```bash
METABOLIC-G.pl -in-gn /path/to/genomes -o METABOLIC_out -t 16
```
 
**3.2 Genomes + metagenomic reads (`METABOLIC-C.pl`)**
 
First run GTDB-Tk on the same genomes, once per genome set, in its own environment:
 
```bash
gtdbtk classify_wf --cpus 16 -x fasta --genome_dir /path/to/genomes \
  --skip_ani_screen --out_dir /path/to/gtdbtk_out
```
 
Then run METABOLIC-C:
 
```bash
METABOLIC-C.pl -in-gn /path/to/genomes -r omic_reads_parameters.txt \
  -gtdbtk-dir /path/to/gtdbtk_out -o METABOLIC_out -t 16
```
 
`omic_reads_parameters.txt` lists one read pair per line, as `forward_reads.fastq,reverse_reads.fastq`.
 
If you installed from source, prefix the commands with `perl` (for example, `perl METABOLIC-G.pl ...`).
 
### 4. Test run (optional)
 
The upstream test dataset cannot be downloaded from the command line. Download it in a browser from
<https://figshare.com/ndownloader/files/43500597>, unzip it, and run:
 
```bash
METABOLIC-C.pl -test true -test-files-dir /path/to/METABOLIC_test_files \
  -gtdbtk-dir /path/to/gtdbtk_out
```
 
## Documentation
 
Run `-help` on any script for the full option list (press `q` to exit).
The [upstream wiki](https://github.com/AnantharamanLab/METABOLIC/wiki) is still the best reference for the
inputs, outputs and interpretation of results. Its **installation** and **database setup** sections do not
apply to this fork; use the Quick start above instead. The wiki also does not cover `-db-dir`,
`-download-db`, `-test-files-dir` or `-gtdbtk-dir`.
 
## Citation
 
If you use METABOLIC, please cite the original paper:
 
> Zhou, Z., Tran, P.Q., Breister, A.M. et al. METABOLIC: high-throughput profiling of microbial genomes for
> functional traits, metabolism, biogeochemistry, and community-scale functional networks.
> *Microbiome* 10, 33 (2022). https://doi.org/10.1186/s40168-021-01213-8
 
If the Bioconda package or the changes in this fork were useful, you can also mention this repository
(https://github.com/AndaMM/METABOLIC, v4.1.1).
 
## License
 
GPL-3.0, as in the original project. See [LICENSE](LICENSE).


