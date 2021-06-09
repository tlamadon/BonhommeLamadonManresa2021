BonhommeLamadonManresa2021
==========================

Replication code for: "Discretizing Unobserved Heterogeneity", by
Bonhomme, Lamadon and Manresa

Download the latest zip file with all results and source code:
https://github.com/tlamadon/BonhommeLamadonManresa2021/raw/main/BonhommeLamadonManresa2021.zip


Code content
------------

There are two parts to the code:

 1. The matlab folder contains the matlab routines that run the Monte-Carlo 
    simulations. Each of the "Code" files can be run directly by itself. 
    Each file sets default values for each of the parameters, however these 
    can be overwritten by the user.
    We provide a makefile that can run all the simulations. If Matlab is installed, 
    you should be able to run `make sims` from within the top folder. This will generate the 
    "mat" files in the "results" folder.

 2. The python folder provides routines that take the "mat" files output and generate
    the figures in the paper. This requires some depdencies to run. You can either:
    -   install then by using the provided conda environment file:
        `conda env create --file conda-env.yml` and then activating `blm2-env`
    -   install them through pip with `pip install numpy pandas matplotlib tqdm seaborn scipy`
    You can then type `make all` which should generate the pdf figure files, the tex files 
    for the tables and the pdf generated from the tex files (provided you have 
    a working version of latex).

Generated Figures:
------------------

 - Figure 1 (results/fig-tiselection-bias.pdf)
 - Figure 2 (results/fig-tvprobit-bias.pdf)
 - Table S1 (results/tab-tiselection-param-n1000-alone.pdf)
 - Table S2 (results/tab-tvprobit-param-n1000-alone.pdf)
 - Table S3 (results/tab-tiprobit-alone.pdf)


Additional information:
-----------------------

The repository BonhommeLamadonManresa2021 (https://github.com/tlamadon/BonhommeLamadonManresa2021)
contains all the code to replicate the results presented in the paper. As an alternative we provide 
a separate repository pygrpge (https://github.com/tlamadon/pygrpfe)
with a pip package and notebooks written in python to reproduce the
results from the first model of the paper. You can launch the notebook
either on google colab or using binder:

 - Open In Colab (https://colab.research.google.com/drive/1LJAdsWNX279G4T1aYI9fP5Qz2xiRJiff?usp=sharing)
 - Open in Binder (https://mybinder.org/v2/gh/tlamadon/pygrpfe/HEAD?filepath=docs-src%2Fnotebooks%2Fnb-gfe-example1.ipynb)


Matlab code details
-------------------

The matlab folder contains 6 matlab files:

-   `Code_Earnings_Time_Invariant.m` replicates Figure 1 in the paper
    and Table S1 in the Supplemental Material

-   `Code_Probit_Time_Varying.m` replicates Figure 2 in the paper and
    Table S2 in the Supplemental Material

-   `Code_Probit_Time_Invariant_BinaryCov.m` replicates Table S3 in the
    Supplemental Material

-   `lik.m`, `lik_bb.m`, and `lik_IFE2.m` are functions to compute the
    likelihood function and scores & hessians of probit models.

Final notes
-----------

Thank you for using our codes.

For any feeback, please contact:

-   Stephane at sbonhomme\@uchicago.edu
-   Thibaut at lamadon\@uchicago.edu
-   Elena at elena.manresa\@nyu.edu