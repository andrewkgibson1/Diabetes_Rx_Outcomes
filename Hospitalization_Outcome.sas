
/***************** GENERAL HOSPITALIZATION *****************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

/*
1. import inpatient
2. import Spatient
3. merge inpatient & spatient on patient SID to get scrSSN
4. drop patientSID
*/

/*
5. import ICD10
6. merge 4. with ICD10 on ICD10SID to get ICD10 codes
7. drop ICD10SID
*/

/*
8. merge 7. with SGLT2_outcomes on ScrSSN, adding hospdate and ICD10 codes
9. hosp_followup time & indicator variable for hosp
10. drop hospdate
*/

*CDW Inpatient;
*any diagnosis;
/* 5 seconds - 584,966 records */
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. );
	CREATE TABLE hosp1 AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT patientSID, AdmitDateTime, PrincipalDiagnosisICD10SID
			FROM [ORD_AlAly_201403107D].[Src].[Inpat_Inpatient]
			WHERE [AdmitDateTime] BETWEEN '01JAN2018' AND '31DEC2018' 
		);
	DISCONNECT FROM TUNNEL;
QUIT;

*1. import inpatient;
/* 35 seconds - 13,676,537 records */
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE hosp2 AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT patientSID, AdmitDateTime, PrincipalDiagnosisICD10SID
			FROM [ORD_AlAly_201403107D].[Src].[Inpat_Inpatient]
		);
	DISCONNECT FROM TUNNEL;
QUIT;

*remove trailing blanks in variables;
%squeeze_cdw (alb2, work.alb2);
run;

*2. import Spatient;
/* 25 seconds - 20,459,972 records */
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=ORD_AlAly_201403107D &SQL_OPTIMAL.);
   	CREATE TABLE spatient AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT scrssn, patientsid 
			FROM src.SPatient_SPatient 
        );
   	DISCONNECT FROM TUNNEL;
QUIT;

*3. merge inpatient & spatient on patient SID to get scrSSN;
proc sql;
	create table data.hospSSN as
		select a.*, b.scrssn, b.patientsid
		from work.hosp2 as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

*4. drop patientSID;
data data.hosp3;
	set data.hospSSN;
	hospdate = datepart(AdmitDateTime);
	format hospdate date9.;
	drop AdmitDateTime;
	drop patientSID;
run;

/*
5. import ICD10
6. merge 4. with ICD10 on ICD10SID to get ICD10 codes
7. drop ICD10SID
*/

/**** ICD10 codes from dimension table */
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=CDWWork_FY16_CDWRB01 &SQL_OPTIMAL.);
   	CREATE View ICD10 AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT ICD10SID, ICD10Code
         	FROM Dim.ICD10
     	);
   	DISCONNECT FROM TUNNEL;
QUIT;

* 5 minutes, 13,630,596 observations;
proc sql;
	create table data.hosp4 as 
		select a.*, b.ICD10SID, b.ICD10Code
		from data.hosp3 as a, ICD10 as b
		where a.PrincipalDiagnosisICD10SID=b.ICD10SID;
run;

data data.hosp4;
	set data.hosp4;
	drop ICD10SID;
	drop PrincipalDiagnosisICD10SID;
run;

/*
8. merge 7. with SGLT2_outcomes on ScrSSN, adding hospdate and ICD10 codes
9. hosp_followup time & indicator variable for hosp
10. drop hospdate
*/

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

proc sort data=data.hosp4;
	by scrssn;
run;

data merger;
	merge data.sglt2_outcomes data.hosp4;
	by scrssn;
run;

data test;
	set merger;
	if DispensedDate ^= .;
	if hospdate > DispensedDate and hospdate ^= . and DispensedDate ^= . then hosp='1';
	else hosp='0';
run; 

data a;
	set test;
	if hosp='1';
run;

proc sort data=a;
	by scrssn hospdate;
run;

data b;
	set a;
	by scrssn;
	if first.scrssn;
	hosp_fuptime = hospdate - DispensedDate;
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
	if hosp=. then hosp='0';
	drop hospdate;
run;

proc sort data=data.sglt2_outcomes;
	by drugclass;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*hosp*fy / nopercent norow;
run; 

/***************** HOSPITALIZATION DUE TO HEART FAILURE (Primary diagnosis) *****************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

*CDW Inpatient;
*principal diagnosis;

/****

change this a bit to include hosp=1 and icd codes then hosp_hf=1

*****/

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

proc sort data=data.hosp4;
	by scrssn;
run;

data merger;
	merge data.sglt2_outcomes data.hosp4;
	by scrssn;
run;

data test;
	set merger;
	if DispensedDate ^= .;
	if hospdate > DispensedDate and hospdate ^= . and DispensedDate ^= . and ICD10Code =: 'I50' then hosp_heart_fail='1';  
	else hosp_heart_fail='0';
run; 

data a;
	set test;
	if hosp_heart_fail='1';
run;

proc sort data=a;
	by scrssn hospdate;
run;

data b;
	set a;
	by scrssn;
	if first.scrssn;
	hosp_heart_fail_fuptime = hospdate - DispensedDate;
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
	if hosp_heart_fail=. then hosp_heart_fail='0';
	drop hospdate;
	drop ICD10Code;
run;

/**************************************************************************************************/

*remove duplicates!!!;
*missed doing this with scrssn earlier, only did it with patientSID;

proc sort data=data.sglt2_outcomes;
	by scrssn DispensedDate;
run;

data data.sglt2_outcomes;
	set data.sglt2_outcomes;
	by scrssn DispensedDate;
	if first.scrssn;
run;

/**/

/******************************** NEW ALBUMINURIA OUTCOMES ***************************************/
proc sort data=data.sglt2_outcomes;
	by drugclass;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*alb_incident*fy / norow nopercent;
	table drugclass*alb_progression*fy / norow nopercent  ;
run;

/*********************************** NEW eGFR OUTCOMES ******************************************/

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*double_sCr_egfr45*fy / nopercent norow;
	table drugclass*egfr_decline_egfr60*fy / nopercent norow;
run;

/****************************** NEW COMBINED RENAL OUTCOMES *************************************/

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*renal*fy / nopercent norow;
run; 

/****************************** NEW GENERAL HOSPITALIZATION ************************************/

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*hosp*fy / nopercent norow;
run;

/***************************HOSPITALIZATION DUE TO HEART FAILURE ************************************/

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*hosp_heart_fail*fy / nopercent norow;
run;

/***************** HOSPITALIZATION DUE TO MI OR STROKE (Any diagnosis) *****************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

*CDW Outpatient;
*any diagnosis;
*Outpat_VDiagnosis;

/*

hosp4 - all inpatient with ICD codes & dates & scrSSN
need to combine this with outpatient
then follow previous steps of merging with sglt2_outcomes and selecting on ICD codes

*/

*CDW Outpatient;
*any diagnosis;
/* 8 minutes - 154,846,991 records */
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. );
	CREATE TABLE hosp1 AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT patientSID, VisitDateTime, EventDateTime, VDiagnosisDateTime, ICD10SID
			FROM [ORD_AlAly_201403107D].[Src].[Outpat_VDiagnosis]
			WHERE [VisitDateTime] BETWEEN '01JAN2018' AND '31DEC2018' 
		);
	DISCONNECT FROM TUNNEL;
QUIT;

*1. import outpatient;
/* 33 minutes, 2,673,687,158 records */
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. );
	CREATE TABLE hosp2 AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT patientSID, VisitDateTime, ICD10SID
			FROM [ORD_AlAly_201403107D].[Src].[Outpat_VDiagnosis] 
		);
	DISCONNECT FROM TUNNEL;
QUIT;

*2. import Spatient;
/* 25 seconds - 20,459,972 records */
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=ORD_AlAly_201403107D &SQL_OPTIMAL.);
   	CREATE TABLE spatient AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT scrssn, patientsid 
			FROM src.SPatient_SPatient 
        );
   	DISCONNECT FROM TUNNEL;
QUIT;

*3. merge outpatient & spatient on patient SID to get scrSSN;
/* 50 minutes! */
proc sql;
	create table data.hospSSN1 as
		select a.*, b.scrssn, b.patientsid
		from hosp2 as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

*4. drop patientSID;
data data.hosp5;
	set data.hospSSN1;
	hospdate = datepart(VisitDateTime);
	format hospdate date9.;
	drop VisitDateTime;
	drop patientSID;
run;

/*
5. import ICD10
6. merge 4. with ICD10 on ICD10SID to get ICD10 codes
7. drop ICD10SID
*/

/**** ICD10 codes from dimension table */
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=CDWWork_FY16_CDWRB01 &SQL_OPTIMAL.);
   	CREATE View ICD10 AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT ICD10SID, ICD10Code
         	FROM Dim.ICD10
     	);
   	DISCONNECT FROM TUNNEL;
QUIT;

* 4.5 hours, 2 billion records;
proc sql;
	create table data.hosp6 as 
		select a.*, b.ICD10SID, b.ICD10Code
		from data.hosp5 as a, ICD10 as b
		where a.ICD10SID=b.ICD10SID;
run;

data data.hosp6;
	set data.hosp6;
	drop ICD10SID;
run;

/*
8. merge 7. with inpatient (hosp4) and then with SGLT2_outcomes on ScrSSN, adding hospdate and ICD10 codes
9. hosp_followup time & indicator variable for hosp
10. drop hospdate
*/

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

*35 minutes;
data merger0;
	merge data.hosp6 data.hosp4;
	by scrssn;
run;

*38 minutes;
data merger;
	merge data.sglt2_outcomes merger0;
	by scrssn;
run;

*14 minutes - 60,580,924 observations;
data test;
	set merger;
	if DispensedDate ^= .;
	if hospdate > DispensedDate and hospdate ^= . and DispensedDate ^= . 
	and ICD10Code in: ('I21','I22','I60','I61','I63','I74','S06.34','S06.35','S06.36','S06.37','S06.38','S06.6') 
	then hosp_MI_stroke='1';  
	else hosp_MI_stroke='0';
run; 

data a;
	set test;
	if hosp_MI_stroke='1';
run;

proc sort data=a;
	by scrssn hospdate;
run;

data b;
	set a;
	by scrssn;
	if first.scrssn;
	hosp_MI_stroke_fuptime = hospdate - DispensedDate;
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
	if hosp_MI_stroke=. then hosp_MI_stroke='0';
	drop hospdate;
	drop ICD10Code;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*hosp_MI_stroke*fy / nopercent norow;
run;

/***************** GENERAL DEATH *****************/

options compress=yes;run;

libname data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

*VitalStatus_Mini;
*15 seconds - 10,882,772 records;
PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=ORD_AlAly_201403107D &SQL_OPTIMAL.);
   	CREATE Table death AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT scrssn, dod
         	FROM [ORD_AlAly_201403107D].[Src].[VitalStatus_Mini]
     	);
   	DISCONNECT FROM TUNNEL;
QUIT;

proc sort data=death;
	by scrssn;
run;

data merger2;
	merge data.sglt2_outcomes death;
	by scrssn;
run;

data test;
	set merger2;
	if DispensedDate ^= .;
	if dod ^= .;
	if dod > DispensedDate then death='1';
		else death='0';
run; 

*59 observations of death before DispensedDate???;
data a;
	set test;
	if death='1';
run;

proc sort data=a;
	by scrssn dod;
run;

data b;
	set a;
	by scrssn;
	if first.scrssn;
	death_fuptime = dod - DispensedDate;
run;

proc sort data=data.sglt2_outcomes;
	by scrssn;
run;

data merger3;
	merge data.sglt2_outcomes b;
	by scrssn;
run;

data data.sglt2_outcomes;
	set merger3;
	by scrssn;
	if death=. then death='0';
	drop dod;
run;

proc freq data=data.sglt2_outcomes (where=(fy=2016 or fy=2017 or fy=2018));
	table drugclass*death*fy / nopercent norow;
run;

