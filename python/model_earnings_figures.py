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
df2 = pd.read_csv("../results/model_earnings.csv")
Tgrid = [5,10,15,20,25,30,50]

designs = [
    {'filename':'results_earnings_eta1_N1000.mat',
     'design':'N=1000, gamma=1'},
    {'filename':'results_earnings_eta1_N100.mat',
     'design':'N=100, gamma=1'},
    {'filename':'results_earnings_eta2_N1000.mat',
     'design':'N=1000, gamma=2'},
    {'filename':'results_earnings_eta2_N100.mat',
     'design':'N=100, gamma=2'}]

"""
    Function that generates the tables
"""
def make_tiselection_table(N):
    measures = {
     "Bias":"Bias",
     "std" :"Standard deviation",
     "RMSE" : "Root MSE",
     "se/std" : "Mean ratio standard error to standard deviation"
    }
    
    nm = len(measures) 
        
    tab = (pt.Table().setHeaders(['c', 'r','r','r','r','r', 'r','r','r','r','r']))
    tab.append(pt.Row(["T"]).append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}")
                            .append(measures.keys(),format=r"\multicolumn{{1}}{{c}}{{ {} }}").setEndSpace(2))

    for d in designs:    
        if d['design'].find("N={},".format(N))<0:
            continue        
        dfl = df2.query("design=='{}'".format(d['design']))  
        design = d['design'].replace('N={}, '.format(N),"").replace('gamma=2',"$\\gamma=2$").replace('gamma=1',"$\\gamma=1$")
        tab.append(pt.Row(["", "\multicolumn{{ {} }}{{c}}{{ GFE, {}}}".format(nm,design),
                               "\multicolumn{{ {} }}{{c}}{{ FE, {}}}".format(nm,design)]).setEndSpace(-3))
        tab.addRule([ [2,2+nm-1], [2+nm,2+2*nm-1] ])

        for t in Tgrid:
            r = pt.Row([t])
            for meas in measures.values():
                dfll = dfl.query("measure=='{}'".format(meas)).query("T=={}".format(t))
                r.append( dfll.query("estimator=='GFE'")['value'], format="{:10.3f}") 
            for meas in measures.values():
                dfll = dfl.query("measure=='{}'".format(meas)).query("T=={}".format(t))
                r.append( dfll.query("estimator=='FE'")['value'], format="{:10.3f}")
            tab.append(r)
        tab.lastRow().setEndSpace(0)

    tab.save_to_Tex( path / Path("tab-tiselection-param-n{}-alone.tex".format(N)),stand_alone=True)

for N in tqdm.tqdm([1000]):
    make_tiselection_table(N)

# --------------------
#        Plots
# --------------------
Tgrid = [5,10,15,20,25,30]

designs_plot = [ v['design'] for v in designs if v['design'].find('1000')>=0]
dfl = df2.query("design in {}".format(designs_plot)).query("measure in ['Bias']")  

dfl['design'] = dfl['design'].str.replace("gamma=1",r"$\\eta=1$")
dfl['design'] = dfl['design'].str.replace("gamma=2",r"$\\eta=2$")
dfl['design'] = dfl['design'].str.replace("N=1000, ","")

dfl['value'] = dfl['value'] + 1.0
dfl =  dfl.query("T<=30")

g = sns.FacetGrid(dfl, col="design", hue="estimator",sharey="row",col_wrap=2)
g.map(sns.lineplot, "T","value")

for ax in g.axes:
    ax.axhline(1.0, linestyle="dotted",color="black")
    ax.lines[1].set_linestyle("--")
    ax.set_xticks(Tgrid)

g.set_titles(row_template = '{row_name}', col_template = '{col_name}')
g.set_ylabels("parameter")
g.savefig(  path / Path("fig-tiselection-bias.pdf"))
plt.show()