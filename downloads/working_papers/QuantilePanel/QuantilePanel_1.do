/***************************************************************************************************/
/* Fall 2014 Quantile Panel Data Do File        			   		         					   */
/* Bryan S. Graham, UC - BERKELEY									         			   		   */
/* bgraham@econ.berkeley.edu       						         		   			   			   */
/* Oct 2014                              								         				   */
/***************************************************************************************************/

/***************************************************************************************************/
/* This file replicates the empirical results presented in Section 4 of the paper "Quantile        */
/* regression with panel data" by Bryan Graham, Jinyong Hahn, Alex Poirier and James L. Powell.    */
/* To run the file adjust the global directory points below to properly point to the location of   */
/* the NLSY79_Teaching_Fall2014.dta data file, this do file and wherever you would like output     */
/* to be saved (e.g., figures, log file etc.).                                                     */
/***************************************************************************************************/


/* use a semicolon as the command delimiter */
#delimit ;

clear matrix;
clear mata;
clear;

set matsize 8000;
set memory 1000m;

/***************************************************************************************************/
/* SET DIRECTORY LOCATIONS FOR DATA, DO FILES AND OUTPUT FILES (including graphics)                */
/***************************************************************************************************/


global SOURCE 			"/accounts/fac/bgraham/Teaching/Ec240a_Fall2014";
global DO 				"/accounts/fac/bgraham/Research_EML/QuantilePanel/Empirics/Stata_Do";
global WRITE 			"/accounts/fac/bgraham/Research_EML/QuantilePanel/Empirics/Created_Data";

/* load dataset */
use "$SOURCE/NLSY79_Teaching_Fall2014.dta", clear;


/* Form balanced panel */
/* Selection criteria: (i) paid employment (not self-employed), (ii) collective bargaining coverage information, (iii) valid hourly wage data (drop < $1 and >$1000 per hour ) (iv) in core NLSY79 samples (v) male */
/* NOTE: Core sample includes all the cross sectional samples as well as the supplemental black and hispanic samples */
g BalancedPanel 	= 	(cps_status88<=2)*(cps_union88~=.)*(cps_hourly_wage88~=.)*(cps_hourly_wage88>=1)*(cps_hourly_wage88<=1000)* 	
						(cps_status89<=2)*(cps_union89~=.)*(cps_hourly_wage89~=.)*(cps_hourly_wage89>=1)*(cps_hourly_wage89<=1000)*
						(cps_status90<=2)*(cps_union90~=.)*(cps_hourly_wage90~=.)*(cps_hourly_wage90>=1)*(cps_hourly_wage90<=1000)*
						(cps_status91<=2)*(cps_union91~=.)*(cps_hourly_wage91~=.)*(cps_hourly_wage91>=1)*(cps_hourly_wage91<=1000)*
						(cps_status92<=2)*(cps_union92~=.)*(cps_hourly_wage92~=.)*(cps_hourly_wage92>=1)*(cps_hourly_wage92<=1000)*(core_sample==1)*(male==1);

log using "$WRITE/QuantilePanelResults", replace;
log on;

/* Display employment status of all target individuals */
tab core_sample male, missing;
tab cps_status88 if core_sample==1 & male==1, missing;
tab cps_status89 if core_sample==1 & male==1, missing;
tab cps_status90 if core_sample==1 & male==1, missing;
tab cps_status91 if core_sample==1 & male==1, missing;
tab cps_status92 if core_sample==1 & male==1, missing;
log off;

g cross_section88 = (cps_status88<=2)*(cps_union88~=.)*(cps_hourly_wage88~=.)*(cps_hourly_wage88>=1)*(cps_hourly_wage88<=1000)*(core_sample==1)*(male==1);
g cross_section89 = (cps_status89<=2)*(cps_union89~=.)*(cps_hourly_wage89~=.)*(cps_hourly_wage89>=1)*(cps_hourly_wage89<=1000)*(core_sample==1)*(male==1);
g cross_section90 = (cps_status90<=2)*(cps_union90~=.)*(cps_hourly_wage90~=.)*(cps_hourly_wage90>=1)*(cps_hourly_wage90<=1000)*(core_sample==1)*(male==1);
g cross_section91 = (cps_status91<=2)*(cps_union91~=.)*(cps_hourly_wage91~=.)*(cps_hourly_wage91>=1)*(cps_hourly_wage91<=1000)*(core_sample==1)*(male==1);
g cross_section92 = (cps_status92<=2)*(cps_union92~=.)*(cps_hourly_wage92~=.)*(cps_hourly_wage92>=1)*(cps_hourly_wage92<=1000)*(core_sample==1)*(male==1);

log on;
/* Size of feasible cross sectional analysis for each year */
tab cross_section88 if core_sample==1 & male==1, missing;
tab cross_section89 if core_sample==1 & male==1, missing;
tab cross_section90 if core_sample==1 & male==1, missing;
tab cross_section91 if core_sample==1 & male==1, missing;
tab cross_section92 if core_sample==1 & male==1, missing;

tab BalancedPanel if core_sample==1 & male==1, missing;	
log off;

keep if	BalancedPanel==1;			  

/* Form collective bargaining coverage history variable */				  
egen 	UnionHistory 	= group(cps_union88 cps_union89 cps_union90 cps_union91 cps_union92), label;
g 		UnionSum 		= cps_union88+cps_union89+cps_union90+cps_union91+cps_union92;

log on;
tab UnionHistory;
tab UnionSum;
log off;

/* Put dataset in stacked/panel form */
stack 	cps_hourly_wage88 cps_status88 cps_union88 cps_union88 cps_union89 cps_union90 cps_union91 cps_union92 UnionHistory year_born live_with_mom_at_14 live_with_dad_at_14 single_mom_at_14 hispanic black ROTTER ROSENBERG HGC_Age24 HGC_FATH79r HGC_MOTH79r AFQT80_PCT_ABL sample_wgts PID_79 HHID_79
		cps_hourly_wage89 cps_status89 cps_union89 cps_union88 cps_union89 cps_union90 cps_union91 cps_union92 UnionHistory year_born live_with_mom_at_14 live_with_dad_at_14 single_mom_at_14 hispanic black ROTTER ROSENBERG HGC_Age24 HGC_FATH79r HGC_MOTH79r AFQT80_PCT_ABL sample_wgts PID_79 HHID_79
		cps_hourly_wage90 cps_status90 cps_union90 cps_union88 cps_union89 cps_union90 cps_union91 cps_union92 UnionHistory year_born live_with_mom_at_14 live_with_dad_at_14 single_mom_at_14 hispanic black ROTTER ROSENBERG HGC_Age24 HGC_FATH79r HGC_MOTH79r AFQT80_PCT_ABL sample_wgts PID_79 HHID_79
		cps_hourly_wage91 cps_status91 cps_union91 cps_union88 cps_union89 cps_union90 cps_union91 cps_union92 UnionHistory year_born live_with_mom_at_14 live_with_dad_at_14 single_mom_at_14 hispanic black ROTTER ROSENBERG HGC_Age24 HGC_FATH79r HGC_MOTH79r AFQT80_PCT_ABL sample_wgts PID_79 HHID_79
		cps_hourly_wage92 cps_status92 cps_union92 cps_union88 cps_union89 cps_union90 cps_union91 cps_union92 UnionHistory year_born live_with_mom_at_14 live_with_dad_at_14 single_mom_at_14 hispanic black ROTTER ROSENBERG HGC_Age24 HGC_FATH79r HGC_MOTH79r AFQT80_PCT_ABL sample_wgts PID_79 HHID_79,
      	into(HourlyWage cps_status Union U88 U89 U90 U91 U92 UnionHistory year_born live_with_mom_at_14 live_with_dad_at_14 single_mom_at_14 hispanic black ROTTER ROSENBERG HGC_Age24 HGC_FATH79r HGC_MOTH79r AFQT80_PCT_ABL sample_wgts PID_79 HHID_79) clear;

rename _stack year;
replace year = 1988 if year==1;
replace year = 1989 if year==2;
replace year = 1990 if year==3;
replace year = 1991 if year==4;
replace year = 1992 if year==5;

g T1988 = (year==1988);
g T1989 = (year==1989);
g T1990 = (year==1990);
g T1991 = (year==1991);
g T1992 = (year==1992);

g LogWage = log(HourlyWage);

g Union_X_T1989 = Union*T1989;
g Union_X_T1990 = Union*T1990;
g Union_X_T1991 = Union*T1991;
g Union_X_T1992 = Union*T1992;

/* Generate Arellano/Bover Instrument set */
g T88_U88 = U88*(year==1988);
g T88_U89 = U89*(year==1988);
g T88_U90 = U90*(year==1988);
g T88_U91 = U91*(year==1988);
g T88_U92 = U92*(year==1988);

g T89_U88 = U88*(year==1989);
g T89_U89 = U89*(year==1989);
g T89_U90 = U90*(year==1989);
g T89_U91 = U91*(year==1989);
g T89_U92 = U92*(year==1989);

g T90_U88 = U88*(year==1990);
g T90_U89 = U89*(year==1990);
g T90_U90 = U90*(year==1990);
g T90_U91 = U91*(year==1990);
g T90_U92 = U92*(year==1990);

g T91_U88 = U88*(year==1991);
g T91_U89 = U89*(year==1991);
g T91_U90 = U90*(year==1991);
g T91_U91 = U91*(year==1991);
g T91_U92 = U92*(year==1991);

g T92_U88 = U88*(year==1992);
g T92_U89 = U89*(year==1992);
g T92_U90 = U90*(year==1992);
g T92_U91 = U91*(year==1992);
g T92_U92 = U92*(year==1992);

log on;
/* Sumary Statistics */
/* Time invariant characteristics */
/* Full Sample */
sum hispanic black HGC_Age24 ROTTER ROSENBERG AFQT80_PCT_ABL if year==1988 [aw=sample_wgts];
/* Never in Union */
sum hispanic black HGC_Age24 ROTTER ROSENBERG AFQT80_PCT_ABL if UnionHistory==1 & year==1988 [aw=sample_wgts];
/* Sometimes in Union */
sum hispanic black HGC_Age24 ROTTER ROSENBERG AFQT80_PCT_ABL if UnionHistory>1 & UnionHistory<32 & year==1988 [aw=sample_wgts];
/* Always in Union */
sum hispanic black HGC_Age24 ROTTER ROSENBERG AFQT80_PCT_ABL if UnionHistory==32 & year==1988 [aw=sample_wgts];

/* Time varying attributes */
/* Full sample */
bys year: sum LogWage HourlyWage Union [aw=sample_wgts];
/* Never in Union */
bys year: sum LogWage HourlyWage Union if UnionHistory==1  [aw=sample_wgts];
/* Sometimes in Union */
bys year: sum LogWage HourlyWage Union if UnionHistory>1 & UnionHistory<32  [aw=sample_wgts];
/* Always in Union */
bys year: sum LogWage HourlyWage Union if UnionHistory==32  [aw=sample_wgts];
log off;

g NeverUnion 	= (UnionHistory==1);
g AlwaysUnion 	= (UnionHistory==32);
g Movers		= 1 - NeverUnion - AlwaysUnion;

log on;
bys year: reg HourlyWage Movers AlwaysUnion  [aw=sample_wgts], cluster(HHID_79);
bys year: reg LogWage Movers AlwaysUnion  [aw=sample_wgts], cluster(HHID_79);
reg hispanic NeverUnion AlwaysUnion if year==1988  [aw=sample_wgts], cluster(HHID_79);
reg black NeverUnion AlwaysUnion if year==1988  [aw=sample_wgts], cluster(HHID_79);
reg HGC_Age24 NeverUnion AlwaysUnion if year==1988  [aw=sample_wgts], cluster(HHID_79);
reg AFQT80_PCT_ABL NeverUnion AlwaysUnion if year==1988  [aw=sample_wgts], cluster(HHID_79);

/**************/
/* Pooled OLS */
/**************/

/* No covariates */
/* w/o time-varying slopes */
reg LogWage Union T1989-T1992 [aw=sample_wgts], cluster(HHID_79);
/* w time-varying slopes */
reg LogWage Union Union_X_T1989-Union_X_T1992 T1989-T1992 [aw=sample_wgts], cluster(HHID_79);
test Union_X_T1989=Union_X_T1990=Union_X_T1991=Union_X_T1992=0;

/* With covariates */
/* w/o time-varying slopes */
reg LogWage Union T1989-T1992 hispanic black HGC_Age24 AFQT80_PCT_ABL [aw=sample_wgts], cluster(HHID_79); /* Gets number of households with covariate data */
reg LogWage Union T1989-T1992 hispanic black HGC_Age24 AFQT80_PCT_ABL [aw=sample_wgts], cluster(PID_79);  /* Number of individuals with covariate data */
g t = e(sample);
reg LogWage Union T1989-T1992 [aw=sample_wgts] if t==1, cluster(HHID_79);								  /* Simple model on subset of individuals with complete covariate data */	
drop t;
/* w/ time-varying slopes */
reg LogWage Union Union_X_T1989-Union_X_T1992 T1989-T1992 hispanic black HGC_Age24 AFQT80_PCT_ABL [aw=sample_wgts], cluster(HHID_79);
test Union_X_T1989=Union_X_T1990=Union_X_T1991=Union_X_T1992=0;

/******************/
/* Chamberlain-FE */
/******************/

/********************************/
/* w/o correlated heterogeneity */
/********************************/

/* w/o time-varying slopes */
gmm (LogWage - {xb:Union T1989 T1990 T1991 T1992}-{b0}) [aw=sample_wgts], instruments(T1988-T1992 T88_U88-T92_U92, nocons) derivative(/xb = -1) derivative(/b0 = -1) vce(cluster HHID_79) twostep;
estat overid;

/* w/ time-varying slopes */
gmm (LogWage - {xb:Union Union_X_T1989 Union_X_T1990 Union_X_T1991 Union_X_T1992 T1989 T1990 T1991 T1992}-{b0}) [aw=sample_wgts], instruments(T1988-T1992 T88_U88-T92_U92, nocons) derivative(/xb = -1) derivative(/b0 = -1) vce(cluster HHID_79) twostep;
estat overid;

/*******************************/
/* w/ correlated heterogeneity */
/*******************************/

/* w/o time-varying slopes */
gmm (LogWage - {xb:Union T1989 T1990 T1991 T1992 U88-U92}-{b0}) [aw=sample_wgts], instruments(T1988-T1992 T88_U88-T92_U92, nocons) derivative(/xb = -1) derivative(/b0 = -1) vce(cluster HHID_79) twostep;
estat overid;

/* w/ time-varying slopes */
gmm (LogWage - {xb:Union Union_X_T1989 Union_X_T1990 Union_X_T1991 Union_X_T1992 T1989 T1990 T1991 T1992 U88-U92}-{b0}) [aw=sample_wgts], instruments(T1988-T1992 T88_U88-T92_U92, nocons) derivative(/xb = -1) derivative(/b0 = -1) vce(cluster HHID_79) twostep;
estat overid;

/*****************************************************/
/* Fully flexible model for correlated heterogeneity */
/*****************************************************/
/* w/o time-varying slopes */
areg LogWage Union T1989-T1992 [aw=sample_wgts], absorb(UnionHistory) cluster(HHID_79);

/* w/ time-varying slopes */
areg LogWage Union Union_X_T1989-Union_X_T1992 T1989-T1992 [aw=sample_wgts], absorb(UnionHistory) cluster(HHID_79);
test Union_X_T1989=Union_X_T1990=Union_X_T1991=Union_X_T1992=0;
log off;

/******************************************************************************/
/* COMPUTE CRC QUANTILE PANEL DATA MODEL                                      */
/* PART I: COMPUTE POINT ESTIMATES                                            */
/******************************************************************************/

/**************************/
/* INITIALIZE PROBLEM     */
/**************************/

egen t = max(UnionHistory);	/* Number of support points of X */
local M 	= t[1];
drop t;
local L		= `M' - 2;		/* Number of mover support points */
		
local T 	= 5;			/* Number of time periods */
local P 	= 2;			/* Dimension of X_t */
local ngp 	= 99;			/* Number of tau quantile grid points */

/* Form tau evaluation grip */
local gp_s = (1/(`ngp'+1))*100;
local gp_f = (`ngp'/(`ngp'+1))*100;

matrix CQ 			= J(`T',1+`ngp',0);	/* Matrix to store conditional quantile estimates for each m=1...M (plus conditional mean in last column) */
matrix cell_sizes 	= J(`M',1,0);		/* Vector to store number of effective units per cell m=1...M */
matrix stayers      = J(`M',1,0);		/* Vector indicating whether a given support point is a stayer support point */

/********************************************************/
/* ESTIMATE CQF of Y FOR EACH SUPPORT POINT AND PERIOD  */
/********************************************************/

/* NOTE: First and last union histories correspond to stayers 0 0 0 0 0 and 1 1 1 1 1 */
levelsof UnionHistory, local(UnionHistory_list);
local l = 0;	/* Indexes mover support points */


foreach m of local UnionHistory_list {; /* Loop over all support points of X */
	
	/* Get union history associated with m-th support point */
	quietly: reg U88  [aw=sample_wgts] if UnionHistory == `m',r;
	matrix U88 = e(b);
	quietly: reg U89  [aw=sample_wgts] if UnionHistory == `m',r;
	matrix U89 = e(b);
	quietly: reg U90  [aw=sample_wgts] if UnionHistory == `m',r;
	matrix U90 = e(b);
	quietly: reg U91  [aw=sample_wgts] if UnionHistory == `m',r;
	matrix U91 = e(b);
	quietly: reg U92  [aw=sample_wgts] if UnionHistory == `m',r;
	matrix U92 = e(b);
	
	/* Calculate total of sample weights associated current support point */
	quietly: total sample_wgts if UnionHistory == `m' & year==1988;
	matrix wgt_total = e(b);
	matrix cell_sizes[`m',1] 	= wgt_total[1,1];
		
	/* Check to see if current support point is a "stayer" */
	matrix stayers[`m',1]		= 1 - ((U88[1,1]+U89[1,1]+U90[1,1]+U91[1,1]+U92[1,1])~=0)*((U88[1,1]+U89[1,1]+U90[1,1]+U91[1,1]+U92[1,1])~=`T');
	local l = `l' + ((U88[1,1]+U89[1,1]+U90[1,1]+U91[1,1]+U92[1,1])~=0)*((U88[1,1]+U89[1,1]+U90[1,1]+U91[1,1]+U92[1,1])~=`T');
		
	/* Compute support point's values of x_m and w_m matrices */
	/* NOTE: Fit restricted model with intercept shifts only */
	matrix x_m = 1, U88[1,1] \ 1, U89[1,1] \ 1, U90[1,1] \ 1, U91[1,1] \ 1, U92[1,1];
	matrix w_m = 0, 0, 0, 0 \ 1, 0, 0, 0 \ 0, 1, 0, 0 \ 0, 0, 1, 0 \ 0, 0, 0, 1;
	
	/* Calculate T x 1 vector of conditional quantiles of Y for each tau in grid */
	forval t = 1988/1992 {;
		di "-> UnionHistory = `m'";
		di "-> Year = `t'";
		/* Compute log earnings quantile for each year-by-history cell (also compute mean to get APEs) */
		quietly: sum LogWage [aw=sample_wgts] if year==`t' & UnionHistory == `m';
		matrix CQ[`t'-1987,`ngp'+1] = r(mean);	/* Mean estimate */
		quietly: _pctile LogWage [aw=sample_wgts] if year==`t' & UnionHistory == `m', p(`gp_s'(`gp_s')`gp_f');
		forval q=1/`ngp' {;
			matrix CQ[`t'-1987,`q'] =  r(r`q');	/* Quantile estimate */
		};		
	};
	
	/* Form m-th support points contribution to PI vector and G matrix */
	local stayer = stayers[`m',1];
		
	if `stayer'==1 {;
		/* Case 1: m-th support point is a "stayer" support point */
		matrix STM = J(`T'-1,1,-1),I(`T'-1);	/* stayer `transform' matrix */
		matrix MD_m = J(`T'-1,1,wgt_total[1,1]), STM*CQ, STM*w_m, J(`T'-1,`L'*`P',0);
	};
	else {;
		/* Case 2: m-th support point is a "mover" support point */
		if `l'==1 {;
			matrix MD_m = J(`T',1,wgt_total[1,1]), CQ, w_m, x_m, J(`T',(`L'-`l')*`P',0);
		};
		else if `l'==`L' {;
			matrix MD_m = J(`T',1,wgt_total[1,1]), CQ, w_m, J(`T',(`l'-1)*`P',0), x_m;
		};
		else {;
			matrix MD_m = J(`T',1,wgt_total[1,1]), CQ, w_m, J(`T',(`l'-1)*`P',0), x_m, J(`T',(`L'-`l')*`P',0);
		};
	};
	
	matrix MD =  (nullmat(MD) \ MD_m);
	
};

/************************************************************/
/* COMPUTE DELTA() AND BETA(,X) VECTORS BY MINIMUM DISTANCE */
/************************************************************/


matrix G 		= MD[1...,1+`ngp'+1+1...]; 						/* G from MD matrix */
matrix A 		= diag(MD[1...,1]);								/* Construct weight matrix */
matrix GAG 		= G'*A*G;
matrix p 		= cell_sizes[2..31,1]/trace(diag(cell_sizes[2..31,1]));	/* Re-normalized probability mass for each mover support point */

/* Extract individual coefficient components */
local ngp_p1 = `ngp'+1;

forval q = 1/`ngp_p1' {;
	matrix PI 				= MD[1...,1+`q'];		/* PI vector */
	matrix GAPI				= G'*A*PI;
	mata : st_matrix("GAMMA", cholsolve(st_matrix("GAG"),st_matrix("GAPI")));
	matrix DELTA			= nullmat(DELTA), GAMMA[1..(`T'-1),1];
	forval l = 1/`L' {;
		matrix b0			= nullmat(b0) \ GAMMA[(`T'-1) + (`l'-1)*`P' + 1,1];									 
		matrix b1			= nullmat(b1) \ GAMMA[(`T'-1) + (`l'-1)*`P' + 2,1];
	};
	
	matrix BETA0 = nullmat(BETA0), b0;
	matrix BETA1 = nullmat(BETA1), b1;
	matrix drop b0 b1;
};

matrix DELTA_APE 	= DELTA[1...,`ngp_p1'];
matrix BETA_APE 	= p'*(BETA0[1...,`ngp_p1'], BETA1[1...,`ngp_p1']);
matrix APE          = BETA_APE, DELTA_APE';

matrix DELTA		= DELTA[1...,1..`ngp'];
matrix BETA0		= BETA0[1...,1..`ngp'];
matrix BETA1		= BETA1[1...,1..`ngp'];

/**************************************************/
/* COMPUTE ACQE INEQUALITY MEASURE AND UQE        */
/**************************************************/

local uq = round(0.90*(`ngp'+1));
local lq = round(0.10*(`ngp'+1));

/* 90-10 inequality measure */
matrix GAP9010_NU     = p'*(BETA0[1...,`uq']-BETA0[1...,`lq'] 																				+ (DELTA[4,`uq']-DELTA[4,`lq'])*J(30,1,1)); 
matrix GAP9010_U   	  = p'*(BETA0[1...,`uq']-BETA0[1...,`lq'] + hadamard(BETA1[1...,`uq']-BETA1[1...,`lq'],J(30,1,1))  						+ (DELTA[4,`uq']-DELTA[4,`lq'])*J(30,1,1)); 
matrix GAP9010_DIF    = GAP9010_U[1,1] - GAP9010_NU[1,1]; 
matrix GAP9010		  = GAP9010_NU, GAP9010_U, GAP9010_DIF; 

/* Compute unconditional quantile effect */
matrix BETA1 = vec(BETA1);
svmat BETA1;

/* Construct weights for UQE inversion */
matrix UQE_wgts = J(99,1,1) # p;
svmat UQE_wgts;

matrix UQE 		= J(99,2,0);		/* UQE of Union Coverage */
matrix UQE_NV 	= J(99,2,0);        /* UQE of Union Coverage: cross-section and Abrevaya and Dahl */

forval tau = 1/99 {;
	di "-> tau = `tau'";
	quietly _pctile BETA11 [aw= UQE_wgts1], p(`tau');
	matrix UQE[`tau',1] = `tau'/100;
	matrix UQE[`tau',2] = r(r1);

	/* Compute UQE for Pooled Quantile Regression Estimators */
	/* Linear Quantile Regression */
	local t = `tau'/100;
	quietly qreg LogWage Union T1989-T1992 [pw=sample_wgts], quantile(`t');
	matrix union_eff = e(b);
	matrix UQE_NV[`tau',1] = union_eff[1,1];
	
	/* Abrevaya and Dahl Approach */
	quietly qreg LogWage Union U88-U92 T1989-T1992 [pw=sample_wgts], quantile(`t');
	matrix union_eff = e(b);
	matrix UQE_NV[`tau',2] = union_eff[1,1];
};
drop BETA1* UQE_wgts*;

matrix drop BETA0 BETA1 DELTA GAMMA DELTA_APE BETA_APE UQE_wgts p;


/******************************************************************************/
/* COMPUTE CRC QUANTILE PANEL DATA MODEL                                      */
/* PART II: BAYESIAN BOOTSTRAP                                                */
/******************************************************************************/

local BS = 200;
set seed 19;

/* Initialize matrices to save bootstrap replication results in */
matrix GAP_BS 	= J(`BS',3,0);
matrix UQE_BS 	= J(`BS',99,0);
matrix CQ_BS	= J(`T',`ngp'+1,0);


g V = 0; /* Variable to store Bayes Bootstrap random weights */

forval b=1/`BS' {;

	di "-> Bayesian Bootstrap Replication = `b' of `BS'";
			
	/* Construct Bayes Bootstrap Weights */
	bys HHID_79: g t=rgamma(1,1);
	bys HHID_79: replace t=t[_n-1] if _n>1;
	quietly: replace V = t*sample_wgt;
	drop t;
	

	foreach m of local UnionHistory_list {; /* Loop over all support points of X */
	
		/* Calculate total of sample weights within current support point */
		quietly: total V if UnionHistory == `m' & year==1988;
		matrix wgt_total = e(b);
		matrix cell_sizes[`m',1] 	= wgt_total[1,1];
					
		forval t = 1988/1992 {;
			/* Compute log earnings quantile for each year-by-history cell  (also compute mean to get APEs) */
			quietly: sum LogWage [aw=V] if year==`t' & UnionHistory == `m';
			matrix CQ_BS[`t'-1987,`ngp'+1] = r(mean);		/* Mean estimate */
			quietly: _pctile LogWage [aw=V] if year==`t' & UnionHistory == `m', p(`gp_s'(`gp_s')`gp_f');
			forval q=1/`ngp' {;
				matrix CQ_BS[`t'-1987,`q'] =  r(r`q');	/* Quantile estimate */
			};			
		};
		
		/* Keep track of bootstrap weights */
		local stayer = stayers[`m',1];
		
		if `stayer'==1 {;
			/* Case 1: m-th support point is a "stayer" support point */
			matrix MD_m = J(`T'-1,1,wgt_total[1,1]), STM*CQ_BS;
		};
		else {;
			/* Case 2: m-th support point is a "mover" support point */
			matrix MD_m = J(`T',1,wgt_total[1,1]), CQ_BS;
		};
		matrix MD_BS =  (nullmat(MD_BS) \ MD_m);
	};

	/************************************************************/
	/* COMPUTE DELTA() AND BETA(,X) VECTORS BY MINIMUM DISTANCE */
	/************************************************************/
	
	matrix A 		= diag(MD_BS[1...,1]);		/* Construct weight matrix */
	matrix GAG 		= G'*A*G;
	matrix p 		= cell_sizes[2..31,1]/trace(diag(cell_sizes[2..31,1]));	/* Re-normalized probability mass for each mover support point */
			
	/* Extract individual coefficient components */
	forval q = 1/`ngp_p1' {;
		matrix PI 				= MD_BS[1...,1+`q'];		/* PI vector */
		matrix GAPI				= G'*A*PI;
		mata : st_matrix("GAMMA", cholsolve(st_matrix("GAG"),st_matrix("GAPI")));
		matrix DELTA			= nullmat(DELTA), GAMMA[1..(`T'-1),1];
		forval l = 1/`L' {;
			matrix b0			= nullmat(b0) \ GAMMA[(`T'-1) + (`l'-1)*`P' + 1,1];									 
			matrix b1			= nullmat(b1) \ GAMMA[(`T'-1) + (`l'-1)*`P' + 2,1];
		};
	
		matrix BETA0 = nullmat(BETA0), b0;
		matrix BETA1 = nullmat(BETA1), b1;
		matrix drop b0 b1;		
	};
	
	
	matrix DELTA_APE 	= DELTA[1...,`ngp_p1'];
	matrix BETA_APE 	= p'*(BETA0[1...,`ngp_p1'], BETA1[1...,`ngp_p1']);
	matrix APE_BS 		=  (nullmat(APE_BS) \  ((BETA_APE, DELTA_APE') - APE));
	
	matrix DELTA		= DELTA[1...,1..`ngp'];
	matrix BETA0		= BETA0[1...,1..`ngp'];
	matrix BETA1		= BETA1[1...,1..`ngp'];
	
	/**************************************************/
	/* COMPUTE ACQE INEQUALITY MEASURE AND UQE        */
	/**************************************************/
	
	/* 90-10 inequality measure */
	matrix GAP_BS[`b',1]    = p'*(BETA0[1...,`uq']-BETA0[1...,`lq']   																				+ (DELTA[4,`uq']-DELTA[4,`lq'])*J(30,1,1)) 	- GAP9010[1,1]; 
	matrix GAP_BS[`b',2]    = p'*(BETA0[1...,`uq']-BETA0[1...,`lq'] + hadamard(BETA1[1...,`uq']-BETA1[1...,`lq'],J(30,1,1))  						+ (DELTA[4,`uq']-DELTA[4,`lq'])*J(30,1,1))  - GAP9010[1,2]; 
	matrix GAP_BS[`b',3]    = (GAP_BS[`b',2] - GAP_BS[`b',1]); /* NOTE: Bias correction "built in" by virtue of previous two steps */ 
		
	/* Compute unconditional quantile effect */
	matrix BETA1 = vec(BETA1);
	svmat BETA1;
	
	/* Construct weights for UQE inversion */
	matrix UQE_wgts = J(99,1,1) # p;
	svmat UQE_wgts;
		
	forval tau = 1/99 {;
		quietly _pctile BETA11 [aw=UQE_wgts1], p(`tau');
		matrix UQE_BS[`b',`tau'] = r(r1) - UQE[`tau',2];
	};
	drop BETA1* UQE_wgts*;
	matrix drop BETA0 BETA1 DELTA GAMMA MD_BS DELTA_APE BETA_APE UQE_wgts;
};	


/******************************************************/
/* CONSTRUCT 90 PERCENT CONFIDENCE BANDS              */
/******************************************************/

local ul_BS = round(0.95*(`BS'));
local ll_BS = round(0.05*(`BS'));

matrix GAP_CB = J(4,3,0);
matrix UQE_CB = J(99,4,0);
matrix APE_CB = J(4,`P' + (`T'-1),0);

forval g = 1/3 {;
	mata : st_matrix("GAP_BS", sort(st_matrix("GAP_BS"), `g'));
	matrix GAP_CB[1,`g'] = GAP9010[1,`g'] - GAP_BS[`ul_BS',`g'];
	matrix GAP_CB[2,`g'] = GAP9010[1,`g'] - GAP_BS[`ll_BS',`g']; 
	matrix GAP_CB[3,`g'] = (GAP_CB[2,`g'] - GAP_CB[1,`g'])/(2*1.645); 
	matrix GAP_CB[4,`g'] = GAP9010[1,`g'] - J(1,`BS',1)*GAP_BS[1...,`g']/`BS'; 
};

forval tau = 1/99 {;
		mata : st_matrix("UQE_BS", sort(st_matrix("UQE_BS"), `tau'));
		matrix UQE_CB[`tau',1] = UQE[`tau',2] - (UQE_BS[`ul_BS',`tau']); 
		matrix UQE_CB[`tau',2] = UQE[`tau',2] - (UQE_BS[`ll_BS',`tau']);
		matrix UQE_CB[`tau',3] = (UQE_CB[`tau',2]-UQE_CB[`tau',1])/(2*1.645); 
		matrix UQE_CB[`tau',4] = UQE[`tau',2] - J(1,`BS',1)*UQE_BS[1...,`tau']/`BS'; 
};

local num_reg = `P' + (`T'-1);
forval p = 1/`num_reg' {;
	mata : st_matrix("APE_BS", sort(st_matrix("APE_BS"), `p'));
	matrix APE_CB[1,`p'] = APE[1,`p'] - APE_BS[`ul_BS',`p'];
	matrix APE_CB[2,`p'] = APE[1,`p'] - APE_BS[`ll_BS',`p']; 
	matrix APE_CB[3,`p'] = (APE_CB[2,`p']-APE_CB[1,`p'])/(2*1.645); 
	matrix APE_CB[4,`p'] = APE[1,`p'] - J(1,`BS',1)*APE_BS[1...,`p']/`BS';
};

/*****************************************************/
/* Plot the UQE                                      */
/*****************************************************/

/* sort UQE w/o heterogeneity to be monotonic */
mata : st_matrix("UQE_NVsorted", sort(st_matrix("UQE_NV"), 1));

svmat UQE;
svmat UQE_NV;
svmat UQE_NVsorted;
svmat UQE_CB;

local beta_bar = APE[1,2];

scatter UQE_CB4 UQE_CB1 UQE_CB2 UQE_NVsorted1 UQE1 if UQE1>=.1 & UQE1<=.9, lcolor(blue gs10 gs10 red) msymbol(i i i i) c(l l l l) clpattern(l -. -. shortdash)
		xlabel(0.10 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9)
		ylabel(-0.20 0.00 0.20 0.40)
		yscale(range(-0.2 0.5))
		title("")
		subtitle("Quantile Partial Effect of Union Coverage")
      	xtitle("Quantile")
      	xline(0.5, lcolor(gs2) lpattern(dash))
		yline(0,   lcolor(gs2))
		yline(`beta_bar', lcolor(gs2))
      	legend(lab(1 "UQE") lab(2 "95% CI") lab(3 "")  lab(4 "w/o heterogeneity") cols(1))
		scheme(s1color);

graph save $WRITE/Fig_UQE.gph, replace;
graph export $WRITE/Fig_UQE.eps , replace;

/*****************************************************/
/* SUMMARIZE ESTIMATION RESULTS                      */
/*****************************************************/

matrix GAP_RESULTS = GAP9010_NU, GAP9010_U, GAP9010_DIF \ GAP_CB;
matrix APE_RESULTS = APE \ APE_CB;
matrix UQE_RESULTS = UQE, UQE_CB;

log on;
/* Summary of results (point estimate, 90 percent interval and bootstrap SE estimate */

/* Conditional inequality results */
matrix list GAP_RESULTS ;

/* APE results */
matrix list APE_RESULTS;

/* UQE results */
matrix list UQE_RESULTS ;


log off;
log close;
