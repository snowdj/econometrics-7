---
layout: post
title:  "ipt Module for Program Evaluation"
date:   2016-05-15
categories: Causal Inference
use_math: true
---

Earlier this spring my co-authors and I finally published the paper “Efficient estimation of data combination models by the method of auxiliary-to-study tilting (AST)” in the _Journal of Business and Economic Statistics_ . A copy of this paper can be found on my research page [here]({{ site.url }}{{ site.baseurl}}/downloads/publications/JBES_v34n2_2016/BSG_JBES_v34n2_2016.pdf).

Publishing this material was almost a decade long process. On the whole I've been reasonably-to-very lucky when it comes to publishing, but this paper is an exception that proves the rule. The material dates to 2006 (the "Eureka moment" came shortly after the birth of my son), with the first widely circulated version appearing in Section 4 of the initial version of our 2008 NBER Working Paper “Inverse probability tilting and missing data problems.” 

The bulk of the material in the 2008 NBER paper was published in the _Review of Economic Studies_ in 2012 (after many _very_ challenging revisions). A copy of that paper is available [here]({{ site.url }}{{ site.baseurl}}/downloads/publications/ReStud_v79n3_2012/BSG_ReStud_v79n3_2012.pdf). The "Section 4" material, which just appeared in print this spring, went through a long "revise and resubmit", "reject and resubmit" and then straight "reject" editorial process at another journal before we turned to the _Journal of Business and Economic Statistics_. 

The upshot of these twists and turns is that the end research product went through numerous improvements prior to publication. For both papers we were pushed hard by the editor and referees to improve our research. Unfortunately, while not especially esoteric by the standards of modern econometrics, neither the _Review of Economic Studies_ nor the _Journal of Business and Economic Statistics_ papers are especially easy to read for a non-specialist.

The two papers are respectively organized around a rather general semiparametric _missing data_ and _data combination_ problem. Many interesting econometric problems fall within these two classes. Perhaps the leading two estimands covered by our work are the Average Treatment Effect (ATE) and the Average Treatment Effect on the Treated (ATT). Unfortunately readers interested in the implications of our work for program evaluation applications have to struggle through papers with much more generality than they probably need or want.

A key idea in both papers is to construct a propensity score estimate that re-weights the treatment and control subsamples to exactly match/balance moments of the pre-treatment covariates across the two samples. Researchers often present a table of average mean differences in pre-treatment covariates both before and after undertaking some sort of adjustment procedure (e.g., matching). Researchers using our estimators could present a table showing _zero mean differences_ in the pre-treatment covariates across treatment and control units after re-weighting. When presenting this work to applied audiences I have generally found researchers receptive and attracted to this feature of our method.

The whole idea of invoking "selection on observables" is that, if one adjusts for differences in the observed covariates across treatment and control units, all selection bias can be removed. The key idea in our paper is to directly reweight the treatment and control subsamples to impose distributional balance in observed covariates. 

The approach we developed in the two papers was inspired by older ideas on contingency table calibration which go back at least to the 1940s, as well as, more subtlety, by the structure of the semiparametric efficiency bound for the missing data and data combination problems. See, for example, this [paper]({{ site.url }}{{ site.baseurl}}/downloads/publications/Econometrica_v79n2_2011/BSG_Econometrica_v79n2_2011.pdf). We also used ideas from the literature on the efficient estimation of expectations, particularly as it appears in research on generalized empirical likelihood (e.g., Imbens (1997, _Review of Economic Studies_, Newey and Smith (2004, _Econometrica_)).

The product of our particular mix of all these ingredients is a rather good estimator for the ATE as well as the ATT. One that, in addition to having good _first-order_ asymptotic properties (namely local efficiency and double robustness), also has good _higher-order_ asymptotic properties. 

Since our work first appeared, many other authors have developed various direct covariate balancing estimators of the propensity score. The [Entropy Balancing](https://pan.oxfordjournals.org/content/20/1/25.full) approach of Jens Hainmueller is one which I believe developed independently (and concurrently) with our work. The [Covariate Balancing Propensity Score](http://onlinelibrary.wiley.com/doi/10.1111/rssb.12027/full) method of Kosuke Imai and Marc Ratkovic, which appeared after our (and Hainmueller's) work, has proved especially popular in the field of Political Science. 

There is also some nice work extending the idea of exact balancing to high-dimensional settings. This extension is non-trivial since with many controls there may be _no_ re-weighting which exactly balances, say the means, of the control variables across the treated and non-treated subsamples. In such cases only approximate balancing is possible and there are a variety of delicate decisions involved here. See [this](http://arxiv.org/abs/1604.07125) working paper by Susan Athey, Guido Imbens and Stefan Wager for some interesting ideas in this area.

There is a lot more additional work in this area. Too much to properly survey here. There are also several important antecedents to our work; not all of them obvious. For example, my favorite is the clever approach to adjusting for non-ignorable attrition using refreshment samples introduced by Hirano, Imbens, Ridder and Rubin (1998, _Econometrica_). That paper implicitly uses calibration ideas which influenced our own work.

Nevertheless, despite all the recent work on "covariate balancing" propensity scores, our two papers remain distinctive, not just for being "first", but in terms of the theoretical development of the estimators. We show that our ATE and ATT estimators are locally efficient, doubly robust and have attractive higher order properties relative to other first order equivalent estimators. In the case of our ATT procedure I am aware of no other locally efficient estimator in the literature (although I could be wrong!). Furthermore, while I have not formally analyzed them, the structure of some recent suggestions for estimation of covariate balancing propensity scores suggest, by analogy with known results on GMM estimation of over-identified models, poor finite sample properties (at least relative to our proposals).

While we wrote and made available a fair amount of code in connection with our two papers (mostly in MATLAB) we did not do a tremendous amount to promote it, or make it easy for other researchers to use in their own work. When our second paper finally came out this spring I decided I would try to write some more user friendly code. This is part of a bigger resolution to make my work more accessible to researchers.

While I would like to make a Stata and R implementations of our estimators available, I decided to first prepare a Python 2.7 implementation. I like Python a lot. It is widely-used in the Data Science and Machine Learning communities. While senior researchers in statistics and econometrics may be less familiar with Python, chances are their students are very familiar with it. Python is probably the most common language used to teach introductory computer science. At Berkeley Python is also used to teach our general education [Foundations of Data Science](https://data-8.appspot.com/sp16/) course.

The Python package is called **ipt** for "inverse probability tilting". Currently it only includes a implementation of our ATT estimator, although I intend to incorporate an ATE estimator into the package in the future. This package is registered on [PyPi](https://pypi.python.org/pypi/ipt/). The source code is available at [this](https://github.com/bryangraham/ipt) GitHub repository. The **ipt** package has the following dependencies: numpy, numpy.linalg, scipy, scipy.optimize and scipy.stats. These are standard libraries and are included in most scientific Python distributions. For example they are included in the highly recommended [Anaconda distribution of Python](https://www.continuum.io/downloads). If you are using the [Anaconda distribution of Python](https://www.continuum.io/downloads), then you can follow the (straightforward but tedious) instructions [here](http://conda.pydata.org/docs/build_tutorials/pkgs.html) to learn how install the **ipt** package from PyPi and make it available in Anaconda using the "conda" package manager. For users who anticipate only infrequent use, permanent installation of the **ipt** package may not be worth the trouble. One possibility is to just clone (ie., copy) the [GitHub repository](https://github.com/bryangraham/ipt), which contains the latest version of **ipt**. Then append the path pointing to the location of the ipt package (on your local machine) to your sys directory. This is what is done in the snippet of code below.

For example if you download the repository into a directory called "ipt" on your local machine and navigate there, you should observe the following basic structure (perhaps with more .py files in the ipt/ folder as additional functionality is added to the module over time)

{% highlight plain-text %}
README.txt
LICENSE
MANIFEST.in
setup.py
ipt/__init__.py
ipt/logit.py
ipt/att.py
{% endhighlight %}

To use the package to estimate the ATT using the NSW evaluation dataset used by Dehejia and Wahba (1999, _Journal of the American Statistical Association_) you can then run the following code snippet:

{% highlight python %}
# Append location of ipt module root directory to systems path
# NOTE: Only required if ipt module not "permanently" installed via "pip", "conda" etc.
import sys
sys.path.append('/Users/bgraham/Dropbox/Sites/software/ipt/')

# Load ipt package
import ipt as ipt

# Read help file for ipt.att()
help(ipt.att)

# Read nsw data directly from Rajeev Dehejia's webpage into a
# Pandas dataframe
import numpy as np
import pandas as pd

nsw=pd.read_stata("http://www.nber.org/~rdehejia/data/nsw_dw.dta")

# Make some adjustments to variable definitions in experimental dataframe
nsw['constant'] = 1                # Add constant to observational dataframe
nsw['age']      = nsw['age']/10    # Rescale age to be in decades
nsw['re74']     = nsw['re74']/1000 # Recale earnings to be in thousands
nsw['re75']     = nsw['re75']/1000 # Recale earnings to be in thousands

# Treatment indicator
D = nsw['treat']

# Balancing moments
t_W = nsw[['constant','black','hispanic','education','age','re74','re75']]

# Propensity score variables
r_W = nsw[['constant']]

# Outcome
Y = nsw['re78']

# Compute AST estimate of ATT
[gamma_as, vcov_gamma_ast, study_test, auxiliary_test, pi_eff_nsw, pi_s_nsw, pi_a_nsw, exitflag] = \
                                                                ipt.att(D, Y, r_W, t_W, study_tilt=True)
{% endhighlight %}

The **ipt.att()** command will spit out lots of useful and interesting diagnostic output (set silent=True to suppress this). For a reasonably well-narrated guided tour of the ipt.att() command see this iPython [Notebook](https://github.com/bryangraham/ipt/blob/master/Notebooks/Tilting_Estimates_of_ATT.ipynb) on GitHub.	

While I would appreciate bug reports, suggestions for improvements and so on, I am unable to provide any meaningful user-support for the package. When I manage to code up the ATE estimator (or any additional features) I'll post an update on this blog.

_This posted was lightly edited on 5/29/16 to reflect a few
bug fixes and initial module improvements._


