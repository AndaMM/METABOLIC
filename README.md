<img src="https://github.com/AnantharamanLab/METABOLIC/blob/master/METABOLIC.jpg" width="85%">


# METABOLIC
**MET**abolic **A**nd **B**ioge**O**chemistry ana**L**yses **I**n mi**C**robes  
Current Version: 4.0
Tested on: Ubuntu 18.04.5 LTS (Linux 5.4.0-81-generic x86_64) (Sep 2021)

This software enables the prediction of metabolic and biogeochemical functional trait profiles to any given genome datasets. These genome datasets can either be metagenome-assembled genomes (MAGs), single-cell amplified genomes (SAGs) or isolated strain sequenced genomes. METABOLIC has two main implementations, which are METABOLIC-G and METABOLIC-C. METABOLIC-G.pl allows for generation of metabolic profiles and biogeochemical cycling diagrams of input genomes and does not require input of sequencing reads. METABOLIC-C.pl generates the same output as METABOLIC-G.pl, but as it allows for the input of metagenomic read data, it will generate information pertaining to community metabolism. It can also calculate the genome coverage. The information is parsed and diagrams for elemental/biogeochemical cycling pathways (currently Nitrogen, Carbon, Sulfur and "other") are produced.  

| Program Name|Program Description |
|---|---|
|METABOLIC-G.pl|Allows for classification of the metabolic capabilities of input genomes. |
|METABOLIC-C.pl|Allows for classification of the metabolic capabilities of input genomes, <br />calculation of genome coverage, creation of biogeochemical cycling diagrams,<br /> and visualization of community metabolic interactions and contribution to biogeochemical processes by each microbial group. |
<br>

Slides of introducing METABOLIC (for a C-DEBI series meeting presentation) were provided here: (https://github.com/AnantharamanLab/METABOLIC/blob/master/METABOLIC_C-DEBI_slides.pdf) 

(The carbon fixation pathway automated annotation gets updated - in Appendix)
### Updated usage options (Sept 2026, tested on Ubuntu 24.04 LTS)

A few options have been added to remove paths that were hardcoded relative to the script's own location, and GTDB-Tk is no longer run automatically. <br>
`-db-dir` lets you point METABOLIC at a database directory anywhere on disk (defaults to the directory the script lives in, so existing setups keep working unchanged). You can also set this via the `METABOLIC_DB_DIR` environment variable instead. <br>
`-download-db` downloads and sets up the databases into `-db-dir`, then exits without running an analysis. Safe to re-run — it skips any database that's already present. <br>
`-test-files-dir` lets you point at the METABOLIC test dataset if you've placed it somewhere other than next to the script (the upstream Figshare bundle can only be downloaded via a browser, not the CLI, at the next URL: https://figshare.com/ndownloader/files/43500597). <br>
`-gtdbtk-dir` **(required)** points METABOLIC-C.pl/METABOLIC-C.2nd_run.pl at the output of a `gtdbtk classify_wf` run you've done beforehand. These scripts no longer run GTDB-Tk themselves — GTDB-Tk has its own large, independently-versioned reference database and dependency chain, so it must always be run separately first, e.g.:
```
gtdbtk classify_wf --cpus <N> -x fasta --genome_dir path/to/genomes --skip_ani_screen --out_dir path/to/gtdbtk_out
```


<br>
<br>

If you are using this program, please consider citing the original paper, available at [Microbiome](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-021-01213-8):
```
Zhou, Z., Tran, P.Q., Breister, A.M. et al. METABOLIC: high-throughput profiling of microbial genomes for functional traits, metabolism, biogeochemistry, and community-scale functional networks. Microbiome 10, 33 (2022). https://doi.org/10.1186/s40168-021-01213-8
```
<br>
<br>

## Installing and using METABOLIC

For general background and full option reference, see the upstream project wiki: <br>
https://github.com/AnantharamanLab/METABOLIC/wiki<br>
(Note: the wiki doesn't cover this fork's `-db-dir`/`-download-db`/`-gtdbtk-dir` options above — use the quickstart below for those.)

### 1. Set up the environment and activate it

```
conda env create -f env.yml
```

### 2. Set up the databases (once)

```
perl METABOLIC-C.pl -db-dir /path/to/databases -download-db
```

Or point `-db-dir` (or `$METABOLIC_DB_DIR`) at a database directory you've already built.



### 3. Run METABOLIC

3.1. Genomes only, no reads (`METABOLIC-G.pl`):
```
perl METABOLIC-G.pl -db-dir /path/to/databases -in-gn /path/to/genomes -o METABOLIC_out
```

3.2. Genomes + metagenomic reads, for community metabolism and coverage (`METABOLIC-C.pl`):
3.2.1. Run GTDB-Tk on your genomes (once per genome set) - in another GTDB-Tk environment

```
gtdbtk classify_wf --cpus <N> -x fasta --genome_dir /path/to/genomes --skip_ani_screen --out_dir /path/to/gtdbtk_out
```
3.2.2. Run METABOLIC on your genomes + reads
```
perl METABOLIC-C.pl -db-dir /path/to/databases -in-gn /path/to/genomes \
  -r omic_reads_parameters.txt -gtdbtk-dir /path/to/gtdbtk_out -o METABOLIC_out
```

`omic_reads_parameters.txt` is a CSV of `forward_reads.fastq,reverse_reads.fastq`, one pair per line.

### 4. Try it on the bundled test dataset

```
perl METABOLIC-C.pl -db-dir /path/to/databases -test true -gtdbtk-dir /path/to/gtdbtk_out
```

See `-help` on either script for the full option list. Press `q` to exit the help menu. Also check out the official wiki for this tool: https://github.com/AnantharamanLab/METABOLIC/wiki.



