# BonhommeLamadonManresa2021
Replication code for: "Discretizing Unobserved Heterogeneity", by Bonhomme, Lamadon and Manresa

Download the latest zip file with all results and source code: [![Generic badge](https://img.shields.io/badge/Download-zip-green.svg)](https://github.com/tlamadon/BonhommeLamadonManresa2021/raw/main/BonhommeLamadonManresa2021.zip)

This repository [![BonhommeLamadonManresa2021](https://badgen.net/badge//gh/BonhommeLamadonManresa2021?icon=github)](https://github.com/tlamadon/BonhommeLamadonManresa2021)  contains all the code to replicate the results presented in the paper. Reproducing the results should be close to be as simple as typing `make all` in your terminal. See however the require dependencies below.

As an alternative we provide a separate repository [![pygrpge](https://badgen.net/badge//gh/pygrpfe?icon=github)](https://github.com/tlamadon/pygrpfe) with a pip package and notebooks written in python to reproduce the results from the first model of the paper. You can launch the notebook either on google colab or using binder:


 - [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1LJAdsWNX279G4T1aYI9fP5Qz2xiRJiff?usp=sharing)
 - [![Binder](https://binder.pangeo.io/badge_logo.svg)](https://mybinder.org/v2/gh/tlamadon/pygrpfe/HEAD?filepath=docs-src%2Fnotebooks%2Fnb-gfe-example1.ipynb)

## Generated figures:

 - [Figure 1](https://github.com/tlamadon/BonhommeLamadonManresa2021/blob/main/results/fig-tiselection-bias.pdf)
 - [Figure 2](https://github.com/tlamadon/BonhommeLamadonManresa2021/blob/main/results/fig-tvprobit-bias.pdf)
 - [Table S1](https://github.com/tlamadon/BonhommeLamadonManresa2021/blob/main/results/tab-tiselection-param-n1000-alone.pdf)
 - [Table S2](https://github.com/tlamadon/BonhommeLamadonManresa2021/blob/main/results/tab-tvprobit-param-n1000-alone.pdf)
 - [Table S3](https://github.com/tlamadon/BonhommeLamadonManresa2021/blob/main/results/tab-tiprobit-alone.pdf)

## Overview

 - The matlab folder contains the code to generate the simulations used in the
   paper
 - The Makefile can be used to regenerate all the results. Each matlab file can
   also be used to generate individual results where parameters can be changed
easily
 - The results folder contains the results that we generate for the paper using
   the random seed defined in the makefile

## Dependencies

 - To generate the mat files you only need access to matlab. You can use the
   makefile directly with `make sims`
 - To generate the table and plots from the mat files you will need a few
   python dependencies. You can either:
     - install then by using the provided cona environment file: `conda env create --file conda-env.yml` and then activating `blm2-env`
     - install it through pip with `pip install numpy pandas matplotlib tqdm seaborn scipy`
 - To compile the tables you need a working copy of latex. 

## Code content

The matlab folder contains 6 matlab files:

 - `Code_Earnings_Time_Invariant.m` replicates Figure 1 in the paper and Table S1 in
the Supplemental Material

 - `Code_Probit_Time_Varying.m` replicates Figure 2 in the paper and Table S2 in the
Supplemental Material

 - `Code_Probit_Time_Invariant_BinaryCov.m` replicates Table S3 in the Supplemental
Material

 -  `lik.m`, `lik_bb.m`, and `lik_IFE2.m` are functions to compute the likelihood
function and scores & hessians of probit models.

## Final notes

Thank you for using our codes.

For any feeback, please contact: 

 - Stephane at sbonhomme@uchicago.edu
 - Thibaut at lamadon@uchicago.edu
 - Elena at elena.manresa@nyu.edu
