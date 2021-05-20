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
df3 = pd.read_csv("../results/model_probit_tv.csv")

Tgrid = [5,10,15,20,25,30,50]
N=1000    

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

measures = {
 "Bias":"Bias",
 "std" :"Standard deviation",
 "RMSE" : "Root MSE",
 "se/std" : "Mean ratio standard error to standard deviation",
}

nm = len(measures)     
Tgrid = [5,10,15,20,25,30,50]

tab = (pt.Table().setHeaders(['c'] + 4*nm*['r']))
tab.append(pt.Row(["T"]).append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}")
                        .append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}")
                        .append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}")
                        .append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}").setEndSpace(2))

for d in designs:    
    if d['design'].find("N={},".format(N))<0:
        continue        
    dfl = df3.query("design=='{}'".format(d['design']))  
    design = d['design'].replace('N={}, '.format(N),"")
    for sigma in [-1,0,1,10]:
        design = design.replace('sigma={}'.format(sigma),"$\\sigma{{=}}{}$".format(sigma))
    
    tab.append(pt.Row(["", "\multicolumn{{ {} }}{{c}}{{ 2-way GFE, {}}}".format(nm,design),
                           "\multicolumn{{ {} }}{{c}}{{ GFE, {}}}".format(nm,design),
                           "\multicolumn{{ {} }}{{c}}{{ FE, {}}}".format(nm,design),
                           "\multicolumn{{ {} }}{{c}}{{ IFE, {}}}".format(nm,design)
                      ]).setEndSpace(-3))
    tab.addRule([ [2,2+nm-1], [2+nm,2+2*nm-1] ,[2+2*nm,2+3*nm-1],[2+3*nm,2+4*nm-1]])

    for t in Tgrid:
        r = pt.Row([t])
        for meas in measures.values():
            dfll = dfl.query("measure=='{}'".format(meas)).query("T=={}".format(t))
            r.append( dfll.query("estimator=='TWGFE'")['value'], format="{:10.3f}") 
        for meas in measures.values():
            dfll = dfl.query("measure=='{}'".format(meas)).query("T=={}".format(t))
            r.append( dfll.query("estimator=='GFE'")['value'], format="{:10.3f}")
        for meas in measures.values():
            dfll = dfl.query("measure=='{}'".format(meas)).query("T=={}".format(t))
            r.append( dfll.query("estimator=='FE'")['value'], format="{:10.3f}")
        for meas in measures.values():
            dfll = dfl.query("measure=='{}'".format(meas)).query("T=={}".format(t))
            r.append( dfll.query("estimator=='IFE'")['value'], format="{:10.3f}")
        tab.append(r)
    tab.lastRow().setEndSpace(0)

tab.save_to_Tex( path / Path("tab-tvprobit-param-n{}-alone.tex".format(N)),stand_alone=True)

# # --------------------
# #        Plots
# # --------------------
Tgrid = [5,10,15,20,25,30]

designs_plot = [ v['design'] for v in designs if v['design'].find('1000')>=0]
dfl = df3.query("design in {}".format(designs_plot)).query("measure in ['Bias']").query('estimator != "TWGFE"')  

for sigma in [-1,0,1,10]:
    dfl['design'] = dfl['design'].str.replace('sigma={}'.format(sigma),r"$\\sigma{{=}}{}$".format(sigma))

dfl['design'] = dfl['design'].str.replace("N=1000, ","")
# dfl['design'] = dfl['design'].str.replace("N=100, ","")    
dfl = dfl.query("T<=30")

dfl['value'] = dfl['value'] + 1.0
dfl =  dfl.query("T<=30")    

g = sns.FacetGrid(dfl, col="design", hue="estimator", sharey="row",col_wrap=4,height=2.5,aspect=0.9)
g.map(sns.lineplot, "T","value")

for ax in g.axes:
    ax.axhline(1.0, linestyle="dotted",color="black")
    ax.lines[1].set_linestyle("--")
    ax.lines[2].set_linestyle("-.")
    ax.set_xticks(Tgrid)

g.set_titles(row_template = '{row_name}', col_template = '{col_name}')
g.set_ylabels("parameter")
g.savefig(  path / Path("fig-tvprobit-bias.pdf"), bbox_inches='tight')
plt.show()

# g.set_titles(row_template = '{row_name}', col_template = '{col_name}')
# g.set_ylabels("parameter")
# g.savefig(  path / Path("fig-tiselection-bias.pdf"))
# plt.show()