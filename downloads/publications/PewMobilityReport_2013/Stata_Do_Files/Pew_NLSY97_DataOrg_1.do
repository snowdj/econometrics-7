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

/**************************************************************************************************/
/* Organization and preliminary analysis of 1997 NLSY Sample                                      */
/**************************************************************************************************/

/* Adjust the SOURCE_DATA directory to point to the location of the PewMobilityNLSY97.dct dictionary file. Adjust the    */
/* WRITE_DATA and DO_FILES directorys to point to the location of where you would like to write any created files and */
/* where you have placed this do file respectively. */

global SOURCE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/NLSY97";
global GEOCODE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Geocodes";
global WRITE_DATA "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Created_Data";
global WRITE_DATA_TEACHING "/accounts/fac/bgraham/Teaching/Ec240a_Fall2011/EmpiricalExamples/NLSYEmpiricalExamples";
global DO_FILES "/accounts/fac/bgraham/Research_EML/NeighborhoodSorting/Data/Stata_Do";

/* load FGLS stata/mata program used below */
do "$DO_FILES/TS_FGLS.ado";

/* read in source data (extract from Dec 8, 2011 release for NLSY97) */
infile using "$SOURCE_DATA/PewMobilityNLSY97.dct";

/* added value lables to variables */
do "$DO_FILES/PewMobilityNLSY97_value_labels.do";

/**************************************************************************************************/
/* BASELINE RESPONDENT CHARACTERISTICS                                                            */
/**************************************************************************************************/

g PID_97  = R0000100;    /* individual ID number */
g HHID_97 = R1193000;	 /* household ID number (for `clustering') */

g YouthRelToRP_97 = R0535300 if R0535300>0;  /* Youth's relationship to respondent `parent' */

/* Determine if responding parent is mother (=1), father (=0) or someone else (=missing) */
g RP_Mother_97 = 1 if YouthRelToRP_97==1;			
replace RP_Mother_97 = 0 if YouthRelToRP_97==2; 

/* Characteristics of first non-respondent parent */
g NRP1_Dead 	= (R0533800==1) if R0533800>=0;  /*"Don't know" set equal to missing */
g NRP1_InHH 	= (R0534000==1) if R0534000>=0;
g NRP1_ROSNum 	= R0533900;
g NRP1_IsMom 	= (R0534200==2) if R0534200>0;

/* Characteristics of second non-respondent parent */
g NRP2_Dead 	= (R0534300==1) if R0534300>=0;  /*"Don't know" set equal to missing */
g NRP2_InHH 	= (R0534500==1) if R0534500>=0;
g NRP2_ROSNum 	= R0534400;
g NRP2_IsMom 	= (R0534700==2) if R0534700>0;

/* Determine in spouse of respondent parent is also a parent */
g RP_SpouseIsMom = NRP1_IsMom if R0558500==1;     
replace RP_SpouseIsMom = NRP2_IsMom if R0558600==1 & missing(RP_SpouseIsMom);
 
/* sample designations and sampling weights */
g cross_section = (R1235800==1);
g sample_wgts   =  R1236100;

/* birth year and age in months */
g month_born 	= R0536401;
g year_born  	= R0536402;
g age_1997   	= (1997 + (5/12)) - (year_born + month_born/12);
label variable age_1997 "Age in May of 1997";

/* Height and weight at baseline */
g Height_m_97  	= (R0322500*12 + R0322600)*2.54 if R0322500>=3 & R0322600>=0; /*use only obs 3ft or higher */
g Weight_kg_97 	= R0322700*0.45359237 if  R0322700>=40;                       /*use only obs 40lb or higher */

/* Sex, Race & MSA status */
g male  = (R0536300==1);
g black = (R1482600==1);
g hispanic = (R1482600==2);       
g MSA_97 = R1210400;

/* Test Scores */
g ASVAB_99 = R9829600 if R9829600>=0; 
g PIAT_97 = R1210700 if R1210700>=0;
g PIAT_98 = R2569600 if R2569600>=0;
g PIAT_99 = R3891600 if R3891600>=0;
g PIAT_00 = R5473600 if R5473600>=0;
g PIAT_01 = R7237300 if R7237300>=0;
g PIAT_02 = S1552600 if S1552600>0;

/*****************************************************************************************************/
/* BASIC HOUSEHOLD STRICTURE AND ROSTER INFORMATION AT BASELINE DATA                                 */
/*****************************************************************************************************/

g LivesWithMom97       = (R0327700==1) if R0327700>=0;
g MotherAlive97        = (R0327700==1) if R0327700>0;
replace MotherAlive97  = (R0327900==1) if R0327900>=0 & missing(MotherAlive97);

g LivesWithDad97       = (R0335600==1) if R0335600>=0;
g FatherAlive97        = (R0335600==1) if R0335600>0;
replace FatherAlive97  = (R0335800==1) if R0335800>=0 & missing(FatherAlive97);

g Youth_RL97 		= R0533400; 		   /*HH Roster line number for youth */
g Mom_RL97   		= R0533600;            /*HH Roster line number for youth's mother */
g Dad_RL97 	 		= R0532300;            /*HH Roster line number for youth's father */
g AdoptMom_RL97		= R0531900;            /*HH Roster line number for youth's adoptive mother */
g AdoptDad_RL97		= R0531800;            /*HH Roster line number for youth's adoptive father */
g StepMom_RL97		= R0536000;            /*HH Roster line number for youth's step mother */
g StepDad_RL97		= R0535900;            /*HH Roster line number for youth's step father */
g NR_Mom_RL97       = R0535100;            /*HH Roster line number for youth's NONRESIDENT mother */
g NR_Dad_RL97       = R0535000;            /*HH Roster line number for youth's NONRESIDENT father */

/* Parent's place of birth */
g 		mother_usborn = (R0551500==1) if R0551500>=0 & RP_Mother_97==1;
replace mother_usborn = (R0555000==1) if R0555000>=0 & RP_SpouseIsMom==1 & missing(mother_usborn);
replace mother_usborn = (R0559500==1) if R0559500>=0 & NRP1_IsMom==1 & missing(mother_usborn);
replace mother_usborn = (R0559600==1) if R0559600>=0 & NRP2_IsMom==1 & missing(mother_usborn);


g 		father_usborn = (R0551500==1) if R0551500>=0 & RP_Mother_97==0;
replace father_usborn = (R0555000==1) if R0555000>=0 & RP_SpouseIsMom==0 & missing(father_usborn);
replace father_usborn = (R0559500==1) if R0559500>=0 & NRP1_IsMom==0 & missing(father_usborn);
replace father_usborn = (R0559600==1) if R0559600>=0 & NRP2_IsMom==0 & missing(father_usborn);

/* Parent's height and weight */
g 		mother_height_m_97 = (R0608200*12 + R0608300)*2.54 if R0608200>=3 & R0608300>=0 & RP_Mother_97==1;
replace mother_height_m_97 = (R0608500*12 + R0608600)*2.54 if R0608500>=3 & R0608600>=0 & NRP1_IsMom==1 & missing(mother_height_m_97);
replace mother_height_m_97 = (R0608900*12 + R0609000)*2.54 if R0608900>=3 & R0609000>=0 & NRP2_IsMom==1 & missing(mother_height_m_97);

g 		mother_weight_kg_97 = R0608400*0.45359237 if R0608400>=40 & RP_Mother_97==1;
replace mother_weight_kg_97 = R0608700*0.45359237 if R0608700>=40 & NRP1_IsMom==1 & missing(mother_weight_kg_97);
replace mother_weight_kg_97 = R0609100*0.45359237 if R0609100>=40 & NRP2_IsMom==1 & missing(mother_weight_kg_97);

g 		father_height_m_97 = (R0608200*12 + R0608300)*2.54 if R0608200>=3 & R0608300>=0 & RP_Mother_97==0;
replace father_height_m_97 = (R0608500*12 + R0608600)*2.54 if R0608500>=3 & R0608600>=0 & NRP1_IsMom==0 & missing(father_height_m_97);
replace father_height_m_97 = (R0608900*12 + R0609000)*2.54 if R0608900>=3 & R0609000>=0 & NRP2_IsMom==0 & missing(father_height_m_97);

g 		father_weight_kg_97 = R0608400*0.45359237 if R0608400>=40 & RP_Mother_97==0;
replace father_weight_kg_97 = R0608700*0.45359237 if R0608700>=40 & NRP1_IsMom==0 & missing(father_weight_kg_97);
replace father_weight_kg_97 = R0609100*0.45359237 if R0609100>=40 & NRP2_IsMom==0 & missing(father_weight_kg_97);

/* Grandparents year of birth */
/* Maternal grandmother */
g MatGrdMoth_YOB = R0554300 if R0554300>0 & RP_Mother_97==1;
replace MatGrdMoth_YOB = R0554400 if R0554400 >0 & RP_Mother_97==1 & missing(MatGrdMoth_YOB);
replace MatGrdMoth_YOB = R0557800 if R0557800>=0 & RP_SpouseIsMom==1 & missing(MatGrdMoth_YOB);
replace MatGrdMoth_YOB = R0557900 if R0557900>=0 & RP_SpouseIsMom==1 & missing(MatGrdMoth_YOB);
replace MatGrdMoth_YOB = R0564400 if R0564400>=0 & NRP1_IsMom==1 & missing(MatGrdMoth_YOB);
replace MatGrdMoth_YOB = R0564600 if R0564600>=0 & NRP1_IsMom==1 & missing(MatGrdMoth_YOB);
replace MatGrdMoth_YOB = R0564500 if R0564500>=0 & NRP2_IsMom==1 & missing(MatGrdMoth_YOB);
replace MatGrdMoth_YOB = R0564700 if R0564700>=0 & NRP2_IsMom==1 & missing(MatGrdMoth_YOB);

/* Paternal grandmother */
g PatGrdMoth_YOB = R0554300 if R0554300>0 & RP_Mother_97==0;
replace PatGrdMoth_YOB = R0554400 if R0554400 >0 & RP_Mother_97==0 & missing(PatGrdMoth_YOB);
replace PatGrdMoth_YOB = R0557800 if R0557800>=0 & RP_SpouseIsMom==0 & missing(PatGrdMoth_YOB);
replace PatGrdMoth_YOB = R0557900 if R0557900>=0 & RP_SpouseIsMom==0 & missing(PatGrdMoth_YOB);
replace PatGrdMoth_YOB = R0564400 if R0564400>=0 & NRP1_IsMom==0 & missing(PatGrdMoth_YOB);
replace PatGrdMoth_YOB = R0564600 if R0564600>=0 & NRP1_IsMom==0 & missing(PatGrdMoth_YOB);
replace PatGrdMoth_YOB = R0564500 if R0564500>=0 & NRP2_IsMom==0 & missing(PatGrdMoth_YOB);
replace PatGrdMoth_YOB = R0564700 if R0564700>=0 & NRP2_IsMom==0 & missing(PatGrdMoth_YOB);

/* Maternal grandfather */
g MatGrdFath_YOB = R0554600 if R0554600>0 & RP_Mother_97==1;
replace MatGrdFath_YOB = R0554700 if R0554700 >0 & RP_Mother_97==1 & missing(MatGrdFath_YOB);
replace MatGrdFath_YOB = R0558100 if R0558100>=0 & RP_SpouseIsMom==1 & missing(MatGrdFath_YOB);
replace MatGrdFath_YOB = R0558200 if R0558200>=0 & RP_SpouseIsMom==1 & missing(MatGrdFath_YOB);
replace MatGrdFath_YOB = R0565000 if R0565000>=0 & NRP1_IsMom==1 & missing(MatGrdFath_YOB);
replace MatGrdFath_YOB = R0565200 if R0565200>=0 & NRP1_IsMom==1 & missing(MatGrdFath_YOB);
replace MatGrdFath_YOB = R0565100 if R0565100>=0 & NRP2_IsMom==1 & missing(MatGrdFath_YOB);
replace MatGrdFath_YOB = R0565300 if R0565300>=0 & NRP2_IsMom==1 & missing(MatGrdFath_YOB);

/* Paternal grandfather */
g PatGrdFath_YOB = R0554600 if R0554600>0 & RP_Mother_97==0;
replace PatGrdFath_YOB = R0554700 if R0554700 >0 & RP_Mother_97==0 & missing(PatGrdFath_YOB);
replace PatGrdFath_YOB = R0558100 if R0558100>=0 & RP_SpouseIsMom==0 & missing(PatGrdFath_YOB);
replace PatGrdFath_YOB = R0558200 if R0558200>=0 & RP_SpouseIsMom==0 & missing(PatGrdFath_YOB);
replace PatGrdFath_YOB = R0565000 if R0565000>=0 & NRP1_IsMom==0 & missing(PatGrdFath_YOB);
replace PatGrdFath_YOB = R0565200 if R0565200>=0 & NRP1_IsMom==0 & missing(PatGrdFath_YOB);
replace PatGrdFath_YOB = R0565100 if R0565100>=0 & NRP2_IsMom==0 & missing(PatGrdFath_YOB);
replace PatGrdFath_YOB = R0565300 if R0565300>=0 & NRP2_IsMom==0 & missing(PatGrdFath_YOB);

g MatGrdMoth_Age_97 = 1997 - MatGrdMoth_YOB;
g PatGrdMoth_Age_97 = 1997 - PatGrdMoth_YOB;
g MatGrdFath_Age_97 = 1997 - MatGrdFath_YOB;
g PatGrdFath_Age_97 = 1997 - PatGrdFath_YOB;

/* Grandparents schooling */
/* Maternal grandmother */
g MatGrdMoth_HGC = R0554500 if R0554500>0 & RP_Mother_97==1;
replace MatGrdMoth_HGC = R0558000 if R0558000>=0 & RP_SpouseIsMom==1 & missing(MatGrdMoth_HGC);
replace MatGrdMoth_HGC = R0564800 if R0564800>=0 & NRP1_IsMom==1 & missing(MatGrdMoth_HGC);
replace MatGrdMoth_HGC = R0564900 if R0564900>=0 & NRP2_IsMom==1 & missing(MatGrdMoth_HGC);

/* Paternal grandmother */
g PatGrdMoth_HGC = R0554500 if R0554500>0 & RP_Mother_97==0;
replace PatGrdMoth_HGC = R0558000 if R0558000>=0 & RP_SpouseIsMom==0 & missing(PatGrdMoth_HGC);
replace PatGrdMoth_HGC = R0564800 if R0564800>=0 & NRP1_IsMom==0 & missing(PatGrdMoth_HGC);
replace PatGrdMoth_HGC = R0564900 if R0564900>=0 & NRP2_IsMom==0 & missing(PatGrdMoth_HGC);

/* Maternal grandfather */
g MatGrdFath_HGC = R0554500 if R0554500>0 & RP_Mother_97==1;
replace MatGrdFath_HGC = R0558300 if R0558300>=0 & RP_SpouseIsMom==1 & missing(MatGrdFath_HGC);
replace MatGrdFath_HGC = R0565400 if R0565400>=0 & NRP1_IsMom==1 & missing(MatGrdFath_HGC);
replace MatGrdFath_HGC = R0565500 if R0565500>=0 & NRP2_IsMom==1 & missing(MatGrdFath_HGC);

/* Paternal grandfather */
g PatGrdFath_HGC = R0554500 if R0554500>0 & RP_Mother_97==0;
replace PatGrdFath_HGC = R0558300 if R0558300>=0 & RP_SpouseIsMom==0 & missing(PatGrdFath_HGC);
replace PatGrdFath_HGC = R0565400 if R0565400>=0 & NRP1_IsMom==0 & missing(PatGrdFath_HGC);
replace PatGrdFath_HGC = R0565500 if R0565500>=0 & NRP2_IsMom==0 & missing(PatGrdFath_HGC);
       
/*****************************************************************************************************/
/* BASIC RESPONDENT DEMOGRAPHICS                                                                     */ 
/*****************************************************************************************************/

/* calculate years of completed schooling by May 1st of interview year */
g HGC_97r = R1204400 if R1204400 >=0 & R1204400~=95;
g HGC_98r = R2563101 if R2563101 >=0 & R2563101~=95;
g HGC_99r = R3884701 if R3884701 >=0 & R3884701~=95;
g HGC_00r = R5463901 if R5463901 >=0 & R5463901~=95;
g HGC_01r = R7227601 if R7227601 >=0 & R7227601~=95;
g HGC_02r = S1541501 if S1541501 >=0 & S1541501~=95;
g HGC_03r = S2011301 if S2011301 >=0 & S2011301~=95;
g HGC_04r = S3812201 if S3812201 >=0 & S3812201~=95;
g HGC_05r = S5412600 if S5412600 >=0 & S5412600~=95;
g HGC_06r = S7513500 if S7513500 >=0 & S7513500~=95;
g HGC_07r = T0013900 if T0013900 >=0 & T0013900~=95;
g HGC_08r = T2016000 if T2016000 >=0 & T2016000~=95;
g HGC_09r = T3606300 if T3606300 >=0 & T3606300~=95;

/* years of schooling at age 24 */
g HGC_Age24 = HGC_97r if floor(age_1997)==24;

replace HGC_Age24 = HGC_98r if floor(age_1997)==23;
replace HGC_Age24 = HGC_97r if floor(age_1997)==23 & HGC_98r==.;

replace HGC_Age24 = HGC_99r if floor(age_1997)==22;
replace HGC_Age24 = HGC_98r if floor(age_1997)==22 & HGC_99r==.;
replace HGC_Age24 = HGC_97r if floor(age_1997)==22 & HGC_98r==. & HGC_99r==.;

replace HGC_Age24 = HGC_00r if floor(age_1997)==21;
replace HGC_Age24 = HGC_99r if floor(age_1997)==21 & HGC_00r==.;
replace HGC_Age24 = HGC_98r if floor(age_1997)==21 & HGC_99r==. & HGC_00r==.;

replace HGC_Age24 = HGC_01r if floor(age_1997)==20;
replace HGC_Age24 = HGC_00r if floor(age_1997)==20 & HGC_01r==.;
replace HGC_Age24 = HGC_99r if floor(age_1997)==20 & HGC_00r==. & HGC_01r==.;

replace HGC_Age24 = HGC_02r if floor(age_1997)==19;
replace HGC_Age24 = HGC_01r if floor(age_1997)==19 & HGC_02r==.;
replace HGC_Age24 = HGC_00r if floor(age_1997)==19 & HGC_01r==. & HGC_02r==.;

replace HGC_Age24 = HGC_03r if floor(age_1997)==18;
replace HGC_Age24 = HGC_02r if floor(age_1997)==18 & HGC_03r==.;
replace HGC_Age24 = HGC_01r if floor(age_1997)==18 & HGC_02r==. & HGC_03r==.;

replace HGC_Age24 = HGC_04r if floor(age_1997)==17;
replace HGC_Age24 = HGC_03r if floor(age_1997)==17 & HGC_04r==.;
replace HGC_Age24 = HGC_02r if floor(age_1997)==17 & HGC_03r==. & HGC_04r==.;

replace HGC_Age24 = HGC_05r if floor(age_1997)==16;
replace HGC_Age24 = HGC_04r if floor(age_1997)==16 & HGC_05r==.;
replace HGC_Age24 = HGC_03r if floor(age_1997)==16 & HGC_04r==. & HGC_05r==.;

replace HGC_Age24 = HGC_06r if floor(age_1997)==15;
replace HGC_Age24 = HGC_05r if floor(age_1997)==15 & HGC_06r==.;
replace HGC_Age24 = HGC_04r if floor(age_1997)==15 & HGC_05r==. & HGC_06r==.;

replace HGC_Age24 = HGC_07r if floor(age_1997)==14;
replace HGC_Age24 = HGC_06r if floor(age_1997)==14 & HGC_07r==.;
replace HGC_Age24 = HGC_05r if floor(age_1997)==14 & HGC_06r==. & HGC_07r==.;

replace HGC_Age24 = HGC_08r if floor(age_1997)==13;
replace HGC_Age24 = HGC_07r if floor(age_1997)==13 & HGC_08r==.;
replace HGC_Age24 = HGC_06r if floor(age_1997)==13 & HGC_07r==. & HGC_08r==.;

replace HGC_Age24 = HGC_09r if floor(age_1997)==12;
replace HGC_Age24 = HGC_08r if floor(age_1997)==12 & HGC_09r==.;
replace HGC_Age24 = HGC_07r if floor(age_1997)==12 & HGC_08r==. & HGC_09r==.;

/***************************************************************************************************/
/* Determine if respondent is living with mother and/or father                                     */
/* NOTE: This determination is done by examing the household roster information in each wave of the*/
/*       NLSY97. "Stepparents" include adoptive parents as well.                                   */
/***************************************************************************************************/

g MotherInHome_97  = (R1315800==3) + (R1315900==3) + (R1316000==3) + (R1316100==3) +
                     (R1316200==3) + (R1316300==3) + (R1316400==3) + (R1316500==3) +
                     (R1316600==3) + (R1316700==3) + (R1316800==3) + (R1316900==3) +
                     (R1317000==3) + (R1317100==3) + (R1317200==3) + (R1317300==3) +
                     (R1317400==3) if R1315800~=-5;                    
                                          
g FatherInHome_97  = (R1315800==4) + (R1315900==4) + (R1316000==4) + (R1316100==4) +
                     (R1316200==4) + (R1316300==4) + (R1316400==4) + (R1316500==4) +
                     (R1316600==4) + (R1316700==4) + (R1316800==4) + (R1316900==4) +
                     (R1317000==4) + (R1317100==4) + (R1317200==4) + (R1317300==4) +
                     (R1317400==4) if R1315800~=-5;                    

g StepMotherInHome_97  = (R1315800==5 | R1315800==7) + (R1315900==5 | R1315900==7) + 
						 (R1316000==5 | R1316000==7) + (R1316100==5 | R1316100==7) +
                         (R1316200==5 | R1316200==7) + (R1316300==5 | R1316300==7) + 
                         (R1316400==5 | R1316400==7) + (R1316500==5 | R1316500==7) +
                         (R1316600==5 | R1316600==7) + (R1316700==5 | R1316700==7) + 
                         (R1316800==5 | R1316800==7) + (R1316900==5 | R1316900==7) +
                         (R1317000==5 | R1317000==7) + (R1317100==5 | R1317100==7) + 
                         (R1317200==5 | R1317200==7) + (R1317300==5 | R1317300==7) +
                         (R1317400==5 | R1317400==7) if R1315800~=-5;                    
                     	                      
g StepFatherInHome_97  = (R1315800==6 | R1315800==8) + (R1315900==6 | R1315900==8) + 
						 (R1316000==6 | R1316000==8) + (R1316100==6 | R1316100==8) +
                         (R1316200==6 | R1316200==8) + (R1316300==6 | R1316300==8) + 
                         (R1316400==6 | R1316400==8) + (R1316500==6 | R1316500==8) +
                         (R1316600==6 | R1316600==8) + (R1316700==6 | R1316700==8) + 
                         (R1316800==6 | R1316800==8) + (R1316900==6 | R1316900==8) +
                         (R1317000==6 | R1317000==8) + (R1317100==6 | R1317100==8) + 
                         (R1317200==6 | R1317200==8) + (R1317300==6 | R1317300==8) +
                         (R1317400==6 | R1317400==8) if R1315800~=-5;                    

g MotherInHome_98  = (R2416300==3) + (R2416400==3) + (R2416500==3) + (R2416600==3) +
                     (R2416700==3) + (R2416800==3) + (R2416900==3) + (R2417000==3) +
                     (R2417100==3) + (R2417200==3) + (R2417300==3) + (R2417400==3) +
                     (R2417500==3) + (R2417600==3) if R2416300~=-5;
                   
g FatherInHome_98  = (R2416300==4) + (R2416400==4) + (R2416500==4) + (R2416600==4) +
                     (R2416700==4) + (R2416800==4) + (R2416900==4) + (R2417000==4) +
                     (R2417100==4) + (R2417200==4) + (R2417300==4) + (R2417400==4) +
                     (R2417500==4) + (R2417600==4) if R2416300~=-5;
                     
g StepMotherInHome_98  = (R2416300==5 | R2416300==7) + (R2416400==5 | R2416400==7) + 
					     (R2416500==5 | R2416500==7) + (R2416600==5 | R2416600==7) +
                         (R2416700==5 | R2416700==7) + (R2416800==5 | R2416800==7) + 
                         (R2416900==5 | R2416900==7) + (R2417000==5 | R2417000==7) +
                         (R2417100==5 | R2417100==7) + (R2417200==5 | R2417200==7) + 
                         (R2417300==5 | R2417300==7) + (R2417400==5 | R2417400==7) +
                         (R2417500==5 | R2417500==7) + (R2417600==5 | R2417600==7) if R2416300~=-5;
                        
g StepFatherInHome_98  = (R2416300==6 | R2416300==8) + (R2416400==6 | R2416400==8) + 
					     (R2416500==6 | R2416500==8) + (R2416600==6 | R2416600==8) +
                         (R2416700==6 | R2416700==8) + (R2416800==6 | R2416800==8) + 
                         (R2416900==6 | R2416900==8) + (R2417000==6 | R2417000==8) +
                         (R2417100==6 | R2417100==8) + (R2417200==6 | R2417200==8) + 
                         (R2417300==6 | R2417300==8) + (R2417400==6 | R2417400==8) +
                         (R2417500==6 | R2417500==8) + (R2417600==6 | R2417600==8) if R2416300~=-5;
                         
g MotherInHome_99  = (R3726900==3) + (R3727000==3) + (R3727100==3) + (R3727200==3) +
                     (R3727300==3) + (R3727400==3) + (R3727500==3) + (R3727600==3) +
                     (R3727700==3) + (R3727800==3) + (R3727900==3) + (R3728000==3) +
                     (R3728100==3) + (R3728200==3) if R3726900~=-5;
                                         
g FatherInHome_99  = (R3726900==4) + (R3727000==4) + (R3727100==4) + (R3727200==4) +
                     (R3727300==4) + (R3727400==4) + (R3727500==4) + (R3727600==4) +
                     (R3727700==4) + (R3727800==4) + (R3727900==4) + (R3728000==4) +
                     (R3728100==4) + (R3728200==4) if R3726900~=-5;

g StepMotherInHome_99  = (R3726900==5 | R3726900==7) + (R3727000==5 | R3727000==7) + 
                         (R3727100==5 | R3727100==7) + (R3727200==5 | R3727200==7) +
                         (R3727300==5 | R3727300==7) + (R3727400==5 | R3727400==7) + 
                         (R3727500==5 | R3727500==7) + (R3727600==5 | R3727600==7) +
                         (R3727700==5 | R3727700==7) + (R3727800==5 | R3727800==7) + 
                         (R3727900==5 | R3727900==7) + (R3728000==5 | R3728000==7) +
                         (R3728100==5 | R3728100==7) + (R3728200==5 | R3728200==7) if R3726900~=-5;
                                         
g StepFatherInHome_99  = (R3726900==6 | R3726900==8) + (R3727000==6 | R3727000==8) + 
                         (R3727100==6 | R3727100==8) + (R3727200==6 | R3727200==8) +
                         (R3727300==6 | R3727300==8) + (R3727400==6 | R3727400==8) + 
                         (R3727500==6 | R3727500==8) + (R3727600==6 | R3727600==8) +
                         (R3727700==6 | R3727700==8) + (R3727800==6 | R3727800==8) + 
                         (R3727900==6 | R3727900==8) + (R3728000==6 | R3728000==8) +
                         (R3728100==6 | R3728100==8) + (R3728200==6 | R3728200==8) if R3726900~=-5;
                         
g MotherInHome_00  = (R5191800==3) + (R5191900==3) + (R5192000==3) + (R5192100==3) +
                     (R5192200==3) + (R5192300==3) + (R5192400==3) + (R5192500==3) +
                     (R5192600==3) + (R5192700==3) + (R5192800==3) + (R5192900==3) +
                     (R5193000==3) + (R5193100==3) if R5191800~=-5;
                     
g FatherInHome_00  = (R5191800==4) + (R5191900==4) + (R5192000==4) + (R5192100==4) +
                     (R5192200==4) + (R5192300==4) + (R5192400==4) + (R5192500==4) +
                     (R5192600==4) + (R5192700==4) + (R5192800==4) + (R5192900==4) +
                     (R5193000==4) + (R5193100==4) if R5191800~=-5;
                     
g StepMotherInHome_00  = (R5191800==5 | R5191800==7) + (R5191900==5 | R5191900==7) + 
                         (R5192000==5 | R5192000==7) + (R5192100==5 | R5192100==7) +
                         (R5192200==5 | R5192200==7) + (R5192300==5 | R5192300==7) + 
                         (R5192400==5 | R5192400==7) + (R5192500==5 | R5192500==7) +
                         (R5192600==5 | R5192600==7) + (R5192700==5 | R5192700==7) + 
                         (R5192800==5 | R5192800==7) + (R5192900==5 | R5192900==7) +
                         (R5193000==5 | R5193000==7) + (R5193100==5 | R5193100==7) if R5191800~=-5;
                         
g StepFatherInHome_00  = (R5191800==6 | R5191800==8) + (R5191900==6 | R5191900==8) + 
                         (R5192000==6 | R5192000==8) + (R5192100==6 | R5192100==8) +
                         (R5192200==6 | R5192200==8) + (R5192300==6 | R5192300==8) + 
                         (R5192400==6 | R5192400==8) + (R5192500==6 | R5192500==8) +
                         (R5192600==6 | R5192600==8) + (R5192700==6 | R5192700==8) + 
                         (R5192800==6 | R5192800==8) + (R5192900==6 | R5192900==8) +
                         (R5193000==6 | R5193000==8) + (R5193100==6 | R5193100==8) if R5191800~=-5;

g MotherInHome_01  = (R6919700==3) + (R6919800==3) + (R6919900==3) + (R6920000==3) +
                     (R6920100==3) + (R6920200==3) + (R6920300==3) + (R6920400==3) +
                     (R6920500==3) + (R6920600==3) + (R6920700==3) + (R6920800==3) +
                     (R6920900==3) + (R6921000==3) + (R6921100==3) + (R6921200==3) if R6919700~=-5;

g FatherInHome_01  = (R6919700==4) + (R6919800==4) + (R6919900==4) + (R6920000==4) +
                     (R6920100==4) + (R6920200==4) + (R6920300==4) + (R6920400==4) +
                     (R6920500==4) + (R6920600==4) + (R6920700==4) + (R6920800==4) +
                     (R6920900==4) + (R6921000==4) + (R6921100==4) + (R6921200==4) if R6919700~=-5;

g StepMotherInHome_01  = (R6919700==5 | R6919700==7) + (R6919800==5 | R6919800==7) + 
					     (R6919900==5 | R6919900==7) + (R6920000==5 | R6920000==7) +
                         (R6920100==5 | R6920100==7) + (R6920200==5 | R6920200==7) + 
                         (R6920300==5 | R6920300==7) + (R6920400==5 | R6920400==7) +
                         (R6920500==5 | R6920500==7) + (R6920600==5 | R6920600==7) + 
                         (R6920700==5 | R6920700==7) + (R6920800==5 | R6920800==7) +
                         (R6920900==5 | R6920900==7) + (R6921000==5 | R6921000==7) + 
                         (R6921100==5 | R6921100==7) + (R6921200==5 | R6921200==7) if R6919700~=-5;

g StepFatherInHome_01  = (R6919700==6 | R6919700==8) + (R6919800==6 | R6919800==8) + 
					     (R6919900==6 | R6919900==8) + (R6920000==6 | R6920000==8) +
                         (R6920100==6 | R6920100==8) + (R6920200==6 | R6920200==8) + 
                         (R6920300==6 | R6920300==8) + (R6920400==6 | R6920400==8) +
                         (R6920500==6 | R6920500==8) + (R6920600==6 | R6920600==8) + 
                         (R6920700==6 | R6920700==8) + (R6920800==6 | R6920800==8) +
                         (R6920900==6 | R6920900==8) + (R6921000==6 | R6921000==8) + 
                         (R6921100==6 | R6921100==8) + (R6921200==6 | R6921200==8) if R6919700~=-5;

g MotherInHome_02  = (S1353900==3) + (S1354000==3) + (S1354100==3) + (S1354200==3) +
                     (S1354300==3) + (S1354400==3) + (S1354500==3) + (S1354600==3) +
                     (S1354700==3) + (S1354800==3) + (S1354900==3) + (S1355000==3) +
                     (S1355100==3) if S1353900~=-5;
                     
g FatherInHome_02  = (S1353900==4) + (S1354000==4) + (S1354100==4) + (S1354200==4) +
                     (S1354300==4) + (S1354400==4) + (S1354500==4) + (S1354600==4) +
                     (S1354700==4) + (S1354800==4) + (S1354900==4) + (S1355000==4) +
                     (S1355100==4) if S1353900~=-5;

g StepMotherInHome_02  = (S1353900==5 | S1353900==7) + (S1354000==5 | S1354000==7) + 
                         (S1354100==5 | S1354100==7) + (S1354200==5 | S1354200==7) +
                         (S1354300==5 | S1354300==7) + (S1354400==5 | S1354400==7) + 
                         (S1354500==5 | S1354500==7) + (S1354600==5 | S1354600==7) +
                         (S1354700==5 | S1354700==7) + (S1354800==5 | S1354800==7) + 
                         (S1354900==5 | S1354900==7) + (S1355000==5 | S1355000==7) +
                         (S1355100==5 | S1355100==7) if S1353900~=-5;

g StepFatherInHome_02  = (S1353900==6 | S1353900==8) + (S1354000==6 | S1354000==8) + 
                         (S1354100==6 | S1354100==8) + (S1354200==6 | S1354200==8) +
                         (S1354300==6 | S1354300==8) + (S1354400==6 | S1354400==8) + 
                         (S1354500==6 | S1354500==8) + (S1354600==6 | S1354600==8) +
                         (S1354700==6 | S1354700==8) + (S1354800==6 | S1354800==8) + 
                         (S1354900==6 | S1354900==8) + (S1355000==6 | S1355000==8) +
                         (S1355100==6 | S1355100==8) if S1353900~=-5;
                     
g MotherInHome_03  = (S3417000==3) + (S3417100==3) + (S3417200==3) + (S3417300==3) +
                     (S3417400==3) + (S3417500==3) + (S3417600==3) + (S3417700==3) +
                     (S3417800==3) + (S3417900==3) + (S3418000==3) + (S3418100==3) +
                     (S3418200==3) if S3417000~=-5;

g FatherInHome_03  = (S3417000==4) + (S3417100==4) + (S3417200==4) + (S3417300==4) +
                     (S3417400==4) + (S3417500==4) + (S3417600==4) + (S3417700==4) +
                     (S3417800==4) + (S3417900==4) + (S3418000==4) + (S3418100==4) +
                     (S3418200==4) if S3417000~=-5;

g StepMotherInHome_03  = (S3417000==5 | S3417000==7) + (S3417100==5 | S3417100==7) + 
                         (S3417200==5 | S3417200==7) + (S3417300==5 | S3417300==7) +
                         (S3417400==5 | S3417400==7) + (S3417500==5 | S3417500==7) + 
                         (S3417600==5 | S3417600==7) + (S3417700==5 | S3417700==7) +
                         (S3417800==5 | S3417800==7) + (S3417900==5 | S3417900==7) + 
                         (S3418000==5 | S3418000==7) + (S3418100==5 | S3418100==7) +
                         (S3418200==5 | S3418200==7) if S3417000~=-5;

g StepFatherInHome_03  = (S3417000==6 | S3417000==8) + (S3417100==6 | S3417100==8) + 
                         (S3417200==6 | S3417200==8) + (S3417300==6 | S3417300==8) +
                         (S3417400==6 | S3417400==8) + (S3417500==6 | S3417500==8) + 
                         (S3417600==6 | S3417600==8) + (S3417700==6 | S3417700==8) +
                         (S3417800==6 | S3417800==8) + (S3417900==6 | S3417900==8) + 
                         (S3418000==6 | S3418000==8) + (S3418100==6 | S3418100==8) +
                         (S3418200==6 | S3418200==8) if S3417000~=-5;

g MotherInHome_04  = (S5171600==3) + (S5171700==3) + (S5171800==3) + (S5171900==3) +
                     (S5172000==3) + (S5172100==3) + (S5172200==3) + (S5172300==3) +
                     (S5172400==3) + (S5172500==3) + (S5172600==3) + (S5172700==3) if S5171600~=-5;

g FatherInHome_04  = (S5171600==4) + (S5171700==4) + (S5171800==4) + (S5171900==4) +
                     (S5172000==4) + (S5172100==4) + (S5172200==4) + (S5172300==4) +
                     (S5172400==4) + (S5172500==4) + (S5172600==4) + (S5172700==4) if S5171600~=-5;

g StepMotherInHome_04  = (S5171600==5 | S5171600==7) + (S5171700==5 | S5171700==7) + 
					     (S5171800==5 | S5171800==7) + (S5171900==5 | S5171900==7) +
                         (S5172000==5 | S5172000==7) + (S5172100==5 | S5172100==7) + 
                         (S5172200==5 | S5172200==7) + (S5172300==5 | S5172300==7) +
                         (S5172400==5 | S5172400==7) + (S5172500==5 | S5172500==7) + 
                         (S5172600==5 | S5172600==7) + (S5172700==5 | S5172700==7) if S5171600~=-5;

g StepFatherInHome_04  = (S5171600==6 | S5171600==8) + (S5171700==6 | S5171700==8) + 
					     (S5171800==6 | S5171800==8) + (S5171900==6 | S5171900==8) +
                         (S5172000==6 | S5172000==8) + (S5172100==6 | S5172100==8) + 
                         (S5172200==6 | S5172200==8) + (S5172300==6 | S5172300==8) +
                         (S5172400==6 | S5172400==8) + (S5172500==6 | S5172500==8) + 
                         (S5172600==6 | S5172600==8) + (S5172700==6 | S5172700==8) if S5171600~=-5;

/* We can compare the above with NLSY79 provided child status variables for each wave */
g CV_YTH_REL_HH_97 = R1205300;
g CV_YTH_REL_HH_98 = R2563600;
g CV_YTH_REL_HH_99 = R3885200;
g CV_YTH_REL_HH_00 = R5464400;
g CV_YTH_REL_HH_01 = R7228100;
g CV_YTH_REL_HH_02 = S1542000;
g CV_YTH_REL_HH_03 = S2011800;
                         
/**************************************************************************************************/
/* PARENTAL AGE VARIABLES                                                                         */
/* NOTE: We discard measures which imply an age at respondent's birth of less than 13 and greater */
/*       than 70 for males, and less than 13 and greater than 50 for females.                     */
/**************************************************************************************************/

/* First get age from date of birth information in 1997 resident household roster */
g MothersAge_97    = (R1315800==3)*((1997 + (5/12)) - (R1085102 + R1085101/12))*(R1085102>0)*(R1085101>0) + 
					 (R1315900==3)*((1997 + (5/12)) - (R1085202 + R1085201/12))*(R1085202>0)*(R1085201>0) + 
					 (R1316000==3)*((1997 + (5/12)) - (R1085302 + R1085301/12))*(R1085302>0)*(R1085301>0) + 
					 (R1316100==3)*((1997 + (5/12)) - (R1085402 + R1085401/12))*(R1085402>0)*(R1085401>0) +
                     (R1316200==3)*((1997 + (5/12)) - (R1085502 + R1085501/12))*(R1085502>0)*(R1085501>0) + 
                     (R1316300==3)*((1997 + (5/12)) - (R1085602 + R1085601/12))*(R1085602>0)*(R1085601>0) + 
                     (R1316400==3)*((1997 + (5/12)) - (R1085702 + R1085701/12))*(R1085702>0)*(R1085701>0) + 
                     (R1316500==3)*((1997 + (5/12)) - (R1085802 + R1085801/12))*(R1085802>0)*(R1085801>0) +
                     (R1316600==3)*((1997 + (5/12)) - (R1085902 + R1085901/12))*(R1085902>0)*(R1085901>0) + 
                     (R1316700==3)*((1997 + (5/12)) - (R1086002 + R1086001/12))*(R1086002>0)*(R1086001>0) + 
                     (R1316800==3)*((1997 + (5/12)) - (R1086102 + R1086101/12))*(R1086102>0)*(R1086101>0) + 
                     (R1316900==3)*((1997 + (5/12)) - (R1086202 + R1086201/12))*(R1086202>0)*(R1086201>0) +
                     (R1317000==3)*((1997 + (5/12)) - (R1086302 + R1086301/12))*(R1086302>0)*(R1086301>0) + 
                     (R1317100==3)*((1997 + (5/12)) - (R1086402 + R1086401/12))*(R1086402>0)*(R1086401>0) + 
                     (R1317200==3)*((1997 + (5/12)) - (R1086502 + R1086501/12))*(R1086502>0)*(R1086501>0) + 
                     (R1317400==3)*((1997 + (5/12)) - (R1086602 + R1086601/12))*(R1086602>0)*(R1086601>0) if R1315800~=-5;                    
replace MothersAge_97 = . if (MothersAge_97-floor(age_1997))<13 | (MothersAge_97-floor(age_1997))>50;
g str200 MothersAge_97_Source = "(1) Parental date-of-birth question in 1997 HR" if MothersAge_97~=.;                            
                                          
g FathersAge_97    = (R1315800==4)*((1997 + (5/12)) - (R1085102 + R1085101/12))*(R1085102>0)*(R1085101>0) + 
					 (R1315900==4)*((1997 + (5/12)) - (R1085202 + R1085201/12))*(R1085202>0)*(R1085201>0) + 
					 (R1316000==4)*((1997 + (5/12)) - (R1085302 + R1085301/12))*(R1085302>0)*(R1085301>0) + 
					 (R1316100==4)*((1997 + (5/12)) - (R1085402 + R1085401/12))*(R1085402>0)*(R1085401>0) +
                     (R1316200==4)*((1997 + (5/12)) - (R1085502 + R1085501/12))*(R1085502>0)*(R1085501>0) + 
                     (R1316300==4)*((1997 + (5/12)) - (R1085602 + R1085601/12))*(R1085602>0)*(R1085601>0) + 
                     (R1316400==4)*((1997 + (5/12)) - (R1085702 + R1085701/12))*(R1085702>0)*(R1085701>0) + 
                     (R1316500==4)*((1997 + (5/12)) - (R1085802 + R1085801/12))*(R1085802>0)*(R1085801>0) +
                     (R1316600==4)*((1997 + (5/12)) - (R1085902 + R1085901/12))*(R1085902>0)*(R1085901>0) + 
                     (R1316700==4)*((1997 + (5/12)) - (R1086002 + R1086001/12))*(R1086002>0)*(R1086001>0) + 
                     (R1316800==4)*((1997 + (5/12)) - (R1086102 + R1086101/12))*(R1086102>0)*(R1086101>0) + 
                     (R1316900==4)*((1997 + (5/12)) - (R1086202 + R1086201/12))*(R1086202>0)*(R1086201>0) +
                     (R1317000==4)*((1997 + (5/12)) - (R1086302 + R1086301/12))*(R1086302>0)*(R1086301>0) + 
                     (R1317100==4)*((1997 + (5/12)) - (R1086402 + R1086401/12))*(R1086402>0)*(R1086401>0) + 
                     (R1317200==4)*((1997 + (5/12)) - (R1086502 + R1086501/12))*(R1086502>0)*(R1086501>0) + 
                     (R1317400==4)*((1997 + (5/12)) - (R1086602 + R1086601/12))*(R1086602>0)*(R1086601>0) if R1315800~=-5;
replace FathersAge_97 = . if (FathersAge_97-floor(age_1997))<13 | (FathersAge_97-floor(age_1997))>70;
g str200 FathersAge_97_Source = "(1) Parental date-of-birth question in 1997 HR" if FathersAge_97~=.;  

/* Second get age from "age" information in 1997 resident household roster */ 
replace MothersAge_97    = (R1315800==3)*(R1080300)*(R1080300>0) + 
		          		   (R1315900==3)*(R1080400)*(R1080400>0) + 
		          		   (R1316000==3)*(R1080500)*(R1080500>0) +  
					       (R1316100==3)*(R1080600)*(R1080600>0) + 
                           (R1316200==3)*(R1080700)*(R1080700>0) +  
                           (R1316300==3)*(R1080800)*(R1080800>0) +  
                           (R1316400==3)*(R1080900)*(R1080900>0) +  
                           (R1316500==3)*(R1081000)*(R1081000>0) + 
                           (R1316600==3)*(R1081100)*(R1081100>0) +  
                           (R1316700==3)*(R1081200)*(R1081200>0) +  
                           (R1316800==3)*(R1081300)*(R1081300>0) +  
                           (R1316900==3)*(R1081400)*(R1081400>0) + 
                           (R1317000==3)*(R1081500)*(R1081500>0) +  
                           (R1317100==3)*(R1081600)*(R1081600>0) +  
                           (R1317200==3)*(R1081700)*(R1081700>0) +  
                           (R1317300==3)*(R1081800)*(R1081800>0) + 
                           (R1317400==3)*(R1081801)*(R1081801>0) if R1315800~=-5 & missing(MothersAge_97);   
replace MothersAge_97 = . if (MothersAge_97-floor(age_1997))<13 | (MothersAge_97-floor(age_1997))>50;
replace MothersAge_97_Source = "(2) Parental age question in 1997 HR" if MothersAge_97~=. & missing(MothersAge_97_Source);                              

replace FathersAge_97    = (R1315800==4)*(R1080300)*(R1080300>0) + 
		          		   (R1315900==4)*(R1080400)*(R1080400>0) + 
		          		   (R1316000==4)*(R1080500)*(R1080500>0) +  
					       (R1316100==4)*(R1080600)*(R1080600>0) + 
                           (R1316200==4)*(R1080700)*(R1080700>0) +  
                           (R1316300==4)*(R1080800)*(R1080800>0) +  
                           (R1316400==4)*(R1080900)*(R1080900>0) +  
                           (R1316500==4)*(R1081000)*(R1081000>0) + 
                           (R1316600==4)*(R1081100)*(R1081100>0) +  
                           (R1316700==4)*(R1081200)*(R1081200>0) +  
                           (R1316800==4)*(R1081300)*(R1081300>0) +  
                           (R1316900==4)*(R1081400)*(R1081400>0) + 
                           (R1317000==4)*(R1081500)*(R1081500>0) +  
                           (R1317100==4)*(R1081600)*(R1081600>0) +  
                           (R1317200==4)*(R1081700)*(R1081700>0) +  
                           (R1317300==4)*(R1081800)*(R1081800>0) + 
                           (R1317400==4)*(R1081801)*(R1081801>0) if R1315800~=-5 & missing(FathersAge_97);                                          
replace FathersAge_97 = . if (FathersAge_97-floor(age_1997))<13 | (FathersAge_97-floor(age_1997))>70;
replace FathersAge_97_Source = "(2) Parental age question in 1997 HR" if FathersAge_97~=. & missing(FathersAge_97_Source);                                
                        
/* Third get age from "age" information in 1997 non-resident household roster */ 
replace MothersAge_97    = (R1186600==3)*(R1163700)*(R1163700>0) +
						   (R1186700==3)*(R1163800)*(R1163800>0) +
					       (R1186800==3)*(R1163900)*(R1163900>0) +
				           (R1186900==3)*(R1164000)*(R1164000>0) +
						   (R1187000==3)*(R1164100)*(R1164100>0) +
						   (R1187100==3)*(R1164200)*(R1164200>0) +
						   (R1187200==3)*(R1164300)*(R1164300>0) +
						   (R1187300==3)*(R1164400)*(R1164400>0) +
						   (R1187400==3)*(R1164500)*(R1164500>0) +
						   (R1187500==3)*(R1164600)*(R1164600>0) +
						   (R1187600==3)*(R1164700)*(R1164700>0) +
						   (R1187700==3)*(R1164800)*(R1164800>0) +
						   (R1187800==3)*(R1164900)*(R1164900>0) +
						   (R1187900==3)*(R1165000)*(R1165000>0) +
						   (R1188000==3)*(R1165100)*(R1165100>0) +
						   (R1188100==3)*(R1165700)*(R1165700>0) if R1186600~=-5 & missing(MothersAge_97);    
replace MothersAge_97 = . if (MothersAge_97-floor(age_1997))<13 | (MothersAge_97-floor(age_1997))>50;
replace MothersAge_97_Source = "(3) Parental age question in 1997 Non-Res HR" if MothersAge_97~=. & missing(MothersAge_97_Source);                             

replace FathersAge_97    = (R1186600==4)*(R1163700)*(R1163700>0) +
						   (R1186700==4)*(R1163800)*(R1163800>0) +
					       (R1186800==4)*(R1163900)*(R1163900>0) +
				           (R1186900==4)*(R1164000)*(R1164000>0) +
						   (R1187000==4)*(R1164100)*(R1164100>0) +
						   (R1187100==4)*(R1164200)*(R1164200>0) +
						   (R1187200==4)*(R1164300)*(R1164300>0) +
						   (R1187300==4)*(R1164400)*(R1164400>0) +
						   (R1187400==4)*(R1164500)*(R1164500>0) +
						   (R1187500==4)*(R1164600)*(R1164600>0) +
						   (R1187600==4)*(R1164700)*(R1164700>0) +
						   (R1187700==4)*(R1164800)*(R1164800>0) +
						   (R1187800==4)*(R1164900)*(R1164900>0) +
						   (R1187900==4)*(R1165000)*(R1165000>0) +
						   (R1188000==4)*(R1165100)*(R1165100>0) +
						   (R1188100==4)*(R1165700)*(R1165700>0) if R1186600~=-5 & missing(FathersAge_97);    
replace FathersAge_97 = . if (FathersAge_97-floor(age_1997))<13 | (FathersAge_97-floor(age_1997))>70;
replace FathersAge_97_Source = "(3) Parental age question in 1997 Non-Res HR" if FathersAge_97~=. & missing(FathersAge_97_Source);   

/* Fourth get age from "age" information in 1998 resident household roster */
replace MothersAge_97    = (R2416300==3)*(R2399900)*(R2399900>0) +
						   (R2416400==3)*(R2400000)*(R2400000>0) +
					       (R2416500==3)*(R2400100)*(R2400100>0) +
				           (R2416600==3)*(R2400200)*(R2400200>0) +
						   (R2416700==3)*(R2400300)*(R2400300>0) +
						   (R2416800==3)*(R2400400)*(R2400400>0) +
						   (R2416900==3)*(R2400500)*(R2400500>0) +
						   (R2417000==3)*(R2400600)*(R2400600>0) +
						   (R2417100==3)*(R2400700)*(R2400700>0) +
						   (R2417200==3)*(R2400800)*(R2400800>0) +
						   (R2417300==3)*(R2400900)*(R2400900>0) +
						   (R2417400==3)*(R2401000)*(R2401000>0) +
						   (R2417500==3)*(R2401100)*(R2401100>0) +
						   (R2417600==3)*(R2401200)*(R2401200>0) - 1 if R2416300~=-5 & missing(MothersAge_97);    
replace MothersAge_97 = . if (MothersAge_97-floor(age_1997))<13 | (MothersAge_97-floor(age_1997))>50;
replace MothersAge_97_Source = "(4) Parental age question in 1998 HR" if MothersAge_97~=. & missing(MothersAge_97_Source);                              

replace FathersAge_97    = (R2416300==4)*(R2399900)*(R2399900>0) +
						   (R2416400==4)*(R2400000)*(R2400000>0) +
					       (R2416500==4)*(R2400100)*(R2400100>0) +
				           (R2416600==4)*(R2400200)*(R2400200>0) +
						   (R2416700==4)*(R2400300)*(R2400300>0) +
						   (R2416800==4)*(R2400400)*(R2400400>0) +
						   (R2416900==4)*(R2400500)*(R2400500>0) +
						   (R2417000==4)*(R2400600)*(R2400600>0) +
						   (R2417100==4)*(R2400700)*(R2400700>0) +
						   (R2417200==4)*(R2400800)*(R2400800>0) +
						   (R2417300==4)*(R2400900)*(R2400900>0) +
						   (R2417400==4)*(R2401000)*(R2401000>0) +
						   (R2417500==4)*(R2401100)*(R2401100>0) +
						   (R2417600==4)*(R2401200)*(R2401200>0) - 1 if R2416300~=-5 & missing(FathersAge_97);    
replace FathersAge_97 = . if (FathersAge_97-floor(age_1997))<13 | (FathersAge_97-floor(age_1997))>70;
replace FathersAge_97_Source = "(4) Parental age question in 1998 HR" if FathersAge_97~=. & missing(FathersAge_97_Source);                              


/* Fifth get age from "age" information in 1998 non-resident household roster */                            
replace MothersAge_97    = (R2443000==3)*(R2420500)*(R2420500>0) +
						   (R2443100==3)*(R2420600)*(R2420600>0) +
						   (R2443200==3)*(R2420700)*(R2420700>0) +
						   (R2443300==3)*(R2420800)*(R2420800>0) +
						   (R2443400==3)*(R2420900)*(R2420900>0) +
						   (R2443500==3)*(R2421000)*(R2421000>0) +
						   (R2443600==3)*(R2421100)*(R2421100>0) +
						   (R2443700==3)*(R2421200)*(R2421200>0) +
						   (R2443800==3)*(R2421300)*(R2421300>0) +
						   (R2443900==3)*(R2421400)*(R2421400>0) +
						   (R2444000==3)*(R2421500)*(R2421500>0) +
						   (R2444100==3)*(R2421600)*(R2421600>0) +
						   (R2444200==3)*(R2421700)*(R2421700>0) +
						   (R2444300==3)*(R2421800)*(R2421800>0) +
						   (R2444400==3)*(R2421900)*(R2421900>0) +
						   (R2444500==3)*(R2422000)*(R2422000>0) +
						   (R2444600==3)*(R2422400)*(R2422400>0) - 1 if R2443000~=-5 & missing(MothersAge_97);    
replace MothersAge_97 = . if (MothersAge_97-floor(age_1997))<13 | (MothersAge_97-floor(age_1997))>50;
replace MothersAge_97_Source = "(5) Parental age question in 1998 Non-Res HR" if MothersAge_97~=. & missing(MothersAge_97_Source);                              
                                                      
replace FathersAge_97    = (R2443000==4)*(R2420500)*(R2420500>0) +
						   (R2443100==4)*(R2420600)*(R2420600>0) +
						   (R2443200==4)*(R2420700)*(R2420700>0) +
						   (R2443300==4)*(R2420800)*(R2420800>0) +
						   (R2443400==4)*(R2420900)*(R2420900>0) +
						   (R2443500==4)*(R2421000)*(R2421000>0) +
						   (R2443600==4)*(R2421100)*(R2421100>0) +
						   (R2443700==4)*(R2421200)*(R2421200>0) +
						   (R2443800==4)*(R2421300)*(R2421300>0) +
						   (R2443900==4)*(R2421400)*(R2421400>0) +
						   (R2444000==4)*(R2421500)*(R2421500>0) +
						   (R2444100==4)*(R2421600)*(R2421600>0) +
						   (R2444200==4)*(R2421700)*(R2421700>0) +
						   (R2444300==4)*(R2421800)*(R2421800>0) +
						   (R2444400==4)*(R2421900)*(R2421900>0) +
						   (R2444500==4)*(R2422000)*(R2422000>0) +
						   (R2444600==4)*(R2422400)*(R2422400>0) - 1 if R2443000~=-5 & missing(FathersAge_97);    
replace FathersAge_97 = . if (FathersAge_97-floor(age_1997))<13 | (FathersAge_97-floor(age_1997))>70;
replace FathersAge_97_Source = "(5) Parental age question in 1998 Non-Res HR" if FathersAge_97~=. & missing(FathersAge_97_Source);                              

/* Sixth get age from "age" information in 1999 resident household roster */                            
replace MothersAge_97    = (R3726900==3)*(R3708200)*(R3708200>0) +
						   (R3727000==3)*(R3708300)*(R3708300>0) +
						   (R3727100==3)*(R3708400)*(R3708400>0) +
						   (R3727200==3)*(R3708500)*(R3708500>0) +
						   (R3727300==3)*(R3708600)*(R3708600>0) +
						   (R3727400==3)*(R3708700)*(R3708700>0) +
						   (R3727500==3)*(R3708800)*(R3708800>0) +
						   (R3727600==3)*(R3708900)*(R3708900>0) +
						   (R3727700==3)*(R3709000)*(R3709000>0) +
						   (R3727800==3)*(R3709100)*(R3709100>0) +
						   (R3727900==3)*(R3709200)*(R3709200>0) +
						   (R3728000==3)*(R3709300)*(R3709300>0) +
						   (R3728100==3)*(R3709400)*(R3709400>0) +
						   (R3728200==3)*(R3709500)*(R3709500>0) - 2 if R3726900~=-5 & missing(MothersAge_97);    
replace MothersAge_97 = . if (MothersAge_97-floor(age_1997))<13 | (MothersAge_97-floor(age_1997))>50;
replace MothersAge_97_Source = "(6) Parental age question in 1999 HR" if MothersAge_97~=. & missing(MothersAge_97_Source);                              

replace FathersAge_97    = (R3726900==4)*(R3708200)*(R3708200>0) +
						   (R3727000==4)*(R3708300)*(R3708300>0) +
						   (R3727100==4)*(R3708400)*(R3708400>0) +
						   (R3727200==4)*(R3708500)*(R3708500>0) +
						   (R3727300==4)*(R3708600)*(R3708600>0) +
						   (R3727400==4)*(R3708700)*(R3708700>0) +
						   (R3727500==4)*(R3708800)*(R3708800>0) +
						   (R3727600==4)*(R3708900)*(R3708900>0) +
						   (R3727700==4)*(R3709000)*(R3709000>0) +
						   (R3727800==4)*(R3709100)*(R3709100>0) +
						   (R3727900==4)*(R3709200)*(R3709200>0) +
						   (R3728000==4)*(R3709300)*(R3709300>0) +
						   (R3728100==4)*(R3709400)*(R3709400>0) +
						   (R3728200==4)*(R3709500)*(R3709500>0) - 2 if R3726900~=-5 & missing(FathersAge_97);    
replace FathersAge_97 = . if (FathersAge_97-floor(age_1997))<13 | (FathersAge_97-floor(age_1997))>70;
replace FathersAge_97_Source = "(6) Parental age question in 1999 HR" if FathersAge_97~=. & missing(FathersAge_97_Source);                              

/* Seventh get age from "age" information in 1999 non-resident household roster */                            
replace MothersAge_97    = (R3759000==3)*(R3731100)*(R3731100>0) +
                           (R3759100==3)*(R3731200)*(R3731200>0) +
                           (R3759200==3)*(R3731300)*(R3731300>0) +
                           (R3759300==3)*(R3731400)*(R3731400>0) +
                           (R3759400==3)*(R3731500)*(R3731500>0) +
                           (R3759500==3)*(R3731600)*(R3731600>0) +
                           (R3759600==3)*(R3731700)*(R3731700>0) +
                           (R3759700==3)*(R3731800)*(R3731800>0) +
                           (R3759800==3)*(R3731900)*(R3731900>0) +
                           (R3759900==3)*(R3732000)*(R3732000>0) +
                           (R3760000==3)*(R3732100)*(R3732100>0) +
                           (R3760100==3)*(R3732200)*(R3732200>0) +
                           (R3760200==3)*(R3732300)*(R3732300>0) +
                           (R3760300==3)*(R3732400)*(R3732400>0) +
                           (R3760400==3)*(R3732500)*(R3732500>0) +
                           (R3760500==3)*(R3732600)*(R3732600>0) +
                           (R3760600==3)*(R3732700)*(R3732700>0) +
                           (R3760700==3)*(R3732800)*(R3732800>0) +
                           (R3760900==3)*(R3732900)*(R3732900>0) +
                           (R3761100==3)*(R3733000)*(R3733000>0) +
                           (R3761200==3)*(R3733100)*(R3733100>0) +
                           (R3761300==3)*(R3733200)*(R3733200>0) - 2 if R3759000~=-5 & missing(MothersAge_97);    
replace MothersAge_97 = . if (MothersAge_97-floor(age_1997))<13 | (MothersAge_97-floor(age_1997))>50;
replace MothersAge_97_Source = "(7) Parental age question in 1999 non-res HR" if MothersAge_97~=. & missing(MothersAge_97_Source);                              

replace FathersAge_97    = (R3759000==4)*(R3731100)*(R3731100>0) +
                           (R3759100==4)*(R3731200)*(R3731200>0) +
                           (R3759200==4)*(R3731300)*(R3731300>0) +
                           (R3759300==4)*(R3731400)*(R3731400>0) +
                           (R3759400==4)*(R3731500)*(R3731500>0) +
                           (R3759500==4)*(R3731600)*(R3731600>0) +
                           (R3759600==4)*(R3731700)*(R3731700>0) +
                           (R3759700==4)*(R3731800)*(R3731800>0) +
                           (R3759800==4)*(R3731900)*(R3731900>0) +
                           (R3759900==4)*(R3732000)*(R3732000>0) +
                           (R3760000==4)*(R3732100)*(R3732100>0) +
                           (R3760100==4)*(R3732200)*(R3732200>0) +
                           (R3760200==4)*(R3732300)*(R3732300>0) +
                           (R3760300==4)*(R3732400)*(R3732400>0) +
                           (R3760400==4)*(R3732500)*(R3732500>0) +
                           (R3760500==4)*(R3732600)*(R3732600>0) +
                           (R3760600==4)*(R3732700)*(R3732700>0) +
                           (R3760700==4)*(R3732800)*(R3732800>0) +
                           (R3760900==4)*(R3732900)*(R3732900>0) +
                           (R3761100==4)*(R3733000)*(R3733000>0) +
                           (R3761200==4)*(R3733100)*(R3733100>0) +
                           (R3761300==4)*(R3733200)*(R3733200>0) - 2 if R3759000~=-5 & missing(FathersAge_97);    
replace FathersAge_97 = . if (FathersAge_97-floor(age_1997))<13 | (FathersAge_97-floor(age_1997))>70;
replace FathersAge_97_Source = "(7) Parental age question in 1999 non-res HR" if FathersAge_97~=. & missing(FathersAge_97_Source);                              

/* Compute squares and interactions of parent age */
g FathersAge_97_2 = FathersAge_97^2;
g MothersAge_97_2 = MothersAge_97^2;
g FxMAge_97 = FathersAge_97*MothersAge_97;
g ParentsAge_97 = (FathersAge_97 + MothersAge_97)/2;
g ParentsAge_97_2 = ParentsAge_97^2;

/******************************************************************************************************/
/* get step-father's age (if applicable) from the household rosters                                   */
/* NOTE: Calculated in such a way as to allow the identity of the step-father to change across years. */
/*       As before we throw away units aged less than 13 or greater than 70 at respondent's birth     */
/******************************************************************************************************/

g StepFathersAge_97 = (R1315800==6 | R1315800==8)*(R1080300)*(R1080300>0) + 
		              (R1315900==6 | R1315900==8)*(R1080400)*(R1080400>0) + 
		              (R1316000==6 | R1316000==8)*(R1080500)*(R1080500>0) +  
				      (R1316100==6 | R1316100==8)*(R1080600)*(R1080600>0) + 
                      (R1316200==6 | R1316200==8)*(R1080700)*(R1080700>0) +  
                      (R1316300==6 | R1316300==8)*(R1080800)*(R1080800>0) +  
                      (R1316400==6 | R1316400==8)*(R1080900)*(R1080900>0) +  
                      (R1316500==6 | R1316500==8)*(R1081000)*(R1081000>0) + 
                      (R1316600==6 | R1316600==8)*(R1081100)*(R1081100>0) +  
                      (R1316700==6 | R1316700==8)*(R1081200)*(R1081200>0) +  
                      (R1316800==6 | R1316800==8)*(R1081300)*(R1081300>0) +  
                      (R1316900==6 | R1316900==8)*(R1081400)*(R1081400>0) + 
                      (R1317000==6 | R1317000==8)*(R1081500)*(R1081500>0) +  
                      (R1317100==6 | R1317100==8)*(R1081600)*(R1081600>0) +  
                      (R1317200==6 | R1317200==8)*(R1081700)*(R1081700>0) +  
                      (R1317300==6 | R1317300==8)*(R1081800)*(R1081800>0) + 
                      (R1317400==6 | R1317400==8)*(R1081801)*(R1081801>0) if R1315800~=-5 ;   
replace StepFathersAge_97 = . if (StepFathersAge_97-floor(age_1997))<13 | (StepFathersAge_97-floor(age_1997))>70;

g StepFathersAge_98 = (R2416300==6 | R2416300==8)*(R2399900)*(R2399900>0) +
			 	      (R2416400==6 | R2416400==8)*(R2400000)*(R2400000>0) +
					  (R2416500==6 | R2416500==8)*(R2400100)*(R2400100>0) +
				      (R2416600==6 | R2416600==8)*(R2400200)*(R2400200>0) +
					  (R2416700==6 | R2416700==8)*(R2400300)*(R2400300>0) +
					  (R2416800==6 | R2416800==8)*(R2400400)*(R2400400>0) +
					  (R2416900==6 | R2416900==8)*(R2400500)*(R2400500>0) +
					  (R2417000==6 | R2417000==8)*(R2400600)*(R2400600>0) +
					  (R2417100==6 | R2417100==8)*(R2400700)*(R2400700>0) +
					  (R2417200==6 | R2417200==8)*(R2400800)*(R2400800>0) +
					  (R2417300==6 | R2417300==8)*(R2400900)*(R2400900>0) +
					  (R2417400==6 | R2417400==8)*(R2401000)*(R2401000>0) +
					  (R2417500==6 | R2417500==8)*(R2401100)*(R2401100>0) +
					  (R2417600==6 | R2417600==8)*(R2401200)*(R2401200>0) if R2416300~=-5;    
replace StepFathersAge_98 = . if (StepFathersAge_98-1-floor(age_1997))<13 | (StepFathersAge_98-1-floor(age_1997))>70;

g StepFathersAge_99 = (R3726900==6 | R3726900==8)*(R3708200)*(R3708200>0) +
		 		      (R3727000==6 | R3727000==8)*(R3708300)*(R3708300>0) +
					  (R3727100==6 | R3727100==8)*(R3708400)*(R3708400>0) +
					  (R3727200==6 | R3727200==8)*(R3708500)*(R3708500>0) +
					  (R3727300==6 | R3727300==8)*(R3708600)*(R3708600>0) +
					  (R3727400==6 | R3727400==8)*(R3708700)*(R3708700>0) +
					  (R3727500==6 | R3727500==8)*(R3708800)*(R3708800>0) +
					  (R3727600==6 | R3727600==8)*(R3708900)*(R3708900>0) +
					  (R3727700==6 | R3727700==8)*(R3709000)*(R3709000>0) +
					  (R3727800==6 | R3727800==8)*(R3709100)*(R3709100>0) +
					  (R3727900==6 | R3727900==8)*(R3709200)*(R3709200>0) +
					  (R3728000==6 | R3728000==8)*(R3709300)*(R3709300>0) +
					  (R3728100==6 | R3728100==8)*(R3709400)*(R3709400>0) +
					  (R3728200==6 | R3728200==8)*(R3709500)*(R3709500>0) if R3726900~=-5;
replace StepFathersAge_99 = . if (StepFathersAge_99-2-floor(age_1997))<13 | (StepFathersAge_99-2-floor(age_1997))>70;

g StepFathersAge_00 = (R5191800==6 | R5191800==8)*(R3708200)*(R3708200>0) +
				      (R5191900==6 | R5191900==8)*(R3708300)*(R3708300>0) +
					  (R5192000==6 | R5192000==8)*(R3708400)*(R3708400>0) +
					  (R5192100==6 | R5192100==8)*(R3708500)*(R3708500>0) +
					  (R5192200==6 | R5192200==8)*(R3708600)*(R3708600>0) +
					  (R5192300==6 | R5192300==8)*(R3708700)*(R3708700>0) +
					  (R5192400==6 | R5192400==8)*(R3708800)*(R3708800>0) +
					  (R5192500==6 | R5192500==8)*(R3708900)*(R3708900>0) +
					  (R5192600==6 | R5192600==8)*(R3709000)*(R3709000>0) +
					  (R5192700==6 | R5192700==8)*(R3709100)*(R3709100>0) +
					  (R5192800==6 | R5192800==8)*(R3709200)*(R3709200>0) +
					  (R5192900==6 | R5192900==8)*(R3709300)*(R3709300>0) +
					  (R5193000==6 | R5193000==8)*(R3709400)*(R3709400>0) +
					  (R5193100==6 | R5193100==8)*(R3709500)*(R3709500>0) if R5191800~=-5;
replace StepFathersAge_00 = . if (StepFathersAge_00-3-floor(age_1997))<13 | (StepFathersAge_00-3-floor(age_1997))>70;

g StepFathersAge_01 = (R6919700==6 | R6919700==8)*(R6894100)*(R6894100>0) +
				      (R6919800==6 | R6919800==8)*(R6894200)*(R6894200>0) +
				      (R6919900==6 | R6919900==8)*(R6894300)*(R6894300>0) +
				      (R6920000==6 | R6920000==8)*(R6894400)*(R6894400>0) +
				      (R6920100==6 | R6920100==8)*(R6894500)*(R6894500>0) +
				      (R6920200==6 | R6920200==8)*(R6894600)*(R6894600>0) +
				      (R6920300==6 | R6920300==8)*(R6894700)*(R6894700>0) +
				      (R6920400==6 | R6920400==8)*(R6894800)*(R6894800>0) +
				      (R6920500==6 | R6920500==8)*(R6894900)*(R6894900>0) +
				      (R6920600==6 | R6920600==8)*(R6895000)*(R6895000>0) +
				      (R6920700==6 | R6920700==8)*(R6895100)*(R6895100>0) +
				      (R6920800==6 | R6920800==8)*(R6895200)*(R6895200>0) +
				      (R6920900==6 | R6920900==8)*(R6895300)*(R6895300>0) +
				      (R6921000==6 | R6921000==8)*(R6895400)*(R6895400>0) +
				      (R6921100==6 | R6921100==8)*(R6895500)*(R6895500>0) +
				      (R6921200==6 | R6921200==8)*(R6895600)*(R6895600>0) if R6919700~=-5;
replace StepFathersAge_01 = . if (StepFathersAge_01-4-floor(age_1997))<13 | (StepFathersAge_01-4-floor(age_1997))>70;

g StepFathersAge_02  = (S1353900==6 | S1353900==8)*(S1334400)*(S1334400>0) + 
					   (S1354000==6 | S1354000==8)*(S1334500)*(S1334500>0) + 
                       (S1354100==6 | S1354100==8)*(S1334600)*(S1334600>0) + 
                       (S1354200==6 | S1354200==8)*(S1334700)*(S1334700>0) +
                       (S1354300==6 | S1354300==8)*(S1334800)*(S1334800>0) + 
                       (S1354400==6 | S1354400==8)*(S1334900)*(S1334900>0) + 
                       (S1354500==6 | S1354500==8)*(S1335000)*(S1335000>0) + 
                       (S1354600==6 | S1354600==8)*(S1335100)*(S1335100>0) +
                       (S1354700==6 | S1354700==8)*(S1335200)*(S1335200>0) + 
                       (S1354800==6 | S1354800==8)*(S1335300)*(S1335300>0) + 
                       (S1354900==6 | S1354900==8)*(S1335400)*(S1335400>0) + 
                       (S1355000==6 | S1355000==8)*(S1335500)*(S1335500>0) +
                       (S1355100==6 | S1355100==8)*(S1335600)*(S1335600>0) if S1353900~=-5;
replace StepFathersAge_02 = . if (StepFathersAge_02-5-floor(age_1997))<13 | (StepFathersAge_02-5-floor(age_1997))>70;

g StepFathersAge_03  = (S3417000==6 | S3417000==8)*(S3400100)*(S3400100>0) + 
					   (S3417100==6 | S3417100==8)*(S3400200)*(S3400200>0) + 
                       (S3417200==6 | S3417200==8)*(S3400300)*(S3400300>0) + 
                       (S3417300==6 | S3417300==8)*(S3400400)*(S3400400>0) +
                       (S3417400==6 | S3417400==8)*(S3400500)*(S3400500>0) + 
                       (S3417500==6 | S3417500==8)*(S3400600)*(S3400600>0) + 
                       (S3417600==6 | S3417600==8)*(S3400700)*(S3400700>0) + 
                       (S3417700==6 | S3417700==8)*(S3400800)*(S3400800>0) +
                       (S3417800==6 | S3417800==8)*(S3400900)*(S3400900>0) + 
                       (S3417900==6 | S3417900==8)*(S3401000)*(S3401000>0) + 
                       (S3418000==6 | S3418000==8)*(S3401100)*(S3401100>0) + 
                       (S3418100==6 | S3418100==8)*(S3401200)*(S3401200>0) +
                       (S3418200==6 | S3418200==8)*(S3401300)*(S3401300>0) if S3417000~=-5;
replace StepFathersAge_03 = . if (StepFathersAge_03-6-floor(age_1997))<13 | (StepFathersAge_03-6-floor(age_1997))>70;

g StepFathersAge_04  = (S5171600==6 | S5171600==8)*(S5088000)*(S5088000>0) + 
					   (S5171700==6 | S5171700==8)*(S5088100)*(S5088100>0) + 
					   (S5171800==6 | S5171800==8)*(S5088200)*(S5088200>0) + 
					   (S5171900==6 | S5171900==8)*(S5088300)*(S5088300>0) +
                       (S5172000==6 | S5172000==8)*(S5088400)*(S5088400>0) + 
                       (S5172100==6 | S5172100==8)*(S5088500)*(S5088500>0) + 
                       (S5172200==6 | S5172200==8)*(S5088600)*(S5088600>0) + 
                       (S5172300==6 | S5172300==8)*(S5088700)*(S5088700>0) +
                       (S5172400==6 | S5172400==8)*(S5088800)*(S5088800>0) + 
                       (S5172500==6 | S5172500==8)*(S5088900)*(S5088900>0) + 
                       (S5172600==6 | S5172600==8)*(S5089000)*(S5089000>0) + 
                       (S5172700==6 | S5172700==8)*(S5089100)*(S5089100>0) if S5171600~=-5;
replace StepFathersAge_04 = . if (StepFathersAge_04-7-floor(age_1997))<13 | (StepFathersAge_04-7-floor(age_1997))>70;
                         
/**************************************************************************************************/
/* PARENTAL EDUCATION VARIABLES                                                                   */
/* NOTE: (i) purpose question, (2) base res HR roster, (3) base non res HR RS, (4) 1998 res HR    */
/**************************************************************************************************/

/* get highest grade completed data for parents from baseline if available */
/* NOTE: Categorize "ungraded" as zero years of schooling */
g HGC_FATH97 = R1302400 if R1302400>=0 & R1302400<=20;
replace HGC_FATH97=0 if R1302400==95;
g HGC_MOTH97 = R1302500 if R1302500>=0 & R1302500<=20;
replace HGC_MOTH97=0 if R1302500==95;
g str200 HGC_FATH97_Source = "(1) Purpose question in baseline" if HGC_FATH97~=.;
g str200 HGC_MOTH97_Source = "(1) Purpose question in baseline" if HGC_MOTH97~=.;

/* use education data in 1997 household roster to fill in missing values for parents' education */
/* first look at residential roster */
replace HGC_FATH97 = (R1315800==4)*(R1099400) + 
		          	 (R1315900==4)*(R1099500) + 
		             (R1316000==4)*(R1099600) +  
					 (R1316100==4)*(R1099700) + 
                     (R1316200==4)*(R1099800) +  
                     (R1316300==4)*(R1099900) +  
                     (R1316400==4)*(R1100000) +  
                     (R1316500==4)*(R1100100) + 
                     (R1316600==4)*(R1100200) +  
                     (R1316700==4)*(R1100300) +  
                     (R1316800==4)*(R1100400) +  
                     (R1316900==4)*(R1100500) + 
                     (R1317000==4)*(R1100600) +  
                     (R1317100==4)*(R1100700) +  
                     (R1317200==4)*(R1100800) +  
                     (R1317300==4)*(R1100900) if R1315800~=-5 & missing(HGC_FATH97) & FatherInHome_97==1;
replace HGC_FATH97 = 0 if HGC_FATH97==95;                        
replace HGC_FATH97 = . if HGC_FATH97<0 | HGC_FATH97>20;
replace HGC_FATH97_Source = "(2) HGC question in 1997 HR" if HGC_FATH97~=. & missing(HGC_FATH97_Source);                              

replace HGC_MOTH97 = (R1315800==3)*(R1099400) + 
		          	 (R1315900==3)*(R1099500) + 
		             (R1316000==3)*(R1099600) +  
					 (R1316100==3)*(R1099700) + 
                     (R1316200==3)*(R1099800) +  
                     (R1316300==3)*(R1099900) +  
                     (R1316400==3)*(R1100000) +  
                     (R1316500==3)*(R1100100) + 
                     (R1316600==3)*(R1100200) +  
                     (R1316700==3)*(R1100300) +  
                     (R1316800==3)*(R1100400) +  
                     (R1316900==3)*(R1100500) + 
                     (R1317000==3)*(R1100600) +  
                     (R1317100==3)*(R1100700) +  
                     (R1317200==3)*(R1100800) +  
                     (R1317300==3)*(R1100900) if R1315800~=-5 & missing(HGC_FATH97) & MotherInHome_97==1;
replace HGC_MOTH97 = 0 if HGC_MOTH97==95;                            
replace HGC_MOTH97 = . if HGC_MOTH97<0 | HGC_MOTH97>20;
replace HGC_MOTH97_Source = "(2) HGC question in 1997 HR" if HGC_MOTH97~=. & missing(HGC_MOTH97_Source);

/* second look at non-residential roster */
g FatherOnNonResRoster_97 = (R1186600==4) + (R1186700==4) + (R1186800==4) + (R1186900==4) +
					 	    (R1187000==4) + (R1187100==4) + (R1187200==4) + (R1187300==4) +
					 	    (R1187400==4) + (R1187500==4) + (R1187600==4) + (R1187700==4) +
					 	    (R1187800==4) + (R1187900==4) + (R1188000==4) + (R1188100==4) if R1186600~=-5;
					 	  
replace HGC_FATH97 = (R1186600==4)*(R1176900) +
					 (R1186700==4)*(R1177000) +
					 (R1186800==4)*(R1177100) +
				     (R1186900==4)*(R1177200) +
					 (R1187000==4)*(R1177300) +
					 (R1187100==4)*(R1177400) +
					 (R1187200==4)*(R1177500) +
					 (R1187300==4)*(R1177600) +
					 (R1187400==4)*(R1177700) +
					 (R1187500==4)*(R1177800) +
					 (R1187600==4)*(R1177900) +
					 (R1187700==4)*(R1178000) +
					 (R1187800==4)*(R1178100) +
					 (R1187900==4)*(R1178200) +
					 (R1188000==4)*(R1178300) +
					 (R1188100==4)*(R1178900) if R1186600~=-5 & missing(HGC_FATH97) & FatherOnNonResRoster_97==1;;                              
replace HGC_FATH97 = 0 if HGC_FATH97==95;   
replace HGC_FATH97 = . if HGC_FATH97<0 | HGC_FATH97>20;
replace HGC_FATH97_Source = "(3) HGC question in 1997 non-res HR" if HGC_FATH97~=. & missing(HGC_FATH97_Source);                              

g MotherOnNonResRoster_97 = (R1186600==3) + (R1186700==3) + (R1186800==3) + (R1186900==3) +
					 	    (R1187000==3) + (R1187100==3) + (R1187200==3) + (R1187300==3) +
					 	    (R1187400==3) + (R1187500==3) + (R1187600==3) + (R1187700==3) +
					 	    (R1187800==3) + (R1187900==3) + (R1188000==3) + (R1188100==3) if R1186600~=-5;
					 	  
replace HGC_MOTH97 = (R1186600==3)*(R1176900) +
					 (R1186700==3)*(R1177000) +
					 (R1186800==3)*(R1177100) +
				     (R1186900==3)*(R1177200) +
					 (R1187000==3)*(R1177300) +
					 (R1187100==3)*(R1177400) +
					 (R1187200==3)*(R1177500) +
					 (R1187300==3)*(R1177600) +
					 (R1187400==3)*(R1177700) +
					 (R1187500==3)*(R1177800) +
					 (R1187600==3)*(R1177900) +
					 (R1187700==3)*(R1178000) +
					 (R1187800==3)*(R1178100) +
					 (R1187900==3)*(R1178200) +
					 (R1188000==3)*(R1178300) +
					 (R1188100==3)*(R1178900) if R1186600~=-5 & missing(HGC_MOTH97) & MotherOnNonResRoster_97==1;
replace HGC_MOTH97 = 0 if HGC_MOTH97==95;			 					                               
replace HGC_MOTH97 = . if HGC_MOTH97<0 | HGC_MOTH97>20;
replace HGC_MOTH97_Source = "(3) HGC question in 1997 non-res HR" if HGC_MOTH97~=. & missing(HGC_MOTH97_Source);                              

/* use education data in 1998 household roster to fill in missing values for parents' education */
/* NOTE: Only residential roster includes schooling information */
replace HGC_FATH97 = (R2416300==4)*(R2407900) + 
					 (R2416400==4)*(R2408000) + 
					 (R2416500==4)*(R2408100) + 
					 (R2416600==4)*(R2408200) +
                     (R2416700==4)*(R2408300) + 
                     (R2416800==4)*(R2408400) + 
                     (R2416900==4)*(R2408500) + 
                     (R2417000==4)*(R2408600) +
                     (R2417100==4)*(R2408700) + 
                     (R2417200==4)*(R2408800) + 
                     (R2417300==4)*(R2408900) + 
                     (R2417400==4)*(R2409000) +
                     (R2417500==4)*(R2409100) + 
                     (R2417600==4)*(R2409200) if R2416300~=-5 & missing(HGC_FATH97) & FatherInHome_98==1;;                              
replace HGC_FATH97 = 0 if HGC_FATH97==95;   
replace HGC_FATH97 = . if HGC_FATH97<0 | HGC_FATH97>20;
replace HGC_FATH97_Source = "(4) HGC question in 1998 HR" if HGC_FATH97~=. & missing(HGC_FATH97_Source);                              

replace HGC_MOTH97 = (R2416300==3)*(R2407900) + 
					 (R2416400==3)*(R2408000) + 
					 (R2416500==3)*(R2408100) + 
					 (R2416600==3)*(R2408200) +
                     (R2416700==3)*(R2408300) + 
                     (R2416800==3)*(R2408400) + 
                     (R2416900==3)*(R2408500) + 
                     (R2417000==3)*(R2408600) +
                     (R2417100==3)*(R2408700) + 
                     (R2417200==3)*(R2408800) + 
                     (R2417300==3)*(R2408900) + 
                     (R2417400==3)*(R2409000) +
                     (R2417500==3)*(R2409100) + 
                     (R2417600==3)*(R2409200) if R2416300~=-5 & missing(HGC_MOTH97) & MotherInHome_98==1;;                              
replace HGC_MOTH97 = 0 if HGC_MOTH97==95;   
replace HGC_MOTH97 = . if HGC_MOTH97<0 | HGC_MOTH97>20;
replace HGC_MOTH97_Source = "(4) HGC question in 1998 HR" if HGC_MOTH97~=. & missing(HGC_MOTH97_Source);                              

/* create average parental education and interaction variables */
g HGC_PAR97 = (HGC_MOTH97+HGC_FATH97)/2;   
g HGC_MxF97 = HGC_MOTH97*HGC_FATH97;

/* create parental education data availability measures */
g str200 ParentsHGCAvailability = "(1) Both parents' education available" 	 if HGC_MOTH97 ~=. & HGC_FATH97 ~=.;
replace  ParentsHGCAvailability	= "(2) Mother's education only" 			 if HGC_MOTH97 ~=. & HGC_FATH97 ==.; 
replace  ParentsHGCAvailability	= "(3) Father's education only" 			 if HGC_MOTH97 ==. & HGC_FATH97 ~=.;
replace  ParentsHGCAvailability	= "(4) Neither parents' education available" if HGC_MOTH97 ==. & HGC_FATH97 ==.;                                                  

/**************************************************************************************************/
/* FAMILY INCOME AND WAGES ETC.                                                                   */
/**************************************************************************************************/

g family_income_97 	= R1204500 if R1204500>=0;
g income_source_97  = R1204600;
g family_size_97    = R1205400 if R1205400>0;

g family_income_98 	= R2563300 if R2563300>=0;
g family_size_98    = R2563700 if R2563700>0;

g family_income_99 	= R3884900 if R3884900>=0;
g family_size_99    = R3885300 if R3885300>0;

g family_income_00 	= R5464100 if R5464100>=0;
g family_size_00    = R5464500 if R5464500>0;

g family_income_01 	= R7227800 if R7227800>=0;
g family_size_01    = R7228200 if R7228200>0;

g family_income_02 	= S1541700 if S1541700>=0;
g family_size_02    = S1542100 if S1542100>0;

g family_income_03 	= S2011500 if S2011500>=0;
g family_size_03    = S2011900 if S2011900>0;

g family_income_04 	= S3812400 if S3812400>=0;
g family_size_04    = S3813400 if S3813400>0;

g family_income_05 	= S5412800 if S5412800>=0;
g family_size_05    = S5413000 if S5413000>0;

g family_income_06 	= S7513700 if S7513700>=0;
g family_size_06    = S7513900 if S7513900>0;

g family_income_07 	= T0014100 if T0014100>=0;
g family_size_07    = T0014300 if T0014300>0;

g family_income_08 	= T2016200 if T2016200>=0;
g family_size_08    = T2016400 if T2016400>0;

g family_income_09 	= T3606500 if T3606500>=0;
g family_size_09    = T3606700 if T3606700>0;

/*****************************************************************************************************/
/* Flag units/year combinations with inconsistent household roster information                       */
/*****************************************************************************************************/

g mom_roster_flag_97 = 1 	if (MotherInHome_97>1 & MotherInHome_97~=.) | 
							   (StepMotherInHome_97>1 & StepMotherInHome_97~=.) | 
							   (MotherInHome_97>=1 & MotherInHome_97~=. & StepMotherInHome_97>=1 & StepMotherInHome_97~=.);
g dad_roster_flag_97 = 1 	if (FatherInHome_97>1 & FatherInHome_97~=.) | 
							   (StepFatherInHome_97>1 & StepFatherInHome_97~=.) | 
							   (FatherInHome_97>=1 & FatherInHome_97~=. & StepFatherInHome_97>=1 & StepFatherInHome_97~=.);

g mom_roster_flag_98 = 1 	if (MotherInHome_98>1 & MotherInHome_98~=.) | 
							   (StepMotherInHome_98>1 & StepMotherInHome_98~=.) | 
							   (MotherInHome_98>=1 & MotherInHome_98~=. & StepMotherInHome_98>=1 & StepMotherInHome_98~=.);
g dad_roster_flag_98 = 1 	if (FatherInHome_98>1 & FatherInHome_98~=.) | 
							   (StepFatherInHome_98>1 & StepFatherInHome_98~=.) | 
							   (FatherInHome_98>=1 & FatherInHome_98~=. & StepFatherInHome_98>=1 & StepFatherInHome_98~=.);

g mom_roster_flag_99 = 1 	if (MotherInHome_99>1 & MotherInHome_99~=.) | 
							   (StepMotherInHome_99>1 & StepMotherInHome_99~=.) | 
							   (MotherInHome_99>=1 & MotherInHome_99~=. & StepMotherInHome_99>=1 & StepMotherInHome_99~=.);
g dad_roster_flag_99 = 1 	if (FatherInHome_99>1 & FatherInHome_99~=.) | 
							   (StepFatherInHome_99>1 & StepFatherInHome_99~=.) | 
							   (FatherInHome_99>=1 & FatherInHome_99~=. & StepFatherInHome_99>=1 & StepFatherInHome_99~=.);
							   
g mom_roster_flag_00 = 1 	if (MotherInHome_00>1 & MotherInHome_00~=.) | 
							   (StepMotherInHome_00>1 & StepMotherInHome_00~=.) | 
							   (MotherInHome_00>=1 & MotherInHome_00~=. & StepMotherInHome_00>=1 & StepMotherInHome_00~=.);
g dad_roster_flag_00 = 1 	if (FatherInHome_00>1 & FatherInHome_00~=.) | 
							   (StepFatherInHome_00>1 & StepFatherInHome_00~=.) | 
							   (FatherInHome_00>=1 & FatherInHome_00~=. & StepFatherInHome_00>=1 & StepFatherInHome_00~=.);
							   
g mom_roster_flag_01 = 1 	if (MotherInHome_01>1 & MotherInHome_01~=.) | 
							   (StepMotherInHome_01>1 & StepMotherInHome_01~=.) | 
							   (MotherInHome_01>=1 & MotherInHome_01~=. & StepMotherInHome_01>=1 & StepMotherInHome_01~=.);
g dad_roster_flag_01 = 1 	if (FatherInHome_01>1 & FatherInHome_01~=.) | 
							   (StepFatherInHome_01>1 & StepFatherInHome_01~=.) | 
							   (FatherInHome_01>=1 & FatherInHome_01~=. & StepFatherInHome_01>=1 & StepFatherInHome_01~=.);
							   
g mom_roster_flag_02 = 1 	if (MotherInHome_02>1 & MotherInHome_02~=.) | 
							   (StepMotherInHome_02>1 & StepMotherInHome_02~=.) | 
							   (MotherInHome_02>=1 & MotherInHome_02~=. & StepMotherInHome_02>=1 & StepMotherInHome_02~=.);
g dad_roster_flag_02 = 1 	if (FatherInHome_02>1 & FatherInHome_02~=.) | 
							   (StepFatherInHome_02>1 & StepFatherInHome_02~=.) | 
							   (FatherInHome_02>=1 & FatherInHome_02~=. & StepFatherInHome_02>=1 & StepFatherInHome_02~=.);
							   
g mom_roster_flag_03 = 1 	if (MotherInHome_03>1 & MotherInHome_03~=.) | 
							   (StepMotherInHome_03>1 & StepMotherInHome_03~=.) | 
							   (MotherInHome_03>=1 & MotherInHome_03~=. & StepMotherInHome_03>=1 & StepMotherInHome_03~=.);
g dad_roster_flag_03 = 1 	if (FatherInHome_03>1 & FatherInHome_03~=.) | 
							   (StepFatherInHome_03>1 & StepFatherInHome_03~=.) | 
							   (FatherInHome_03>=1 & FatherInHome_03~=. & StepFatherInHome_03>=1 & StepFatherInHome_03~=.);
							   
g mom_roster_flag_04 = 1 	if (MotherInHome_04>1 & MotherInHome_04~=.) | 
							   (StepMotherInHome_04>1 & StepMotherInHome_04~=.) | 
							   (MotherInHome_04>=1 & MotherInHome_04~=. & StepMotherInHome_04>=1 & StepMotherInHome_04~=.);
g dad_roster_flag_04 = 1 	if (FatherInHome_04>1 & FatherInHome_04~=.) | 
							   (StepFatherInHome_04>1 & StepFatherInHome_04~=.) | 
							   (FatherInHome_04>=1 & FatherInHome_04~=. & StepFatherInHome_04>=1 & StepFatherInHome_04~=.);
							   
/*****************************************************************************************************/
/* GENERATE "HOUSEHOLD HEAD" AGE INFORMATION in 1997                                                 */
/* NOTE: Head is father, step-father or mother in that order                                         */
/*****************************************************************************************************/

g HouseholdHeadAge_97 = FathersAge_97 if FatherInHome_97==1;
g str100 HouseholdHeadAge_97_source = "Father" if HouseholdHeadAge_97~=.;
replace HouseholdHeadAge_97 = StepFathersAge_97 if HouseholdHeadAge_97==. & StepFatherInHome_97==1;
replace HouseholdHeadAge_97_source = "Step-Father" if HouseholdHeadAge_97_source=="" & HouseholdHeadAge_97~=.;
replace HouseholdHeadAge_97 = MothersAge_97 if HouseholdHeadAge_97==. & MotherInHome_97==1;
replace HouseholdHeadAge_97_source = "Mother" if HouseholdHeadAge_97_source=="" & HouseholdHeadAge_97~=.;
							   							   							   							   							   							   							   							   							   							   
g HouseholdHeadAge_98 = FathersAge_97+1 if FatherInHome_98==1;
g str100 HouseholdHeadAge_98_source = "Father" if HouseholdHeadAge_98~=.;
replace HouseholdHeadAge_98 = StepFathersAge_98 if HouseholdHeadAge_98==. & StepFatherInHome_98==1;
replace HouseholdHeadAge_98_source = "Step-Father" if HouseholdHeadAge_98_source=="" & HouseholdHeadAge_98~=.;
replace HouseholdHeadAge_98 = MothersAge_97+1 if HouseholdHeadAge_98==. & MotherInHome_98==1;
replace HouseholdHeadAge_98_source = "Mother" if HouseholdHeadAge_98_source=="" & HouseholdHeadAge_98~=.;
							   							   							   							   							   							   							   							   							   							   
g HouseholdHeadAge_99 = FathersAge_97+2 if FatherInHome_99==1;
g str100 HouseholdHeadAge_99_source = "Father" if HouseholdHeadAge_99~=.;
replace HouseholdHeadAge_99 = StepFathersAge_99 if HouseholdHeadAge_99==. & StepFatherInHome_99==1;
replace HouseholdHeadAge_99_source = "Step-Father" if HouseholdHeadAge_99_source=="" & HouseholdHeadAge_99~=.;
replace HouseholdHeadAge_99 = MothersAge_97+2 if HouseholdHeadAge_99==. & MotherInHome_99==1;
replace HouseholdHeadAge_99_source = "Mother" if HouseholdHeadAge_99_source=="" & HouseholdHeadAge_99~=.;

g HouseholdHeadAge_00 = FathersAge_97+3 if FatherInHome_00==1;
g str100 HouseholdHeadAge_00_source = "Father" if HouseholdHeadAge_00~=.;
replace HouseholdHeadAge_00 = StepFathersAge_00 if HouseholdHeadAge_00==. & StepFatherInHome_00==1;
replace HouseholdHeadAge_00_source = "Step-Father" if HouseholdHeadAge_00_source=="" & HouseholdHeadAge_00~=.;
replace HouseholdHeadAge_00 = MothersAge_97+3 if HouseholdHeadAge_00==. & MotherInHome_00==1;
replace HouseholdHeadAge_00_source = "Mother" if HouseholdHeadAge_00_source=="" & HouseholdHeadAge_00~=.;

g HouseholdHeadAge_01 = FathersAge_97+4 if FatherInHome_01==1;
g str100 HouseholdHeadAge_01_source = "Father" if HouseholdHeadAge_01~=.;
replace HouseholdHeadAge_01 = StepFathersAge_01 if HouseholdHeadAge_01==. & StepFatherInHome_01==1;
replace HouseholdHeadAge_01_source = "Step-Father" if HouseholdHeadAge_01_source=="" & HouseholdHeadAge_01~=.;
replace HouseholdHeadAge_01 = MothersAge_97+4 if HouseholdHeadAge_01==. & MotherInHome_01==1;
replace HouseholdHeadAge_01_source = "Mother" if HouseholdHeadAge_01_source=="" & HouseholdHeadAge_01~=.;

g HouseholdHeadAge_02 = FathersAge_97+5 if FatherInHome_02==1;
g str100 HouseholdHeadAge_02_source = "Father" if HouseholdHeadAge_02~=.;
replace HouseholdHeadAge_02 = StepFathersAge_02 if HouseholdHeadAge_02==. & StepFatherInHome_02==1;
replace HouseholdHeadAge_02_source = "Step-Father" if HouseholdHeadAge_02_source=="" & HouseholdHeadAge_02~=.;
replace HouseholdHeadAge_02 = MothersAge_97+5 if HouseholdHeadAge_02==. & MotherInHome_02==1;
replace HouseholdHeadAge_02_source = "Mother" if HouseholdHeadAge_02_source=="" & HouseholdHeadAge_02~=.;

g HouseholdHeadAge_03 = FathersAge_97+6 if FatherInHome_03==1;
g str100 HouseholdHeadAge_03_source = "Father" if HouseholdHeadAge_03~=.;
replace HouseholdHeadAge_03 = StepFathersAge_03 if HouseholdHeadAge_03==. & StepFatherInHome_03==1;
replace HouseholdHeadAge_03_source = "Step-Father" if HouseholdHeadAge_03_source=="" & HouseholdHeadAge_03~=.;
replace HouseholdHeadAge_03 = MothersAge_97+6 if HouseholdHeadAge_03==. & MotherInHome_03==1;
replace HouseholdHeadAge_03_source = "Mother" if HouseholdHeadAge_03_source=="" & HouseholdHeadAge_03~=.;

g HouseholdHeadAge_04 = FathersAge_97+7 if FatherInHome_04==1;
g str100 HouseholdHeadAge_04_source = "Father" if HouseholdHeadAge_04~=.;
replace HouseholdHeadAge_04 = StepFathersAge_04 if HouseholdHeadAge_04==. & StepFatherInHome_04==1;
replace HouseholdHeadAge_04_source = "Step-Father" if HouseholdHeadAge_04_source=="" & HouseholdHeadAge_04~=.;
replace HouseholdHeadAge_04 = MothersAge_97+7 if HouseholdHeadAge_04==. & MotherInHome_04==1;
replace HouseholdHeadAge_04_source = "Mother" if HouseholdHeadAge_04_source=="" & HouseholdHeadAge_04~=.;

/*****************************************************************************************************/
/* GENERATE PARENTAL FAMILY INCOME VARIABLES                                                         */
/* NOTE: Deflate using the national CPI-U-R (research) index with 2010 = 100                         */ 
/*****************************************************************************************************/

g RPFIpc_96v3 = 3.202*(family_income_97/2.314)/family_size_97 if (MotherInHome_97==1 | FatherInHome_97==1) & age_1997-1<19 & HouseholdHeadAge_97~=.;
g RPFIpc_96v4 = 3.202*(family_income_97/2.314)/family_size_97 if MotherInHome_97==1 & FatherInHome_97==1 & age_1997-1<19 & HouseholdHeadAge_97~=.;

replace RPFIpc_96v3 = . if RPFIpc_96v3<100;
replace RPFIpc_96v4 = . if RPFIpc_96v4<100;

g RPFI_96v3 = RPFIpc_96v3*family_size_97;
g RPFI_96v4 = RPFIpc_96v4*family_size_97;

g RPFIpc_97v3 = 3.202*(family_income_98/2.364)/family_size_98 if (MotherInHome_98==1 | FatherInHome_98==1) & age_1997<19 & HouseholdHeadAge_98~=.;
g RPFIpc_97v4 = 3.202*(family_income_98/2.364)/family_size_98 if MotherInHome_98==1 & FatherInHome_98==1 & age_1997<19 & HouseholdHeadAge_98~=.;

replace RPFIpc_97v3 = . if RPFIpc_97v3<100;
replace RPFIpc_97v4 = . if RPFIpc_97v4<100;

g RPFI_97v3 = RPFIpc_97v3*family_size_98;
g RPFI_97v4 = RPFIpc_97v4*family_size_98;

g RPFIpc_98v3 = 3.202*(family_income_99/2.397)/family_size_99 if (MotherInHome_99==1 | FatherInHome_99==1) & age_1997+1<19 & HouseholdHeadAge_99~=.;
g RPFIpc_98v4 = 3.202*(family_income_99/2.397)/family_size_99 if MotherInHome_99==1 & FatherInHome_99==1 & age_1997+1<19 & HouseholdHeadAge_99~=.;

replace RPFIpc_98v3 = . if RPFIpc_98v3<100;
replace RPFIpc_98v4 = . if RPFIpc_98v4<100;

g RPFI_98v3 = RPFIpc_98v3*family_size_99;
g RPFI_98v4 = RPFIpc_98v4*family_size_99;

g RPFIpc_99v3 = 3.202*(family_income_00/2.447)/family_size_00 if (MotherInHome_00==1 | FatherInHome_00==1) & age_1997+2<19 & HouseholdHeadAge_00~=.;
g RPFIpc_99v4 = 3.202*(family_income_00/2.447)/family_size_00 if MotherInHome_00==1 & FatherInHome_00==1 & age_1997+2<19 & HouseholdHeadAge_00~=.;

replace RPFIpc_99v3 = . if RPFIpc_99v3<100;
replace RPFIpc_99v4 = . if RPFIpc_99v4<100;

g RPFI_99v3 = RPFIpc_99v3*family_size_00;
g RPFI_99v4 = RPFIpc_99v4*family_size_00;

g RPFIpc_00v3 = 3.202*(family_income_01/2.529)/family_size_01 if (MotherInHome_01==1 | FatherInHome_01==1) & age_1997+3<19 & HouseholdHeadAge_01~=.;
g RPFIpc_00v4 = 3.202*(family_income_01/2.529)/family_size_01 if MotherInHome_01==1 & FatherInHome_01==1 & age_1997+3<19 & HouseholdHeadAge_01~=.;

replace RPFIpc_00v3 = . if RPFIpc_00v3<100;
replace RPFIpc_00v4 = . if RPFIpc_00v4<100;

g RPFI_00v3 = RPFIpc_00v3*family_size_01;
g RPFI_00v4 = RPFIpc_00v4*family_size_01;

g RPFIpc_01v3 = 3.202*(family_income_02/2.600)/family_size_02 if (MotherInHome_02==1 | FatherInHome_02==1) & age_1997+4<19 & HouseholdHeadAge_02~=.;
g RPFIpc_01v4 = 3.202*(family_income_02/2.600)/family_size_02 if MotherInHome_02==1 & FatherInHome_02==1 & age_1997+4<19 & HouseholdHeadAge_02~=.;

replace RPFIpc_01v3 = . if RPFIpc_01v3<100;
replace RPFIpc_01v4 = . if RPFIpc_01v4<100;

g RPFI_01v3 = RPFIpc_01v3*family_size_02;
g RPFI_01v4 = RPFIpc_01v4*family_size_02;

g RPFIpc_02v3 = 3.202*(family_income_03/2.642)/family_size_03 if (MotherInHome_03==1 | FatherInHome_03==1) & age_1997+5<19 & HouseholdHeadAge_03~=.;
g RPFIpc_02v4 = 3.202*(family_income_03/2.642)/family_size_03 if MotherInHome_03==1 & FatherInHome_03==1 & age_1997+5<19 & HouseholdHeadAge_03~=.;

replace RPFIpc_02v3 = . if RPFIpc_02v3<100;
replace RPFIpc_02v4 = . if RPFIpc_02v4<100;

g RPFI_02v3 = RPFIpc_02v3*family_size_03;
g RPFI_02v4 = RPFIpc_02v4*family_size_03;

g RPFIpc_03v3 = 3.202*(family_income_04/2.701)/family_size_04 if (MotherInHome_04==1 | FatherInHome_04==1) & age_1997+6<19 & HouseholdHeadAge_04~=.;
g RPFIpc_03v4 = 3.202*(family_income_04/2.701)/family_size_04 if MotherInHome_04==1 & FatherInHome_04==1 & age_1997+6<19 & HouseholdHeadAge_04~=.;

replace RPFIpc_03v3 = . if RPFIpc_03v3<100;
replace RPFIpc_03v4 = . if RPFIpc_03v4<100;

g RPFI_03v3 = RPFIpc_03v3*family_size_04;
g RPFI_03v4 = RPFIpc_03v4*family_size_04;

/*****************************************************************************************************/
/* GENERATE A RESPONDENT-BY-WAVE DATA AVAILABILITY CODE                                              */
/*****************************************************************************************************/

g str200 DataAvailabilityCode97 = "(1) Lives with birth parents" 			if MotherInHome_97==1 & FatherInHome_97==1 & mom_roster_flag_97~=1 & dad_roster_flag_97~=1;
replace  DataAvailabilityCode97 = "(2) Lives with birth mother" 			if MotherInHome_97==1 & FatherInHome_97==0 & mom_roster_flag_97~=1 & dad_roster_flag_97~=1 & DataAvailabilityCode97=="";
replace  DataAvailabilityCode97 = "(3) Lives with birth father" 			if MotherInHome_97==0 & FatherInHome_97==1 & mom_roster_flag_97~=1 & dad_roster_flag_97~=1 & DataAvailabilityCode97=="";
replace  DataAvailabilityCode97 = "(4) Does not live with birth parent(s)" 	if MotherInHome_97==0 & FatherInHome_97==0 & mom_roster_flag_97~=1 & dad_roster_flag_97~=1 & DataAvailabilityCode97=="";
replace  DataAvailabilityCode97 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_97==1 | dad_roster_flag_97==1) & DataAvailabilityCode97=="";
replace  DataAvailabilityCode97 = "(6) Non-reponse" 						if (MotherInHome_97==. | FatherInHome_97==.) & DataAvailabilityCode97=="";

g str200 DataAvailabilityCode98 = "(1) Lives with birth parents" 			if MotherInHome_98==1 & FatherInHome_98==1 & mom_roster_flag_98~=1 & dad_roster_flag_98~=1;
replace  DataAvailabilityCode98 = "(2) Lives with birth mother" 			if MotherInHome_98==1 & FatherInHome_98==0 & mom_roster_flag_98~=1 & dad_roster_flag_98~=1 & DataAvailabilityCode98=="";
replace  DataAvailabilityCode98 = "(3) Lives with birth father" 			if MotherInHome_98==0 & FatherInHome_98==1 & mom_roster_flag_98~=1 & dad_roster_flag_98~=1 & DataAvailabilityCode98=="";
replace  DataAvailabilityCode98 = "(4) Does not live with birth parent(s)" 	if MotherInHome_98==0 & FatherInHome_98==0 & mom_roster_flag_98~=1 & dad_roster_flag_98~=1 & DataAvailabilityCode98=="";
replace  DataAvailabilityCode98 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_98==1 | dad_roster_flag_98==1) & DataAvailabilityCode98=="";
replace  DataAvailabilityCode98 = "(6) Non-reponse" 						if (MotherInHome_98==. | FatherInHome_98==.) & DataAvailabilityCode98=="";

g str200 DataAvailabilityCode99 = "(1) Lives with birth parents" 			if MotherInHome_99==1 & FatherInHome_99==1 & mom_roster_flag_99~=1 & dad_roster_flag_99~=1;
replace  DataAvailabilityCode99 = "(2) Lives with birth mother" 			if MotherInHome_99==1 & FatherInHome_99==0 & mom_roster_flag_99~=1 & dad_roster_flag_99~=1 & DataAvailabilityCode99=="";
replace  DataAvailabilityCode99 = "(3) Lives with birth father" 			if MotherInHome_99==0 & FatherInHome_99==1 & mom_roster_flag_99~=1 & dad_roster_flag_99~=1 & DataAvailabilityCode99=="";
replace  DataAvailabilityCode99 = "(4) Does not live with birth parent(s)" 	if MotherInHome_99==0 & FatherInHome_99==0 & mom_roster_flag_99~=1 & dad_roster_flag_99~=1 & DataAvailabilityCode99=="";
replace  DataAvailabilityCode99 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_99==1 | dad_roster_flag_99==1) & DataAvailabilityCode99=="";
replace  DataAvailabilityCode99 = "(6) Non-reponse" 						if (MotherInHome_99==. | FatherInHome_99==.) & DataAvailabilityCode99=="";

g str200 DataAvailabilityCode00 = "(1) Lives with birth parents" 			if MotherInHome_00==1 & FatherInHome_00==1 & mom_roster_flag_00~=1 & dad_roster_flag_00~=1;
replace  DataAvailabilityCode00 = "(2) Lives with birth mother" 			if MotherInHome_00==1 & FatherInHome_00==0 & mom_roster_flag_00~=1 & dad_roster_flag_00~=1 & DataAvailabilityCode00=="";
replace  DataAvailabilityCode00 = "(3) Lives with birth father" 			if MotherInHome_00==0 & FatherInHome_00==1 & mom_roster_flag_00~=1 & dad_roster_flag_00~=1 & DataAvailabilityCode00=="";
replace  DataAvailabilityCode00 = "(4) Does not live with birth parent(s)" 	if MotherInHome_00==0 & FatherInHome_00==0 & mom_roster_flag_00~=1 & dad_roster_flag_00~=1 & DataAvailabilityCode00=="";
replace  DataAvailabilityCode00 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_00==1 | dad_roster_flag_00==1) & DataAvailabilityCode00=="";
replace  DataAvailabilityCode00 = "(6) Non-reponse" 						if (MotherInHome_00==. | FatherInHome_00==.) & DataAvailabilityCode00=="";

g str200 DataAvailabilityCode01 = "(1) Lives with birth parents" 			if MotherInHome_01==1 & FatherInHome_01==1 & mom_roster_flag_01~=1 & dad_roster_flag_01~=1;
replace  DataAvailabilityCode01 = "(2) Lives with birth mother" 			if MotherInHome_01==1 & FatherInHome_01==0 & mom_roster_flag_01~=1 & dad_roster_flag_01~=1 & DataAvailabilityCode01=="";
replace  DataAvailabilityCode01 = "(3) Lives with birth father" 			if MotherInHome_01==0 & FatherInHome_01==1 & mom_roster_flag_01~=1 & dad_roster_flag_01~=1 & DataAvailabilityCode01=="";
replace  DataAvailabilityCode01 = "(4) Does not live with birth parent(s)" 	if MotherInHome_01==0 & FatherInHome_01==0 & mom_roster_flag_01~=1 & dad_roster_flag_01~=1 & DataAvailabilityCode01=="";
replace  DataAvailabilityCode01 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_01==1 | dad_roster_flag_01==1) & DataAvailabilityCode01=="";
replace  DataAvailabilityCode01 = "(6) Non-reponse" 						if (MotherInHome_01==. | FatherInHome_01==.) & DataAvailabilityCode01=="";

g str200 DataAvailabilityCode02 = "(1) Lives with birth parents" 			if MotherInHome_02==1 & FatherInHome_02==1 & mom_roster_flag_02~=1 & dad_roster_flag_02~=1;
replace  DataAvailabilityCode02 = "(2) Lives with birth mother" 			if MotherInHome_02==1 & FatherInHome_02==0 & mom_roster_flag_02~=1 & dad_roster_flag_02~=1 & DataAvailabilityCode02=="";
replace  DataAvailabilityCode02 = "(3) Lives with birth father" 			if MotherInHome_02==0 & FatherInHome_02==1 & mom_roster_flag_02~=1 & dad_roster_flag_02~=1 & DataAvailabilityCode02=="";
replace  DataAvailabilityCode02 = "(4) Does not live with birth parent(s)" 	if MotherInHome_02==0 & FatherInHome_02==0 & mom_roster_flag_02~=1 & dad_roster_flag_02~=1 & DataAvailabilityCode02=="";
replace  DataAvailabilityCode02 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_02==1 | dad_roster_flag_02==1) & DataAvailabilityCode02=="";
replace  DataAvailabilityCode02 = "(6) Non-reponse" 						if (MotherInHome_02==. | FatherInHome_02==.) & DataAvailabilityCode02=="";							

g str200 DataAvailabilityCode03 = "(1) Lives with birth parents" 			if MotherInHome_03==1 & FatherInHome_03==1 & mom_roster_flag_03~=1 & dad_roster_flag_03~=1;
replace  DataAvailabilityCode03 = "(2) Lives with birth mother" 			if MotherInHome_03==1 & FatherInHome_03==0 & mom_roster_flag_03~=1 & dad_roster_flag_03~=1 & DataAvailabilityCode03=="";
replace  DataAvailabilityCode03 = "(3) Lives with birth father" 			if MotherInHome_03==0 & FatherInHome_03==1 & mom_roster_flag_03~=1 & dad_roster_flag_03~=1 & DataAvailabilityCode03=="";
replace  DataAvailabilityCode03 = "(4) Does not live with birth parent(s)" 	if MotherInHome_03==0 & FatherInHome_03==0 & mom_roster_flag_03~=1 & dad_roster_flag_03~=1 & DataAvailabilityCode03=="";
replace  DataAvailabilityCode03 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_03==1 | dad_roster_flag_03==1) & DataAvailabilityCode03=="";
replace  DataAvailabilityCode03 = "(6) Non-reponse" 						if (MotherInHome_03==. | FatherInHome_03==.) & DataAvailabilityCode03=="";

g str200 DataAvailabilityCode04 = "(1) Lives with birth parents" 			if MotherInHome_04==1 & FatherInHome_04==1 & mom_roster_flag_04~=1 & dad_roster_flag_04~=1;
replace  DataAvailabilityCode04 = "(2) Lives with birth mother" 			if MotherInHome_04==1 & FatherInHome_04==0 & mom_roster_flag_04~=1 & dad_roster_flag_04~=1 & DataAvailabilityCode04=="";
replace  DataAvailabilityCode04 = "(3) Lives with birth father" 			if MotherInHome_04==0 & FatherInHome_04==1 & mom_roster_flag_04~=1 & dad_roster_flag_04~=1 & DataAvailabilityCode04=="";
replace  DataAvailabilityCode04 = "(4) Does not live with birth parent(s)" 	if MotherInHome_04==0 & FatherInHome_04==0 & mom_roster_flag_04~=1 & dad_roster_flag_04~=1 & DataAvailabilityCode04=="";
replace  DataAvailabilityCode04 = "(5) Inconsistency in household roster" 	if (mom_roster_flag_04==1 | dad_roster_flag_04==1) & DataAvailabilityCode04=="";
replace  DataAvailabilityCode04 = "(6) Non-reponse" 						if (MotherInHome_04==. | FatherInHome_04==.) & DataAvailabilityCode04=="";

/****************************************************************************************************/
/* COMPUTE MEASURES OF AVERAGE PARENTAL/FAMILY INCOME DURING ADOLESCENCE                            */
/* NOTE: Use the "third" income measure defined above (i.e., at least one parent, less <= 18 years) */
/****************************************************************************************************/

/* per capita measure */
egen RPFIpc_Avg		= rowmean(RPFIpc_96v3 RPFIpc_97v3 RPFIpc_98v3 RPFIpc_99v3 
							  RPFIpc_00v3 RPFIpc_01v3 RPFIpc_02v3 RPFIpc_03v3);                        
egen numRPFIpc  	= rownonmiss(RPFIpc_96v3 RPFIpc_97v3 RPFIpc_98v3 RPFIpc_99v3 
								 RPFIpc_00v3 RPFIpc_01v3 RPFIpc_02v3 RPFIpc_03v3);                                   

/* non per capita measure */
egen RPFI_Avg 		= rowmean(RPFI_96v3 RPFI_97v3 RPFI_98v3 RPFI_99v3 RPFI_00v3 
							  RPFI_01v3 RPFI_02v3 RPFI_03v3);

/* average age of household head */
g hh96 = (HouseholdHeadAge_97-1) if RPFIpc_96v3~=.;
g hh97 = (HouseholdHeadAge_98-1) if RPFIpc_97v3~=.; 
g hh98 = (HouseholdHeadAge_99-1) if RPFIpc_98v3~=.;
g hh99 = (HouseholdHeadAge_00-1) if RPFIpc_99v3~=.;
g hh00 = (HouseholdHeadAge_01-1) if RPFIpc_00v3~=.;
g hh01 = (HouseholdHeadAge_02-1) if RPFIpc_01v3~=.;
g hh02 = (HouseholdHeadAge_03-1) if RPFIpc_02v3~=.;
g hh03 = (HouseholdHeadAge_04-1) if RPFIpc_03v3~=.;
                              
egen AvgHeadAge = rowmean(hh96 hh97 hh98 hh99 hh00 hh01 hh02 hh03);
drop hh96-hh03;

/* average family size */
g fs96 = (family_size_97) if RPFIpc_96v3~=.;
g fs97 = (family_size_98) if RPFIpc_97v3~=.; 
g fs98 = (family_size_99) if RPFIpc_98v3~=.;
g fs99 = (family_size_00) if RPFIpc_99v3~=.;
g fs00 = (family_size_01) if RPFIpc_00v3~=.;
g fs01 = (family_size_02) if RPFIpc_01v3~=.;
g fs02 = (family_size_03) if RPFIpc_02v3~=.;
g fs03 = (family_size_04) if RPFIpc_03v3~=.;
                              
egen AvgFamSize = rowmean(fs96 fs97 fs98 fs99 fs00 fs01 fs02 fs03);
drop fs96-fs03;

/*****************************************************************************************************/
/* GENERATE CHILD FAMILY INCOME VARIABLES                                                            */
/* NOTE: Deflate using the national CPI-U-R (research) index with 2010 = 100                         */
/*       Only start measuring income at age 22 and greater                                           */
/*****************************************************************************************************/

g RCFIpc_2002 = 3.202*(family_income_03/2.642)/family_size_03 if age_1997>=17;
replace RCFIpc_2002 = . if RCFIpc_2002<100;
g RCFI_2002 = RCFIpc_2002*family_size_03;

g RCFIpc_2003 = 3.202*(family_income_04/2.701)/family_size_04 if age_1997>=16;
replace RCFIpc_2003 = . if RCFIpc_2003<100;
g RCFI_2003 = RCFIpc_2003*family_size_04;

g RCFIpc_2004 = 3.202*(family_income_05/2.774)/family_size_05 if age_1997>=15;
replace RCFIpc_2004 = . if RCFIpc_2004<100;
g RCFI_2004 = RCFIpc_2004*family_size_05;

g RCFIpc_2005 = 3.202*(family_income_06/2.867)/family_size_06 if age_1997>=14;
replace RCFIpc_2005 = . if RCFIpc_2005<100;
g RCFI_2005 = RCFIpc_2005*family_size_06;

g RCFIpc_2006 = 3.202*(family_income_07/2.961)/family_size_07 if age_1997>=13;
replace RCFIpc_2006 = . if RCFIpc_2006<100;
g RCFI_2006 = RCFIpc_2006*family_size_07;

g RCFIpc_2007 = 3.202*(family_income_08/3.045)/family_size_08 if age_1997>=12;
replace RCFIpc_2007 = . if RCFIpc_2007<100;
g RCFI_2007 = RCFIpc_2007*family_size_08;

g RCFIpc_2008 = 3.202*(family_income_09/3.162)/family_size_09 if age_1997>=11;
replace RCFIpc_2008 = . if RCFIpc_2008<100;
g RCFI_2008 = RCFIpc_2008*family_size_09;

/* Compute measures of average respondent income over early adulthood */
egen RCFIpc_Avg = rowmean(RCFIpc_2002 RCFIpc_2003 RCFIpc_2004 RCFIpc_2005
                          RCFIpc_2006 RCFIpc_2007 RCFIpc_2008);                         
egen RCFI_Avg 	= rowmean(RCFI_2002 RCFI_2003 RCFI_2004 RCFI_2005
                          RCFI_2006 RCFI_2007 RCFI_2008);                                                          
egen NumberOfAdultIncomes = rownonmiss(RCFIpc_2002 RCFIpc_2003 RCFIpc_2004 RCFIpc_2005
                                       RCFIpc_2006 RCFIpc_2007 RCFIpc_2008);
                                       
/* average age of child during period of "adult" income measurement */
g ca02 = (age_1997+5) if RCFIpc_2002~=.;
g ca03 = (age_1997+6) if RCFIpc_2003~=.;
g ca04 = (age_1997+7) if RCFIpc_2004~=.;
g ca05 = (age_1997+8) if RCFIpc_2005~=.;
g ca06 = (age_1997+9) if RCFIpc_2006~=.;
g ca07 = (age_1997+10) if RCFIpc_2007~=.;
g ca08 = (age_1997+11) if RCFIpc_2008~=.;
                              
egen AvgChildAge = rowmean(ca02 ca03 ca04 ca05 ca06 ca07 ca08);
drop ca02-ca08;

/* average family size */
g fs02 = (family_size_03) if RCFIpc_2002~=.;
g fs03 = (family_size_04) if RCFIpc_2003~=.; 
g fs04 = (family_size_05) if RCFIpc_2004~=.;
g fs05 = (family_size_06) if RCFIpc_2005~=.;
g fs06 = (family_size_07) if RCFIpc_2006~=.;
g fs07 = (family_size_08) if RCFIpc_2007~=.;
g fs08 = (family_size_09) if RCFIpc_2008~=.;
                              
egen AvgChildFamSize = rowmean(fs02 fs03 fs04 fs05 fs06 fs07 fs08);
drop fs02-fs08;                                   

save "$WRITE_DATA/PewNLSY97_AnalyticBase", replace;
save "$WRITE_DATA_TEACHING/NLSY97_BaseFile", replace;

log using "$WRITE_DATA/PewMobilityNLSY97_SummaryStatistics", replace;
log on;

/*****************************************************************************************************/
/* MERGE WITH CONFIDENTIAL GEOCODE DATA                                                              */
/*****************************************************************************************************/    

merge 1:1 PID_97 using "$WRITE_DATA/PewNLSY97_MSACodes_97_00";
drop _merge;

g MSACMA99 = MSACMA_97;
tab MSACMA99, missing;

g MSAPMA99 = MSAPMA_97;
tab MSAPMA99, missing;

g NECMA99 = NECMA_97;
tab NECMA99, missing;

sort PID_97;
save "$WRITE_DATA/PewNLSY97_AnalyticBase", replace;

use "$WRITE_DATA/PewNLSY97_PlaceNames", clear;
drop if MSAPMA99==. & NECMA99==.; 
sort MSAPMA99 NECMA99;
save "$WRITE_DATA/PewNLSY97_PlaceNamesTemp", replace;
use "$WRITE_DATA/PewNLSY97_AnalyticBase", clear;
sort MSAPMA99 NECMA99;

merge m:1 MSAPMA99 NECMA99 using "$WRITE_DATA/PewNLSY97_PlaceNamesTemp", keep(1 2 3);
tab MSAPMA99 if _merge==1, missing;
tab NECMA99 if _merge==1, missing;
tab MSAPMA99 if _merge==2, missing;
tab NECMA99 if _merge==2, missing;
drop if _merge==2;
drop _merge;
save "$WRITE_DATA/PewNLSY97_AnalyticBase", replace;
erase "$WRITE_DATA/PewNLSY97_PlaceNamesTemp.dta";

/* import the 1979-to-1997 MSA concordance */
insheet using "$GEOCODE_DATA/MSA81To99Concordance.csv", comma clear;
rename msapma99 MSAPMA99;
rename necma99 NECMA99;
drop if MSAPMA99==. & NECMA99==.;
sort MSAPMA99 NECMA99;
save "$WRITE_DATA/MSA81To99Concordance_temp", replace;

/* merge concordance codes with 1997 data */
use "$WRITE_DATA/PewNLSY97_AnalyticBase", clear;
sort MSAPMA99 NECMA99;
merge m:1 MSAPMA99 NECMA99 using "$WRITE_DATA/MSA81To99Concordance_temp";
tab MSAPMA99 if _merge==1, missing;
tab NECMA99 if _merge==1, missing;
tab MSAPMA99 if _merge==2, missing;
tab NECMA99 if _merge==2, missing;
drop if _merge==2;
drop _merge;
capture g MSA = msapma99m if necma99m==.;
replace MSA = necma99m if MSA==.;
rename PlaceName PlaceName99;
drop scsa81 msapma99 msacma99 pmsa99 necma99 placename99 msapma99m msacma99m pmsa99m necma99m;
save "$WRITE_DATA/PewNLSY97_AnalyticBase", replace;
erase "$WRITE_DATA/MSA81To99Concordance_temp.dta";

/* Count the number of households per MSA/PMSA */
drop if MSA==.;
bys MSA: egen NumIndividualsInMSA = count(male);
collapse NumIndividualsInMSA, by(MSA);
tab NumIndividualsInMSA;
log off;

/*****************************************************************************************************/
/* MERGE WITH NEIGHBORHOOD CHANGE DATA (Concordance codes, 2000 census tracts)                       */
/*****************************************************************************************************/    

/* sort NCDB files by MSA code */
use "$WRITE_DATA/msapma_ncdb_1970to2000cw", clear;
sort MSA;
save "$WRITE_DATA/msapma_ncdb_1970to2000cw", replace;

use "$WRITE_DATA/PewNLSY97_AnalyticBase", clear;
sort MSA;

log on;
merge m:1 MSA using "$WRITE_DATA/msapma_ncdb_1970to2000cw", keep(1 2 3);
tab MSA if _merge==1, missing;
tab MSA if _merge==2, missing;
drop if _merge==2;
drop _merge;
log off;

/*****************************************************************************************************/
/* Merge with county and city factbook data in NLSY97 geocode files (using 1999 MSAPMA codes)        */
/*****************************************************************************************************/

sort PID_97;
merge 1:1 PID_97 using "$WRITE_DATA/PewNLSY97_FactbookData";
drop _merge;

/*****************************************************************************************************/
/* Merge with State and Metropolitan Area Data Book, 1997-98 files (not completed!)                  */
/*****************************************************************************************************/

g InMatchedMSA = (MSA~=.);
g HaveNSIIncInfo = (NSI_00~=.);
save "$WRITE_DATA/PewNLSY97_AnalyticBase", replace;


/*****************************************************************************************************/
/* SOME BASIC SUMMARY STATISTICS FOR THE NLSY79                                                      */
/* CORE SAMPLE INCLUDES THOSE AGE 19 & UNDER AT BASELINE AND RESIDENT IN AN SMSA                     */
/*****************************************************************************************************/

/* Count the number of households per MSA with needed data */
drop if MSA==.;
drop if numRPFIpc<1;
drop if NumberOfAdultIncomes<1;
drop if InMatchedMSA~=1;
bys MSA: egen NumIndividualsInMSA = sum(male);
collapse NumIndividualsInMSA, by(MSA);

log on;
tab NumIndividualsInMSA;
tab NumIndividualsInMSA if NumIndividualsInMSA<10;
tab NumIndividualsInMSA if NumIndividualsInMSA>=10;
log off;

use "$WRITE_DATA/PewNLSY97_AnalyticBase", clear;
log on;

/*****************************************************************************************************/
/* EDUCATION/AGE INFORMATION                                                                         */
/*****************************************************************************************************/

log on;
tab MSA_97, missing;
tab age_1997, missing;
tab InMatchedMSA;

/* Summarize parental education data availability */
tab HGC_FATH97 if InMatchedMSA==1, missing;
tab HGC_FATH97_Source if InMatchedMSA==1, missing;
tab HGC_MOTH97 if InMatchedMSA==1, missing;
tab HGC_MOTH97_Source if InMatchedMSA==1, missing;
tab ParentsHGCAvailability if InMatchedMSA==1;

/* Summarize parental data availability */
sum FathersAge_97 if InMatchedMSA==1;
tab FathersAge_97_Source if InMatchedMSA==1, missing;
sum MothersAge_97 if InMatchedMSA==1;
tab MothersAge_97_Source if InMatchedMSA==1, missing;
sum StepFathersAge_97 if InMatchedMSA==1;
tab StepFathersAge_97 if InMatchedMSA==1, missing;

/* Summarize estimation sample for parent-child educational transmission */
tab HGC_Age24 if InMatchedMSA==1, missing;

sum HGC_Age24 HGC_FATH97 FathersAge_97 HGC_MOTH97 MothersAge_97 black hispanic male
	if HGC_Age24~=. & HGC_FATH97~=. & FathersAge_97~=. & HGC_MOTH97~=. & MothersAge_97~=. & InMatchedMSA==1;	
	
sum HGC_Age24 HGC_FATH97 FathersAge_97 HGC_MOTH97 MothersAge_97 male
	if HGC_Age24~=. & HGC_FATH97~=. & FathersAge_97~=. & HGC_MOTH97~=. & MothersAge_97~=. & InMatchedMSA==1 & black==1;	

sum HGC_Age24 HGC_FATH97 FathersAge_97 HGC_MOTH97 MothersAge_97 male
	if HGC_Age24~=. & HGC_FATH97~=. & FathersAge_97~=. & HGC_MOTH97~=. & MothersAge_97~=. & InMatchedMSA==1 & hispanic==1;

/* Summarize parental & grandparent education data availability */
sum black hispanic male HGC_Age24 HGC_FATH97 FathersAge_97 HGC_MOTH97 MothersAge_97 
	MatGrdMoth_HGC MatGrdMoth_Age_97 PatGrdMoth_HGC PatGrdMoth_Age_97
	MatGrdFath_HGC MatGrdFath_Age_97 PatGrdFath_HGC PatGrdFath_Age_97
	if HGC_Age24~=. & HGC_FATH97~=. & FathersAge_97~=. & HGC_MOTH97~=. & MothersAge_97~=. &
	   MatGrdMoth_HGC~=. &  MatGrdMoth_Age_97~=. &  PatGrdMoth_HGC~=. &  PatGrdMoth_Age_97 &
	   MatGrdFath_HGC~=. &  MatGrdFath_Age_97~=. &  PatGrdFath_HGC~=. &  PatGrdFath_Age_97~=. & InMatchedMSA==1;	   

/* Summarize parental co-residence information for all respondents */
tab DataAvailabilityCode97 if InMatchedMSA==1;
tab DataAvailabilityCode98 if InMatchedMSA==1;
tab DataAvailabilityCode99 if InMatchedMSA==1;
tab DataAvailabilityCode00 if InMatchedMSA==1;
tab DataAvailabilityCode01 if InMatchedMSA==1;
tab DataAvailabilityCode02 if InMatchedMSA==1;
tab DataAvailabilityCode03 if InMatchedMSA==1;
tab DataAvailabilityCode04 if InMatchedMSA==1;


/* Source of household head age information */
tab HouseholdHeadAge_97_source if InMatchedMSA==1, missing;
tab HouseholdHeadAge_98_source if InMatchedMSA==1, missing;
tab HouseholdHeadAge_99_source if InMatchedMSA==1, missing;
tab HouseholdHeadAge_00_source if InMatchedMSA==1, missing;
tab HouseholdHeadAge_01_source if InMatchedMSA==1, missing;
tab HouseholdHeadAge_02_source if InMatchedMSA==1, missing;
tab HouseholdHeadAge_03_source if InMatchedMSA==1, missing;
tab HouseholdHeadAge_04_source if InMatchedMSA==1, missing;

log off;
                                                                                               
log on;
/***************************************************************************************************/
/* BASIC STATISTICS FOR INCOME MOBILITY ESTIMATION SAMPLE                                          */
/***************************************************************************************************/

/* Summary of parental generation income data */
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize if numRPFIpc>0 & InMatchedMSA==1;

/* Summary of child generation income data */
tab NumberOfAdultIncomes if InMatchedMSA==1, missing;

/* Union sample */
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize 
	RCFIpc_Avg RCFI_Avg NumberOfAdultIncomes AvgChildAge AvgChildFamSize 
	black hispanic male if numRPFIpc>0 & NumberOfAdultIncomes>0 & InMatchedMSA==1;
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize 
	RCFIpc_Avg RCFI_Avg NumberOfAdultIncomes AvgChildAge AvgChildFamSize 
	black hispanic male if numRPFIp>0 & NumberOfAdultIncomes>0 & InMatchedMSA==1 & black==1;
sum RPFIpc_Avg RPFI_Avg numRPFIpc AvgHeadAge AvgFamSize 
	RCFIpc_Avg RCFI_Avg NumberOfAdultIncomes AvgChildAge AvgChildFamSize 
	black hispanic male if numRPFIpc>0 & NumberOfAdultIncomes>0 & InMatchedMSA==1 & hispanic==1;

log off;

/* Family income correlations */
keep RCFI_2002-RCFI_2008 RPFI_Avg AvgHeadAge male hispanic black age_1997 sample_wgts HHID_97 PID_97
     MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
     total_population_70 total_population_80 total_population_90 total_population_00
     prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 
     prc_black_90 prc_hispanic_90 prc_black_00 prc_hispanic_00
     prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 
     NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97;

/* stack data so that each row corresponds to a child-year pair */
stack RCFI_2002 RPFI_Avg age_1997 AvgHeadAge male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97
      RCFI_2003 RPFI_Avg age_1997 AvgHeadAge male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97
      RCFI_2004 RPFI_Avg age_1997 AvgHeadAge male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97
      RCFI_2005 RPFI_Avg age_1997 AvgHeadAge male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97
      RCFI_2006 RPFI_Avg age_1997 AvgHeadAge male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97
      RCFI_2007 RPFI_Avg age_1997 AvgHeadAge male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97
      RCFI_2008 RPFI_Avg age_1997 AvgHeadAge male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST_97 NORTH_CENTRAL_97 SOUTH_97 WEST_97,
      into(own_income parents_income own_age parents_age male hispanic black MSA placename_msa NSI_70 NSI_80 NSI_90 NSI_00 
																	 total_population_70 total_population_80 total_population_90 total_population_00 prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 prc_black_90 
																	 prc_hispanic_90 prc_black_00 prc_hispanic_00 prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     																 prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     																 prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
     																 sigma_t_70  sigma_t_80  sigma_t_90  sigma_t_00 HHID_97 PID_97 sample_wgts NORTH_EAST NORTH_CENTRAL SOUTH WEST) clear;

rename _stack year;
replace year = 2002 if year==1;
replace year = 2003 if year==2;  
replace year = 2004 if year==3;  
replace year = 2005 if year==4;
replace year = 2006 if year==5;  
replace year = 2007 if year==6;  
replace year = 2008 if year==7;

g D02 = (year==2002);
g D03 = (year==2003);
g D04 = (year==2004);
g D05 = (year==2005);
g D06 = (year==2006);
g D07 = (year==2007);
g D08 = (year==2008);

save "$WRITE_DATA/PewNLSY97_Panel", replace;

g log_parents_income = log(parents_income);
g log_own_income = log(own_income);

g childs_age   = own_age + (year - 1997 - 25);
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

/* find MSAs with at least 25 sampled households with complete data in target group */
g DA1 = (log_own_income~=.)*(log_parents_income~=.)*(parents_age~=.)*(childs_age~=.)*(male~=.)*(black~=.)*(hispanic~=.)*(MSA~=.);
keep if DA==1;
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
							D02-D08 if MSA == `l', cluster(HHID_97) nocons;
		if _rc==0 {;
			replace num_hh_in_MSA = e(N_clust) if MSA == `l';
			matrix b = e(b);
			replace ige_hat_MSA = b[1,1] if MSA == `l';
			matrix V = e(V);
			replace ige_hat_var_MSA = V[1,1] if MSA == `l';
			capture reg log_own_income log_parents_income 
						parents_age parents_age_2 
						childs_age childs_age_2 
						D02-D08 if MSA == `l', cluster(PID_97) nocons;	
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
					D03-D08 [pw=sample_wgts], cluster(PID_97);	

reg log_own_income 	log_parents_income													
					parents_age parents_age_2 parents_age_3 parents_age_4
					childs_age childs_age_2 childs_age_3 childs_age_4
					D03-D08 [pw=sample_wgts], cluster(HHID_97);	
					
reg log_own_income 	log_parents_income													
					parents_age parents_age_2 parents_age_3 parents_age_4
					childs_age childs_age_2 childs_age_3 childs_age_4
					D03-D08
					_MSA_* [pw=sample_wgts], nocons cluster(HHID_97);
testparm _MSA_*, equal; 							 	
					
reg log_own_income 	_MSAXlog_*														
					parents_age parents_age_2 parents_age_3 parents_age_4
					childs_age childs_age_2 childs_age_3 childs_age_4
					D03-D08 
					_MSA_* [pw=sample_wgts], nocons cluster(HHID_97);

/* switch to matrix formulation of the problem */
matrix b = e(b);
matrix b = b[1,1..num_cities]';
matrix V = e(V);
matrix V = V[1..num_cities,1..num_cities];

testparm _MSA_*, equal; 						
testparm _MSAXlog_*, equal;


collapse (mean) log_own_income _MSA* 
				parents_age parents_age_2 parents_age_3 parents_age_4 
				childs_age childs_age_2 childs_age_3 childs_age_4
				ca1_X_lpi ca2_X_lpi ca3_X_lpi ca4_X_lpi
				D02-D08 sample_wgts num_hh_in_MSA num_res_in_MSA ige_hat_MSA ige_hat_var_MSA
				NSI_70 NSI_80 NSI_90 NSI_00 
				total_population_70 total_population_80 total_population_90 total_population_00 
				prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 
				prc_black_90 prc_hispanic_90 prc_black_00 prc_hispanic_00 
				prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     			prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     			prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
				NORTH_EAST NORTH_CENTRAL SOUTH WEST, by(MSA placename_msa HHID_97 PID_97);
				
margins [pw=sample_wgts], 	expression(	_b[_MSAXlog_240]*_MSA_240   + _b[_MSAXlog_380]*_MSA_380   + 
					 			    	_b[_MSAXlog_520]*_MSA_520   + _b[_MSAXlog_640]*_MSA_640   + 
					 			    	_b[_MSAXlog_720]*_MSA_720   +
					 					_b[_MSAXlog_860]*_MSA_860   + _b[_MSAXlog_1000]*_MSA_1000 +
					 					_b[_MSAXlog_1123]*_MSA_1123 + _b[_MSAXlog_1240]*_MSA_1240 + 
					 					_b[_MSAXlog_1280]*_MSA_1280 + _b[_MSAXlog_1303]*_MSA_1303 + 
					 					_b[_MSAXlog_1440]*_MSA_1440 + _b[_MSAXlog_1520]*_MSA_1520 +
					 					_b[_MSAXlog_1600]*_MSA_1600 + _b[_MSAXlog_1680]*_MSA_1680 +
					 					_b[_MSAXlog_1840]*_MSA_1840 + 
					 					_b[_MSAXlog_1880]*_MSA_1880 + _b[_MSAXlog_1920]*_MSA_1920 + 
					 					_b[_MSAXlog_2080]*_MSA_2080 + _b[_MSAXlog_2160]*_MSA_2160 + 
					 					_b[_MSAXlog_2290]*_MSA_2290 + _b[_MSAXlog_2440]*_MSA_2440 + 
					 					_b[_MSAXlog_2700]*_MSA_2700 + _b[_MSAXlog_2760]*_MSA_2760 + 
					 					_b[_MSAXlog_3000]*_MSA_3000 + _b[_MSAXlog_3290]*_MSA_3290 + 
					 					_b[_MSAXlog_3360]*_MSA_3360 + _b[_MSAXlog_3480]*_MSA_3480 + 
					 					_b[_MSAXlog_3520]*_MSA_3520 + _b[_MSAXlog_3560]*_MSA_3560 + 
					 					_b[_MSAXlog_3760]*_MSA_3760 + _b[_MSAXlog_3880]*_MSA_3880 + 
					 					_b[_MSAXlog_4040]*_MSA_4040 + _b[_MSAXlog_4480]*_MSA_4480 + 
					 					_b[_MSAXlog_4640]*_MSA_4640 + _b[_MSAXlog_4920]*_MSA_4920 + 
					 					_b[_MSAXlog_5000]*_MSA_5000 + _b[_MSAXlog_5120]*_MSA_5120 + 
					 					_b[_MSAXlog_5170]*_MSA_5170 + _b[_MSAXlog_5360]*_MSA_5360 + 
					 					_b[_MSAXlog_5380]*_MSA_5380 +
					 					_b[_MSAXlog_5560]*_MSA_5560 + _b[_MSAXlog_5600]*_MSA_5600 + 
					 					_b[_MSAXlog_5720]*_MSA_5720 + _b[_MSAXlog_5880]*_MSA_5880 +
					 					_b[_MSAXlog_5945]*_MSA_5945 +
					 					_b[_MSAXlog_6160]*_MSA_6160 + _b[_MSAXlog_6200]*_MSA_6200 + 
					 					_b[_MSAXlog_6280]*_MSA_6280 + _b[_MSAXlog_6560]*_MSA_6560 + 
					 					_b[_MSAXlog_6760]*_MSA_6760 + _b[_MSAXlog_6780]*_MSA_6780 +
					 					_b[_MSAXlog_6840]*_MSA_6840 +
					 					_b[_MSAXlog_6895]*_MSA_6895 + _b[_MSAXlog_6960]*_MSA_6960 +
					 					_b[_MSAXlog_7040]*_MSA_7040 +
					 					_b[_MSAXlog_7240]*_MSA_7240 + _b[_MSAXlog_7320]*_MSA_7320 +
					 					_b[_MSAXlog_7360]*_MSA_7360 + _b[_MSAXlog_7480]*_MSA_7480 +
					 					_b[_MSAXlog_7600]*_MSA_7600 + _b[_MSAXlog_7920]*_MSA_7920 +
					 					_b[_MSAXlog_8160]*_MSA_8160 + _b[_MSAXlog_8200]*_MSA_8200 +
					 					_b[_MSAXlog_8280]*_MSA_8280 +
					 					_b[_MSAXlog_8520]*_MSA_8520 + _b[_MSAXlog_8800]*_MSA_8800 +
					 					_b[_MSAXlog_8840]*_MSA_8840 + _b[_MSAXlog_9200]*_MSA_9200 +
					 					_b[_MSAXlog_9280]*_MSA_9280);														
log off;

/* collapse remaining dataset to MSA level */
collapse (mean) num_hh_in_MSA num_res_in_MSA ige_hat_MSA ige_hat_var_MSA
				NSI_70 NSI_80 NSI_90 NSI_00 
				total_population_70 total_population_80 total_population_90 total_population_00 
				prc_black_70 prc_hispanic_70 prc_black_80 prc_hispanic_80 
				prc_black_90 prc_hispanic_90 prc_black_00 prc_hispanic_00 
				prc_under18_70 prc_under18_80 prc_under18_90 prc_under18_00
     			prc_over65_70 prc_over65_80 prc_over65_90 prc_over65_00 
     			prc_foreign_70 prc_foreign_80 prc_foreign_90 prc_foreign_00
				NORTH_EAST NORTH_CENTRAL SOUTH WEST, by(MSA placename_msa);
			
g SelectedPlaceName = placename_msa 
					  if MSA==1123 | MSA==1600 | MSA==1602 | MSA==1920 | MSA==1922 | 
					     MSA==2160 | MSA==2162 | MSA==4480 | MSA==4472 | MSA==4492 |
					     MSA==5000 | MSA==5600 | MSA==5602 | MSA==7360 | MSA==7362 | 
					     MSA==8840 | MSA==8872;	

/* scatter plot of the IGE estimates versus NSI (Card-Krueger Estimates) */
svmat b;
rename b IGE_INC;
scatter IGE_INC NSI_00, 
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
graph save $WRITE_DATA/NSI_1997_Card_Krueger_Scatter.gph, replace;
graph export $WRITE_DATA/NSI_1997_Card_Krueger_Scatter.eps, replace;

/* scatter plot of the IGE estimates versus NSI (MSA-specific Estimates) */
scatter ige_hat_MSA NSI_00, 
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
graph save $WRITE_DATA/NSI_1997_Scatter.gph, replace;
graph export $WRITE_DATA/NSI_1997_Scatter.eps, replace;		
		

log on;

/* some summary statistics */
sum num_hh_in_MSA num_res_in_MSA, detail;

/* Compute Hanushek (1974) FGLS estimates */  

/* using Card-Krueger type first step estimates */
ts_fgls IGE_INC NSI_00, firststepvcov(V);
ts_fgls IGE_INC NORTH_CENTRAL SOUTH WEST, firststepvcov(V);
ts_fgls IGE_INC prc_black_00 prc_hispanic_00, firststepvcov(V);

/* using MSA-specific regression first step estimates */
mkmat ige_hat_var_MSA;
matrix V = diag(ige_hat_var_MSA);
ts_fgls ige_hat_MSA NSI_00, firststepvcov(V);
ts_fgls ige_hat_MSA NORTH_CENTRAL SOUTH WEST, firststepvcov(V);
ts_fgls ige_hat_MSA prc_black_00 prc_hispanic_00, firststepvcov(V);

g se_ige_hat_MSA = sqrt(ige_hat_var_MSA);
vwls ige_hat_MSA NSI_00, sd(se_ige_hat_MSA);
vwls ige_hat_MSA NORTH_CENTRAL SOUTH WEST, sd(se_ige_hat_MSA);
vwls ige_hat_MSA prc_black_00 prc_hispanic_00, sd(se_ige_hat_MSA);

reg ige_hat_MSA NSI_00, r;
reg ige_hat_MSA NORTH_CENTRAL SOUTH WEST, r;
reg ige_hat_MSA prc_black_00 prc_hispanic_00, r;

reg ige_hat_MSA NSI_00 [aw=total_population_80], r;
reg ige_hat_MSA NORTH_CENTRAL SOUTH WEST [aw=total_population_80], r;
reg ige_hat_MSA prc_black_00 prc_hispanic_00 [aw=total_population_80], r;
log off;
log close;
