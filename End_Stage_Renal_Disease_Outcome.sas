/* 
Three definitions:
1. Dialysis
2. Tranplantation
3. eGFR < 15
*/

/***************** DIALYSIS OR TRANSPLANTATION (Any diagnosis) *****************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

*37 minutes;
proc sort data=data.hosp6;
	by scrssn;
run;

proc sort data=data.hosp4;
	by scrssn;
run;

*54 minutes;
data data.io_merger;
	merge data.hosp6 data.hosp4;
	by scrssn;
run;

*45 minutes;
data data.sglt2_io_merger;
	merge data.sglt2_outcomes data.io_merger;
	by scrssn;
	if hospdate > DispensedDate and hospdate ^= . and DispensedDate ^= .;
run;

*14 minutes - 60,580,924 observations;
data test;
	set data.sglt2_io_merger;
	if ICD10Code in ('N18.6','Z99.2','Z49.31','Z49.32','Y84.1','Z94.0') 
	then dial_trans='1';  
	else dial_trans='0';
run; 

data a;
	set test;
	if dial_trans='1';
run;

proc sort data=a;
	by scrssn hospdate;
run;

data b;
	set a;
	by scrssn;
	if first.scrssn;
	dial_trans_fuptime = hospdate - DispensedDate;
run;

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

data merger1;
	merge data.sglt2_outcomes b;
	by scrssn;
run;

data data.sglt2_outcomes;
	set merger1;
	by scrssn;
	if dial_trans=. then dial_trans='0';
	drop hospdate;
	drop ICD10Code;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*dial_trans*fy / nopercent norow;
run;

/********************************     eGFR < 15     ******************************************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';
libname egfr '/data/dart/2014/ORD_AlAly_201403107D/Clean Data'; 

proc sort data=egfr.egfr2018;
	by scrssn;
run;

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

data test0;
	set data.sglt2_outcomes;
	drop egfr;
run;

data merger;
	merge test0 egfr.egfr2018;
	by scrssn;
	if res_date > DispensedDate and res_date ^= . and DispensedDate ^= .;
run;

data test;
	set merger;
	if egfr <= 15 
	then egfr15='1';  
	else egfr15='0';
run; 

data a;
	set test;
	if egfr15='1';
run;

proc sort data=a;
	by scrssn res_date;
run;

data b;
	set a;
	by scrssn;
	if first.scrssn;
	egfr15_fuptime = res_date - DispensedDate;
run;

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

data merger1;
	merge data.sglt2_outcomes b;
	by scrssn;
run;

data merger2;
	set merger1;
	if egfr15 ='1' and dial_trans ='1' and egfr15_fuptime < dial_trans_fuptime 
		then do;
			ESRD_fuptime = egfr15_fuptime;
			ESRD = '1';
		end;
	else if egfr15 ='1' and dial_trans ='1' and egfr15_fuptime >= dial_trans_fuptime
		then do;
			ESRD_fuptime = dial_trans_fuptime;
			ESRD = '1';
		end;
	else if egfr15 = '1' 
		then do;
			ESRD_fuptime = egfr15_fuptime;
			ESRD = '1';
		end;
	else if dial_trans = '1' 
		then do;
			ESRD_fuptime = dial_trans_fuptime;
			ESRD = '1'; 
		end;
	else ESRD = '0';
run;

data data.sglt2_outcomes;
	set merger2;
	by scrssn;
	drop dial_trans dial_trans_fuptime res_date lab_res inout egfr egfr15 egfr15_fuptime;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*ESRD*fy / nopercent norow;
run;


/******************** RENAL OUTCOMES COMBINED *****************************/

data data.sglt2_outcomes_test;
	set data.sglt2_outcomes;
	if egfr_decline_egfr60 = '1' or alb_incident = '1' or alb_progression = '1' or ESRD = '1' then renal = '1';
	else renal = '0';
run;

proc sort data=data.sglt2_outcomes_test;
	by drugclass;
run;

proc freq data=data.sglt2_outcomes_test (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*renal*fy / nopercent norow;
run; 
