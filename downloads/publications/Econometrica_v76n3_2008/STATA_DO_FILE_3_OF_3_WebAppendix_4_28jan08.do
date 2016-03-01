/***************************************************************************************************/
/* IDENTIFYING SOCIAL INTERACTIONS THROUGH CONDITIONAL VARIANCE RESTRICTIONS, SUPPLEMENTAL         */
/* MATERIAL: STATA DO FILE 3 OF 3 FOR REPLICATION OF EMPIRICAL RESULTS (SUPPLEMENTAL FILE 4 OF 8)  */
/***************************************************************************************************/

/***************************************************************************************************/
/* ABSTRACT: This is the third of three STATA do files which were used to calculate all the        */
/* empirical results in the paper and the supplemental web appendix with the exception of the power*/
/* calculations. To run the files one will need to modify the directory references to match the    */
/* the file structure on one's computer.										   */
/***************************************************************************************************/

/***************************************************************************************************/
/* DO FILE 3 OF 3  "IDENTIFYING SOCIAL INTERACTIONS THROUGH CONDITIONAL VARIANCE RESTRICTIONS"     */                           
/***************************************************************************************************/

/***************************************************************************************************/
/* PROJECT STAR exploratory analysis 	 				   		   		         */
/* "Social Interactions"		        								         */
/* Bryan S. Graham, UC - BERKELEY 		     								         */
/* bgraham@econ.berkeley.edu                 						         		   */
/* March 2006                               								         */
/***************************************************************************************************/

/* use a semicolon as the command delimiter */
#delimit ;

clear;

set matsize 2000;
set memory 100m;

use "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", clear;

/***************************************************************************/
/* "Excess Variance" Analysis (MATH) 		                           */
/***************************************************************************/

sort schidkn classK;

/* prepare math scores for covariance analysis */
sort classK;						/* sort data by classroom */
keep if mathnorm~=.;					/* drop observations with missing math scores */

/* number of schools, classrooms, distinct classroom sizes and students (by test score) */
g NS = 79;				/* # of schools */
g N = 317;				/* # of classrooms */
g NCS = 17;				/* # of unique classroom sizes */
g n_math = 5724;			/* # of students w/ valid math test scores */

g MSc_math = nummath_csk;	/* number of individuals in each class with valid math test scores */
g Mc = class_size;		/* "true" class size */

/* Divide schools into schools with lots of heterogeneity in years teaching experience and little heterogeneity */
bys schidkn: egen stdTQ = sd(experienceK);
g HHTeaExp = 1 if stdTQ>=5;					/* NOTE: 5 is the median standard deviation; "High Heterogeneity" (HH) schools */
replace HHTeaExp = 0 if HHTeaExp == .;
g HHTeaExpXsmallK = HHTeaExp*smallK;
g HHTeaExpXregaideK = HHTeaExp*regaideK;

/* Generate experienceksv by class type interactions */
g experienceksv = stdTQ^2;
g experienceksvXsmallK = experienceksv*smallK;
g experienceksvXregaideK = experienceksv*regaideK;

/* Generate ThreeClassSchool by class type interactions */
g LargeSchool = 1-ThreeClassSchool;
g LargeSchoolXsmallK = LargeSchool*smallK;
g LargeSchoolXregaideK = LargeSchool*regaideK;

/* Generate blackksv by class type iteractions */
bys schidkn: egen blackksm = mean(black);
g blackksv=blackksm*(1-blackksm);
g blackksvXsmallK = blackksv*smallK;
g blackksvXregaideK = blackksv*regaideK;

/* VERSIONS OF THE DEPENDENT VARIABLE */
/* CASE 1 : Use residuals from math scores on school dummies, smallK, and regaideK */
/* CASE 2 : Use residuals from math scores on school dummies, smallK, regaideK, HHTeaExpXsmallK and HHTeaExpXregaideK */
/* CASE 3 : Use residuals from math scores on school dummies, smallK, regaideK, experienceksvXregaideK and experienceksvXsmallK */
/* CASE 4 : Use residuals from math scores on school dummies, smallK, regaideK, LargeSchoolXsmallK and LargeSchoolXregaideK */
/* CASE 5 : Use residuals from math scores on school dummies, smallK, regaideK, blackksvXregaideK and blackksvXsmallK */


bys classK: egen math_cm = mean(mathnorm);  		/* (raw) class mean test scores */
g math_dcm = mathnorm - math_cm;			      /* individual scores deviated from classroom means */

reg mathnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies and smallK */
bys classK: egen r1math_cm = mean(r);
drop r;

reg mathnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK HHTeaExpXsmallK HHTeaExpXregaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, HHTeaExpXregaideK and HHTeaExpXsmallK */
bys classK: egen r2math_cm = mean(r);
drop r;

reg mathnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK experienceksvXregaideK experienceksvXsmallK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, experienceksvXregaideK and experienceksvXsmallK */
bys classK: egen r3math_cm = mean(r);
drop r;

reg mathnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK LargeSchoolXsmallK LargeSchoolXregaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, ThreeClassSchoolXsmallK and ThreeClassSchoolXregaideK */
bys classK: egen r4math_cm = mean(r);
drop r;

reg mathnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK blackksvXsmallK blackksvXregaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, blackksvXregaideK and blackksvXsmallK */
bys classK: egen r5math_cm = mean(r);
drop r;


/*********************************************************************************/
/* Prepare math score data for estimation                                        */
/*********************************************************************************/

/* generate column vector of ones */
g c_ones = 1;

/* Between-group "squares" */
g gb1_c = r1math_cm^2 - MSc_math*(1/MSc_math-1/Mc)*(1/(MSc_math-1))*math_dcm^2;
g gb2_c = r2math_cm^2 - MSc_math*(1/MSc_math-1/Mc)*(1/(MSc_math-1))*math_dcm^2;
g gb3_c = r3math_cm^2 - MSc_math*(1/MSc_math-1/Mc)*(1/(MSc_math-1))*math_dcm^2;
g gb4_c = r4math_cm^2 - MSc_math*(1/MSc_math-1/Mc)*(1/(MSc_math-1))*math_dcm^2;
g gb5_c = r5math_cm^2 - MSc_math*(1/MSc_math-1/Mc)*(1/(MSc_math-1))*math_dcm^2;

/* Within-group "squares" */
g gw_c = MSc_math*(1/Mc)*(1/(MSc_math-1))*math_dcm^2;

/* "True" within-group squares */
g W_c = (MSc_math/(MSc_math-1))*math_dcm^2;


/* NOTE: Extra MSc_math multiplicative factor is reversed by collapse command below */

/*********************************************************************************/
/* collapse data to classroom-level means                                        */
/*********************************************************************************/

collapse 	schidkn gb1_c gb2_c gb3_c gb4_c gb5_c gw_c W_c
		c_ones Mc MSc_math smallK regaideK	
		HHTeaExp HHTeaExpXsmallK HHTeaExpXregaideK
		experienceksv experienceksvXregaideK experienceksvXsmallK
	      LargeSchool LargeSchoolXsmallK LargeSchoolXregaideK 
		blackksv blackksvXregaideK blackksvXsmallK
		SIKschidkn_2-SIKschidkn_1, by(classK);

/************************************************************/
/* Outsheet data to a text file f/ use by MATLAB            */
/************************************************************/

outsheet 	classK gb1_c gb2_c gb3_c gb4_c gb5_c gw_c c_ones smallK regaideK
		HHTeaExpXsmallK HHTeaExpXregaideK
		experienceksvXregaideK experienceksvXsmallK
		LargeSchoolXsmallK LargeSchoolXregaideK
		blackksvXregaideK blackksvXsmallK
		schidkn SIKschidkn_2-SIKschidkn_1
		using "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\WALD_MATH.out", comma replace;

log using "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderstar_3.log", replace;
log on;

/**************************************************/
/* Wald-IV Estimates of Social Interactions (MATH)*/
/**************************************************/

/**************************************************/
/* These results appear in Table 1 of the paper   */
/**************************************************/

/* CASE 1 : Use residuals from math scores on school dummies, regaideK and smallK */

	/* First-stage */
	reg gw_c regaideK smallK SIKschidkn_2-SIKschidkn_1, nocons r; 
	test smallK;

	/* Structural model */
	ivreg2 gb1_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), r nocons ffirst small;
	
	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);		

/*********************************************************/
/* These results appear in Table 2 of the Web Appendix   */
/*********************************************************/

/* CASE 2 : Use residuals from math scores on school dummies, regaideK, smallK, HHTeaExpXsmallK and HHTeaExpXregaideK */

	/* First-stage */
	reg gw_c regaideK HHTeaExpXregaideK SIKschidkn_2-SIKschidkn_1 smallK HHTeaExpXsmallK, nocons r; 
	test smallK HHTeaExpXsmallK;

	/* Structural model */
	/* High heterogeneity sub-sample */
	ivreg2 gb2_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if HHTeaExp==1, nocons r ffirst small;
	
	/* Low heterogeneity sub-sample */
	ivreg2 gb2_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if HHTeaExp==0, nocons r ffirst small;

	/* Calculate standard error of difference in estimates of gamma2 across two subsamples */
	g HHTeaExpXgw_c = HHTeaExp*gw_c;
	ivreg2 gb2_c regaideK HHTeaExpXregaideK SIKschidkn_2-SIKschidkn_1 (gw_c HHTeaExp*gw_c = smallK HHTeaExpXsmallK), nocons r ffirst small;
	test HHTeaExpXgw_c = 0;

	/* Pooled sample */
	ivreg2 gb2_c regaideK HHTeaExpXregaideK HHTeaExpXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK ), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	

/* CASE 3 : Use residuals from math scores on school dummies, regaideK, smallK, experienceksvXregaideK experienceksvXsmallK */

	/* First-stage */
	reg gw_c regaideK experienceksvXregaideK experienceksvXsmallK SIKschidkn_2-SIKschidkn_1 smallK, nocons r; 
	test smallK;

	/* Structural model */
      ivreg2 gb3_c regaideK experienceksvXregaideK experienceksvXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	

/*********************************************************/
/* Robustness to heterogenous class size effects         */
/*********************************************************/

/* CASE 4 : Use residuals from math scores on school dummies, regaideK, smallK, LargeSchoolXsmallK and LargeSchoolXregaideK */

	/* First-stage */
	reg gw_c regaideK LargeSchoolXregaideK SIKschidkn_2-SIKschidkn_1 smallK LargeSchoolXsmallK, nocons r; 
	test smallK LargeSchoolXsmallK;

	/* Structural model */
	/* Schools w/ three classrooms */
	ivreg2 gb4_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if LargeSchool==0, nocons r ffirst small;

	/* Schools w/ more than three classrooms */
	ivreg2 gb4_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if LargeSchool==1, nocons r ffirst small;

	/* Calculate standard error of difference in estimates of gamma2 across two subsamples */
	g LargeSchoolXgw_c = LargeSchool*gw_c;
	ivreg gb4_c regaideK LargeSchoolXregaideK SIKschidkn_2-SIKschidkn_1 (gw_c LargeSchoolXgw_c = smallK LargeSchoolXsmallK), nocons r;
	test LargeSchoolXgw_c = 0;

	/* Pooled sampled*/
      ivreg2 gb4_c regaideK LargeSchoolXregaideK LargeSchoolXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	

/* CASE 5 : Use residuals from math scores on school dummies, smallK, regaideK, blackksvXregaideK and blackksvXsmallK  */

	/* First-stage */
	reg gw_c regaideK blackksvXregaideK blackksvXsmallK SIKschidkn_2-SIKschidkn_1 smallK, nocons r; 
	test smallK;

	/* Structural model */
      ivreg2 gb5_c regaideK blackksvXregaideK blackksvXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	


/* ESTIMATE SIGMA (STANDARD DEVIATION OF UNCONDITIONAL EPSILON DISTRIBUTION) */
/* NOTE: This is used for the calculations made in the text of the paper on
         the top of p. 21 */

	reg W_c,robust;
	nlcom sqrt(_b[_cons]);

log off;

/***************************************************************************/
/* "Excess Variance" Analysis (READING) 		                           */
/***************************************************************************/

use "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", clear;
sort schidkn classK;

/* prepare math scores for covariance analysis */
sort classK;						/* sort data by classroom */
keep if readnorm~=.;					/* drop observations with missing reading scores */

/* number of schools, classrooms, distinct classroom sizes and students (by test score) */
g NS = 79;				/* # of schools */
g N = 317;				/* # of classrooms */
g NCS = 17;				/* # of unique classroom sizes */
g n_read = 5646;			/* # of students w/ valid reading test scores */

g MSc_read = numread_csk;	/* number of individuals in each class with valid reading test scores */
g Mc = class_size;		/* "true" class size */

/* Divide schools into schools with lots of heterogeneity in years teaching experience and little heterogeneity */
bys schidkn: egen stdTQ = sd(experienceK);
g HHTeaExp = 1 if stdTQ>=5;					/* NOTE: 5 is the median standard deviation; "High Heterogeneity" (HH) schools */
replace HHTeaExp = 0 if HHTeaExp == .;
g HHTeaExpXsmallK = HHTeaExp*smallK;
g HHTeaExpXregaideK = HHTeaExp*regaideK;

/* Generate experienceksv by class type interactions */
g experienceksv = stdTQ^2;
g experienceksvXsmallK = experienceksv*smallK;
g experienceksvXregaideK = experienceksv*regaideK;

/* Generate ThreeClassSchool by class type interactions */
g LargeSchool = 1-ThreeClassSchool;
g LargeSchoolXsmallK = LargeSchool*smallK;
g LargeSchoolXregaideK = LargeSchool*regaideK;

/* Generate blackksv by class type iteractions */
bys schidkn: egen blackksm = mean(black);
g blackksv=blackksm*(1-blackksm);
g blackksvXsmallK = blackksv*smallK;
g blackksvXregaideK = blackksv*regaideK;

/* VERSIONS OF THE DEPENDENT VARIABLE */
/* CASE 1 : Use residuals from reading scores on school dummies, smallK, and regaideK */
/* CASE 2 : Use residuals from reading scores on school dummies, smallK, regaideK, HHTeaExpXsmallK and HHTeaExpXregaideK */
/* CASE 3 : Use residuals from reading scores on school dummies, smallK, regaideK, experienceksvXregaideK and experienceksvXsmallK */
/* CASE 4 : Use residuals from reading scores on school dummies, smallK, regaideK, LargeSchoolXsmallK and LargeSchoolXregaideK */
/* CASE 5 : Use residuals from reading scores on school dummies, smallK, regaideK, blackksvXregaideK and blackksvXsmallK */


bys classK: egen read_cm = mean(readnorm);  		/* (raw) class mean test scores */
g read_dcm = readnorm - read_cm;			      /* individual scores deviated from classroom means */

reg readnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies and smallK */
bys classK: egen r1read_cm = mean(r);
drop r;

reg readnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK HHTeaExpXsmallK HHTeaExpXregaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, HHTeaExpXregaideK and HHTeaExpXsmallK */
bys classK: egen r2read_cm = mean(r);
drop r;

reg readnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK experienceksvXregaideK experienceksvXsmallK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, experienceksvXregaideK and experienceksvXsmallK */
bys classK: egen r3read_cm = mean(r);
drop r;

reg readnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK LargeSchoolXsmallK LargeSchoolXregaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, ThreeClassSchoolXsmallK and ThreeClassSchoolXregaideK */
bys classK: egen r4read_cm = mean(r);
drop r;

reg readnorm SIKschidkn_2-SIKschidkn_1 smallK regaideK blackksvXsmallK blackksvXregaideK, nocons cluster(classK);
predict r, resid;							/* class mean of scores orthogonalized w.r.t. school dummies, smallK, blackksvXregaideK and blackksvXsmallK */
bys classK: egen r5read_cm = mean(r);
drop r;


/*********************************************************************************/
/* Prepare reading score data for estimation                                     */
/*********************************************************************************/

/* generate column vector of ones */
g c_ones = 1;

/* Between-group "squares" */
g gb1_c = r1read_cm^2 - MSc_read*(1/MSc_read-1/Mc)*(1/(MSc_read-1))*read_dcm^2;
g gb2_c = r2read_cm^2 - MSc_read*(1/MSc_read-1/Mc)*(1/(MSc_read-1))*read_dcm^2;
g gb3_c = r3read_cm^2 - MSc_read*(1/MSc_read-1/Mc)*(1/(MSc_read-1))*read_dcm^2;
g gb4_c = r4read_cm^2 - MSc_read*(1/MSc_read-1/Mc)*(1/(MSc_read-1))*read_dcm^2;
g gb5_c = r5read_cm^2 - MSc_read*(1/MSc_read-1/Mc)*(1/(MSc_read-1))*read_dcm^2;

/* Within-group "squares" */
g gw_c = MSc_read*(1/Mc)*(1/(MSc_read-1))*read_dcm^2;

/* "True" within-group squares */
g W_c = (MSc_read/(MSc_read-1))*read_dcm^2;


/* NOTE: Extra MSc_read multiplicative factor is reversed by collapse command below */

/*********************************************************************************/
/* collapse data to classroom-level means                                        */
/*********************************************************************************/

collapse 	schidkn gb1_c gb2_c gb3_c gb4_c gb5_c gw_c W_c
		c_ones Mc MSc_read smallK regaideK	
		HHTeaExp HHTeaExpXsmallK HHTeaExpXregaideK
		experienceksv experienceksvXregaideK experienceksvXsmallK
	      LargeSchool LargeSchoolXsmallK LargeSchoolXregaideK 
		blackksv blackksvXregaideK blackksvXsmallK
		SIKschidkn_2-SIKschidkn_1, by(classK);

/************************************************************/
/* Outsheet data to a text file f/ use by MATLAB            */
/************************************************************/

outsheet 	classK gb1_c gb2_c gb3_c gb4_c gb5_c gw_c c_ones smallK regaideK
		HHTeaExpXsmallK HHTeaExpXregaideK
		experienceksvXregaideK experienceksvXsmallK
		LargeSchoolXsmallK LargeSchoolXregaideK
		blackksvXregaideK blackksvXsmallK
		SIKschidkn_2-SIKschidkn_1
		using "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\WALD_READ.out", comma replace;

log on;

/**************************************************/
/* Wald-IV Estimates of Social Interactions (READ)*/
/**************************************************/

/**************************************************/
/* These results appear in Table 1 of the paper   */
/**************************************************/

/* CASE 1 : Use residuals from math scores on school dummies, regaideK and smallK */

	/* First-stage */
	reg gw_c regaideK SIKschidkn_2-SIKschidkn_1 smallK, nocons r; 
	test smallK;

	/* Structural model */
	ivreg2 gb1_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), r nocons ffirst small;
	
	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	
	
/*********************************************************/
/* These results appear in Table 2 of the Web Appendix   */
/*********************************************************/

/* CASE 2 : Use residuals from math scores on school dummies, regaideK, smallK, HHTeaExpXsmallK and HHTeaExpXregaideK */

	/* First-stage */
	reg gw_c regaideK HHTeaExpXregaideK SIKschidkn_2-SIKschidkn_1 smallK HHTeaExpXsmallK, nocons r; 
	test smallK HHTeaExpXsmallK;

	/* Structural model */
	/* High heterogeneity sub-sample */
	ivreg2 gb2_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if HHTeaExp==1, nocons r ffirst small;

	/* Low heterogeneity sub-sample */
	ivreg2 gb2_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if HHTeaExp==0, nocons r ffirst small;

	/* Calculate standard error of difference in estimates of gamma2 across two subsamples */
	g HHTeaExpXgw_c = HHTeaExp*gw_c;
	ivreg2 gb2_c regaideK HHTeaExpXregaideK SIKschidkn_2-SIKschidkn_1 (gw_c HHTeaExp*gw_c = smallK HHTeaExpXsmallK), nocons r ffirst small;
	test HHTeaExpXgw_c = 0;

	/* Pooled sample */
	ivreg2 gb2_c regaideK HHTeaExpXregaideK HHTeaExpXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK ), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	

/* CASE 3 : Use residuals from math scores on school dummies, regaideK, smallK, experienceksvXregaideK experienceksvXsmallK */

	/* First-stage */
	reg gw_c regaideK experienceksvXregaideK experienceksvXsmallK SIKschidkn_2-SIKschidkn_1 smallK, nocons r; 
	test smallK;

	/* Structural model */
      ivreg2 gb3_c regaideK experienceksvXregaideK experienceksvXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	

/*********************************************************/
/* Robustness to heterogenous class size effects         */
/*********************************************************/

/* CASE 4 : Use residuals from math scores on school dummies, regaideK, smallK, LargeSchoolXsmallK and LargeSchoolXregaideK */

	/* First-stage */
	reg gw_c regaideK LargeSchoolXregaideK SIKschidkn_2-SIKschidkn_1 smallK LargeSchoolXsmallK, nocons r; 
	test smallK LargeSchoolXsmallK;

	/* Structural model */
	/* Schools w/ three classrooms */
	ivreg2 gb4_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if LargeSchool==0, nocons r ffirst small;

	/* Schools w/ more than three classrooms */
	ivreg2 gb4_c regaideK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK) if LargeSchool==1, nocons r ffirst small;

	/* Calculate standard error of difference in estimates of gamma2 across two subsamples */
	g LargeSchoolXgw_c = LargeSchool*gw_c;
	ivreg gb4_c regaideK LargeSchoolXregaideK SIKschidkn_2-SIKschidkn_1 (gw_c LargeSchoolXgw_c = smallK LargeSchoolXsmallK), nocons r;
	test LargeSchoolXgw_c = 0;

	/* Pooled sampled*/
      ivreg2 gb4_c regaideK LargeSchoolXregaideK LargeSchoolXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	

/* CASE 5 : Use residuals from math scores on school dummies, smallK, regaideK, blackksvXregaideK and blackksvXsmallK  */

	/* First-stage */
	reg gw_c regaideK blackksvXregaideK blackksvXsmallK SIKschidkn_2-SIKschidkn_1 smallK, nocons r; 
	test smallK;

	/* Structural model */
      ivreg2 gb5_c regaideK blackksvXregaideK blackksvXsmallK SIKschidkn_2-SIKschidkn_1 (gw_c = smallK), nocons r ffirst small;	

	test gw_c = 1;
	testnl sqrt(_b[gw_c]) = 1;
	nlcom sqrt(_b[gw_c]);	


/* ESTIMATE SIGMA (STANDARD DEVIATION OF UNCONDITIONAL EPSILON DISTRIBUTION) */
/* NOTE: This is used for the calculations made in the text of the paper on
         the top of p. 21 */

	reg W_c,robust;
	nlcom sqrt(_b[_cons]);

log off;

log close;


