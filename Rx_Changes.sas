libname r '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

/*
1. Must have been 30+ or 60+ days on last Rx
2. Rx history of this cohort
3. String of drug class switching
*/

*look for last.dispenseddate for each ScrSSN and check days supply;
proc sort data=r.drug_hclean out=hclean;
	by ScrSSN DispensedDate;
run;

data h30;
	set hclean;
	by ScrSSN;
	if last.ScrSSN and DaysSupply >= 30;
run; *n=1,031,093;

/**may wait on this until after getting full history;*/
/*data h60;*/
/*	set hclean;*/
/*	by ScrSSN;*/
/*	if last.ScrSSN and DaysSupply >= 60;*/
/*run; *n=895,600;*/

* Metformin - get first prescription for each ScrSSN - full history;
*make sure used Rx for 30+ days;
*45 min , n=19,516,550;
proc sql ;
	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE r.met1 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			select PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose, min(DispensedDate)
			from [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
/*			inner join [h30] as b*/
/*			on a.PatientSID = b.PatientSID*/
			where [LocalDrugNameWithDose] like '%METFORMIN%'
			and [DaysSupply] >= 30
			and [DispensedDate] < '01Oct2018'
			group by PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose
			);
	DISCONNECT FROM TUNNEL ;
quit;

* Sulfonylureas - get first prescription for each ScrSSN - full history;
*18 min, n=3,569,008;
proc sql ;
	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE r.sulf1 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			select PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose, min(DispensedDate)
			from [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
/*			inner join [h30] as b*/
/*			on a.PatientSID = b.PatientSID*/
			where (
				[LocalDrugNameWithDose] like '%GLIMEPIRIDE%' or 
				[LocalDrugNameWithDose] like '%GLIPIZIDE%' or
				[LocalDrugNameWithDose] like '%TOLAZAMIDE%' or
				[LocalDrugNameWithDose] like '%CHLORPROPAMIDE%' or
				[LocalDrugNameWithDose] like '%AMARYL%' or
				[LocalDrugNameWithDose] like '%GLYBURIDE%' or
				[LocalDrugNameWithDose] like '%TOLBUTAMIDE%'
				)
			and [DaysSupply] >= 30
			and [DispensedDate] < '01Oct2018'
			group by PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose
			);
	DISCONNECT FROM TUNNEL ;
quit;

* DPP4 - get first prescription for each ScrSSN - full history;
*11 min, n= 191,318;
proc sql ;
	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE r.dpp1 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			select PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose, min(DispensedDate)
			from [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
/*			inner join [h30] as b*/
/*			on a.PatientSID = b.PatientSID*/
			where (
				[LocalDrugNameWithDose] like '%ALOGLIPTIN%' or 
				[LocalDrugNameWithDose] like '%LINAGLIPTIN%' or
				[LocalDrugNameWithDose] like '%SITAGLIPTIN%' or
				[LocalDrugNameWithDose] like '%SAXAGLIPTIN%' 
				)
			and [DaysSupply] >= 30
			and [DispensedDate] < '01Oct2018'
			group by PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose
			);
	DISCONNECT FROM TUNNEL ;
quit;

* SGLT2 - get first prescription for each ScrSSN - full history;
* 30 sec, n=36,990;
proc sql ;
	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE r.sglt1 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			select PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose, min(DispensedDate)
			from [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
/*			inner join [h30] as b*/
/*			on a.PatientSID = b.PatientSID*/
			where (
				[LocalDrugNameWithDose] like '%CANAGLIFLOZIN%' or 
				[LocalDrugNameWithDose] like '%DAPAGLIFLOZIN%' or
				[LocalDrugNameWithDose] like '%EMPAGLIFLOZIN%'
				)
			and [DaysSupply] >= 30
			and [DispensedDate] < '01Oct2018'
			group by PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose
			);
	DISCONNECT FROM TUNNEL ;
quit;

* GLP1 - get first prescription for each ScrSSN - full history;
* 40 sec, n=60,275;
proc sql ;
	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE r.glp1 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			select PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose, min(DispensedDate)
			from [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
/*			inner join [h30] as b*/
/*			on a.PatientSID = b.PatientSID*/
			where (
				[LocalDrugNameWithDose] like '%EXENATIDE%' or 
				[LocalDrugNameWithDose] like '%DULAGLUTIDE%' or
				[LocalDrugNameWithDose] like '%LIRAGLUTIDE%'
				)
			and [DaysSupply] >= 30
			and [DispensedDate] < '01Oct2018'
			group by PatientSID, DaysSupply, LocalDrugNameWithDose, DrugNameWithoutDose
			);
	DISCONNECT FROM TUNNEL ;
quit;

*merge them all;
*20 sec, n=23,374,141;
data r.drugh;
	set r.met1 r.sulf1 r.dpp1 r.sglt1 r.glp1;
run;

/******************   clean things up  ****************/
data test;
	set r.met1;
	where upcase(LocalDrugNameWithDose) like '%METFORMIN%';
run;

proc sort data=test;
	by PatientSID EXPRSSN;
run;
data met1;
	set test;
	by PatientSID;
	if first.PatientSID;
run;

proc sort data=r.sulf1;
	by PatientSID EXPRSSN;
run;
data sulf1;
	set r.sulf1;
	by PatientSID;
	if first.PatientSID;
run;

proc sort data=r.dpp1;
	by PatientSID EXPRSSN;
run;
data dpp1;
	set r.dpp1;
	by PatientSID;
	if first.PatientSID;
run;

proc sort data=r.sglt1;
	by PatientSID EXPRSSN;
run;
data sglt1;
	set r.sglt1;
	by PatientSID;
	if first.PatientSID;
run;

proc sort data=r.glp1;
	by PatientSID EXPRSSN;
run;
data glp1;
	set r.glp1;
	by PatientSID;
	if first.PatientSID;
run;

data drugh;
	set met1 sulf1 dpp1 sglt1 glp1;
run; *n=3,834,798;

proc sort data=drugh;
	by PatientSID;
run;

data r.met1;
	set met1;
run;

data r.sulf1;
	set sulf1;
run;

data r.dpp1;
	set dpp1;
run;

data r.sglt1;
	set sglt1;
run;

data r.glp1;
	set glp1;
run;

data r.drugh;
	set r.met1 r.sulf1 r.dpp1 r.sglt1 r.glp1;
run;

/****** done cleaning *****/

*convert from PatientSID to ScrSSN;
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

proc sql;
	create table drugh as
		select a.*, b.scrssn, b.patientsid
		from r.drugh as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

proc sort data=drugh;
	by scrssn patientSID EXPRSSN;
run;

data drugh;
	set drugh;
	if scrssn ^= .;
run;

*assign classes;
data drugh1;
	set drugh;
	length class $ 13;
	if 	index(upcase(localdrugnamewithdose),"EXENATIDE") or 
		index(upcase(localdrugnamewithdose),"LIRAGLUTIDE") or
		index(upcase(localdrugnamewithdose),"DULAGLUTIDE") then do; 
			class = 'GLP1'; output; end;
	else if 
		index(upcase(localdrugnamewithdose),"CANAGLIFLOZIN") or 
		index(upcase(localdrugnamewithdose),"DAPAGLIFLOZIN") or
		index(upcase(localdrugnamewithdose),"EMPAGLIFLOZIN") then do;
			class = 'SGLT2'; output; end;
	else if 
		index(upcase(localdrugnamewithdose),"GLIMEPIRIDE") or 
		index(upcase(localdrugnamewithdose),"AMARYL") or
		index(upcase(localdrugnamewithdose),"GLIPIZIDE") or 
		index(upcase(localdrugnamewithdose),"GLYBURIDE") or
		index(upcase(localdrugnamewithdose),"TOLAZAMIDE") or 
		index(upcase(localdrugnamewithdose),"TOLBUTAMIDE") or 
		index(upcase(localdrugnamewithdose),"CHLORPROPAMIDE") then do;
			class = 'Sulfonylureas'; output; end;
	else if 
		index(upcase(localdrugnamewithdose),"ALOGLIPTIN") or 
		index(upcase(localdrugnamewithdose),"LINAGLIPTIN") or
		index(upcase(localdrugnamewithdose),"SITAGLIPTIN") or 
		index(upcase(localdrugnamewithdose),"SAXAGLIPTIN") then do;
			class = 'DPP4'; output; end; 
	else if 
		index(upcase(localdrugnamewithdose),"METFORMIN") then do;
			class= 'Metformin'; output; end;
	else do;	
			class = 'Other'; output; end;
run;

*unique class for each ScrSSNs;
proc sort data=drugh1;
	by scrssn class EXPRSSN;
run;

data drugh;
	set drugh1;
	by scrssn class;
	if first.class;
	rename EXPRSSN=DispensedDate;
run;

proc sort data = drugh;
	by scrssn DispensedDate class;
run;

*concatenate drug classes into string and count # for each switch;
data r.fullhist30(drop=PatientSID DaysSupply LocalDrugNameWithDose DrugNameWithoutDose DispensedDate class);
  set drugh;
  by ScrSSN DispensedDate class;

  length class_hs $ 500;
  retain class_hs;

  if first.ScrSSN then
	class_hs = class;
  else if DispensedDate=lag(DispensedDate) then
  	class_hs = catx('/',class_hs,class);
  else
  	class_hs = catx('-',class_hs,class);
run;

data test;
	set r.fullhist30;
	by scrssn;
	if last.scrssn; *n= 2,085,527;
run;

proc sql ;
	CREATE TABLE test1 AS
  		select a.* 
		from test as a
		inner join r.rxstrch as b
		on a.ScrSSN = b.ScrSSN;
quit; *n=1,038,564;

title "Full Class History, 30+ days on Rx";
ods output nlevels=charlevels;
proc freq data=test1 nlevels;
	table class_hs;
run;
ods output close;
title;

data r.fullhist30;
	set test1;
run;

data GLPno;
	set r.fullhist30;
	if index(class_hs,'-GLP1') or index(class_hs,'/GLP1');  *n= 32,690;
run;

title "Switch to GLP";
ods output nlevels=charlevels;
proc freq data=GLPno nlevels;
	table class_hs;
run;
ods output close;
title;

data SGLT2no;
	set r.fullhist30;
	if index(class_hs,'-SGLT2') or index(class_hs,'/SGLT2');  *n= 1,039,441;
run;

title "Switch to SGLT2";
ods output nlevels=charlevels;
proc freq data=SGLT2no nlevels;
	table class_hs;
run;
ods output close;
title;

data count (drop=i n);
	set r.fullhist30;

/*	length MetGLP1 MetSGLT2 SulfGLP1 SulfSGLT2 DPP4GLP1 DPP4SGLT2 SGLT2GLP1 GLP1SGLT2 10 n 1;*/
	retain MetGLP1 MetSGLT2 SulfGLP1 SulfSGLT2 DPP4GLP1 DPP4SGLT2 SGLT2GLP1 GLP1SGLT2 0;

	n= count(class_hs,'-');

	if n>0 then do i=1 to n;

		if index(scan(class_hs,i,'-'),'Metformin') AND index(scan(class_hs,i+1,'-'),'GLP1')
			then MetGLP1 = MetGLP1 + 1;
		if index(scan(class_hs,i,'-'),'Metformin') AND index(scan(class_hs,i+1,'-'),'SGLT2')
			then MetSGLT2 = MetSGLT2 + 1;

		if index(scan(class_hs,i,'-'),'Sulfonylureas') AND index(scan(class_hs,i+1,'-'),'GLP1')
			then SulfGLP1 = SulfGLP1 + 1;
		if index(scan(class_hs,i,'-'),'Sulfonylureas') AND index(scan(class_hs,i+1,'-'),'SGLT2')
			then SulfSGLT2 = SulfSGLT2 + 1;

		if index(scan(class_hs,i,'-'),'DPP4') AND index(scan(class_hs,i+1,'-'),'GLP1')
			then DPP4GLP1 = DPP4GLP1 + 1;
		if index(scan(class_hs,i,'-'),'DPP4') AND index(scan(class_hs,i+1,'-'),'SGLT2')
			then DPP4SGLT2 = DPP4SGLT2 + 1;

		if index(scan(class_hs,i,'-'),'SGLT2') AND index(scan(class_hs,i+1,'-'),'GLP1')
			then SGLT2GLP1 = SGLT2GLP1 + 1;
		if index(scan(class_hs,i,'-'),'GLP1') AND index(scan(class_hs,i+1,'-'),'SGLT2')
			then GLP1SGLT2 = GLP1SGLT2 + 1;
	end;
run;

proc sql noprint;
	select n(class_hs) into :nobs
	from count;
quit;

proc print data=count(firstobs=&nobs);
	var MetGLP1 MetSGLT2 SulfGLP1 SulfSGLT2 DPP4GLP1 DPP4SGLT2 SGLT2GLP1 GLP1SGLT2;
run;

/*************************/

data r.fullhist60(drop=rx_class);
  set a;
  by ScrSSN min_r1;

  length class_hs $ 500;
  retain class_hs;

  if first.ScrSSN then
	class_hs = rx_class;
  else
  	class_hs = catx('-',class_hs,rx_class);
run;

data test;
	set r.fullhist60;
	by scrssn;
	if last.scrssn; *n= ?;
run;

title "Class History";
ods output nlevels=charlevels;
proc freq data=test nlevels;
	table class_hs;
run;
ods output close;
title;
