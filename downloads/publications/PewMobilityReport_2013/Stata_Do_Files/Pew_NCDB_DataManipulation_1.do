/***************************************************************************************************/
/* Intergenerational Mobility							   		         						   */
/* Bryan S. Graham, UC - BERKELEY									         			   		   */
/* Patrick Sharkey, NYU												         			   		   */
/* bgraham@econ.berkeley.edu       						         		   			   			   */
/* March 2012                              								         				   */
/***************************************************************************************************/

/* use a semicolon as the command delimiter */
#delimit ;

clear matrix;
clear mata;
clear;

set matsize 8000;
set memory 1000m;

/* Adjust the SOURCE_DATA_LOCATION directory to point to the location of the NCDB source files.  */
/* Adjust the WRITE_DATA and DO_FILES directorys to point to the location of where you would like to write any created files and */
/* where you have placed this do file respectively. */

global SOURCE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/NCDB";
global WRITE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Created_Data";
global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";

/************************************************************************************************/
/* This do file manipulates the raw extracts from the NCDB to produce NSI measures by MSA.      */
/* Other MSA-level variables are also constructed.                                              */
/* The NCDB extracts used are: (i) NCDB_70to00.csv, (ii)  NCDB_80.csv                           */
/* Also uses the MSA81To99Concordance.dta file                                                  */        
/************************************************************************************************/
/**************************************************************************************************/
/* NCDB 1970 to 2000 using 1999 MSA definitions 						                          */
/**************************************************************************************************/

/********/
/* 1970 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_70 = region;
g division_70 = divis;

/* create some basic-tract level aggregates */
g total_population_70 = shr7d;
g total_white_population_70 = shrwht7n;
g total_black_population_70 = shrblk7n;
g total_hispanic_population_70 = shrhsp7n;
g total_under18_population_70 = child7n;
g total_over65_population_70 = old7n;
g total_foreign_population_70 = forborn7;

g total_families_70 = favinc7d;
g total_family_income_70 = favinc7n;
g average_family_income_70 = favinc7;

g total_25p_population_70  	= educpp7;
g yrs_sch_25p_00to08_70 	= educ87;
g yrs_sch_25p_09to12_70 	= educ117;
g yrs_sch_25p_12_70 		= educ127;
g yrs_sch_25p_12to16_70 	= educ157;
g yrs_sch_25p_16_70 		= educ167;	

g dropout_16_19_70          = hsdrop7n;
g total_16_19_70			= hsdrop7d;	

save "$WRITE_DATA/tract_ncdb_1970ot", replace;

/* compute quantiles of income distribution for each tract */
g prc_1000 = falt17/total_families_70;
g prc_2000 = (falt17+falt27)/total_families_70;
g prc_3000 = (falt17+falt27+falt37)/total_families_70;
g prc_4000 = (falt17+falt27+falt37+falt47)/total_families_70;
g prc_5000 = (falt17+falt27+falt37+falt47+falt57)/total_families_70;
g prc_6000 = (falt17+falt27+falt37+falt47+falt57+falt67)/total_families_70;
g prc_7000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77)/total_families_70;
g prc_8000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87)/total_families_70;
g prc_9000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97)/total_families_70;
g prc_10000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107)/total_families_70;
g prc_12000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127)/total_families_70;
g prc_15000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157)/total_families_70;
g prc_25000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257)/total_families_70;
g prc_50000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257+falt507)/total_families_70;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_1000 = invnormal(prc_1000) if prc_1000>0 & prc_1000<1;
g actQ_1000 = log(1000);

g refQ_2000 = invnormal(prc_2000) if prc_2000>0 & prc_2000<1;
g actQ_2000 = log(2000);

g refQ_3000 = invnormal(prc_3000) if prc_3000>0 & prc_3000<1;
g actQ_3000 = log(3000);

g refQ_4000 = invnormal(prc_4000) if prc_4000>0 & prc_4000<1;
g actQ_4000 = log(4000);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_6000 = invnormal(prc_6000) if prc_6000>0 & prc_6000<1;
g actQ_6000 = log(6000);

g refQ_7000 = invnormal(prc_7000) if prc_7000>0 & prc_7000<1;
g actQ_7000 = log(7000);

g refQ_8000 = invnormal(prc_8000) if prc_8000>0 & prc_8000<1;
g actQ_8000 = log(8000);

g refQ_9000 = invnormal(prc_9000) if prc_9000>0 & prc_9000<1;
g actQ_9000 = log(9000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12000 = invnormal(prc_12000) if prc_12000>0 & prc_12000<1;
g actQ_12000 = log(12000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_1000 actQ_1000 msapma99 necma99 geo2000
		refQ_2000 actQ_2000 msapma99 necma99 geo2000
		refQ_3000 actQ_3000 msapma99 necma99 geo2000
		refQ_4000 actQ_4000 msapma99 necma99 geo2000
		refQ_5000 actQ_5000 msapma99 necma99 geo2000
		refQ_6000 actQ_6000 msapma99 necma99 geo2000
		refQ_7000 actQ_7000 msapma99 necma99 geo2000
		refQ_8000 actQ_8000 msapma99 necma99 geo2000
		refQ_9000 actQ_9000 msapma99 necma99 geo2000
		refQ_10000 actQ_10000 msapma99 necma99 geo2000
		refQ_12000 actQ_12000 msapma99 necma99 geo2000
		refQ_15000 actQ_15000 msapma99 necma99 geo2000
		refQ_25000 actQ_25000 msapma99 necma99 geo2000
		refQ_50000 actQ_50000 msapma99 necma99 geo2000, into(refQ actQ msapma99 necma99 geo2000);		

save "$WRITE_DATA/stacked_tract_ncdb_1970ot", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily areg actQ refQ if msapma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if msapma99 == `l';
			replace r_squared_for_MSAw = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if msapma99 == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(msapma99);

sort msapma99;			
save "$WRITE_DATA/within_tract_ncdb_1970ot", replace;		

/* re-load stacked tract data compute the within-neighborhood standard */
/* deviation of log income by NECMAs                                   */
use "$WRITE_DATA/stacked_tract_ncdb_1970ot", clear;		

/* for each NECMA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_NECMA 	= .;
g r_squared_for_NECMAw 	= .;
g within_tract_sigma 	= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily areg actQ refQ if necma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_NECMA = e(N_clust) if necma99 == `l';
			replace r_squared_for_NECMAw = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if necma99 == `l';	
		};	
};

/* collapse data down to NECMA level and save results */
collapse 	(mean) 
			num_tracts_in_NECMA r_squared_for_NECMAw within_tract_sigma, by(necma99);

sort necma99;
append using "$WRITE_DATA/within_tract_ncdb_1970ot";
sort msapma99 necma99;			
save "$WRITE_DATA/within_tract_ncdb_1970ot", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1970ot", clear;
		
collapse 	(sum)
			total_families_70 total_family_income_70 
			total_population_70 total_black_population_70 total_hispanic_population_70
			total_under18_population_70 total_over65_population_70 total_foreign_population_70
			total_25p_population_70
			yrs_sch_25p_00to08_70 yrs_sch_25p_09to12_70 yrs_sch_25p_12_70
			yrs_sch_25p_12to16_70 yrs_sch_25p_16_70
			falt17 falt27 falt37 falt47 falt57 falt67 falt77 falt87 falt97 falt107 
			falt127 falt157 falt257 falt507, by(msapma99);

/* some basic MSA-level aggregates */
g avg_fam_inc_70 	= total_family_income_70/total_families_70;					
g prc_black_70   	= (total_black_population_70/total_population_70)*100; 
g prc_hispanic_70 	= (total_hispanic_population_70/total_population_70)*100;	
g prc_under18_70 	= (total_under18_population_70/total_population_70)*100;	
g prc_over65_70 	= (total_over65_population_70/total_population_70)*100;	
g prc_foreign_70 	= (total_foreign_population_70/total_population_70)*100;	

/* compute quantiles of income distribution at the MSA level */
g prc_1000 = falt17/total_families_70;
g prc_2000 = (falt17+falt27)/total_families_70;
g prc_3000 = (falt17+falt27+falt37)/total_families_70;
g prc_4000 = (falt17+falt27+falt37+falt47)/total_families_70;
g prc_5000 = (falt17+falt27+falt37+falt47+falt57)/total_families_70;
g prc_6000 = (falt17+falt27+falt37+falt47+falt57+falt67)/total_families_70;
g prc_7000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77)/total_families_70;
g prc_8000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87)/total_families_70;
g prc_9000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97)/total_families_70;
g prc_10000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107)/total_families_70;
g prc_12000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127)/total_families_70;
g prc_15000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157)/total_families_70;
g prc_25000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257)/total_families_70;
g prc_50000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257+falt507)/total_families_70;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_1000 = invnormal(prc_1000) if prc_1000>0 & prc_1000<1;
g actQ_1000 = log(1000);

g refQ_2000 = invnormal(prc_2000) if prc_2000>0 & prc_2000<1;
g actQ_2000 = log(2000);

g refQ_3000 = invnormal(prc_3000) if prc_3000>0 & prc_3000<1;
g actQ_3000 = log(3000);

g refQ_4000 = invnormal(prc_4000) if prc_4000>0 & prc_4000<1;
g actQ_4000 = log(4000);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_6000 = invnormal(prc_6000) if prc_6000>0 & prc_6000<1;
g actQ_6000 = log(6000);

g refQ_7000 = invnormal(prc_7000) if prc_7000>0 & prc_7000<1;
g actQ_7000 = log(7000);

g refQ_8000 = invnormal(prc_8000) if prc_8000>0 & prc_8000<1;
g actQ_8000 = log(8000);

g refQ_9000 = invnormal(prc_9000) if prc_9000>0 & prc_9000<1;
g actQ_9000 = log(9000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12000 = invnormal(prc_12000) if prc_12000>0 & prc_12000<1;
g actQ_12000 = log(12000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

sort msapma99;
save "$WRITE_DATA/msa_level_ncdb_1970ot", replace;	

stack 	refQ_1000 actQ_1000 msapma99
		refQ_2000 actQ_2000 msapma99  
		refQ_3000 actQ_3000 msapma99 
		refQ_4000 actQ_4000 msapma99 
		refQ_5000 actQ_5000 msapma99 
		refQ_6000 actQ_6000 msapma99
		refQ_7000 actQ_7000 msapma99
		refQ_8000 actQ_8000 msapma99
		refQ_9000 actQ_9000 msapma99
		refQ_10000 actQ_10000 msapma99
		refQ_12000 actQ_12000 msapma99
		refQ_15000 actQ_15000 msapma99
		refQ_25000 actQ_25000 msapma99
		refQ_50000 actQ_50000 msapma99, into(refQ actQ msapma99);		

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu 			= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily reg actQ refQ if msapma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if msapma99 == `l';	
			replace overall_mu = b[1,2] if msapma99 == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(msapma99);		
sort msapma99;
save "$WRITE_DATA/msa_sigma_ncdb_1970ot", replace;

/* reload tract-level data and repeat calculations for NECMAs */
use "$WRITE_DATA/tract_ncdb_1970ot", clear;
		
collapse 	(sum) 
			total_families_70 total_family_income_70 
			total_population_70 total_black_population_70 total_hispanic_population_70
			total_under18_population_70 total_over65_population_70 total_foreign_population_70
			total_25p_population_70
			yrs_sch_25p_00to08_70 yrs_sch_25p_09to12_70 yrs_sch_25p_12_70
			yrs_sch_25p_12to16_70 yrs_sch_25p_16_70
			falt17 falt27 falt37 falt47 falt57 falt67 falt77 falt87 falt97 falt107 
			falt127 falt157 falt257 falt507, by(necma99);

/* some basic NECMA-level aggregates */	
g avg_fam_inc_70 	= total_family_income_70/total_families_70;				
g prc_black_70   	= (total_black_population_70/total_population_70)*100; 
g prc_hispanic_70 	= (total_hispanic_population_70/total_population_70)*100;
g prc_under18_70 	= (total_under18_population_70/total_population_70)*100;	
g prc_over65_70 	= (total_over65_population_70/total_population_70)*100;	
g prc_foreign_70 	= (total_foreign_population_70/total_population_70)*100;		

/* compute quantiles of income distribution at the NECMA level */
g prc_1000 = falt17/total_families_70;
g prc_2000 = (falt17+falt27)/total_families_70;
g prc_3000 = (falt17+falt27+falt37)/total_families_70;
g prc_4000 = (falt17+falt27+falt37+falt47)/total_families_70;
g prc_5000 = (falt17+falt27+falt37+falt47+falt57)/total_families_70;
g prc_6000 = (falt17+falt27+falt37+falt47+falt57+falt67)/total_families_70;
g prc_7000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77)/total_families_70;
g prc_8000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87)/total_families_70;
g prc_9000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97)/total_families_70;
g prc_10000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107)/total_families_70;
g prc_12000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127)/total_families_70;
g prc_15000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157)/total_families_70;
g prc_25000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257)/total_families_70;
g prc_50000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257+falt507)/total_families_70;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_1000 = invnormal(prc_1000) if prc_1000>0 & prc_1000<1;
g actQ_1000 = log(1000);

g refQ_2000 = invnormal(prc_2000) if prc_2000>0 & prc_2000<1;
g actQ_2000 = log(2000);

g refQ_3000 = invnormal(prc_3000) if prc_3000>0 & prc_3000<1;
g actQ_3000 = log(3000);

g refQ_4000 = invnormal(prc_4000) if prc_4000>0 & prc_4000<1;
g actQ_4000 = log(4000);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_6000 = invnormal(prc_6000) if prc_6000>0 & prc_6000<1;
g actQ_6000 = log(6000);

g refQ_7000 = invnormal(prc_7000) if prc_7000>0 & prc_7000<1;
g actQ_7000 = log(7000);

g refQ_8000 = invnormal(prc_8000) if prc_8000>0 & prc_8000<1;
g actQ_8000 = log(8000);

g refQ_9000 = invnormal(prc_9000) if prc_9000>0 & prc_9000<1;
g actQ_9000 = log(9000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12000 = invnormal(prc_12000) if prc_12000>0 & prc_12000<1;
g actQ_12000 = log(12000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

sort necma99;
save "$WRITE_DATA/necma_level_ncdb_1970ot", replace;	

stack 	refQ_1000 actQ_1000 necma99
		refQ_2000 actQ_2000 necma99  
		refQ_3000 actQ_3000 necma99 
		refQ_4000 actQ_4000 necma99 
		refQ_5000 actQ_5000 necma99 
		refQ_6000 actQ_6000 necma99
		refQ_7000 actQ_7000 necma99
		refQ_8000 actQ_8000 necma99
		refQ_9000 actQ_9000 necma99
		refQ_10000 actQ_10000 necma99
		refQ_12000 actQ_12000 necma99
		refQ_15000 actQ_15000 necma99
		refQ_25000 actQ_25000 necma99
		refQ_50000 actQ_50000 necma99, into(refQ actQ necma99);
		
/* for each NECMA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu 			= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily reg actQ refQ if necma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if necma99 == `l';	
			replace overall_mu = b[1,2] if necma99 == `l';	

		};	
};

/* save NECMA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(necma99);		
sort necma99;
save "$WRITE_DATA/necma_sigma_ncdb_1970ot", replace;

/* append MSA- and NECMA-level data into single file */	
use "$WRITE_DATA/msa_level_ncdb_1970ot", clear;
append using "$WRITE_DATA/necma_level_ncdb_1970ot";	
save "$WRITE_DATA/msa_necma_level_ncdb_1970ot", replace;		
		
/* merge all data and create file NCDB 1970 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1970ot", clear;
append using "$WRITE_DATA/necma_sigma_ncdb_1970ot";
sort msapma99 necma99;	
merge 1:1 msapma99 necma99 using "$WRITE_DATA/within_tract_ncdb_1970ot";
drop _merge;
sort msapma99 necma99;	
merge 1:1 msapma99 necma using "$WRITE_DATA/msa_necma_level_ncdb_1970ot";
drop _merge;
drop falt17-falt507 prc_1000-actQ_50000;
g NSI_70 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_70 = overall_sigma;
g sigma_w_70 = within_tract_sigma;
g mu_t_70 = overall_mu;
g r2_t_70 = r_squared_for_MSAt;
g r2_w_70 = r_squared_for_MSAw;
replace r2_w_70 = r_squared_for_NECMAw if r2_w_70==.;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw r_squared_for_NECMAw;
sort msapma99 necma99;		
save "$WRITE_DATA/msa_ncdb_1970ot", replace;

/* produce some summary statistics */
sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 r2_t_70 r2_w_70 if msapma99~=.;
sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 r2_t_70 r2_w_70 if necma99~=.;

erase "$WRITE_DATA/tract_ncdb_1970ot.dta";
erase "$WRITE_DATA/within_tract_ncdb_1970ot.dta";
erase "$WRITE_DATA/msa_level_ncdb_1970ot.dta";
erase "$WRITE_DATA/necma_level_ncdb_1970ot.dta";
erase "$WRITE_DATA/msa_necma_level_ncdb_1970ot.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1970ot.dta";
erase "$WRITE_DATA/necma_sigma_ncdb_1970ot.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1970ot.dta";

/********/
/* 1980 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_80 = region;
g division_80 = divis;

/* create some basic-tract level aggregates */
g total_population_80 = shr8d;
g total_white_population_80 = shrwht8n;
g total_black_population_80 = shrblk8n;
g total_hispanic_population_80 = shrhsp8n;
g total_under18_population_80 = child8n;
g total_over65_population_80 = old8n;
g total_foreign_population_80 = forborn8;

g total_families_80 = favinc8d;
g total_family_income_80 = favinc8n;
g average_family_income_80 = favinc8;

g total_25p_population_80  	= educpp8;
g yrs_sch_25p_00to08_80 	= educ88;
g yrs_sch_25p_09to12_80 	= educ118;
g yrs_sch_25p_12_80 		= educ128;
g yrs_sch_25p_12to16_80 	= educ158;
g yrs_sch_25p_16_80 		= educ168;	

g dropout_16_19_80          = hsdrop8n;
g total_16_19_80			= hsdrop8d;	

save "$WRITE_DATA/tract_ncdb_1980ot", replace;

/* compute quantiles of income distribution for each tract */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_2500 actQ_2500 msapma99 necma99 geo2000
		refQ_5000 actQ_5000 msapma99 necma99 geo2000
		refQ_7500 actQ_7500 msapma99 necma99 geo2000
		refQ_10000 actQ_10000 msapma99 necma99 geo2000 
		refQ_12500 actQ_12500 msapma99 necma99 geo2000 
		refQ_15000 actQ_15000 msapma99 necma99 geo2000 
		refQ_17500 actQ_17500 msapma99 necma99 geo2000 
		refQ_20000 actQ_20000 msapma99 necma99 geo2000 
		refQ_22500 actQ_22500 msapma99 necma99 geo2000 
		refQ_25000 actQ_25000 msapma99 necma99 geo2000 
		refQ_27500 actQ_27500 msapma99 necma99 geo2000 
		refQ_30000 actQ_30000 msapma99 necma99 geo2000 
		refQ_35000 actQ_35000 msapma99 necma99 geo2000 
		refQ_40000 actQ_40000 msapma99 necma99 geo2000 
		refQ_50000 actQ_50000 msapma99 necma99 geo2000 
		refQ_75000 actQ_75000 msapma99 necma99 geo2000, into(refQ actQ msapma99 necma99 geo2000);

save "$WRITE_DATA/stacked_tract_ncdb_1980ot", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily areg actQ refQ if msapma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if msapma99 == `l';
			replace r_squared_for_MSAw = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if msapma99 == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(msapma99);

sort msapma99;			
save "$WRITE_DATA/within_tract_ncdb_1980ot", replace;		

/* re-load stacked tract data compute the within-neighborhood standard */
/* deviation of log income by NECMAs                                   */
use "$WRITE_DATA/stacked_tract_ncdb_1980ot", clear;		

/* for each NECMA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_NECMA 	= .;
g r_squared_for_NECMAw 	= .;
g within_tract_sigma 	= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily areg actQ refQ if necma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_NECMA = e(N_clust) if necma99 == `l';
			replace r_squared_for_NECMAw = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if necma99 == `l';	
		};	
};

/* collapse data down to NECMA level and save results */
collapse 	(mean) 
			num_tracts_in_NECMA r_squared_for_NECMAw within_tract_sigma, by(necma99);

sort necma99;
append using "$WRITE_DATA/within_tract_ncdb_1980ot";
sort msapma99 necma99;			
save "$WRITE_DATA/within_tract_ncdb_1980ot", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1980ot", clear;
		
collapse 	(sum) 
			total_families_80 total_family_income_80 
			total_population_80 total_black_population_80 total_hispanic_population_80
			total_under18_population_80 total_over65_population_80 total_foreign_population_80
			total_25p_population_80
			yrs_sch_25p_00to08_80 yrs_sch_25p_09to12_80 yrs_sch_25p_12_80
			yrs_sch_25p_12to16_80 yrs_sch_25p_16_80
			falt38 falt58 falt88 falt108 falt138 falt158 falt188 falt208 
			falt238 falt258 falt288 falt308 falt358 falt408 falt498 falt758, by(msapma99);

/* some basic MSA-level aggregates */
g avg_fam_inc_80 	= total_family_income_80/total_families_80;					
g prc_black_80   	= (total_black_population_80/total_population_80)*100; 
g prc_hispanic_80 	= (total_hispanic_population_80/total_population_80)*100;
g prc_under18_80 	= (total_under18_population_80/total_population_80)*100;	
g prc_over65_80 	= (total_over65_population_80/total_population_80)*100;	
g prc_foreign_80 	= (total_foreign_population_80/total_population_80)*100;	
	
/* compute quantiles of income distribution at the MSA level */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

sort msapma99;
save "$WRITE_DATA/msa_level_ncdb_1980ot", replace;	

stack 	refQ_2500 actQ_2500 msapma99
		refQ_5000 actQ_5000 msapma99
		refQ_7500 actQ_7500 msapma99
		refQ_10000 actQ_10000 msapma99 
		refQ_12500 actQ_12500 msapma99 
		refQ_15000 actQ_15000 msapma99 
		refQ_17500 actQ_17500 msapma99 
		refQ_20000 actQ_20000 msapma99 
		refQ_22500 actQ_22500 msapma99 
		refQ_25000 actQ_25000 msapma99 
		refQ_27500 actQ_27500 msapma99 
		refQ_30000 actQ_30000 msapma99 
		refQ_35000 actQ_35000 msapma99
		refQ_40000 actQ_40000 msapma99 
		refQ_50000 actQ_50000 msapma99
		refQ_75000 actQ_75000 msapma99, into(refQ actQ msapma99);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu 		= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily reg actQ refQ if msapma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if msapma99 == `l';	
			replace overall_mu = b[1,2] if msapma99 == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(msapma99);		
sort msapma99;
save "$WRITE_DATA/msa_sigma_ncdb_1980ot", replace;

/* reload tract-level data and repeat calculations for NECMAs */
use "$WRITE_DATA/tract_ncdb_1980ot", clear;
		
collapse 	(sum) 
			total_families_80 total_family_income_80 
			total_population_80 total_black_population_80 total_hispanic_population_80
			total_under18_population_80 total_over65_population_80 total_foreign_population_80
			total_25p_population_80
			yrs_sch_25p_00to08_80 yrs_sch_25p_09to12_80 yrs_sch_25p_12_80
			yrs_sch_25p_12to16_80 yrs_sch_25p_16_80
			falt38 falt58 falt88 falt108 falt138 falt158 falt188 falt208 
			falt238 falt258 falt288 falt308 falt358 falt408 falt498 falt758, by(necma99);

/* some basic NECMA-level aggregates */
g avg_fam_inc_80 	= total_family_income_80/total_families_80;					
g prc_black_80   	= (total_black_population_80/total_population_80)*100; 
g prc_hispanic_80 	= (total_hispanic_population_80/total_population_80)*100;
g prc_under18_80 	= (total_under18_population_80/total_population_80)*100;	
g prc_over65_80 	= (total_over65_population_80/total_population_80)*100;	
g prc_foreign_80 	= (total_foreign_population_80/total_population_80)*100;	

/* compute quantiles of income distribution at the NECMA level */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

sort necma99;
save "$WRITE_DATA/necma_level_ncdb_1980ot", replace;	

stack 	refQ_2500 actQ_2500 necma99
		refQ_5000 actQ_5000 necma99
		refQ_7500 actQ_7500 necma99
		refQ_10000 actQ_10000 necma99 
		refQ_12500 actQ_12500 necma99 
		refQ_15000 actQ_15000 necma99 
		refQ_17500 actQ_17500 necma99 
		refQ_20000 actQ_20000 necma99 
		refQ_22500 actQ_22500 necma99 
		refQ_25000 actQ_25000 necma99 
		refQ_27500 actQ_27500 necma99 
		refQ_30000 actQ_30000 necma99 
		refQ_35000 actQ_35000 necma99
		refQ_40000 actQ_40000 necma99 
		refQ_50000 actQ_50000 necma99
		refQ_75000 actQ_75000 necma99, into(refQ actQ necma99);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu	 		= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily reg actQ refQ if necma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if necma99 == `l';	
			replace overall_mu = b[1,2] if necma99 == `l';	
		};	
};

/* save NECMA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(necma99);		
sort necma99;
save "$WRITE_DATA/necma_sigma_ncdb_1980ot", replace;

/* appenda MSA- and NECMA-level data into single file */	
use "$WRITE_DATA/msa_level_ncdb_1980ot", clear;
append using "$WRITE_DATA/necma_level_ncdb_1980ot";	
save "$WRITE_DATA/msa_necma_level_ncdb_1980ot", replace;		
		
/* merge all data and create file NCDB 1980 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1980ot", clear;
append using "$WRITE_DATA/necma_sigma_ncdb_1980ot";
sort msapma99 necma99;	
merge 1:1 msapma99 necma99 using "$WRITE_DATA/within_tract_ncdb_1980ot";
drop _merge;
sort msapma99 necma99;	
merge 1:1 msapma99 necma using "$WRITE_DATA/msa_necma_level_ncdb_1980ot";
drop _merge;
drop falt38-falt758 prc_2500-actQ_75000;
g NSI_80 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_80 = overall_sigma;
g mu_t_80 = overall_mu;
g sigma_w_80 = within_tract_sigma;
g r2_t_80 = r_squared_for_MSAt;
g r2_w_80 = r_squared_for_MSAw;
replace r2_w_80 = r_squared_for_NECMAw if r2_w_80==.;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw r_squared_for_NECMAw;
sort msapma99 necma99;		
save "$WRITE_DATA/msa_ncdb_1980ot", replace;

/* produce some summary statistics */
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 r2_t_80 r2_w_80 if msapma99~=.;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 r2_t_80 r2_w_80 if necma99~=.;

erase "$WRITE_DATA/tract_ncdb_1980ot.dta";
erase "$WRITE_DATA/within_tract_ncdb_1980ot.dta";
erase "$WRITE_DATA/msa_level_ncdb_1980ot.dta";
erase "$WRITE_DATA/necma_level_ncdb_1980ot.dta";
erase "$WRITE_DATA/msa_necma_level_ncdb_1980ot.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1980ot.dta";
erase "$WRITE_DATA/necma_sigma_ncdb_1980ot.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1980ot.dta";

/********/
/* 1990 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_90 = region;
g division_90 = divis;

/* create some basic-tract level aggregates */
g total_population_90 = shr9d;
g total_white_population_90 = shrwht9n;
g total_black_population_90 = shrblk9n;
g total_hispanic_population_90 = shrhsp9n;
g total_under18_population_90 = child9n;
g total_over65_population_90 = old9n;
g total_foreign_population_90 = forborn9;

g total_families_90 = favinc9d;
g total_family_income_90 = favinc9n;
g average_family_income_90 = favinc9;
g median_family_income_90 = mdfamy9;

g total_25p_population_90  	= educpp9;
g yrs_sch_25p_00to08_90 	= educ89;
g yrs_sch_25p_09to12_90 	= educ119;
g yrs_sch_25p_12_90 		= educ129;
g yrs_sch_25p_12to14_90 	= educ159;
g yrs_sch_25p_14_90 		= educa9;
g yrs_sch_25p_16_90 		= educ169;	

g dropout_16_19_90          = hsdrop9n;
g total_16_19_90			= hsdrop9d;	

save "$WRITE_DATA/tract_ncdb_1990ot", replace;

/* compute quantiles of income distribution for each tract */
g prc_5000  = falty59/total_families_90;
g prc_10000 = (falty59+falty109)/total_families_90;
g prc_12500 = (falty59+falty109+falt139)/total_families_90;
g prc_15000 = (falty59+falty109+falt139+falt159)/total_families_90;
g prc_17500 = (falty59+falty109+falt139+falt159+falt189)/total_families_90;
g prc_20000 = (falty59+falty109+falt139+falt159+falt189+falt209)/total_families_90;
g prc_22500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239)/total_families_90;
g prc_25000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259)/total_families_90;
g prc_27500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289)/total_families_90;
g prc_30000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309)/total_families_90;
g prc_35000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359)/total_families_90;
g prc_40000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409)/total_families_90;
g prc_50000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499)/total_families_90;
g prc_60000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a)/total_families_90;
g prc_75000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a)/total_families_90;
g prc_100000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009)/total_families_90;
g prc_125000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259)/total_families_90;
g prc_150000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259+falt1509)/total_families_90;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_5000 actQ_5000 msapma99 necma99 geo2000
		refQ_10000 actQ_10000 msapma99 necma99 geo2000 
		refQ_12500 actQ_12500 msapma99 necma99 geo2000 
		refQ_15000 actQ_15000 msapma99 necma99 geo2000 
		refQ_17500 actQ_17500 msapma99 necma99 geo2000 
		refQ_20000 actQ_20000 msapma99 necma99 geo2000 
		refQ_22500 actQ_22500 msapma99 necma99 geo2000 
		refQ_25000 actQ_25000 msapma99 necma99 geo2000 
		refQ_27500 actQ_27500 msapma99 necma99 geo2000 
		refQ_30000 actQ_30000 msapma99 necma99 geo2000 
		refQ_35000 actQ_35000 msapma99 necma99 geo2000 
		refQ_40000 actQ_40000 msapma99 necma99 geo2000 
		refQ_50000 actQ_50000 msapma99 necma99 geo2000 
		refQ_60000 actQ_60000 msapma99 necma99 geo2000 
		refQ_75000 actQ_75000 msapma99 necma99 geo2000 
		refQ_100000 actQ_100000 msapma99 necma99 geo2000 
		refQ_125000 actQ_125000 msapma99 necma99 geo2000 
		refQ_150000 actQ_150000 msapma99 necma99 geo2000, into(refQ actQ msapma99 necma99 geo2000);

save "$WRITE_DATA/stacked_tract_ncdb_1990ot", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily areg actQ refQ if msapma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if msapma99 == `l';
			replace r_squared_for_MSAw = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if msapma99 == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(msapma99);

sort msapma99;			
save "$WRITE_DATA/within_tract_ncdb_1990ot", replace;		

/* re-load stacked tract data compute the within-neighborhood standard */
/* deviation of log income by NECMAs                                   */
use "$WRITE_DATA/stacked_tract_ncdb_1990ot", clear;		

/* for each NECMA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_NECMA 	= .;
g r_squared_for_NECMAw 	= .;
g within_tract_sigma 	= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily areg actQ refQ if necma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_NECMA = e(N_clust) if necma99 == `l';
			replace r_squared_for_NECMAw = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if necma99 == `l';	
		};	
};

/* collapse data down to NECMA level and save results */
collapse 	(mean) 
			num_tracts_in_NECMA r_squared_for_NECMAw within_tract_sigma, by(necma99);

sort necma99;
append using "$WRITE_DATA/within_tract_ncdb_1990ot";
sort msapma99 necma99;			
save "$WRITE_DATA/within_tract_ncdb_1990ot", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1990ot", clear;
		
collapse 	(sum) 
			total_families_90 total_family_income_90 
			total_population_90 total_black_population_90 total_hispanic_population_90
			total_under18_population_90 total_over65_population_90 total_foreign_population_90
			total_25p_population_90
			yrs_sch_25p_00to08_90 yrs_sch_25p_09to12_90 yrs_sch_25p_12_90
			yrs_sch_25p_12to14_90 yrs_sch_25p_14_90 yrs_sch_25p_16_90
			falty59 falty109 falt139 falt159 falt189 falt209 
			falt239 falt259 falt289 falt309 falt359 falt409 
			falt499 falt609a falt759a falt1009 falt1259 falt1509, by(msapma99);

/* some basic MSA-level aggregates */
g avg_fam_inc_90 	= total_family_income_90/total_families_90;					
g prc_black_90   	= (total_black_population_90/total_population_90)*100; 
g prc_hispanic_90 	= (total_hispanic_population_90/total_population_90)*100;
g prc_under18_90 	= (total_under18_population_90/total_population_90)*100;	
g prc_over65_90 	= (total_over65_population_90/total_population_90)*100;	
g prc_foreign_90 	= (total_foreign_population_90/total_population_90)*100;	
	
/* compute quantiles of income distribution at the MSA level */
g prc_5000  = falty59/total_families_90;
g prc_10000 = (falty59+falty109)/total_families_90;
g prc_12500 = (falty59+falty109+falt139)/total_families_90;
g prc_15000 = (falty59+falty109+falt139+falt159)/total_families_90;
g prc_17500 = (falty59+falty109+falt139+falt159+falt189)/total_families_90;
g prc_20000 = (falty59+falty109+falt139+falt159+falt189+falt209)/total_families_90;
g prc_22500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239)/total_families_90;
g prc_25000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259)/total_families_90;
g prc_27500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289)/total_families_90;
g prc_30000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309)/total_families_90;
g prc_35000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359)/total_families_90;
g prc_40000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409)/total_families_90;
g prc_50000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499)/total_families_90;
g prc_60000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a)/total_families_90;
g prc_75000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a)/total_families_90;
g prc_100000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009)/total_families_90;
g prc_125000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259)/total_families_90;
g prc_150000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259+falt1509)/total_families_90;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

sort msapma99;
save "$WRITE_DATA/msa_level_ncdb_1990ot", replace;	

stack 	refQ_5000 actQ_5000 msapma99
		refQ_10000 actQ_10000 msapma99 
		refQ_12500 actQ_12500 msapma99 
		refQ_15000 actQ_15000 msapma99 
		refQ_17500 actQ_17500 msapma99 
		refQ_20000 actQ_20000 msapma99 
		refQ_22500 actQ_22500 msapma99 
		refQ_25000 actQ_25000 msapma99 
		refQ_27500 actQ_27500 msapma99 
		refQ_30000 actQ_30000 msapma99 
		refQ_35000 actQ_35000 msapma99
		refQ_40000 actQ_40000 msapma99 
		refQ_50000 actQ_50000 msapma99
		refQ_60000 actQ_60000 msapma99 
		refQ_75000 actQ_75000 msapma99 
		refQ_100000 actQ_100000 msapma99 
		refQ_125000 actQ_125000 msapma99 
		refQ_150000 actQ_150000 msapma99, into(refQ actQ msapma99);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu	 		= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily reg actQ refQ if msapma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if msapma99 == `l';	
			replace overall_mu = b[1,2] if msapma99 == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(msapma99);		
sort msapma99;
save "$WRITE_DATA/msa_sigma_ncdb_1990ot", replace;

/* reload tract-level data and repeat calculations for NECMAs */
use "$WRITE_DATA/tract_ncdb_1990ot", clear;
		
collapse 	(sum) 
			total_families_90 total_family_income_90 
			total_population_90 total_black_population_90 total_hispanic_population_90
			total_under18_population_90 total_over65_population_90 total_foreign_population_90
			total_25p_population_90
			yrs_sch_25p_00to08_90 yrs_sch_25p_09to12_90 yrs_sch_25p_12_90
			yrs_sch_25p_12to14_90 yrs_sch_25p_14_90 yrs_sch_25p_16_90
			falty59 falty109 falt139 falt159 falt189 falt209 
			falt239 falt259 falt289 falt309 falt359 falt409 
			falt499 falt609a falt759a falt1009 falt1259 falt1509, by(necma99);

/* some basic NECMA-level aggregates */
g avg_fam_inc_90 	= total_family_income_90/total_families_90;					
g prc_black_90   	= (total_black_population_90/total_population_90)*100; 
g prc_hispanic_90 	= (total_hispanic_population_90/total_population_90)*100;
g prc_under18_90 	= (total_under18_population_90/total_population_90)*100;	
g prc_over65_90 	= (total_over65_population_90/total_population_90)*100;	
g prc_foreign_90 	= (total_foreign_population_90/total_population_90)*100;		

/* compute quantiles of income distribution at the NECMA level */
g prc_5000  = falty59/total_families_90;
g prc_10000 = (falty59+falty109)/total_families_90;
g prc_12500 = (falty59+falty109+falt139)/total_families_90;
g prc_15000 = (falty59+falty109+falt139+falt159)/total_families_90;
g prc_17500 = (falty59+falty109+falt139+falt159+falt189)/total_families_90;
g prc_20000 = (falty59+falty109+falt139+falt159+falt189+falt209)/total_families_90;
g prc_22500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239)/total_families_90;
g prc_25000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259)/total_families_90;
g prc_27500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289)/total_families_90;
g prc_30000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309)/total_families_90;
g prc_35000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359)/total_families_90;
g prc_40000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409)/total_families_90;
g prc_50000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499)/total_families_90;
g prc_60000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a)/total_families_90;
g prc_75000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a)/total_families_90;
g prc_100000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009)/total_families_90;
g prc_125000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259)/total_families_90;
g prc_150000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259+falt1509)/total_families_90;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

sort necma99;
save "$WRITE_DATA/necma_level_ncdb_1990ot", replace;	

stack 	refQ_5000 actQ_5000 necma99
		refQ_10000 actQ_10000 necma99 
		refQ_12500 actQ_12500 necma99 
		refQ_15000 actQ_15000 necma99 
		refQ_17500 actQ_17500 necma99 
		refQ_20000 actQ_20000 necma99 
		refQ_22500 actQ_22500 necma99 
		refQ_25000 actQ_25000 necma99 
		refQ_27500 actQ_27500 necma99 
		refQ_30000 actQ_30000 necma99 
		refQ_35000 actQ_35000 necma99
		refQ_40000 actQ_40000 necma99 
		refQ_50000 actQ_50000 necma99
		refQ_60000 actQ_60000 necma99 
		refQ_75000 actQ_75000 necma99 
		refQ_100000 actQ_100000 necma99 
		refQ_125000 actQ_125000 necma99 
		refQ_150000 actQ_150000 necma99, into(refQ actQ necma99);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu	 		= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily reg actQ refQ if necma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if necma99 == `l';
			replace overall_mu = b[1,2] if necma99 == `l';	
		};	
};

/* save NECMA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(necma99);		
sort necma99;
save "$WRITE_DATA/necma_sigma_ncdb_1990ot", replace;

/* appenda MSA- and NECMA-level data into single file */	
use "$WRITE_DATA/msa_level_ncdb_1990ot", clear;
append using "$WRITE_DATA/necma_level_ncdb_1990ot";	
save "$WRITE_DATA/msa_necma_level_ncdb_1990ot", replace;		
		
/* merge all data and create file NCDB 1990 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1990ot", clear;
append using "$WRITE_DATA/necma_sigma_ncdb_1990ot";
sort msapma99 necma99;	
merge 1:1 msapma99 necma99 using "$WRITE_DATA/within_tract_ncdb_1990ot";
drop _merge;
sort msapma99 necma99;	
merge 1:1 msapma99 necma using "$WRITE_DATA/msa_necma_level_ncdb_1990ot";
drop _merge;
drop falty59-falt1509 prc_5000-actQ_150000;
g NSI_90 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_90 = overall_sigma;
g mu_t_90 = overall_mu;
g sigma_w_90 = within_tract_sigma;
g r2_t_90 = r_squared_for_MSAt;
g r2_w_90 = r_squared_for_MSAw;
replace r2_w_90 = r_squared_for_NECMAw if r2_w_90==.;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw r_squared_for_NECMAw;
sort msapma99 necma99;		
save "$WRITE_DATA/msa_ncdb_1990ot", replace;

/* produce some summary statistics */
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 r2_t_90 r2_w_90 if msapma99~=.;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 r2_t_90 r2_w_90 if necma99~=.;

erase "$WRITE_DATA/tract_ncdb_1990ot.dta";
erase "$WRITE_DATA/within_tract_ncdb_1990ot.dta";
erase "$WRITE_DATA/msa_level_ncdb_1990ot.dta";
erase "$WRITE_DATA/necma_level_ncdb_1990ot.dta";
erase "$WRITE_DATA/msa_necma_level_ncdb_1990ot.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1990ot.dta";
erase "$WRITE_DATA/necma_sigma_ncdb_1990ot.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1990ot.dta";

/********/
/* 2000 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_00 = region;
g division_00 = divis;

/* create some basic-tract level aggregates */
g total_population_00 = trctpop0;
g total_white_population_00 = shrwht0n;
g total_black_population_00 = shrblk0n;
g total_hispanic_population_00 = shrhsp0n;
g total_under18_population_00 = child0n;
g total_over65_population_00 = old0n;
g total_foreign_population_00 = forborn0;

g total_families_00 = favinc0d;
g total_family_income_00 = favinc0n;
g average_family_income_00 = favinc0;
g median_family_income_00 = mdfamy0;

g total_25p_population_00  	= educpp0;
g yrs_sch_25p_00to08_00 	= educ80;
g yrs_sch_25p_09to12_00 	= educ110;
g yrs_sch_25p_12_00 		= educ120;
g yrs_sch_25p_12to14_00 	= educ150;
g yrs_sch_25p_14_00 		= educa0;
g yrs_sch_25p_16_00 		= educ160;	

g dropout_16_19_00          = hsdrop0n;
g total_16_19_00			= hsdrop0d;	

save "$WRITE_DATA/tract_ncdb_2000ot", replace;

/* compute quantiles of income distribution for each tract */
g prc_10000  = fay0100/total_families_00;
g prc_15000  = (fay0100+fay0150)/total_families_00;
g prc_20000  = (fay0100+fay0150+fay0200)/total_families_00;
g prc_25000  = (fay0100+fay0150+fay0200+fay0250)/total_families_00;
g prc_30000  = (fay0100+fay0150+fay0200+fay0250+fay0300)/total_families_00;
g prc_35000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350)/total_families_00;
g prc_40000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400)/total_families_00;
g prc_45000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450)/total_families_00;
g prc_50000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500)/total_families_00;
g prc_60000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600)/total_families_00;
g prc_75000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750)/total_families_00;
g prc_100000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000)/total_families_00;
g prc_125000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250)/total_families_00;
g prc_150000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500)/total_families_00;
g prc_200000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500+fay02000)/total_families_00;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_45000 = invnormal(prc_45000) if prc_45000>0 & prc_45000<1;
g actQ_45000 = log(45000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

g refQ_200000 = invnormal(prc_200000) if prc_200000>0 & prc_200000<1;
g actQ_200000 = log(200000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_10000 actQ_10000 msapma99 necma99 geo2000
		refQ_15000 actQ_15000 msapma99 necma99 geo2000 
		refQ_20000 actQ_20000 msapma99 necma99 geo2000 
		refQ_25000 actQ_25000 msapma99 necma99 geo2000 
		refQ_30000 actQ_30000 msapma99 necma99 geo2000 
		refQ_35000 actQ_35000 msapma99 necma99 geo2000 
		refQ_40000 actQ_40000 msapma99 necma99 geo2000
		refQ_45000 actQ_45000 msapma99 necma99 geo2000  
		refQ_50000 actQ_50000 msapma99 necma99 geo2000 
		refQ_60000 actQ_60000 msapma99 necma99 geo2000 
		refQ_75000 actQ_75000 msapma99 necma99 geo2000 
		refQ_100000 actQ_100000 msapma99 necma99 geo2000 
		refQ_125000 actQ_125000 msapma99 necma99 geo2000 
		refQ_150000 actQ_150000 msapma99 necma99 geo2000
		refQ_200000 actQ_200000 msapma99 necma99 geo2000, into(refQ actQ msapma99 necma99 geo2000);

save "$WRITE_DATA/stacked_tract_ncdb_2000ot", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily areg actQ refQ if msapma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if msapma99 == `l';
			replace r_squared_for_MSAw = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if msapma99 == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(msapma99);

sort msapma99;			
save "$WRITE_DATA/within_tract_ncdb_2000ot", replace;		

/* re-load stacked tract data compute the within-neighborhood standard */
/* deviation of log income by NECMAs                                   */
use "$WRITE_DATA/stacked_tract_ncdb_2000ot", clear;		

/* for each NECMA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_NECMA 	= .;
g r_squared_for_NECMAw 	= .;
g within_tract_sigma 	= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily areg actQ refQ if necma99 == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_NECMA = e(N_clust) if necma99 == `l';
			replace r_squared_for_NECMAw = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if necma99 == `l';	
		};	
};

/* collapse data down to NECMA level and save results */
collapse 	(mean) 
			num_tracts_in_NECMA r_squared_for_NECMAw within_tract_sigma, by(necma99);

sort necma99;
append using "$WRITE_DATA/within_tract_ncdb_2000ot";
sort msapma99 necma99;			
save "$WRITE_DATA/within_tract_ncdb_2000ot", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_2000ot", clear;
		
collapse 	(sum) 
			total_families_00 total_family_income_00 
			total_population_00 total_black_population_00 total_hispanic_population_00
			total_under18_population_00 total_over65_population_00 total_foreign_population_00
			total_25p_population_00
			yrs_sch_25p_00to08_00 yrs_sch_25p_09to12_00 yrs_sch_25p_12_00
			yrs_sch_25p_12to14_00 yrs_sch_25p_14_00 yrs_sch_25p_16_00
			fay0100 fay0150 fay0200 fay0250 fay0300 fay0350 fay0400 fay0450
			fay0500 fay0600 fay0750 fay01000 fay01250 fay01500 fay02000, by(msapma99);

/* some basic MSA-level aggregates */
g avg_fam_inc_00 	= total_family_income_00/total_families_00;					
g prc_black_00   	= (total_black_population_00/total_population_00)*100; 
g prc_hispanic_00 	= (total_hispanic_population_00/total_population_00)*100;
g prc_under18_00 	= (total_under18_population_00/total_population_00)*100;	
g prc_over65_00 	= (total_over65_population_00/total_population_00)*100;	
g prc_foreign_00 	= (total_foreign_population_00/total_population_00)*100;		

/* compute quantiles of income distribution at the MSA level */
g prc_10000  = fay0100/total_families_00;
g prc_15000  = (fay0100+fay0150)/total_families_00;
g prc_20000  = (fay0100+fay0150+fay0200)/total_families_00;
g prc_25000  = (fay0100+fay0150+fay0200+fay0250)/total_families_00;
g prc_30000  = (fay0100+fay0150+fay0200+fay0250+fay0300)/total_families_00;
g prc_35000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350)/total_families_00;
g prc_40000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400)/total_families_00;
g prc_45000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450)/total_families_00;
g prc_50000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500)/total_families_00;
g prc_60000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600)/total_families_00;
g prc_75000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750)/total_families_00;
g prc_100000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000)/total_families_00;
g prc_125000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250)/total_families_00;
g prc_150000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500)/total_families_00;
g prc_200000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500+fay02000)/total_families_00;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_45000 = invnormal(prc_45000) if prc_45000>0 & prc_45000<1;
g actQ_45000 = log(45000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

g refQ_200000 = invnormal(prc_200000) if prc_200000>0 & prc_200000<1;
g actQ_200000 = log(200000);

sort msapma99;
save "$WRITE_DATA/msa_level_ncdb_2000ot", replace;	

stack 	refQ_10000 actQ_10000 msapma99 
		refQ_15000 actQ_15000 msapma99 
		refQ_20000 actQ_20000 msapma99 
		refQ_25000 actQ_25000 msapma99 
		refQ_30000 actQ_30000 msapma99 
		refQ_35000 actQ_35000 msapma99
		refQ_40000 actQ_40000 msapma99
		refQ_45000 actQ_45000 msapma99 
		refQ_50000 actQ_50000 msapma99
		refQ_60000 actQ_60000 msapma99 
		refQ_75000 actQ_75000 msapma99 
		refQ_100000 actQ_100000 msapma99 
		refQ_125000 actQ_125000 msapma99 
		refQ_150000 actQ_150000 msapma99
		refQ_200000 actQ_200000 msapma99, into(refQ actQ msapma99);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu 		= .;

levelsof msapma99, local(msapma99_list);
foreach l of local msapma99_list {;
		di "-> msapma99 = `l'";
		capture noisily reg actQ refQ if msapma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if msapma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if msapma99 == `l';	
			replace overall_mu = b[1,2] if msapma99 == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(msapma99);		
sort msapma99;
save "$WRITE_DATA/msa_sigma_ncdb_2000ot", replace;

/* reload tract-level data and repeat calculations for NECMAs */
use "$WRITE_DATA/tract_ncdb_2000ot", clear;
		
collapse 	(sum) 
			total_families_00 total_family_income_00 
			total_population_00 total_black_population_00 total_hispanic_population_00
			total_under18_population_00 total_over65_population_00 total_foreign_population_00
			total_25p_population_00
			yrs_sch_25p_00to08_00 yrs_sch_25p_09to12_00 yrs_sch_25p_12_00
			yrs_sch_25p_12to14_00 yrs_sch_25p_14_00 yrs_sch_25p_16_00
			fay0100 fay0150 fay0200 fay0250 fay0300 fay0350 fay0400 fay0450
			fay0500 fay0600 fay0750 fay01000 fay01250 fay01500 fay02000, by(necma99);

/* some basic NECMA-level aggregates */
g avg_fam_inc_00 	= total_family_income_00/total_families_00;					
g prc_black_00   	= (total_black_population_00/total_population_00)*100; 
g prc_hispanic_00 	= (total_hispanic_population_00/total_population_00)*100;
g prc_under18_00 	= (total_under18_population_00/total_population_00)*100;	
g prc_over65_00 	= (total_over65_population_00/total_population_00)*100;	
g prc_foreign_00 	= (total_foreign_population_00/total_population_00)*100;		

/* compute quantiles of income distribution at the NECMA level */
g prc_10000  = fay0100/total_families_00;
g prc_15000  = (fay0100+fay0150)/total_families_00;
g prc_20000  = (fay0100+fay0150+fay0200)/total_families_00;
g prc_25000  = (fay0100+fay0150+fay0200+fay0250)/total_families_00;
g prc_30000  = (fay0100+fay0150+fay0200+fay0250+fay0300)/total_families_00;
g prc_35000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350)/total_families_00;
g prc_40000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400)/total_families_00;
g prc_45000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450)/total_families_00;
g prc_50000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500)/total_families_00;
g prc_60000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600)/total_families_00;
g prc_75000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750)/total_families_00;
g prc_100000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000)/total_families_00;
g prc_125000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250)/total_families_00;
g prc_150000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500)/total_families_00;
g prc_200000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500+fay02000)/total_families_00;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_45000 = invnormal(prc_45000) if prc_45000>0 & prc_45000<1;
g actQ_45000 = log(45000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

g refQ_200000 = invnormal(prc_200000) if prc_200000>0 & prc_200000<1;
g actQ_200000 = log(200000);

sort necma99;
save "$WRITE_DATA/necma_level_ncdb_2000ot", replace;	

stack 	refQ_10000 actQ_10000 necma99 
		refQ_15000 actQ_15000 necma99 
		refQ_20000 actQ_20000 necma99 
		refQ_25000 actQ_25000 necma99 
		refQ_30000 actQ_30000 necma99 
		refQ_35000 actQ_35000 necma99
		refQ_40000 actQ_40000 necma99 
		refQ_45000 actQ_45000 necma99
		refQ_50000 actQ_50000 necma99
		refQ_60000 actQ_60000 necma99 
		refQ_75000 actQ_75000 necma99 
		refQ_100000 actQ_100000 necma99 
		refQ_125000 actQ_125000 necma99 
		refQ_150000 actQ_150000 necma99
		refQ_200000 actQ_200000 necma99, into(refQ actQ necma99);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu 			= .;

levelsof necma99, local(necma99_list);
foreach l of local necma99_list {;
		di "-> necma99 = `l'";
		capture noisily reg actQ refQ if necma99 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if necma99 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if necma99 == `l';	
			replace overall_mu = b[1,2] if necma99 == `l';	
		};	
};

/* save NECMA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(necma99);		
sort necma99;
save "$WRITE_DATA/necma_sigma_ncdb_2000ot", replace;

/* append MSA- and NECMA-level data into single file */	
use "$WRITE_DATA/msa_level_ncdb_2000ot", clear;
append using "$WRITE_DATA/necma_level_ncdb_2000ot";	
save "$WRITE_DATA/msa_necma_level_ncdb_2000ot", replace;		
		
/* merge all data and create file NCDB 2000 file */	
use "$WRITE_DATA/msa_sigma_ncdb_2000ot", clear;
append using "$WRITE_DATA/necma_sigma_ncdb_2000ot";
sort msapma99 necma99;	
merge 1:1 msapma99 necma99 using "$WRITE_DATA/within_tract_ncdb_2000ot";
drop _merge;
sort msapma99 necma99;	
merge 1:1 msapma99 necma using "$WRITE_DATA/msa_necma_level_ncdb_2000ot";
drop _merge;
drop fay0100-fay02000 prc_10000-actQ_200000;
g NSI_00 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_00 = overall_sigma;
g mu_t_00 = overall_mu;
g sigma_w_00 = within_tract_sigma;
g r2_t_00 = r_squared_for_MSAt;
g r2_w_00 = r_squared_for_MSAw;
replace r2_w_00 = r_squared_for_NECMAw if r2_w_00==.;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw r_squared_for_NECMAw;
sort msapma99 necma99;		
save "$WRITE_DATA/msa_ncdb_2000ot", replace;

/* produce some summary statistics */
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 r2_t_00 r2_w_00 if msapma99~=.;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 r2_t_00 r2_w_00 if necma99~=.;

erase "$WRITE_DATA/tract_ncdb_2000ot.dta";
erase "$WRITE_DATA/within_tract_ncdb_2000ot.dta";
erase "$WRITE_DATA/msa_level_ncdb_2000ot.dta";
erase "$WRITE_DATA/necma_level_ncdb_2000ot.dta";
erase "$WRITE_DATA/msa_necma_level_ncdb_2000ot.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_2000ot.dta";
erase "$WRITE_DATA/necma_sigma_ncdb_2000ot.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_2000ot.dta";

/**************************************************************************************************/
/* MERGE 1970 to 2000 FILES INTO A SINGLE COMMON BOUNDARIES DATASET                               */
/**************************************************************************************************/
	
use "$WRITE_DATA/msa_ncdb_1970ot", clear;
sort msapma99 necma99;
merge 1:1 msapma99 necma99 using "$WRITE_DATA/msa_ncdb_1980ot";
drop _merge;
sort msapma99 necma99;
merge 1:1 msapma99 necma99 using "$WRITE_DATA/msa_ncdb_1990ot";
drop _merge;
merge 1:1 msapma99 necma99 using "$WRITE_DATA/msa_ncdb_2000ot";
drop _merge;

g prc_dropout25_70 = 100*(yrs_sch_25p_00to08_70+yrs_sch_25p_09to12_70)/total_25p_population_70;
g prc_dropout25_80 = 100*(yrs_sch_25p_00to08_80+yrs_sch_25p_09to12_80)/total_25p_population_80;
g prc_dropout25_90 = 100*(yrs_sch_25p_00to08_90+yrs_sch_25p_09to12_90)/total_25p_population_90;
g prc_dropout25_00 = 100*(yrs_sch_25p_00to08_00+yrs_sch_25p_09to12_00)/total_25p_population_00;

g prc_college25_70 = 100*(yrs_sch_25p_16_70)/total_25p_population_70;
g prc_college25_80 = 100*(yrs_sch_25p_16_80)/total_25p_population_80;
g prc_college25_90 = 100*(yrs_sch_25p_16_90)/total_25p_population_90;
g prc_college25_00 = 100*(yrs_sch_25p_16_00)/total_25p_population_00;


drop 	num_tracts_in_NECMA num_tracts_in_MSA 
		total_families_70 total_family_income_70 total_black_population_70 total_hispanic_population_70 
		total_under18_population_70 total_over65_population_70 total_foreign_population_70
		total_25p_population_70 yrs_sch_25p_00to08_70 yrs_sch_25p_09to12_70 yrs_sch_25p_12_70 yrs_sch_25p_12to16_70 yrs_sch_25p_16_70 
		total_families_80 total_family_income_80 total_black_population_80 total_hispanic_population_80 
		total_under18_population_80 total_over65_population_80 total_foreign_population_80
		total_25p_population_80 yrs_sch_25p_00to08_80 yrs_sch_25p_09to12_80 yrs_sch_25p_12_80 yrs_sch_25p_12to16_80 yrs_sch_25p_16_80 
		total_families_90 total_family_income_90 total_black_population_90 total_hispanic_population_90 
		total_under18_population_90 total_over65_population_90 total_foreign_population_90
		total_25p_population_90 yrs_sch_25p_00to08_90 yrs_sch_25p_09to12_90 yrs_sch_25p_12_90 yrs_sch_25p_12to14_90 yrs_sch_25p_14_90 yrs_sch_25p_16_90 
		total_families_00 total_family_income_00 total_black_population_00 total_hispanic_population_00 
		total_under18_population_00 total_over65_population_00 total_foreign_population_00
		total_25p_population_00 yrs_sch_25p_00to08_00 yrs_sch_25p_09to12_00 yrs_sch_25p_12_00 yrs_sch_25p_12to14_00 yrs_sch_25p_14_00 yrs_sch_25p_16_00;

g sigma_b_70 = sqrt(sigma_t_70^2 - sigma_w_70^2);
g sigma_b_80 = sqrt(sigma_t_80^2 - sigma_w_80^2);
g sigma_b_90 = sqrt(sigma_t_90^2 - sigma_w_90^2);
g sigma_b_00 = sqrt(sigma_t_00^2 - sigma_w_00^2);
g ALL_YEARS = (sigma_b_70~=.)*(sigma_b_80~=.)*(sigma_b_90~=.)*(sigma_b_00~=.);

log using "$WRITE_DATA/summary_stats_ncdb_1970to2000", replace;
log on;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & necma99==.;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & necma99==.;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & necma99==.;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & necma99==.;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & necma99==. & total_population_70>250000;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & necma99==. & total_population_70>250000;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & necma99==. & total_population_70>250000;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & necma99==. & total_population_70>250000;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & necma99==. & total_population_70<=250000;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & necma99==. & total_population_70<=250000;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & necma99==. & total_population_70<=250000;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & necma99==. & total_population_70<=250000;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & msapma99==.;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & msapma99==.;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & msapma99==.;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & msapma99==.;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & msapma99==. & total_population_70>250000;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & msapma99==. & total_population_70>250000;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & msapma99==. & total_population_70>250000;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & msapma99==. & total_population_70>250000;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & msapma99==. & total_population_70<=250000;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & msapma99==. & total_population_70<=250000;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & msapma99==. & total_population_70<=250000;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & msapma99==. & total_population_70<=250000;

log off;
save "$WRITE_DATA/msapma_necma_ncdb_1970to2000", replace;	

keep if ALL_YEARS==1 & necma99==.;
stack NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 total_population_70 total_population_70 avg_fam_inc_70 prc_dropout25_70 prc_college25_70 prc_black_70 prc_hispanic_70 msapma99
	  NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 total_population_70 total_population_80 avg_fam_inc_80 prc_dropout25_80 prc_college25_80 prc_black_80 prc_hispanic_80 msapma99
	  NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 total_population_70 total_population_90 avg_fam_inc_90 prc_dropout25_90 prc_college25_90 prc_black_90 prc_hispanic_90 msapma99
	  NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 total_population_70 total_population_00 avg_fam_inc_00 prc_dropout25_00 prc_college25_00 prc_black_00 prc_hispanic_00 msapma99,
	  into(NSI mu sigma sigma_b sigma_w pop70 pop avg_fam_inc prc_dropout25 prc_college25 prc_black prc_hispanic msapma99);
	  
rename _stack year;

replace year = 1970 if year==1;
replace year = 1980 if year==2;
replace year = 1990 if year==3;
replace year = 2000 if year==4;

g D70 = (year==1970);
g D80 = (year==1980);
g D90 = (year==1990);
g D00 = (year==2000);	 

save "$WRITE_DATA/msapma_necma_ncdb_1970to2000_stacked", replace;	

log on;
reg NSI D70 D80 D90 D00, nocons cluster(msapma99);
matrix b_all = e(b)';
reg NSI D70 D80 D90 D00 if pop70<=250000, nocons cluster(msapma99);
matrix b_small = e(b)';
reg NSI D70 D80 D90 D00 if pop70>=250000, nocons cluster(msapma99);
matrix b_large = e(b)';
log off;

matrix input years = (1970\1980\1990\2000);
svmat b_all;
svmat b_small;
svmat b_large;
svmat years;

scatter b_all1 b_small1 b_large1 years1, msymbol(i i i) c(l l l) clpattern(l - -.) lw(medium medium medium) lc(red red blue) 		xlabel(1970 1980 1990 2000)		ylabel(0.1 0.125 0.15 0.175 0.2 0.225 0.25)		yscale(range(0.1 0.25))
		xscale(range(1970 2000))		title("")		subtitle("Residential income stratification: 1970 to 2000")    	xtitle("Year")
    	ytitle("Neighborhood Sorting Index")
    	legend(lab(1 "All MSAs") lab(2 "Small MSAs") lab(3 "Large MSAs") cols(1) pos(5) ring(0));
    			
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_TRENDS_1970_to_2000.gph, replace;

log close;

/**************************************************************************************************/
/* USING 1981 SMSA81 DEFINITIONS                                                                  */
/**************************************************************************************************/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_80.csv", clear comma names;

/* some basic census region indicators */
g region_80 = region;
g division_80 = divis;

/* create some basic-tract level aggregates */
g total_population_80 = shr8d;
g total_white_population_80 = shrwht8n;
g total_black_population_80 = shrblk8n;
g total_hispanic_population_80 = shrhsp8n;
g total_under18_population_80 = child8n;
g total_over65_population_80 = old8n;
g total_foreign_population_80 = forborn8;

g total_families_80 = favinc8d;
g total_family_income_80 = favinc8n;
g average_family_income_80 = favinc8;

g total_25p_population_80  	= educpp8;
g yrs_sch_25p_00to08_80 	= educ88;
g yrs_sch_25p_09to12_80 	= educ118;
g yrs_sch_25p_12_80 		= educ128;
g yrs_sch_25p_12to16_80 	= educ158;
g yrs_sch_25p_16_80 		= educ168;	

g dropout_16_19_80          = hsdrop8n;
g total_16_19_80			= hsdrop8d;	

save "$WRITE_DATA/tract_ncdb_1980", replace;

/* compute quantiles of income distribution for each tract */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_2500 actQ_2500 smsa80 geo1980
		refQ_5000 actQ_5000 smsa80 geo1980
		refQ_7500 actQ_7500 smsa80 geo1980
		refQ_10000 actQ_10000 smsa80 geo1980 
		refQ_12500 actQ_12500 smsa80 geo1980 
		refQ_15000 actQ_15000 smsa80 geo1980 
		refQ_17500 actQ_17500 smsa80 geo1980 
		refQ_20000 actQ_20000 smsa80 geo1980 
		refQ_22500 actQ_22500 smsa80 geo1980 
		refQ_25000 actQ_25000 smsa80 geo1980 
		refQ_27500 actQ_27500 smsa80 geo1980 
		refQ_30000 actQ_30000 smsa80 geo1980 
		refQ_35000 actQ_35000 smsa80 geo1980 
		refQ_40000 actQ_40000 smsa80 geo1980 
		refQ_50000 actQ_50000 smsa80 geo1980 
		refQ_75000 actQ_75000 smsa80 geo1980, into(refQ actQ smsa80 geo1980);

save "$WRITE_DATA/stacked_tract_ncdb_1980", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof smsa80, local(smsa80_list);
foreach l of local smsa80_list {;
		di "-> smsa80 = `l'";
		capture noisily areg actQ refQ if smsa80 == `l', absorb(geo1980) vce(cluster geo1980);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if smsa80 == `l';
			replace r_squared_for_MSAw = e(r2) if smsa80 == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if smsa80 == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(smsa80);

sort smsa80;			
save "$WRITE_DATA/within_tract_ncdb_1980", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1980", clear;
		
collapse 	(sum) 
			total_families_80 total_family_income_80 
			total_population_80 total_black_population_80 total_hispanic_population_80
			total_under18_population_80 total_over65_population_80 total_foreign_population_80
			total_25p_population_80
			yrs_sch_25p_00to08_80 yrs_sch_25p_09to12_80 yrs_sch_25p_12_80
			yrs_sch_25p_12to16_80 yrs_sch_25p_16_80
			falt38 falt58 falt88 falt108 falt138 falt158 falt188 falt208 
			falt238 falt258 falt288 falt308 falt358 falt408 falt498 falt758, by(smsa80);

/* some basic MSA-level aggregates */
g avg_fam_inc_80 	= total_family_income_80/total_families_80;						
g prc_black_80   	= (total_black_population_80/total_population_80)*100; 
g prc_hispanic_80 	= (total_hispanic_population_80/total_population_80)*100;
g prc_under18_80 	= (total_under18_population_80/total_population_80)*100;	
g prc_over65_80 	= (total_over65_population_80/total_population_80)*100;	
g prc_foreign_80 	= (total_foreign_population_80/total_population_80)*100;
	
/* compute quantiles of income distribution at the MSA level */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

sort smsa80;
save "$WRITE_DATA/msa_level_ncdb_1980", replace;	

stack 	refQ_2500 actQ_2500 smsa80
		refQ_5000 actQ_5000 smsa80
		refQ_7500 actQ_7500 smsa80
		refQ_10000 actQ_10000 smsa80 
		refQ_12500 actQ_12500 smsa80 
		refQ_15000 actQ_15000 smsa80 
		refQ_17500 actQ_17500 smsa80 
		refQ_20000 actQ_20000 smsa80 
		refQ_22500 actQ_22500 smsa80 
		refQ_25000 actQ_25000 smsa80 
		refQ_27500 actQ_27500 smsa80 
		refQ_30000 actQ_30000 smsa80 
		refQ_35000 actQ_35000 smsa80
		refQ_40000 actQ_40000 smsa80 
		refQ_50000 actQ_50000 smsa80
		refQ_75000 actQ_75000 smsa80, into(refQ actQ smsa80);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu 			= .;

levelsof smsa80, local(smsa80_list);
foreach l of local smsa80_list {;
		di "-> smsa80 = `l'";
		capture noisily reg actQ refQ if smsa80 == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if smsa80 == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if smsa80 == `l';	
			replace overall_mu = b[1,2] if smsa80 == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(smsa80);		
sort smsa80;
save "$WRITE_DATA/msa_sigma_ncdb_1980", replace;
	
		
/* merge all data and create file NCDB 1980 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1980", clear;
sort smsa80;	
merge 1:1 smsa80 using "$WRITE_DATA/within_tract_ncdb_1980";
drop _merge;
sort smsa80;	
merge 1:1 smsa80 using "$WRITE_DATA/msa_level_ncdb_1980";
drop _merge;
drop falt38-falt758 prc_2500-actQ_75000;
g NSI_80 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_80 = overall_sigma;
g mu_t_80 = overall_mu;
g sigma_w_80 = within_tract_sigma;
g r2_t_80 = r_squared_for_MSAt;
g r2_w_80 = r_squared_for_MSAw;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw;
sort smsa80;		
save "$WRITE_DATA/msa_ncdb_1980", replace;

/* produce some summary statistics */
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 r2_t_80 r2_w_80 if smsa80~=.;

erase "$WRITE_DATA/tract_ncdb_1980.dta";
erase "$WRITE_DATA/within_tract_ncdb_1980.dta";
erase "$WRITE_DATA/msa_level_ncdb_1980.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1980.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1980.dta";

/**************************************************************************************************/
/* USING CROSSWALK INTO 81To99 MSA PANEL DEFINITIONS                                              */
/**************************************************************************************************/

/**************************************************************************************************/
/* 1980 USING 1980 TRACTING OF SMSA/MSA                											  */
/**************************************************************************************************/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_80.csv", clear comma names;

/* some basic census region indicators */
g region_80 = region;
g division_80 = divis;

/* create some basic-tract level aggregates */
g total_population_80 = shr8d;
g total_white_population_80 = shrwht8n;
g total_black_population_80 = shrblk8n;
g total_hispanic_population_80 = shrhsp8n;
g total_under18_population_80 = child8n;
g total_over65_population_80 = old8n;
g total_foreign_population_80 = forborn8;

g total_families_80 = favinc8d;
g total_family_income_80 = favinc8n;
g average_family_income_80 = favinc8;

g total_25p_population_80  	= educpp8;
g yrs_sch_25p_00to08_80 	= educ88;
g yrs_sch_25p_09to12_80 	= educ118;
g yrs_sch_25p_12_80 		= educ128;
g yrs_sch_25p_12to16_80 	= educ158;
g yrs_sch_25p_16_80 		= educ168;	

g dropout_16_19_80          = hsdrop8n;
g total_16_19_80			= hsdrop8d;
save "$WRITE_DATA/tract_ncdb_1980cw", replace;	

/* merge with 1981 to 1999 MSA concordance */
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort SMSA81;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_1980cw", clear;
capture g SMSA81 = smsa80;
sort SMSA81;
merge m:m SMSA81 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab SMSA81 if _merge==1;
tab SMSA81 if _merge==2;
drop if _merge==2;
drop _merge;
capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
drop scsa81 MSAPMA99 msacma99 pmsa99 NECMA99 placename99 msapma99m msacma99m pmsa99m necma99m;
save "$WRITE_DATA/tract_ncdb_1980cw", replace;

/* compute quantiles of income distribution for each tract */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_2500 actQ_2500 MSA geo1980
		refQ_5000 actQ_5000 MSA geo1980
		refQ_7500 actQ_7500 MSA geo1980
		refQ_10000 actQ_10000 MSA geo1980 
		refQ_12500 actQ_12500 MSA geo1980 
		refQ_15000 actQ_15000 MSA geo1980 
		refQ_17500 actQ_17500 MSA geo1980 
		refQ_20000 actQ_20000 MSA geo1980 
		refQ_22500 actQ_22500 MSA geo1980 
		refQ_25000 actQ_25000 MSA geo1980 
		refQ_27500 actQ_27500 MSA geo1980 
		refQ_30000 actQ_30000 MSA geo1980 
		refQ_35000 actQ_35000 MSA geo1980 
		refQ_40000 actQ_40000 MSA geo1980 
		refQ_50000 actQ_50000 MSA geo1980 
		refQ_75000 actQ_75000 MSA geo1980, into(refQ actQ MSA geo1980);

save "$WRITE_DATA/stacked_tract_ncdb_1980cw", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily areg actQ refQ if MSA == `l', absorb(geo1980) vce(cluster geo1980);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if MSA == `l';
			replace r_squared_for_MSAw = e(r2) if MSA == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if MSA == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(MSA);

sort MSA;			
save "$WRITE_DATA/within_tract_ncdb_1980cw", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1980cw", clear;
		
collapse 	(sum) 
			total_families_80 total_family_income_80 
			total_population_80 total_black_population_80 total_hispanic_population_80
			total_under18_population_80 total_over65_population_80 total_foreign_population_80
			total_25p_population_80
			yrs_sch_25p_00to08_80 yrs_sch_25p_09to12_80 yrs_sch_25p_12_80
			yrs_sch_25p_12to16_80 yrs_sch_25p_16_80
			falt38 falt58 falt88 falt108 falt138 falt158 falt188 falt208 
			falt238 falt258 falt288 falt308 falt358 falt408 falt498 falt758, by(MSA);

/* some basic MSA-level aggregates */	
g avg_fam_inc_80 	= total_family_income_80/total_families_80;				
g prc_black_80   	= (total_black_population_80/total_population_80)*100; 
g prc_hispanic_80 	= (total_hispanic_population_80/total_population_80)*100;
g prc_under18_80 	= (total_under18_population_80/total_population_80)*100;	
g prc_over65_80 	= (total_over65_population_80/total_population_80)*100;	
g prc_foreign_80 	= (total_foreign_population_80/total_population_80)*100;		
	
/* compute quantiles of income distribution at the MSA level */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

sort MSA;
save "$WRITE_DATA/msa_level_ncdb_1980cw", replace;	

stack 	refQ_2500 actQ_2500 MSA
		refQ_5000 actQ_5000 MSA
		refQ_7500 actQ_7500 MSA
		refQ_10000 actQ_10000 MSA 
		refQ_12500 actQ_12500 MSA 
		refQ_15000 actQ_15000 MSA 
		refQ_17500 actQ_17500 MSA 
		refQ_20000 actQ_20000 MSA 
		refQ_22500 actQ_22500 MSA 
		refQ_25000 actQ_25000 MSA 
		refQ_27500 actQ_27500 MSA 
		refQ_30000 actQ_30000 MSA 
		refQ_35000 actQ_35000 MSA
		refQ_40000 actQ_40000 MSA 
		refQ_50000 actQ_50000 MSA
		refQ_75000 actQ_75000 MSA, into(refQ actQ MSA);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu	 		= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily reg actQ refQ if MSA == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if MSA == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if MSA == `l';	
			replace overall_mu = b[1,2] if MSA == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(MSA);		
sort MSA;
save "$WRITE_DATA/msa_sigma_ncdb_1980cw", replace;
	
		
/* merge all data and create file NCDB 1980 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1980cw", clear;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/within_tract_ncdb_1980cw";
drop _merge;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/msa_level_ncdb_1980cw";
drop _merge;
drop falt38-falt758 prc_2500-actQ_75000;
g NSI_80 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_80 = overall_sigma;
g mu_t_80 = overall_mu;
g sigma_w_80 = within_tract_sigma;
g r2_t_80 = r_squared_for_MSAt;
g r2_w_80 = r_squared_for_MSAw;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw;
sort MSA;		
save "$WRITE_DATA/msa_ncdb_1980cw", replace;

/* produce some summary statistics */
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 r2_t_80 r2_w_80 if MSA~=.;

erase "$WRITE_DATA/tract_ncdb_1980cw.dta";
erase "$WRITE_DATA/within_tract_ncdb_1980cw.dta";
erase "$WRITE_DATA/msa_level_ncdb_1980cw.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1980cw.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1980cw.dta";

/**************************************************************************************************/
/* NCDB 1970 to 2000 using 1981to1999 CROSSWALK *and* NCDB panel tracting of MSAs                 */
/**************************************************************************************************/

/********/
/* 1970 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_70 = region;
g division_70 = divis;

/* create some basic-tract level aggregates */
g total_population_70 = shr7d;
g total_white_population_70 = shrwht7n;
g total_black_population_70 = shrblk7n;
g total_hispanic_population_70 = shrhsp7n;
g total_under18_population_70 = child7n;
g total_over65_population_70 = old7n;
g total_foreign_population_70 = forborn7;

g total_families_70 = favinc7d;
g total_family_income_70 = favinc7n;
g average_family_income_70 = favinc7;

g total_25p_population_70  	= educpp7;
g yrs_sch_25p_00to08_70 	= educ87;
g yrs_sch_25p_09to12_70 	= educ117;
g yrs_sch_25p_12_70 		= educ127;
g yrs_sch_25p_12to16_70 	= educ157;
g yrs_sch_25p_16_70 		= educ167;	

g dropout_16_19_70          = hsdrop7n;
g total_16_19_70			= hsdrop7d;	
save "$WRITE_DATA/tract_ncdb_1970ot_cw", replace;

/*******************************************/
/* merge with 1981 to 1999 MSA concordance */
/*******************************************/

/***************************/
/* first merge on MSAPMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort MSAPMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_1970ot_cw", clear;
capture drop MSAPMA99;
capture g MSAPMA99 = msapma99;
sort MSAPMA99;
merge m:m MSAPMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab MSAPMA99 if _merge==1;
tab MSAPMA99 if _merge==2;
drop if _merge==2;
drop _merge;
save "$WRITE_DATA/tract_ncdb_1970ot_cw", replace;

/***************************/
/* second merge on NECMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort NECMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_1970ot_cw", clear;
capture drop NECMA99;
capture g NECMA99  = necma99;
sort NECMA99;
merge m:m NECMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab NECMA99 if _merge==1;
tab NECMA99 if _merge==2;
drop if _merge==2;
drop _merge;

capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
drop scsa81 MSAPMA99 msacma99 pmsa99 NECMA99 placename99 msapma99m msacma99m pmsa99m necma99m;
save "$WRITE_DATA/tract_ncdb_1970ot_cw", replace;

/* compute quantiles of income distribution for each tract */
g prc_1000 = falt17/total_families_70;
g prc_2000 = (falt17+falt27)/total_families_70;
g prc_3000 = (falt17+falt27+falt37)/total_families_70;
g prc_4000 = (falt17+falt27+falt37+falt47)/total_families_70;
g prc_5000 = (falt17+falt27+falt37+falt47+falt57)/total_families_70;
g prc_6000 = (falt17+falt27+falt37+falt47+falt57+falt67)/total_families_70;
g prc_7000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77)/total_families_70;
g prc_8000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87)/total_families_70;
g prc_9000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97)/total_families_70;
g prc_10000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107)/total_families_70;
g prc_12000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127)/total_families_70;
g prc_15000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157)/total_families_70;
g prc_25000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257)/total_families_70;
g prc_50000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257+falt507)/total_families_70;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_1000 = invnormal(prc_1000) if prc_1000>0 & prc_1000<1;
g actQ_1000 = log(1000);

g refQ_2000 = invnormal(prc_2000) if prc_2000>0 & prc_2000<1;
g actQ_2000 = log(2000);

g refQ_3000 = invnormal(prc_3000) if prc_3000>0 & prc_3000<1;
g actQ_3000 = log(3000);

g refQ_4000 = invnormal(prc_4000) if prc_4000>0 & prc_4000<1;
g actQ_4000 = log(4000);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_6000 = invnormal(prc_6000) if prc_6000>0 & prc_6000<1;
g actQ_6000 = log(6000);

g refQ_7000 = invnormal(prc_7000) if prc_7000>0 & prc_7000<1;
g actQ_7000 = log(7000);

g refQ_8000 = invnormal(prc_8000) if prc_8000>0 & prc_8000<1;
g actQ_8000 = log(8000);

g refQ_9000 = invnormal(prc_9000) if prc_9000>0 & prc_9000<1;
g actQ_9000 = log(9000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12000 = invnormal(prc_12000) if prc_12000>0 & prc_12000<1;
g actQ_12000 = log(12000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_1000 actQ_1000 MSA geo2000
		refQ_2000 actQ_2000 MSA geo2000
		refQ_3000 actQ_3000 MSA geo2000
		refQ_4000 actQ_4000 MSA geo2000
		refQ_5000 actQ_5000 MSA geo2000
		refQ_6000 actQ_6000 MSA geo2000
		refQ_7000 actQ_7000 MSA geo2000
		refQ_8000 actQ_8000 MSA geo2000
		refQ_9000 actQ_9000 MSA geo2000
		refQ_10000 actQ_10000 MSA geo2000
		refQ_12000 actQ_12000 MSA geo2000
		refQ_15000 actQ_15000 MSA geo2000
		refQ_25000 actQ_25000 MSA geo2000
		refQ_50000 actQ_50000 MSA geo2000, into(refQ actQ MSA geo2000);		

save "$WRITE_DATA/stacked_tract_ncdb_1970ot_cw", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily areg actQ refQ if MSA == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if MSA == `l';
			replace r_squared_for_MSAw = e(r2) if MSA == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if MSA == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(MSA);

sort MSA;			
save "$WRITE_DATA/within_tract_ncdb_1970ot_cw", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1970ot_cw", clear;
		
collapse 	(sum)
			total_families_70 total_family_income_70 
			total_population_70 total_black_population_70 total_hispanic_population_70
			total_under18_population_70 total_over65_population_70 total_foreign_population_70
			total_25p_population_70
			yrs_sch_25p_00to08_70 yrs_sch_25p_09to12_70 yrs_sch_25p_12_70
			yrs_sch_25p_12to16_70 yrs_sch_25p_16_70
			falt17 falt27 falt37 falt47 falt57 falt67 falt77 falt87 falt97 falt107 
			falt127 falt157 falt257 falt507, by(MSA);

/* some basic MSA-level aggregates */
g avg_fam_inc_70 	= total_family_income_70/total_families_70;					
g prc_black_70   	= (total_black_population_70/total_population_70)*100; 
g prc_hispanic_70 	= (total_hispanic_population_70/total_population_70)*100;	
g prc_under18_70 	= (total_under18_population_70/total_population_70)*100;	
g prc_over65_70 	= (total_over65_population_70/total_population_70)*100;	
g prc_foreign_70 	= (total_foreign_population_70/total_population_70)*100;	

/* compute quantiles of income distribution at the MSA level */
g prc_1000 = falt17/total_families_70;
g prc_2000 = (falt17+falt27)/total_families_70;
g prc_3000 = (falt17+falt27+falt37)/total_families_70;
g prc_4000 = (falt17+falt27+falt37+falt47)/total_families_70;
g prc_5000 = (falt17+falt27+falt37+falt47+falt57)/total_families_70;
g prc_6000 = (falt17+falt27+falt37+falt47+falt57+falt67)/total_families_70;
g prc_7000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77)/total_families_70;
g prc_8000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87)/total_families_70;
g prc_9000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97)/total_families_70;
g prc_10000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107)/total_families_70;
g prc_12000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127)/total_families_70;
g prc_15000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157)/total_families_70;
g prc_25000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257)/total_families_70;
g prc_50000 = (falt17+falt27+falt37+falt47+falt57+falt67+falt77+falt87+falt97+falt107+falt127+falt157+falt257+falt507)/total_families_70;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_1000 = invnormal(prc_1000) if prc_1000>0 & prc_1000<1;
g actQ_1000 = log(1000);

g refQ_2000 = invnormal(prc_2000) if prc_2000>0 & prc_2000<1;
g actQ_2000 = log(2000);

g refQ_3000 = invnormal(prc_3000) if prc_3000>0 & prc_3000<1;
g actQ_3000 = log(3000);

g refQ_4000 = invnormal(prc_4000) if prc_4000>0 & prc_4000<1;
g actQ_4000 = log(4000);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_6000 = invnormal(prc_6000) if prc_6000>0 & prc_6000<1;
g actQ_6000 = log(6000);

g refQ_7000 = invnormal(prc_7000) if prc_7000>0 & prc_7000<1;
g actQ_7000 = log(7000);

g refQ_8000 = invnormal(prc_8000) if prc_8000>0 & prc_8000<1;
g actQ_8000 = log(8000);

g refQ_9000 = invnormal(prc_9000) if prc_9000>0 & prc_9000<1;
g actQ_9000 = log(9000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12000 = invnormal(prc_12000) if prc_12000>0 & prc_12000<1;
g actQ_12000 = log(12000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

sort MSA;
save "$WRITE_DATA/msa_level_ncdb_1970ot_cw", replace;	

stack 	refQ_1000 actQ_1000 MSA
		refQ_2000 actQ_2000 MSA  
		refQ_3000 actQ_3000 MSA 
		refQ_4000 actQ_4000 MSA 
		refQ_5000 actQ_5000 MSA 
		refQ_6000 actQ_6000 MSA
		refQ_7000 actQ_7000 MSA
		refQ_8000 actQ_8000 MSA
		refQ_9000 actQ_9000 MSA
		refQ_10000 actQ_10000 MSA
		refQ_12000 actQ_12000 MSA
		refQ_15000 actQ_15000 MSA
		refQ_25000 actQ_25000 MSA
		refQ_50000 actQ_50000 MSA, into(refQ actQ MSA);		

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu	 		= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily reg actQ refQ if MSA == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if MSA == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if MSA == `l';
			replace overall_mu = b[1,2] if MSA == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(MSA);		
sort MSA;
save "$WRITE_DATA/msa_sigma_ncdb_1970ot_cw", replace;
	
/* merge all data and create file NCDB 1970 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1970ot_cw", clear;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/within_tract_ncdb_1970ot_cw";
drop _merge;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/msa_level_ncdb_1970ot_cw";
drop _merge;
drop falt17-falt507 prc_1000-actQ_50000;
g NSI_70 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_70 = overall_sigma;
g mu_t_70 = overall_mu;
g sigma_w_70 = within_tract_sigma;
g r2_t_70 = r_squared_for_MSAt;
g r2_w_70 = r_squared_for_MSAw;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw;
sort MSA;		
save "$WRITE_DATA/msa_ncdb_1970ot_cw", replace;

/* produce some summary statistics */
sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 r2_t_70 r2_w_70 if MSA~=.;

erase "$WRITE_DATA/tract_ncdb_1970ot_cw.dta";
erase "$WRITE_DATA/within_tract_ncdb_1970ot_cw.dta";
erase "$WRITE_DATA/msa_level_ncdb_1970ot_cw.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1970ot_cw.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1970ot_cw.dta";

/********/
/* 1980 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_80 = region;
g division_80 = divis;

/* create some basic-tract level aggregates */
g total_population_80 = shr8d;
g total_white_population_80 = shrwht8n;
g total_black_population_80 = shrblk8n;
g total_hispanic_population_80 = shrhsp8n;
g total_under18_population_80 = child8n;
g total_over65_population_80 = old8n;
g total_foreign_population_80 = forborn8;

g total_families_80 = favinc8d;
g total_family_income_80 = favinc8n;
g average_family_income_80 = favinc8;

g total_25p_population_80  	= educpp8;
g yrs_sch_25p_00to08_80 	= educ88;
g yrs_sch_25p_09to12_80 	= educ118;
g yrs_sch_25p_12_80 		= educ128;
g yrs_sch_25p_12to16_80 	= educ158;
g yrs_sch_25p_16_80 		= educ168;	

g dropout_16_19_80          = hsdrop8n;
g total_16_19_80			= hsdrop8d;	

save "$WRITE_DATA/tract_ncdb_1980ot_cw", replace;

/*******************************************/
/* merge with 1981 to 1999 MSA concordance */
/*******************************************/

/***************************/
/* first merge on MSAPMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort MSAPMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_1980ot_cw", clear;
capture drop MSAPMA99;
capture g MSAPMA99 = msapma99;
sort MSAPMA99;
merge m:m MSAPMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab MSAPMA99 if _merge==1;
tab MSAPMA99 if _merge==2;
drop if _merge==2;
drop _merge;
save "$WRITE_DATA/tract_ncdb_1980ot_cw", replace;

/***************************/
/* second merge on NECMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort NECMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_1980ot_cw", clear;
capture drop NECMA99;
capture g NECMA99 = necma99;
sort NECMA99;
merge m:m NECMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab NECMA99 if _merge==1;
tab NECMA99 if _merge==2;
drop if _merge==2;
drop _merge;

capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
drop scsa81 MSAPMA99 msacma99 pmsa99 NECMA99 placename99 msapma99m msacma99m pmsa99m necma99m;
save "$WRITE_DATA/tract_ncdb_1980ot_cw", replace;

/* compute quantiles of income distribution for each tract */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_2500 actQ_2500 MSA geo2000
		refQ_5000 actQ_5000 MSA geo2000
		refQ_7500 actQ_7500 MSA geo2000
		refQ_10000 actQ_10000 MSA geo2000 
		refQ_12500 actQ_12500 MSA geo2000 
		refQ_15000 actQ_15000 MSA geo2000 
		refQ_17500 actQ_17500 MSA geo2000 
		refQ_20000 actQ_20000 MSA geo2000 
		refQ_22500 actQ_22500 MSA geo2000 
		refQ_25000 actQ_25000 MSA geo2000 
		refQ_27500 actQ_27500 MSA geo2000 
		refQ_30000 actQ_30000 MSA geo2000 
		refQ_35000 actQ_35000 MSA geo2000 
		refQ_40000 actQ_40000 MSA geo2000 
		refQ_50000 actQ_50000 MSA geo2000 
		refQ_75000 actQ_75000 MSA geo2000, into(refQ actQ MSA geo2000);

save "$WRITE_DATA/stacked_tract_ncdb_1980ot_cw", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily areg actQ refQ if MSA == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if MSA == `l';
			replace r_squared_for_MSAw = e(r2) if MSA == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if MSA == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(MSA);

sort MSA;			
save "$WRITE_DATA/within_tract_ncdb_1980ot_cw", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1980ot_cw", clear;
		
collapse 	(sum) 
			total_families_80 total_family_income_80 
			total_population_80 total_black_population_80 total_hispanic_population_80
			total_under18_population_80 total_over65_population_80 total_foreign_population_80
			total_25p_population_80
			yrs_sch_25p_00to08_80 yrs_sch_25p_09to12_80 yrs_sch_25p_12_80
			yrs_sch_25p_12to16_80 yrs_sch_25p_16_80
			falt38 falt58 falt88 falt108 falt138 falt158 falt188 falt208 
			falt238 falt258 falt288 falt308 falt358 falt408 falt498 falt758, by(MSA);

/* some basic MSA-level aggregates */
g avg_fam_inc_80 	= total_family_income_80/total_families_80;					
g prc_black_80   	= (total_black_population_80/total_population_80)*100; 
g prc_hispanic_80 	= (total_hispanic_population_80/total_population_80)*100;
g prc_under18_80 	= (total_under18_population_80/total_population_80)*100;	
g prc_over65_80 	= (total_over65_population_80/total_population_80)*100;	
g prc_foreign_80 	= (total_foreign_population_80/total_population_80)*100;	
	
/* compute quantiles of income distribution at the MSA level */
g prc_2500  = falt38/total_families_80;
g prc_5000 	= (falt38+falt58)/total_families_80;
g prc_7500 	= (falt38+falt58+falt88)/total_families_80;
g prc_10000 = (falt38+falt58+falt88+falt108)/total_families_80;
g prc_12500 = (falt38+falt58+falt88+falt108+falt138)/total_families_80;
g prc_15000 = (falt38+falt58+falt88+falt108+falt138+falt158)/total_families_80;
g prc_17500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188)/total_families_80;
g prc_20000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208)/total_families_80;
g prc_22500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238)/total_families_80;
g prc_25000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258)/total_families_80;
g prc_27500 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288)/total_families_80;
g prc_30000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308)/total_families_80;
g prc_35000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358)/total_families_80;
g prc_40000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408)/total_families_80;
g prc_50000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498)/total_families_80;
g prc_75000 = (falt38+falt58+falt88+falt108+falt138+falt158+falt188+falt208+falt238+falt258+falt288+falt308+falt358+falt408+falt498+falt758)/total_families_80;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_2500 = invnormal(prc_2500) if prc_2500>0 & prc_2500<1;
g actQ_2500 = log(2500);

g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_7500 = invnormal(prc_7500) if prc_7500>0 & prc_7500<1;
g actQ_7500 = log(7500);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

sort MSA;
save "$WRITE_DATA/msa_level_ncdb_1980ot_cw", replace;	

stack 	refQ_2500 actQ_2500 MSA
		refQ_5000 actQ_5000 MSA
		refQ_7500 actQ_7500 MSA
		refQ_10000 actQ_10000 MSA 
		refQ_12500 actQ_12500 MSA 
		refQ_15000 actQ_15000 MSA 
		refQ_17500 actQ_17500 MSA 
		refQ_20000 actQ_20000 MSA 
		refQ_22500 actQ_22500 MSA 
		refQ_25000 actQ_25000 MSA 
		refQ_27500 actQ_27500 MSA 
		refQ_30000 actQ_30000 MSA 
		refQ_35000 actQ_35000 MSA
		refQ_40000 actQ_40000 MSA 
		refQ_50000 actQ_50000 MSA
		refQ_75000 actQ_75000 MSA, into(refQ actQ MSA);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu	 		= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily reg actQ refQ if MSA == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if MSA == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if MSA == `l';
			replace overall_mu = b[1,2] if MSA == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(MSA);		
sort MSA;
save "$WRITE_DATA/msa_sigma_ncdb_1980ot_cw", replace;
	
/* merge all data and create file NCDB 1980 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1980ot_cw", clear;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/within_tract_ncdb_1980ot_cw";
drop _merge;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/msa_level_ncdb_1980ot_cw";
drop _merge;
drop falt38-falt758 prc_2500-actQ_75000;
g NSI_80 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_80 = overall_sigma;
g mu_t_80 = overall_mu;
g sigma_w_80 = within_tract_sigma;
g r2_t_80 = r_squared_for_MSAt;
g r2_w_80 = r_squared_for_MSAw;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw;
sort MSA;		
save "$WRITE_DATA/msa_ncdb_1980ot_cw", replace;

/* produce some summary statistics */
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 r2_t_80 r2_w_80 if MSA~=.;

erase "$WRITE_DATA/tract_ncdb_1980ot_cw.dta";
erase "$WRITE_DATA/within_tract_ncdb_1980ot_cw.dta";
erase "$WRITE_DATA/msa_level_ncdb_1980ot_cw.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1980ot_cw.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1980ot_cw.dta";

/********/
/* 1990 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_90 = region;
g division_90 = divis;

/* create some basic-tract level aggregates */
g total_population_90 = shr9d;
g total_white_population_90 = shrwht9n;
g total_black_population_90 = shrblk9n;
g total_hispanic_population_90 = shrhsp9n;
g total_under18_population_90 = child9n;
g total_over65_population_90 = old9n;
g total_foreign_population_90 = forborn9;

g total_families_90 = favinc9d;
g total_family_income_90 = favinc9n;
g average_family_income_90 = favinc9;
g median_family_income_90 = mdfamy9;

g total_25p_population_90  	= educpp9;
g yrs_sch_25p_00to08_90 	= educ89;
g yrs_sch_25p_09to12_90 	= educ119;
g yrs_sch_25p_12_90 		= educ129;
g yrs_sch_25p_12to14_90 	= educ159;
g yrs_sch_25p_14_90 		= educa9;
g yrs_sch_25p_16_90 		= educ169;	

g dropout_16_19_90          = hsdrop9n;
g total_16_19_90			= hsdrop9d;	

save "$WRITE_DATA/tract_ncdb_1990ot_cw", replace;

/*******************************************/
/* merge with 1981 to 1999 MSA concordance */
/*******************************************/

/***************************/
/* first merge on MSAPMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort MSAPMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_1990ot_cw", clear;
capture drop MSAPMA99;
capture g MSAPMA99 = msapma99;
sort MSAPMA99;
merge m:m MSAPMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab MSAPMA99 if _merge==1;
tab MSAPMA99 if _merge==2;
drop if _merge==2;
drop _merge;
save "$WRITE_DATA/tract_ncdb_1990ot_cw", replace;

/***************************/
/* second merge on NECMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort NECMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_1990ot_cw", clear;
capture drop NECMA99;
capture g NECMA99 = necma99;
sort NECMA99;
merge m:m NECMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab NECMA99 if _merge==1;
tab NECMA99 if _merge==2;
drop if _merge==2;
drop _merge;

capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
drop scsa81 MSAPMA99 msacma99 pmsa99 NECMA99 placename99 msapma99m msacma99m pmsa99m necma99m;
save "$WRITE_DATA/tract_ncdb_1990ot_cw", replace;

/* compute quantiles of income distribution for each tract */
g prc_5000  = falty59/total_families_90;
g prc_10000 = (falty59+falty109)/total_families_90;
g prc_12500 = (falty59+falty109+falt139)/total_families_90;
g prc_15000 = (falty59+falty109+falt139+falt159)/total_families_90;
g prc_17500 = (falty59+falty109+falt139+falt159+falt189)/total_families_90;
g prc_20000 = (falty59+falty109+falt139+falt159+falt189+falt209)/total_families_90;
g prc_22500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239)/total_families_90;
g prc_25000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259)/total_families_90;
g prc_27500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289)/total_families_90;
g prc_30000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309)/total_families_90;
g prc_35000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359)/total_families_90;
g prc_40000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409)/total_families_90;
g prc_50000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499)/total_families_90;
g prc_60000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a)/total_families_90;
g prc_75000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a)/total_families_90;
g prc_100000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009)/total_families_90;
g prc_125000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259)/total_families_90;
g prc_150000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259+falt1509)/total_families_90;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_5000 actQ_5000 MSA geo2000
		refQ_10000 actQ_10000 MSA geo2000 
		refQ_12500 actQ_12500 MSA geo2000 
		refQ_15000 actQ_15000 MSA geo2000 
		refQ_17500 actQ_17500 MSA geo2000 
		refQ_20000 actQ_20000 MSA geo2000 
		refQ_22500 actQ_22500 MSA geo2000 
		refQ_25000 actQ_25000 MSA geo2000 
		refQ_27500 actQ_27500 MSA geo2000 
		refQ_30000 actQ_30000 MSA geo2000 
		refQ_35000 actQ_35000 MSA geo2000 
		refQ_40000 actQ_40000 MSA geo2000 
		refQ_50000 actQ_50000 MSA geo2000 
		refQ_60000 actQ_60000 MSA geo2000 
		refQ_75000 actQ_75000 MSA geo2000 
		refQ_100000 actQ_100000 MSA geo2000 
		refQ_125000 actQ_125000 MSA geo2000 
		refQ_150000 actQ_150000 MSA geo2000, into(refQ actQ MSA geo2000);

save "$WRITE_DATA/stacked_tract_ncdb_1990ot_cw", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily areg actQ refQ if MSA == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if MSA == `l';
			replace r_squared_for_MSAw = e(r2) if MSA == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if MSA == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(MSA);

sort MSA;			
save "$WRITE_DATA/within_tract_ncdb_1990ot_cw", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_1990ot_cw", clear;
		
collapse 	(sum) 
			total_families_90 total_family_income_90 
			total_population_90 total_black_population_90 total_hispanic_population_90
			total_under18_population_90 total_over65_population_90 total_foreign_population_90
			total_25p_population_90
			yrs_sch_25p_00to08_90 yrs_sch_25p_09to12_90 yrs_sch_25p_12_90
			yrs_sch_25p_12to14_90 yrs_sch_25p_14_90 yrs_sch_25p_16_90
			falty59 falty109 falt139 falt159 falt189 falt209 
			falt239 falt259 falt289 falt309 falt359 falt409 
			falt499 falt609a falt759a falt1009 falt1259 falt1509, by(MSA);

/* some basic MSA-level aggregates */
g avg_fam_inc_90 	= total_family_income_90/total_families_90;								
g prc_black_90   	= (total_black_population_90/total_population_90)*100; 
g prc_hispanic_90 	= (total_hispanic_population_90/total_population_90)*100;
g prc_under18_90 	= (total_under18_population_90/total_population_90)*100;	
g prc_over65_90 	= (total_over65_population_90/total_population_90)*100;	
g prc_foreign_90 	= (total_foreign_population_90/total_population_90)*100;	
	
/* compute quantiles of income distribution at the MSA level */
g prc_5000  = falty59/total_families_90;
g prc_10000 = (falty59+falty109)/total_families_90;
g prc_12500 = (falty59+falty109+falt139)/total_families_90;
g prc_15000 = (falty59+falty109+falt139+falt159)/total_families_90;
g prc_17500 = (falty59+falty109+falt139+falt159+falt189)/total_families_90;
g prc_20000 = (falty59+falty109+falt139+falt159+falt189+falt209)/total_families_90;
g prc_22500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239)/total_families_90;
g prc_25000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259)/total_families_90;
g prc_27500 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289)/total_families_90;
g prc_30000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309)/total_families_90;
g prc_35000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359)/total_families_90;
g prc_40000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409)/total_families_90;
g prc_50000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499)/total_families_90;
g prc_60000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a)/total_families_90;
g prc_75000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a)/total_families_90;
g prc_100000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009)/total_families_90;
g prc_125000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259)/total_families_90;
g prc_150000 = (falty59+falty109+falt139+falt159+falt189+falt209+falt239+falt259+falt289+falt309+falt359+falt409+falt499+falt609a+falt759a+falt1009+falt1259+falt1509)/total_families_90;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_5000 = invnormal(prc_5000) if prc_5000>0 & prc_5000<1;
g actQ_5000 = log(5000);

g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_12500 = invnormal(prc_12500) if prc_12500>0 & prc_12500<1;
g actQ_12500 = log(12500);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_17500 = invnormal(prc_17500) if prc_17500>0 & prc_17500<1;
g actQ_17500 = log(17500);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_22500 = invnormal(prc_22500) if prc_22500>0 & prc_22500<1;
g actQ_22500 = log(22500);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_27500 = invnormal(prc_27500) if prc_27500>0 & prc_27500<1;
g actQ_27500 = log(27500);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

sort MSA;
save "$WRITE_DATA/msa_level_ncdb_1990ot_cw", replace;	

stack 	refQ_5000 actQ_5000 MSA
		refQ_10000 actQ_10000 MSA 
		refQ_12500 actQ_12500 MSA 
		refQ_15000 actQ_15000 MSA 
		refQ_17500 actQ_17500 MSA 
		refQ_20000 actQ_20000 MSA 
		refQ_22500 actQ_22500 MSA 
		refQ_25000 actQ_25000 MSA 
		refQ_27500 actQ_27500 MSA 
		refQ_30000 actQ_30000 MSA 
		refQ_35000 actQ_35000 MSA
		refQ_40000 actQ_40000 MSA 
		refQ_50000 actQ_50000 MSA
		refQ_60000 actQ_60000 MSA 
		refQ_75000 actQ_75000 MSA 
		refQ_100000 actQ_100000 MSA 
		refQ_125000 actQ_125000 MSA 
		refQ_150000 actQ_150000 MSA, into(refQ actQ MSA);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu	 		= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily reg actQ refQ if MSA == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if MSA == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if MSA == `l';	
			replace overall_mu = b[1,2] if MSA == `l';	
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(MSA);		
sort MSA;
save "$WRITE_DATA/msa_sigma_ncdb_1990ot_cw", replace;
	
/* merge all data and create file NCDB 1990 file */	
use "$WRITE_DATA/msa_sigma_ncdb_1990ot_cw", clear;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/within_tract_ncdb_1990ot_cw";
drop _merge;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/msa_level_ncdb_1990ot_cw";
drop _merge;
drop falty59-falt1509 prc_5000-actQ_150000;
g NSI_90 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_90 = overall_sigma;
g mu_t_90 = overall_mu;
g sigma_w_90 = within_tract_sigma;
g r2_t_90 = r_squared_for_MSAt;
g r2_w_90 = r_squared_for_MSAw;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw;
sort MSA;		
save "$WRITE_DATA/msa_ncdb_1990ot_cw", replace;

/* produce some summary statistics */
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 r2_t_90 r2_w_90 if MSA~=.;

erase "$WRITE_DATA/tract_ncdb_1990ot_cw.dta";
erase "$WRITE_DATA/within_tract_ncdb_1990ot_cw.dta";
erase "$WRITE_DATA/msa_level_ncdb_1990ot_cw.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_1990ot_cw.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_1990ot_cw.dta";

/********/
/* 2000 */
/********/

/* read in NCDB extracts (from UC Data Lab CD-ROMS read in April 2012) */
insheet using "$SOURCE_DATA/NCDB_70to00.csv", clear comma names;

/* some basic census region indicators */
g region_00 = region;
g division_00 = divis;

/* create some basic-tract level aggregates */
g total_population_00 = trctpop0;
g total_white_population_00 = shrwht0n;
g total_black_population_00 = shrblk0n;
g total_hispanic_population_00 = shrhsp0n;
g total_under18_population_00 = child0n;
g total_over65_population_00 = old0n;
g total_foreign_population_00 = forborn0;

g total_families_00 = favinc0d;
g total_family_income_00 = favinc0n;
g average_family_income_00 = favinc0;
g median_family_income_00 = mdfamy0;

g total_25p_population_00  	= educpp0;
g yrs_sch_25p_00to08_00 	= educ80;
g yrs_sch_25p_09to12_00 	= educ110;
g yrs_sch_25p_12_00 		= educ120;
g yrs_sch_25p_12to14_00 	= educ150;
g yrs_sch_25p_14_00 		= educa0;
g yrs_sch_25p_16_00 		= educ160;	

g dropout_16_19_00          = hsdrop0n;
g total_16_19_00			= hsdrop0d;	

save "$WRITE_DATA/tract_ncdb_2000ot_cw", replace;

/*******************************************/
/* merge with 1981 to 1999 MSA concordance */
/*******************************************/

/***************************/
/* first merge on MSAPMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort MSAPMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_2000ot_cw", clear;
capture drop MSAPMA99;
capture g MSAPMA99 = msapma99;
sort MSAPMA99;
merge m:m MSAPMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab MSAPMA99 if _merge==1;
tab MSAPMA99 if _merge==2;
drop if _merge==2;
drop _merge;
save "$WRITE_DATA/tract_ncdb_2000ot_cw", replace;

/***************************/
/* second merge on NECMA99 */
/***************************/
use "$WRITE_DATA/MSA81To99Concordance", clear;
sort NECMA99;
save "$WRITE_DATA/MSA81To99Concordance", replace;

/* merge concordance with NCDB tract level data*/
use "$WRITE_DATA/tract_ncdb_2000ot_cw", clear;
capture drop NECMA99;
capture g NECMA99 = necma99;
sort NECMA99;
merge m:m NECMA99 using "$WRITE_DATA/MSA81To99Concordance";
tab _merge;
tab NECMA99 if _merge==1;
tab NECMA99 if _merge==2;
drop if _merge==2;
drop _merge;

capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
drop scsa81 MSAPMA99 msacma99 pmsa99 NECMA99 placename99 msapma99m msacma99m pmsa99m necma99m;
save "$WRITE_DATA/tract_ncdb_2000ot_cw", replace;

/* compute quantiles of income distribution for each tract */
g prc_10000  = fay0100/total_families_00;
g prc_15000  = (fay0100+fay0150)/total_families_00;
g prc_20000  = (fay0100+fay0150+fay0200)/total_families_00;
g prc_25000  = (fay0100+fay0150+fay0200+fay0250)/total_families_00;
g prc_30000  = (fay0100+fay0150+fay0200+fay0250+fay0300)/total_families_00;
g prc_35000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350)/total_families_00;
g prc_40000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400)/total_families_00;
g prc_45000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450)/total_families_00;
g prc_50000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500)/total_families_00;
g prc_60000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600)/total_families_00;
g prc_75000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750)/total_families_00;
g prc_100000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000)/total_families_00;
g prc_125000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250)/total_families_00;
g prc_150000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500)/total_families_00;
g prc_200000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500+fay02000)/total_families_00;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_45000 = invnormal(prc_45000) if prc_45000>0 & prc_45000<1;
g actQ_45000 = log(45000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

g refQ_200000 = invnormal(prc_200000) if prc_200000>0 & prc_200000<1;
g actQ_200000 = log(200000);

/* stack data in order to implement regression estimator described in appendix */
stack 	refQ_10000 actQ_10000 MSA geo2000
		refQ_15000 actQ_15000 MSA geo2000 
		refQ_20000 actQ_20000 MSA geo2000 
		refQ_25000 actQ_25000 MSA geo2000 
		refQ_30000 actQ_30000 MSA geo2000 
		refQ_35000 actQ_35000 MSA geo2000 
		refQ_40000 actQ_40000 MSA geo2000
		refQ_45000 actQ_45000 MSA geo2000  
		refQ_50000 actQ_50000 MSA geo2000 
		refQ_60000 actQ_60000 MSA geo2000 
		refQ_75000 actQ_75000 MSA geo2000 
		refQ_100000 actQ_100000 MSA geo2000 
		refQ_125000 actQ_125000 MSA geo2000 
		refQ_150000 actQ_150000 MSA geo2000
		refQ_200000 actQ_200000 MSA geo2000, into(refQ actQ MSA geo2000);

save "$WRITE_DATA/stacked_tract_ncdb_2000ot_cw", replace;		
		
/* for each MSA compute the within-neighborhood standard deviation of log income */
g num_tracts_in_MSA 	= .;
g r_squared_for_MSAw 	= .;
g within_tract_sigma 	= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily areg actQ refQ if MSA == `l', absorb(geo2000) vce(cluster geo2000);
		if _rc==0 {;
			replace num_tracts_in_MSA = e(N_clust) if MSA == `l';
			replace r_squared_for_MSAw = e(r2) if MSA == `l';
			matrix b = e(b);
			replace within_tract_sigma = b[1,1] if MSA == `l';	
		};	
};

/* collapse data down to MSA level and save results */
collapse 	(mean) 
			num_tracts_in_MSA r_squared_for_MSAw within_tract_sigma, by(MSA);

sort MSA;			
save "$WRITE_DATA/within_tract_ncdb_2000ot_cw", replace;		

/* reload tract-level data and aggregate-up to the MSA level */	
use "$WRITE_DATA/tract_ncdb_2000ot_cw", clear;
		
collapse 	(sum) 
			total_families_00 total_family_income_00 
			total_population_00 total_black_population_00 total_hispanic_population_00
			total_under18_population_00 total_over65_population_00 total_foreign_population_00
			total_25p_population_00
			yrs_sch_25p_00to08_00 yrs_sch_25p_09to12_00 yrs_sch_25p_12_00
			yrs_sch_25p_12to14_00 yrs_sch_25p_14_00 yrs_sch_25p_16_00
			fay0100 fay0150 fay0200 fay0250 fay0300 fay0350 fay0400 fay0450
			fay0500 fay0600 fay0750 fay01000 fay01250 fay01500 fay02000, by(MSA);

/* some basic MSA-level aggregates */
g avg_fam_inc_00 	= total_family_income_00/total_families_00;					
g prc_black_00   	= (total_black_population_00/total_population_00)*100; 
g prc_hispanic_00 	= (total_hispanic_population_00/total_population_00)*100;
g prc_under18_00 	= (total_under18_population_00/total_population_00)*100;	
g prc_over65_00 	= (total_over65_population_00/total_population_00)*100;	
g prc_foreign_00 	= (total_foreign_population_00/total_population_00)*100;		

/* compute quantiles of income distribution at the MSA level */
g prc_10000  = fay0100/total_families_00;
g prc_15000  = (fay0100+fay0150)/total_families_00;
g prc_20000  = (fay0100+fay0150+fay0200)/total_families_00;
g prc_25000  = (fay0100+fay0150+fay0200+fay0250)/total_families_00;
g prc_30000  = (fay0100+fay0150+fay0200+fay0250+fay0300)/total_families_00;
g prc_35000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350)/total_families_00;
g prc_40000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400)/total_families_00;
g prc_45000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450)/total_families_00;
g prc_50000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500)/total_families_00;
g prc_60000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600)/total_families_00;
g prc_75000  = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750)/total_families_00;
g prc_100000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000)/total_families_00;
g prc_125000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250)/total_families_00;
g prc_150000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500)/total_families_00;
g prc_200000 = (fay0100+fay0150+fay0200+fay0250+fay0300+fay0350+fay0400+fay0450+fay0500+fay0600+fay0750+fay01000+fay01250+fay01500+fay02000)/total_families_00;

/* Compute corresponding reference quantiles of a standard normal random variable */
g refQ_10000 = invnormal(prc_10000) if prc_10000>0 & prc_10000<1;
g actQ_10000 = log(10000);

g refQ_15000 = invnormal(prc_15000) if prc_15000>0 & prc_15000<1;
g actQ_15000 = log(15000);

g refQ_20000 = invnormal(prc_20000) if prc_20000>0 & prc_20000<1;
g actQ_20000 = log(20000);

g refQ_25000 = invnormal(prc_25000) if prc_25000>0 & prc_25000<1;
g actQ_25000 = log(25000);

g refQ_30000 = invnormal(prc_30000) if prc_30000>0 & prc_30000<1;
g actQ_30000 = log(30000);

g refQ_35000 = invnormal(prc_35000) if prc_35000>0 & prc_35000<1;
g actQ_35000 = log(35000);

g refQ_40000 = invnormal(prc_40000) if prc_40000>0 & prc_40000<1;
g actQ_40000 = log(40000);

g refQ_45000 = invnormal(prc_45000) if prc_45000>0 & prc_45000<1;
g actQ_45000 = log(45000);

g refQ_50000 = invnormal(prc_50000) if prc_50000>0 & prc_50000<1;
g actQ_50000 = log(50000);

g refQ_60000 = invnormal(prc_60000) if prc_60000>0 & prc_60000<1;
g actQ_60000 = log(60000);

g refQ_75000 = invnormal(prc_75000) if prc_75000>0 & prc_75000<1;
g actQ_75000 = log(75000);

g refQ_100000 = invnormal(prc_100000) if prc_100000>0 & prc_100000<1;
g actQ_100000 = log(100000);

g refQ_125000 = invnormal(prc_125000) if prc_125000>0 & prc_125000<1;
g actQ_125000 = log(125000);

g refQ_150000 = invnormal(prc_150000) if prc_150000>0 & prc_150000<1;
g actQ_150000 = log(150000);

g refQ_200000 = invnormal(prc_200000) if prc_200000>0 & prc_200000<1;
g actQ_200000 = log(200000);

sort MSA;
save "$WRITE_DATA/msa_level_ncdb_2000ot_cw", replace;	

stack 	refQ_10000 actQ_10000 MSA 
		refQ_15000 actQ_15000 MSA 
		refQ_20000 actQ_20000 MSA 
		refQ_25000 actQ_25000 MSA 
		refQ_30000 actQ_30000 MSA 
		refQ_35000 actQ_35000 MSA
		refQ_40000 actQ_40000 MSA
		refQ_45000 actQ_45000 MSA 
		refQ_50000 actQ_50000 MSA
		refQ_60000 actQ_60000 MSA 
		refQ_75000 actQ_75000 MSA 
		refQ_100000 actQ_100000 MSA 
		refQ_125000 actQ_125000 MSA 
		refQ_150000 actQ_150000 MSA
		refQ_200000 actQ_200000 MSA, into(refQ actQ MSA);

/* for each MSA compute the overall standard deviation of log income */		
g r_squared_for_MSAt 	= .;
g overall_sigma 		= .;
g overall_mu 			= .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily reg actQ refQ if MSA == `l', r;
		if _rc==0 {;
			replace r_squared_for_MSAt = e(r2) if MSA == `l';
			matrix b = e(b);
			replace overall_sigma = b[1,1] if MSA == `l';	
			replace overall_mu = b[1,2] if MSA == `l';
		};	
};

/* save MSA-level family income standard deviation estimates */
collapse (mean)	r_squared_for_MSAt overall_sigma overall_mu, by(MSA);		
sort MSA;
save "$WRITE_DATA/msa_sigma_ncdb_2000ot_cw", replace;

/* merge all data and create file NCDB 2000 file */	
use "$WRITE_DATA/msa_sigma_ncdb_2000ot_cw", clear;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/within_tract_ncdb_2000ot_cw";
drop _merge;
sort MSA;	
merge 1:1 MSA using "$WRITE_DATA/msa_level_ncdb_2000ot_cw";
drop _merge;
drop fay0100-fay02000 prc_10000-actQ_200000;
g NSI_00 = 1 - (within_tract_sigma/overall_sigma)^2;
g sigma_t_00 = overall_sigma;
g mu_t_00 = overall_mu;
g sigma_w_00 = within_tract_sigma;
g r2_t_00 = r_squared_for_MSAt;
g r2_w_00 = r_squared_for_MSAw;
drop overall_sigma overall_mu within_tract_sigma r_squared_for_MSAt r_squared_for_MSAw;
sort MSA;		
save "$WRITE_DATA/msa_ncdb_2000ot_cw", replace;

/* produce some summary statistics */
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 r2_t_00 r2_w_00 if MSA~=.;

erase "$WRITE_DATA/tract_ncdb_2000ot_cw.dta";
erase "$WRITE_DATA/within_tract_ncdb_2000ot_cw.dta";
erase "$WRITE_DATA/msa_level_ncdb_2000ot_cw.dta";
erase "$WRITE_DATA/msa_sigma_ncdb_2000ot_cw.dta";
erase "$WRITE_DATA/stacked_tract_ncdb_2000ot_cw.dta";

/**************************************************************************************************/
/* MERGE 1970 to 2000 FILES INTO A SINGLE COMMON BOUNDARIES DATASET                               */
/**************************************************************************************************/
	
use "$WRITE_DATA/msa_ncdb_1970ot_cw", clear;
sort MSA;
merge 1:1 MSA using "$WRITE_DATA/msa_ncdb_1980ot_cw";
drop _merge;
sort MSA;
merge 1:1 MSA using "$WRITE_DATA/msa_ncdb_1990ot_cw";
drop _merge;
sort MSA;
merge 1:1 MSA using "$WRITE_DATA/msa_ncdb_2000ot_cw";
drop _merge;

g prc_dropout25_70 = 100*(yrs_sch_25p_00to08_70+yrs_sch_25p_09to12_70)/total_25p_population_70;
g prc_dropout25_80 = 100*(yrs_sch_25p_00to08_80+yrs_sch_25p_09to12_80)/total_25p_population_80;
g prc_dropout25_90 = 100*(yrs_sch_25p_00to08_90+yrs_sch_25p_09to12_90)/total_25p_population_90;
g prc_dropout25_00 = 100*(yrs_sch_25p_00to08_00+yrs_sch_25p_09to12_00)/total_25p_population_00;

g prc_college25_70 = 100*(yrs_sch_25p_16_70)/total_25p_population_70;
g prc_college25_80 = 100*(yrs_sch_25p_16_80)/total_25p_population_80;
g prc_college25_90 = 100*(yrs_sch_25p_16_90)/total_25p_population_90;
g prc_college25_00 = 100*(yrs_sch_25p_16_00)/total_25p_population_00;

drop 	num_tracts_in_MSA 
		total_families_70 total_family_income_70 total_black_population_70 total_hispanic_population_70 
		total_under18_population_70 total_over65_population_70 total_foreign_population_70
		total_25p_population_70 yrs_sch_25p_00to08_70 yrs_sch_25p_09to12_70 yrs_sch_25p_12_70 yrs_sch_25p_12to16_70 yrs_sch_25p_16_70 
		total_families_80 total_family_income_80 total_black_population_80 total_hispanic_population_80 
		total_under18_population_80 total_over65_population_80 total_foreign_population_80
		total_25p_population_80 yrs_sch_25p_00to08_80 yrs_sch_25p_09to12_80 yrs_sch_25p_12_80 yrs_sch_25p_12to16_80 yrs_sch_25p_16_80 
		total_families_90 total_family_income_90 total_black_population_90 total_hispanic_population_90 
		total_under18_population_90 total_over65_population_90 total_foreign_population_90
		total_25p_population_90 yrs_sch_25p_00to08_90 yrs_sch_25p_09to12_90 yrs_sch_25p_12_90 yrs_sch_25p_12to14_90 yrs_sch_25p_14_90 yrs_sch_25p_16_90 
		total_families_00 total_family_income_00 total_black_population_00 total_hispanic_population_00 
		total_under18_population_00 total_over65_population_00 total_foreign_population_00
		total_25p_population_00 yrs_sch_25p_00to08_00 yrs_sch_25p_09to12_00 yrs_sch_25p_12_00 yrs_sch_25p_12to14_00 yrs_sch_25p_14_00 yrs_sch_25p_16_00;

g sigma_b_70 = sqrt(sigma_t_70^2 - sigma_w_70^2);
g sigma_b_80 = sqrt(sigma_t_80^2 - sigma_w_80^2);
g sigma_b_90 = sqrt(sigma_t_90^2 - sigma_w_90^2);
g sigma_b_00 = sqrt(sigma_t_00^2 - sigma_w_00^2);
g ALL_YEARS = (sigma_b_70~=.)*(sigma_b_80~=.)*(sigma_b_90~=.)*(sigma_b_00~=.);

log using "$WRITE_DATA/summary_stats_ncdb_1970to2000cw", replace;
log on;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & total_population_70>250000;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & total_population_70>250000;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & total_population_70>250000;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & total_population_70>250000;

sum NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 r2_t_70 r2_w_70 if ALL_YEARS==1 & total_population_70<=250000;
sum NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 r2_t_80 r2_w_80 if ALL_YEARS==1 & total_population_70<=250000;
sum NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 r2_t_90 r2_w_90 if ALL_YEARS==1 & total_population_70<=250000;
sum NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 r2_t_00 r2_w_00 if ALL_YEARS==1 & total_population_70<=250000;

log off;
save "$WRITE_DATA/msapma_ncdb_1970to2000cw", replace;	

keep if ALL_YEARS==1;
stack NSI_70 mu_t_70 sigma_t_70 sigma_w_70 sigma_b_70 total_population_70 total_population_70 avg_fam_inc_70 prc_dropout25_70 prc_college25_70 prc_black_70 prc_hispanic_70 MSA
	  NSI_80 mu_t_80 sigma_t_80 sigma_w_80 sigma_b_80 total_population_70 total_population_80 avg_fam_inc_80 prc_dropout25_80 prc_college25_80 prc_black_80 prc_hispanic_80 MSA
	  NSI_90 mu_t_90 sigma_t_90 sigma_w_90 sigma_b_90 total_population_70 total_population_90 avg_fam_inc_90 prc_dropout25_90 prc_college25_90 prc_black_90 prc_hispanic_90 MSA
	  NSI_00 mu_t_00 sigma_t_00 sigma_w_00 sigma_b_00 total_population_70 total_population_00 avg_fam_inc_00 prc_dropout25_00 prc_college25_00 prc_black_00 prc_hispanic_00 MSA,
	  into(NSI mu_t sigma sigma_b sigma_w pop70 pop avg_fam_inc prc_dropout25 prc_college25 prc_black prc_hispanic MSA);
	  
rename _stack year;

replace year = 1970 if year==1;
replace year = 1980 if year==2;
replace year = 1990 if year==3;
replace year = 2000 if year==4;

g D70 = (year==1970);
g D80 = (year==1980);
g D90 = (year==1990);
g D00 = (year==2000);	 

save "$WRITE_DATA/msapma_ncdb_1970to2000cw_stacked", replace;	

log on;
reg NSI D70 D80 D90 D00, nocons cluster(MSA);
matrix b_all = e(b)';
reg NSI D70 D80 D90 D00 if pop70<=250000, nocons cluster(MSA);
matrix b_small = e(b)';
reg NSI D70 D80 D90 D00 if pop70>250000, nocons cluster(MSA);
matrix b_large = e(b)';
log off;

matrix input years = (1970\1980\1990\2000);
svmat b_all;
svmat b_small;
svmat b_large;
svmat years;

scatter b_all1 b_small1 b_large1 years1, msymbol(i i i) c(l l l) clpattern(l - -.) lw(medium medium medium) lc(red red blue) 		xlabel(1970 1980 1990 2000)		ylabel(0.1 0.125 0.15 0.175 0.2 0.225 0.25)		yscale(range(0.1 0.25))
		xscale(range(1970 2000))		title("")		subtitle("Residential income stratification: 1970 to 2000")    	xtitle("Year")
    	ytitle("Neighborhood Sorting Index")
    	legend(lab(1 "All MSAs") lab(2 "Small MSAs") lab(3 "Large MSAs") cols(1) pos(5) ring(0));
    			
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_TRENDS_1970_to_2000cw.gph, replace;

scatter NSI sigma if year==2000, msymbol(o) 
		xlabel(0.6 0.8 1.0 1.2) 
		ylabel(0 0.1 0.2 0.3 0.4) 
		yscale(range(0 0.4)) 
		xscale(range(0.6 1.2)) 
		title("") 
		subtitle("Inequality & residential income stratification across MSAs: 2000") 
		xtitle("Standard deviation of log income") 
		ytitle("Neighborhood Sorting Index");
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/INEQ_vs_NSI_2000cw.gph, replace;		

log close;





