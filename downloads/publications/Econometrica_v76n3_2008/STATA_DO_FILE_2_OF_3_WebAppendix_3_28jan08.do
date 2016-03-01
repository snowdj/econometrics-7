/***************************************************************************************************/
/* IDENTIFYING SOCIAL INTERACTIONS THROUGH CONDITIONAL VARIANCE RESTRICTIONS, SUPPLEMENTAL         */
/* MATERIAL: STATA DO FILE 2 OF 3 FOR REPLICATION OF EMPIRICAL RESULTS (SUPPLEMENTAL FILE 3 OF 8)  */
/***************************************************************************************************/

/***************************************************************************************************/
/* ABSTRACT: This is the second of three STATA do files which were used to calculate all the       */
/* empirical results in the paper and the supplemental web appendix with the exception of the power*/
/* calculations. To run the files one will need to modify the directory references to match the    */
/* the file structure on one's computer.										   */
/***************************************************************************************************/

/***************************************************************************************************/
/* DO FILE 2 OF 3  "IDENTIFYING SOCIAL INTERACTIONS THROUGH CONDITIONAL VARIANCE RESTRICTIONS"     */                           
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

set matsize 800;
set memory 100m;

use "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", clear;


/**************************************************/
/*  Test for Non-Random Missing Test Scores       */
/**************************************************/

/****************************************************/
/* The following substantiates claims made on p. 11 */
/* of the supplemental Web Appendix to the paper    */
/****************************************************/

log using "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderstar_2.log", replace;

log on;

/* math test: basic covariate set */
reg 	tookmathk black girl poor
	blackkcm girlkcm poorkcm
	smallK regaideK blackteacherK mastersK experienceK 
	SIKschidkn_1 SIKschidkn_2- SIKschidkn_80, cluster(classK) nocons;

test black girl poor;
test blackkcm girlkcm poorkcm;
test smallK regaideK blackteacherK mastersK experienceK;
test black girl poor 
     blackkcm girlkcm poorkcm
     smallK regaideK blackteacherK mastersK experienceK;

/* reading test: basic covariate set */
reg 	tookreadk black girl poor
	blackkcm girlkcm poorkcm
	smallK regaideK blackteacherK mastersK experienceK 
	SIKschidkn_1 SIKschidkn_2- SIKschidkn_80, cluster(classK) nocons;

test black girl poor;
test blackkcm girlkcm poorkcm;
test smallK regaideK blackteacherK mastersK experienceK;
test black girl poor 
     blackkcm girlkcm poorkcm
     smallK regaideK blackteacherK mastersK experienceK;

log off;

/**********************************************************/
/* Analysis of the distribution of class-level variables  */
/**********************************************************/

use "C:\BSG_WORK\Research\PeerEffects\STAR_DATA\Stata_DF\kinderclean.dta", clear;

collapse 	schidkn mathnorm readnorm black girl poor
	   	smallK regaideK blackteacherK mastersK experienceK 
		class_size nummath_csk numread_csk	
	      SIKschidkn_1 SIKschidkn_2-SIKschidkn_80
		CLSclass_si_12 CLSclass_si_13-CLSclass_si_28, by(classK);


log on;
tab class_size;

histogram 	class_size, discrete width(1) start(12) percent
		xlabel(12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28)
		ylabel(0 2 4 6 8 10 12 14)
		title("Class size variation across Project STAR classrooms")
      	xtitle("Kindergarten class size")
		ytitle("Percent of classes"); 

sum 	black girl poor
	smallK regaideK blackteacherK mastersK experienceK 
	class_size nummath_csk numread_csk;

log close;
