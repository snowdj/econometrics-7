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
/* Organization and preliminary analysis of 1979 NLSY Sample                                      */
/**************************************************************************************************/

/* Adjust the SOURCE_DATA directory to point to the location of the PewMobilityNLSY79.dct dictionary file. Adjust the    */
/* WRITE_DATA and DO_FILES directorys to point to the location of where you would like to write any created files and */
/* where you have placed this do file respectively. */

global SOURCE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/NLSY79";
global GEOCODE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Geocodes";
global WRITE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Created_Data";
global WRITE_DATA_TEACHING "/accounts/fac/bgraham/Teaching/Ec240a_Fall2011/EmpiricalExamples/NLSYEmpiricalExamples";
global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";

/* load FGLS stata/mata program used below */
do "$DO_FILES/TS_FGLS.ado";

/* read in source data (extract from Oct 12, 2011 release for NLSY79) */
infile using "$SOURCE_DATA/PewMobilityNLSY79.dct";

/* added value lables to variables */
do "$DO_FILES/PewMobilityNLSY79_value_labels.do";

/**************************************************************************************************/
/* BASELINE RESPONDENT CHARACTERISTICS                                                            */
/**************************************************************************************************/

g PID_79 = R0000100;    /* individual ID number */
g HHID_79 = R0000149;	/* household ID number (for `clustering') */

/* sample designations and sampling weights */
g cross_section_male = (R0173600<=4);
g cross_section_female = (R0173600>4)*(R0173600<=8);
g supp_section_male = (R0173600>9)*(R0173600<=11);     /* exclude economically white disadvantaged */
g supp_section_female = (R0173600>12)*(R0173600<=14);  /* exclude economically white disadvantaged */
g core_sample = cross_section_male+cross_section_female+supp_section_male+supp_section_female;
g nlsy79_sample_wgts =  R0216100;

/* adjust baseline sampling weights for the exclusion of the supplemental poor "white" sample */
g poor_white_males = (R0173600==2) + (R0173600==9);
g poor_white_females = (R0173600==5) + (R0173600==12);
bys R0173600: egen wgts_sum = total(nlsy79_sample_wgts);
bys poor_white_males: egen wgts_sum_pwm = total(nlsy79_sample_wgts);
bys poor_white_females: egen wgts_sum_pwf = total(nlsy79_sample_wgts);
g sample_wgts = nlsy79_sample_wgts if core_sample == 1;
replace sample_wgts = (wgts_sum_pwm/wgts_sum)*nlsy79_sample_wgts if R0173600==2;
replace sample_wgts = (wgts_sum_pwf/wgts_sum)*nlsy79_sample_wgts if R0173600==5;
drop wgts_sum_pwm wgts_sum_pwf wgts_sum poor_white_males poor_white_females;

/* birth year and age in months */
g month_born = R0000300;
g year_born = R0000500;
g age_1979 = (79 + (5/12)) - (year_born + month_born/12);
label variable age_1979 "Age in May of 1979";

/*****************************************************************************************************/
/* BASIC PARENTAL DATA                                                                               */
/*****************************************************************************************************/

/* parental demographic information */
g mother_usborn = (R0006100==1) if R0006100>=1 & R0006100<=2;
g mother_ukn = (R0006100==3) & R0006100>=0;
g father_usborn = (R0007300==1) if R0007300>=1 & R0007300<=2;
g father_ukn = (R0007300==3) & R0007300>=0;

g live_with_mom_79 = (R0006600==1) if R0006600>=0 | R0006600==-4;
g mom_is_living_79 = (R0006700==1) if R0006700>=0;
replace mom_is_living_79 = live_with_mom_79 if live_with_mom_79==1;

g live_with_mom_80 = (R0223000==1) if R0223000>=0 | R0223000==-4;
g mom_is_living_80 = (R0223100==1) if R0223100>=0;
replace mom_is_living_80 = live_with_mom_80 if live_with_mom_80==1; 

g live_with_dad_79 = (R0008000==1) if R0008000>=0 | R0008000==-4;
g dad_is_living_79 = (R0008100==1) if R0008100>=0;
replace dad_is_living_79 = live_with_dad_79 if live_with_dad_79==1; 

g live_with_dad_80 = (R0223400==1) if R0223400>=0 | R0223400==-4;
g dad_is_living_80 = (R0223500==1) if R0223500>=0;
replace dad_is_living_80 = live_with_dad_80 if live_with_dad_80==1; 

/*****************************************************************************************************/
/* BASIC RESPONDENT DEMOGRAPHICS                                                                     */ 
/*****************************************************************************************************/

g usborn = (R0000700==1) if R0000700>=1;
g male = (R0214800==1);
g hispanic = (R0214700==1);
g black = (R0214700==2);

/* schooling expectations */
g HGC_Desired_79 = R0023400 if R0023400>=0;
g HGC_Expected_79 = R0023500 if R0023500>=0;

g HGC_Desired_81 = R0419600 if R0419600>=0;
g HGC_Expected_81 = R0419700 if R0419700>=0;

g HGC_Desired_82 = R0406400 if R0406400>=0;
g HGC_Expected_82 = R0666800 if R0666800>=0;

/* AFQT percentile (2006 scoring)*/
g AFQT = R0618301/1000  if R0618301>0;
g AFQT_NoProb = (R0614800==51);			/* AFQT score based on test with no reported "problems" */
g AFQT_Adj = AFQT if AFQT_NoProb==1;    /* AFQT scores, problem free only */

/* calculate years of completed schooling by May 1st of interview year */
g HGC_79r = R0216701 if R0216701 >=0;
g HGC_80r = R0406401 if R0406401 >=0;
g HGC_81r = R0618901 if R0618901 >=0;
g HGC_82r = R0898201 if R0898201 >=0;
g HGC_83r = R1145001 if R1145001 >=0;
g HGC_84r = R1520201 if R1520201 >=0;
g HGC_85r = R1890901 if R1890901 >=0;
g HGC_86r = R2258001 if R2258001 >=0;
g HGC_87r = R2445401 if R2445401 >=0;
g HGC_88r = R2871101 if R2871101 >=0;
g HGC_89r = R3074801 if R3074801 >=0;
g HGC_90r = R3401501 if R3401501 >=0;
g HGC_91r = R3656901 if R3656901 >=0;
g HGC_92r = R4007401 if R4007401 >=0;
g HGC_93r = R4418501 if R4418501 >=0;
g HGC_94r = R5081500 if R5081500 >=0;

/* years of schooling at age 28 */
g HGC_Age28 = HGC_79r if floor(age_1979)==28;

replace HGC_Age28 = HGC_80r if floor(age_1979)==27;
replace HGC_Age28 = HGC_79r if floor(age_1979)==27 & HGC_80r==.;

replace HGC_Age28 = HGC_81r if floor(age_1979)==26;
replace HGC_Age28 = HGC_80r if floor(age_1979)==26 & HGC_81r==.;
replace HGC_Age28 = HGC_79r if floor(age_1979)==26 & HGC_80r==. & HGC_81r==.;

replace HGC_Age28 = HGC_82r if floor(age_1979)==25;
replace HGC_Age28 = HGC_81r if floor(age_1979)==25 & HGC_82r==.;
replace HGC_Age28 = HGC_80r if floor(age_1979)==25 & HGC_81r==. & HGC_82r==.;

replace HGC_Age28 = HGC_83r if floor(age_1979)==24;
replace HGC_Age28 = HGC_82r if floor(age_1979)==24 & HGC_83r==.;
replace HGC_Age28 = HGC_81r if floor(age_1979)==24 & HGC_82r==. & HGC_83r==.;

replace HGC_Age28 = HGC_84r if floor(age_1979)==23;
replace HGC_Age28 = HGC_83r if floor(age_1979)==23 & HGC_84r==.;
replace HGC_Age28 = HGC_82r if floor(age_1979)==23 & HGC_83r==. & HGC_84r==.;

replace HGC_Age28 = HGC_85r if floor(age_1979)==22;
replace HGC_Age28 = HGC_84r if floor(age_1979)==22 & HGC_85r==.;
replace HGC_Age28 = HGC_83r if floor(age_1979)==22 & HGC_84r==. & HGC_85r==.;

replace HGC_Age28 = HGC_86r if floor(age_1979)==21;
replace HGC_Age28 = HGC_85r if floor(age_1979)==21 & HGC_86r==.;
replace HGC_Age28 = HGC_84r if floor(age_1979)==21 & HGC_85r==. & HGC_86r==.;

replace HGC_Age28 = HGC_87r if floor(age_1979)==20;
replace HGC_Age28 = HGC_86r if floor(age_1979)==20 & HGC_87r==.;
replace HGC_Age28 = HGC_85r if floor(age_1979)==20 & HGC_86r==. & HGC_87r==.;

replace HGC_Age28 = HGC_88r if floor(age_1979)==19;
replace HGC_Age28 = HGC_87r if floor(age_1979)==19 & HGC_88r==.;
replace HGC_Age28 = HGC_86r if floor(age_1979)==19 & HGC_87r==. & HGC_88r==.;

replace HGC_Age28 = HGC_89r if floor(age_1979)==18;
replace HGC_Age28 = HGC_88r if floor(age_1979)==18 & HGC_89r==.;
replace HGC_Age28 = HGC_87r if floor(age_1979)==18 & HGC_88r==. & HGC_89r==.;

replace HGC_Age28 = HGC_90r if floor(age_1979)==17;
replace HGC_Age28 = HGC_89r if floor(age_1979)==17 & HGC_90r==.;
replace HGC_Age28 = HGC_88r if floor(age_1979)==17 & HGC_89r==. & HGC_90r==.;

replace HGC_Age28 = HGC_91r if floor(age_1979)==16;
replace HGC_Age28 = HGC_90r if floor(age_1979)==16 & HGC_91r==.;
replace HGC_Age28 = HGC_89r if floor(age_1979)==16 & HGC_90r==. & HGC_91r==.;

replace HGC_Age28 = HGC_92r if floor(age_1979)==15;
replace HGC_Age28 = HGC_91r if floor(age_1979)==15 & HGC_92r==.;
replace HGC_Age28 = HGC_90r if floor(age_1979)==15 & HGC_91r==. & HGC_92r==.;

replace HGC_Age28 = HGC_93r if floor(age_1979)==14;
replace HGC_Age28 = HGC_92r if floor(age_1979)==14 & HGC_93r==.;
replace HGC_Age28 = HGC_91r if floor(age_1979)==14 & HGC_92r==. & HGC_93r==.;

replace HGC_Age28 = HGC_94r if floor(age_1979)==13;
replace HGC_Age28 = HGC_93r if floor(age_1979)==13 & HGC_94r==.;
replace HGC_Age28 = HGC_92r if floor(age_1979)==13 & HGC_93r==. & HGC_94r==.;

/* years of schooling at age 24 */
g HGC_Age24 = HGC_79r if floor(age_1979)==24;

replace HGC_Age24 = HGC_80r if floor(age_1979)==23;
replace HGC_Age24 = HGC_79r if floor(age_1979)==23 & HGC_80r==.;

replace HGC_Age24 = HGC_81r if floor(age_1979)==22;
replace HGC_Age24 = HGC_80r if floor(age_1979)==22 & HGC_81r==.;
replace HGC_Age24 = HGC_79r if floor(age_1979)==22 & HGC_80r==. & HGC_81r==.;

replace HGC_Age24 = HGC_82r if floor(age_1979)==21;
replace HGC_Age24 = HGC_81r if floor(age_1979)==21 & HGC_82r==.;
replace HGC_Age24 = HGC_80r if floor(age_1979)==21 & HGC_81r==. & HGC_82r==.;

replace HGC_Age24 = HGC_83r if floor(age_1979)==20;
replace HGC_Age24 = HGC_82r if floor(age_1979)==20 & HGC_83r==.;
replace HGC_Age24 = HGC_81r if floor(age_1979)==20 & HGC_82r==. & HGC_83r==.;

replace HGC_Age24 = HGC_84r if floor(age_1979)==19;
replace HGC_Age24 = HGC_83r if floor(age_1979)==19 & HGC_84r==.;
replace HGC_Age24 = HGC_82r if floor(age_1979)==19 & HGC_83r==. & HGC_84r==.;

replace HGC_Age24 = HGC_85r if floor(age_1979)==18;
replace HGC_Age24 = HGC_84r if floor(age_1979)==18 & HGC_85r==.;
replace HGC_Age24 = HGC_83r if floor(age_1979)==18 & HGC_84r==. & HGC_85r==.;

replace HGC_Age24 = HGC_86r if floor(age_1979)==17;
replace HGC_Age24 = HGC_85r if floor(age_1979)==17 & HGC_86r==.;
replace HGC_Age24 = HGC_84r if floor(age_1979)==17 & HGC_85r==. & HGC_86r==.;

replace HGC_Age24 = HGC_87r if floor(age_1979)==16;
replace HGC_Age24 = HGC_86r if floor(age_1979)==16 & HGC_87r==.;
replace HGC_Age24 = HGC_85r if floor(age_1979)==16 & HGC_86r==. & HGC_87r==.;

replace HGC_Age24 = HGC_88r if floor(age_1979)==15;
replace HGC_Age24 = HGC_87r if floor(age_1979)==15 & HGC_88r==.;
replace HGC_Age24 = HGC_86r if floor(age_1979)==15 & HGC_87r==. & HGC_88r==.;

replace HGC_Age24 = HGC_89r if floor(age_1979)==14;
replace HGC_Age24 = HGC_88r if floor(age_1979)==14 & HGC_89r==.;
replace HGC_Age24 = HGC_87r if floor(age_1979)==14 & HGC_88r==. & HGC_89r==.;

replace HGC_Age24 = HGC_90r if floor(age_1979)==13;
replace HGC_Age24 = HGC_89r if floor(age_1979)==13 & HGC_90r==.;
replace HGC_Age24 = HGC_88r if floor(age_1979)==13 & HGC_89r==. & HGC_90r==.;

/***************************************************************************************************/
/* Determine if respondent is living with mother and/or father                                     */
/* NOTE: This determination is done by examing the household roster information in each wave of the*/
/*       NLSY79.                                                                                   */
/***************************************************************************************************/

g MotherInHome_79  = (R0174900==5) + (R0175800==5) + (R0176700==5) + (R0177600==5) +
                     (R0178500==5) + (R0179400==5) + (R0180300==5) + (R0181200==5) +
                     (R0182100==5) + (R0183000==5) + (R0183900==5) + (R0184800==5) +
                     (R0185700==5) + (R0186600==5) + (R0187500==5) if R0174900~=-5;                    
                                          
g FatherInHome_79  = (R0174900==4) + (R0175800==4) + (R0176700==4) + (R0177600==4) +
                     (R0178500==4) + (R0179400==4) + (R0180300==4) + (R0181200==4) +
                     (R0182100==4) + (R0183000==4) + (R0183900==4) + (R0184800==4) +
                     (R0185700==4) + (R0186600==4) + (R0187500==4) if R0174900~=-5;

g StepMotherInHome_79  = (R0174900==38) + (R0175800==38) + (R0176700==38) + (R0177600==38) +
                     	 (R0178500==38) + (R0179400==38) + (R0180300==38) + (R0181200==38) +
                     	 (R0182100==38) + (R0183000==38) + (R0183900==38) + (R0184800==38) +
                     	 (R0185700==38) + (R0186600==38) + (R0187500==38) if R0174900~=-5; 
                     	                      
g StepFatherInHome_79  = (R0174900==37) + (R0175800==37) + (R0176700==37) + (R0177600==37) +
                     	 (R0178500==37) + (R0179400==37) + (R0180300==37) + (R0181200==37) +
                     	 (R0182100==37) + (R0183000==37) + (R0183900==37) + (R0184800==37) +
                     	 (R0185700==37) + (R0186600==37) + (R0187500==37) if R0174900~=-5;                    	                      
                                        
g MotherInHome_80  = (R0393900==5) + (R0394500==5) + (R0395100==5) + (R0395700==5) +
                     (R0396300==5) + (R0396900==5) + (R0397500==5) + (R0398100==5) +
                     (R0398700==5) + (R0399300==5) + (R0399900==5) + (R0400500==5) +
                     (R0401100==5) + (R0401700==5) + (R0402300==5) if R0393900~=-5;  
                  
g FatherInHome_80  = (R0393900==4) + (R0394500==4) + (R0395100==4) + (R0395700==4) +
                     (R0396300==4) + (R0396900==4) + (R0397500==4) + (R0398100==4) +
                     (R0398700==4) + (R0399300==4) + (R0399900==4) + (R0400500==4) +
                     (R0401100==4) + (R0401700==4) + (R0402300==4) if R0393900~=-5;
                     
g StepMotherInHome_80  = (R0393900==38) + (R0394500==38) + (R0395100==38) + (R0395700==38) +
                         (R0396300==38) + (R0396900==38) + (R0397500==38) + (R0398100==38) +
                         (R0398700==38) + (R0399300==38) + (R0399900==38) + (R0400500==38) +
                         (R0401100==38) + (R0401700==38) + (R0402300==38) if R0393900~=-5;

g StepFatherInHome_80  = (R0393900==37) + (R0394500==37) + (R0395100==37) + (R0395700==37) +
                         (R0396300==37) + (R0396900==37) + (R0397500==37) + (R0398100==37) +
                         (R0398700==37) + (R0399300==37) + (R0399900==37) + (R0400500==37) +
                         (R0401100==37) + (R0401700==37) + (R0402300==37) if R0393900~=-5;                                                                                        

g MotherInHome_81  = (R0603300==5) + (R0603900==5) + (R0604500==5) + (R0605100==5) +
                     (R0605700==5) + (R0606300==5) + (R0606900==5) + (R0607500==5) +
                     (R0608100==5) + (R0608700==5) + (R0609300==5) + (R0609900==5) +
                     (R0610500==5) + (R0611100==5) + (R0611700==5) if R0603300~=-5;

g FatherInHome_81  = (R0603300==4) + (R0603900==4) + (R0604500==4) + (R0605100==4) +
                     (R0605700==4) + (R0606300==4) + (R0606900==4) + (R0607500==4) +
                     (R0608100==4) + (R0608700==4) + (R0609300==4) + (R0609900==4) +
                     (R0610500==4) + (R0611100==4) + (R0611700==4) if R0603300~=-5;
                     
g StepMotherInHome_81  = (R0603300==38) + (R0603900==38) + (R0604500==38) + (R0605100==38) +
                         (R0605700==38) + (R0606300==38) + (R0606900==38) + (R0607500==38) +
                         (R0608100==38) + (R0608700==38) + (R0609300==38) + (R0609900==38) +
                         (R0610500==38) + (R0611100==38) + (R0611700==38) if R0603300~=-5;

g StepFatherInHome_81  = (R0603300==37) + (R0603900==37) + (R0604500==37) + (R0605100==37) +
                         (R0605700==37) + (R0606300==37) + (R0606900==37) + (R0607500==37) +
                         (R0608100==37) + (R0608700==37) + (R0609300==37) + (R0609900==37) +
                         (R0610500==37) + (R0611100==37) + (R0611700==37) if R0603300~=-5;                         

g MotherInHome_82  = (R0817700==5) + (R0818400==5) + (R0819100==5) + (R0819800==5) +
                     (R0820500==5) + (R0821200==5) + (R0821900==5) + (R0822600==5) +
                     (R0823300==5) + (R0824000==5) + (R0824700==5) + (R0825400==5) +
                     (R0826100==5) + (R0826800==5) + (R0827500==5) if R0817700~=-5;
                     
g FatherInHome_82  = (R0817700==4) + (R0818400==4) + (R0819100==4) + (R0819800==4) +
                     (R0820500==4) + (R0821200==4) + (R0821900==4) + (R0822600==4) +
                     (R0823300==4) + (R0824000==4) + (R0824700==4) + (R0825400==4) +
                     (R0826100==4) + (R0826800==4) + (R0827500==4) if R0817700~=-5;
                     
g StepMotherInHome_82  = (R0817700==38) + (R0818400==38) + (R0819100==38) + (R0819800==38) +
                         (R0820500==38) + (R0821200==38) + (R0821900==38) + (R0822600==38) +
                         (R0823300==38) + (R0824000==38) + (R0824700==38) + (R0825400==38) +
                         (R0826100==38) + (R0826800==38) + (R0827500==38) if R0817700~=-5;
                         
g StepFatherInHome_82  = (R0817700==37) + (R0818400==37) + (R0819100==37) + (R0819800==37) +
                         (R0820500==37) + (R0821200==37) + (R0821900==37) + (R0822600==37) +
                         (R0823300==37) + (R0824000==37) + (R0824700==37) + (R0825400==37) +
                         (R0826100==37) + (R0826800==37) + (R0827500==37) if R0817700~=-5;                             

g MotherInHome_83  = (R1055600==5) + (R1056300==5) + (R1057000==5) + (R1057700==5) +
                     (R1058400==5) + (R1059100==5) + (R1059800==5) + (R1060500==5) +
                     (R1061200==5) + (R1061900==5) + (R1062600==5) + (R1063300==5) +
                     (R1064000==5) + (R1064700==5) + (R1065400==5) if R105560~=-5;

g FatherInHome_83  = (R1055600==4) + (R1056300==4) + (R1057000==4) + (R1057700==4) +
                     (R1058400==4) + (R1059100==4) + (R1059800==4) + (R1060500==4) +
                     (R1061200==4) + (R1061900==4) + (R1062600==4) + (R1063300==4) +
                     (R1064000==4) + (R1064700==4) + (R1065400==4) if R105560~=-5;

g StepMotherInHome_83  = (R1055600==38) + (R1056300==38) + (R1057000==38) + (R1057700==38) +
                         (R1058400==38) + (R1059100==38) + (R1059800==38) + (R1060500==38) +
                         (R1061200==38) + (R1061900==38) + (R1062600==38) + (R1063300==38) +
                         (R1064000==38) + (R1064700==38) + (R1065400==38) if R105560~=-5;
                         
g StepFatherInHome_83  = (R1055600==37) + (R1056300==37) + (R1057000==37) + (R1057700==37) +
                         (R1058400==37) + (R1059100==37) + (R1059800==37) + (R1060500==37) +
                         (R1061200==37) + (R1061900==37) + (R1062600==37) + (R1063300==37) +
                         (R1064000==37) + (R1064700==37) + (R1065400==37) if R105560~=-5;                         

g MotherInHome_84  = (R1441100==5) + (R1441800==5) + (R1442500==5) + (R1443200==5) +
                     (R1443900==5) + (R1444600==5) + (R1445300==5) + (R1446000==5) +
                     (R1446700==5) + (R1447400==5) + (R1448100==5) + (R1448800==5) +
                     (R1449500==5) + (R1450200==5) + (R1450900==5) if R1441100~=-5;
                     
g FatherInHome_84  = (R1441100==4) + (R1441800==4) + (R1442500==4) + (R1443200==4) +
                     (R1443900==4) + (R1444600==4) + (R1445300==4) + (R1446000==4) +
                     (R1446700==4) + (R1447400==4) + (R1448100==4) + (R1448800==4) +
                     (R1449500==4) + (R1450200==4) + (R1450900==4) if R1441100~=-5;
                   
g StepMotherInHome_84  = (R1441100==38) + (R1441800==38) + (R1442500==38) + (R1443200==38) +
                         (R1443900==38) + (R1444600==38) + (R1445300==38) + (R1446000==38) +
                         (R1446700==38) + (R1447400==38) + (R1448100==38) + (R1448800==38) +
                         (R1449500==38) + (R1450200==38) + (R1450900==38) if R1441100~=-5;

g StepFatherInHome_84  = (R1441100==37) + (R1441800==37) + (R1442500==37) + (R1443200==37) +
                         (R1443900==37) + (R1444600==37) + (R1445300==37) + (R1446000==37) +
                         (R1446700==37) + (R1447400==37) + (R1448100==37) + (R1448800==37) +
                         (R1449500==37) + (R1450200==37) + (R1450900==37) if R1441100~=-5;
                                                       
g MotherInHome_85  = (R1869500==5) + (R1870200==5) + (R1870900==5) + (R1871600==5) +
                     (R1872300==5) + (R1873000==5) + (R1873700==5) + (R1874400==5) +
                     (R1875100==5) + (R1875800==5) + (R1876500==5) + (R1877200==5) +
                     (R1877900==5) + (R1878600==5) + (R1879300==5) if R1869500~=-5;

g FatherInHome_85  = (R1869500==4) + (R1870200==4) + (R1870900==4) + (R1871600==4) +
                     (R1872300==4) + (R1873000==4) + (R1873700==4) + (R1874400==4) +
                     (R1875100==4) + (R1875800==4) + (R1876500==4) + (R1877200==4) +
                     (R1877900==4) + (R1878600==4) + (R1879300==4) if R1869500~=-5;
                                          
g StepMotherInHome_85  = (R1869500==38) + (R1870200==38) + (R1870900==38) + (R1871600==38) +
                         (R1872300==38) + (R1873000==38) + (R1873700==38) + (R1874400==38) +
                         (R1875100==38) + (R1875800==38) + (R1876500==38) + (R1877200==38) +
                         (R1877900==38) + (R1878600==38) + (R1879300==38) if R1869500~=-5;

g StepFatherInHome_85  = (R1869500==37) + (R1870200==37) + (R1870900==37) + (R1871600==37) +
                         (R1872300==37) + (R1873000==37) + (R1873700==37) + (R1874400==37) +
                         (R1875100==37) + (R1875800==37) + (R1876500==37) + (R1877200==37) +
                         (R1877900==37) + (R1878600==37) + (R1879300==37) if R1869500~=-5;
                         
g MotherInHome_86  = (R2235400==5) + (R2236100==5) + (R2236800==5) + (R2237500==5) +
                     (R2238200==5) + (R2238900==5) + (R2239600==5) + (R2240300==5) +
                     (R2241000==5) + (R2241700==5) + (R2242400==5) + (R2243100==5) +
                     (R2243800==5) + (R2244500==5) + (R2245200==5) if R2235400~=-5;

g FatherInHome_86  = (R2235400==4) + (R2236100==4) + (R2236800==4) + (R2237500==4) +
                     (R2238200==4) + (R2238900==4) + (R2239600==4) + (R2240300==4) +
                     (R2241000==4) + (R2241700==4) + (R2242400==4) + (R2243100==4) +
                     (R2243800==4) + (R2244500==4) + (R2245200==4) if R2235400~=-5;

g StepMotherInHome_86  = (R2235400==38) + (R2236100==38) + (R2236800==38) + (R2237500==38) +
                         (R2238200==38) + (R2238900==38) + (R2239600==38) + (R2240300==38) +
                         (R2241000==38) + (R2241700==38) + (R2242400==38) + (R2243100==38) +
                         (R2243800==38) + (R2244500==38) + (R2245200==38) if R2235400~=-5;
                         
g StepFatherInHome_86  = (R2235400==37) + (R2236100==37) + (R2236800==37) + (R2237500==37) +
                         (R2238200==37) + (R2238900==37) + (R2239600==37) + (R2240300==37) +
                         (R2241000==37) + (R2241700==37) + (R2242400==37) + (R2243100==37) +
                         (R2243800==37) + (R2244500==37) + (R2245200==37) if R2235400~=-5;                         

g MotherInHome_87  = (R2429800==5) + (R2430500==5) + (R2431200==5) + (R2431900==5) +
                     (R2432600==5) + (R2433300==5) + (R2434000==5) + (R2434700==5) +
                     (R2435400==5) + (R2436100==5) + (R2436800==5) + (R2437500==5) +
                     (R2438200==5) + (R2438900==5) + (R2439600==5) if R2429800~=-5;

g FatherInHome_87  = (R2429800==4) + (R2430500==4) + (R2431200==4) + (R2431900==4) +
                     (R2432600==4) + (R2433300==4) + (R2434000==4) + (R2434700==4) +
                     (R2435400==4) + (R2436100==4) + (R2436800==4) + (R2437500==4) +
                     (R2438200==4) + (R2438900==4) + (R2439600==4) if R2429800~=-5;

g StepMotherInHome_87  = (R2429800==38) + (R2430500==38) + (R2431200==38) + (R2431900==38) +
                         (R2432600==38) + (R2433300==38) + (R2434000==38) + (R2434700==38) +
                         (R2435400==38) + (R2436100==38) + (R2436800==38) + (R2437500==38) +
                         (R2438200==38) + (R2438900==38) + (R2439600==38) if R2429800~=-5;

g StepFatherInHome_87  = (R2429800==37) + (R2430500==37) + (R2431200==37) + (R2431900==37) +
                         (R2432600==37) + (R2433300==37) + (R2434000==37) + (R2434700==37) +
                         (R2435400==37) + (R2436100==37) + (R2436800==37) + (R2437500==37) +
                         (R2438200==37) + (R2438900==37) + (R2439600==37) if R2429800~=-5;
                         
g MotherInHome_88  = (R2750800==5) + (R2751500==5) + (R2752200==5) + (R2752900==5) +
                     (R2753600==5) + (R2754300==5) + (R2755000==5) + (R2755700==5) +
                     (R2756400==5) + (R2757100==5) + (R2757800==5) + (R2758500==5) +
                     (R2759200==5) + (R2759900==5) + (R2760600==5) if R2750800~=-5;
                     
g FatherInHome_88  = (R2750800==4) + (R2751500==4) + (R2752200==4) + (R2752900==4) +
                     (R2753600==4) + (R2754300==4) + (R2755000==4) + (R2755700==4) +
                     (R2756400==4) + (R2757100==4) + (R2757800==4) + (R2758500==4) +
                     (R2759200==4) + (R2759900==4) + (R2760600==4) if R2750800~=-5;                     
                     
g StepMotherInHome_88  = (R2750800==38) + (R2751500==38) + (R2752200==38) + (R2752900==38) +
                         (R2753600==38) + (R2754300==38) + (R2755000==38) + (R2755700==38) +
                         (R2756400==38) + (R2757100==38) + (R2757800==38) + (R2758500==38) +
                         (R2759200==38) + (R2759900==38) + (R2760600==38) if R2750800~=-5;
                         
g StepFatherInHome_88  = (R2750800==37) + (R2751500==37) + (R2752200==37) + (R2752900==37) +
                         (R2753600==37) + (R2754300==37) + (R2755000==37) + (R2755700==37) +
                         (R2756400==37) + (R2757100==37) + (R2757800==37) + (R2758500==37) +
                         (R2759200==37) + (R2759900==37) + (R2760600==37) if R2750800~=-5;                                                                                                                                                                 
                     
/**************************************************************************************************/
/* PARENTAL AGE VARIABLES                                                                         */
/* NOTE: We discard measures which imply an age at respondent's birth of less than 13 and greater */
/*       than 70 for males, and less than 13 and greater than 50 for females.                     */
/**************************************************************************************************/

/* get age from parental age questions asked in 1987 and 1988 rounds */
g FathersAge_79 = R2303200 - 8 if R2303200>0;
replace FathersAge_79 = . if (FathersAge_79-floor(age_1979))<13 | (FathersAge_79-floor(age_1979))>70;
g str100 FathersAge_79_Source = "Parental age question in 1987" if FathersAge_79~=.;
replace FathersAge_79 = R2505400 - 9 if R2505400>0 & FathersAge_79==.;
replace FathersAge_79 = . if (FathersAge_79-floor(age_1979))<13 | (FathersAge_79-floor(age_1979))>70;
replace FathersAge_79_Source = "Parental age question in 1988" if FathersAge_79_Source=="" & FathersAge_79~=.;

g MothersAge_79 = R2303600 - 8 if R2303600>0;
replace MothersAge_79 = . if (MothersAge_79-floor(age_1979))<13 | (MothersAge_79-floor(age_1979))>50;
g str100 MothersAge_79_Source = "Parental age question in 1987" if MothersAge_79~=.;
replace MothersAge_79 = R2505800 - 9 if R2505800>0 & MothersAge_79==.;
replace MothersAge_79 = . if (MothersAge_79-floor(age_1979))<13 | (MothersAge_79-floor(age_1979))>50;
replace MothersAge_79_Source = "Parental age question in 1988" if MothersAge_79_Source=="" & MothersAge_79~=.;

/* get age from parental birth year questions asked in 1987 and 1988 rounds */
replace FathersAge_79 = 79 - R2303100 if R2303100~=66 & R2303100>0 & FathersAge_79==.;
replace FathersAge_79 = . if (FathersAge_79-floor(age_1979))<13 | (FathersAge_79-floor(age_1979))>70;
replace FathersAge_79_Source = "Parental birthday question in 1987" if FathersAge_79_Source=="" & FathersAge_79~=.;
replace FathersAge_79 = 79 - R2505300 if R2505300~=66 & R2505300>0 & FathersAge_79==.;
replace FathersAge_79 = . if (FathersAge_79-floor(age_1979))<13 | (FathersAge_79-floor(age_1979))>70;
replace FathersAge_79_Source = "Parental birthday question in 1988" if FathersAge_79_Source=="" & FathersAge_79~=.;

replace MothersAge_79 = 79 - R2303500 if R2303500~=66 & R2303500>0 & MothersAge_79==.;
replace MothersAge_79 = . if (MothersAge_79-floor(age_1979))<13 | (MothersAge_79-floor(age_1979))>50;
replace MothersAge_79_Source = "Parental birthday question in 1987" if MothersAge_79_Source=="" & MothersAge_79~=.;
replace MothersAge_79 = 79 - R2505700 if R2505700~=66 & R2505700>0 & MothersAge_79==.;
replace MothersAge_79 = . if (MothersAge_79-floor(age_1979))<13 | (MothersAge_79-floor(age_1979))>50;
replace MothersAge_79_Source = "Parental birthday question in 1988" if MothersAge_79_Source=="" & MothersAge_79~=.;

/* get age from 1979 household roster information */
replace FathersAge_79 = (R0174900==4)*(R0175000>0)*R0175000 + (R0175800==4)*(R0175900>0)*R0175900 + 
					    (R0176700==4)*(R0176800>0)*R0176800 + (R0177600==4)*(R0177700>0)*R0177700 +
                        (R0178500==4)*(R0178600>0)*R0178600 + (R0179400==4)*(R0179500>0)*R0179500 + 
                        (R0180300==4)*(R0180400>0)*R0180400 + (R0181200==4)*(R0181300>0)*R0181300 +
                        (R0182100==4)*(R0182200>0)*R0182200 + (R0183000==4)*(R0183100>0)*R0183100 + 
                        (R0183900==4)*(R0184000>0)*R0184000 + (R0184800==4)*(R0184900>0)*R0184900 +
                        (R0185700==4)*(R0185800>0)*R0185800 + (R0186600==4)*(R0186700>0)*R0186700 + 
                        (R0187500==4)*(R0187600>0)*R0187600 if FathersAge_79==. & FatherInHome_79==1;
replace FathersAge_79 = . if (FathersAge_79-floor(age_1979))<13 | (FathersAge_79-floor(age_1979))>70;
replace FathersAge_79_Source = "Household roster 1979" if FathersAge_79_Source=="" & FathersAge_79~=.;                        
                     
replace MothersAge_79 = (R0174900==5)*(R0175000>0)*R0175000 + (R0175800==5)*(R0175900>0)*R0175900 + 
					    (R0176700==5)*(R0176800>0)*R0176800 + (R0177600==5)*(R0177700>0)*R0177700 +
                        (R0178500==5)*(R0178600>0)*R0178600 + (R0179400==5)*(R0179500>0)*R0179500 + 
                        (R0180300==5)*(R0180400>0)*R0180400 + (R0181200==5)*(R0181300>0)*R0181300 +
                        (R0182100==5)*(R0182200>0)*R0182200 + (R0183000==5)*(R0183100>0)*R0183100 + 
                        (R0183900==5)*(R0184000>0)*R0184000 + (R0184800==5)*(R0184900>0)*R0184900 +
                        (R0185700==5)*(R0185800>0)*R0185800 + (R0186600==5)*(R0186700>0)*R0186700 + 
                        (R0187500==5)*(R0187600>0)*R0187600 if MothersAge_79==. & MotherInHome_79==1;
replace MothersAge_79 = . if (MothersAge_79-floor(age_1979))<13 | (MothersAge_79-floor(age_1979))>50;                        
replace MothersAge_79_Source = "Household roster 1979" if MothersAge_79_Source=="" & MothersAge_79~=.;


/* get age from 1980 household roster information */                                        
replace FathersAge_79 = (R0393900==4)*(R0394000>0)*R0394000 + (R0394500==4)*(R0394600>0)*R0394600 + 
						(R0395100==4)*(R0395200>0)*R0395200 + (R0395700==4)*(R0395800>0)*R0395800 +
                     	(R0396300==4)*(R0396400>0)*R0396400 + (R0396900==4)*(R0397000>0)*R0397000 + 
                     	(R0397500==4)*(R0397600>0)*R0397600 + (R0398100==4)*(R0398200>0)*R0398200 +
                     	(R0398700==4)*(R0398800>0)*R0398800 + (R0399300==4)*(R0399400>0)*R0399400 + 
                     	(R0399900==4)*(R0400000>0)*R0400000 + (R0400500==4)*(R0400600>0)*R0400600 +
                     	(R0401100==4)*(R0401200>0)*R0401200 + (R0401700==4)*(R0401800>0)*R0401800 + 
                     	(R0402300==4)*(R0402400>0)*R0402400 - 1 if FathersAge_79==. & FatherInHome_80==1;
replace FathersAge_79 = . if (FathersAge_79-floor(age_1979))<13 | (FathersAge_79-floor(age_1979))>70;
replace FathersAge_79_Source = "Household roster 1980" if FathersAge_79_Source=="" & FathersAge_79~=.;                     	                                                                                           
                                     
replace MothersAge_79 = (R0393900==5)*(R0394000>0)*R0394000 + (R0394500==5)*(R0394600>0)*R0394600 + 
						(R0395100==5)*(R0395200>0)*R0395200 + (R0395700==5)*(R0395800>0)*R0395800 +
                     	(R0396300==5)*(R0396400>0)*R0396400 + (R0396900==5)*(R0397000>0)*R0397000 + 
                     	(R0397500==5)*(R0397600>0)*R0397600 + (R0398100==5)*(R0398200>0)*R0398200 +
                     	(R0398700==5)*(R0398800>0)*R0398800 + (R0399300==5)*(R0399400>0)*R0399400 + 
                     	(R0399900==5)*(R0400000>0)*R0400000 + (R0400500==5)*(R0400600>0)*R0400600 +
                     	(R0401100==5)*(R0401200>0)*R0401200 + (R0401700==5)*(R0401800>0)*R0401800 + 
                     	(R0402300==5)*(R0402400>0)*R0402400 - 1 if MothersAge_79==. & MotherInHome_80==1;
replace MothersAge_79 = . if (MothersAge_79-floor(age_1979))<13 | (MothersAge_79-floor(age_1979))>50;
replace MothersAge_79_Source = "Household roster 1980" if MothersAge_79_Source=="" & MothersAge_79~=.;

/* get age from 1981 household roster information */
replace FathersAge_79 = (R0603300==4)*(R0603400>0)*R0603400 + (R0603900==4)*(R0604000>0)*R0604000 + 
						(R0604500==4)*(R0604600>0)*R0604600 + (R0605100==4)*(R0605200>0)*R0605200 +
                     	(R0605700==4)*(R0605800>0)*R0605800 + (R0606300==4)*(R0606400>0)*R0606400 + 
                     	(R0606900==4)*(R0607000>0)*R0607000 + (R0607500==4)*(R0607600>0)*R0607600 +
                     	(R0608100==4)*(R0608200>0)*R0608200 + (R0608700==4)*(R0608800>0)*R0608800 + 
                     	(R0609300==4)*(R0609400>0)*R0609400 + (R0609900==4)*(R0610000>0)*R0610000 +
                     	(R0610500==4)*(R0610600>0)*R0610600 + (R0611100==4)*(R0611200>0)*R0611200 + 
                     	(R0611700==4)*(R0611800>0)*R0611800 - 2 if FathersAge_79==. & FatherInHome_81==1;
replace FathersAge_79 = . if (FathersAge_79-floor(age_1979))<13 | (FathersAge_79-floor(age_1979))>70;
replace FathersAge_79_Source = "Household roster 1981" if FathersAge_79_Source=="" & FathersAge_79~=.; 

replace MothersAge_79 = (R0603300==5)*(R0603400>0)*R0603400 + (R0603900==5)*(R0604000>0)*R0604000 + 
						(R0604500==5)*(R0604600>0)*R0604600 + (R0605100==5)*(R0605200>0)*R0605200 +
                     	(R0605700==5)*(R0605800>0)*R0605800 + (R0606300==5)*(R0606400>0)*R0606400 + 
                     	(R0606900==5)*(R0607000>0)*R0607000 + (R0607500==5)*(R0607600>0)*R0607600 +
                     	(R0608100==5)*(R0608200>0)*R0608200 + (R0608700==5)*(R0608800>0)*R0608800 + 
                     	(R0609300==5)*(R0609400>0)*R0609400 + (R0609900==5)*(R0610000>0)*R0610000 +
                     	(R0610500==5)*(R0610600>0)*R0610600 + (R0611100==5)*(R0611200>0)*R0611200 + 
                     	(R0611700==5)*(R0611800>0)*R0611800 - 2 if MothersAge_79==. & MotherInHome_81==1;
replace MothersAge_79 = . if (MothersAge_79-floor(age_1979))<13 | (MothersAge_79-floor(age_1979))>50;
replace MothersAge_79_Source = "Household roster 1981" if MothersAge_79_Source=="" & MothersAge_79~=.;

/* Compute squares and interactions of parent age */
g FathersAge_79_2 = FathersAge_79^2;
g MothersAge_79_2 = MothersAge_79^2;
g FxMAge_79 = FathersAge_79*MothersAge_79;
g ParentsAge_79 = (FathersAge_79 + MothersAge_79)/2;
g ParentsAge_79_2 = ParentsAge_79^2;

/******************************************************************************************************/
/* get step-father's age (if applicable) from the household rosters                                   */
/* NOTE: Calculated in such a way as to allow the identity of the step-father to change across years. */
/*       As before we throw away units aged less than 13 or greater than 70 at respondent's birth     */
/******************************************************************************************************/

/* Stepfather age in 1979 */
g StepFathersAge_79 = (R0174900==37)*(R0175000>0)*R0175000 + (R0175800==37)*(R0175900>0)*R0175900 + 
				      (R0176700==37)*(R0176800>0)*R0176800 + (R0177600==37)*(R0177700>0)*R0177700 +
                      (R0178500==37)*(R0178600>0)*R0178600 + (R0179400==37)*(R0179500>0)*R0179500 + 
                      (R0180300==37)*(R0180400>0)*R0180400 + (R0181200==37)*(R0181300>0)*R0181300 +
                      (R0182100==37)*(R0182200>0)*R0182200 + (R0183000==37)*(R0183100>0)*R0183100 + 
                      (R0183900==37)*(R0184000>0)*R0184000 + (R0184800==37)*(R0184900>0)*R0184900 +
                      (R0185700==37)*(R0185800>0)*R0185800 + (R0186600==37)*(R0186700>0)*R0186700 + 
                      (R0187500==37)*(R0187600>0)*R0187600 if StepFatherInHome_79==1;
replace StepFathersAge_79 = . if (StepFathersAge_79-floor(age_1979))<13 | (StepFathersAge_79-floor(age_1979))>70;                        

/* Stepfather age in 1980 */                                      
g StepFathersAge_80 = (R0393900==37)*(R0394000>0)*R0394000 + (R0394500==37)*(R0394600>0)*R0394600 + 
					  (R0395100==37)*(R0395200>0)*R0395200 + (R0395700==37)*(R0395800>0)*R0395800 +
                      (R0396300==37)*(R0396400>0)*R0396400 + (R0396900==37)*(R0397000>0)*R0397000 + 
                      (R0397500==37)*(R0397600>0)*R0397600 + (R0398100==37)*(R0398200>0)*R0398200 +
                      (R0398700==37)*(R0398800>0)*R0398800 + (R0399300==37)*(R0399400>0)*R0399400 + 
                      (R0399900==37)*(R0400000>0)*R0400000 + (R0400500==37)*(R0400600>0)*R0400600 +
                      (R0401100==37)*(R0401200>0)*R0401200 + (R0401700==37)*(R0401800>0)*R0401800 + 
                      (R0402300==37)*(R0402400>0)*R0402400 if StepFatherInHome_80==1;
replace StepFathersAge_80 = . if (StepFathersAge_80-1-floor(age_1979))<13 | (StepFathersAge_80-1-floor(age_1979))>70;

/* Stepfather age in 1981 */ 
g StepFathersAge_81 = (R0603300==37)*(R0603400>0)*R0603400 + (R0603900==37)*(R0604000>0)*R0604000 + 
					  (R0604500==37)*(R0604600>0)*R0604600 + (R0605100==37)*(R0605200>0)*R0605200 +
                      (R0605700==37)*(R0605800>0)*R0605800 + (R0606300==37)*(R0606400>0)*R0606400 + 
                      (R0606900==37)*(R0607000>0)*R0607000 + (R0607500==37)*(R0607600>0)*R0607600 +
                      (R0608100==37)*(R0608200>0)*R0608200 + (R0608700==37)*(R0608800>0)*R0608800 + 
                      (R0609300==37)*(R0609400>0)*R0609400 + (R0609900==37)*(R0610000>0)*R0610000 +
                      (R0610500==37)*(R0610600>0)*R0610600 + (R0611100==37)*(R0611200>0)*R0611200 + 
                      (R0611700==37)*(R0611800>0)*R0611800 if StepFatherInHome_81==1;
replace StepFathersAge_81 = . if (StepFathersAge_81-2-floor(age_1979))<13 | (StepFathersAge_81-2-floor(age_1979))>70;

/* Stepfather age in 1982 */
g StepFathersAge_82 = (R0817700==37)*(R0817800>0)*R0817800 + (R0818400==37)*(R0818500>0)*R0818500 + 
					  (R0819100==37)*(R0819200>0)*R0819200 + (R0819800==37)*(R0819900>0)*R0819900 +
                      (R0820500==37)*(R0820600>0)*R0820600 + (R0821200==37)*(R0821300>0)*R0821300 +
                      (R0821900==37)*(R0822000>0)*R0822000 + (R0822600==37)*(R0822700>0)*R0822700 +
                      (R0823300==37)*(R0823400>0)*R0823400 + (R0824000==37)*(R0824100>0)*R0824100 + 
                      (R0824700==37)*(R0824800>0)*R0824800 + (R0825400==37)*(R0825500>0)*R0825500 +
                      (R0826100==37)*(R0826200>0)*R0826200 + (R0826800==37)*(R0826900>0)*R0826900 + 
                      (R0827500==37)*(R0827600>0)*R0827600 if StepFatherInHome_82==1;
replace StepFathersAge_82 = . if (StepFathersAge_82-3-floor(age_1979))<13 | (StepFathersAge_82-3-floor(age_1979))>70;

/* Stepfather age in 1983 */
g StepFathersAge_83 = (R1055600==37)*(R1055700>0)*R1055700 + (R1056300==37)*(R1056400>0)*R1056400 + 
				      (R1057000==37)*(R1057100>0)*R1057100 + (R1057700==37)*(R1057800>0)*R1057800 +
                      (R1058400==37)*(R1058500>0)*R1058500 + (R1059100==37)*(R1059200>0)*R1059200 + 
                      (R1059800==37)*(R1059900>0)*R1059900 + (R1060500==37)*(R1060600>0)*R1060600 +
                      (R1061200==37)*(R1061300>0)*R1061300 + (R1061900==37)*(R1062000>0)*R1062000 +
                      (R1062600==37)*(R1062700>0)*R1062700 + (R1063300==37)*(R1063400>0)*R1063400 +
                      (R1064000==37)*(R1064100>0)*R1064100 + (R1064700==37)*(R1064800>0)*R1064800 + 
                      (R1065400==37)*(R1065500>0)*R1065500 if StepFatherInHome_83==1;
replace StepFathersAge_83 = . if (StepFathersAge_83-4-floor(age_1979))<13 | (StepFathersAge_83-4-floor(age_1979))>70;

/* Stepfather age in 1984 */
g StepFathersAge_84 = (R1441100==37)*(R1441200>0)*R1441200 + (R1441800==37)*(R1441900>0)*R1441900 + 
				  	  (R1442500==37)*(R1442600>0)*R1442600 + (R1443200==37)*(R1443300>0)*R1443300 +
                      (R1443900==37)*(R1444000>0)*R1444000 + (R1444600==37)*(R1444700>0)*R1444700 + 
                      (R1445300==37)*(R1445400>0)*R1445400 + (R1446000==37)*(R1446100>0)*R1446100 +
                      (R1446700==37)*(R1446800>0)*R1446800 + (R1447400==37)*(R1447500>0)*R1447500 + 
                      (R1448100==37)*(R1448200>0)*R1448200 + (R1448800==37)*(R1448900>0)*R1448900 +
                      (R1449500==37)*(R1449600>0)*R1449600 + (R1450200==37)*(R1450300>0)*R1450300 + 
                      (R1450900==37)*(R1451000>0)*R1451000 if StepFatherInHome_84==1;
replace StepFathersAge_84 = . if (StepFathersAge_84-5-floor(age_1979))<13 | (StepFathersAge_84-5-floor(age_1979))>70;

/* Stepfather age in 1985 */
g StepFathersAge_85 = (R1869500==37)*(R1869600>0)*R1869600 + (R1870200==37)*(R1870300>0)*R1870300 + 
					  (R1870900==37)*(R1871000>0)*R1871000 + (R1871600==37)*(R1871700>0)*R1871700 +
                      (R1872300==37)*(R1872400>0)*R1872400 + (R1873000==37)*(R1873100>0)*R1873100 + 
                      (R1873700==37)*(R1873800>0)*R1873800 + (R1874400==37)*(R1874500>0)*R1874500 +
                      (R1875100==37)*(R1875200>0)*R1875200 + (R1875800==37)*(R1875900>0)*R1875900 + 
                      (R1876500==37)*(R1876600>0)*R1876600 + (R1877200==37)*(R1877300>0)*R1877300 +
                      (R1877900==37)*(R1878000>0)*R1878000 + (R1878600==37)*(R1878700>0)*R1878700 + 
                      (R1879300==37)*(R1879400>0)*R1879400 if StepFatherInHome_85==1;
replace StepFathersAge_85 = . if (StepFathersAge_85-6-floor(age_1979))<13 | (StepFathersAge_85-6-floor(age_1979))>70;

/* Stepfather age in 1986 */
g StepFathersAge_86 = (R2235400==37)*(R2235500>0)*R2235500 + (R2236100==37)*(R2236200>0)*R2236200 + 
					  (R2236800==37)*(R2236900>0)*R2236900 + (R2237500==37)*(R2237600>0)*R2237600 +
                      (R2238200==37)*(R2238300>0)*R2238300 + (R2238900==37)*(R2239000>0)*R2239000 + 
                      (R2239600==37)*(R2239700>0)*R2239700 + (R2240300==37)*(R2240400>0)*R2240400 +
                      (R2241000==37)*(R2241100>0)*R2241100 + (R2241700==37)*(R2241800>0)*R2241800 + 
                      (R2242400==37)*(R2242500>0)*R2242500 + (R2243100==37)*(R2243200>0)*R2243200 +
                      (R2243800==37)*(R2243900>0)*R2243900 + (R2244500==37)*(R2244600>0)*R2244600 + 
                      (R2245200==37)*(R2245300>0)*R2245300 if StepFatherInHome_86==1;
replace StepFathersAge_86 = . if (StepFathersAge_86-7-floor(age_1979))<13 | (StepFathersAge_86-7-floor(age_1979))>70;

/* Stepfather age in 1987 */
g StepFathersAge_87 = (R2429800==37)*(R2429900>0)*R2429900 + (R2430500==37)*(R2430600>0)*R2430600 + 
					  (R2431200==37)*(R2431300>0)*R2431300 + (R2431900==37)*(R2432000>0)*R2432000 +
                      (R2432600==37)*(R2432700>0)*R2432700 + (R2433300==37)*(R2433400>0)*R2433400 + 
                      (R2434000==37)*(R2434100>0)*R2434100 + (R2434700==37)*(R2434800>0)*R2434800 +
                      (R2435400==37)*(R2435500>0)*R2435500 + (R2436100==37)*(R2436200>0)*R2436200 + 
                      (R2436800==37)*(R2436900>0)*R2436900 + (R2437500==37)*(R2437600>0)*R2437600 +
                      (R2438200==37)*(R2438300>0)*R2438300 + (R2438900==37)*(R2439000>0)*R2439000 + 
                      (R2439600==37)*(R2439700>0)*R2439700 if StepFatherInHome_87==1;
replace StepFathersAge_87 = . if (StepFathersAge_87-8-floor(age_1979))<13 | (StepFathersAge_87-8-floor(age_1979))>70;

/* Stepfather age in 1988 */
g StepFathersAge_88 = (R2750800==37)*(R2750900>0)*R2750900 + (R2751500==37)*(R2751600>0)*R2751600 + 
					  (R2752200==37)*(R2752300>0)*R2752300 + (R2752900==37)*(R2753000>0)*R2753000 +
                      (R2753600==37)*(R2753700>0)*R2753700 + (R2754300==37)*(R2754400>0)*R2754400 + 
                      (R2755000==37)*(R2755100>0)*R2755100 + (R2755700==37)*(R2755800>0)*R2755800 +
                      (R2756400==37)*(R2756500>0)*R2756500 + (R2757100==37)*(R2757200>0)*R2757200 + 
                      (R2757800==37)*(R2757900>0)*R2757900 + (R2758500==37)*(R2758600>0)*R2758600 +
                      (R2759200==37)*(R2759300>0)*R2759300 + (R2759900==37)*(R2760000>0)*R2760000 + 
                      (R2760600==37)*(R2760700>0)*R2760700 if StepFatherInHome_88==1; 
replace StepFathersAge_88 = . if (StepFathersAge_88-9-floor(age_1979))<13 | (StepFathersAge_88-9-floor(age_1979))>70;
                       
/**************************************************************************************************/
/* PARENTAL EDUCATION VARIABLES                                                                   */
/**************************************************************************************************/

/* get highest grade completed data for parents from baseline if available */
g HGC_FATH79r = R0007900 if R0007900>=0;
g HGC_MOTH79r = R0006500 if R0006500>=0;
g str100 HGC_FATH79r_Source = "Parental education question in 1979" if HGC_FATH79r~=.;
g str100 HGC_MOTH79r_Source = "Parental education question in 1979" if HGC_MOTH79r~=.;

/* use education data in 1979 household roster to fill in missing values for parents' education */
replace HGC_FATH79r   = (R0174900==4)*(R0175100>0)*R0175100 + (R0175800==4)*(R0176000>0)*R0176000 + 
					    (R0176700==4)*(R0176900>0)*R0176900 + (R0177600==4)*(R0177800>0)*R0177800 +
                        (R0178500==4)*(R0178700>0)*R0178700 + (R0179400==4)*(R0179600>0)*R0179600 + 
                        (R0180300==4)*(R0180500>0)*R0180500 + (R0181200==4)*(R0181400>0)*R0181400 +
                        (R0182100==4)*(R0182300>0)*R0182300 + (R0183000==4)*(R0183200>0)*R0183200 + 
                        (R0183900==4)*(R0184100>0)*R0184100 + (R0184800==4)*(R0185000>0)*R0185000 +
                        (R0185700==4)*(R0185900>0)*R0185900 + (R0186600==4)*(R0186800>0)*R0186800 + 
                        (R0187500==4)*(R0187700>0)*R0187700 if HGC_FATH79r==. & FatherInHome_79==1;
replace HGC_FATH79r = . if HGC_FATH79r<0 | HGC_FATH79r>20;

replace HGC_MOTH79r   = (R0174900==5)*(R0175100>0)*R0175100 + (R0175800==5)*(R0176000>0)*R0176000 + 
					    (R0176700==5)*(R0176900>0)*R0176900 + (R0177600==5)*(R0177800>0)*R0177800 +
                        (R0178500==5)*(R0178700>0)*R0178700 + (R0179400==5)*(R0179600>0)*R0179600 + 
                        (R0180300==5)*(R0180500>0)*R0180500 + (R0181200==5)*(R0181400>0)*R0181400 +
                        (R0182100==5)*(R0182300>0)*R0182300 + (R0183000==5)*(R0183200>0)*R0183200 + 
                        (R0183900==5)*(R0184100>0)*R0184100 + (R0184800==5)*(R0185000>0)*R0185000 +
                        (R0185700==5)*(R0185900>0)*R0185900 + (R0186600==5)*(R0186800>0)*R0186800 + 
                        (R0187500==5)*(R0187700>0)*R0187700 if HGC_MOTH79r==. & MotherInHome_79==1;
replace HGC_MOTH79r = . if HGC_MOTH79r<0 | HGC_MOTH79r>20;
replace HGC_FATH79r_Source = "Household roster 1979" if HGC_FATH79r_Source=="" & HGC_FATH79r~=.;
replace HGC_MOTH79r_Source = "Household roster 1979" if HGC_MOTH79r_Source=="" & HGC_MOTH79r~=.;

/* use education data in 1980 household roster to fill in missing values for parents' education */
/* NOTE: Need to add grade info for roster member #15 is missing in 1980 */
replace HGC_FATH79r = 	(R0393900==4)*(R0394100>0)*R0394100 + (R0394500==4)*(R0394700>0)*R0394700 + 
						(R0395100==4)*(R0395300>0)*R0395300 + (R0395700==4)*(R0395900>0)*R0395900 +
                     	(R0396300==4)*(R0396500>0)*R0396500 + (R0396900==4)*(R0397100>0)*R0397100 + 
                     	(R0397500==4)*(R0397700>0)*R0397700 + (R0398100==4)*(R0398300>0)*R0398300 +
                     	(R0398700==4)*(R0398900>0)*R0398900 + (R0399300==4)*(R0399500>0)*R0399500 + 
                     	(R0399900==4)*(R0400100>0)*R0400100 + (R0400500==4)*(R0400700>0)*R0400700 +
                     	(R0401100==4)*(R0401300>0)*R0401300 + (R0401700==4)*(R0401900>0)*R0401900
                     	if HGC_FATH79r==. & FatherInHome_80==1 & (R0402300~=4);
replace HGC_FATH79r = . if HGC_FATH79r<0 | HGC_FATH79r>20;

replace HGC_MOTH79r = 	(R0393900==5)*(R0394100>0)*R0394100 + (R0394500==5)*(R0394700>0)*R0394700 + 
						(R0395100==5)*(R0395300>0)*R0395300 + (R0395700==5)*(R0395900>0)*R0395900 +
                     	(R0396300==5)*(R0396500>0)*R0396500 + (R0396900==5)*(R0397100>0)*R0397100 + 
                     	(R0397500==5)*(R0397700>0)*R0397700 + (R0398100==5)*(R0398300>0)*R0398300 +
                     	(R0398700==5)*(R0398900>0)*R0398900 + (R0399300==5)*(R0399500>0)*R0399500 + 
                     	(R0399900==5)*(R0400100>0)*R0400100 + (R0400500==5)*(R0400700>0)*R0400700 +
                     	(R0401100==5)*(R0401300>0)*R0401300 + (R0401700==5)*(R0401900>0)*R0401900
                     	if HGC_MOTH79r==. & MotherInHome_80==1 & (R0402300~=5);
replace HGC_MOTH79r = . if HGC_MOTH79r<0 | HGC_MOTH79r>20;
replace HGC_FATH79r_Source = "Household roster 1980" if HGC_FATH79r_Source=="" & HGC_FATH79r~=.;
replace HGC_MOTH79r_Source = "Household roster 1980" if HGC_MOTH79r_Source=="" & HGC_MOTH79r~=.;


/* use education data in 1981 household roster to fill in missing values for parents' education */
replace HGC_FATH79r = 	(R0603300==4)*(R0603500>0)*R0603500 + (R0603900==4)*(R0604100>0)*R0604100 + 
						(R0604500==4)*(R0604700>0)*R0604700 + (R0605100==4)*(R0605300>0)*R0605300 +
                     	(R0605700==4)*(R0605900>0)*R0605900 + (R0606300==4)*(R0606500>0)*R0606500 + 
                     	(R0606900==4)*(R0607100>0)*R0607100 + (R0607500==4)*(R0607700>0)*R0607700 +
                     	(R0608100==4)*(R0608300>0)*R0608300 + (R0608700==4)*(R0608900>0)*R0608900 + 
                     	(R0609300==4)*(R0609500>0)*R0609500 + (R0609900==4)*(R0610100>0)*R0610100 +
                     	(R0610500==4)*(R0610700>0)*R0610700 + (R0611100==4)*(R0611300>0)*R0611300 + 
                     	(R0611700==4)*(R0611900>0)*R0611900 if HGC_FATH79r==. & FatherInHome_81==1;
replace HGC_FATH79r = . if HGC_FATH79r<0 | HGC_FATH79r>20;

replace HGC_MOTH79r = 	(R0603300==5)*(R0603500>0)*R0603500 + (R0603900==5)*(R0604100>0)*R0604100 + 
						(R0604500==5)*(R0604700>0)*R0604700 + (R0605100==5)*(R0605300>0)*R0605300 +
                     	(R0605700==5)*(R0605900>0)*R0605900 + (R0606300==5)*(R0606500>0)*R0606500 + 
                     	(R0606900==5)*(R0607100>0)*R0607100 + (R0607500==5)*(R0607700>0)*R0607700 +
                     	(R0608100==5)*(R0608300>0)*R0608300 + (R0608700==5)*(R0608900>0)*R0608900 + 
                     	(R0609300==5)*(R0609500>0)*R0609500 + (R0609900==5)*(R0610100>0)*R0610100 +
                     	(R0610500==5)*(R0610700>0)*R0610700 + (R0611100==5)*(R0611300>0)*R0611300 + 
                     	(R0611700==5)*(R0611900>0)*R0611900 if HGC_MOTH79r==. & MotherInHome_81==1;
replace HGC_MOTH79r = . if HGC_MOTH79r<0 | HGC_MOTH79r>20;
replace HGC_FATH79r_Source = "Household roster 1981" if HGC_FATH79r_Source=="" & HGC_FATH79r~=.;
replace HGC_MOTH79r_Source = "Household roster 1981" if HGC_MOTH79r_Source=="" & HGC_MOTH79r~=.;

/* create average parental education and interaction variables */
g HGC_PAR79r = (HGC_MOTH79r+HGC_FATH79r)/2;   
g HGC_MxF79r = HGC_MOTH79r*HGC_FATH79r;

/* create parental education data availability measures */
g str200 ParentsHGCAvailability = "(1) Both parents' education available" 	 if HGC_MOTH79r ~=. & HGC_FATH79r ~=. & core_sample==1;
replace  ParentsHGCAvailability	= "(2) Mother's education only" 			 if HGC_MOTH79r ~=. & HGC_FATH79r ==. & core_sample==1; 
replace  ParentsHGCAvailability	= "(3) Father's education only" 			 if HGC_MOTH79r ==. & HGC_FATH79r ~=. & core_sample==1;
replace  ParentsHGCAvailability	= "(4) Neither parents' education available" if HGC_MOTH79r ==. & HGC_FATH79r ==. & core_sample==1;                                                  
                   	
/**************************************************************************************************/
/* FAMILY INCOME AND WAGES ETC.                                                                   */
/**************************************************************************************************/

g family_income_pc79 	= R0217900 if R0217900>=0;
g own_wages_pc79        = R0155400 if R0155400>=0;
g spouse_wages_pc79     = R0155500 if R0155500>=0;
g family_size_79        = R0217502 if R0217502>0;

g family_income_pc80 	= R0406010 if R0406010>=0;
g own_wages_pc80        = R0312300 if R0312300>=0;
g spouse_wages_pc80     = R0312710 if R0312710>=0;
g family_size_80        = R0405210 if R0405210>0;

g family_income_pc81 	= R0618410 if R0618410>=0;
g own_wages_pc81        = R0482600 if R0482600>=0;
g spouse_wages_pc81     = R0482910 if R0482910>=0;
g family_size_81        = R0647103 if R0647103>0;

g family_income_pc82 	= R0898600 if R0898600>=0;
g own_wages_pc82        = R0782100 if R0782100>=0;
g spouse_wages_pc82     = R0784300 if R0784300>=0;
g family_size_82        = R0896710 if R0896710>0; 

g family_income_pc83 	= R1144500 if R1144500>=0;
g own_wages_pc83        = R1024000 if R1024000>=0;     /* universe for wage/salary is "all" in 1983 on */
g spouse_wages_pc83     = R1026200 if R1026200>=0;
g family_size_83        = R1144410 if R1144410>0;

g family_income_pc84 	= R1519700 if R1519700>=0;
g own_wages_pc84        = R1410700 if R1410700>=0;     
g spouse_wages_pc84     = R1412900 if R1412900>=0;
g family_size_84        = R1519610 if R1519610>0;

g family_income_pc85 	= R1890400 if R1890400>=0;
g own_wages_pc85        = R1778500 if R1778500>=0;     
g spouse_wages_pc85     = R1780700 if R1780700>=0;
g family_size_85        = R1890210 if R1890210>0;

g family_income_pc86 	= R2257500 if R2257500>=0;
g own_wages_pc86        = R2141600 if R2141600>=0;     
g spouse_wages_pc86     = R2143800 if R2143800>=0;
g family_size_86        = R2257410 if R2257410>0;

g family_income_pc87 	= R2444700 if R2444700>=0;
g own_wages_pc87        = R2350300 if R2350300>=0;     
g spouse_wages_pc87     = R2352500 if R2352500>=0;
g family_size_87        = R2444610 if R2444610>0;

g family_income_pc88 	= R2870200 if R2870200>=0;
g own_wages_pc88        = R2722500 if R2722500>=0;     
g spouse_wages_pc88     = R2724700 if R2724700>=0;
g family_size_88        = R2870110 if R2870110>0;

g family_income_pc89 	= R3074000 if R3074000>=0;
g own_wages_pc89        = R2971400 if R2971400>=0;     
g spouse_wages_pc89     = R2973600 if R2973600>=0;
g family_size_89        = R3073910 if R3073910>0;

g family_income_pc90 	= R3400700 if R3400700>=0;
g own_wages_pc90        = R3279400 if R3279400>=0;     
g spouse_wages_pc90     = R3281600 if R3281600>=0;
g partner_wages_pc90    = R3292200 if R3292200>=0;
g family_size_90        = R3400600 if R3400600>0;

g family_income_pc91 	= R3656100 if R3656100>=0;
g own_wages_pc91        = R3559000 if R3559000>=0;     
g spouse_wages_pc91     = R3561200 if R3561200>=0;
g partner_wages_pc91    = R3571800 if R3571800>=0;
g family_size_91        = R3656000 if R3656000>0;

g family_income_pc92 	= R4006600 if R4006600>=0;
g own_wages_pc92        = R3897100 if R3897100>=0;     
g spouse_wages_pc92     = R3899300 if R3899300>=0;
g partner_wages_pc92    = R3909900 if R3909900>=0;
g family_size_92        = R4006500 if R4006500>0;

g family_income_pc93 	= R4417700 if R4417700>=0;
g own_wages_pc93        = R4295100 if R4295100>=0;     
g spouse_wages_pc93     = R4314400 if R4314400>=0;
g partner_wages_pc93    = R4390800 if R4390800>=0;
g family_size_93        = R4417600 if R4417600>0;

g family_income_pc94 	= R5080700 if R5080700>=0;
g own_wages_pc94        = R4982800 if R4982800>=0;     
g spouse_wages_pc94     = R4996000 if R4996000>=0;
g family_size_94        = R5080600 if R5080600>0;

g family_income_pc96 	= R5166000 if R5166000>=0;
g own_wages_pc96        = R5626200 if R5626200>=0;     
g spouse_wages_pc96     = R5650800 if R5650800>=0;
g family_size_96        = R5165900 if R5165900>0;

g family_income_pc98 	= R6478700 if R6478700>=0;
g own_wages_pc98        = R6364600 if R6364600>=0;     
g spouse_wages_pc98     = R6374900 if R6374900>=0;
g family_size_98        = R6478600 if R6478600>0;

g family_income_pc00 	= R7006500 if R7006500>=0;
g own_wages_pc00        = R6909700 if R6909700>=0;     
g spouse_wages_pc00     = R6917800 if R6917800>=0;
g family_size_00        = R7006400 if R7006400>0;

/* NOTE: Additional variables available from this year onwards to improve earnings data */
g family_income_pc02 	= R7703700 if R7703700>=0;
g own_wages_pc02        = R7607800 if R7607800>=0;     
g spouse_wages_pc02     = R7617600 if R7617600>=0;
g family_size_02        = R7703600 if R7703600>0;

g family_income_pc04 	= R8496100 if R8496100>=0;
g own_wages_pc04        = R8316300 if R8316300>=0;     
g spouse_wages_pc04     = R8325800 if R8325800>=0;
g family_size_04        = R8496000 if R8496000>0;

g family_income_pc06 	= T0987800 if T0987800>=0;
g own_wages_pc06        = T0912400 if T0912400>=0;     
g spouse_wages_pc06     = T0920800 if T0920800>=0;
g family_size_06        = T0987600 if T0987600>0;

g family_income_pc08 	= T2210000 if T2210000>=0;
g own_wages_pc08        = T2076700 if T2076700>=0;     
g spouse_wages_pc08     = T2085500 if T2085500>=0;
g family_size_08        = T2209900 if T2209900>0;

/*****************************************************************************************************/
/* Flag units/year combinations with inconsistent household roster information                       */
/*****************************************************************************************************/

g mom_roster_flag_79 = 1 	if (MotherInHome_79>1 & MotherInHome_79~=.) | 
							   (StepMotherInHome_79>1 & StepMotherInHome_79~=.) | 
							   (MotherInHome_79>=1 & MotherInHome_79~=. & StepMotherInHome_79>=1 & StepMotherInHome_79~=.);
g dad_roster_flag_79 = 1 	if (FatherInHome_79>1 & FatherInHome_79~=.) | 
							   (StepFatherInHome_79>1 & StepFatherInHome_79~=.) | 
							   (FatherInHome_79>=1 & FatherInHome_79~=. & StepFatherInHome_79>=1 & StepFatherInHome_79~=.);
							   
g mom_roster_flag_80 = 1 	if (MotherInHome_80>1 & MotherInHome_80~=.) | 
							   (StepMotherInHome_80>1 & StepMotherInHome_80~=.) | 
							   (MotherInHome_80>=1 & MotherInHome_80~=. & StepMotherInHome_80>=1 & StepMotherInHome_80~=.);
g dad_roster_flag_80 = 1 	if (FatherInHome_80>1 & FatherInHome_80~=.) | 
							   (StepFatherInHome_80>1 & StepFatherInHome_80~=.) | 
							   (FatherInHome_80>=1 & FatherInHome_80~=. & StepFatherInHome_80>=1 & StepFatherInHome_80~=.);
							   
g mom_roster_flag_81 = 1 	if (MotherInHome_81>1 & MotherInHome_81~=.) | 
							   (StepMotherInHome_81>1 & StepMotherInHome_81~=.) | 
							   (MotherInHome_81>=1 & MotherInHome_81~=. & StepMotherInHome_81>=1 & StepMotherInHome_81~=.);
g dad_roster_flag_81 = 1 	if (FatherInHome_81>1 & FatherInHome_81~=.) | 
							   (StepFatherInHome_81>1 & StepFatherInHome_81~=.) | 
							   (FatherInHome_81>=1 & FatherInHome_81~=. & StepFatherInHome_81>=1 & StepFatherInHome_81~=.);
							   							   
g mom_roster_flag_82 = 1 	if (MotherInHome_82>1 & MotherInHome_82~=.) | 
							   (StepMotherInHome_82>1 & StepMotherInHome_82~=.) | 
							   (MotherInHome_82>=1 & MotherInHome_82~=. & StepMotherInHome_82>=1 & StepMotherInHome_82~=.);
g dad_roster_flag_82 = 1 	if (FatherInHome_82>1 & FatherInHome_82~=.) | 
							   (StepFatherInHome_82>1 & StepFatherInHome_82~=.) | 
							   (FatherInHome_82>=1 & FatherInHome_82~=. & StepFatherInHome_82>=1 & StepFatherInHome_82~=.);

g mom_roster_flag_83 = 1 	if (MotherInHome_83>1 & MotherInHome_83~=.) | 
							   (StepMotherInHome_83>1 & StepMotherInHome_83~=.) | 
							   (MotherInHome_83>=1 & MotherInHome_83~=. & StepMotherInHome_83>=1 & StepMotherInHome_83~=.);
g dad_roster_flag_83 = 1 	if (FatherInHome_83>1 & FatherInHome_83~=.) | 
							   (StepFatherInHome_83>1 & StepFatherInHome_83~=.) | 
							   (FatherInHome_83>=1 & FatherInHome_83~=. & StepFatherInHome_83>=1 & StepFatherInHome_83~=.);

g mom_roster_flag_84 = 1 	if (MotherInHome_84>1 & MotherInHome_84~=.) | 
							   (StepMotherInHome_84>1 & StepMotherInHome_84~=.) | 
							   (MotherInHome_84>=1 & MotherInHome_84~=. & StepMotherInHome_84>=1 & StepMotherInHome_84~=.);
g dad_roster_flag_84 = 1 	if (FatherInHome_84>1 & FatherInHome_84~=.) | 
							   (StepFatherInHome_84>1 & StepFatherInHome_84~=.) | 
							   (FatherInHome_84>=1 & FatherInHome_84~=. & StepFatherInHome_84>=1 & StepFatherInHome_84~=.);							   

g mom_roster_flag_85 = 1 	if (MotherInHome_85>1 & MotherInHome_85~=.) | 
							   (StepMotherInHome_85>1 & StepMotherInHome_85~=.) | 
							   (MotherInHome_85>=1 & MotherInHome_85~=. & StepMotherInHome_85>=1 & StepMotherInHome_85~=.);
g dad_roster_flag_85 = 1 	if (FatherInHome_85>1 & FatherInHome_85~=.) | 
							   (StepFatherInHome_85>1 & StepFatherInHome_85~=.) | 
							   (FatherInHome_85>=1 & FatherInHome_85~=. & StepFatherInHome_85>=1 & StepFatherInHome_85~=.);							   
							   
g mom_roster_flag_86 = 1 	if (MotherInHome_86>1 & MotherInHome_86~=.) | 
							   (StepMotherInHome_86>1 & StepMotherInHome_86~=.) | 
							   (MotherInHome_86>=1 & MotherInHome_86~=. & StepMotherInHome_86>=1 & StepMotherInHome_86~=.);
g dad_roster_flag_86 = 1 	if (FatherInHome_86>1 & FatherInHome_86~=.) | 
							   (StepFatherInHome_86>1 & StepFatherInHome_86~=.) | 
							   (FatherInHome_86>=1 & FatherInHome_86~=. & StepFatherInHome_86>=1 & StepFatherInHome_86~=.);							   
							   
g mom_roster_flag_87 = 1 	if (MotherInHome_87>1 & MotherInHome_87~=.) | 
							   (StepMotherInHome_87>1 & StepMotherInHome_87~=.) | 
							   (MotherInHome_87>=1 & MotherInHome_87~=. & StepMotherInHome_87>=1 & StepMotherInHome_87~=.);
g dad_roster_flag_87 = 1 	if (FatherInHome_87>1 & FatherInHome_87~=.) | 
							   (StepFatherInHome_87>1 & StepFatherInHome_87~=.) | 
							   (FatherInHome_87>=1 & FatherInHome_87~=. & StepFatherInHome_87>=1 & StepFatherInHome_87~=.);								   

g mom_roster_flag_88 = 1 	if (MotherInHome_88>1 & MotherInHome_88~=.) | 
							   (StepMotherInHome_88>1 & StepMotherInHome_88~=.) | 
							   (MotherInHome_88>=1 & MotherInHome_88~=. & StepMotherInHome_88>=1 & StepMotherInHome_88~=.);
g dad_roster_flag_88 = 1 	if (FatherInHome_88>1 & FatherInHome_88~=.) | 
							   (StepFatherInHome_88>1 & StepFatherInHome_88~=.) | 
							   (FatherInHome_88>=1 & FatherInHome_88~=. & StepFatherInHome_88>=1 & StepFatherInHome_88~=.);								   
							   
/*****************************************************************************************************/
/* GENERATE "HOUSEHOLD HEAD" AGE INFORMATION in 1979                                                 */
/* NOTE: Head is father, step-father or mother in that order                                         */
/*****************************************************************************************************/

g HouseholdHeadAge_79 = FathersAge_79 if FatherInHome_79==1;
g str100 HouseholdHeadAge_79_source = "Father" if HouseholdHeadAge_79~=.;
replace HouseholdHeadAge_79 = StepFathersAge_79 if HouseholdHeadAge_79==. & StepFatherInHome_79==1;
replace HouseholdHeadAge_79_source = "Step-Father" if HouseholdHeadAge_79_source=="" & HouseholdHeadAge_79~=.;
replace HouseholdHeadAge_79 = MothersAge_79 if HouseholdHeadAge_79==. & MotherInHome_79==1;
replace HouseholdHeadAge_79_source = "Mother" if HouseholdHeadAge_79_source=="" & HouseholdHeadAge_79~=.;

g HouseholdHeadAge_80 = FathersAge_79+1 if FatherInHome_80==1;
g str100 HouseholdHeadAge_80_source = "Father" if HouseholdHeadAge_80~=.;
replace HouseholdHeadAge_80 = StepFathersAge_80 if HouseholdHeadAge_80==. & StepFatherInHome_80==1;
replace HouseholdHeadAge_80_source = "Step-Father" if HouseholdHeadAge_80_source=="" & HouseholdHeadAge_80~=.;
replace HouseholdHeadAge_80 = MothersAge_79+1 if HouseholdHeadAge_80==. & MotherInHome_80==1;
replace HouseholdHeadAge_80_source = "Mother" if HouseholdHeadAge_80_source=="" & HouseholdHeadAge_80~=.;

g HouseholdHeadAge_81 = FathersAge_79+2 if FatherInHome_81==1;
g str100 HouseholdHeadAge_81_source = "Father" if HouseholdHeadAge_81~=.;
replace HouseholdHeadAge_81 = StepFathersAge_81 if HouseholdHeadAge_81==. & StepFatherInHome_81==1;
replace HouseholdHeadAge_81_source = "Step-Father" if HouseholdHeadAge_81_source=="" & HouseholdHeadAge_81~=.;
replace HouseholdHeadAge_81 = MothersAge_79+2 if HouseholdHeadAge_81==. & MotherInHome_81==1;
replace HouseholdHeadAge_81_source = "Mother" if HouseholdHeadAge_81_source=="" & HouseholdHeadAge_81~=.;

g HouseholdHeadAge_82 = FathersAge_79+3 if FatherInHome_82==1;
g str100 HouseholdHeadAge_82_source = "Father" if HouseholdHeadAge_82~=.;
replace HouseholdHeadAge_82 = StepFathersAge_82 if HouseholdHeadAge_82==. & StepFatherInHome_82==1;
replace HouseholdHeadAge_82_source = "Step-Father" if HouseholdHeadAge_82_source=="" & HouseholdHeadAge_82~=.;
replace HouseholdHeadAge_82 = MothersAge_79+3 if HouseholdHeadAge_82==. & MotherInHome_82==1;
replace HouseholdHeadAge_82_source = "Mother" if HouseholdHeadAge_82_source=="" & HouseholdHeadAge_82~=.;

g HouseholdHeadAge_83 = FathersAge_79+4 if FatherInHome_83==1;
g str100 HouseholdHeadAge_83_source = "Father" if HouseholdHeadAge_83~=.;
replace HouseholdHeadAge_83 = StepFathersAge_83 if HouseholdHeadAge_83==. & StepFatherInHome_83==1;
replace HouseholdHeadAge_83_source = "Step-Father" if HouseholdHeadAge_83_source=="" & HouseholdHeadAge_83~=.;
replace HouseholdHeadAge_83 = MothersAge_79+4 if HouseholdHeadAge_83==. & MotherInHome_83==1;
replace HouseholdHeadAge_83_source = "Mother" if HouseholdHeadAge_83_source=="" & HouseholdHeadAge_83~=.;

g HouseholdHeadAge_84 = FathersAge_79+5 if FatherInHome_84==1;
g str100 HouseholdHeadAge_84_source = "Father" if HouseholdHeadAge_84~=.;
replace HouseholdHeadAge_84 = StepFathersAge_84 if HouseholdHeadAge_84==. & StepFatherInHome_84==1;
replace HouseholdHeadAge_84_source = "Step-Father" if HouseholdHeadAge_84_source=="" & HouseholdHeadAge_84~=.;
replace HouseholdHeadAge_84 = MothersAge_79+5 if HouseholdHeadAge_84==. & MotherInHome_84==1;
replace HouseholdHeadAge_84_source = "Mother" if HouseholdHeadAge_84_source=="" & HouseholdHeadAge_84~=.;

g HouseholdHeadAge_85 = FathersAge_79+6 if FatherInHome_85==1;
g str100 HouseholdHeadAge_85_source = "Father" if HouseholdHeadAge_85~=.;
replace HouseholdHeadAge_85 = StepFathersAge_85 if HouseholdHeadAge_85==. & StepFatherInHome_85==1;
replace HouseholdHeadAge_85_source = "Step-Father" if HouseholdHeadAge_85_source=="" & HouseholdHeadAge_85~=.;
replace HouseholdHeadAge_85 = MothersAge_79+6 if HouseholdHeadAge_85==. & MotherInHome_85==1;
replace HouseholdHeadAge_85_source = "Mother" if HouseholdHeadAge_85_source=="" & HouseholdHeadAge_85~=.;

g HouseholdHeadAge_86 = FathersAge_79+7 if FatherInHome_86==1;
g str100 HouseholdHeadAge_86_source = "Father" if HouseholdHeadAge_86~=.; 
replace HouseholdHeadAge_86 = StepFathersAge_86 if HouseholdHeadAge_86==. & StepFatherInHome_86==1;
replace HouseholdHeadAge_86_source = "Step-Father" if HouseholdHeadAge_86_source=="" & HouseholdHeadAge_86~=.;
replace HouseholdHeadAge_86 = MothersAge_79+7 if HouseholdHeadAge_86==. & MotherInHome_86==1;
replace HouseholdHeadAge_86_source = "Mother" if HouseholdHeadAge_86_source=="" & HouseholdHeadAge_86~=.;

g HouseholdHeadAge_87 = FathersAge_79+8 if FatherInHome_87==1;
g str100 HouseholdHeadAge_87_source = "Father" if HouseholdHeadAge_87~=.;
replace HouseholdHeadAge_87 = StepFathersAge_87 if HouseholdHeadAge_87==. & StepFatherInHome_87==1;
replace HouseholdHeadAge_87_source = "Step-Father" if HouseholdHeadAge_87_source=="" & HouseholdHeadAge_87~=.;
replace HouseholdHeadAge_87 = MothersAge_79+8 if HouseholdHeadAge_87==. & MotherInHome_87==1;
replace HouseholdHeadAge_87_source = "Mother" if HouseholdHeadAge_87_source=="" & HouseholdHeadAge_87~=.;

g HouseholdHeadAge_88 = FathersAge_79+9 if FatherInHome_88==1;
g str100 HouseholdHeadAge_88_source = "Father" if HouseholdHeadAge_88~=.;
replace HouseholdHeadAge_88 = StepFathersAge_88 if HouseholdHeadAge_88==. & StepFatherInHome_88==1;
replace HouseholdHeadAge_88_source = "Step-Father" if HouseholdHeadAge_88_source=="" & HouseholdHeadAge_88~=.;
replace HouseholdHeadAge_88 = MothersAge_79+9 if HouseholdHeadAge_88==. & MotherInHome_88==1;
replace HouseholdHeadAge_88_source = "Mother" if HouseholdHeadAge_88_source=="" & HouseholdHeadAge_88~=.;																	   								   								   								   							   
				   							   
/*****************************************************************************************************/
/* GENERATE PARENTAL FAMILY INCOME VARIABLES                                                         */
/* NOTE: Deflate using the national CPI-U-R (research) index with 2010 = 100                         */
/*****************************************************************************************************/

g RPFIpc_78v1 = 3.202*(family_income_pc79/1.044)/family_size_79 if (MotherInHome_79==1 | FatherInHome_79==1) & age_1979-1<23 & HouseholdHeadAge_79~=.;
g RPFIpc_78v2 = 3.202*(family_income_pc79/1.044)/family_size_79 if MotherInHome_79==1 & FatherInHome_79==1 & age_1979-1<23 & HouseholdHeadAge_79~=.;
g RPFIpc_78v3 = 3.202*(family_income_pc79/1.044)/family_size_79 if (MotherInHome_79==1 | FatherInHome_79==1) & age_1979-1<19 & HouseholdHeadAge_79~=.;
g RPFIpc_78v4 = 3.202*(family_income_pc79/1.044)/family_size_79 if MotherInHome_79==1 & FatherInHome_79==1 & age_1979-1<19 & HouseholdHeadAge_79~=.;

replace RPFIpc_78v1 = . if RPFIpc_78v1<100;
replace RPFIpc_78v2 = . if RPFIpc_78v2<100;
replace RPFIpc_78v3 = . if RPFIpc_78v3<100;
replace RPFIpc_78v4 = . if RPFIpc_78v4<100;

g RPFI_78v1 = RPFIpc_78v1*family_size_79;
g RPFI_78v2 = RPFIpc_78v2*family_size_79;
g RPFI_78v3 = RPFIpc_78v3*family_size_79;
g RPFI_78v4 = RPFIpc_78v4*family_size_79;

g RPFIpc_79v1 = 3.202*(family_income_pc80/1.144)/family_size_80 if (MotherInHome_80==1 | FatherInHome_80==1) & age_1979<23 & HouseholdHeadAge_80~=.;
g RPFIpc_79v2 = 3.202*(family_income_pc80/1.144)/family_size_80 if MotherInHome_80==1 & FatherInHome_80==1 & age_1979<23 & HouseholdHeadAge_80~=.;
g RPFIpc_79v3 = 3.202*(family_income_pc80/1.144)/family_size_80 if (MotherInHome_80==1 | FatherInHome_80==1) & age_1979<19 & HouseholdHeadAge_80~=.;
g RPFIpc_79v4 = 3.202*(family_income_pc80/1.144)/family_size_80 if MotherInHome_80==1 & FatherInHome_80==1 & age_1979<19 & HouseholdHeadAge_80~=.;

replace RPFIpc_79v1 = . if RPFIpc_79v1<100;
replace RPFIpc_79v2 = . if RPFIpc_79v2<100;
replace RPFIpc_79v3 = . if RPFIpc_79v3<100;
replace RPFIpc_79v4 = . if RPFIpc_79v4<100;

g RPFI_79v1 = RPFIpc_79v1*family_size_80;
g RPFI_79v2 = RPFIpc_79v2*family_size_80;
g RPFI_79v3 = RPFIpc_79v3*family_size_80;
g RPFI_79v4 = RPFIpc_79v4*family_size_80;

g RPFIpc_80v1 = 3.202*(family_income_pc81/1.271)/family_size_81 if (MotherInHome_81==1 | FatherInHome_81==1) & age_1979+1<23 & HouseholdHeadAge_81~=.;
g RPFIpc_80v2 = 3.202*(family_income_pc81/1.271)/family_size_81 if MotherInHome_81==1 & FatherInHome_81==1 & age_1979+1<23 & HouseholdHeadAge_81~=.;
g RPFIpc_80v3 = 3.202*(family_income_pc81/1.271)/family_size_81 if (MotherInHome_81==1 | FatherInHome_81==1) & age_1979+1<19 & HouseholdHeadAge_81~=.;
g RPFIpc_80v4 = 3.202*(family_income_pc81/1.271)/family_size_81 if MotherInHome_81==1 & FatherInHome_81==1 & age_1979+1<19 & HouseholdHeadAge_81~=.;

replace RPFIpc_80v1 = . if RPFIpc_80v1<100;
replace RPFIpc_80v2 = . if RPFIpc_80v2<100;
replace RPFIpc_80v3 = . if RPFIpc_80v3<100;
replace RPFIpc_80v4 = . if RPFIpc_80v4<100;

g RPFI_80v1 = RPFIpc_80v1*family_size_81;
g RPFI_80v2 = RPFIpc_80v2*family_size_81;
g RPFI_80v3 = RPFIpc_80v3*family_size_81;
g RPFI_80v4 = RPFIpc_80v4*family_size_81;

g RPFIpc_81v1 = 3.202*(family_income_pc82/1.392)/family_size_82 if (MotherInHome_82==1 | FatherInHome_82==1) & age_1979+2<23 & HouseholdHeadAge_82~=.;
g RPFIpc_81v2 = 3.202*(family_income_pc82/1.392)/family_size_82 if MotherInHome_82==1 & FatherInHome_82==1 & age_1979+2<23 & HouseholdHeadAge_82~=.;
g RPFIpc_81v3 = 3.202*(family_income_pc82/1.392)/family_size_82 if (MotherInHome_82==1 | FatherInHome_82==1) & age_1979+2<19 & HouseholdHeadAge_82~=.;
g RPFIpc_81v4 = 3.202*(family_income_pc82/1.392)/family_size_82 if MotherInHome_82==1 & FatherInHome_82==1 & age_1979+2<19 & HouseholdHeadAge_82~=.;

replace RPFIpc_81v1 = . if RPFIpc_81v1<100;
replace RPFIpc_81v2 = . if RPFIpc_81v2<100;
replace RPFIpc_81v3 = . if RPFIpc_81v3<100;
replace RPFIpc_81v4 = . if RPFIpc_81v4<100;

g RPFI_81v1 = RPFIpc_81v1*family_size_82;
g RPFI_81v2 = RPFIpc_81v2*family_size_82;
g RPFI_81v3 = RPFIpc_81v3*family_size_82;
g RPFI_81v4 = RPFIpc_81v4*family_size_82;

g RPFIpc_82v1 = 3.202*(family_income_pc83/1.476)/family_size_83 if (MotherInHome_83==1 | FatherInHome_83==1) & age_1979+3<23 & HouseholdHeadAge_83~=.;
g RPFIpc_82v2 = 3.202*(family_income_pc83/1.476)/family_size_83 if MotherInHome_83==1 & FatherInHome_83==1 & age_1979+3<23 & HouseholdHeadAge_83~=.;
g RPFIpc_82v3 = 3.202*(family_income_pc83/1.476)/family_size_83 if (MotherInHome_83==1 | FatherInHome_83==1) & age_1979+3<19 & HouseholdHeadAge_83~=.;
g RPFIpc_82v4 = 3.202*(family_income_pc83/1.476)/family_size_83 if MotherInHome_83==1 & FatherInHome_83==1 & age_1979+3<19 & HouseholdHeadAge_83~=.;

replace RPFIpc_82v1 = . if RPFIpc_82v1<100;
replace RPFIpc_82v2 = . if RPFIpc_82v2<100;
replace RPFIpc_82v3 = . if RPFIpc_82v3<100;
replace RPFIpc_82v4 = . if RPFIpc_82v4<100;

g RPFI_82v1 = RPFIpc_82v1*family_size_83;
g RPFI_82v2 = RPFIpc_82v2*family_size_83;
g RPFI_82v3 = RPFIpc_82v3*family_size_83;
g RPFI_82v4 = RPFIpc_82v4*family_size_83;

g RPFIpc_83v1 = 3.202*(family_income_pc84/1.539)/family_size_84 if (MotherInHome_84==1 | FatherInHome_84==1) & age_1979+4<23 & HouseholdHeadAge_84~=.;
g RPFIpc_83v2 = 3.202*(family_income_pc84/1.539)/family_size_84 if MotherInHome_84==1 & FatherInHome_84==1 & age_1979+4<23 & HouseholdHeadAge_84~=.;
g RPFIpc_83v3 = 3.202*(family_income_pc84/1.539)/family_size_84 if (MotherInHome_84==1 | FatherInHome_84==1) & age_1979+4<19 & HouseholdHeadAge_84~=.;
g RPFIpc_83v4 = 3.202*(family_income_pc84/1.539)/family_size_84 if MotherInHome_84==1 & FatherInHome_84==1 & age_1979+4<19 & HouseholdHeadAge_84~=.;

replace RPFIpc_83v1 = . if RPFIpc_83v1<100;
replace RPFIpc_83v2 = . if RPFIpc_83v2<100;
replace RPFIpc_83v3 = . if RPFIpc_83v3<100;
replace RPFIpc_83v4 = . if RPFIpc_83v4<100;

g RPFI_83v1 = RPFIpc_83v1*family_size_84;
g RPFI_83v2 = RPFIpc_83v2*family_size_84;
g RPFI_83v3 = RPFIpc_83v3*family_size_84;
g RPFI_83v4 = RPFIpc_83v4*family_size_84;

g RPFIpc_84v1 = 3.202*(family_income_pc85/1.602)/family_size_85 if (MotherInHome_85==1 | FatherInHome_85==1) & age_1979+5<23 & HouseholdHeadAge_85~=.;
g RPFIpc_84v2 = 3.202*(family_income_pc85/1.602)/family_size_85 if MotherInHome_85==1 & FatherInHome_85==1 & age_1979+5<23 & HouseholdHeadAge_85~=.;

replace RPFIpc_84v1 = . if RPFIpc_84v1<100;
replace RPFIpc_84v2 = . if RPFIpc_84v2<100;

g RPFI_84v1 = RPFIpc_84v1*family_size_85;
g RPFI_84v2 = RPFIpc_84v2*family_size_85;

g RPFIpc_85v1 = 3.202*(family_income_pc86/1.657)/family_size_86 if (MotherInHome_86==1 | FatherInHome_86==1) & age_1979+6<23 & HouseholdHeadAge_86~=.;
g RPFIpc_85v2 = 3.202*(family_income_pc86/1.657)/family_size_86 if MotherInHome_86==1 & FatherInHome_86==1 & age_1979+6<23 & HouseholdHeadAge_86~=.;

replace RPFIpc_85v1 = . if RPFIpc_85v1<100;
replace RPFIpc_85v2 = . if RPFIpc_85v2<100;

g RPFI_85v1 = RPFIpc_85v1*family_size_86;
g RPFI_85v2 = RPFIpc_85v2*family_size_86;

g RPFIpc_86v1 = 3.202*(family_income_pc87/1.687)/family_size_87 if (MotherInHome_87==1 | FatherInHome_87==1) & age_1979+7<23 & HouseholdHeadAge_87~=.;
g RPFIpc_86v2 = 3.202*(family_income_pc87/1.687)/family_size_87 if MotherInHome_87==1 & FatherInHome_87==1 & age_1979+7<23 & HouseholdHeadAge_87~=.;

replace RPFIpc_86v1 = . if RPFIpc_86v1<100;
replace RPFIpc_86v2 = . if RPFIpc_86v2<100;

g RPFI_86v1 = RPFIpc_86v1*family_size_87;
g RPFI_86v2 = RPFIpc_86v2*family_size_87;

g RPFIpc_87v1 = 3.202*(family_income_pc88/1.744)/family_size_88 if (MotherInHome_88==1 | FatherInHome_88==1) & age_1979+8<23 & HouseholdHeadAge_88~=.;
g RPFIpc_87v2 = 3.202*(family_income_pc88/1.744)/family_size_88 if MotherInHome_88==1 & FatherInHome_88==1 & age_1979+8<23 & HouseholdHeadAge_88~=.;

replace RPFIpc_87v1 = . if RPFIpc_87v1<100;
replace RPFIpc_87v2 = . if RPFIpc_87v2<100;

g RPFI_87v1 = RPFIpc_87v1*family_size_88;
g RPFI_87v2 = RPFIpc_87v2*family_size_88;

/*****************************************************************************************************/
/* GENERATE A RESPONDENT-BY-WAVE DATA AVAILABILITY CODE                                              */
/*****************************************************************************************************/

g str200 DataAvailabilityCode79 = "(1) Lives with birth parents" 			if MotherInHome_79==1 & FatherInHome_79==1 & mom_roster_flag_79~=1 & dad_roster_flag_79~=1 & core_sample==1;
replace  DataAvailabilityCode79 = "(2) Lives with birth mother" 			if MotherInHome_79==1 & FatherInHome_79==0 & mom_roster_flag_79~=1 & dad_roster_flag_79~=1 & core_sample==1 & DataAvailabilityCode79=="";
replace  DataAvailabilityCode79 = "(3) Lives with birth father" 			if MotherInHome_79==0 & FatherInHome_79==1 & mom_roster_flag_79~=1 & dad_roster_flag_79~=1 & core_sample==1 & DataAvailabilityCode79=="";
replace  DataAvailabilityCode79 = "(4) Does not live with birth parent(s)" 	if MotherInHome_79==0 & FatherInHome_79==0 & mom_roster_flag_79~=1 & dad_roster_flag_79~=1 & core_sample==1 & DataAvailabilityCode79=="";
replace  DataAvailabilityCode79 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_79==1 | dad_roster_flag_79==1) & core_sample==1 & DataAvailabilityCode79=="";
replace  DataAvailabilityCode79 = "(6) Non-reponse" 						if (MotherInHome_79==. | FatherInHome_79==.) & core_sample==1 & DataAvailabilityCode79=="";

g str200 DataAvailabilityCode80 = "(1) Lives with birth parents" 			if MotherInHome_80==1 & FatherInHome_80==1 & mom_roster_flag_80~=1 & dad_roster_flag_80~=1 & core_sample==1;
replace  DataAvailabilityCode80 = "(2) Lives with birth mother" 			if MotherInHome_80==1 & FatherInHome_80==0 & mom_roster_flag_80~=1 & dad_roster_flag_80~=1 & core_sample==1 & DataAvailabilityCode80=="";
replace  DataAvailabilityCode80 = "(3) Lives with birth father" 			if MotherInHome_80==0 & FatherInHome_80==1 & mom_roster_flag_80~=1 & dad_roster_flag_80~=1 & core_sample==1 & DataAvailabilityCode80=="";
replace  DataAvailabilityCode80 = "(4) Does not live with birth parent(s)" 	if MotherInHome_80==0 & FatherInHome_80==0 & mom_roster_flag_80~=0 & dad_roster_flag_80~=1 & core_sample==1 & DataAvailabilityCode80=="";
replace  DataAvailabilityCode80 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_80==1 | dad_roster_flag_80==1) & core_sample==1 & DataAvailabilityCode80=="";
replace  DataAvailabilityCode80 = "(6) Non-reponse" 						if (MotherInHome_80==. | FatherInHome_80==.) & core_sample==1 & DataAvailabilityCode80=="";

g str200 DataAvailabilityCode81 = "(1) Lives with birth parents" 			if MotherInHome_81==1 & FatherInHome_81==1 & mom_roster_flag_81~=1 & dad_roster_flag_81~=1 & core_sample==1;
replace  DataAvailabilityCode81 = "(2) Lives with birth mother" 			if MotherInHome_81==1 & FatherInHome_81==0 & mom_roster_flag_81~=1 & dad_roster_flag_81~=1 & core_sample==1 & DataAvailabilityCode81=="";
replace  DataAvailabilityCode81 = "(3) Lives with birth father" 			if MotherInHome_81==0 & FatherInHome_81==1 & mom_roster_flag_81~=1 & dad_roster_flag_81~=1 & core_sample==1 & DataAvailabilityCode81=="";
replace  DataAvailabilityCode81 = "(4) Does not live with birth parent(s)" 	if MotherInHome_81==0 & FatherInHome_81==0 & mom_roster_flag_81~=0 & dad_roster_flag_81~=1 & core_sample==1 & DataAvailabilityCode81=="";
replace  DataAvailabilityCode81 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_81==1 | dad_roster_flag_81==1) & core_sample==1 & DataAvailabilityCode81=="";
replace  DataAvailabilityCode81 = "(6) Non-reponse" 						if (MotherInHome_81==. | FatherInHome_81==.) & core_sample==1 & DataAvailabilityCode81=="";

g str200 DataAvailabilityCode82 = "(1) Lives with birth parents" 			if MotherInHome_82==1 & FatherInHome_82==1 & mom_roster_flag_82~=1 & dad_roster_flag_82~=1 & core_sample==1;
replace  DataAvailabilityCode82 = "(2) Lives with birth mother" 			if MotherInHome_82==1 & FatherInHome_82==0 & mom_roster_flag_82~=1 & dad_roster_flag_82~=1 & core_sample==1 & DataAvailabilityCode82=="";
replace  DataAvailabilityCode82 = "(3) Lives with birth father" 			if MotherInHome_82==0 & FatherInHome_82==1 & mom_roster_flag_82~=1 & dad_roster_flag_82~=1 & core_sample==1 & DataAvailabilityCode82=="";
replace  DataAvailabilityCode82 = "(4) Does not live with birth parent(s)" 	if MotherInHome_82==0 & FatherInHome_82==0 & mom_roster_flag_82~=0 & dad_roster_flag_82~=1 & core_sample==1 & DataAvailabilityCode82=="";
replace  DataAvailabilityCode82 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_82==1 | dad_roster_flag_82==1) & core_sample==1 & DataAvailabilityCode82=="";
replace  DataAvailabilityCode82 = "(6) Non-reponse" 						if (MotherInHome_82==. | FatherInHome_82==.) & core_sample==1 & DataAvailabilityCode82=="";

g str200 DataAvailabilityCode83 = "(1) Lives with birth parents" 			if MotherInHome_83==1 & FatherInHome_83==1 & mom_roster_flag_83~=1 & dad_roster_flag_83~=1 & core_sample==1;
replace  DataAvailabilityCode83 = "(2) Lives with birth mother" 			if MotherInHome_83==1 & FatherInHome_83==0 & mom_roster_flag_83~=1 & dad_roster_flag_83~=1 & core_sample==1 & DataAvailabilityCode83=="";
replace  DataAvailabilityCode83 = "(3) Lives with birth father" 			if MotherInHome_83==0 & FatherInHome_83==1 & mom_roster_flag_83~=1 & dad_roster_flag_83~=1 & core_sample==1 & DataAvailabilityCode83=="";
replace  DataAvailabilityCode83 = "(4) Does not live with birth parent(s)" 	if MotherInHome_83==0 & FatherInHome_83==0 & mom_roster_flag_83~=0 & dad_roster_flag_83~=1 & core_sample==1 & DataAvailabilityCode83=="";
replace  DataAvailabilityCode83 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_83==1 | dad_roster_flag_83==1) & core_sample==1 & DataAvailabilityCode83=="";
replace  DataAvailabilityCode83 = "(6) Non-reponse" 						if (MotherInHome_83==. | FatherInHome_83==.) & core_sample==1 & DataAvailabilityCode83=="";

g str200 DataAvailabilityCode84 = "(1) Lives with birth parents" 			if MotherInHome_84==1 & FatherInHome_84==1 & mom_roster_flag_84~=1 & dad_roster_flag_84~=1 & core_sample==1;
replace  DataAvailabilityCode84 = "(2) Lives with birth mother" 			if MotherInHome_84==1 & FatherInHome_84==0 & mom_roster_flag_84~=1 & dad_roster_flag_84~=1 & core_sample==1 & DataAvailabilityCode84=="";
replace  DataAvailabilityCode84 = "(3) Lives with birth father" 			if MotherInHome_84==0 & FatherInHome_84==1 & mom_roster_flag_84~=1 & dad_roster_flag_84~=1 & core_sample==1 & DataAvailabilityCode84=="";
replace  DataAvailabilityCode84 = "(4) Does not live with birth parent(s)" 	if MotherInHome_84==0 & FatherInHome_84==0 & mom_roster_flag_84~=0 & dad_roster_flag_84~=1 & core_sample==1 & DataAvailabilityCode84=="";
replace  DataAvailabilityCode84 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_84==1 | dad_roster_flag_84==1) & core_sample==1 & DataAvailabilityCode84=="";
replace  DataAvailabilityCode84 = "(6) Non-reponse" 						if (MotherInHome_84==. | FatherInHome_84==.) & core_sample==1 & DataAvailabilityCode84=="";

g str200 DataAvailabilityCode85 = "(1) Lives with birth parents" 			if MotherInHome_85==1 & FatherInHome_85==1 & mom_roster_flag_85~=1 & dad_roster_flag_85~=1 & core_sample==1;
replace  DataAvailabilityCode85 = "(2) Lives with birth mother" 			if MotherInHome_85==1 & FatherInHome_85==0 & mom_roster_flag_85~=1 & dad_roster_flag_85~=1 & core_sample==1 & DataAvailabilityCode85=="";
replace  DataAvailabilityCode85 = "(3) Lives with birth father" 			if MotherInHome_85==0 & FatherInHome_85==1 & mom_roster_flag_85~=1 & dad_roster_flag_85~=1 & core_sample==1 & DataAvailabilityCode85=="";
replace  DataAvailabilityCode85 = "(4) Does not live with birth parent(s)" 	if MotherInHome_85==0 & FatherInHome_85==0 & mom_roster_flag_85~=0 & dad_roster_flag_85~=1 & core_sample==1 & DataAvailabilityCode85=="";
replace  DataAvailabilityCode85 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_85==1 | dad_roster_flag_85==1) & core_sample==1 & DataAvailabilityCode85=="";
replace  DataAvailabilityCode85 = "(6) Non-reponse" 						if (MotherInHome_85==. | FatherInHome_85==.) & core_sample==1 & DataAvailabilityCode85=="";

g str200 DataAvailabilityCode86 = "(1) Lives with birth parents" 			if MotherInHome_86==1 & FatherInHome_86==1 & mom_roster_flag_86~=1 & dad_roster_flag_86~=1 & core_sample==1;
replace  DataAvailabilityCode86 = "(2) Lives with birth mother" 			if MotherInHome_86==1 & FatherInHome_86==0 & mom_roster_flag_86~=1 & dad_roster_flag_86~=1 & core_sample==1 & DataAvailabilityCode86=="";
replace  DataAvailabilityCode86 = "(3) Lives with birth father" 			if MotherInHome_86==0 & FatherInHome_86==1 & mom_roster_flag_86~=1 & dad_roster_flag_86~=1 & core_sample==1 & DataAvailabilityCode86=="";
replace  DataAvailabilityCode86 = "(4) Does not live with birth parent(s)" 	if MotherInHome_86==0 & FatherInHome_86==0 & mom_roster_flag_86~=0 & dad_roster_flag_86~=1 & core_sample==1 & DataAvailabilityCode86=="";
replace  DataAvailabilityCode86 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_86==1 | dad_roster_flag_86==1) & core_sample==1 & DataAvailabilityCode86=="";
replace  DataAvailabilityCode86 = "(6) Non-reponse" 						if (MotherInHome_86==. | FatherInHome_86==.) & core_sample==1 & DataAvailabilityCode86=="";

g str200 DataAvailabilityCode87 = "(1) Lives with birth parents" 			if MotherInHome_87==1 & FatherInHome_87==1 & mom_roster_flag_87~=1 & dad_roster_flag_87~=1 & core_sample==1;
replace  DataAvailabilityCode87 = "(2) Lives with birth mother" 			if MotherInHome_87==1 & FatherInHome_87==0 & mom_roster_flag_87~=1 & dad_roster_flag_87~=1 & core_sample==1 & DataAvailabilityCode87=="";
replace  DataAvailabilityCode87 = "(3) Lives with birth father" 			if MotherInHome_87==0 & FatherInHome_87==1 & mom_roster_flag_87~=1 & dad_roster_flag_87~=1 & core_sample==1 & DataAvailabilityCode87=="";
replace  DataAvailabilityCode87 = "(4) Does not live with birth parent(s)" 	if MotherInHome_87==0 & FatherInHome_87==0 & mom_roster_flag_87~=0 & dad_roster_flag_87~=1 & core_sample==1 & DataAvailabilityCode87=="";
replace  DataAvailabilityCode87 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_87==1 | dad_roster_flag_87==1) & core_sample==1 & DataAvailabilityCode87=="";
replace  DataAvailabilityCode87 = "(6) Non-reponse" 						if (MotherInHome_87==. | FatherInHome_87==.) & core_sample==1 & DataAvailabilityCode87=="";

g str200 DataAvailabilityCode88 = "(1) Lives with birth parents" 			if MotherInHome_88==1 & FatherInHome_88==1 & mom_roster_flag_88~=1 & dad_roster_flag_88~=1 & core_sample==1;
replace  DataAvailabilityCode88 = "(2) Lives with birth mother" 			if MotherInHome_88==1 & FatherInHome_88==0 & mom_roster_flag_88~=1 & dad_roster_flag_88~=1 & core_sample==1 & DataAvailabilityCode88=="";
replace  DataAvailabilityCode88 = "(3) Lives with birth father" 			if MotherInHome_88==0 & FatherInHome_88==1 & mom_roster_flag_88~=1 & dad_roster_flag_88~=1 & core_sample==1 & DataAvailabilityCode88=="";
replace  DataAvailabilityCode88 = "(4) Does not live with birth parent(s)" 	if MotherInHome_88==0 & FatherInHome_88==0 & mom_roster_flag_88~=0 & dad_roster_flag_88~=1 & core_sample==1 & DataAvailabilityCode88=="";
replace  DataAvailabilityCode88 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_88==1 | dad_roster_flag_88==1) & core_sample==1 & DataAvailabilityCode88=="";
replace  DataAvailabilityCode88 = "(6) Non-reponse" 						if (MotherInHome_88==. | FatherInHome_88==.) & core_sample==1 & DataAvailabilityCode88=="";

/****************************************************************************************************/
/* COMPUTE MEASURES OF AVERAGE PARENTAL/FAMILY INCOME DURING ADOLESCENCE                            */
/* NOTE: Use the "third" income measure defined above (i.e., at least one parent, less <= 18 years) */
/****************************************************************************************************/

/* per capita measure */ 
egen RPFIpc_Avg = rowmean(RPFIpc_78v3 RPFIpc_79v3 RPFIpc_80v3 RPFIpc_81v3 RPFIpc_82v3 RPFIpc_83v3);                         
egen numRPFIpc 	= rownonmiss(RPFIpc_78v3 RPFIpc_79v3 RPFIpc_80v3 RPFIpc_81v3 RPFIpc_82v3 RPFIpc_83v3);                                   

/* non per capita measure */
egen RPFI_Avg  	= rowmean(RPFI_78v3 RPFI_79v3 RPFI_80v3 RPFI_81v3 RPFI_82v3 RPFI_83v3);

/* average age of household head */
g hh78 = (HouseholdHeadAge_79-1) if RPFIpc_78v3~=.;
g hh79 = (HouseholdHeadAge_80-1) if RPFIpc_79v3~=.; 
g hh80 = (HouseholdHeadAge_81-1) if RPFIpc_80v3~=.;
g hh81 = (HouseholdHeadAge_82-1) if RPFIpc_81v3~=.;
g hh82 = (HouseholdHeadAge_83-1) if RPFIpc_82v3~=.;
g hh83 = (HouseholdHeadAge_84-1) if RPFIpc_83v3~=.;
                              
egen AvgHeadAge = rowmean(hh78 hh79 hh80 hh81 hh82 hh83);
drop hh78-hh83;

/* average family size */
g fs78 = (family_size_79) if RPFIpc_78v3~=.;
g fs79 = (family_size_80) if RPFIpc_79v3~=.; 
g fs80 = (family_size_81) if RPFIpc_80v3~=.;
g fs81 = (family_size_82) if RPFIpc_81v3~=.;
g fs82 = (family_size_83) if RPFIpc_82v3~=.;
g fs83 = (family_size_84) if RPFIpc_83v3~=.;
                              
egen AvgFamSize = rowmean(fs78 fs79 fs80 fs81 fs82 fs83);
drop fs78-fs83;
                                                                 
/*****************************************************************************************************/
/* GENERATE CHILD FAMILY INCOME VARIABLES                                                            */
/* NOTE: Deflate using the national CPI-U-R (research) index with 2010 = 100                         */
/*       Only start measuring income at age 22 and greater                                           */
/*****************************************************************************************************/

g RCFIpc_1982 = 3.202*(family_income_pc83/1.476)/family_size_83 if age_1979>=19;
replace RCFIpc_1982 = . if RCFIpc_1982<100;
g RCFI_1982 = RCFIpc_1982*family_size_83;

g RCFIpc_1983 = 3.202*(family_income_pc84/1.539)/family_size_84 if age_1979>=18;
replace RCFIpc_1983 = . if RCFIpc_1983<100;
g RCFI_1983 = RCFIpc_1983*family_size_84;

g RCFIpc_1984 = 3.202*(family_income_pc85/1.602)/family_size_85 if age_1979>=17;
replace RCFIpc_1984 = . if RCFIpc_1984<100;
g RCFI_1984 = RCFIpc_1984*family_size_85;

g RCFIpc_1985 = 3.202*(family_income_pc86/1.657)/family_size_86 if age_1979>=16;
replace RCFIpc_1985 = . if RCFIpc_1985<100;
g RCFI_1985 = RCFIpc_1985*family_size_86;

g RCFIpc_1986 = 3.202*(family_income_pc87/1.687)/family_size_87 if age_1979>=15;
replace RCFIpc_1986 = . if RCFIpc_1986<100;
g RCFI_1986 = RCFIpc_1986*family_size_87;

g RCFIpc_1987 = 3.202*(family_income_pc88/1.744)/family_size_88 if age_1979>=14;
replace RCFIpc_1987 = . if RCFIpc_1987<100;
g RCFI_1987 = RCFIpc_1987*family_size_88;

g RCFIpc_1988 = 3.202*(family_income_pc89/1.808)/family_size_89 if age_1979>=13;
replace RCFIpc_1988 = . if RCFIpc_1988<100;
g RCFI_1988 = RCFIpc_1988*family_size_89;

g RCFIpc_1989 = 3.202*(family_income_pc90/1.886)/family_size_90;
replace RCFIpc_1989 = . if RCFIpc_1989<100;
g RCFI_1989 = RCFIpc_1989*family_size_90;

g RCFIpc_1990 = 3.202*(family_income_pc91/1.980)/family_size_91;
replace RCFIpc_1990 = . if RCFIpc_1990<100;
g RCFI_1990 = RCFIpc_1990*family_size_91;

g RCFIpc_1991 = 3.202*(family_income_pc92/2.051)/family_size_92;
replace RCFIpc_1991 = . if RCFIpc_1991<100;
g RCFI_1991 = RCFIpc_1991*family_size_92;

g RCFIpc_1992 = 3.202*(family_income_pc93/2.103)/family_size_93;
replace RCFIpc_1992 = . if RCFIpc_1992<100;
g RCFI_1992 = RCFIpc_1992*family_size_93;

g RCFIpc_1993 = 3.202*(family_income_pc94/2.155)/family_size_94;
replace RCFIpc_1993 = . if RCFIpc_1993<100;
g RCFI_1993 = RCFIpc_1993*family_size_94;

g RCFIpc_1995 = 3.202*(family_income_pc96/2.254)/family_size_96;
replace RCFIpc_1995 = . if RCFIpc_1995<100;
g RCFI_1995 = RCFIpc_1995*family_size_96;

g RCFIpc_1997 = 3.202*(family_income_pc98/2.364)/family_size_98;
replace RCFIpc_1997 = . if RCFIpc_1997<100;
g RCFI_1997 = RCFIpc_1997*family_size_98;

g RCFIpc_1999 = 3.202*(family_income_pc00/2.447)/family_size_00;
replace RCFIpc_1999 = . if RCFIpc_1999<100;
g RCFI_1999 = RCFIpc_1999*family_size_00;

g RCFIpc_2001 = 3.202*(family_income_pc02/2.600)/family_size_02;
replace RCFIpc_2001 = . if RCFIpc_2001<100;
g RCFI_2001 = RCFIpc_2001*family_size_02;

g RCFIpc_2003 = 3.202*(family_income_pc04/2.701)/family_size_04;
replace RCFIpc_2003 = . if RCFIpc_2003<100;
g RCFI_2003 = RCFIpc_2003*family_size_04;

g RCFIpc_2005 = 3.202*(family_income_pc06/2.867)/family_size_06;
replace RCFIpc_2005 = . if RCFIpc_2005<100;
g RCFI_2005 = RCFIpc_2005*family_size_06;

g RCFIpc_2007 = 3.202*(family_income_pc08/3.045)/family_size_08;
replace RCFIpc_2005 = . if RCFIpc_2005<100;
g RCFI_2007 = RCFIpc_2007*family_size_08;

/* Compute measures of average respondent income over early adulthood */
egen RCFIpc_Avg = rowmean(RCFIpc_1982 RCFIpc_1983 RCFIpc_1984 RCFIpc_1985
                          RCFIpc_1986 RCFIpc_1987
                          RCFIpc_1988 RCFIpc_1989 RCFIpc_1990 RCFIpc_1991
                          RCFIpc_1992 RCFIpc_1993 RCFIpc_1995 RCFIpc_1997
                          RCFIpc_1999 RCFIpc_2001 RCFIpc_2003 RCFIpc_2005
                          RCFIpc_2007);                         
egen RCFI_Avg 	= rowmean(RCFI_1982 RCFI_1983 RCFI_1984 RCFI_1985
						  RCFI_1986 RCFI_1987 
						  RCFI_1988 RCFI_1989 RCFI_1990 RCFI_1991
                          RCFI_1992 RCFI_1993 RCFI_1995 RCFI_1997
                          RCFI_1999 RCFI_2001 RCFI_2003 RCFI_2005
                          RCFI_2007);                                                          
egen NumberOfAdultIncomes = rownonmiss(RCFIpc_1982 RCFIpc_1983 RCFIpc_1984 RCFIpc_1985
						  RCFIpc_1986 RCFIpc_1987
						  RCFIpc_1988 RCFIpc_1989 RCFIpc_1990 RCFIpc_1991
                          RCFIpc_1992 RCFIpc_1993 RCFIpc_1995 RCFIpc_1997
                          RCFIpc_1999 RCFIpc_2001 RCFIpc_2003 RCFIpc_2005
                          RCFIpc_2007);
                                       
/* average age of child during period of "adult" income measurement */
g ca82 = (age_1979+3) if RCFIpc_1982~=.;
g ca83 = (age_1979+4) if RCFIpc_1983~=.;
g ca84 = (age_1979+5) if RCFIpc_1984~=.;
g ca85 = (age_1979+6) if RCFIpc_1985~=.;
g ca86 = (age_1979+7) if RCFIpc_1986~=.;
g ca87 = (age_1979+8) if RCFIpc_1987~=.;
g ca88 = (age_1979+9) if RCFIpc_1988~=.;
g ca89 = (age_1979+10) if RCFIpc_1989~=.;
g ca90 = (age_1979+11) if RCFIpc_1990~=.;
g ca91 = (age_1979+12) if RCFIpc_1991~=.;
g ca92 = (age_1979+13) if RCFIpc_1992~=.;
g ca93 = (age_1979+14) if RCFIpc_1993~=.;
g ca95 = (age_1979+16) if RCFIpc_1995~=.;
g ca97 = (age_1979+18) if RCFIpc_1997~=.;
g ca99 = (age_1979+20) if RCFIpc_1999~=.;
g ca01 = (age_1979+22) if RCFIpc_2001~=.;
g ca03 = (age_1979+24) if RCFIpc_2003~=.;
g ca05 = (age_1979+26) if RCFIpc_2005~=.;
g ca07 = (age_1979+28) if RCFIpc_2007~=.;
                              
egen AvgChildAge = rowmean(ca82 ca83 ca84 ca85 ca86 ca87 
						   ca88 ca89 ca90 ca91 ca92 ca93 ca95 ca97 ca99 ca01 ca03 ca05 ca07);
drop ca82-ca07;
/* average family size */
g fs82 = (family_size_83) if RCFIpc_1982~=.;
g fs83 = (family_size_84) if RCFIpc_1983~=.;
g fs84 = (family_size_85) if RCFIpc_1984~=.;
g fs85 = (family_size_86) if RCFIpc_1985~=.;
g fs86 = (family_size_87) if RCFIpc_1986~=.;
g fs87 = (family_size_88) if RCFIpc_1987~=.;
g fs88 = (family_size_89) if RCFIpc_1988~=.;
g fs89 = (family_size_90) if RCFIpc_1989~=.;
g fs90 = (family_size_91) if RCFIpc_1990~=.;
g fs91 = (family_size_92) if RCFIpc_1991~=.;
g fs92 = (family_size_93) if RCFIpc_1992~=.;
g fs93 = (family_size_94) if RCFIpc_1993~=.;
g fs95 = (family_size_96) if RCFIpc_1995~=.;
g fs97 = (family_size_98) if RCFIpc_1997~=.;
g fs99 = (family_size_00) if RCFIpc_1999~=.;
g fs01 = (family_size_02) if RCFIpc_2001~=.;
g fs03 = (family_size_04) if RCFIpc_2003~=.;
g fs05 = (family_size_06) if RCFIpc_2005~=.;
g fs07 = (family_size_08) if RCFIpc_2007~=.;
                              
egen AvgChildFamSize = rowmean(fs82 fs83 fs84 fs85 fs86 fs87
							   fs88 fs89 fs90 fs91 fs92 fs93 fs95 fs97 fs99 fs01 fs03 fs05 fs07);
drop fs82-fs07;

sort PID_79;
save "$WRITE_DATA/PewNLSY79_AnalyticBase", replace;
save "$WRITE_DATA_TEACHING/NLSY79_BaseFile", replace;

log using "$WRITE_DATA/PewMobilityNLSY79_SummaryStatistics", replace;
log on;

/*****************************************************************************************************/
/* MERGE WITH CONFIDENTIAL GEOCODE DATA                                                              */
/*****************************************************************************************************/    

/* Get SMSA codes from confidential BLS files */
merge 1:1 PID_79 using "$WRITE_DATA/PewNLSY79_MSACodes_79_82";
g SMSA81 = SMSA_79 if SMSA_79>0;
 
tab SMSA81 if core_sample==1, missing;
tab SMSA81 if core_sample==1 & age_1979<20, missing;

drop _merge;
sort PID_79;
save "$WRITE_DATA/PewNLSY79_AnalyticBase", replace;

sort SMSA81;
merge m:1 SMSA81 using "$WRITE_DATA/PewNLSY79_MSANames";
tab SMSA81 if _merge==1, missing;
tab SMSA81 if _merge==2, missing;
drop if _merge==2;
drop _merge;
save "$WRITE_DATA/PewNLSY79_AnalyticBase", replace;
log off;

/* import the 1979-to-1997 MSA concordance */
insheet using "$GEOCODE_DATA/MSA81To99Concordance.csv", comma clear;
rename smsa81 SMSA81;
drop if SMSA81==.;
sort SMSA81;
save "$WRITE_DATA/MSA81To99Concordance_temp", replace;

/* merge concordance codes with 1979 data */
use "$WRITE_DATA/PewNLSY79_AnalyticBase", clear;
sort SMSA81;
merge m:1 SMSA81 using "$WRITE_DATA/MSA81To99Concordance_temp";
tab _merge;
tab SMSA81 if _merge==1, missing;
tab SMSA81 if _merge==2, missing;
drop if _merge==2;
drop _merge;
capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
rename PlaceName PlaceName81;
drop scsa81 msapma99 msacma99 pmsa99 necma99 placename99 msapma99m msacma99m pmsa99m necma99m;
save "$WRITE_DATA/PewNLSY79_AnalyticBase", replace;
erase "$WRITE_DATA/MSA81To99Concordance_temp.dta";

/* Count the number of households per MSA */
drop if MSA==.;
drop if core_sample~=1;
bys MSA: egen NumIndividualsInMSA = sum((core_sample==1));
bys MSA: egen NumIndividualsInMSAUnder19 = sum((core_sample==1)*(age_1979<20));
collapse NumIndividualsInMSA NumIndividualsInMSAUnder19, by(MSA);

tab NumIndividualsInMSA;
tab NumIndividualsInMSAUnder19;

/*****************************************************************************************************/
/* MERGE WITH NEIGHBORHOOD CHANGE DATA (Concordance codes, 1980 census tracts)                       */
/*****************************************************************************************************/    

/* sort NCDB files by MSA code */
use "$WRITE_DATA/msa_ncdb_1980cw", clear;
sort MSA;
save "$WRITE_DATA/msa_ncdb_1980cw", replace;
use "$WRITE_DATA/PewNLSY79_AnalyticBase", clear;
sort MSA;

log on;
merge m:1 MSA using "$WRITE_DATA/msa_ncdb_1980cw", keep(1 2 3);
tab MSA if _merge==1, missing;
tab MSA if _merge==2, missing;
drop if _merge==2;
drop _merge;
log off;

/*****************************************************************************************************/
/* Merge with county and city factbook data in NLSY79 geocode files (uses 1981 SMSA codes)           */
/*****************************************************************************************************/

sort PID_79;
merge 1:1 PID_79 using "$WRITE_DATA/PewNLSY79_FactbookData";
drop _merge;

/*****************************************************************************************************/
/* Merge with State and Metropolitan Area Data Book, 1982 files (uses 1981 SMSA codes)               */
/*****************************************************************************************************/

log on;
merge m:1 SMSA81 using "$WRITE_DATA/Pew_SMADB82", keep(1 2 3);
tab SMSA81 if _merge==1, missing;
tab SMSA81 if _merge==2, missing;
drop if _merge==2;
drop _merge;
log off;
   
/*****************************************************************************************************/
/* SOME BASIC INTERGENERATIONAL MOBILITY RESULTS                                                     */
/*****************************************************************************************************/

g InMatchedMSA = (MSA~=.);
g HaveNSIIncInfo = (NSI_80~=.);
save "$WRITE_DATA/PewNLSY79_AnalyticBase", replace;

/**************************************/
/* INCOME MOBILITY                    */
/**************************************/

/***************************************/
/* Basic features of estimation sample */
/***************************************/

/* Count the number of households per MSA with needed data */
drop if MSA==.;
drop if core_sample~=1;
drop if numRPFIpc<1;
drop if NumberOfAdultIncomes<1;
drop if age_1979>=20;
drop if InMatchedMSA~=1;
bys MSA: egen NumHouseholdsInMSA = sum((core_sample==1)*(age_1979<20));
collapse NumHouseholdsInMSA, by(MSA);

log on;
tab NumHouseholdsInMSA;
tab NumHouseholdsInMSA if NumHouseholdsInMSA<10;
tab NumHouseholdsInMSA if NumHouseholdsInMSA>=10;
log off;

use "$WRITE_DATA/PewNLSY79_AnalyticBase", clear;
log on;

/*****************************************************************************************************/
/* SOME BASIC SUMMARY STATISTICS FOR THE NLSY79                                                      */
/* CORE SAMPLE INCLUDES THOSE AGE 19 & UNDER AT BASELINE AND RESIDENT IN AN SMSA                     */
/*****************************************************************************************************/

/*****************************************************************************************************/
/* EDUCATION/AGE INFORMATION                                                                         */
/*****************************************************************************************************/

log on;
tab core_sample;
tab core_sample if age_1979<20;
tab core_sample if age_1979<20 & InMatchedMSA==1;

/* Summarize parental education data availability */
tab HGC_FATH79r if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HGC_FATH79r_Source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;

tab HGC_MOTH79r if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HGC_MOTH79r_Source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;

tab ParentsHGCAvailability if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab ParentsHGCAvailability if core_sample==1 & age_1979<20 & InMatchedMSA==1;

/* Summarize parent age data availability */
sum FathersAge_79 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab FathersAge_79_Source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
sum MothersAge_79 if core_sample==1 & age_1979<20 & InMatchedMSA==1,;
tab MothersAge_79_Source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;

/* Summarize estimation sample for parent-child educational transmission */
tab HGC_Age24 if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HGC_Age28 if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;

sum HGC_Age24 HGC_FATH79r FathersAge_79 HGC_MOTH79r MothersAge_79 black hispanic male
	if HGC_Age24~=. & HGC_FATH79r~=. & FathersAge_79~=. & HGC_MOTH79r~=. & MothersAge_79~=. & core_sample==1 & age_1979<20 & InMatchedMSA==1;	
	
sum HGC_Age24 HGC_FATH79r FathersAge_79 HGC_MOTH79r MothersAge_79 black hispanic male
	if HGC_Age24~=. & HGC_FATH79r~=. & FathersAge_79~=. & HGC_MOTH79r~=. & MothersAge_79~=. & core_sample==1 & age_1979<20 & InMatchedMSA==1 & black==1;	

sum HGC_Age24 HGC_FATH79r FathersAge_79 HGC_MOTH79r MothersAge_79 black hispanic male
	if HGC_Age24~=. & HGC_FATH79r~=. & FathersAge_79~=. & HGC_MOTH79r~=. & MothersAge_79~=. & core_sample==1 & age_1979<20 & InMatchedMSA==1 & hispanic==1;	

/* Summarize parental co-residence information for respondents aged 19 or under at baseline */
tab DataAvailabilityCode79 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode80 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode81 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode82 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode83 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode84 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode85 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode86 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode87 if core_sample==1 & age_1979<20 & InMatchedMSA==1;
tab DataAvailabilityCode88 if core_sample==1 & age_1979<20 & InMatchedMSA==1;


/* Source of household head age information */
tab HouseholdHeadAge_79_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_80_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_81_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_82_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_83_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_84_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_85_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_86_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_87_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
tab HouseholdHeadAge_88_source if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;
log off;


log on;
/***************************************************************************************************/
/* BASIC STATISTICS FOR INCOME MOBILITY ESTIMATION SAMPLE                                          */
/* NOTE: Focus on core_sample aged 19 or under at baseline                                         */
/***************************************************************************************************/

/* Summary of parental generation income data */
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize if numRPFIpc>0  & core_sample==1 & age_1979<20 & InMatchedMSA==1;

/* Summary of child generation income data */
tab NumberOfAdultIncomes if core_sample==1 & age_1979<20 & InMatchedMSA==1, missing;

/* Union sample */
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize 
	RCFIpc_Avg RCFI_Avg NumberOfAdultIncomes AvgChildAge AvgChildFamSize 
	black hispanic male if numRPFIpc>0 & NumberOfAdultIncomes>0 & core_sample==1 & age_1979<20 & InMatchedMSA==1;
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize 
	RCFIpc_Avg RCFI_Avg NumberOfAdultIncomes AvgChildAge AvgChildFamSize 
	black hispanic male if numRPFIpc>0 & NumberOfAdultIncomes>0 & black==1 & core_sample==1 & age_1979<20 & InMatchedMSA==1;
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize 
	RCFIpc_Avg RCFI_Avg NumberOfAdultIncomes AvgChildAge AvgChildFamSize 
	black hispanic male if numRPFIpc>0 & NumberOfAdultIncomes>0 & hispanic==1 & core_sample==1 & age_1979<20 & InMatchedMSA==1;

log off;

/* Family income correlations */
keep RCFI_1982-RCFI_2007 RPFI_Avg AvgHeadAge male hispanic black age_1979 core_sample sample_wgts HHID_79 PID_79
     MSA placename_msa NSI_80 total_population_80 prc_black_80 prc_hispanic_80 
     prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80    
     NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79;

/* stack data so that each row corresponds to a child-year pair */
stack 	RCFI_1982 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1983 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1984 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1985 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1986 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1987 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1988 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1989 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1990 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1991 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1992 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1993 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1995 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1997 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_1999 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_2001 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_2003 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
		RCFI_2005 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79
	  	RCFI_2007 RPFI_Avg age_1979 AvgHeadAge male hispanic black NSI_80 MSA placename_msa total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST_79 NORTH_CENTRAL_79 SOUTH_79 WEST_79,
      	into(own_income parents_income own_age parents_age male hispanic black NSI_80 MSA PlaceName total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80 sigma_t_80 HHID_79 PID_79 core_sample sample_wgts NORTH_EAST NORTH_CENTRAL SOUTH WEST) clear;

rename _stack year;
replace year = 1982 if year==1;
replace year = 1983 if year==2;
replace year = 1984 if year==3;
replace year = 1985 if year==4;
replace year = 1986 if year==5;
replace year = 1987 if year==6;
replace year = 1988 if year==7;
replace year = 1989 if year==8;  
replace year = 1990 if year==9;  
replace year = 1991 if year==10;
replace year = 1992 if year==11;  
replace year = 1993 if year==12;  
replace year = 1995 if year==13;  
replace year = 1997 if year==14;  
replace year = 1999 if year==15;  
replace year = 2001 if year==16;  
replace year = 2003 if year==17;
replace year = 2005 if year==18;
replace year = 2007 if year==19;

g D82 = (year==1982);
g D83 = (year==1983);
g D84 = (year==1984);
g D85 = (year==1985);
g D86 = (year==1986);
g D87 = (year==1987);
g D88 = (year==1988);
g D89 = (year==1989);
g D90 = (year==1990);
g D91 = (year==1991);
g D92 = (year==1992);
g D93 = (year==1993);
g D95 = (year==1995);
g D97 = (year==1997);
g D99 = (year==1999);
g D01 = (year==2001);
g D03 = (year==2003);
g D05 = (year==2005);
g D07 = (year==2007);

save "$WRITE_DATA/PewNLSY79_Panel", replace;

g log_parents_income = log(parents_income);
g log_own_income = log(own_income);

g childs_age   = own_age + (year - 1979 - 40);
g childs_age_2 = childs_age^2;
g childs_age_3 = childs_age^3;
g childs_age_4 = childs_age^4;

g parents_age_2 = parents_age^2;
g parents_age_3 = parents_age^3;
g parents_age_4 = parents_age^4;

g pa1_X_lpi = parents_age*log_parents_income;
g pa2_X_lpi = parents_age_2*log_parents_income;
g pa3_X_lpi = parents_age_3*log_parents_income;
g pa4_X_lpi = parents_age_4*log_parents_income;

g ca1_X_lpi = childs_age*log_parents_income;
g ca2_X_lpi = childs_age_2*log_parents_income;
g ca3_X_lpi = childs_age_3*log_parents_income;
g ca4_X_lpi = childs_age_4*log_parents_income;

/* find MSAs with at least 25 sampled households with complete data in target group */
/* only include MSAs with at least 100000 residents in 1980 */
g DA1 = (log_own_income~=.)*(log_parents_income~=.)*(parents_age~=.)*(childs_age~=.)*(male~=.)*(black~=.)*(hispanic~=.)*(MSA~=.);
keep if DA==1 & core_sample==1 & own_age<20;
keep if total_population_80>=100000;

g num_hh_in_MSA = .;
g num_res_in_MSA =.;         
g ige_hat_MSA = .;
g ige_hat_var_MSA = .;

levelsof MSA, local(MSA_list);
foreach l of local MSA_list {;
		di "-> MSA = `l'";
		capture noisily reg log_own_income log_parents_income 
							parents_age parents_age_2 
							childs_age childs_age_2 
							D82-D07 if MSA == `l', cluster(HHID_79) nocons;
		if _rc==0 {;
			replace num_hh_in_MSA = e(N_clust) if MSA == `l';
			matrix b = e(b);
			replace ige_hat_MSA = b[1,1] if MSA == `l';
			matrix V = e(V);
			replace ige_hat_var_MSA = V[1,1] if MSA == `l';
			capture reg log_own_income log_parents_income 
						parents_age parents_age_2 
						childs_age childs_age_2 
						D82-D07 if MSA == `l', cluster(PID_79) nocons;	
			replace num_res_in_MSA = e(N_clust) if MSA == `l';					
		};	
};

log on;
/* Number of Households MSA */
tab num_hh_in_MSA, missing;
tab num_res_in_MSA, missing;
log off;

/* drop respondents in MSAs with less than 25 sampled households */
drop if num_hh_in_MSA<25;
drop if num_hh_in_MSA==.;
log on;
tab num_hh_in_MSA, missing;
tab num_res_in_MSA, missing;
egen t = group(MSA);
levelsof t;
scalar num_cities = wordcount(r(levels));
drop t;
log off;

/* generate MSA dummy variables and interactions with log parental income */
xi, prefix(_) noomit  i.MSA*log_parents_income;

log on;
reg log_own_income 	log_parents_income													
					parents_age parents_age_2 parents_age_3 parents_age_4
					childs_age childs_age_2 childs_age_3 childs_age_4
					D83-D07 [pw=sample_wgts], cluster(PID_79);	

reg log_own_income 	log_parents_income													
					parents_age parents_age_2 parents_age_3 parents_age_4
					childs_age childs_age_2 childs_age_3 childs_age_4
					D83-D07 [pw=sample_wgts], cluster(HHID_79);	
					
reg log_own_income 	log_parents_income													
					parents_age parents_age_2 parents_age_3 parents_age_4
					childs_age childs_age_2 childs_age_3 childs_age_4
					D83-D07
					_MSA_* [pw=sample_wgts], nocons cluster(HHID_79);
testparm _MSA_*, equal; 							 	
					
reg log_own_income 	_MSAXlog_*														
					parents_age parents_age_2 parents_age_3 parents_age_4
					childs_age childs_age_2 childs_age_3 childs_age_4
					D83-D07 
					_MSA_* [pw=sample_wgts], nocons cluster(HHID_79);
testparm _MSA_*, equal; 						
testparm _MSAXlog_*, equal;

collapse (mean) log_own_income _MSA_* _MSAXlog* parents_age parents_age_2 parents_age_3 parents_age_4 
				pa1_X_lpi pa2_X_lpi pa3_X_lpi pa4_X_lpi childs_age childs_age_2 childs_age_3 childs_age_4
				ca1_X_lpi ca2_X_lpi ca3_X_lpi ca4_X_lpi D82-D07 
				sample_wgts NSI_80 num_hh_in_MSA num_res_in_MSA ige_hat_MSA ige_hat_var_MSA
				total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80
				NORTH_EAST NORTH_CENTRAL SOUTH WEST, by(MSA PlaceName HHID_79 PID_79);
				
margins, 	expression(	_b[_MSAXlog_80]*_MSA_80     + _b[_MSAXlog_240]*_MSA_240   + 
					 	_b[_MSAXlog_460]*_MSA_460   + 
					 	_b[_MSAXlog_520]*_MSA_520   + _b[_MSAXlog_840]*_MSA_840   + 
					 	_b[_MSAXlog_1000]*_MSA_1000 + _b[_MSAXlog_1123]*_MSA_1123 + 
					 	_b[_MSAXlog_1240]*_MSA_1240 + _b[_MSAXlog_1280]*_MSA_1280 + 
					 	_b[_MSAXlog_1600]*_MSA_1600 + _b[_MSAXlog_1680]*_MSA_1680 +
					 	_b[_MSAXlog_1760]*_MSA_1760 + 
					 	_b[_MSAXlog_1840]*_MSA_1840 + _b[_MSAXlog_1920]*_MSA_1920 + 
					 	_b[_MSAXlog_2080]*_MSA_2080 + _b[_MSAXlog_2120]*_MSA_2120 + 
					 	_b[_MSAXlog_2160]*_MSA_2160 + _b[_MSAXlog_2320]*_MSA_2320 + 
					 	_b[_MSAXlog_2640]*_MSA_2640 + _b[_MSAXlog_2840]*_MSA_2840 + 
					 	_b[_MSAXlog_2960]*_MSA_2960 + _b[_MSAXlog_3283]*_MSA_3283 + 
					 	_b[_MSAXlog_3360]*_MSA_3360 + _b[_MSAXlog_3480]*_MSA_3480 + 
					 	_b[_MSAXlog_3840]*_MSA_3840 + 
					 	_b[_MSAXlog_4480]*_MSA_4480 + _b[_MSAXlog_5000]*_MSA_5000 + 
					 	_b[_MSAXlog_5120]*_MSA_5120 + _b[_MSAXlog_5190]*_MSA_5190 +
					 	_b[_MSAXlog_5360]*_MSA_5360 + 
					 	_b[_MSAXlog_5380]*_MSA_5380 + _b[_MSAXlog_5560]*_MSA_5560 + 
					 	_b[_MSAXlog_5600]*_MSA_5600 + _b[_MSAXlog_5640]*_MSA_5640 + 
					 	_b[_MSAXlog_5720]*_MSA_5720 + _b[_MSAXlog_5945]*_MSA_5945 +
					 	_b[_MSAXlog_5960]*_MSA_5960 + 
					 	_b[_MSAXlog_6080]*_MSA_6080 + _b[_MSAXlog_6160]*_MSA_6160 + 
					 	_b[_MSAXlog_6280]*_MSA_6280 + _b[_MSAXlog_6600]*_MSA_6600 + 
					 	_b[_MSAXlog_6780]*_MSA_6780 + _b[_MSAXlog_6840]*_MSA_6840 + 
					 	_b[_MSAXlog_7040]*_MSA_7040 + _b[_MSAXlog_7320]*_MSA_7320 + 
					 	_b[_MSAXlog_7360]*_MSA_7360 + _b[_MSAXlog_7520]*_MSA_7520 + 
					 	_b[_MSAXlog_8120]*_MSA_8120 + _b[_MSAXlog_8200]*_MSA_8200 + 
					 	_b[_MSAXlog_8280]*_MSA_8280 + _b[_MSAXlog_8840]*_MSA_8840);														
log off;

/* switch to matrix formulation of the problem */
g c = 1;
matrix b = e(b);
matrix b = b[1,1..num_cities]';
matrix V = e(V);
matrix V = V[1..num_cities,1..num_cities];

/* collapse remaining dataset to MSA level */
collapse (mean) NSI_80 num_hh_in_MSA num_res_in_MSA ige_hat_MSA ige_hat_var_MSA
				total_population_80 prc_black_80 prc_hispanic_80 prc_under18_80 prc_over65_80 prc_foreign_80
				NORTH_EAST NORTH_CENTRAL SOUTH WEST, by(MSA PlaceName);
				
svmat b;
rename b IGE_INC;
g SelectedPlaceName = PlaceName 
					  if MSA==1123 | MSA==1600 | MSA==1920 | MSA==2160 | MSA==4480 | 
					     MSA==5000 | MSA==5600 | MSA==7360 | MSA==8840;	
replace	SelectedPlaceName = PlaceName if IGE_INC>0.9 | IGE_INC<0.1;		

/* scatter plot of the IGE estimates versus NSI (Card-Krueger Estimates) */
scatter IGE_INC NSI_80, 
        mlabel(SelectedPlaceName)
		msymbol(Oh)
		xlabel(0 0.1 0.2 0.3 0.4 0.5) 
		ylabel(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1) 
		yscale(range(0 1))
		xscale(range(0 0.5)) 
		title("") 
		subtitle("Mobility and residential stratification") 
		xtitle("Neighborhood Sorting Index (NSI) - Income") 
		ytitle("Intergenerational elasticity of earnings (IGE)") 
		legend(off);
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_INC_1979_Card_Krueger_Scatter.gph, replace;
graph export $WRITE_DATA/NSI_INC_1979_Card_Krueger_Scatter.eps, replace;

/* scatter plot of the IGE estimates versus NSI (MSA-specific Estimates) */
scatter ige_hat_MSA NSI_80, 
        mlabel(SelectedPlaceName)
		msymbol(Oh)
		xlabel(0 0.1 0.2 0.3 0.4 0.5) 
		ylabel(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1) 
		yscale(range(0 1))
		xscale(range(0 0.5)) 
		title("") 
		subtitle("Mobility and residential stratification") 
		xtitle("Neighborhood Sorting Index (NSI) - Income") 
		ytitle("Intergenerational elasticity of earnings (IGE)") 
		legend(off);
		
graph display, margins(medium) scheme(s1manual);
graph save $WRITE_DATA/NSI_INC_1979_Scatter.gph, replace;
graph export $WRITE_DATA/NSI_INC_1979_Scatter.eps, replace;		
		

log on;

/* some summary statistics */
sum num_hh_in_MSA num_res_in_MSA, detail;

/* Compute Hanushek (1974) FGLS estimates */  

/* using Card-Krueger type first step estimates */
ts_fgls IGE_INC NSI_80, firststepvcov(V);
ts_fgls IGE_INC NORTH_CENTRAL SOUTH WEST, firststepvcov(V);
ts_fgls IGE_INC prc_black_80 prc_hispanic_80, firststepvcov(V);

/* using MSA-specific regression first step estimates */
mkmat ige_hat_var_MSA;
matrix V = diag(ige_hat_var_MSA);
ts_fgls ige_hat_MSA NSI_80, firststepvcov(V);
ts_fgls ige_hat_MSA NORTH_CENTRAL SOUTH WEST, firststepvcov(V);
ts_fgls ige_hat_MSA prc_black_80 prc_hispanic_80, firststepvcov(V);

g se_ige_hat_MSA = sqrt(ige_hat_var_MSA);
vwls ige_hat_MSA NSI_80, sd(se_ige_hat_MSA);
vwls ige_hat_MSA NORTH_CENTRAL SOUTH WEST, sd(se_ige_hat_MSA);
vwls ige_hat_MSA prc_black_80 prc_hispanic_80, sd(se_ige_hat_MSA);

reg ige_hat_MSA NSI_80, r;
reg ige_hat_MSA NORTH_CENTRAL SOUTH WEST, r;
reg ige_hat_MSA prc_black_80 prc_hispanic_80, r;

reg ige_hat_MSA NSI_80 [aw=total_population_80], r;
reg ige_hat_MSA NORTH_CENTRAL SOUTH WEST [aw=total_population_80], r;
reg ige_hat_MSA prc_black_80 prc_hispanic_80 [aw=total_population_80], r;

log off;
log close;
