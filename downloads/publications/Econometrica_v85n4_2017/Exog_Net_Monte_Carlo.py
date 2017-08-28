#-----------------------------------------------------------------------------#
#- This script replicates the Monte Carlo experiments reported in "An        -#
#- econometric model of link formation with degree heterogeneity" by Bryan   -#
#- Graham (NBER Working Paper No. 20341). It uses functionality contained in -#
#- the netrics module. See http://bryangraham.github.io/econometrics/ for    -#
#- additional details.                                                       -#
#-----------------------------------------------------------------------------#

# Bryan Graham
# January 2017

# Division of two integers in Python 2.7 does not return a floating point result. 
# The default is to round down to the nearest integer. The following piece of 
# code changes the default.
from __future__ import division

# Append location of netrics module base directory to system path
import sys
sys.path.append('/Users/bgraham/Dropbox/Sites/software/netrics/')   #Desktop path
#sys.path.append('/accounts/fac/bgraham/scratch/netrics')             #EML path

# Load netrics module
import netrics as netrics

# Import additional libraries
# Load libraries
import time
import multiprocessing as mp
import numpy as np
import scipy as sp
import networkx as nx
import pandas as pd
import matplotlib.pyplot as plt

#-----------------------------------------------------------------------------#
#- Define main simulation/Monte Carlo loop                                   -#
#-----------------------------------------------------------------------------#
def runSimulationDesign(m):
    
    # ----------------------------------------------------- #
    # STEP 0: Set the random state for reproducibility      #
    # ----------------------------------------------------- #    
    
    randst = np.random.RandomState(m*361)
    
    # Extract DGP parameters for current/m-th data generating process
    K          = MonteCarloDesigns[m][0]
    AShape1    = MonteCarloDesigns[m][1]
    AShape2    = MonteCarloDesigns[m][2]
    SuppLength = MonteCarloDesigns[m][3]
    AMean0     = MonteCarloDesigns[m][4]
    AMean1     = MonteCarloDesigns[m][5]
    beta       = MonteCarloDesigns[m][6]
    
    # Initialize storage matrices for results 
    SimulationResults_TL  = np.zeros((B,6))
    SimulationResults_JFE = np.zeros((B,5))
    SimulationResults_BC  = np.zeros((B,5))
    NetworkProperties     = np.zeros((B,5))
    
    # Run B simulations for current DGP
    for b in xrange(0,B):
    
        # ----------------------------------------------------- #
        # - STEP 1: Simulate network                          - #
        # ----------------------------------------------------- #
                
        W_nnk = []                 # Initialize regressor matrices
        W     = []
        X_bar = np.zeros((N,1))
        
        for k in range(0,K):
        
            # Draw kth observed agent-specific covariates: X = -1 or 1
            X    =  2 * (randst.binomial(1, 1/2, (N,1)) - 1/2) # N x 1 2d array
                        
            # Compute average of covariate vector
            X_bar += X/K
        
            # Construct a K-length list with the N x N dyad-level covariate matrices 2d arrays as elements
            W_k   =  X * X.T - np.eye(N)                         # N x N 2d array
            W_nnk.append(W_k)                                    # Append to list
            
            # Construct 
            W_k   =  W_k[ij_LowTri].reshape((-1,1))              # Vectorize: n x 1
            W.append(W_k)
            
        # n x K regressor matrix (converts list of vectors into a matrix (i.e., 2d array))
        W = np.column_stack(W)
        
        # Draw agent-specific unobserved degree heterogeneity
        # NOTE: for K = 1 this reproduces the specification studied in the working paper
        A_i   = (AMean0 + AMean1)/2 + (AMean1 - (AMean0 + AMean1)/2) * X_bar \
                 + SuppLength*(randst.beta(AShape1, AShape2, (N,1)) - AShape1/(AShape1+AShape2))    # N x 1 2d array
        A     = A_i + A_i.T - 2*np.diag(np.ravel(A_i))                                              # N x N 2d array 
        A     = A[ij_LowTri].reshape((-1,1))                                                        # Vectorize: n x 1
        
        # n x 1 vector of ij link probabilitie
        p     = np.exp(np.dot(W,np.ones((K,1))*beta) + A) / (1+np.exp(np.dot(W,np.ones((K,1))*beta) + A)) # n x 1 2d array
        
        # Take random draw of adjacency matrix for current design
        D            = np.zeros((N,N), dtype='int8')          # N x N adjacency matrix
        D[ij_LowTri] = np.ravel(randst.uniform(0, 1, (n,1)) <= p)
        D            = D + D.T
     
        del X, X_bar, W_k, A, p # Delete components of DGP that are not needed below
        
        # ----------------------------------------------------- #
        # - STEP 2: Compute network summary statistics        - #
        # ----------------------------------------------------- #
        
        G = nx.Graph(D)
        deg_seq = nx.degree(G).values()
        NetworkProperties[b,0] = nx.density(G)                                      # Density           
        NetworkProperties[b,1] = nx.transitivity(G)                                 # Transitivity
        NetworkProperties[b,2] = np.mean(deg_seq)                                   # Mean Degree
        NetworkProperties[b,3] = np.std(deg_seq)                                    # Std. of Degree
        NetworkProperties[b,4] = len(max(nx.connected_components(G), key=len))/N    # Giant component
        
        del G, deg_seq  # Delete graph & degree sequence                            
                
        # ----------------------------------------------------- #
        # - STEP 3: Compute tetrad logit estimate of beta     - #
        # ----------------------------------------------------- #
        
        try:
            
            # Compute tetrad logit estimates
            [beta_TL, vcov_beta_TL, tetrad_frac_TL, success_TL] = netrics.tetrad_logit(D, W_nnk, dtcon=fixed_dtcon, \
                                                                                       silent=True, W_names=None)              
            # record fraction of tetrads contributing to TL criterion function
            SimulationResults_TL[b,0] = tetrad_frac_TL
        
            # record that tetrad logit optimizer exited without an exception
            SimulationResults_TL[b,1] = True
        
            # point estimate
            SimulationResults_TL[b,2] = beta_TL[0]
            
            # standatd error estimate
            SimulationResults_TL[b,3] = np.sqrt(vcov_beta_TL[0,0])
        
            # coverage with alpha = 0.5 (95 percent interval)
            SimulationResults_TL[b,4] = (beta_TL[0] - 1.96*np.sqrt(vcov_beta_TL[0,0]) <= beta <= beta_TL[0] \
                                         + 1.96*np.sqrt(vcov_beta_TL[0,0])) 
        
            # coverage with alpha = 0.10 (90 percent interval)
            SimulationResults_TL[b,5] = (beta_TL[0] - 1.645*np.sqrt(vcov_beta_TL[0,0]) <= beta <= beta_TL[0] \
                                         + 1.645*np.sqrt(vcov_beta_TL[0,0]))  
            
        except Exception, e:
            
            # record that tetrad logit optimizer failed
            SimulationResults_TL[b,1] = False
        
        # ----------------------------------------------------- #
        # - STEP 4: Compute JFE/BC logit estimates of beta    - #
        # ----------------------------------------------------- #
        
        try:
            
            # Compute joint fixed effect logit estimates
            [beta_JFE, beta_JFE_BC, vcov_beta_JFE, A_JFE, success_JFE] = netrics.dyad_jfe_logit(D, W_nnk, T, \
                                                                                                silent=True, W_names=None,\
                                                                                                beta_sv=beta*np.ones((K,)))              
                    
            # record that tetrad logit optimizer exited without an exception
            SimulationResults_JFE[b,0] = True
                
            # point estimate
            SimulationResults_JFE[b,1] = beta_JFE[0]
            SimulationResults_BC[b,0]  = beta_JFE_BC[0]
            
            # standatd error estimate
            SimulationResults_JFE[b,2] = np.sqrt(vcov_beta_JFE[0,0])
            SimulationResults_BC[b,1]  = np.sqrt(vcov_beta_JFE[0,0])
        
            # coverage with alpha = 0.5 (95 percent interval)
            SimulationResults_JFE[b,3] = (beta_JFE[0] - 1.96*np.sqrt(vcov_beta_JFE[0,0]) <= beta <= beta_JFE[0] \
                                         + 1.96*np.sqrt(vcov_beta_JFE[0,0])) 
            SimulationResults_BC[b,2]  = (beta_JFE_BC[0] - 1.96*np.sqrt(vcov_beta_JFE[0,0]) <= beta <= beta_JFE_BC[0] \
                                         + 1.96*np.sqrt(vcov_beta_JFE[0,0])) 
        
            # coverage with alpha = 0.10 (90 percent interval)
            SimulationResults_JFE[b,4] = (beta_JFE[0] - 1.645*np.sqrt(vcov_beta_JFE[0,0]) <= beta <= beta_JFE[0] \
                                         + 1.645*np.sqrt(vcov_beta_JFE[0,0]))  
            SimulationResults_BC[b,3]  = (beta_JFE_BC[0] - 1.645*np.sqrt(vcov_beta_JFE[0,0]) <= beta <= beta_JFE_BC[0] \
                                         + 1.645*np.sqrt(vcov_beta_JFE[0,0]))
                                         
            # Calculate rmse of estimated fixed effects
            SimulationResults_BC[b,4]  = (np.mean((A_JFE-A_i)**2))**(1/2)                             
            
        except Exception, e:
            
            # record that JFE/BC logit optimizer failed
            SimulationResults_JFE[b,0] = False
            
            
        if (b==19) and (m==0):
            # Save 19th simulation draw, "dense" example
            DegreeEffects[:,0] = np.ravel(A_i)
            DegreeEffects[:,1] = np.ravel(A_JFE)
            
        if (b==19) and (m==2):
            # Save 19th simulation draw, "sparse" example
            DegreeEffects[:,2] = np.ravel(A_i)
            DegreeEffects[:,3] = np.ravel(A_JFE)        
    
    return np.column_stack((SimulationResults_TL, SimulationResults_JFE, SimulationResults_BC, NetworkProperties))

#-----------------------------------------------------------------------------#
#- MONTE CARLO EXPERIMENTS                                                   -#
#-----------------------------------------------------------------------------#

B = 100
N = 100
n = N*(N-1) // 2

# Count number of processors on machine
num_cores = mp.cpu_count()
print "{0:1d} CPUs available".format(num_cores)

# Get multi-indices for lower triangle of N x N matrix
ij_LowTri = np.tril_indices(N, -1)

# Selection matrix such that T_ij'A = A_i + A_j (n x N)
T = netrics.dyad_jfe_select_matrix(N)[0]

#-------------------------------------#
#- Get tetrad indices                -#
#-------------------------------------#

fixed_dtcon = netrics.generate_tetrad_indices(N, full_set=True)

#-------------------------------------#
#- Specifiy Monte Carlo designs      -#
#-------------------------------------#

# Order of parameters: K,  lambda0, lambda1, SuppLength, alpha_L=E[A|X=0], alpha_H=E[A|X=1], beta
# NOTE: These are the names of the DGP parameters used in the text of the paper
MonteCarloDesigns = [[1,   1,   1,   1,    0,     0,   1], \
                     [1,   1,   1,   1, -1/2,  -1/2,   1], \
                     [1,   1,   1,   1,   -1,    -1,   1], \
                     [1,   1,   1,   1,   -2,    -2,   1], \
                     [1, 1/4, 3/4,   1, -1/6,   2/6,   1], \
                     [1, 1/4, 3/4,   1, -4/6,  -1/6,   1], \
                     [1, 1/4, 3/4,   1, -7/6,  -4/6,   1], \
                     [1, 1/4, 3/4,   1,-13/6, -10/6,   1]]

# Initialize storage matrix for Monte Carlo results & network statistics
SimulationResults_TL  = [] 
SimulationResults_JFE = []
SimulationResults_BC  = [] 
NetworkProperties   = [] 

# Storage matrix for example of estimated degree fixed effects in dense and sparse cases
global DegreeEffects
DegreeEffects = np.zeros((N,4))

pool = mp.Pool(processes = 8)  # Use eight cores
MCResults = pool.map(runSimulationDesign, xrange(0,len(MonteCarloDesigns)))
pool.close()
pool.join()
    
# MCResults = [runSimulationDesign(m) for m in xrange(0,len(MonteCarloDesigns))]

for m in xrange(0,len(MonteCarloDesigns)):
    SimulationResults_TL.append(MCResults[m][:,0:6])
    SimulationResults_JFE.append(MCResults[m][:,6:11])
    SimulationResults_BC.append(MCResults[m][:,11:16])
    NetworkProperties.append(MCResults[m][:,16:21])

# Write example estimated degree fixed effects to text file
# Directory where estimated effects will be saved
workdir =  '/Users/bgraham/Dropbox/Research/Networks/Graphics/'
np.savetxt('A_hat.out', DegreeEffects, delimiter=',')   

#-----------------------------------------------------------------------------#
#- Network topology for each Monte Carlo design                              -#
#-----------------------------------------------------------------------------#    
    
for m in range(0,len(MonteCarloDesigns)):
    
    print "-------------------------------------------------"
    print "- NETWORK PROPERTIES FOR MONTE CARLO DESIGN = "+ str(m+1) + " -"
    print "-------------------------------------------------"
        
    # Summary statistics for simulated network sequences
    NetworkSummary = np.mean(NetworkProperties[m], axis=0)
    
    print ""
    print "Average network density and transitivity"
    print NetworkSummary[0:2]

    print ""
    print "Average degree and degree standard deviation"
    print NetworkSummary[2:4]

    print ""
    print "Average fraction of nodes in largest connected component"
    print NetworkSummary[4]
    print ""
    print ""    

#-----------------------------------------------------------------------------#
#- Summary of Monte Carlo Results                                            -#
#-----------------------------------------------------------------------------#  
    
for m in range(0,len(MonteCarloDesigns)):
    
    print "--------------------------------------------------"
    print "- MONTE CARLO RESULTS FOR MONTE CARLO DESIGN = "+ str(m+1) + " -"
    print "--------------------------------------------------"
    
    #---------------------------------------------------#
    #- TETRAD LOGIT SIMULATION RESULTS                 -#
    #---------------------------------------------------#
    
    print "------------------------------------------------------------------------"
    print "- RESULTS FOR TETRAD LOGIT ESTIMATOR                                   -"
    print "------------------------------------------------------------------------"
    
    # Find simulation replicates where convergence was successful
    b = np.where(SimulationResults_TL[m][:,1])[0]
    SimRes = SimulationResults_TL[m][b,:]

    # Create Pandas dataframe with SN logit Monte Carlo results
    TL=pd.DataFrame({'tetrad_frac_TL' : SimRes[:,0], 'beta_TL' : SimRes[:,2],\
                     'beta_se' : SimRes[:,3],'coverage95' :  SimRes[:,4],\
                     'coverage90' :  SimRes[:,5]})

    print ""
    print "Monte Carlo summary statistics for Tetrad Logit"
    print "--------------------------------------------------"
    print TL.describe()

    Q = TL[['beta_TL']].quantile(q=[0.05,0.95])
    print ""
    print "Robust estimate of standard deviation of beta_TL"
    print "(based on 0.05 & 0.95 sample quantiles of beta_TL)"
    print ""
    print (Q['beta_TL'][0.95]-Q['beta_TL'][0.05])/(2*1.645)
    
    #---------------------------------------------------#
    #- JFE LOGIT SIMULATION RESULTS                    -#
    #---------------------------------------------------#
    
    print "------------------------------------------------------------------------"
    print "- RESULTS FOR JOINT FIXED EFFECTS LOGIT ESTIMATOR                      -"
    print "------------------------------------------------------------------------"
    
    # Find simulation replicates where convergence was successful
    b = np.where(SimulationResults_JFE[m][:,1])[0]
    SimRes = SimulationResults_JFE[m][b,:]

    # Create Pandas dataframe with SN logit Monte Carlo results
    JFE=pd.DataFrame({'beta_JFE' : SimRes[:,1],\
                      'beta_se' : SimRes[:,2],'coverage95' :  SimRes[:,3],\
                      'coverage90' :  SimRes[:,4]})

    print ""
    print "Monte Carlo summary statistics for JFE Logit"
    print "--------------------------------------------------"
    print JFE.describe()

    Q = JFE[['beta_JFE']].quantile(q=[0.05,0.95])
    print ""
    print "Robust estimate of standard deviation of beta_JFE"
    print "(based on 0.05 & 0.95 sample quantiles of beta_JFE)"
    print ""
    print (Q['beta_JFE'][0.95]-Q['beta_JFE'][0.05])/(2*1.645)
    
    #---------------------------------------------------#
    #- BIAS CORRECTED JFE LOGIT SIMULATION RESULTS     -#
    #---------------------------------------------------#
    
    print "------------------------------------------------------------------------"
    print "- RESULTS FOR BIAS CORRECTED JOINT FIXED EFFECTS LOGIT ESTIMATOR       -"
    print "------------------------------------------------------------------------"
       
    # Find simulation replicates where convergence was successful
    SimRes = SimulationResults_BC[m][b,:]

    # Create Pandas dataframe with SN logit Monte Carlo results
    BC=pd.DataFrame({'beta_BC' : SimRes[:,0],\
                      'beta_se' : SimRes[:,1],'coverage95' :  SimRes[:,2],\
                      'coverage90' :  SimRes[:,3], 'rmse A_hat' :  SimRes[:,4]})

    print ""
    print "Monte Carlo summary statistics for BC Logit"
    print "--------------------------------------------------"
    print BC.describe()

    Q = BC[['beta_BC']].quantile(q=[0.05,0.95])
    print ""
    print "Robust estimate of standard deviation of beta_JFE_BC"
    print "(based on 0.05 & 0.95 sample quantiles of beta_JFE_BC)"
    print ""
    print (Q['beta_BC'][0.95]-Q['beta_BC'][0.05])/(2*1.645)    