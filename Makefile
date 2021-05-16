all:
	matlab -nodesktop -nodisplay -nosplash -r "S=5;eta=2; run('matlab/Code_Earnings_Time_Invariant.m'); exit;"
	matlab -nodesktop -nodisplay -nosplash -r "S=5; run('matlab/Code_Earnings_Time_Invariant.m'); exit;"
