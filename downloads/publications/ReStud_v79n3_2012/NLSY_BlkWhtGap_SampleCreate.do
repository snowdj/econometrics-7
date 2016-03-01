/***************************************************************************************************/
/* IPT NLSY79 dataset preparation 	 					   		         						   */
/* Bryan S. Graham, NYU (w/ Dan Egel and Cristine Pinto)			         			   		   */
/* bsg1@nyu.edu                 						         		   			   			   */
/* July 2010                               								         				   */
/***************************************************************************************************/

/***************************************************************************************************/
/* This do file and the accompanying Stata dictionary file report estimation results and figures   */
/* presented in the paper "Inverse Probability Tilting". The data and do                           */
/* file are provided "as is". I am unable to assist with their interpretation or use. However      */
/* please do feel free to e-mail me if you find any mistakes at bryan.graham@nyu.edu.              */
/***************************************************************************************************/

/* use a semicolon as the command delimiter */
#delimit ;

clear matrix;
clear;

set matsize 800;
set memory 100m;

/* Adjust the SOURCE_DATA directory to point to the location of the NLSY_BlkWhtGap.DCT dictionary file. Adjust the    */
/* WRITE_DATA and DO_FILES directorys to point to the location of where you would like to write any created files and */
/* where you have placed this do file respectively. */

global SOURCE_DATA "C:\Documents and Settings\bsg1\My Documents\BSG_WORK_19W4th\Research\IPT\IPT_Spr11\ResubmissionFiles\ReplicationCode\Empirical_Application\Source_Data";
global WRITE_DATA "C:\Documents and Settings\bsg1\My Documents\BSG_WORK_19W4th\Research\IPT\IPT_Spr11\ResubmissionFiles\ReplicationCode\Empirical_Application\Created_Data";
global DO_FILES "C:\Documents and Settings\bsg1\My Documents\BSG_WORK_19W4th\Research\IPT\IPT_Spr11\ResubmissionFiles\ReplicationCode\Empirical_Application\Stata_Do";

/* read in source data (extract from April 30, 2008 release for NLSY79) */
infile using "$SOURCE_DATA\NLSY_BlkWhtGap.DCT";

g HHID_79 = R0000149;	/* household ID number (for `clustering') */						

/* Calculate age by May 1st of each survey year */
g Age_in_79r = R0216500 if R0172500<5 | R0000300<5;
replace Age_in_79r = R0216500 - 1 if R0172500>=5 & R0000300>=5;

/* parents years of completed schooling at baseline */
g DadSch_in_79r = R0007900 if R0007900>=0;
g MomSch_in_79r = R0006500 if  R0006500>=0;
g DadXMom_Sch = DadSch_in_79r*MomSch_in_79r;

/* Basic respondent demographics */
g usborn = (R0000700==1);
g mother_usborn = (R0006100==1);
g father_usborn = (R0007300==1);
g male = (R0214800==1);
g hispanic = (R0214700==1);
g black = (R0214700==2);
g born1962to1964 = (R0000500>=62);
g yearborn = R0000500;
g yearborn62 = (R0000500==62);
g yearborn63 = (R0000500==63);
g yearborn64 = (R0000500==64);

/* sample weights */
g core_sample = (R0173600<=8 | R0173600==10  | R0173600==11 | R0173600==13  | R0173600==14);
g male_blkwhthis_sample = (R0173600<=4 | R0173600==10 | R0173600==11);
g sample_wgts =  R0216100;

/* Calculate years of completed schooling by May 1st of interview year */
g YrsSch_in_79r = R0216701 if R0216701>=0;
g YrsSch_in_80r = R0406401 if R0406401>=0;
g YrsSch_in_81r = R0618901 if R0618901>=0;
g YrsSch_in_82r = R0898201 if R0898201>=0;
g YrsSch_in_83r = R1145001 if R1145001>=0;
g YrsSch_in_84r = R1520201 if R1520201>=0;
g YrsSch_in_85r = R1890901 if R1890901>=0;
g YrsSch_in_86r = R2258001 if R2258001>=0;
g YrsSch_in_87r = R2445401 if R2445401>=0;
g YrsSch_in_88r = R2871101 if R2871101>=0;
g YrsSch_in_89r = R3074801 if R3074801>=0;
g YrsSch_in_90r = R3401501 if R3401501>=0;
g YrsSch_in_91r = R3656901 if R3656901>=0;
g YrsSch_in_92r = R4007401 if R4007401>=0;
g YrsSch_in_93r = R4418501 if R4418501>=0;
g YrsSch_in_94r = R5103900 if R5103900>=0;

/* years if schooling at age 22 */
g YrsSchAtAge22 = YrsSch_in_79r if Age_in_79r==22;
replace YrsSchAtAge22 = YrsSch_in_80r if Age_in_79r==21;
replace YrsSchAtAge22 = YrsSch_in_81r if Age_in_79r==20;
replace YrsSchAtAge22 = YrsSch_in_82r if Age_in_79r==19;
replace YrsSchAtAge22 = YrsSch_in_83r if Age_in_79r==18;
replace YrsSchAtAge22 = YrsSch_in_84r if Age_in_79r==17;
replace YrsSchAtAge22 = YrsSch_in_85r if Age_in_79r==16;
replace YrsSchAtAge22 = YrsSch_in_86r if Age_in_79r==15;
replace YrsSchAtAge22 = YrsSch_in_87r if Age_in_79r==14;
replace YrsSchAtAge22 = YrsSch_in_88r if Age_in_79r==13;

/* years of schooling at age 28 */
g YrsSchAtAge28 = YrsSch_in_79r if Age_in_79r==28;
replace YrsSchAtAge28 = YrsSch_in_80r if Age_in_79r==27;
replace YrsSchAtAge28 = YrsSch_in_81r if Age_in_79r==26;
replace YrsSchAtAge28 = YrsSch_in_82r if Age_in_79r==25;
replace YrsSchAtAge28 = YrsSch_in_83r if Age_in_79r==24;
replace YrsSchAtAge28 = YrsSch_in_84r if Age_in_79r==23;
replace YrsSchAtAge28 = YrsSch_in_85r if Age_in_79r==22;
replace YrsSchAtAge28 = YrsSch_in_86r if Age_in_79r==21;
replace YrsSchAtAge28 = YrsSch_in_87r if Age_in_79r==20;
replace YrsSchAtAge28 = YrsSch_in_88r if Age_in_79r==19;
replace YrsSchAtAge28 = YrsSch_in_89r if Age_in_79r==18;
replace YrsSchAtAge28 = YrsSch_in_90r if Age_in_79r==17;
replace YrsSchAtAge28 = YrsSch_in_91r if Age_in_79r==16;
replace YrsSchAtAge28 = YrsSch_in_92r if Age_in_79r==15;
replace YrsSchAtAge28 = YrsSch_in_93r if Age_in_79r==14;
replace YrsSchAtAge28 = YrsSch_in_94r if Age_in_79r==13;

/* age in base survey year */
g AgeIn1979 = R0000600;
g Age13In1979 = (AgeIn1979==13);
g Age14In1979 = (AgeIn1979==14);
g Age15In1979 = (AgeIn1979==15);
g Age16In1979 = (AgeIn1979==16);
g Age17In1979 = (AgeIn1979==17);
g Age18In1979 = (AgeIn1979==18);
g Age19In1979 = (AgeIn1979==19);
g Age20In1979 = (AgeIn1979==20);
g Age21In1979 = (AgeIn1979==21);
g Age22In1979 = (AgeIn1979==22);

/* AFQT percentile */
g AFQT = R0618300 if R0618300>0;
g AFQT_NoProb = (R0614800==51);			/* AFQT score based on test with no reported "problems" */
g AFQT_Adj1 = AFQT if AFQT_NoProb==1;   /* AFQT scores, problem free only */

/* Calculate real annual earnings 1990 to 1993 (1993 prices) */
/* CPI with 1982-84 = 100: 1990: 130.7, 1991: 136.2, 1992: 140.3, 1993: 144.5 */

g earnings90 = R3559001*(144.5/130.7) if R3559001>=0;
g earnings91 = R3897101*(144.5/136.2) if R3897101>=0;
g earnings92 = R4295101*(144.5/140.3) if R4295101>=0;
g earnings93 = R4982801               if R4982801>=0;

egen AvgEarnings_90to93 = rowmean(earnings90 earnings91 earnings92 earnings93);
g LogEarn = log(AvgEarnings_90to93);

/* Calculate average hourly wages */
g wages90 = R3127800*(144.5/130.7) if R3127800>=100 & R3127800<=7500;
g wages91 = R3523500*(144.5/136.2) if R3523500>=100 & R3523500<=7500;
g wages92 = R3728500*(144.5/140.3) if R3728500>=100 & R3728500<=7500;
g wages93 = R4416800 			   if R4416800>=100 & R4416800<=7500;

egen AvgHourlyWages_90to93 = rowmean(wages90 wages91 wages92 wages93);
g LogWage = log(AvgHourlyWages_90to93);

/* Early childhood IQ */
/* Compute age in months at which IQ test was taken */
g AgeAtIQ_CTMM  = 12*(R0017314 - R0000500) + (R0017313 - R0000300) if R0017313>0 & R0017313<=12 & R0017314>67;
g AgeAtIQ_OL    = 12*(R0017319 - R0000500) + (R0017318 - R0000300) if R0017318>0 & R0017318<=12 & R0017319>57;
g AgeAtIQ_LT    = 12*(R0017324 - R0000500) + (R0017323 - R0000300) if R0017323>0 & R0017323<=12 & R0017324>57;
g AgeAtIQ_HN    = 12*(R0017329 - R0000500) + (R0017328 - R0000300) if R0017328>0 & R0017328<=12 & R0017329>57;
g AgeAtIQ_KA    = 12*(R0017334 - R0000500) + (R0017333 - R0000300) if R0017333>0 & R0017333<=12 & R0017334>57;
g AgeAtIQ_DAT   = 12*(R0017339 - R0000500) + (R0017338 - R0000300) if R0017338>0 & R0017338<=12 & R0017339>57;
g AgeAtIQ_CSCAT = 12*(R0017344 - R0000500) + (R0017343 - R0000300) if R0017343>0 & R0017343<=12 & R0017344>57;
g AgeAtIQ_SB    = 12*(R0017349 - R0000500) + (R0017348 - R0000300) if R0017348>0 & R0017348<=12 & R0017349>57;
g AgeAtIQ_W     = 12*(R0017354 - R0000500) + (R0017353 - R0000300) if R0017353>0 & R0017353<=12 & R0017354>57;
g AgeAtIQ_OIQ1  = 12*(R0017390 - R0000500) + (R0017389 - R0000300) if R0017389>0 & R0017389<=12 & R0017390>57;
g AgeAtIQ_OIQ2  = 12*(R0017396 - R0000500) + (R0017395 - R0000300) if R0017395>0 & R0017395<=12 & R0017396>57;

/* take average age at test taking in case of multiple tests */
egen AgeAtIQ = rowmean(AgeAtIQ_CTMM AgeAtIQ_OL AgeAtIQ_LT AgeAtIQ_HN AgeAtIQ_KA AgeAtIQ_DAT AgeAtIQ_CSCAT AgeAtIQ_SB AgeAtIQ_W AgeAtIQ_OIQ1 AgeAtIQ_OIQ2);

/* IQ percentile */
g PerIQ_CTMM 	= R0017312 if R0017312>=0 & R0017312<=99;
g PerIQ_OL 		= R0017317 if R0017317>=0 & R0017317<=99;
g PerIQ_LT 		= R0017322 if R0017322>=0 & R0017322<=99;
g PerIQ_HN 		= R0017327 if R0017327>=0 & R0017317<=99;
g PerIQ_KA 		= R0017332 if R0017332>=0 & R0017332<=99;
g PerIQ_DAT 	= R0017337 if R0017337>=0 & R0017337<=99;
g PerIQ_CSCAT 	= R0017342 if R0017342>=0 & R0017342<=99;
g PerIQ_SB 		= R0017347 if R0017347>=0 & R0017347<=99;
g PerIQ_W 		= R0017352 if R0017352>=0 & R0017352<=99;
g PerIQ_OIQ1 	= R0017388 if R0017388>=0 & R0017388<=99;
g PerIQ_OIQ2 	= R0017394 if R0017394>=0 & R0017394<=99;

/* average IQ percentile in case of multiple tests */
egen PerIQ = rowmean(PerIQ_CTMM PerIQ_OL PerIQ_LT PerIQ_HN PerIQ_KA PerIQ_DAT PerIQ_CSCAT PerIQ_SB PerIQ_W PerIQ_OIQ1 PerIQ_OIQ2);

/* get "early" IQ test scores (taken between age 7 and 12) */
g EarlyPerIQ = PerIQ if AgeAtIQ>=84 & AgeAtIQ<156;

/* replication of Neal and Johnson (1996) sample (with hispanics) */
g NJ_target_sample_orig = (male_blkwhthis_sample==1 & born1962to1964==1);
g NJ_sample_orig = (male_blkwhthis_sample==1 & born1962to1964==1 & LogWage~=. & yearborn~=. & black ~= . & hispanic ~= . & AFQT_Adj1~=.);
g NJ_missing_wages_orig = (male_blkwhthis_sample==1 & born1962to1964==1 & LogWage==. & yearborn~=. & black ~= . & hispanic ~= . & AFQT_Adj1~=.);
g NJ_missing_AFQT_orig = (male_blkwhthis_sample==1 & born1962to1964==1 & LogWage~=. & yearborn~=. & black ~= . & hispanic ~= . & AFQT_Adj1==.);
g NJ_missing_wagesAndAFQT_orig = (male_blkwhthis_sample==1 & born1962to1964==1 & LogWage==. & yearborn~=. & black ~= . & hispanic ~= . & AFQT_Adj1==.);
tab NJ_missing_wages_orig if NJ_target_sample_orig==1;
tab NJ_missing_AFQT_orig if NJ_target_sample_orig==1;
tab NJ_missing_wagesAndAFQT_orig if NJ_target_sample_orig==1;

/* replication of Neal and Johnson (1996) sample (without hispanics) */
/* NOTE: Hispanics are excluded because so few have an early test score */
g NJ_target_sample = (male_blkwhthis_sample==1 & born1962to1964==1 & hispanic ~= 1 & hispanic ~= .);
g NJ_sample = (male_blkwhthis_sample==1 & born1962to1964==1 & hispanic ~= 1 & LogWage~=. & yearborn~=. & black ~= .  & hispanic ~= . & AFQT_Adj1~=.);
g NJ_missing_wages = (male_blkwhthis_sample==1 & born1962to1964==1 & hispanic ~= 1 & LogWage==. & yearborn~=. & black ~= .  & hispanic ~= . & AFQT_Adj1~=.);
g NJ_missing_AFQT = (male_blkwhthis_sample==1 & born1962to1964==1 & hispanic ~= 1 & LogWage~=. & yearborn~=. & black ~= .  & hispanic ~= . & AFQT_Adj1==.);
g NJ_missing_wagesAndAFQT = (male_blkwhthis_sample==1 & born1962to1964==1 & hispanic ~= 1 & LogWage==. & yearborn~=. & black ~= .  & hispanic ~= . & AFQT_Adj1==.);
tab NJ_missing_wages if NJ_target_sample==1;
tab NJ_missing_AFQT if NJ_target_sample==1;
tab NJ_missing_wagesAndAFQT if NJ_target_sample==1;

log using "$WRITE_DATA\NLSY79_Sample_Log", replace;
log on;
table NJ_target_sample_orig [pweight=sample_wgts], c(mean black mean hispanic mean yearborn);
table NJ_sample_orig [pweight=sample_wgts] if NJ_target_sample_orig==1, c(mean black mean hispanic mean yearborn);
table NJ_sample_orig if NJ_target_sample_orig==1, c(n black mean black n hispanic mean hispanic);

table NJ_target_sample [pweight=sample_wgts], c(mean black mean yearborn);
table NJ_sample [pweight=sample_wgts] if NJ_target_sample==1, c(mean black mean yearborn);
table NJ_sample if NJ_target_sample==1, c(n black mean black);

/* Form transformations of AFQT and Early Childhood IQ for analysis */
g AFQT_Adj2 = invnormal(AFQT_Adj1/100) if AFQT_Adj1~=.;	   /* transform to approximate normality */
reg AFQT_Adj2 yearborn62-yearborn64 [pweight=sample_wgts] if NJ_sample==1, nocons;  /* age-adjusted AFQT score */
predict AFQTStd, resid;

g EarlyIQ = invnormal(EarlyPerIQ/100) if EarlyPerIQ~=.;	   /* transform to approximate normality */
g AgeAtIQ7 = (AgeAtIQ>=7*12)*(AgeAtIQ<8*12);
g AgeAtIQ8 = (AgeAtIQ>=8*12)*(AgeAtIQ<9*12);
g AgeAtIQ9 = (AgeAtIQ>=9*12)*(AgeAtIQ<10*12);
g AgeAtIQ10 = (AgeAtIQ>=10*12)*(AgeAtIQ<11*12);
g AgeAtIQ11 = (AgeAtIQ>=11*12)*(AgeAtIQ<12*12);
g AgeAtIQ12 = (AgeAtIQ>=12*12)*(AgeAtIQ<13*12);

reg EarlyIQ AgeAtIQ7-AgeAtIQ12 yearborn63-yearborn64 [pweight=sample_wgts] if NJ_sample==1, nocons; /* age-adjusted early IQ score */
predict EarlyIQStd, resid;

/* summary statistics on black and white differences */
reg AvgHourlyWages_90to93 black [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);
reg LogWage black [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);
reg AFQTStd black [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);

/* replicate Neal and Johnson (1996) basic finding */
reg LogWage yearborn black [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);
reg LogWage yearborn black AFQTStd [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);

/* look at AFQT gap */
reg AFQTStd yearborn black [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);

/* define basic estimation sample for early childhood model and compute summary statistics */
g nonmissing = (EarlyIQStd~=.) if NJ_sample==1;
tab nonmissing if NJ_sample==1;
table NJ_sample [pweight=sample_wgts], c(mean yearborn mean black);
table NJ_sample [pweight=sample_wgts], c(mean AFQTStd mean AvgHourlyWages_90to93 mean LogWage);
table nonmissing [pweight=sample_wgts] if NJ_sample==1, 
		c(mean yearborn mean black);
table nonmissing [pweight=sample_wgts] if NJ_sample==1, 
		c(mean AFQTStd mean EarlyIQStd mean AvgHourlyWages_90to93 mean LogWage);

reg AvgHourlyWages_90to93 nonmissing [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);
reg LogWage nonmissing [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);
reg yearborn nonmissing [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);
reg black nonmissing [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);
reg AFQTStd nonmissing [pweight=sample_wgts] if NJ_sample==1, cluster(HHID_79);

/* complete case analysis */
reg LogWage yearborn black [pweight=sample_wgts] if NJ_sample==1 & nonmissing==1, cluster(HHID_79);
reg LogWage yearborn black AFQTStd [pweight=sample_wgts] if NJ_sample==1 & nonmissing==1, cluster(HHID_79);
reg LogWage yearborn black EarlyIQStd [pweight=sample_wgts] if NJ_sample==1 & nonmissing==1, cluster(HHID_79);
reg LogWage yearborn black EarlyIQStd AFQTStd [pweight=sample_wgts] if NJ_sample==1 & nonmissing==1, cluster(HHID_79);
reg AFQTStd yearborn black EarlyIQStd [pweight=sample_wgts] if NJ_sample==1 & nonmissing==1, cluster(HHID_79);

log off;
log close;

outsheet sample_wgts HHID_79 nonmissing LogWage yearborn black AFQTStd EarlyIQStd if NJ_sample==1 using "$WRITE_DATA\NLSY79_Sample.out", replace;
save "$WRITE_DATA\NLSY79_Sample.dta", replace;
