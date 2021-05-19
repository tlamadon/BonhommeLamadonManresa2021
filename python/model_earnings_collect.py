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

measure_list = ['Bias','Standard deviation',
                'Root MSE',
                'Mean ratio standard error to standard deviation']

def get_measure2(mat,meas,estimator):
    """ Extract the measure from the matlab file"""
    
    if estimator == "FE":
        col = 1
    elif estimator == "GFE":
        col = 0
    else:
        return

    pcost = 1.0 #(-mat['cost1']+mat['cost0'] )
    
    if meas =='Bias':
        return(mat['Results_tot'][:,col]-pcost)    
    if meas =='Standard deviation':
        return(mat['Results_tot_std'][:,col])    
    if meas =='Root MSE':
        return(np.sqrt(( mat['Results_tot'][:,col] - pcost)**2+mat['Results_tot_std'][:,col]**2))    
    if meas =='Mean ratio standard error to standard deviation':
        return(mat['Results_tot_se'][:,col] / mat['Results_tot_std'][:,col])        
    if meas =='Coverage':
        return(mat['Results_tot_cov'][:,col])

def extract2(mat,meas_list,name):    
    for meas in meas_list:
        yield {'estimator':'GFE','T':Tgrid,'value': get_measure2(mat,meas,'GFE').flatten(), 'measure': meas}
        yield {'estimator':'FE', 'T':Tgrid,'value': get_measure2(mat,meas,'FE').flatten(),  'measure': meas}
        
designs = [
    {'filename':'results_earnings_eta1_N1000.mat',
     'design':'N=1000, gamma=1'},
    {'filename':'results_earnings_eta1_N100.mat',
     'design':'N=100, gamma=1'},
    {'filename':'results_earnings_eta2_N1000.mat',
     'design':'N=1000, gamma=2'},
    {'filename':'results_earnings_eta2_N100.mat',
     'design':'N=100, gamma=2'}]
    
res_all = []
for d in designs:
    mat = loadmat(path / Path(d['filename']))
    res = [pd.DataFrame(v) for v in extract2(mat,measure_list,'toto')]
    res = pd.concat(res)
    res['design'] = d['design']
    res_all.append(res)
    
df2  = pd.concat(res_all)
df2.to_csv("../results/model_earnings.csv")


    