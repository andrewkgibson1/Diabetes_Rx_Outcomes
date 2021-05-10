*make library to store working datasets;
libname Data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

/* all years */
/* 1 hr, 10 min */
/* only sglt2 and glp1 */
PROC SQL  ;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE sglt2_4 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			SELECT *
			FROM [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
			WHERE [DrugNameWithoutDose] 
				IN ('ALBIGLUTIDE'
				,'CANAGLIFLOZIN'
				,'CANAGLIFLOZIN/METFORMIN'
				,'DAPAGLIFLOZIN'
				,'DAPAGLIFLOZIN/METFORMIN'
				,'DULAGLUTIDE'
				,'EMPAGLIFLOZIN'
				,'EMPAGLIFLOZIN/LINAGLIPTIN'
				,'EMPAGLIFLOZIN/METFORMIN'
				,'INSULIN DEGLUDEC/LIRAGLUTIDE'
				,'LIRAGLUTIDE'
				,'SEMAGLUTIDE'
				)
		);
	DISCONNECT FROM TUNNEL ;
QUIT ;

/* This macro will get rid of trailing blanks in certain vars */

%squeeze_cdw (sglt2_4, data.sglt2_4_cleaned);
run;
proc  contents data=data.sglt2_4_cleaned; 
title "run on: &sysdate";
title2 "Cleansed extract";
run;

proc sort data=Data.sglt2_4_cleaned;
	by PatientSID;
run;

*all drug prescriptions at least a week;
Data Data.sglt2_all;
	set Data.sglt2_4_cleaned;
	where DaysSupply >= 7;
	*classify drugs as SGLT2 or GLP;
	if 	index(DrugNameWithoutDose, 'CANAGLIFLOZIN') or index(DrugNameWithoutDose, 'DAPAGLIFLOZIN') or 
		index(DrugNameWithoutDose, 'EMPAGLIFLOZIN')
		then drugclass = 'SGLT2'; 
		else drugclass = 'GLP';
	*create year variable;
	if DispensedDate = . 
		then drugyear = year(datepart(ReleaseDateTime));
		else drugyear = year(DispensedDate);
run;

*figure out what date to use;
proc means data=data.sglt2_all nmiss n;
	var DispensedDate ReleaseDateTime;
run;
*DispensedDate ~7,000 missing;
*ReleaseDateTime ~26,000 missing;
*MOST ReleaseDateTime records happen after DispensedDate, however, very close to each other;

title "all drug prescriptions";
proc freq data=Data.sglt2_all;
	table DrugNameWithoutDose*drugyear;
	table drugclass*drugyear;
run;

proc sort data=data.sglt2_all;
	by drugclass PatientSID;
run;

*first drug prescriptions for both GLP and SGLT2s;
Data Data.sglt2_first;
	set Data.sglt2_all (where = (not missing(drugyear)));
	by drugclass PatientSID;
	if (first.PatientSID and drugclass = 'GLP') or (first.PatientSID and drugclass = 'SGLT2');
	if DispensedDate = . and drugclass = 'GLP'
			then GLP_followup = (today() - datepart(ReleaseDateTime)) / 365;
		else if drugclass = 'GLP'
			then GLP_followup = (today() - DispensedDate) / 365;
		else if DispensedDate = . and drugclass = 'SGLT2'
			then SGLT2_followup = (today() - datepart(ReleaseDateTime)) / 365;
		else 
			SGLT2_followup = (today() - DispensedDate) / 365;
run;

title "First Time GLP Prescriptions";
proc freq data=Data.sglt2_first;
	where drugclass = 'GLP';
	table DrugNameWithoutDose*drugyear;
run;
*2009-2019;

title "First Time SGLT2 Prescriptions";
proc freq data=Data.sglt2_first;
	where drugclass = 'SGLT2';
	table DrugNameWithoutDose*drugyear;
run;
*2013-2019;

title "follow up times";
proc univariate data=Data.sglt2_first;
	var SGLT2_followup GLP_followup;
	histogram SGLT2_followup GLP_followup;
run;

*number of patients with both GLP and SGLT2;
proc sort data=data.sglt2_first;
	by PatientSID;
run;

data data.sglt2_both; 
	set data.sglt2_first;
	by PatientSID;
	if first.PatientSID
		then both = 0;
		else both = 1;
run;

title "patients who have both GLP and SGLT2";
proc freq data=data.sglt2_both;
	table both;
run;
