# BonhommeLamadonManresa2021
Replication code for: "Discretizing Unobserved Heterogeneity", by Bonhomme, Lamadon and Manresa

Please also look at additional source code for the approach that we provide at
 [group fixed effect in python](https://github.com/tlamadon/pygrpfe). This repo
offers interactive tutorial that solve the models presented in the paper. 

## Overview

 - The matlab folder contains the code to generate the simulations used in the
   paper
 - The Makefile can be used to regenrate all the results. Each matlab file can
   also be used to generate individual results where parameters can be changed
easily
 - The results folder contains the results that we generate for the paper using
   the random seed defined in the makefile

## Dependencies

 - To generate the mat files you only need access to matlab. You can use the
   makefile directly with `make sims`
 - To generate the table and plots from the mat files you will need a few
   python dependencies. The easiest way to install then is to use the provided
conda environement file. `conda -f env.yml`
 - To compile the tables you need a working copy of latex. 

## Content

The matlab folder contains 6 matlab files:

 - Code_Earnings_Time_Invariant.m replicates Figure 1 in the paper and Table S1 in
the Supplemental Material

 - Code_Probit_Time_Varying.m replicates Figure 2 in the paper and Table S2 in the
Supplemental Material

 - Code_Probit_Time_Invariant_BinaryCov.m replicates Table S3 in the Supplemental
Material

 -  lik.m, lik_bb.m, and lik_IFE2.m are functions to compute the likelihood
function and scores & hessians of probit models

## Preview of results:

![Earnings](results/fig-tiselection-bias.pdf?raw=true "Optional Title")

## Final notes

Thank you for using our codes.

For any feeback, please contact 
Stephane at sbonhomme@uchicago.edu
Thibaut at lamadon@uchicago.edu
or Elena at elena.manresa@nyu.edu
