MATLAB = matlab -nodesktop -nodisplay -nosplash
RS = 634143
NWORKERS = 16
ACTIVATE = /usr/local/python/anaconda3/bin/activate

# common matlab code arguments
MARGS = S=1000; RNG_SEED=$(RS); NWORKERS = $(NWORKERS); 

all: model_earnings model_probit_tv

figures: results/tab-tiselection-param-n1000-alone.pdf

# rules for earnings and participation model
# ------------------------------------------

model_earnings: \
	results/results_earnings_eta1_N1000.mat \
	results/results_earnings_eta2_N1000.mat \
	results/model_earnings.csv 

figures_earnings: results/model_earnings.csv python/model_earnings_figures.py
	$(ACTIVATE) blm2-env && cd python && python model_earnings_figures.py

results/tab%.pdf: results/tab%.tex
	cd results && pdflatex -interaction=nonstopmode $<

results/results_earnings_eta1_N%.mat: | results
	$(MATLAB) -r "eta=1.000001; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Earnings_Time_Invariant.m'); exit;"

results/results_earnings_eta2_N%.mat: | results
	$(MATLAB) -r "eta=2; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Earnings_Time_Invariant.m'); exit;"

results/model_earnings.csv: results/results_earnings_eta1_N1000.mat
	$(CONDA) activate blm2-env && cd python && python model_earnings_collect.py

results/model_probit_tv.csv: 
	$(CONDA) activate blm2-env && cd python && python model_probit_tv_collect.py

# rules for time varying probits
# ------------------------------

model_probit_tv: \
	results/results_tv_N1000_rho_m10.mat \
	results/results_tv_N1000_rho_10.mat \
	results/results_tv_N1000_rho_1.mat \
	results/results_tv_N1000_rho_0.mat

results/results_tv_N%_rho_m10.mat:  | results
	$(MATLAB) -r "rho=-10; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_10.mat: | results
	$(MATLAB) -r "rho=10; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_0.mat: | results
	$(MATLAB) -r "rho=0.000001; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_1.mat: | results
	$(MATLAB) -r "rho=1; N=$*; RES_FILE='../$@'; $(MARGS); run('matlab/Code_Probit_Time_Varying.m'); exit;"

# result folder
# -------------

results:
	mkdir results

clean:
	rm -rf results
