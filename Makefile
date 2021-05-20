MATLAB = matlab -nodesktop -nodisplay -nosplash
RS = 634143
NWORKERS = 16
ACTIVATE = /usr/local/python/anaconda3/bin/activate

# common matlab code arguments
MARGS = S=1000; RNG_SEED=$(RS); NWORKERS = $(NWORKERS); 

# create pdfs
results/tab-%.pdf: results/tab-%.tex
	cd results && pdflatex -interaction=nonstopmode $(notdir $<)

# results/tab-earnings-param-n1000-alone.pdf: results/tab-earnings-param-n1000-alone.tex
# 	cd results && pdflatex -interaction=nonstopmode $(notdir $<)


# rules for earnings and participation model
# ------------------------------------------

FILES_EARNINGS_SIMS = \
	results/results_earnings_eta1_N1000.mat \
	results/results_earnings_eta2_N1000.mat

FILES_EARNINGS_FIGS = \
	results/tab-tiselection-param-n1000-alone.pdf \
	results/fig-tiselection-bias.pdf

model_earnings: $(FILES_EARNINGS_SIMS)

results/fig-tiselection-bias.pdf results/tab-tiselection-param-n1000-alone.tex: results/model_earnings.csv python/model_earnings_figures.py
	$(ACTIVATE) blm2-env && cd python && python model_earnings_figures.py

results/results_earnings_eta1_N%.mat: | results
	$(MATLAB) -r "eta=1.000001; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Earnings_Time_Invariant.m'); exit;"

results/results_earnings_eta2_N%.mat: | results
	$(MATLAB) -r "eta=2; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Earnings_Time_Invariant.m'); exit;"

results/model_earnings.csv: $(FILES_EARNINGS_SIMS)
	$(ACTIVATE) blm2-env && cd python && python model_earnings_collect.py

# rules for time varying probits
# ------------------------------

FILES_PROBIT_TV_SIMS = \
	results/results_tv_N1000_rho_m10.mat \
	results/results_tv_N1000_rho_10.mat \
	results/results_tv_N1000_rho_1.mat \
	results/results_tv_N1000_rho_0.mat

FILES_PROBIT_TV_FIGS = \
	results/tab-tvprobit-param-n1000-alone.pdf \
	results/fig-tvprobit-bias.pdf

model_probit_tv: $(FILES_PROBIT_TV_FIGS)

results/fig-tvprobit-bias.pdf results/tab-tvprobit-param-n1000-alone.tex: results/model_probit_tv.csv
	$(ACTIVATE) blm2-env && cd python && python model_probit_tv_figures.py

results/results_tv_N%_rho_m10.mat: | results
	$(MATLAB) -r "rho=-10; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_10.mat: | results
	$(MATLAB) -r "rho=10; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_0.mat: | results
	$(MATLAB) -r "rho=0.000001; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_1.mat: | results
	$(MATLAB) -r "rho=1; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/model_probit_tv.csv: $(FILES_PROBIT_TV_SIMS)
	$(CONDA) activate blm2-env && cd python && python model_probit_tv_collect.py

# rules for conditional
# ---------------------

FILES_PROBIT_TI_SIMS = \
	results/results_cond_cov1.mat \
	results/results_cond_cov2.mat \
	results/results_cond_cov3.mat 

FILES_PROBIT_TI_FIGS = \
	results/tab-tiprobit-alone.pdf 

model_cond_cov: $(FILES_PROBIT_TI_SIMS)

results/results_cond_cov%.mat: | results
	$(MATLAB) -r "rho=-10; N=1000; dimtheta=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Invariant_BinaryCov.m'); exit;"

results/model_probit_ti.csv: $(FILES_PROBIT_TI_SIMS)
	$(CONDA) activate blm2-env && cd python && python model_probit_ti_collect.py

results/tab-tiprobit-alone.tex: results/model_probit_ti.csv
	$(ACTIVATE) blm2-env && cd python && python model_probit_ti_figures.py

# result folder
# -------------

sims: $(FILES_PROBIT_TI_SIMS) $(FILES_PROBIT_TV_SIMS) $(FILES_EARNINGS_SIMS) | results

results:
	mkdir results

clean:
	rm -rf results/*.pdf results/*.tex results/*.csv

all: $(FILES_PROBIT_TV_FIGS) $(FILES_EARNINGS_FIGS) $(FILES_PROBIT_TI_FIGS)

# create zip file
# ---------------

FILES_FIGS = $(shell find . -name '*.pdf') $(shell find . -name '*.tex') $(shell find . -name '*.csv')
FILES_SOURCE = $(shell find . -name '*.m') $(shell find . -name '*.py')

zip: BonhommeLamadonManresa2021.zip

BonhommeLamadonManresa2021.zip: $(FILES_SOURCE) $(FILES_FIGS)
	zip -r BonhommeLamadonManresa2021.zip \
		Makefile \
		README.md \
		$(FILES_SOURCE) \
		$(FILES_FIGS)
