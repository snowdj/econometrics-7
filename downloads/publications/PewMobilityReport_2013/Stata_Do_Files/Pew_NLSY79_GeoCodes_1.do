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

/**************************************************************************************************/
/* Organize NLSY 1979 Geocode data from NORC and Special BLS License                              */
/**************************************************************************************************/ 

/* Adjust the SOURCE_DATA directory to point to the location of the location_081610.dct dictionary file. Adjust the    */
/* WRITE_DATA and DO_FILES directorys to point to the location of where you would like to write any created files and */
/* where you have placed this do file respectively. */

global SOURCE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Geocodes/NLSY79_GeoCodes";
global WRITE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Created_Data";
global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";

/**************************************************************************************************/
/* SMSA OF RESIDENCE 1979 to 1982                                                                 */
/**************************************************************************************************/

/* read in MSA residence source data (from NORC CD-ROMS dated August 2010) */
/* NOTE: These datafiles available only via special agreement from the BLS */
infile using "$SOURCE_DATA/location_081610.dct";

/* added value lables to variables */
do "$SOURCE_DATA/location_081610-value-labels.do";

g PID_79  = R0000100;    /* individual ID number      */
g SMSA_79 = R0219003;    /* SMSA of residence in 1979 */
g SMSA_80 = R0408003;    /* SMSA of residence in 1980 */
g SMSA_81 = R0648003;    /* SMSA of residence in 1981 */
g SMSA_82 = R0899003;    /* SMSA of residence in 1982 */

g NORTH_EAST_79 	= inlist(R0219002,9,23,25,33,34,36,42,44,50) if R0219002~=-4;
g NORTH_CENTRAL_79	= inlist(R0219002,17,18,19,20,26,27,29,31,38,39,46,55) if R0219002~=-4;
g SOUTH_79  		= inlist(R0219002,1,5,10,11,12,13,21,22,24,28,37,40,45,47,48,51,54) if R0219002~=-4;
g WEST_79			= inlist(R0219002,2,4,6,8,15,16,30,32,35,41,49,53,56) if R0219002~=-4;

sort PID_79;
save "$WRITE_DATA/PewNLSY79_MSACodes_79_82", replace;

/**************************************************************************************************/
/* COUNTY AND CITY FACTBOOK DATA                                                                  */
/**************************************************************************************************/

clear;

/* read in county and city factbook source data (from NORC CD-ROMS dated August 2010) */
infile using "$SOURCE_DATA/County_city_data_bk_79_89.dct";

/* added value lables to variables */
do "$SOURCE_DATA/County_city_data_bk_79_89-value-labels.do";

g PID_79  = R0000100;    /* individual ID number      */

g LAND_AREA_SMSA79 = R0219059;
label variable LAND_AREA_SMSA79 "R0219059 - CCDB 1977";

g POP_1975_SMSA79 = R0219062;
label variable POP_1975_SMSA79 "R0219062 - CCDB 1977";

g BLACK_1970_SMSA79 = R0219064;
label variable BLACK_1970_SMSA79 "R0219064 - CCDB 1977";

g HISPANIC_1970_SMSA79 = R0219065;
label variable HISPANIC_1970_SMSA79 "R0219065 - CCDB 1977";

g CRIME_1975_SMSA79 = R0219084;
label variable CRIME_1975_SMSA79 "R0219084 - CCDB 1977";

g HIGHSCHOOL_1970_SMSA79 = R0219086;
label variable HIGHSCHOOL_1970_SMSA79 "R0219086 - CCDB 1972";

g COLLEGE_1970_SMSA79 = R0219087;
label variable COLLEGE_1970_SMSA79 "R0219087 - CCDB 1972";

g MEDIANINC_1969_SMSA79 = R0219103;
label variable MEDIANINC_1969_SMSA79 "R0219103 - CCDB 1977";

g POVRATE_1969_SMSA79 = R0219112;
label variable POVRATE_1969_SMSA79 "R0219112 - CCDB 1977";

keep PID_79-POVRATE_1969_SMSA79;
sort PID_79;
save "$WRITE_DATA/PewNLSY79_FactbookData", replace;

insheet SMSA81 SCSA81 STATEC81 CITYTOWN  PlaceName using "$SOURCE_DATA/SMSA80Codes.csv" , comma clear names;
g t= strpos(placename,"SMSA");
drop if t==0;
drop t statec81 citytown;
rename smsa81 SMSA81;
rename scsa81 SCSA81;
rename placename PlaceName;
save "$WRITE_DATA/PewNLSY79_MSANames", replace;










