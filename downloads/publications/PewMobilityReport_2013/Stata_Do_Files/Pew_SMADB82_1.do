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

/***************************************************************************************************/
/* Organize data drawn from 1982 State and Metropolitan Databook as archived by ISCPR              */
/***************************************************************************************************/

/* Adjust the SOURCE_DATA directory to point to the location of the 08187-0002-Data.txt ISCPR file. Adjust the    */
/* WRITE_DATA and DO_FILES directorys to point to the location of where you would like to write any created files and */
/* where you have placed this do file respectively. */

global SOURCE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/SMADB_82/DS0002";
global WRITE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Created_Data";
global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";

infix using "$SOURCE_DATA/08187-0002-Data.txt";

drop lri_s2 rsi_s2 geo_id_s2 scsa_s2 smsa_s2 necma_s2 state_co_s2;

/* only keep records corresponding to SMSAs */
keep if lri>=5 & lri<=917;
keep if smsa~=.; 

/* compute some basic SMSA-level variables for analysis */
g log_pop_80 = log(pop_total_80);
g log_land_80 = log(land_area_80);
g prc_black_80 = (black_pop_80/pop_total_80)*100;
g prc_hispanic_80 = (hispanic_pop_80/pop_total_80)*100;

/* log-linear interpolate to estimate public school enrollment in 1976/77 */
g ps_enroll_76_77 = ps_enroll_74_75*exp((log(ps_enroll_74_75/ps_enroll_69_70)/5)*2) 
					if ps_enroll_74_75c==0 & ps_enroll_74_75>0 & ps_enroll_69_70c==0 & ps_enroll_69_70>0;

/* compute expenditures per capita and education expenditures per student in 1976-1977 in 2010 dollars */
/* US CPI research series back to Dec 1977 and CPI-U DEC-to-DEC inflation rate of 6.7 to get back to Dec 1976 */
g exp_pc_76_77 = 1.067*3.202*(tot_exp_76_77*1000)/pop_77 if tot_exp_76_77c==0 & tot_exp_76_77>0 & pop_77c==0 & pop_77>0;
g log_exp_pc_76_77 = log(exp_pc_76_77);

g educ_exp_pp_76_77 = 1.067*3.202*(educ_exp_76_77*1000)/ps_enroll_76_77 if educ_exp_76_77c==0 & educ_exp_76_77>0;
g log_educ_exp_pp_76_77 = log(educ_exp_pp_76_77);

keep smsa log_pop_80 log_land_80 prc_black_80 prc_hispanic_80 exp_pc_76_77 educ_exp_pp_76_77 log_exp_pc_76_77 log_educ_exp_pp_76_77;
rename smsa SMSA81;
sort SMSA81; 
save "$WRITE_DATA/Pew_SMADB82", replace;






