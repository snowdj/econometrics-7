version 11.0
capture program drop ts_panel_fgls
capture mata mata drop m_ts_panel_fgls()

mata:

void m_ts_panel_fgls(string scalar firststep, string scalar firststep_var, string scalar controlvars, string scalar groupcontrolvars, string scalar touse, string scalar group_id, string scalar cohort_id)
	
	{
	
	/* define mata objects */
	real matrix X, W, Z 
	real matrix OMEGA_hat, iOMEGA_hat, V_hat
	real colvector Y, Y_var
	real scalar N_bp, N_up, n, K, J, sigma2_e, sigma2_a
	string colvector C_names, X_names, W_names, Z_names
	
	/* get required dataviews */
	st_view(Y, ., tokens(firststep), touse)
	st_view(Y_var, ., tokens(firststep_var), touse)
	st_view(X, ., tokens(controlvars), touse)
	st_view(W, ., tokens(groupcontrolvars), touse)
	st_view(G, ., tokens(group_id), touse)
	st_view(C, ., tokens(cohort_id), touse)
	
	X_names = tokens(controlvars)'
	W_names = tokens(groupcontrolvars)'
	C_names = tokens(cohort_id)'
	
	n 			= rows(X)
	Z           = C,X,W
	Z_names     = (C_names',X_names',W_names')'
	K 			= cols(X)
	J 			= cols(W)
			
	/*****************************************/
	/* within-city analysis to get sigma2_e  */
	/*****************************************/
	
	panel_info 	= panelsetup(G,1,2,2)
	N_bp		= rows(panel_info);
	Y_dif		= J(N_bp,1,0)
	X_dif		= J(N_bp,1+K,0)    
	V_dif		= J(N_bp,1,0)
	
	for (i=1; i<=rows(panel_info); i++) {
	    Y_i 	= panelsubmatrix(Y, i, panel_info)
	    Y_var_i = panelsubmatrix(Y_var, i, panel_info)
		X_i 	= panelsubmatrix(X, i, panel_info)	
		Y_dif[i,1]  	= Y_i[2,1] - Y_i[1,1]
		V_dif[i,1]  	= Y_var_i[2,1] + Y_var_i[1,1]
		X_dif[i,.]  	= 1, X_i[2,.] - X_i[1,.]	
	}
	XX_dif = cross(X_dif,X_dif)
	if (rank(XX_dif) < 1 + K) {
			errprintf("singular or near singular matrix ")
			exit(499)
		}
	XY_dif = cross(X_dif,Y_dif)
	pi_dif = cholsolve(XX_dif,XY_dif)
	e_dif = Y_dif - X_dif*pi_dif
	sigma2_e = (e_dif'*e_dif - sum(V_dif) 
	            + trace(cholinv(XX_dif)*X_dif'*diag(V_dif)*X_dif))/(2*(N_bp-1-K))	         		         

	/*****************************************/
	/* between-city analysis to get sigma2_a */
	/*****************************************/            
	
	Y_bar		= J(N_bp,1,0)
	Z_bar		= J(N_bp,K+J,0)
	V_bar		= J(N_bp,1,0)
	s2iT        = J(N_bp,1,0)
	
	for (i=1; i<=rows(panel_info); i++) {
	    Y_i 	= panelsubmatrix(Y, i, panel_info)
	    Y_var_i = panelsubmatrix(Y_var, i, panel_info)
	   	X_i 	= panelsubmatrix(X, i, panel_info)
		W_i 	= panelsubmatrix(W, i, panel_info)
		Z_i     = X_i,W_i
		T_i     = rows(Y_i)
		Y_bar[i,1]  = mean(Y_i)
		V_bar[i,1]  = mean(Y_var_i)/T_i
		Z_bar[i,.]  = mean(Z_i)
		s2iT[i,1]   = sigma2_e/T_i	
	}
	ZZ_bar = cross(Z_bar,Z_bar)
		if (rank(ZZ_bar) < K+J) {
			errprintf("singular or near singular matrix")
			exit(499)
		}
	ZY_bar = cross(Z_bar,Y_bar)
	pi_bar = cholsolve(ZZ_bar,ZY_bar)
	e_bar = Y_bar - Z_bar*pi_bar
	sigma2_a = (e_bar'*e_bar - sum(s2iT+V_bar) 
	            + trace(cholinv(ZZ_bar)*Z_bar'*diag(s2iT+V_bar)*Z_bar))/(N_bp-K-J)   
	
	sigma2_e = max((sigma2_e,0))         
	sigma2_a = max((sigma2_a,0))       
	         	
	/*****************************************/
	/* construct the FGLS weight matrix      */
	/*****************************************/  
	
	OMEGA_hat 	= sigma2_e*I(n) + diag(Y_var)
	
	/* work with full panel, including singletons */
	panel_info 	= panelsetup(G,1)
	N_up 		= rows(panel_info)	
	nc          = 0
	
	for (i=1; i<=rows(panel_info); i++) {
	    Y_i 	= panelsubmatrix(Y, i, panel_info)
	   	T_i     = rows(Y_i)
		OMEGA_hat[nc+1..nc+T_i,nc+1..nc+T_i] = OMEGA_hat[nc+1..nc+T_i,nc+1..nc+T_i]+J(T_i,T_i,sigma2_a)
		nc = nc + T_i	
	}
	
	/*****************************************/
	/* compute FGLS estimate of pi           */
	/*****************************************/ 
	
	/* compute fgls estimates of pi */
	iOMEGA_hat = invsym(OMEGA_hat)
	pi_fgls = cholsolve(Z'*iOMEGA_hat*Z,Z'*iOMEGA_hat*Y)
	V_hat = invsym(Z'*iOMEGA_hat*Z)
			
	/* pass fgls result back into stata */
	coef_names 	= (("pi" :* J(1+K+J,1,1)), Z_names)
	st_matrix("V_hat",V_hat)	
	st_matrixrowstripe("V_hat", coef_names)
	st_matrixcolstripe("V_hat", coef_names)	
		
	st_matrix("pi_fgls",pi_fgls')	
	st_matrixcolstripe("pi_fgls", coef_names)	
			
	st_numscalar("nobs",n)	
	st_numscalar("ngroups",N_up)
	st_numscalar("sigma2_e",sigma2_e)
	st_numscalar("sigma2_a",sigma2_a)	
	st_numscalar("rho",sigma2_a/(sigma2_e+sigma2_a))	
	
									 							
	}
	
end

program define ts_panel_fgls, eclass

	version 11
    syntax varlist(numeric) [if] [in], firststep_var(string) group_varlist(string) group_id(string) cohort_id(string)
   	marksample touse
	
	tokenize `varlist'
	local firststep 			`1'
	macro shift
	local controlvars		`*'
	
	tokenize `group_varlist'
	local groupcontrolvars 	`*'


	mata: m_ts_panel_fgls("`firststep'", "`firststep_var'", "`controlvars'", "`groupcontrolvars'", "`touse'","`group_id'","`cohort_id'")     
	
	display ""
	display ""	
	display "Second step FGLS estimates"
	display "First step estimates               : `firststep'"	
	display "City variable                      : `group_id'"	
	display "Number of 2nd step observations    : " nobs
	display "Number of cities/groups            : " ngroups
	display "Within-city variance component     : " sigma2_e
	display "Between-city variance component    : " sigma2_a
	display "rho                                : " rho
	ereturn post pi_fgls V_hat, esample(`touse')
	ereturn scalar N = nobs
	ereturn scalar sigma2_e = sigma2_e
	ereturn scalar sigma2_a = sigma2_a
	ereturn scalar rho      = rho
	ereturn display	
	
end
