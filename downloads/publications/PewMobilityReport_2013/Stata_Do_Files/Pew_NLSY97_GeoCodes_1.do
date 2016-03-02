/***************************************************************************************************/
/* Intergenerational Mobility							   		         						   */
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

/**************************************************************************************************/
/* Organize NLSY 1997 Geocode data from NORC (Need Special BLS License)                           */
/**************************************************************************************************/ 

/* Adjust the SOURCE_DATA_LOCATION directory to point to the location of the Location_R13.dct dictionary file.  */
/* Adjust the SOURCE_DATA_CCDB directory to point to the location of the City_and_County_Data_Bk.dct dictionary file. */
/* Adjust the WRITE_DATA and DO_FILES directorys to point to the location of where you would like to write any created files and */
/* where you have placed this do file respectively. */

global SOURCE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Geocodes/NLSY97_GeoCodes";
global SOURCE_DATA_LOCATION "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Geocodes/NLSY97_GeoCodes/Location";
global SOURCE_DATA_CCDB "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Geocodes/NLSY97_GeoCodes/County and City Data Book";
global WRITE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Created_Data";
global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";

/**************************************************************************************************/
/* MSA OF RESIDENCE 1997 to 2000                                                                  */
/**************************************************************************************************/

/* The NLSY97 geocode files report the MSA, CMSA or NECMA of resident. If a unit resides in a CMSA  */
/* her/his location among its constituent localities is not made available. The coding scheme used  */
/* in Rounds 1 to 5 of the NLSY97 does not match the standard MSA/CMSA FIPS Codes defined by Office */
/* of Management and Budget, 6/30/99. Instead a scheme based on the 1994 City and County Databook   */
/* was used. The two codes are quite close. */

/* read in MSA residence source data (from NORC CD-ROMS dated July 2011) */
infile using "$SOURCE_DATA_LOCATION/Location_R13.dct";

/* added value lables to variables */
do "$SOURCE_DATA_LOCATION/Location_R13-value-labels.do";

g PID_97     = R0000100;     /* individual ID number      */

g MSA_97     = R1243100;     /* MSA of residence in 1997  */
g PMSA_97    = R1243200;     /* PMSA of residence in 1997  */
g MSA_97Type = R1243300;     /* Type MSA 1997 */

g MSA_98     = R2602400;     /* MSA of residence in 1998  */
g PMSA_98    = R2602500;     /* PMSA of residence in 1998  */
g MSA_98Type = R2602600;     /* Type MSA 1998 */

g MSA_99     = R3927600;     /* MSA of residence in 1999  */
g PMSA_99    = R3927700;     /* PMSA of residence in 1999  */
g MSA_99Type = R3927800;     /* Type MSA 1999 */

g MSA_00     = R5521500;     /* MSA of residence in 2000  */
g PMSA_00    = R5521600;     /* PMSA of residence in 2000  */
g MSA_00Type = R5521700;     /* Type MSA 2000 */

/* coding for MSA_yyType variable is 2 : CMSA/PMSA county, 3: MSA county, 4: NECMA county and 5: non-MSA */
g MSACMA_97     	= MSA_97 if MSA_97Type==2 | MSA_97Type==3;
g MSAPMA_97     	= MSA_97 if MSA_97Type==3;
replace MSAPMA_97 	= PMSA_97 if MSA_97Type==2;
g NECMA_97          = MSA_97 if MSA_97Type==4;

g MSACMA_98     	= MSA_98 if MSA_98Type==2 | MSA_98Type==3;
g MSAPMA_98     	= MSA_98 if MSA_98Type==3;
replace MSAPMA_98 	= PMSA_98 if MSA_98Type==2;
g NECMA_98          = MSA_98 if MSA_98Type==4;

g MSACMA_99     	= MSA_99 if MSA_99Type==2 | MSA_99Type==3;
g MSAPMA_99     	= MSA_99 if MSA_99Type==3;
replace MSAPMA_99 	= PMSA_99 if MSA_99Type==2;
g NECMA_99          = MSA_99 if MSA_99Type==4;

g MSACMA_00     	= MSA_00 if MSA_00Type==2 | MSA_00Type==3;
g MSAPMA_00     	= MSA_00 if MSA_00Type==3;
replace MSAPMA_00 	= PMSA_00 if MSA_00Type==2;
g NECMA_00          = MSA_00 if MSA_00Type==4;

g NORTH_EAST_97 	= inlist(R1243000,9,23,25,33,34,36,42,44,50) if R1243000~=-4;
g NORTH_CENTRAL_97	= inlist(R1243000,17,18,19,20,26,27,29,31,38,39,46,55) if R1243000~=-4;
g SOUTH_97  		= inlist(R1243000,1,5,10,11,12,13,21,22,24,28,37,40,45,47,48,51,54) if R1243000~=-4;
g WEST_97			= inlist(R1243000,2,4,6,8,15,16,30,32,35,41,49,53,56) if R1243000~=-4;

sort PID_97;
save "$WRITE_DATA/PewNLSY97_MSACodes_97_00", replace;

/**************************************************************************************************/
/* COUNTY AND CITY FACTBOOK DATA                                                                  */
/**************************************************************************************************/

clear;
/* read in county and city factbook source data (from NORC CD-ROMS dated July 2011) */
infile using "$SOURCE_DATA_CCDB/County_and_City_Data_Bk.dct";

/* added value lables to variables */
do "$SOURCE_DATA_CCDB/County_and_City_Data_Bk-value-labels.do";

g PID_97  = R0000100;    /* individual ID number      */
sort PID_97;
save "$WRITE_DATA/PewNLSY97_FactbookData", replace;

insheet MSA_CMSA PMSA ALT_CMSA STATECO CENTRAL_FLAG CITYTOWN PlaceName using "$SOURCE_DATA/SMSA99Codes.csv" , comma clear names;
g t= strpos(placename,"MSA");
drop if t==0;
drop t stateco citytown;

rename msa_cmsa MSACMA99;
rename pmsa PMSA99;
rename alt_cmsa ALT_CMSA99;
rename central_flag InCenterOfMSA;
rename placename PlaceName;
g MSAPMA99 = MSACMA99;
replace MSAPMA99 = PMSA99 if PMSA99~="";
replace MSAPMA99 = "" if PMSA99=="" & ALT_CMSA99~="";
sort MSACMA99;
save "$WRITE_DATA/PewNLSY97_PlaceNames", replace;

insheet NECMA99 PlaceName using "$SOURCE_DATA/NECMA99Codes.csv" , comma clear names;
rename necma99 NECMA99;
rename placename PlaceName;
append using "$WRITE_DATA/PewNLSY97_PlaceNames";
g MSACMA99a = real(MSACMA99);
rename MSACMA99 MSACMA99s;
rename MSACMA99a MSACMA99;
g MSAPMA99a = real(MSAPMA99);
rename MSAPMA99 MSAPMA99s;
rename MSAPMA99a MSAPMA99;
drop MSACMA99s MSAPMA99s;
save "$WRITE_DATA/PewNLSY97_PlaceNames", replace;
