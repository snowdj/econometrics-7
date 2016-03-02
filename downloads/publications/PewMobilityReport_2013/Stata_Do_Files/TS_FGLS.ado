version 11.0
capture program drop ts_fgls
capture mata mata drop m_ts_fgls()

mata:

void m_ts_fgls(string scalar firststep, string scalar firststepvcov, string scalar controlvars, string scalar touse)
	
	{
	
	/* define mata objects */
	real matrix X, XX  
	real matrix LAMBDA_hat, OMEGA_hat, iOMEGA_hat, V_hat
	real colvector Y, XY, pi_ols, pi_fgls
	real scalar N, K, sigma2_ols
	string colvector X_names
	
	/* normalize objects and extract passed in objects from stata */		
	Y = X = XX = XY = .
	LAMBDA_hat = OMEGA_hat = iOMEGA_hat = V_hat = .
	st_view(Y, ., tokens(firststep), touse)
	LAMBDA_hat = st_matrix(firststepvcov)
	st_view(X, ., tokens(controlvars), touse)
	X_names = tokens(controlvars)
	X_names = (X_names, "_cons")'			
	
	/* estimate sigma2_hat by ols and compute fgls weight matrix */	
	N = rows(X)
	X = (X, J(N,1,1))
	K = cols(X)	
	XX = cross(X,X)
		if (rank(XX) < K) {
			errprintf("singular or near singular matrix")
			exit(499)
		}
	XY = cross(X,Y)
	pi_ols = cholsolve(XX,XY)
	e = Y - X*pi_ols
	sigma2_ols = (e'e - trace(LAMBDA_hat) + trace(cholinv(XX)*X'*LAMBDA_hat*X))/(N-K)
	OMEGA_hat = sigma2_ols*I(N) + LAMBDA_hat
	
	/* compute fgls estimates of pi */
	iOMEGA_hat = invsym(OMEGA_hat)
	pi_fgls = cholsolve(X'*iOMEGA_hat*X,X'*iOMEGA_hat*Y)
	V_hat = invsym(X'*iOMEGA_hat*X)
	
	/* pass fgls result back into stata */
	coef_names 	= (("pi" :* J(K,1,1)), X_names)
	st_matrix("V_hat",V_hat)	
	st_matrixrowstripe("V_hat", coef_names)
	st_matrixcolstripe("V_hat", coef_names)	
		
	st_matrix("pi_fgls",pi_fgls')	
	st_matrixcolstripe("pi_fgls", coef_names)	
			
	st_numscalar("nobs",N)	
	st_numscalar("sigma_ols",sqrt(sigma2_ols))	
									 							
	}
	
end

program define ts_fgls, eclass

	version 11
    syntax varlist(numeric) [if] [in], firststepvcov(string)
   	marksample touse
	
	tokenize `varlist'
	local firststep 		`1'
	macro shift
	local controlvars 		`*'

	mata: m_ts_fgls("`firststep'", "`firststepvcov'", "`controlvars'", "`touse'")     
	
	display ""
	display ""	
	display "Second step FGLS estimates"
	display "First step estimates                        : `firststep'"	
	display "Number of 2nd step observations             : " nobs
	display "Standard deviation of 2nd step observations : " sigma_ols
	ereturn post pi_fgls V_hat, esample(`touse')
	ereturn scalar N = nobs
	ereturn scalar sigma = sigma_ols
	ereturn display	
	
end
