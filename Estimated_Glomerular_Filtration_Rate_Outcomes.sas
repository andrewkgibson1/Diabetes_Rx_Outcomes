/*************** Descriptives with drugs *************************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';
libname egfr '/data/dart/2014/ORD_AlAly_201403107D/Clean Data'; 

proc sort data=egfr.egfr2018;
	by scrssn;
run;

proc sort data=data.sglt2_first;
	by scrssn;
run;

data merger;
	merge data.sglt2_first egfr.egfr2018;
	by scrssn;
run;

*separate lab test dates before Rx date and after;
data a b;
	set merger;
	if DispensedDate ^= ' ' and res_date < DispensedDate then output a;
	else if DispensedDate ^= ' ' and res_date > DispensedDate then output b;
run; 

proc sort data=a;
	by scrssn res_date;
run;

proc sort data=b;
	by scrssn res_date;
run;

*closest lab test date to Rx prescription;
data c;
	set a;
	by scrssn res_date;
	if last.scrssn;
run;

*last lab test date after Rx prescription;
data d;
	set b;
	by scrssn res_date;
	if last.scrssn;
run;

*only records where there is a lab value before and after the drug was received;
data e;
	set c d;
	by scrssn;
	if first.scrssn ^= last.scrssn;
run;

/*************************** DOUBLING OF SERUM CREATININE ******************/	

*check if serum creatinine doubled;
data sCr1;
	set e;
	by scrssn;
	if lab_res/lag(lab_res) >= 2 then sCr = 1;
	else sCr=0;
	fuptime = res_date - DispensedDate;
	if last.scrssn;
	keep scrssn drugclass DispensedDate fuptime sCr egfr;
run;

*reorder variables;
data data.sCr1;
	retain scrssn drugclass DispensedDate fuptime sCr egfr;
	set sCr1;
run;

proc sort data=data.sCr1;
	by drugclass;
run;

proc means data=data.sCr1;
	by drugclass;
	var fuptime;
run;

proc sort data=data.sCr1;
	by scrssn;
run;

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

*merge with full sglt2 outcomes;
data data.sglt2_outcomes;
	merge data.sglt2_outcomes data.sCr1;
	by scrssn;
	if DispensedDate ^= . ;
	if sCr = . then sCr = 0;
	double_serum_creatinine = strip(put(sCr, 1.));
	rename fuptime=double_serum_creatinine_fuptime;
run; 

proc sort data=data.sglt2_outcomes;
	by drugclass double_serum_creatinine;
run;

proc means data=data.sglt2_outcomes;
	by drugclass double_serum_creatinine;
	var double_serum_creatinine_fuptime;
run;

proc freq data=data.sglt2_outcomes;
	table drugclass*double_serum_creatinine;
run;

/********************* 30% DECLINE IN eGFR VALUES ***********************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

*check if 30% decline in eGFR;
data egfr1;
	set e;
	by scrssn;
	if egfr <= 0.7*lag(egfr) then egfr30 = 1;
	else egfr30=0;
	fuptime = res_date - DispensedDate;
	if last.scrssn;
	keep scrssn drugclass DispensedDate fuptime egfr30 egfr;
run;

*reorder variables;
data data.egfr1;
	retain scrssn drugclass DispensedDate fuptime egfr30 egfr;
	set egfr1;
run;

proc sort data=data.egfr1;
	by scrssn;
run;

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

*merge with full sglt2 outcomes;
data data.sglt2_outcomes;
	merge data.sglt2_outcomes data.egfr1;
	by scrssn;
	if DispensedDate ^= . ;
	if egfr30 = . then egfr30 = 0;
	egfr30_decline = strip(put(egfr30, 1.));
	rename fuptime=egfr30_decline_fuptime;
	drop sCr egfr30 fuptime;
run; 

data data.sglt2_outcomes;
	retain 	scrssn drugclass DispensedDate alb_incident_fuptime
			alb_incident alb_progression_fuptime alb_progression
			egfr double_serum_creatinine_fuptime double_serum_creatinine
			egfr30_decline_fuptime egfr30_decline;
	set data.sglt2_outcomes;
run;

/********************* COMBINED OUTCOMES ***************************/

*double serum creatinine and egfr <=45;
*30% decline in egfr and egfr <=60;

data data.sglt2_outcomes;
	set data.sglt2_outcomes;
	double_sCr_egfr45_fuptime = double_serum_creatinine_fuptime;
	if double_serum_creatinine = '1' and egfr <= 45 then double_sCr_egfr45 = '1';
	else double_sCr_egfr45 = '0';

	egfr_decline_egfr60_fuptime = egfr30_decline_fuptime;	
	if egfr30_decline = '1' and egfr <= 60 then egfr_decline_egfr60 = '1';
	else egfr_decline_egfr60 = '0';

run;

proc sort data=data.sglt2_outcomes;
	by drugclass;
run;

proc means data=data.sglt2_outcomes (where=((fy=2015 or fy=2016 or fy=2017 or fy=2018) and (double_sCr_egfr45='1')));
	by fy drugclass;
	var double_sCr_egfr45_fuptime;
run;

proc means data=data.sglt2_outcomes (where=((fy=2015 or fy=2016 or fy=2017 or fy=2018) and (egfr_decline_egfr60='1')));
	by fy drugclass;
	var egfr_decline_egfr60_fuptime;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*double_sCr_egfr45*fy / nopercent norow;
	table drugclass*egfr_decline_egfr60*fy / nopercent norow;
run;

/******************** RENAL OUTCOMES COMBINED *****************************/

data data.sglt2_outcomes;
	set data.sglt2_outcomes;
	if egfr_decline_egfr60 = '1' or alb_incident = '1' or alb_progression = '1' then renal = '1';
	else renal = '0';
run;

proc sort data=data.sglt2_outcomes;
	by  drugclass;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*renal*fy / nopercent norow;
run; 
