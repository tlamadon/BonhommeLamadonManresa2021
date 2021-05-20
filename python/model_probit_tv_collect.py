import os
from scipy.io import loadmat
import pandas as pd
from pathlib import Path
import seaborn as sns
import matplotlib.pylab as plt
import numpy as np
import tqdm
import pytab as pt

path = Path(os.path.expanduser("../results/"))
Tgrid = [5,10,15,20,25,30,50]

designs = [
    {'filename':'../results/results_tv_N1000_rho_m10.mat',
    'design'  :'N=1000, sigma=-10'},
    {'filename':'../results/results_tv_N1000_rho_0.mat',
    'design'  :'N=1000, sigma=0'},
    {'filename':'../results/results_tv_N1000_rho_1.mat',
    'design'  :'N=1000, sigma=1'},
    {'filename':'../results/results_tv_N1000_rho_10.mat',
    'design'  :'N=1000, sigma=10'},
]

def get_measure3(mat,meas,estimator):
    """ Extract the measure from the matlab file"""
    
    theta_value = 1.0

    if estimator == "TWGFE":
        col = 0
    elif estimator == "FE":
        col = 1
    elif estimator == "IFE":
        col = 2
    elif estimator == "GFE":
        col = 3
    else:
        return

    if meas =='Bias':
        return(mat['Results_tot'][:,col] - theta_value)
    
    if meas =='Standard deviation':
        return(mat['Results_tot_std'][:,col])
    
    if meas =='Root MSE':
        return(mat['Results_tot_rmse'][:,col])
    
    if meas =='Mean ratio standard error to standard deviation':
        return(mat['Results_tot_se'][:,col] / mat['Results_tot_std'][:,col])
        
    if meas =='Coverage':
        if 'Results_tot_cov' not in mat.keys():
            return None
        return(mat['Results_tot_cov'][:,col])

    if meas =='K':
        return(mat['Results_K_tot'][:,col])
    
    
def extract3(mat,meas_list):    
    for meas in meas_list:
        for est in ['GFE','FE','TWGFE','IFE']:
            V = get_measure3(mat,meas,est)
            if V is not None:
                yield {'estimator':est,'T':Tgrid,'value':np.real(V.flatten()), 'measure': meas}        

measure_list = ['Bias','Standard deviation',
                'Root MSE',
                'Mean ratio standard error to standard deviation',
                'Coverage']            

res_all = []
for d in designs:
    mat = loadmat(path / Path(d['filename']))
    res = [pd.DataFrame(v) for v in extract3(mat,measure_list)]
    res = pd.concat(res)
    res['design'] = d['design']
    res_all.append(res)
    
df3  = pd.concat(res_all)
df3 

df3.to_csv("../results/model_probit_tv.csv")


    