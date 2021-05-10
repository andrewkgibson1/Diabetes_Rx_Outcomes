

/************  DSS  ****************/

options compress=yes;run;

/* path for output datasets */
libname sasout '/data/dart/2014/ORD_AlAly_201403107D/Clean Data';

*RENAL OUTCOME: Albuminuria - lab values of micro-albumin to creatinine ratio (mA/C) - incident > 30, progression > 300;
/* res_date is date of results. Other dates correspond to non-lab services */
/* 8 seconds - 947,032 records */
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. );
	CREATE TABLE alb1 AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT scrssn, res_date, dsslarno, result
			FROM [ORD_AlAly_201403107D].[Src].[DSS_Lar]
			WHERE [dsslarno] = 56 
			AND [res_date] BETWEEN '01JAN2018' AND '31DEC2018'
		);
	DISCONNECT FROM TUNNEL;
QUIT;

*all records from dss_Lar with mA/C, dsslarno=56;
* 1 minute - 10,763,128 records;
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE alb2 AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT scrssn, res_date, dsslarno, result
			FROM [ORD_AlAly_201403107D].[Src].[DSS_Lar]
			WHERE [dsslarno] = 56
		);
	DISCONNECT FROM TUNNEL;
QUIT;

*remove trailing blanks in variables;
%squeeze_cdw (alb2, work.alb2);
run;

*output all results in a new dataset that have a numeric value in them, don't include lab results that have only character strings;
data bbb;
	set alb2;
	if index(result,'1') then output;
	else if index(result,'2') then output;
	else if index(result,'3') then output;
	else if index(result,'4') then output;
	else if index(result,'5') then output;
	else if index(result,'6') then output;
	else if index(result,'7') then output;
	else if index(result,'8') then output;
	else if index(result,'9') then output;
	else if index(result,'0') then output;
run;

*change character data type to numeric (by adding it to a numeric data type 0), don't include missing;
*indicator variable to tell if mA/C ratio indicates no albuminuria (0), moderate (1), or severe (2);
data num;
	set bbb;
	if result+0=put(result,9.) and result+0^=. then output;
run;
data num;
	set num;
	if result+0<30 then albumin=0;
	else if result+0<300 then albumin=1;
	else albumin=2;
run;

*also process results that have >X value;
data larger;
	set bbb;
	if index(result,'>') then output;
run;
data larger;
	set larger;
	a=compress(result,'>');
	a=compress(a,'=');
	if 0<=a+0<30 then albumin=0;
	else if a+0<300 then albumin=1;
	else if a+0=. then delete;
	else albumin=2;
run;

*process results that have <X value;
data less;
	set bbb;
	if index(result,'<') then output;
run;
data less;
	set less;
	a=compress(result,'<');
	a=compress(a,'=');
	if 0<=a+0<30 then albumin=0;
	else if a+0<300 then albumin=1;
	else if a+0=. then delete;
	else albumin=2;
run;

*process results that have X-Y values;
data range;
	set bbb;
	if index (result,'-') then output;
run;
data range;
	set range;
	if index(result,'300') then albumin=2;
	else delete;
run;

*merge cleaned temp datasets, drop old/temp variables;
data albumin;
	set num larger less range;
	drop result a;
run;

*save cleaned dataset to the permanent folder;
data sasout.albuminuria_dss;
	set albumin;
	rename res_date=date albumin=albuminuria;
	drop dsslarno;
run;


/********** CDW Dipstick *************/

*combine with old cleaned dataset 'albuminuria_dipstick';

/*
1. LOINC # -> albuminuria lab test numbers -> match with lab test observation LOINCSIDs
2. Assign albuminuria status to lab test observation values based on LOINCSIDs
3. For lab test observations that don't have LOINCSID, use labchemtestsids
4. labchemtestsid -> match to labchemtestname from LOINCSIDs to get missing values
*/

/*** Get lab info from CDW_Lab *****/
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. );
   	CREATE view alllab AS 
		SELECT *
   		FROM CONNECTION TO TUNNEL (
      		SELECT  cohortname, patientsid,labchemspecimendatetime,labchemtestsid,
	         		labchemresultvalue, labchemresultnumericvalue,loincsid,units
         	FROM src.Chem_Patientlabchem 
        	where   cohortname='PPI' and labchemspecimendatetime>'2014-09-24' and 
					labchemspecimendatetime<='2019-06-24' 
		);
   	DISCONNECT FROM TUNNEL;
QUIT;

/**** LOINC numbers from dimenstion table */
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=CDWWork_FY16_CDWRB01 &SQL_OPTIMAL.);
   	CREATE TABLE loinc AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT loincsid, loinc, component
         	FROM Dim.loinc
     	);
   	DISCONNECT FROM TUNNEL;
QUIT;

*only include loinc numbers related to albuminuria dipstick;
data loinc;
	set loinc;
	if loinc in ('50556-0','57019-2','57020-0','24357-6','39264-7','50949-7',
				'20621-9','5804-0','32209-9','20454-5','45060-1','11218-5','30001-2',
				'50561-0','57735-3');
run;

libname sasout '/data/dart/2014/ORD_AlAly_201403107D/Clean Data/Temp';

*match loinc codes to lab test values for albuminuria dipstick;
*table 'lab' still includes all lab results, not just for albuminuria;
* 1 hour, 12,895,543 observations;
proc sql;
	create table sasout.lab as 
		select a.*, b.loinc, b.component, b.loincsid as matchid
		from alllab as a, loinc as b
		where a.loincsid=b.loincsid;
run;

*set date & drop unneeded variables;
data sasout.lab;
	set sasout.lab;
	date=datepart(labchemspecimendatetime);
	drop matchid loincsid labchemspecimendatetime cohortname;
run;


*assign albuminuria status based on current dipstick tests from LOINC codes;
data zzz;
	set sasout.lab;
	labchemresultvalue=upcase(labchemresultvalue);

	if index(labchemresultvalue,'CAN') or index(labchemresultvalue,'COM') 
	or index(labchemresultvalue,'PEN') or index(labchemresultvalue,'NA') 
	or index(labchemresultvalue,'N/A') then delete;

	if  index(labchemresultvalue,'>') then albuminuria=1;
	else if index(labchemresultvalue,'<') then albuminuria=0;

	else if index(labchemresultvalue,'NE') then albuminuria=0;
	else if index(labchemresultvalue,'PO') then albuminuria=1;

	else if index(labchemresultvalue,'+') then albuminuria=1;

	else if index(labchemresultvalue,'TR') then albuminuria=0;

	else if index(labchemresultvalue,'SM') or index(labchemresultvalue,'LAR') then albuminuria=1;

	else if index(labchemresultvalue,'MOD') then albuminuria=1;

	else if index(labchemresultvalue,'GT') then albuminuria=1;

	else if labchemresultvalue='T'  then albuminuria=0;
	else if labchemresultvalue='N'  then albuminuria=0;

	else if labchemresultvalue='10-20'  then albuminuria=0;

	else if index(labchemresultvalue,'00') then albuminuria=1;
	else if index(labchemresultvalue,'15') or index(labchemresultvalue,'20') then albuminuria=0;
	else if index(labchemresultvalue,'30') then albuminuria=1;
	else if index(labchemresultvalue,'50') then albuminuria=1;

	else if labchemresultnumericvalue^=. then do;
		if component='PROTEIN' and labchemresultnumericvalue>=30 then albuminuria=1;
		else if component='PROTEIN' and labchemresultnumericvalue<30 then albuminuria=0;
		else if index(component,'ALBUMIN') and labchemresultnumericvalue>=30 then albuminuria=1;
		else if index(component,'ALBUMIN') and labchemresultnumericvalue<30 then albuminuria=0;
	end;

run;

*drop unnecessary variables;
data sasout.lab_loinc;
	set zzz;
	drop component loinc units labchemresultnumericvalue;
run;

*sort by lab test sid;
proc sort data=sasout.lab_loinc out=labchemtestsid nodupkey;
	by labchemtestsid;
run;

*get dimension table for lab test names;
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=CDWWork_FY16_CDWRB01 &SQL_OPTIMAL.);
   	CREATE TABLE testsid AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT  labchemtestsid,	labchemtestien, labchemtestname
         	FROM Dim.labchemtest
     	);
   	DISCONNECT FROM TUNNEL;
QUIT;

*match the name of the lab test to each observation;
proc sql;
	create table labchem as
		select a.labchemtestsid, b.* 
		from labchemtestsid as a , testsid as b
		where a.labchemtestsid=b.labchemtestsid;
quit;

/**** STEP 3 ****/

*get lab records for those who have a missing loincsid (coded as '-1');
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=ORD_AlAly_201403107D &SQL_OPTIMAL.);
	CREATE view alllab AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT cohortname, patientsid, labchemspecimendatetime, labchemtestsid,
	         		labchemresultvalue, labchemresultnumericvalue, loincsid, units
         	FROM src.Chem_Patientlabchem 
        	where cohortname='PPI' and labchemspecimendatetime>'2014-09-24' and 
					labchemspecimendatetime<='2019-06-24' and loincsid<=0
		);
   	DISCONNECT FROM TUNNEL;
QUIT;

*match on lab test names & SIDs that correspond to albuminuria dipstick tests, instead of using LOINC codes;
*26 minutes, 34,292 observations;
proc sql;
	create table sasout.lab_testsid as 
		select a.*, b.labchemtestsid, b.labchemtestname 
		from alllab as a, labchem as b
		where a.labchemtestsid=b.labchemtestsid;
quit;

data sasout.lab_testsid;
	set sasout.lab_testsid;
	date=datepart(labchemspecimendatetime);
	drop labchemspecimendatetime cohortname;
run;
data sasout.lab_testsid;
	set sasout.lab_testsid;
	rename labchemresultnumericvalue=labchemresultvalue;
	drop loincsid labchemtestsid;
run;

*set albuminuria status from dipstick lab tests for new observations;
data zzz;
	set sasout.lab_testsid;
	labchemresultvalue=upcase(labchemresultvalue);
	labchemresultnumericvalue=labchemresultvalue+0;

	if index(labchemresultvalue,'CAN') or index(labchemresultvalue,'COM') 
	or index(labchemresultvalue,'PEN') or index(labchemresultvalue,'NA') or
	index(labchemresultvalue,'N/A') then delete;

	if  index(labchemresultvalue,'>') then albuminuria=1;
	else if index(labchemresultvalue,'<') then albuminuria=0;

	else if index(labchemresultvalue,'NE') then albuminuria=0;
	else if index(labchemresultvalue,'PO') then albuminuria=1;

	else if index(labchemresultvalue,'+') then albuminuria=1;

	else if index(labchemresultvalue,'TR') then albuminuria=0;

	else if index(labchemresultvalue,'SM') or index(labchemresultvalue,'LAR') then albuminuria=1;

	else if index(labchemresultvalue,'MOD') then albuminuria=1;

	else if index(labchemresultvalue,'GT') then albuminuria=1;

	else if labchemresultvalue='T' then albuminuria=0;
	else if labchemresultvalue='N' then albuminuria=0;

	else if labchemresultvalue='10-20' then albuminuria=0;

	else if index(labchemresultvalue,'00') then albuminuria=1;
	else if index(labchemresultvalue,'15') or index(labchemresultvalue,'20') then albuminuria=0;
	else if index(labchemresultvalue,'30') then albuminuria=1;
	else if index(labchemresultvalue,'50') then albuminuria=1;

	else if labchemresultnumericvalue^=. then do;
		if  labchemresultnumericvalue>=30 then albuminuria=1;
		else if labchemresultnumericvalue<30 then albuminuria=0;
	end;

run;

*drop unnecessary variables;
data sasout.lab_testsid;
	set zzz;
	drop units labchemtestname labchemresultnumericvalue;
run;

*get two datasets ready to combine;
data bbb;
	set sasout.lab_testsid;
	source='testsid';
run;
data aaa;
	set sasout.lab_loinc;
	drop labchemtestsid;
	source='LOINC';
run;

*combine normal LOINCSID lab observations and abnormal LOINCSID (testsid) lab observations;
*remove missing;
data albuminuria;
	set bbb aaa;
	where albuminuria^=.;
run;

*get scrssn from Spatient dataset;
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=ORD_AlAly_201403107D &SQL_OPTIMAL.);
   	CREATE TABLE spatient AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT scrssn, patientsid, cohortname 
			FROM src.SPatient_SPatient
		 	where cohortname='PPI' 
        );
   	DISCONNECT FROM TUNNEL;
QUIT;

*link observations to their scrssn through their patientsid;
proc sql;
	create table scrssn as
		select a.*, b.scrssn, b.patientsid
		from albuminuria as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

libname sasout '/data/dart/2014/ORD_AlAly_201403107D/Clean Data';
options compress=yes;run;

data sasout.albuminuria_dipstick;
	set scrssn;
	drop patientsid;
run;

*final dataset;
proc sort data=sasout.albuminuria_dipstick;
	by scrssn date;
run;

proc freq data=sasout.albuminuria_dipstick;
	table albuminuria;
run;

/** combine old dataset 'albuminuria_dipstick' to these new years **/
*there is a week overlap, make sure no duplicates;

data sasout.albuminuria_dipstick_2019;
	set sasout.albuminuria_dipstick sasout.albuminuria_dipstick_0;
run;

proc sort data=sasout.albuminuria_dipstick_2019 nodup;
	by scrssn date;
run;

/***************** Combine DDS & CDW ********************/

data r;
	set sasout.albuminuria_dipstick_2019;
	source1='CDW (dipstick)';
run;

data s;
	set sasout.albuminuria_dss;
	source1='DSS';
run;

*63,942,678 observations;
data sasout.albuminuria_full;
	set r s;
	drop labchemresultvalue source;
	format date DATE9.;
run;

*3,112,514 duplicates deleted;
proc sort data=sasout.albuminuria_full nodup;
	by scrssn date;
run;

*60,830,164 observations;
proc contents data=sasout.albuminuria_full;
run;



/********************* INCIDENCE (Including both DSS and CDW (Dipstick) ***********************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';
libname alb '/data/dart/2014/ORD_AlAly_201403107D/Clean Data'; 

proc sort data=alb.albuminuria_full;
	by scrssn;
run;

proc sort data=data.sglt2_first;
	by scrssn;
run;

data merger;
	merge alb.albuminuria_full data.sglt2_first;
	by scrssn;
run;

/**************

GET ONLY RECORDS OF ALBUMINURIA = 0 IN A
ONLY RECORDS OF ALBUMINURIA = 1 OR 2 IN B
Then there will be two records for each scrSSN
Just take the second record, assign albinc = 1, keep only scrSSn, dateRx, follow up time, albinc

*****************/

*find out who had incidence albuminuria in the year prior to RxDate -> a;
*find out who had incidence albuminuria after RxDate -> b;
data a b;
	set merger;
	if DispensedDate ^= ' ' and DispensedDate - 365 < date < DispensedDate and albuminuria ^= 0 then output a;
	else if DispensedDate ^= ' ' and date > DispensedDate and albuminuria ^= 0 then output b;
	keep scrssn date albuminuria drugclass DispensedDate drugyear;
run; 

*take out people who have had incidence albuminuria in the last year prior to RxDate;
proc sql;
	create table a1 as
		select y.*
		from merger as y
		left join a as z
		on y.scrssn = z.scrssn
		where z.scrssn is NULL;
quit;

data a2;
	set a1;
	if date < DispensedDate and albuminuria = 0;
run;

proc sort data=a2;
	by scrssn date;
run;

proc sort data=b;
	by scrssn date;
run;

*closest lab test date to Rx prescription;
data c;
	set a2;
	by scrssn date;
	if last.scrssn;
run;

*closest lab test date after Rx prescription;
data d;
	set b;
	by scrssn date;
	if first.scrssn;
run;

data e;
	set c d;
	by scrssn;
	if first.scrssn ^= last.scrssn;
run; *n=14,768;

*Just take the first record, assign albinc = 1, keep only scrSSn, dateRx, follow up time, albinc;
data outcome1;
	set e;
	by scrssn;
	albinc = 1;
	fuptime = date - DispensedDate;
	if last.scrssn;
	keep scrssn drugclass DispensedDate fuptime albinc;
run;

*reorder variables;
data data.outcome1;
	retain scrssn drugclass DispensedDate fuptime albinc;
	set outcome1;
run;

proc sort data=data.outcome1;
	by drugclass;
run;

proc means data=data.outcome1;
	by drugclass;
	var fuptime;
run;

proc sort data=data.outcome1;
	by scrssn;
run;

proc sort data=data.sglt2_first;
	by scrssn;
run;

*merge with sglt2 again to get records with no incidence;
data data.sglt2_outcomes;
	merge data.outcome1 data.sglt2_first;
	by scrssn;
	if DispensedDate ^=.;
	if albinc = . then albinc = 0;
	alb_incident = strip(put(albinc, 1.));
	rename fuptime=alb_incident_fuptime;
	keep scrssn drugclass DispensedDate fuptime alb_incident;
run; 

proc sort data=data.sglt2_outcomes;
	by drugclass;
run;

proc means data=data.sglt2_outcomes;
	by drugclass;
	var alb_incident_fuptime;
run;

proc freq data=data.sglt2_outcomes;
	table drugclass*alb_incident;
run;

/********************* PROGRESSION (Including only DSS) ***********************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';
libname alb '/data/dart/2014/ORD_AlAly_201403107D/Clean Data'; 

/*proc sort data=alb.albuminuria_full;*/
/*	by scrssn;*/
/*run;*/
/**/
/*proc sort data=data.sglt2_first;*/
/*	by scrssn;*/
/*run;*/
/**/
/*data merger;*/
/*	merge alb.albuminuria_full data.sglt2_first;*/
/*	by scrssn;*/
/*run;*/

/**************

GET ONLY RECORDS OF ALBUMINURIA = 1 IN A
ONLY RECORDS OF ALBUMINURIA = 2 IN B
Then there will be two records for each scrSSN
Just take the first record, assign albpr = 1, keep only scrSSn, dateRx, follow up time, albpr

*****************/

data aa bb;
	set merger;
	if DispensedDate ^= ' ' and source1 = 'DSS' and DispensedDate - 365 < date < DispensedDate and albuminuria = 1 then output aa;
	else if DispensedDate ^= ' ' and date > DispensedDate and source1 = 'DSS'  and albuminuria = 2 then output bb;
	keep scrssn date albuminuria drugclass DispensedDate drugyear;
run; 

proc sort data=aa;
	by scrssn date;
run;

proc sort data=bb;
	by scrssn date;
run;

*closest lab test date to Rx prescription;
data cc;
	set aa2;
	by scrssn date;
	if last.scrssn;
run;

*closest lab test date after Rx prescription;
data dd;
	set bb;
	by scrssn date;
	if first.scrssn;
run;

data ee;
	set cc dd;
	by scrssn;
	if first.scrssn ^= last.scrssn;
run;

*Just take the first record, assign albpr = 1, keep only scrSSn, dateRx, follow up time, albinc;
data outcome2;
	set ee;
	by scrssn;
	albpr = 1;
	fuptime = date - DispensedDate;
	if last.scrssn;
	keep scrssn drugclass DispensedDate fuptime albpr;
run;

*reorder variables;
data data.outcome2;
	retain scrssn drugclass DispensedDate fuptime albpr;
	set outcome2;
run;

proc sort data=data.outcome2;
	by drugclass;
run;

proc means data=data.outcome2;
	by drugclass;
	var fuptime;
run;

proc sort data=data.outcome2;
	by scrssn;
run;

proc sort data=data.sglt2_first;
	by scrssn;
run;

*merge with sglt2 again to get records with no progression;
data data.outcome2;
	merge data.outcome2 data.sglt2_first;
	by scrssn;
	if DispensedDate ^=.;
	if albpr = . then albpr = 0;
	alb_progression = strip(put(albpr, 1.));
	rename fuptime=alb_progression_fuptime;
	keep scrssn drugclass DispensedDate fuptime alb_progression;	
run; 

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

*merge to sglt2 outcomes dataset;
data data.sglt2_outcomes;
	merge data.sglt2_outcomes data.outcome2;
	by scrssn;
run;

proc sort data=data.sglt2_outcomes;
	by drugclass;
run;

proc means data=data.sglt2_outcomes;
	by drugclass;
	var alb_progression_fuptime;
run;

proc freq data=data.sglt2_outcomes;
	table drugclass*alb_progression;
run;

/********************* LIMIT FOLLOWUP TIME TO >= 1 YEAR ******************************/

/*data data.sglt2_outcomes_1yrfu;*/
/*	set data.sglt2_outcomes;*/
/*	if alb_incident_fuptime >= 365 or alb_incident_fuptime = .;*/
/*	if alb_progression_fuptime >= 365 or alb_progression_fuptime = .;*/
/*run;*/
/**/
/*proc sort data=data.sglt2_outcomes_1yrfu;*/
/*	by drugclass;*/
/*run;*/
/**/
/*proc means data=data.sglt2_outcomes_1yrfu;*/
/*	by drugclass;*/
/*	var alb_incident_fuptime;*/
/*	var alb_progression_fuptime;*/
/*run;*/
/**/
/*proc freq data=data.sglt2_outcomes_1yrfu;*/
/*	table drugclass*alb_incident;*/
/*	table drugclass*alb_progression;*/
/*run;*/

/********************* Outcomes by year (same amount of follow up between GLP & SGLT2) ************************/

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

data data.sglt2_outcomes;
	set data.sglt2_outcomes;
	if month(DispensedDate) = 10 or month(DispensedDate) = 11 or month(DispensedDate) = 12 then fy = year(DispensedDate) + 1;
	else fy = year(DispensedDate);
run;

proc sort data=data.sglt2_outcomes;
	by drugclass;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*alb_incident*fy / norow nopercent;
	table drugclass*alb_progression*fy / norow nopercent  ;
run;
