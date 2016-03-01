/***************************************************************************************************/
/* IDENTIFYING SOCIAL INTERACTIONS THROUGH CONDITIONAL VARIANCE RESTRICTIONS, SUPPLEMENTAL         */
/* MATERIAL: STATA DO FILE 1 OF 3 FOR REPLICATION OF EMPIRICAL RESULTS (SUPPLEMENTAL FILE 2 OF 8)  */
/***************************************************************************************************/

/***************************************************************************************************/
/* ABSTRACT: This is the first of three STATA do files which were used to calculate all the        */
/* empirical results in the paper and the supplemental web appendix with the exception of the power*/
/* calculations. To run the files one will need to modify the directory references to match the    */
/* the file structure on one's computer.										   */
/***************************************************************************************************/

/***************************************************************************************************/
/* DO FILE 1 OF 3  "IDENTIFYING SOCIAL INTERACTIONS THROUGH CONDITIONAL VARIANCE RESTRICTIONS"     */                           
/***************************************************************************************************/

/***************************************************************************************************/
/* PROJECT STAR dataset preparation 	 				   		   		         */
/* "Social Interactions"		        								         */
/* Bryan S. Graham, UC - BERKELEY 		     								         */
/* bgraham@econ.berkeley.edu                 						         		   */
/* March 2006                               								         */
/***************************************************************************************************/

/* use a semicolon as the command delimiter */
#delimit ;

clear;

set matsize 800;
set memory 100m;

use "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\STAR_PAFiles\webstar.dta", clear;

/*********************************************************/
/* PART 1: generate basic individual-level variables     */
/* (for kindergarten class level)		               */	
/*********************************************************/

g black = 1 if srace == 2;
replace black = 0 if black == . & srace~=.;

g girl = 1 if ssex == 2;
replace girl = 0 if ssex == 1;

g poor = 1 if sesk == 1;
replace poor = 0 if sesk == 2;

/***********************************************/
/* impute missing individual-level variables   */
/***********************************************/

/* NOTE: for those students with missing SES data use nearest measure available measure 
   i.e., school lunch status in first grade, second grade etc. This method works for 17         
   of the 23 kindergarten students with missing school lunch data. */

replace poor = 1 if poor == . & ses1 == 1 & stark ==1;
replace poor = 0 if poor == . & ses1 == 2 & stark ==1;
replace poor = 1 if poor == . & ses2 == 1 & stark ==1;
replace poor = 0 if poor == . & ses2 == 2 & stark ==1;
replace poor = 1 if poor == . & ses3 == 1 & stark ==1;
replace poor = 0 if poor == . & ses3 == 2 & stark ==1;

/* NOTE :	A total of 8 students have either missing school lunch data (after above)
		or missing race data or both (3 students lack race data). For these students missing
		values are replaced with school-by-grade medians. The interaction
		variables are then calculated using these replaced values. */

bys schidkn: egen blacksm = median(black);
bys schidkn: egen poorsm = median(poor);
	
replace black = blacksm if black ==.;
replace poor = poorsm if poor ==.;
drop blacksm poorsm;

/****************************************************/
/* PART 2: kindergarten teacher characteristics     */
/****************************************************/

g blackteacherK = 1 if tracek == 2;
replace blackteacherK = 0 if tracek == 1;

g mastersK = 1 if hdegk >=3;
replace mastersK = 0 if hdegk == 2;

g experienceK = totexpk;

g experience_sqK = totexpk^2;

g smallK = 1 if cltypek == 1;
replace smallK = 0 if cltypek == 2 | cltypek == 3;

g regaideK = 1 if cltypek == 2;
replace regaideK = 0 if cltypek == 1 | cltypek == 3;

/**********************************************************************/
/* PART 3: divide students in each school into separate classes       */
/**********************************************************************/

/**********************************************************************/
/* This section groups students into classrooms on the basis on school*/
/* identifiers and teacher characteristics. This algorithmn, after    */
/* sorting out various discrepancies discussed in detail below is able*/
/* to reconstruct 317 of the 325 classrooms in the Project STAR.      */ 
/**********************************************************************/

/* NOTE: 62 students are not categorized by the algorthimn based on
         grouping students by teacher characteristics within schools; of these
         43 appear to be members of a regular and regular/aid class in schools 
	   48 and 55. Lack of classification is due to the absence of teacher
	   race and experience data respectively for these students. The remaining 
	   uncategorized students are sprinkled throughout the schools in an apparently 
	   random way, due entirely to missing teacher race data. However a closer inspection
	   of the data makes it possible to uniquely assign these students to a class based
	   on those classroom-level data which are not missing. Through triangulation it is
	   thus also possible to determine teacher race for these students as well. */
	
/* fill in missing teacher race data for those who are missing it via triangulation */
replace blackteacherK = 0 if newid==81622;
replace blackteacherK = 0 if newid==94070;
replace blackteacherK = 1 if newid==145326;
replace blackteacherK = 1 if newid==82283;
replace blackteacherK = 1 if newid==156231;
replace blackteacherK = 1 if newid==170397;
replace blackteacherK = 1 if newid==125369;
replace blackteacherK = 0 if newid==97882;
replace blackteacherK = 1 if newid==29439;
replace blackteacherK = 0 if newid==108203;
replace blackteacherK = 0 if newid==7440;
replace blackteacherK = 0 if newid==137152;
replace blackteacherK = 0 if newid==64954;
replace blackteacherK = 0 if newid==51104;
replace blackteacherK = 0 if newid==5882;
replace blackteacherK = 0 if newid==44778;
replace blackteacherK = 0 if newid==112017;
replace blackteacherK = 0 if newid==86455;
replace blackteacherK = 0 if newid==4513;

sort schidkn;
egen classK = group(schidkn blackteacherK mastersK experienceK smallK regaideK);

/* generate class numbers for two classrooms mentioned above (to get classroom counts correct below) */	
replace classK = 900 if schidkn==48 & classK==.;
replace classK = 901 if schidkn==55 & classK==.;

/* compute number of students in each class*/
bys classK: egen class_size = count(classK) if classK~=. & stark==1;

bys smallK: tab class_size;
bys regaideK: tab class_size;

/* NOTE: inspection of above tabs reveal that the above algorithmn appears to fail further in three cases
	   a) classK = 292 appears to be two regular classes not one class of 44 students
         b) classK = 181 & 259 each appear to be two small classes NOT small classes of 33 
		students each 				
	   c) these classrooms are dropped in the analysis below */	

/* NOTE: The above analysis suggests the presence of 325 classrooms (as in Project STAR design documentation). Of these		*/
/*       317 can be uniquely identified. Two are missing teacher race and/or experience data and a further 6 are classrooms	*/
/*       that cannot be disaggregated further. See discussion above. Only the data from the 317 classrooms with complete	*/	
/*	   information are used. 																*/

replace classK = 902	if classK == 292 & girl == 1;		/* split 292 into two classrooms to get classroom count correct below */
replace classK = 903	if classK == 181 & girl == 1;		/* split 181 into two classrooms to get classroom count correct below */
replace classK = 904	if classK == 259 & girl == 1;		/* split 259 into two classrooms to get classroom count correct below */

/* re-compute number of students in each class*/
drop class_size;
bys classK: egen class_size = count(classK) if classK~=. & stark==1;

save "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", replace;

/* count number of classrooms in each school */
collapse schidkn class_size smallK, by(classK);

bys schidkn: egen NClass 	= count(classK);
bys schidkn: egen NSmallClass	= sum(smallK);

g ThreeClassSchool = 1 if NClass<=3;
replace ThreeClassSchool = 0 if NClass>3;

sort classK;
save "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\ClassCount.dta", replace;

use "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", clear;
sort classK;

merge classK using "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\ClassCount.dta", keep;
tab _merge;
drop _merge;

/* Only keep data from 317 classrooms that are correctly classified and have complete teacher data */
g UseK = 1 if stark==1;
replace UseK = 0 if classK == 181 |classK == 259 | classK == 292 | classK == 900 | classK == 901 | classK == 902 | classK == 903 | classK == 904;
keep if UseK == 1;		

tab NClass;
tab NSmallClass;
tab ThreeClassSchool;

save "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", replace;

/**************************************************************/
/* NOTE: ALL SUBSEQUENT ANALYSIS USES THE UseK == 1 DATA ONLY */
/*       THIS LEAVES 317 CLASSROOMS WITH VALID DATA           */
/**************************************************************/

/***********************************************************************************/
/* PART 4: Generate kindergarten class means for individual-level variables        */
/***********************************************************************************/

use "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", clear;

bys classK: egen blackkcm = mean(black);
bys classK: egen girlkcm = mean(girl);
bys classK: egen poorkcm = mean(poor);

/**************************************/
/* PART 5: prepare test score data    */
/**************************************/

/* indicator variables for taking tests during kindergarten */
g tookmathk = 1 if tmathssk ~=. & UseK == 1;
replace tookmathk = 0 if tmathssk ==. & UseK == 1;

g tookreadk = 1 if treadssk ~=. & UseK == 1;
replace tookreadk = 0 if treadssk ==. & UseK == 1;

/* normalize test scores using mean/standard deviation for all students */
egen mathmean = mean(tmathssk);
egen mathstd = sd(tmathssk);

g mathnorm = (tmathssk-mathmean)/mathstd;
drop mathmean mathstd;

egen readmean = mean(treadssk);
egen readstd = sd(treadssk);

g readnorm = (treadssk-readmean)/readstd;
drop readmean readstd;

/* compute number of students in each class that took the math and reading tests */
bys classK: egen nummath_csk = count(classK) if classK~=. & UseK==1 & tookmathk==1;
bys classK: egen numread_csk = count(classK) if classK~=. & UseK==1 & tookreadk==1;

/* generate class size dummy variables */
xi , pre(CLS) i.class_size;
g CLSclass_si_12 = 1 if class_size==12;
replace CLSclass_si_12 = 0 if class_size~=12;

xi , pre(C) i.classK;
g CclassK_1 = 1 if classK==1;
replace CclassK_1 = 0 if classK~=1;

/******************************************/
/* PART 6: Summary statistics             */
/******************************************/

log using "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderstar_1.log", replace;

sum 	readnorm mathnorm tookmathk tookreadk 
	black girl poor 
	blackkcm girlkcm poorkcm if UseK==1;

log off;
log close;

/**************************************************/
/* PART 7: generate school dummy variables        */
/**************************************************/

xi , pre(SIK) i.schidk;
	
g  SIKschidkn_1 = 1 if schidk==1;
replace SIKschidkn_1 = 0 if schidk~=1;

/***********************************************/
/* PART 8: Outsheet data to ascii files        */
/***********************************************/

sort schidkn classK;

save "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", replace;

outsheet 	schidkn classK mathnorm readnorm 
		black girl poor 
		blackkcm girlkcm poorkcm  
		smallK regaideK blackteacherK mastersK experienceK experience_sqK class_size
		CLSclass_si_12 CLSclass_si_13-CLSclass_si_28 SIKschidkn_1 SIKschidkn_2-SIKschidkn_80 
		using "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\STARCLEAN.out", comma replace;

