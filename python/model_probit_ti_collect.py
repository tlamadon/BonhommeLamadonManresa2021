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

designs = [
    {'filename':'results_cond_cov1.mat',
    'design':'One covariate','T':20,'P':1},
    {'filename':'results_cond_cov2.mat',
    'design':'Two covariates','T':20,'P':2},
    {'filename':'results_cond_cov3.mat',
    'design':'Three covariates','T':20,'P':3},
]

measures = {
 "Bias":"Bias",
 "std" :"Standard deviation",
 "RMSE" : "Root MSE",
}

measure_list = ['Bias','Standard deviation',"Root MSE"]

def get_measure6(mat,meas,estimator,k):
    """ Extract the measure from the matlab file"""
    
    Kgrid = mat['Kgrid'].flatten()
    nk = len(Kgrid)
    
    if estimator == "GFE":
        col = k
    elif estimator == "CGFE":
        col = nk+k
    elif estimator == "FE":
        col = 2*nk
    else:
        return

    if meas =='Bias':
        return(mat['Results_tot'][:,col]- 1.0)
    
    if meas =='Standard deviation':
        return(mat['Results_tot_std'][:,col])
    
    if meas =='Root MSE':
        v = (mat['Results_tot'][:,col]- 1.0)**2 + mat['Results_tot_std'][:,col]**2
        return(np.sqrt(v))

def extract6(mat,T,P):
    Kgrid = mat['Kgrid'].flatten()
    for meas in measure_list:
        for k in range(len(Kgrid)):
            yield {'estimator':'GFE', 'T':T,'P':P, 'K':Kgrid[k], 'value': get_measure6(mat,meas,'GFE',k)[0], 'measure':meas}
            yield {'estimator':'CGFE','T':T,'P':P, 'K':Kgrid[k], 'value': get_measure6(mat,meas,'CGFE',k)[0], 'measure':meas}
        yield {'estimator':'FE','T':T,'P':P, 'K':0, 'value': get_measure6(mat,meas,'FE',k)[0], 'measure':meas}
    

res_all = []
for d in designs:
    mat = loadmat(path / Path(d['filename']))
    res = pd.DataFrame([v for v in extract6(mat,d['T'],d['P'])])
    res['design'] = d['design']
    res_all.append(res)
    
df6  = pd.concat(res_all)

df6.to_csv("../results/model_pprobit_ti.csv")


    