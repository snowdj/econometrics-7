/***************************************************************************************************/
/* Intergenerational Mobility (Base NLSY Analysis File)     						               */
/* Bryan S. Graham, UC - BERKELEY									         			   		   */
/* Patrick Sharkey, NYU												         			   		   */
/* bgraham@econ.berkeley.edu       						         		   			   			   */
/* May 2013                              								         				   */
/***************************************************************************************************/

/* use a semicolon as the command delimiter */
#delimit ;

clear matrix;
clear mata;
clear;

set matsize 8000;
set memory 1000m;

global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";

do "$DO_FILES/Pew_NCDB_DataManipulation_1";
do "$DO_FILES/Pew_SMADB82_1"
do "$DO_FILES/Pew_NLSY79_GeoCodes_1";
do "$DO_FILES/Pew_NLSY97_GeoCodes_1";
do "$DO_FILES/Pew_NLSY79_DataOrg_1";
do "$DO_FILES/Pew_NLSY97_DataOrg_1";
do "$DO_FILES/Pew_NLSY_Panel";

