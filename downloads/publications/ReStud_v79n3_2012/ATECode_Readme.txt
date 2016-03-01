%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Using IPT to Estimate the ATE -%
%-				 -%
%-  Date: May 10, 2011		 -%
%-  Author: Daniel Egel		 -%
%-  Email: degel@rand.org        -%			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%
%- Overview -%
%%%%%%%%%%%%%%

The M files in this directory estimate the average treatment effect (ATE)
using the inverse probability tilting (IPT) approach as described in Bryan
Graham, Cristine Pinto, and Daniel Egel's "Inverse probability tilting for
moment condition models with missing data" (2011).  The inverse probability
weighting (IPW) estimate of the ATE is also calculated.  The details for the
estimation of both IPT and IPW are provided in Graham, Pinto, and Egel (2011)
available at https://files.nyu.edu/bsg1/public/.

A familiar empirical example - the Lalonde training program - is used to
demonstrate the key characteristics of the IPT estimator.  The data for this
empirical example were drawn from http://www.nber.org/~rdehejia/nswdata.html.

%%%%%%%%%%%%%%%%%%%%%%%
%- Empirical Example -%
%%%%%%%%%%%%%%%%%%%%%%%

The M-file "Lalonde_Application.m" estimates the ATE using both the IPT and IPW.
This file uses the Lalonde experimental treatment and control groups.  The moments
used for creating h(X) (i.e. matching) follow from the key specification of Robert Lalonde's 
"Evaluating the Econometric Evaluations of Training Programs" (1986) and include: age, 
years of education, marriage indicator, nodegree indicator, black indicator, hispanic
indicator, and 1975 income.  Note that Rajeev Dehejia and and Sadek Wahba repeat these
results in "Causal Effects in Nonexperimental Studies: Reevaluating the Evaluation of 
Training Programs" (1999).

Running the "Lalonde_Application.m" M-file does the following:
(1) Loads the Lalonde experimental treatment and control data, creates uniform sampling
	weights, and creates a generic clustering variable
(2) Estimate the ATE using the IPT approach and reports the following:
	- The IPT point estimates, standard errors, t-stat, and p-values
	- The IPT propensity score point estimates, standard errors, t-stat, and p-values (for
	  both D==1 and D==0)
	- The sum of the weights (guaranteed to be 1 for IPT) and the quantiles of the weight
	  distribution
	- Checks the balance of the IPT estimator by reporting:
		(a) Data for D == 1 (reweighted using IPT weights from the IPT "tilt" estimated for
			the data with D == 1)
		(b) Data for D == 0 (reweighted using IPT weights from the IPT "tilt" estimated for
			the data with D == 0)
		(c) All data - unweighted
(3) Estimate the ATE using the IPW approach and reports the following:
	- The IPW point estimates, standard errors, t-stat, and p-values
	- The IPW propensity score point estimates, standard errors, t-stat, and p-values
	- The sum of the weights and the quantiles of the weight
	  distribution
	- Checks the balance of the IPT estimator by reporting:
		(a) Data for D == 1 (reweighted using IPW weights)
		(b) Data for D == 0 (reweighted using IPW weights)
		(c) All data - unweighted

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Modifying the estimator for other problems -%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This estimator is easily adaptable to other empirical problems.  Users only need to
make the following modifications in the "Lalonde_Application.m" M-file:

(1) Load treatment and control data: 
	--> Edit lines 21-23 to load treatment and control data.  Note that the ordering of
		this data is not important.
(2) Load sample weights:
	--> Replace uniform sample weights in line 28 with available sample weights
(3) Identify id variable for clustering:
	--> Replace the generic hh_ids cluster variable with the user cluster variable
(4) Identify the covariates and moments to be used for balancing:
	--> Modify lines 48-58 and create a new [NxK] vector of the covariates to be used
		for balancing.
(5) Identify the outcome variable:
	--> Modify line 65 so that it points to the missing at random outcome variable
