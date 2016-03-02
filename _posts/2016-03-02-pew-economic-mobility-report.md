---
layout: post
title:  "Pew Economic Mobility Report"
date:   2016-03-02
categories: mobility
---

This post serves as a repository of computer code and data files prepared in connection with the report, [_Mobility and the Metropolis: How Communities Factor into Economic Mobility, A Report from the Pew Charitable Trusts._]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/PewMobilityReport_2013.pdf) , co-written with Patrick Sharkey of New York University. This report was commissioned by the Economic Mobility Project of The Pew Charitable Trusts. 

Pat and I are unable to release the geocoded versions of our data files for confidentiality reasons. Individuals interested in replicating our National Longitudinal Survey of Youth (NLSY) or Panel Study of Income Dynamics (PSID) analyses will, respectively, need to obtain special permission from either the Bureau of Labor Statistics (BLS) or from the Institute for Social Research (ISR). 

The Stata .do and .dta files listed below, in conjunction with NLSY79 and NLSY97 geocode data, can be used to replicate our National Longitudinal Survey of Youth (NLSY) analyses. Our NLSY79 geocode CD-ROM is dated August 2010 (#3032). Our NLSY97 geocode CD-ROM is dated July 2011 (#2956).

We regret that we are unable to provide any assistance, beyond the provision of these files, to individuals interested in replicating our work.

#### Stata .do Files ####
[Base Do File]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/Pew_BaseDoFile.do)
[Preparation of 1982 State and Metropolitan Area Databook File]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/Pew_SMADB82_1.do)
[NLSY79 Geocode Organization]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/Pew_NLSY79_GeoCodes_1.do) (requires special use geocodes)
[NLSY97 Geocode Organization]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/Pew_NLSY97_GeoCodes_1.do) (requires special use geocodes)
[NLSY79 Date File Organization]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/Pew_NLSY79_DataOrg_1.do)
[NLSY97 Date File Organization]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/Pew_NLSY97_DataOrg_1.do)
[Construction of Panel File and Generation Main Results Presented in the Report]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/Pew_NLSY_Panel.do)
Ado Files for [Cross Section]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/TS_FGLS.ado) and [Panel]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Stata_Do_Files/TS_PANEL_FGLS.ado) Two-Step GLS Estimation

#### Stata .dta/.dct and Text Files ####
[1982 State and Metropolitan Area Databook]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/08187-0002-Data.txt)
1981 to 1997 MSA [Concordance]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/MSA81To99Concordance.csv)
Neighborhood Change Database [1980 extract]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/NCDB_80.csv)
Neighborhood Change Database [1970 to 2000 extract]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/NCDB_70to00.csv) (using 1999 tracting)
NLSY79 [Dictionary]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/PewMobilityNLSY79.dct.zip) and [Label]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/PewMobilityNLSY79-value-labels.do) File (public release data)
NLSY97 [Dictionary]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/PewMobilityNLSY97.dct.zip)  and [Label]({{ site.url }}{{ site.baseurl}}/downloads/publications/PewMobilityReport_2013/Public_Data_Files/PewMobilityNLSY97-value-labels.do) File (public release data)