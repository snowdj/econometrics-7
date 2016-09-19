---
layout: post
title:  "netrics: a Python module for the econometric analysis of networks"
date:   2016-09-15
categories: Networks
use_math: true
---

Over the past few years I have devoted a large amount of my research time to developing econometric methods for the analysis of network data. This an interesting area; the statistics, math, economics and empirical work are all very interesting (and not coincidently challenging).

The first full paper I've completed is this area is called "An econometric model of link formation with degree heterogeneity.” The latest revision of the paper can be found [here]({{ site.url }}{{ site.baseurl}}/downloads/working_papers/ExogenousNetworks/ExogenousNetworks_31July2015_1stRevision.pdf). The paper proposes and analyzes two estimators for the parameter indexing a simple (but nevertheless interesting) model of network formation. 

To describe the model let `$ \mathbf{D} $` be an `$ N \times N$` adjacency matrix. The `$(i,j)^{th}$` element of `$ \mathbf{D} $` equals one if agents `$i$` and `$j$` are linked and zero otherwise. The paper considers the undirected case so that `$D_{ij}=D_{ji}$`. Assume there are `$i=1,...,N$` agents in the network to be analyzed. Let `$\mathbf{X}$` be an `$N \times J$` matrix of agent-level covariates observed by the econometrician. 

Let `$n=\tbinom{N}{2}$` denote the number of _dyads_, or distinct pairs of agents, in the network. Using the rows of `$\mathbf{X}$` we can construct the `$n \times K$` matrix `$\mathbf{W}$` of dyad-specific covariates. Because the network is undirected these covariates are constructed to be invariant to permutations of their indices (i.e., `$W_{ij}=W_{ji}$`). Examples of such covariates include the physical distance between two agents, the absolute difference in their income levels, whether they belong to the same religion, are blood relatives and so on.

I also assume that each agent is characterized by an unobserved individual-specific parameter `$A_i$`. Let `$ \mathbf{A} $` be the `$N \times 1$` vector of these parameters. For reasons that will become apparent shortly I call these _degree heterogeneity_ parameters. 

With this notation established, the paper assumes the conditional likelihood of the event `$ \mathbf{D=d} $` is:

<div>
$$
\Pr\left(\left.\mathbf{D}=\mathbf{d}\right|\mathbf{X},\mathbf{A}\right)=\prod_{i<j}\left[\frac{\exp\left(W_{ij}'\beta_{0}+A_{i}+A_{j}\right)}{1+\exp\left(W_{ij}'\beta_{0}+A_{i}+A_{j}\right)}\right]^{d_{ij}}\left[\frac{1}{1+\exp\left(W_{ij}'\beta_{0}+A_{i}+A_{j}\right)}\right]^{1-d_{ij}}
$$
</div>

In words: links form independently conditional on `$ \mathbf{X} $` and `$ \mathbf{A} $`. The latter, however, is unobserved by the econometrician. Unconditional on `$ \mathbf{A} $` links will generally be dependent. The `$A_i$` parameters allow individuals to vary in the generic surplus they generate when forming links. Practically this allows for rich patterns of _degree heterogeneity_. A common feature of real work networks are _degree distributions_ characterized by many agents with only a handful of links combined with a few so called "hub" agents with many links. For a popular account of this phenomena you can read this [article](http://www.scientificamerican.com/article/scale-free-networks/) by Albert-Lászlo Barabási and Eric Bonabau in the _Scientific American_. 

The model of network formation outlined above rules out strategic behavior, whereby the return to two agents forming a link may vary with the presence or absence of links elsewhere in the network (a phenomena admittedly central to some economic settings), but it is a reasonably rich starting point for empirical analysis. It provides a nice set-up for studying _homophily_, the tendency of individuals with similar attributes to form links, in a context that also allows for degree heterogeneity. This type of heterogeneity appears to be important in practice and, furthermore, can confound inferences about the presence or absence of homophily (as discussed in the paper via a few examples). For a theoretical take on homophily and degree heterogeneity, with some connections to my paper, and also, incidentally, in a non-strategic setting, see this [paper](http://www.sciencedirect.com/science/article/pii/S0022053112000610) by Yann Bramoulle, Sergio Currarini, Matthew Jackson, Paolo Pin and Brian Rogers in the _Journal of Economic Theory_.

As a quick aside, I am also very interested in models which _do_ allow for strategic link formation. See [this]({{ site.url }}{{ site.baseurl}}/downloads/working_papers/DynamicNetworks/Homophily_and_Transitivity_April2016.pdf) working paper. There's also been very interesting work in this area by Konrad Menzel, Aureo de Paula, Seth Richards-Shubik, Elie Tamer and Shuyang Sheng among others. Much of this work is very recent. A few examples are [here](https://wp.nyu.edu/km125/wp-content/uploads/sites/2027/2015/05/network_formation-1.pdf), [here](http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2577410) and [here](http://www.econ.ucla.edu/people/papers/Sheng/Sheng626.pdf). 

My paper proposes two estimators for the common parameter `$\beta_{0}$` in the model above. The first I call the _tetrad logit_ estimator. A "tetrad" is a group of four agents. It can be "wired" in `$2^6=64$` different ways. The tetrad logit estimator looks at the probability of different tetrad configurations conditional on the configuration belonging to a subset of the 64 possible configurations. These subsets are carefully chosen such that the `$A_i$` degree heterogeneity parameters "drop out" of the resulting criterion function. The argument is based on sufficiency results for exponential families. These arguments have proved very useful in panel data analyses (most famously in a classic 1980 [paper](http://www.jstor.org/stable/2297110) by Gary Chamberlain in the _Review of Economic Studies_). It probably goes without saying that I drew my inspiration from these panel data applications (Gary was my dissertation advisor and has deeply influenced how I think about econometric problems). In independent work, a similar sufficiency argument was introduced by [Karyne Charbonneau](http://www.bankofcanada.ca/profile/karyne-b-charbonneau/) in the related context of gravity models of trade. 

It turns out that the distribution theory for the Tetrad Logit estimator was difficult to work out. It involved many trips to the library and discussions with my colleagues at Berkeley and elsewhere. The tetrad logit estimator is a 4th order U-Process minimizer with a particular degeneracy and dependence structure. This results in some fun twists relative to the normal analysis of such estimators (as in, for example, Honore and Powell (1994, _Journal of Econometrics_)).

Subsequent to my work [Koen Jochmans](https://sites.google.com/site/jochmanskoen/) at Sciences Po has worked out distribution theory for the related set-up initially considered by Charbonneau. Concretely this means a parallel set of results for directed networks is also now available to empirical researchers.

The second estimator I introduced drew its inspiration from so called large-N, large-T nonlinear panel data models. A key reference for my work here is the paper by Hahn and Newey (1994, _Econometrica_). My second estimator jointly estimates the common parameter along with the `$N$` individual-specific degree heterogeneity parameters. It turns out that if the network is sufficiently dense, such that in the limit each agent has many links, such a procedure can work (despite the growing dimension of the incidental parameters). However the limit distribution for the estimate of `$\beta_{0}$` will have a bias term. This can be fixed by bias correction. My work here also draws on results from the probability literature on random graphs; especially a paper by Chatterjee, Dianconis and Sly (2011, _Annals of Applied Probability_). Their work, in turn, builds on an older literature on the Bradley-Terry model in statistics.

I think both estimators have a role to play in empirical work. Right now I am probably most partial to the tetrad logit approach. It delivers a consistent estimate of `$\beta_{0}$` under weaker assumptions than the joint estimator. In particular it can work well in sparse networks (including _very_ sparse networks). Such networks are very common in practice. Also theory, introspection, and Monte Carlo experiments suggest that the joint fixed effects estimator may work very poorly in sparse networks. At the same time researchers will sometimes like to have estimates of the heterogeneity parameters as well as the common parameter (e.g., to compute marginal effects). Andreas Dzemski shows how such estimates can be used for specification testing in a way likely to be very attractive to network researchers. A copy of his paper can be found [here](https://sites.google.com/site/adzemski/research). So I think both approaches have a role to play in empirical work and there is more methodological work to be done to develop each method more fully.
 
The Monte Carlo results reported in the current (publically available) draft were done using a Matlab script I wrote last year. This worked fairly effectively. However, on my desktop computer, the tetrad logit estimator would konk out at just over 100 agents due to memory problems. Exact computation of the tetrad logit estimate is difficult because there are `$\tbinom{N}{4}$` tetrads in a network and this number gets big very quickly. There are a variety of ways one could approximately compute the tetrad logit estimator "at scale", but I wanted to be able to provide code that could work reliably on networks with at least a few hundred agents on a good desktop machine (and perhaps somewhat larger networks when computing on a cluster). To this end I recoded the procedure in Python over the summer and this exercise resulted in a much more successful, and user friendly, implementation.
 
I also recoded the joint fixed effects estimator in Python. To make all this code a bit more accesible to empirical researchers I put everything together into an add-on Python package.
 
The Python package is called **netrics** for "NETwork economeRICS" (it could be worse). Currently the package only includes a implementation of the tetrad logit and joint logit fixed effects procedures as well as a few auxiliary helper functions. I hope to add more functionality over time (e.g., an implementation of my dynamic network formation work mentioned above).

The package is registered on [PyPi](https://pypi.python.org/pypi/netrics). The source code is available at [this](https://github.com/bryangraham/netrics) GitHub repository. The **netrics** package has the following dependencies: numpy, scipy, pandas, numba, numexpr and itertools. These are standard libraries and are included in most scientific Python distributions. For example they are included in the highly recommended [Anaconda distribution of Python](https://www.continuum.io/downloads). If you are using the [Anaconda distribution of Python](https://www.continuum.io/downloads), then you can follow the (straightforward but tedious) instructions [here](http://conda.pydata.org/docs/build_tutorials/pkgs.html) to learn how install the **netrics** package from PyPi and make it available in Anaconda using the "conda" package manager. For users who anticipate only infrequent use, permanent installation of the **netrics** package may not be worth the trouble. One possibility is to just clone (ie., copy) the [GitHub repository](https://github.com/bryangraham/netrics), which contains the latest version of **netrics**. Then append the path pointing to the location of the netrics package (on your local machine) to your sys directory. This is what is done in the snippet of code below.

For example if you download the repository into a directory called "netrics" on your local machine and navigate there, you should observe the following basic structure (perhaps with more .py files in the netrics/ folder)

{% highlight plain-text %}
README.txt
LICENSE
MANIFEST.in
setup.py
netrics/__init__.py
netrics/logit.py
netrics/tetrad_logit.py
{% endhighlight %}

Joachim de Weerdt has kindly made his Nyakatoke network dataset freely available on his website [here](https://www.uantwerpen.be/images/uantwerpen/personalpage32040/files/Nyakatoke%20public%20v1%2015SEP16.zip). To use the **netrics** package to fit a simple model of network formation to the Nyakatoke risk-sharing network collected by Joachim de Weerdt you can then run the following code snippet:

{% highlight python %}
# Import numpy in order to correctly read test data
import numpy as np

# Import urllib in order to download test data from Github repo
import urllib

# Append location of netrics module base directory to system path
# NOTE: only required if permanent install not made (see comments above)
import sys
sys.path.append('/Users/bgraham/Dropbox/Sites/software/netrics/')

# Load netrics module
import netrics as netrics

# Download Nyakatoke test dataset from GitHub
# Edit to download location on your local machine   
download =  '/Users/bgraham/Dropbox/'
url = 'https://github.com/bryangraham/netrics/blob/master/Notebooks/Nyakatoke_Example.npz?raw=true'
urllib.urlretrieve(url, download + "Nyakatoke_Example.npz")

# Open dataset
NyakatokeTestDataset = np.load(download + "Nyakatoke_Example.npz")

# Extract adjacency matrix
D = NyakatokeTestDataset['D']

# Initialize list of dyad-specific covariates as elements
# W = [W0, W1, W2,...WK-1]
W = []

# Initialize list with covariate labels
cov_names = []

# Construct list of regressor matrices and corresponding variable names
for matrix in NyakatokeTestDataset.files:
    if matrix != 'D':
        W.append(NyakatokeTestDataset[matrix])
        cov_names.append(matrix)   

# Fit tetrad logit to Nyakatoke
[beta_TL, vcov_beta_TL, tetrad_frac_TL, success] = \
	netrics.tetrad_logit(D, W, dtcon=None, silent=False, W_names=cov_names)              
        
{% endhighlight %}

The **netrics.tetrad_logit()** function, depending on your machine, may take a few minutes to churn out an answer. The default output is pretty basic. It reports network size, the number of tetrads and the number of tetrads with identifying content (typically only a small fraction of all tetrads). It also reports coefficient and (asymptotically valid) standard error estimates.

For more illustrations of the netrics.tetrad_logit() command, and also of my implementation of the joint fixed effects estimator, see this iPython [Notebook](https://github.com/bryangraham/netrics/blob/master/Notebooks/Introduction_to_Netrics_Module.ipynb) on GitHub.	

While I would appreciate bug reports, suggestions for improvements and so on, I am unable to provide any meaningful user-support for the package. I hope to add additional functionality for the analysis of networks to the package over time. I hope you find it useful. If you do use it for your own research please let me know, I would be very curious to see how it gets deployed in practice.