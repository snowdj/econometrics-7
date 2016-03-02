/***************************************************************************************************/
/* Intergenerational Mobility							   		         						   */
/* Bryan S. Graham, UC - BERKELEY									         			   		   */
/* Patrick Sharkey, NYU												         			   		   */
/* bgraham@econ.berkeley.edu       						         		   			   			   */
/* Oct 2011                              								         				   */
/***************************************************************************************************/

/* use a semicolon as the command delimiter */
#delimit ;

clear matrix;
clear mata;
clear;

set matsize 8000;
set memory 1000m;
set maxvar 10000;

/***************************************************************************************************/
/* "Panel" NLSY Analysis -- This Do file is the source of the main findings in the Pew report      */
/***************************************************************************************************/

global WRITE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Created_Data";
global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";
global GEOCODE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Geocodes";

/* load FGLS stata/mata program used below */
do "$DO_FILES/TS_FGLS.ado";
do "$DO_FILES/TS_PANEL_FGLS.ado";

/* read in MSA Names file created by the Pew_NLSY79_GeoCodes_1 do file */
use "$WRITE_DATA/PewNLSY79_MSANames", clear;

/* export data to comma delimited spreadsheet*/
outsheet SMSA81 SCSA81 PlaceName using "$WRITE_DATA/PewNLSY79_MSAName.out", comma replace;

/* read in MSA Names file creatde by the Pew_NLSY97_GeoCodes_1 do file */
use "$WRITE_DATA/PewNLSY97_PlaceNames", clear;

/* export data to comma delimited spreadsheet*/
outsheet MSAPMA99 MSACMA99 PMSA99 NECMA99 PlaceName using "$WRITE_DATA/PewNLSY97_MSAName.out", comma replace;

/*********************************************/
/* Append the 1979 and 1997 datasets together*/
/*********************************************/

use "$WRITE_DATA/PewNLSY79_Panel", clear;

/* Rename NCDB variables -- these use the 1980 census tracting */
rename NSI_80 NSI_80_ct; /*"ct" stands for contemporaneous tracting*/
rename total_population_80 total_population_80_ct;
rename prc_black_80 prc_black_80_ct;
rename prc_hispanic_80 prc_hispanic_80_ct;
rename prc_under18_80 prc_under18_80_ct;
rename prc_over65_80 prc_over65_80_ct;
rename prc_foreign_80 prc_foreign_80_ct;
rename sigma_t_80 sigma_t_80_ct;

append using "$WRITE_DATA/PewNLSY97_Panel",  generate(cohort);
save "$WRITE_DATA/PewNLSYMergedPanel", replace;

replace D02=0 if cohort==0;
replace D04=0 if cohort==0;
replace D06=0 if cohort==0;
replace D08=0 if cohort==0;

replace D82=0 if cohort==1;
replace D83=0 if cohort==1;
replace D84=0 if cohort==1;
replace D85=0 if cohort==1;
replace D86=0 if cohort==1;
replace D87=0 if cohort==1;
replace D88=0 if cohort==1;
replace D89=0 if cohort==1;
replace D90=0 if cohort==1;
replace D91=0 if cohort==1;
replace D92=0 if cohort==1;
replace D93=0 if cohort==1;
replace D95=0 if cohort==1;
replace D97=0 if cohort==1;
replace D99=0 if cohort==1;
replace D01=0 if cohort==1;

g log_parents_income = log(parents_income);
g log_own_income = log(own_income);

g childs_age   = own_age + (year-1997) - 28 if cohort==1;
replace childs_age   = own_age + (year-1979) - 28 if cohort==0;;
g childs_age_2 = childs_age^2;
g childs_age_3 = childs_age^3;
g childs_age_4 = childs_age^4;

g parents_age_2 = parents_age^2;
g parents_age_3 = parents_age^3;
g parents_age_4 = parents_age^4;

g ca1_X_lpi = childs_age*log_parents_income;
g ca2_X_lpi = childs_age_2*log_parents_income;
g ca3_X_lpi = childs_age_3*log_parents_income;
g ca4_X_lpi = childs_age_4*log_parents_income;

g cohort_X_ca1 = childs_age*cohort;
g cohort_X_ca2 = childs_age_2*cohort;
g cohort_X_ca3 = childs_age_3*cohort;
g cohort_X_ca4 = childs_age_4*cohort;

g cohort_X_pa1 = parents_age*cohort;
g cohort_X_pa2 = parents_age_2*cohort;
g cohort_X_pa3 = parents_age_3*cohort;
g cohort_X_pa4 = parents_age_4*cohort;

g cohort_X_lpi = cohort*log_parents_income;

/* generate merged panel household id */
g t = HHID_79 if cohort==0;
replace t = HHID_97 if cohort==1;
egen HHIDm = group(t cohort);
drop t;

/* generate merged panel respondent id */
g t = PID_79 if cohort==0;
replace t = PID_97 if cohort==1;
egen PIDm = group(t cohort);
drop t;

/* generate merged panel MSA-by-cohort indicator */
g MSAC 		 str8			= "79_00" + string(MSA)  if MSA<100   & cohort==0;
replace MSAC 				= "79_0"  + string(MSA)  if MSA<1000  & cohort==0 & MSAC=="";
replace MSAC 				= "79_"   + string(MSA)  if MSA>=1000 & cohort==0 & MSAC=="";
replace MSAC 				= "97_00" + string(MSA)  if MSA<100   & cohort==1 & MSAC=="";
replace MSAC 				= "97_0"  + string(MSA)  if MSA<1000  & cohort==1 & MSAC=="";
replace MSAC 				= "97_"   + string(MSA)  if MSA>=1000 & cohort==1 & MSAC=="";

g num_hh_in_MSA79 = .;
g num_res_in_MSA79 =.;
g num_obs_in_MSA79 =.;

g num_hh_in_MSA97 = .;
g num_res_in_MSA97 =.;
g num_obs_in_MSA97 =.;

g ige_hat_MSA = .;
g ige_hat_var_MSA = .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily reg log_own_income log_parents_income 
							parents_age parents_age_2 
							childs_age childs_age_2
							D82-D07 if MSA == `l' & cohort==0, cluster(HHID_79) nocons;
		if _rc==0 {;
			replace num_hh_in_MSA79 = e(N_clust) if MSA == `l';
			matrix b = e(b);
			replace ige_hat_MSA = b[1,1] if MSA == `l' & cohort==0;
			matrix V = e(V);
			replace ige_hat_var_MSA = V[1,1] if MSA == `l' & cohort==0;
			capture reg log_own_income log_parents_income 
						parents_age parents_age_2 
						childs_age childs_age_2
						D82-D07 if MSA == `l' & cohort==0, cluster(PID_79) nocons;	
			replace num_res_in_MSA79 = e(N_clust) if MSA == `l';
			replace num_obs_in_MSA79 = e(N) if MSA == `l';					
		};	

		capture noisily reg log_own_income log_parents_income 
							parents_age parents_age_2 
							childs_age childs_age_2
							D02 D03 D04 D05 D06 D07 D08 if MSA == `l' & cohort==1, cluster(HHID_97) nocons;
		if _rc==0 {;
			replace num_hh_in_MSA97 = e(N_clust) if MSA == `l';
			matrix b = e(b);
			replace ige_hat_MSA = b[1,1] if MSA == `l' & cohort==1;
			matrix V = e(V);
			replace ige_hat_var_MSA = V[1,1] if MSA == `l' & cohort==1;
			capture reg log_own_income log_parents_income 
						parents_age parents_age_2 
						childs_age childs_age_2
						D02 D03 D04 D05 D06 D07 D08 if MSA == `l' & cohort==1, cluster(PID_97) nocons;	
			replace num_res_in_MSA97 = e(N_clust) if MSA == `l';
			replace num_obs_in_MSA97 = e(N) if MSA == `l';					
		};	
};

g Greater25In79p97 	=  1 if num_hh_in_MSA79>=25 & num_hh_in_MSA79~=. & num_hh_in_MSA97>=25 & num_hh_in_MSA97~=.;
replace Greater25In79p97 = 0 if Greater25In79p97==.;
g Greater25In79		=   1 if num_hh_in_MSA79>=25 & num_hh_in_MSA79~=.;
replace Greater25In79 = 0 if Greater25In79	==.;
g Greater25In97		=   1 if num_hh_in_MSA97>=25 & num_hh_in_MSA97~=.;
replace Greater25In97 = 0 if Greater25In97	==.;

sort MSA;
save "$WRITE_DATA/PewNLSYMergedPanel", replace;
sort MSA;
save "$WRITE_DATA/PewNLSYMergedPanel", replace;

/************************************************************************************************/
/* MERGE WITH NCDB DATA (Concordance MSAs with 1999 census tracts)                              */
/************************************************************************************************/

use "$WRITE_DATA/msapma_ncdb_1970to2000cw", clear;	
sort MSA;
save "$WRITE_DATA/msapma_ncdb_1970to2000cw", replace;	
use "$WRITE_DATA/PewNLSYMergedPanel", replace;
sort MSA;
merge m:1 MSA using "$WRITE_DATA/msapma_ncdb_1970to2000cw", update replace;
tab MSA if _merge==1;
tab MSA if _merge==2;
drop if _merge==2;
drop _merge;
save "$WRITE_DATA/PewNLSYMergedPanel", replace;

/************************************************************************************************/
/* GET PLACEMAME INFORMATION                                                                    */
/************************************************************************************************/

/* import the 1979-to-1997 MSA concordance */
insheet using "$GEOCODE_DATA/MSA81To99Concordance.csv", comma clear;
drop if msapma99m==. & necma99m==.;
capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
rename placename_msa PlaceName_MSA;
keep MSA PlaceName_MSA;
drop if MSA==.;
collapse MSA, by(PlaceName_MSA);
sort MSA;
save "$WRITE_DATA/MSA81To99Concordance_temp.dta", replace;

use "$WRITE_DATA/PewNLSYMergedPanel", clear;
sort MSA;
merge m:1 MSA using "$WRITE_DATA/MSA81To99Concordance_temp.dta";
tab MSA if _merge==1, missing;
tab MSA if _merge==2, missing;
drop _merge;
save "$WRITE_DATA/PewNLSYMergedPanel", replace;
erase "$WRITE_DATA/MSA81To99Concordance_temp.dta";

/*************************************************************************************************/
/* BASIC TWO STEP ANALYSIS                                                                       */
/*************************************************************************************************/

/* attach the appropriate NSI measure and other MSA characteristics to each unit */
/* Do this using the 1999 "over time" tracting as well as contemporaneous tracts */
g NSI = NSI_80 if cohort==0;
replace NSI = NSI_00 if cohort==1;
g NSI_ct = NSI_80_ct if cohort==0;
replace NSI_ct = NSI_00 if cohort==1;

g prc_black = prc_black_80 if cohort==0;
replace prc_black = prc_black_00 if cohort==1;
g prc_black_ct = prc_black_80_ct if cohort==0;
replace prc_black_ct = prc_black_00 if cohort==1;

g prc_hispanic = prc_hispanic_80 if cohort==0;
replace prc_hispanic = prc_hispanic_00 if cohort==1;
g prc_hispanic_ct = prc_hispanic_80_ct if cohort==0;
replace prc_hispanic_ct = prc_hispanic_00 if cohort==1;

g prc_under18 = prc_under18_80 if cohort==0;
replace prc_under18 = prc_under18_00 if cohort==1;
g prc_under18_ct = prc_under18_80_ct if cohort==0;
replace prc_under18_ct = prc_under18_00 if cohort==1;

g prc_over65 = prc_over65_80 if cohort==0;
replace prc_over65 = prc_over65_00 if cohort==1;
g prc_over65_ct = prc_over65_80_ct if cohort==0;
replace prc_over65_ct = prc_over65_00 if cohort==1;

g prc_foreign = prc_foreign_80 if cohort==0;
replace prc_foreign = prc_foreign_00 if cohort==1;
g prc_foreign_ct = prc_foreign_80_ct if cohort==0;
replace prc_foreign_ct = prc_foreign_00 if cohort==1;

g log_population = log(total_population_80) if cohort==0;
replace log_population = log(total_population_00) if cohort==1;
g log_population_ct = log(total_population_80_ct) if cohort==0;
replace log_population_ct = log(total_population_00) if cohort==1;

g population = (total_population_80) if cohort==0;
replace population = (total_population_00) if cohort==1;
g population_ct = (total_population_80_ct) if cohort==0;
replace population_ct = (total_population_00) if cohort==1;

g sigma_t  = (sigma_t_80) if cohort==0;
replace sigma_t  = (sigma_t_00) if cohort==1;
g sigma_t_ct  = (sigma_t_80_ct) if cohort==0;
replace sigma_t_ct  = (sigma_t_00) if cohort==1;

keep if (Greater25In79==1 & cohort==0) | (Greater25In97==1 & cohort==1);
keep if total_population_80>=100000;

collapse (mean) NSI NSI_ct MSA Greater25In79p97 ige_hat_MSA ige_hat_var_MSA
 				prc_black prc_hispanic prc_under18 prc_over65 prc_foreign population log_population	sigma_t 
 				prc_black_ct prc_hispanic_ct prc_under18_ct prc_over65_ct prc_foreign_ct population_ct log_population_ct sigma_t_ct 
				cohort num_hh_in_MSA79 num_hh_in_MSA97 num_res_in_MSA79 num_res_in_MSA97 num_obs_in_MSA79 num_obs_in_MSA97
				NORTH_EAST NORTH_CENTRAL SOUTH WEST
				NSI_80 total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80
				NSI_80_ct total_population_80_ct prc_black_80_ct prc_hispanic_80_ct prc_under18_80_ct prc_over65_80_ct prc_foreign_80_ct sigma_t_80_ct
				NSI_00 total_population_00 prc_black_00 prc_hispanic_00 prc_under18_00 prc_over65_00 prc_foreign_00 sigma_t_00
				, by(MSAC PlaceName_MSA);		
				
g log_pop_80 	= log(total_population_80);
g log_pop_80_ct = log(total_population_80_ct);
g log_pop_00 	= log(total_population_00);

log using "$WRITE_DATA/PewMobilityPanelStataOutput", replace;
log on;
/* correlations between two 1980 NSI measures (contemporaneous tracts versus "over time" tracks) */
corr NSI_80 NSI_80_ct;
log off;

/*********************************************/
/* Trim outliers                             */
/*********************************************/

/* trim top and bottom 5 percent of ige estimates from each cohort */
/* top/bottom 3 for NLSY79 cohort and top/bottom 4 for NLSY97 cohort */
bys cohort: egen ige_rank = rank(ige_hat_MSA);
g trim_sample = (ige_rank>3 & ige_rank<51)*(1-cohort) + (ige_rank>4 & ige_rank<68)*cohort;

bys Greater25In79p97 MSA: egen t = sum(trim_sample);
g Greater25In79p97_trim_sample = (t==2);

/*************************************************/
/* Summary statistics on sample size etc.        */
/*************************************************/

log on;
sum num_hh_in_MSA79 num_res_in_MSA79 num_obs_in_MSA79 if cohort==0;
sum num_hh_in_MSA79 num_res_in_MSA79 num_obs_in_MSA79 if cohort==0 & trim_sample==1;

sum num_hh_in_MSA97 num_res_in_MSA97 num_obs_in_MSA97 if cohort==1;
sum num_hh_in_MSA97 num_res_in_MSA97 num_obs_in_MSA97 if cohort==1 & trim_sample==1;

/*********************************************/
/* results based on unbalanced panel of MSAs */
/*********************************************/

/* Compute population weight averages of IGE for each cohort */
/* trimmed sample */
reg ige_hat_MSA [aw=population] if cohort==0 & trim_sample==1, r;
reg ige_hat_MSA [aw=population] if cohort==1 & trim_sample==1, r;
reg ige_hat_MSA cohort [aw=population] if trim_sample==1, cluster(MSA);

/* untrimmed sample */
reg ige_hat_MSA [aw=population] if cohort==0 , r;
reg ige_hat_MSA [aw=population] if cohort==1 , r;
reg ige_hat_MSA cohort [aw=population] , cluster(MSA);

/* formally test for constancy of IGE across MSAs */
g ige_hat_se_MSA = sqrt(ige_hat_var_MSA);
g cons = 1;

/* trimmed sample */
vwls ige_hat_MSA cons if cohort==0 & trim_sample==1, sd(ige_hat_se_MSA) nocons;
vwls ige_hat_MSA cons if cohort==1 & trim_sample==1, sd(ige_hat_se_MSA) nocons;

/* untrimmed sample */
vwls ige_hat_MSA cons if cohort==0, sd(ige_hat_se_MSA) nocons;
vwls ige_hat_MSA cons if cohort==1, sd(ige_hat_se_MSA) nocons;
log off;

save "$WRITE_DATA/PewNLSYMergedPanel", replace;

/****************************************************/
/* Empirical Bayes Ranking Analysis (Laird & Louis) */
/****************************************************/

/* NLSY 1979 Ranking */
drop if cohort==1;
log on;
metareg ige_hat_MSA, wsse(ige_hat_se_MSA) reml tau2test;
log off;
predict ige_eb_hat_MSA, xbu;
predict ige_eb_hat_se_MSA, stdxbu;
sort MSA;
mkmat ige_eb_hat_MSA ige_eb_hat_se_MSA MSA, matrix(EB);
matrix P_jk = J(53,53,0);
matrix R_k = J(53,2,0);

/* calculate posterior expected rank */
forval j = 1 2 to 53 {;
	forval k = 1 2 to 53 {;
		matrix P_jk[`j',`k'] = normal((EB[`k',1]-EB[`j',1])/((EB[`k',2]^2+EB[`j',2]^2)^(1/2)));						
	};
};

matrix P_jk = P_jk - diag(vecdiag(P_jk)) + I(53); 
matrix R_k = P_jk*J(53,1,1);

/* calculate standard deviation of posterior expected rank */
matrix SD_R_k = J(53,1,0);
forval k = 1 2 to 53 {;
	matrix P_jlk = J(53,53,0);
	forval j = 1 2 to 53 {;
		forval l = 1 2 to 53 {;
			if EB[`j',1]<EB[`l',1] {;
 				matrix P_jlk[`j',`l'] = normal((EB[`k',1]-EB[`j',1])/((EB[`k',2]^2+EB[`j',2]^2)^(1/2))) - P_jk[`j',`k']*P_jk[`l',`k'];	
 			};
 			else {;
 				matrix P_jlk[`j',`l'] = normal((EB[`k',1]-EB[`l',1])/((EB[`k',2]^2+EB[`l',2]^2)^(1/2))) - P_jk[`j',`k']*P_jk[`l',`k'];	
 			};	
 		};						
	};
	matrix V_R_k_p1 = hadamard(P_jk,J(53,53,1) - P_jk)*J(53,1,1);
	matrix P_jlk = P_jlk - diag(vecdiag(P_jlk)); 
	mata: st_matrix("V_R_k_p2",2*sum(vech(st_matrix("P_jlk"))));
	matrix SD_R_k[`k',1] = sqrt(V_R_k_p1[`k',1] + V_R_k_p2[1,1]);
};

/* list ranked cities with standard deviations */
matrix EB_RANKS = EB, R_k, SD_R_k;
sort MSA;
svmat EB_RANKS;
rename EB_RANKS1 eb_IGE;
rename EB_RANKS3 eb_MSA;
rename EB_RANKS4 eb_rank;
rename EB_RANKS5 eb_rank_sd;
drop EB_RANKS*;
g RANK_GROUPS = 1 if (eb_rank-eb_rank_sd/3)>53/2;
replace RANK_GROUPS = 3 if (eb_rank+eb_rank_sd/3)<53/2; 
replace RANK_GROUPS = 2 if (eb_rank+eb_rank_sd/3)>=53/2 & (eb_rank-eb_rank_sd/3)<=53/2; 
sort RANK_GROUPS eb_rank;

log on;
list PlaceName_MSA eb_rank eb_rank_sd RANK_GROUPS;
bys RANK_GROUPS: sum eb_rank ige_eb_hat_MSA eb_rank_sd;
log off;

/*********************************************/
/* Rank plots for 1979                       */
/*********************************************/

g SelectedPlaceName = PlaceName_MSA 
					  if MSA==1600 | MSA==1920 | MSA==2080 | MSA==2160 |
					     MSA==4480 | MSA==5600 | MSA==7320 | MSA==7360 | MSA==8840;	

twoway (scatter eb_rank ige_eb_hat_MSA [aweight=1/eb_rank_sd^2], msymbol(+))
       (scatter eb_rank ige_eb_hat_MSA , msymbol(none) mlabel(SelectedPlaceName) mlabposition(9)  mlabangle(horizontal) mlabsize(vsmall)), 
		ylabel(5 10 15 20 25 30 35 40 45 50) 
		xlabel(0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55) 
		xscale(range(0.20 0.55))
		yscale(range(1 53)) 
		title("") 
		subtitle("MSA Mobility Rankings: NLSY 1979 Cohort") 
		ytitle("Posterior expected rank") 
		xtitle("Posterior mean IGE") 
		legend(off);
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_1979_Ranks.gph, replace;
graph export $WRITE_DATA/NSI_1979_Ranks.eps, replace;

g t_l = eb_rank - (1/3)*eb_rank_sd;
g t_u = eb_rank + (1/3)*eb_rank_sd;

twoway (scatter eb_rank ige_eb_hat_MSA, msymbol(oh))
	   (scatter t_l ige_eb_hat_MSA, msymbol(+))
	   (scatter t_u ige_eb_hat_MSA, msymbol(+))
       (scatter eb_rank ige_eb_hat_MSA , msymbol(none) mlabel(SelectedPlaceName) mlabposition(9)  mlabangle(horizontal) mlabsize(vsmall)), 
		ylabel(5 10 15 20 25 30 35 40 45 50) 
		xlabel(0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55) 
		xscale(range(0.20 0.55))
		yscale(range(0 60))
		yline(26.5) 
		title("") 
		subtitle("MSA Mobility Rankings: NLSY 1979 Cohort") 
		ytitle("Posterior expected rank") 
		xtitle("Posterior mean IGE") 
		legend(off);
	
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_1979_Ranks_alt.gph, replace;
graph export $WRITE_DATA/NSI_1979_Ranks_alt.eps, replace;

keep eb_MSA eb_IGE eb_rank eb_rank_sd;
sort eb_MSA;
save "$WRITE_DATA/temp_eb_ranks1", replace;	

/* NLSY 1997 Ranking */
use "$WRITE_DATA/PewNLSYMergedPanel", clear;

drop if cohort==0;
log on;
metareg ige_hat_MSA, wsse(ige_hat_se_MSA) reml tau2test;
log off;
predict ige_eb_hat_MSA, xbu;
predict ige_eb_hat_se_MSA, stdxbu;
sort MSA;
mkmat ige_eb_hat_MSA ige_eb_hat_se_MSA MSA, matrix(EB);
matrix P_jk = J(71,71,0);
matrix R_k = J(71,2,0);

/* calculate posterior expected rank */
forval j = 1 2 to 71 {;
	forval k = 1 2 to 71 {;
		matrix P_jk[`j',`k'] = max(0,normal((EB[`k',1]-EB[`j',1])/((EB[`k',2]^2+EB[`j',2]^2)^(1/2))));						
	};
};

matrix P_jk = P_jk - diag(vecdiag(P_jk)) + I(71); 
matrix R_k = P_jk*J(71,1,1);

/* calculate standard deviation of posterior expected rank */
matrix SD_R_k = J(71,1,0);
forval k = 1 2 to 71 {;
	matrix P_jlk = J(71,71,0);
	forval j = 1 2 to 71 {;
		forval l = 1 2 to 71 {;
			if EB[`j',1]<EB[`l',1] {;
 				matrix P_jlk[`j',`l'] = max(0,normal((EB[`k',1]-EB[`j',1])/((EB[`k',2]^2+EB[`j',2]^2)^(1/2)))) - P_jk[`j',`k']*P_jk[`l',`k'];	
 			};
 			else {;
 				matrix P_jlk[`j',`l'] = max(0,normal((EB[`k',1]-EB[`l',1])/((EB[`k',2]^2+EB[`l',2]^2)^(1/2)))) - P_jk[`j',`k']*P_jk[`l',`k'];	
 			};	
 		};						
	};
	matrix V_R_k_p1 = hadamard(P_jk,J(71,71,1) - P_jk)*J(71,1,1);
	matrix P_jlk = P_jlk - diag(vecdiag(P_jlk)); 
	mata: st_matrix("V_R_k_p2",2*sum(vech(st_matrix("P_jlk"))));
	matrix SD_R_k[`k',1] = sqrt(V_R_k_p1[`k',1] + V_R_k_p2[1,1]);
};

/* list ranked cities with standard deviations */
matrix EB_RANKS = EB, R_k, SD_R_k;
sort MSA;
svmat EB_RANKS;
rename EB_RANKS1 eb_IGE;
rename EB_RANKS3 eb_MSA;
rename EB_RANKS4 eb_rank;
rename EB_RANKS5 eb_rank_sd;
drop EB_RANKS*;
g RANK_GROUPS = 1 if (eb_rank-eb_rank_sd/3)>71/2;
replace RANK_GROUPS = 3 if (eb_rank+eb_rank_sd/3)<71/2; 
replace RANK_GROUPS = 2 if (eb_rank+eb_rank_sd/3)>=71/2 & (eb_rank-eb_rank_sd/3)<=71/2; 
sort RANK_GROUPS eb_rank;

log on;
list PlaceName_MSA eb_rank eb_rank_sd RANK_GROUPS;
bys RANK_GROUPS: sum eb_rank ige_eb_hat_MSA eb_rank_sd;
log off;

/*********************************************/
/* Rank plots for 1997                       */
/*********************************************/

g SelectedPlaceName = PlaceName_MSA 
					  if MSA==1600 | MSA==1920 | MSA==2080 | MSA==2160 |
					     MSA==4480 | MSA==5600 | MSA==7320 | MSA==7360 | MSA==8840;	


twoway (scatter eb_rank ige_eb_hat_MSA [aw=1/eb_rank_sd^2], msymbol(+))        
       (scatter eb_rank ige_eb_hat_MSA , msymbol(none) mlabel(SelectedPlaceName) mlabposition(9)  mlabangle(horizontal) mlabsize(tiny)), 
		ylabel(5 10 15 20 25 30 35 40 45 50 55 60 65 70) 
		xlabel(0.15 0.20 0.25 0.30 0.35 0.4) 
		xscale(range(0.15 0.4))
		yscale(range(1 71)) 
		title("") 
		subtitle("MSA Mobility Rankings: NLSY 1997 Cohort") 
		ytitle("Posterior expected rank") 
		xtitle("Posterior mean IGE") 
		legend(off);
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_1997_Ranks.gph, replace;
graph export $WRITE_DATA/NSI_1997_Ranks.eps, replace;

g t_l = eb_rank - (1/3)*eb_rank_sd;
g t_u = eb_rank + (1/3)*eb_rank_sd;

twoway (scatter eb_rank ige_eb_hat_MSA, msymbol(oh))
	   (scatter t_l ige_eb_hat_MSA, msymbol(+))
	   (scatter t_u ige_eb_hat_MSA, msymbol(+))
       (scatter eb_rank ige_eb_hat_MSA , msymbol(none) mlabel(SelectedPlaceName) mlabposition(9)  mlabangle(horizontal) mlabsize(vsmall)), 
		ylabel(5 10 15 20 25 30 35 40 45 50 55 60 65 70) 
		xlabel(0.15 0.20 0.25 0.30 0.35 0.4) 
		xscale(range(0.15 0.4))
		yscale(range(0 80)) 
		yline(35.5) 
		title("") 
		subtitle("MSA Mobility Rankings: NLSY 1997 Cohort") 
		ytitle("Posterior expected rank") 
		xtitle("Posterior mean IGE") 
		legend(off);
	
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_1997_Ranks_alt.gph, replace;
graph export $WRITE_DATA/NSI_1997_Ranks_alt.eps, replace;	

keep eb_MSA eb_IGE eb_rank eb_rank_sd;
rename eb_IGE eb_IGE_97;
rename eb_rank eb_rank_97;
rename eb_rank_sd eb_rank_sd_97;
sort eb_MSA;
save "$WRITE_DATA/temp_eb_ranks2", replace;

merge 1:1 eb_MSA using "$WRITE_DATA/temp_eb_ranks1";

log off;

/*********************************************/
/* Make some plots                           */
/*********************************************/
use "$WRITE_DATA/PewNLSYMergedPanel", clear;

g SelectedPlaceName = PlaceName_MSA 
					  if MSA==1600 | MSA==1920 | 
					     MSA==4480 | MSA==5600 | MSA==7360 ;	

twoway (scatter ige_hat_MSA NSI [aweight=1/ige_hat_var_MSA] if cohort==0 & trim_sample==1, msymbol(circle_hollow))
       (scatter ige_hat_MSA NSI [aweight=1/ige_hat_var_MSA] if cohort==0 & trim_sample==1, msymbol(none) mlabel(SelectedPlaceName) mlabposition(9))
       (lfit ige_hat_MSA NSI [aweight=1/ige_hat_var_MSA] if cohort==0 & trim_sample==1, c(l)), 
		xlabel(0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40) 
		ylabel(0.0 0.2 0.4 0.6 0.8) 
		yscale(range(0 0.8))
		xscale(range(0 0.4)) 
		title("") 
		subtitle("Mobility and residential stratification: 1979 NLSY cohort") 
		xtitle("Neighborhood Sorting Index, 1980") 
		ytitle("Intergenerational elasticity of earnings") 
		legend(off);
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_1979_Scatter.gph, replace;
graph export $WRITE_DATA/NSI_1979_Scatter.eps, replace;	

twoway (scatter ige_hat_MSA NSI [aweight=1/ige_hat_var_MSA] if cohort==1 & trim_sample==1, msymbol(circle_hollow))
       (scatter ige_hat_MSA NSI [aweight=1/ige_hat_var_MSA] if cohort==1 & trim_sample==1, msymbol(none) mlabel(SelectedPlaceName) mlabposition(9))
       (lfit ige_hat_MSA NSI [aweight=1/ige_hat_var_MSA] if cohort==1 & trim_sample==1, c(l)), 
		xlabel(0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40) 
		ylabel(0.0 0.2 0.4 0.6 0.8) 
		yscale(range(0 0.8))
		xscale(range(0 0.4)) 
		title("") 
		subtitle("Mobility and residential stratification: 1997 NLSY cohort") 
		xtitle("Neighborhood Sorting Index, 2000") 
		ytitle("Intergenerational elasticity of earnings") 
		legend(off);
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_1997_Scatter.gph, replace;
graph export $WRITE_DATA/NSI_1997_Scatter.eps, replace;				

log on;

/**********************************************/
/* levels specification                       */
/**********************************************/

/* trimmed sample */
sort trim_sample MSA cohort;

/* efficient panel/GLS procedure (adapted from Hanushek 1974) */
/* using comparable tracting over time */
ts_panel_fgls ige_hat_MSA NSI if trim_sample==1, firststep_var(ige_hat_var_MSA) group_varlist(cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI sigma_t if trim_sample==1, firststep_var(ige_hat_var_MSA) group_varlist(cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI if trim_sample==1, firststep_var(ige_hat_var_MSA) group_varlist(NORTH_CENTRAL SOUTH WEST cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI prc_black prc_hispanic prc_under18 prc_over65 prc_foreign log_population if trim_sample==1 , 
			  firststep_var(ige_hat_var_MSA) group_varlist(NORTH_CENTRAL SOUTH WEST cons) group_id(MSA) cohort_id(cohort);

/* efficient panel/GLS procedure (adapted from Hanushek 1974) */
/* using contemporaneous tracting */
ts_panel_fgls ige_hat_MSA NSI_ct if trim_sample==1, firststep_var(ige_hat_var_MSA) group_varlist(cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI_ct sigma_t_ct if trim_sample==1, firststep_var(ige_hat_var_MSA) group_varlist(cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI_ct if trim_sample==1, firststep_var(ige_hat_var_MSA) group_varlist(NORTH_CENTRAL SOUTH WEST cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI_ct prc_black_ct prc_hispanic_ct prc_under18_ct prc_over65_ct prc_foreign_ct log_population_ct if trim_sample==1 , 
			  firststep_var(ige_hat_var_MSA) group_varlist(NORTH_CENTRAL SOUTH WEST cons) group_id(MSA) cohort_id(cohort);

/* WLS using inverse of first step sampling variance as weights */
/* using comparable tracting over time */
reg ige_hat_MSA cohort NSI [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
reg ige_hat_MSA cohort NSI sigma_t [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
reg ige_hat_MSA cohort NSI NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
reg ige_hat_MSA cohort NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
reg ige_hat_MSA cohort NSI prc_black prc_hispanic prc_under18 prc_over65 prc_foreign log_population NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);

/* WLS using inverse of first step sampling variance as weights */
/* using contemporaneous tracting */
reg ige_hat_MSA cohort NSI_ct [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
reg ige_hat_MSA cohort NSI_ct sigma_t_ct [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
reg ige_hat_MSA cohort NSI_ct NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
reg ige_hat_MSA cohort NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);
lincom _cons+NORTH_CENTRAL;
lincom _cons+SOUTH;
lincom _cons+WEST;

reg ige_hat_MSA cohort NSI_ct prc_black_ct prc_hispanic_ct prc_under18_ct prc_over65_ct prc_foreign_ct log_population_ct NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA] if trim_sample==1, cluster(MSA);

/* untrimmed sample */
/* using contemporaneous tracting only */
sort MSA cohort;

/* efficient panel/GLS procedure (adapted from Hanushek 1974) */
ts_panel_fgls ige_hat_MSA NSI_ct , firststep_var(ige_hat_var_MSA) group_varlist(cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI_ct sigma_t_ct , firststep_var(ige_hat_var_MSA) group_varlist(cons) group_id(MSA) cohort_id(cohort);
test NSI sigma_t;
ts_panel_fgls ige_hat_MSA NSI_ct , firststep_var(ige_hat_var_MSA) group_varlist(NORTH_CENTRAL SOUTH WEST cons) group_id(MSA) cohort_id(cohort);
ts_panel_fgls ige_hat_MSA NSI_ct prc_black_ct prc_hispanic_ct prc_under18_ct prc_over65_ct prc_foreign_ct log_population_ct, 
			  firststep_var(ige_hat_var_MSA) group_varlist(NORTH_CENTRAL SOUTH WEST cons) group_id(MSA) cohort_id(cohort);

/* WLS using inverse of first step sampling variance as weights */
reg ige_hat_MSA cohort NSI_ct [aw=1/ige_hat_var_MSA], cluster(MSA);
reg ige_hat_MSA cohort NSI_ct sigma_t_ct [aw=1/ige_hat_var_MSA], cluster(MSA);
reg ige_hat_MSA cohort NSI_ct NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA], cluster(MSA);
reg ige_hat_MSA cohort NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA], cluster(MSA);
reg ige_hat_MSA cohort NSI_ct prc_black prc_hispanic prc_under18 prc_over65 prc_foreign log_population NORTH_CENTRAL SOUTH WEST [aw=1/ige_hat_var_MSA], cluster(MSA);

log off;

/*********************************************/
/* results based on balanced panel of MSAs   */
/*********************************************/

/* reshape data side into panel form */
keep if Greater25In79p97==1;

/* "over time" tracting */
bys MSA: egen D_NSI = sum(cohort*NSI - (1-cohort)*NSI);
bys MSA: egen D_sigma_t = sum(cohort*sigma_t - (1-cohort)*sigma_t);
bys MSA: egen D_prc_black = sum(cohort*prc_black - (1-cohort)*prc_black);
bys MSA: egen D_prc_hispanic = sum(cohort*prc_hispanic - (1-cohort)*prc_hispanic);
bys MSA: egen D_prc_under18 = sum(cohort*prc_under18 - (1-cohort)*prc_under18);
bys MSA: egen D_prc_over65 = sum(cohort*prc_over65 - (1-cohort)*prc_over65);
bys MSA: egen D_prc_foreign = sum(cohort*prc_foreign - (1-cohort)*prc_foreign);
bys MSA: egen D_log_pop = sum(cohort*log_population - (1-cohort)*log_population);

/* contemporaneous tracting */
bys MSA: egen D_NSI_ct = sum(cohort*NSI_ct - (1-cohort)*NSI_ct);
bys MSA: egen D_sigma_t_ct = sum(cohort*sigma_t_ct - (1-cohort)*sigma_t_ct);
bys MSA: egen D_prc_black_ct = sum(cohort*prc_black_ct - (1-cohort)*prc_black_ct);
bys MSA: egen D_prc_hispanic_ct = sum(cohort*prc_hispanic_ct - (1-cohort)*prc_hispanic_ct);
bys MSA: egen D_prc_under18_ct = sum(cohort*prc_under18_ct - (1-cohort)*prc_under18_ct);
bys MSA: egen D_prc_over65_ct = sum(cohort*prc_over65_ct - (1-cohort)*prc_over65_ct);
bys MSA: egen D_prc_foreign_ct = sum(cohort*prc_foreign_ct - (1-cohort)*prc_foreign_ct);
bys MSA: egen D_log_pop_ct = sum(cohort*log_population_ct - (1-cohort)*log_population_ct);


keep 	MSA PlaceName_MSA SelectedPlaceName cohort ige_hat_MSA ige_hat_var_MSA ige_rank NORTH_CENTRAL SOUTH WEST
		D_NSI D_sigma_t D_prc_black D_prc_hispanic D_prc_under18 D_prc_over65 D_prc_foreign D_log_pop
		D_NSI_ct D_sigma_t_ct D_prc_black_ct D_prc_hispanic_ct D_prc_under18_ct D_prc_over65_ct D_prc_foreign_ct D_log_pop_ct
		total_population_80 Greater25In79p97_trim_sample num_hh_in_MSA79 num_hh_in_MSA97;

reshape wide ige_hat_MSA ige_hat_var_MSA ige_rank, i(MSA) j(cohort);

log on;
/* all cities in panel */
corr ige_rank0 ige_rank1;
spearman  ige_rank0 ige_rank1;
ktau  ige_rank0 ige_rank1;

/* all cities in panel w/ at least 100 hh in each cohort */
corr ige_rank0 ige_rank1 if num_hh_in_MSA79>=100 & num_hh_in_MSA97>=100;
spearman  ige_rank0 ige_rank1 if num_hh_in_MSA79>=100 & num_hh_in_MSA97>=100;
ktau  ige_rank0 ige_rank1 if num_hh_in_MSA79>=100 & num_hh_in_MSA97>=100;

log off;


keep if Greater25In79p97_trim_sample==1;
g D_ige    = ige_hat_MSA1 - ige_hat_MSA0;
g D_ige_var = ige_hat_var_MSA0 + ige_hat_var_MSA1;
g D_ige_se = sqrt(D_ige_var);
mkmat D_ige_var;
matrix V = diag(D_ige_var);

log on;



/* "over time" tracting */
ts_fgls D_ige D_NSI if Greater25In79p97_trim_sample==1, firststepvcov(V);
ts_fgls D_ige D_NSI D_sigma_t if Greater25In79p97_trim_sample==1, firststepvcov(V);
ts_fgls D_ige D_NSI 
			  NORTH_CENTRAL SOUTH WEST if Greater25In79p97_trim_sample==1, firststepvcov(V);
ts_fgls D_ige D_NSI 
			  D_prc_black D_prc_hispanic D_prc_under18 D_prc_over65 D_prc_foreign D_log_pop
			  NORTH_CENTRAL SOUTH WEST if Greater25In79p97_trim_sample==1
              , firststepvcov(V);

reg D_ige D_NSI [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r;   
reg D_ige D_NSI D_sigma_t [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r; 
reg D_ige D_NSI 
		  NORTH_CENTRAL SOUTH WEST [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r; 
reg D_ige D_NSI 
          D_prc_black D_prc_hispanic D_prc_under18 D_prc_over65 D_prc_foreign D_log_pop 
          NORTH_CENTRAL SOUTH WEST [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r; 
          
/* contemporaneous tracting */
ts_fgls D_ige D_NSI_ct  if Greater25In79p97_trim_sample==1, firststepvcov(V);
ts_fgls D_ige D_NSI_ct D_sigma_t_ct if Greater25In79p97_trim_sample==1, firststepvcov(V);
ts_fgls D_ige D_NSI_ct 
			  NORTH_CENTRAL SOUTH WEST if Greater25In79p97_trim_sample==1, firststepvcov(V);
ts_fgls D_ige D_NSI_ct 
			  D_prc_black_ct D_prc_hispanic_ct D_prc_under18_ct D_prc_over65_ct D_prc_foreign_ct D_log_pop_ct
			  NORTH_CENTRAL SOUTH WEST if Greater25In79p97_trim_sample==1
              , firststepvcov(V);

reg D_ige D_NSI_ct [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r;   
reg D_ige D_NSI_ct D_sigma_t_ct [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r; 
reg D_ige D_NSI_ct 
		  NORTH_CENTRAL SOUTH WEST [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r; 
reg D_ige D_NSI_ct 
          D_prc_black_ct D_prc_hispanic_ct D_prc_under18_ct D_prc_over65_ct D_prc_foreign_ct D_log_pop_ct 
          NORTH_CENTRAL SOUTH WEST [aw=1/D_ige_var] if Greater25In79p97_trim_sample==1, r; 
          
log off;     

/* scatter plot of the IGE estimates versus NSI (First Differences) */
twoway (scatter D_ige D_NSI [aweight=1/D_ige_var] , msymbol(circle_hollow))
       (scatter D_ige D_NSI [aweight=1/D_ige_var] , msymbol(none) mlabel(SelectedPlaceName) mlabposition(9))
       (lfit D_ige D_NSI [aweight=1/D_ige_var], c(l)),                  
     	xlabel(-0.02 -0.01 0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08) 
		ylabel(-0.6 -0.4 -0.2 0 0.2 0.4) 
		yscale(range(-0.6 0.4))
		xscale(range(-0.02 0.08)) 
		title("") 
		subtitle("Mobility and residential stratification") 
		xtitle("Change in Neighborhood Sorting Index (NSI) - Income") 
		ytitle("Change in Intergenerational elasticity of earnings (IGE)") 
		legend(off);
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_INC_FirstDif_Scatter.gph, replace;
graph export $WRITE_DATA/NSI_INC_FirstDif_Scatter.eps, replace;
log close;

