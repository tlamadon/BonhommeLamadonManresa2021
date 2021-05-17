MATLAB = matlab -nodesktop -nodisplay -nosplash


all:
	matlab -nodesktop -nodisplay -nosplash -r "eta=2; run('matlab/Code_Earnings_Time_Invariant.m'); exit;"
	matlab -nodesktop -nodisplay -nosplash -r "run('matlab/Code_Earnings_Time_Invariant.m'); exit;"


earnings: 
	results_earnings_eta1_N1000.mat
	results_earnings_eta2_N1000.mat

results_earnings_eta1_N1000.mat:
	matlab -nodesktop -nodisplay -nosplash -r "eta=1.0001; run('matlab/Code_Earnings_Time_Invariant.m'); exit;"

probit_tv: \
	results/results_tv_N100_rho_m10.mat \
	results/results_tv_N100_rho_10.mat \
	results/results_tv_N100_rho_1.mat \
	results/results_tv_N100_rho_0.mat

# rules for time varying probits
# ------------------------------

results/results_tv_N%_rho_m10.mat: results
	$(MATLAB) -r "S=5; rho=-10; N=$*; RES_FILE='../$@'; run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_10.mat: results
	$(MATLAB) -r "S=5; rho=10; N=$*; RES_FILE='../$@'; run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_0.mat: results
	$(MATLAB) -r "S=5; rho=0.000001; N=$*; RES_FILE='../$@'; run('matlab/Code_Probit_Time_Varying.m'); exit;"

results/results_tv_N%_rho_1.mat: results
	$(MATLAB) -r "S=5; rho=1; N=$*; RES_FILE='../$@'; run('matlab/Code_Probit_Time_Varying.m'); exit;"



results:
	mkdir results
