# ---------------------
#       TABLES 
# ---------------------

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
df6 = pd.read_csv("../results/model_probit_ti.csv")
measures = {
 "Bias":"Bias",
 "std" :"Standard deviation",
 "RMSE" : "Root MSE",
}

nm = len(measures)     
Kgrid = [5, 10, 20, 30, 40, 50]

tab = (pt.Table().setHeaders(['c'] + 3*nm*['r']))
tab.append(pt.Row(["K"]).append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}")
                        .append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}")
                        .append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}").setEndSpace(2))

tab.append(pt.Row(["", "\multicolumn{{ {} }}{{c}}{{ GFE, {}}}".format(nm,"1 covariate"),
                       "\multicolumn{{ {} }}{{c}}{{ GFE, {}}}".format(nm,"2 covariates"),
                       "\multicolumn{{ {} }}{{c}}{{ GFE, {}}}".format(nm,"3 covariates")
                  ]).setEndSpace(-3))
tab.addRule([ [2,2+nm-1], [2+nm,2+2*nm-1], [2+2*nm,2+3*nm-1] ])
dfl = df6.query("estimator=='GFE'")    
for k in Kgrid:
    r = pt.Row([k])
    for meas in measures.values():
        dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(1)).query("K=={}".format(k))
        r.append( dfll['value'], format="{:10.3f}") 
    for meas in measures.values():
        dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(2)).query("K=={}".format(k))
        r.append( dfll['value'], format="{:10.3f}")
    for meas in measures.values():
        dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(3)).query("K=={}".format(k))
        r.append( dfll['value'], format="{:10.3f}")
    tab.append(r)
tab.lastRow().setEndSpace(4)



tab.append(pt.Row(["", "\multicolumn{{ {} }}{{c}}{{ Cond. GFE, {}}}".format(nm,"1 covariate"),
                       "\multicolumn{{ {} }}{{c}}{{ Cond. GFE, {}}}".format(nm,"2 covariates"),
                       "\multicolumn{{ {} }}{{c}}{{ Cond. GFE, {}}}".format(nm,"3 covariates")
                  ]).setEndSpace(-3))
tab.addRule([ [2,2+nm-1], [2+nm,2+2*nm-1], [2+2*nm,2+3*nm-1] ])
dfl = df6.query("estimator=='CGFE'")    
for k in Kgrid:
    r = pt.Row([k])
    for meas in measures.values():
        dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(1)).query("K=={}".format(k))
        r.append( dfll['value'], format="{:10.3f}") 
    for meas in measures.values():
        dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(2)).query("K=={}".format(k))
        r.append( dfll['value'], format="{:10.3f}")
    for meas in measures.values():
        dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(3)).query("K=={}".format(k))
        r.append( dfll['value'], format="{:10.3f}")
    tab.append(r)
tab.lastRow().setEndSpace(4)



tab.append(pt.Row(["", "\multicolumn{{ {} }}{{c}}{{ FE, {}}}".format(nm,"1 covariate"),
                       "\multicolumn{{ {} }}{{c}}{{ FE, {}}}".format(nm,"2 covariates"),
                       "\multicolumn{{ {} }}{{c}}{{ FE, {}}}".format(nm,"3 covariates")
                  ]).setEndSpace(-3))
tab.addRule([ [2,2+nm-1], [2+nm,2+2*nm-1], [2+2*nm,2+3*nm-1] ])
dfl = df6.query("estimator=='FE'")    
r = pt.Row(['-'])
k=0
for meas in measures.values():
    dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(1)).query("K=={}".format(k))
    r.append( dfll['value'], format="{:10.3f}") 
for meas in measures.values():
    dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(2)).query("K=={}".format(k))
    r.append( dfll['value'], format="{:10.3f}")
for meas in measures.values():
    dfll = dfl.query("measure=='{}'".format(meas)).query("P=={}".format(3)).query("K=={}".format(k))
    r.append( dfll['value'], format="{:10.3f}")
tab.append(r)
tab.lastRow().setEndSpace(0)

tab.save_to_Tex( path / Path("tab-tiprobit-alone.tex"),stand_alone=True)