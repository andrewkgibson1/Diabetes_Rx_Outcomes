*make library to store working datasets;
libname Data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

PROC SQL  ;
	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
		SELECT *
		FROM CONNECTION TO TUNNEL (
			SELECT count(LocalDrugNameWithDose)
			FROM [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
			WHERE
				[LocalDrugNameWithDose] like '%METFORMIN%'
		);
	DISCONNECT FROM TUNNEL ;
quit;

/* all years */
/* 2 hr, 72,300,198 observations */

/* fy 2018 */
/* 26 min, 3,763,773 observations */
PROC SQL  ;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE data.drug18 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			SELECT *
			FROM [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
			WHERE 
				[DispensedDate] BETWEEN '01OCT2017' AND '30SEP2018'
			AND (
				[DrugNameWithoutDose] LIKE '%GLIMEPIRIDE%' OR
				[DrugNameWithoutDose] LIKE '%AMARYL%' OR
				[DrugNameWithoutDose] LIKE '%GLIPIZIDE%' OR
				[DrugNameWithoutDose] LIKE '%GLYBURIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLAZAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLBUTAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%CHLORPROPAMIDE%' OR

				[DrugNameWithoutDose] LIKE '%ALOGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%LINAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SITAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SAXAGLIPTIN%' OR

				[DrugNameWithoutDose] LIKE '%EXENATIDE%' OR
				[DrugNameWithoutDose] LIKE '%LIRAGLUTIDE%' OR
				[DrugNameWithoutDose] LIKE '%DULAGLUTIDE%' OR

				[DrugNameWithoutDose] LIKE '%CANAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%DAPAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%EMPAGLIFLOZIN%' OR

				[DrugNameWithoutDose] LIKE '%METFORMIN%' OR

				[LocalDrugNameWithDose] LIKE '%GLIMEPIRIDE%' OR
				[LocalDrugNameWithDose] LIKE '%AMARYL%' OR
				[LocalDrugNameWithDose] LIKE '%GLIPIZIDE%' OR
				[LocalDrugNameWithDose] LIKE '%GLYBURIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLAZAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLBUTAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%CHLORPROPAMIDE%' OR

				[LocalDrugNameWithDose] LIKE '%ALOGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%LINAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SITAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SAXAGLIPTIN%' OR

				[LocalDrugNameWithDose] LIKE '%EXENATIDE%' OR
				[LocalDrugNameWithDose] LIKE '%LIRAGLUTIDE%' OR
				[LocalDrugNameWithDose] LIKE '%DULAGLUTIDE%' OR

				[LocalDrugNameWithDose] LIKE '%CANAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%DAPAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%EMPAGLIFLOZIN%' OR

				[LocalDrugNameWithDose] LIKE '%METFORMIN%'
				)
		);
	DISCONNECT FROM TUNNEL ;
QUIT ;

/* fy 2017 */
/* 28 min, 3,664,962 observations */
PROC SQL  ;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE data.drug17 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			SELECT *
			FROM [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
			WHERE 
				[DispensedDate] BETWEEN '01OCT2016' AND '30SEP2017'
			AND (
				[DrugNameWithoutDose] LIKE '%GLIMEPIRIDE%' OR
				[DrugNameWithoutDose] LIKE '%AMARYL%' OR
				[DrugNameWithoutDose] LIKE '%GLIPIZIDE%' OR
				[DrugNameWithoutDose] LIKE '%GLYBURIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLAZAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLBUTAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%CHLORPROPAMIDE%' OR

				[DrugNameWithoutDose] LIKE '%ALOGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%LINAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SITAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SAXAGLIPTIN%' OR

				[DrugNameWithoutDose] LIKE '%EXENATIDE%' OR
				[DrugNameWithoutDose] LIKE '%LIRAGLUTIDE%' OR
				[DrugNameWithoutDose] LIKE '%DULAGLUTIDE%' OR

				[DrugNameWithoutDose] LIKE '%CANAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%DAPAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%EMPAGLIFLOZIN%' OR

				[DrugNameWithoutDose] LIKE '%METFORMIN%' OR

				[LocalDrugNameWithDose] LIKE '%GLIMEPIRIDE%' OR
				[LocalDrugNameWithDose] LIKE '%AMARYL%' OR
				[LocalDrugNameWithDose] LIKE '%GLIPIZIDE%' OR
				[LocalDrugNameWithDose] LIKE '%GLYBURIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLAZAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLBUTAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%CHLORPROPAMIDE%' OR

				[LocalDrugNameWithDose] LIKE '%ALOGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%LINAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SITAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SAXAGLIPTIN%' OR

				[LocalDrugNameWithDose] LIKE '%EXENATIDE%' OR
				[LocalDrugNameWithDose] LIKE '%LIRAGLUTIDE%' OR
				[LocalDrugNameWithDose] LIKE '%DULAGLUTIDE%' OR

				[LocalDrugNameWithDose] LIKE '%CANAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%DAPAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%EMPAGLIFLOZIN%' OR

				[LocalDrugNameWithDose] LIKE '%METFORMIN%'
				)
		);
	DISCONNECT FROM TUNNEL ;
QUIT ;

/* fy 2016 */
/* 23 min, 3,685,521 observations */
PROC SQL  ;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE data.drug16 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			SELECT *
			FROM [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
			WHERE 
				[DispensedDate] BETWEEN '01OCT2015' AND '30SEP2016'
			AND (
				[DrugNameWithoutDose] LIKE '%GLIMEPIRIDE%' OR
				[DrugNameWithoutDose] LIKE '%AMARYL%' OR
				[DrugNameWithoutDose] LIKE '%GLIPIZIDE%' OR
				[DrugNameWithoutDose] LIKE '%GLYBURIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLAZAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLBUTAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%CHLORPROPAMIDE%' OR

				[DrugNameWithoutDose] LIKE '%ALOGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%LINAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SITAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SAXAGLIPTIN%' OR

				[DrugNameWithoutDose] LIKE '%EXENATIDE%' OR
				[DrugNameWithoutDose] LIKE '%LIRAGLUTIDE%' OR
				[DrugNameWithoutDose] LIKE '%DULAGLUTIDE%' OR

				[DrugNameWithoutDose] LIKE '%CANAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%DAPAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%EMPAGLIFLOZIN%' OR

				[DrugNameWithoutDose] LIKE '%METFORMIN%' OR

				[LocalDrugNameWithDose] LIKE '%GLIMEPIRIDE%' OR
				[LocalDrugNameWithDose] LIKE '%AMARYL%' OR
				[LocalDrugNameWithDose] LIKE '%GLIPIZIDE%' OR
				[LocalDrugNameWithDose] LIKE '%GLYBURIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLAZAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLBUTAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%CHLORPROPAMIDE%' OR

				[LocalDrugNameWithDose] LIKE '%ALOGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%LINAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SITAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SAXAGLIPTIN%' OR

				[LocalDrugNameWithDose] LIKE '%EXENATIDE%' OR
				[LocalDrugNameWithDose] LIKE '%LIRAGLUTIDE%' OR
				[LocalDrugNameWithDose] LIKE '%DULAGLUTIDE%' OR

				[LocalDrugNameWithDose] LIKE '%CANAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%DAPAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%EMPAGLIFLOZIN%' OR

				[LocalDrugNameWithDose] LIKE '%METFORMIN%'
				)
		);
	DISCONNECT FROM TUNNEL ;
QUIT ;

/* fy 2014-2015 */
/* 1 hr 30 min, 7,460,483 observations */
PROC SQL  ;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE data.drug1415 AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			SELECT *
			FROM [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
			WHERE 
				[DispensedDate] BETWEEN '01OCT2013' AND '30SEP2015'
			AND (
				[DrugNameWithoutDose] LIKE '%GLIMEPIRIDE%' OR
				[DrugNameWithoutDose] LIKE '%AMARYL%' OR
				[DrugNameWithoutDose] LIKE '%GLIPIZIDE%' OR
				[DrugNameWithoutDose] LIKE '%GLYBURIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLAZAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLBUTAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%CHLORPROPAMIDE%' OR

				[DrugNameWithoutDose] LIKE '%ALOGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%LINAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SITAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SAXAGLIPTIN%' OR

				[DrugNameWithoutDose] LIKE '%EXENATIDE%' OR
				[DrugNameWithoutDose] LIKE '%LIRAGLUTIDE%' OR
				[DrugNameWithoutDose] LIKE '%DULAGLUTIDE%' OR

				[DrugNameWithoutDose] LIKE '%CANAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%DAPAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%EMPAGLIFLOZIN%' OR

				[DrugNameWithoutDose] LIKE '%METFORMIN%' OR

				[LocalDrugNameWithDose] LIKE '%GLIMEPIRIDE%' OR
				[LocalDrugNameWithDose] LIKE '%AMARYL%' OR
				[LocalDrugNameWithDose] LIKE '%GLIPIZIDE%' OR
				[LocalDrugNameWithDose] LIKE '%GLYBURIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLAZAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLBUTAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%CHLORPROPAMIDE%' OR

				[LocalDrugNameWithDose] LIKE '%ALOGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%LINAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SITAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SAXAGLIPTIN%' OR

				[LocalDrugNameWithDose] LIKE '%EXENATIDE%' OR
				[LocalDrugNameWithDose] LIKE '%LIRAGLUTIDE%' OR
				[LocalDrugNameWithDose] LIKE '%DULAGLUTIDE%' OR

				[LocalDrugNameWithDose] LIKE '%CANAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%DAPAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%EMPAGLIFLOZIN%' OR

				[LocalDrugNameWithDose] LIKE '%METFORMIN%'
				)
		);
	DISCONNECT FROM TUNNEL ;
QUIT ;

*years 2014-2018;
* 1 hr 40 min, 18,574,739 observations;
* 2 min the second time;
data data.drug_all;
	set data.drug1415 data.drug16 data.drug17 data.drug18;
run;

/***********************************  Drug Names   ************************************************************/

proc sort data=data.drug_all;
	by DrugNameWithoutDose;
run;

ods output nlevels=charlevels;
proc freq data=data.drug_all nlevels;
	table LocalDrugNameWithDose DrugNameWithoutDose;
run;
ods output close;

data test;
	set data.drug_all;
	if DrugNameWithoutDose = '*Missing*';
run;

title "*Missing* from DrugNameWithoutDose";
ods output nlevels=charlevels;
proc freq data=test nlevels;
	table LocalDrugNameWithDose;
run;
ods output close;
title;

*no double drug therapy among cases where DrugNameWithoutDose is missing;
*can still assign drug class using LocalDrugNameWithDose;

/*********************************************  Days Supply  *************************************************************************/

proc sort data=data.drug_all out=test;
	by DaysSupply;
run;

ods output nlevels=charlevels;
proc freq data=test nlevels;
	table DaysSupply;
run;
ods output close;

proc means data=test nmiss;
	var DaysSupply;
run;

*most are 90 day supply;
*no missing;

/*******************************************  Drug Class  ************************************************************************/

data test;
	set data.drug_all;
	length class1 $13 class2 $13;

	if drugnamewithoutdose = '*Missing*' then do;
		if index(localdrugnamewithdose,"EXENATIDE") or index(localdrugnamewithdose,"LIRAGLUTIDE") or
		index(localdrugnamewithdose,"DULAGLUTIDE") then do; 
			class1 = 'GLP1'; output; end;
		else if index(localdrugnamewithdose,"CANAGLIFLOZIN") or index(localdrugnamewithdose,"DAPAGLIFLOZIN") or
		index(localdrugnamewithdose,"EMPAGLIFLOZIN") then do;
			class1 = 'SGLT2'; output; end;
		else if index(localdrugnamewithdose,"GLIMEPIRIDE") or index(localdrugnamewithdose,"AMARYL") or
		index(localdrugnamewithdose,"GLIPIZIDE") or index(localdrugnamewithdose,"GLYBURIDE") or
		index(localdrugnamewithdose,"TOLAZAMIDE") or index(localdrugnamewithdose,"TOLBUTAMIDE") or 
		index(localdrugnamewithdose,"CHLORPROPAMIDE") then do;
			class1 = 'Sulfonylureas'; output; end;
		else if index(localdrugnamewithdose,"ALOGLIPTIN") or index(localdrugnamewithdose,"LINAGLIPTIN") or
		index(localdrugnamewithdose,"SITAGLIPTIN") or index(localdrugnamewithdose,"SAXAGLIPTIN") then do;
			class1 = 'DPP4'; output; end; 
		else if index(localdrugnamewithdose,"METFORMIN") then do;
			class1= 'Biguanides'; output; end;
		else do;	
			class1 = 'OTHER'; output; end;
	end;
	else do;
		if drugnamewithoutdose = "EXENATIDE" or drugnamewithoutdose = "LIRAGLUTIDE" or
		drugnamewithoutdose = "DULAGLUTIDE" then do;
			class1 = 'GLP1'; output; end;
		else if drugnamewithoutdose = "CANAGLIFLOZIN" or drugnamewithoutdose = "DAPAGLIFLOZIN" or
		drugnamewithoutdose = "EMPAGLIFLOZIN" then do; 
			class1 = 'SGLT2'; output; end;
		else if drugnamewithoutdose = "GLIMEPIRIDE" or drugnamewithoutdose = "AMARYL" or
		drugnamewithoutdose = "GLIPIZIDE" or drugnamewithoutdose = "GLYBURIDE" or
		drugnamewithoutdose = "TOLAZAMIDE" or drugnamewithoutdose = "TOLBUTAMIDE" or 
		drugnamewithoutdose = "CHLORPROPAMIDE" then do; 
			class1 = 'Sulfonylureas'; output; end; 
		else if drugnamewithoutdose = "ALOGLIPTIN" or drugnamewithoutdose = "LINAGLIPTIN" or
		drugnamewithoutdose = "SITAGLIPTIN" or drugnamewithoutdose = "SAXAGLIPTIN" then do;
			class1 = 'DPP4'; output; end;
		else if drugnamewithoutdose = "METFORMIN" then do; 
			class1= 'Biguanides'; output; end; 
		else if drugnamewithoutdose = "ALOGLIPTIN/PIOGLITAZONE" then do; class1 = "DPP4"; class2 = "OTHER"; output; end;
		else if drugnamewithoutdose = "CANAGLIFLOZIN/METFORMIN" then do; class1 = "SGLT2" ; class2 = "Biguanides"; output; end;
		else if drugnamewithoutdose = "DAPAGLIFLOZIN/METFORMIN" then do; class1 = "SGLT2" ; class2 = "Biguanides"; output; end;
		else if drugnamewithoutdose = "EMPAGLIFLOZIN/LINAGLIPTIN" then do; class1 = "SGLT2" ; class2 = "DPP4"; output; end;
		else if drugnamewithoutdose = "EMPAGLIFLOZIN/METFORMIN" then do; class1 = "SGLT2" ; class2 = "Biguanides"; output; end;
		else if drugnamewithoutdose = "GLYBURIDE/METFORMIN" then do; class1 = "Sulfonylureas" ; class2 = "Biguanides"; output; end;
		else if drugnamewithoutdose = "INSULIN DEGLUDEC/LIRAGLUTIDE" then do; class1 = "OTHER" ; class2 = "GLP1"; output; end; 
		else if drugnamewithoutdose = "LINAGLIPTIN/METFORMIN" then do; class1 = "DPP4" ; class2 = "Biguanides"; output; end; 
		else if drugnamewithoutdose = "METFORMIN/PIOGLITAZONE" then do; class1 = "Biguanides" ; class2 = "OTHER"; output; end;
		else if drugnamewithoutdose = "METFORMIN/SAXAGLIPTIN" then do; class1 = "Biguanides" ; class2 = "DPP4"; output; end;
		else if drugnamewithoutdose = "METFORMIN/SITAGLIPTIN" then do; class1 = "Biguanides" ; class2 = "DPP4"; output; end; 

		else do;	
			class1 = 'OTHER'; output; end;
	end;
run;


/*	if index(drugnamewithoutdose,"EXENATIDE") then do; class1="GLP1"; output; end;*/
/*	if index(drugnamewithoutdose,"LIRAGLUTIDE") then do; class1="GLP1"; output; end;*/
/*	if index(drugnamewithoutdose,"DULAGLUTIDE") then do; class1="GLP1"; output; end;*/
/*	if index(drugnamewithoutdose,"GLIMEPIRIDE") then do; class1="Sulfonylureas"; output; end;*/
/*	if index(drugnamewithoutdose,"AMARYL") then do; class1="Sulfonylureas"; output; end;*/
/*	if index(localdrugnamewithdose,"EXENATIDE") then do;  class1="GLP1"; output; end; */
/*	if index(localdrugnamewithdose,"LIRAGLUTIDE") then do;  class1="GLP1"; output; end;*/
/*	if index(localdrugnamewithdose,"DULAGLUTIDE") then do; class1="GLP1"; output; end;*/
/*	if index(localdrugnamewithdose,"GLIMEPIRIDE") then do; class1="Sulfonylureas"; output; end; */
/*	if index(localdrugnamewithdose,"AMARYL") then do; class1="Sulfonylureas"; output; end; */

/*	if index(drugnamewithoutdose,"GLIPIZIDE") then do; class1="Sulfonylureas"; output; end; */
/*	if index(drugnamewithoutdose,"GLYBURIDE") then do; class1="Sulfonylureas"; output; end; */
/*	if index(drugnamewithoutdose,"ALOGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(drugnamewithoutdose,"LINAGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(drugnamewithoutdose,"SITAGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(drugnamewithoutdose,"SAXAGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(drugnamewithoutdose,"CANAGLIFLOZIN") or index(drugnamewithoutdose,"DAPAGLIFLOZIN")*/
/*	or index(drugnamewithoutdose,"EMPAGLIFLOZIN") then do; class1="SGLT2"; output; end;*/
/*	if index(drugnamewithoutdose,"METFORMIN") then do;  class1="Biguanides"; output; end;*/
/*	if index(drugnamewithoutdose,"TOLAZAMIDE") then do;  class1="Sulfonylureas"; output; end;*/
/*	if index(drugnamewithoutdose,"TOLBUTAMIDE") then do;  class1="Sulfonylureas"; output; end;*/
/*	if index(drugnamewithoutdose,"CHLORPROPAMIDE") then do;  class1="Sulfonylureas"; output; end;*/
/*	if index(localdrugnamewithdose,"GLIPIZIDE") then do; class1="Sulfonylureas"; output; end; */
/*	if index(localdrugnamewithdose,"GLYBURIDE") then do; class1="Sulfonylureas"; output; end; */
/*	if index(localdrugnamewithdose,"ALOGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(localdrugnamewithdose,"LINAGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(localdrugnamewithdose,"SITAGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(localdrugnamewithdose,"SAXAGLIPTIN") then do; class1="DPP4"; output; end;*/
/*	if index(localdrugnamewithdose,"CANAGLIFLOZIN") or  index(localdrugnamewithdose,"DAPAGLIFLOZIN")*/
/*	or  index(localdrugnamewithdose,"EMPAGLIFLOZIN") then do; class1="SGLT2"; output; end;*/
/*	if index(localdrugnamewithdose,"METFORMIN") then do;  class1="Biguanides"; output; end;*/
/*	if index(localdrugnamewithdose,"TOLAZAMIDE") then do; class1="Sulfonylureas"; output; end; */
/*	if index(localdrugnamewithdose,"TOLBUTAMIDE") then do; class1="Sulfonylureas"; output; end; */
/*	if index(localdrugnamewithdose,"CHLORPROPAMIDE") then do; class1="Sulfonylureas"; output; end; */





proc sort data=test;
	by class1 class2;
run;

ods output nlevels=charlevels;
proc freq data=test nlevels;
	table class1 class2;
run;
ods output close;

*no missing of drug class;

data data.drug_all;
	set test;
run;

/*********************************************  Add other variables  *********************************************************************/

*fiscal year;
data data.drug_all;
	set data.drug_all;
	if month(DispensedDate) = 10 or month(DispensedDate) = 11 or month(DispensedDate) = 12 then fy = year(DispensedDate) + 1;
	else fy = year(DispensedDate);
run;


/**********************************************  Add ScrSSN     **********************************************************************/

data data.drug_all;
	set data.drug_all;
	keep PatientSID DispensedDate fy LocalDrugNameWithDose DrugNameWithoutDose class1 class2 DaysSupply;
run;

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
	create table test as
		select a.*, b.scrssn, b.patientsid
		from data.drug_all as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

data test;
	retain ScrSSN PatientSID DispensedDate fy LocalDrugNameWithDose DrugNameWithoutDose class1 class2 DaysSupply;
	set test;
run;

data data.drug_all;
	set test;
run;
	
/*******************  Exclude those with history of type-1 diabetes and advanced Kidney Disease (eGFR < 30)  **************/

libname Data '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';
libname egfr '/data/dart/2014/ORD_AlAly_201403107D/Clean Data';

data test;
	set data.drug_all;
	if PatientSID ^= '';
run;

proc sort data=test;
	by PatientSID;
run;

data test1;
	set test;
	by PatientSID;
	if first.PatientSID;
	keep PatientSID;
run;
	
proc sql;
	create table test as
		select a.*, b.scrssn, b.patientsid
		from data.drug_all as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

/* first drug use of history of cohort till fy 2014 */
/* 1 hr 37 min, 2,123,288 observations */
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE data.hist AS
  		SELECT *
		FROM CONNECTION TO TUNNEL (
			SELECT PatientSID, min(DispensedDate)
			FROM [ORD_AlAly_201403107D].[Src].[RxOut_RxOutpatFill]
			WHERE 
				[DispensedDate] <= '01OCT2013'
			AND 
				(
				[DrugNameWithoutDose] LIKE '%GLIMEPIRIDE%' OR
				[DrugNameWithoutDose] LIKE '%AMARYL%' OR
				[DrugNameWithoutDose] LIKE '%GLIPIZIDE%' OR
				[DrugNameWithoutDose] LIKE '%GLYBURIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLAZAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%TOLBUTAMIDE%' OR
				[DrugNameWithoutDose] LIKE '%CHLORPROPAMIDE%' OR

				[DrugNameWithoutDose] LIKE '%ALOGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%LINAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SITAGLIPTIN%' OR
				[DrugNameWithoutDose] LIKE '%SAXAGLIPTIN%' OR

				[DrugNameWithoutDose] LIKE '%EXENATIDE%' OR
				[DrugNameWithoutDose] LIKE '%LIRAGLUTIDE%' OR
				[DrugNameWithoutDose] LIKE '%DULAGLUTIDE%' OR

				[DrugNameWithoutDose] LIKE '%CANAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%DAPAGLIFLOZIN%' OR
				[DrugNameWithoutDose] LIKE '%EMPAGLIFLOZIN%' OR

				[DrugNameWithoutDose] LIKE '%METFORMIN%' OR

				[LocalDrugNameWithDose] LIKE '%GLIMEPIRIDE%' OR
				[LocalDrugNameWithDose] LIKE '%AMARYL%' OR
				[LocalDrugNameWithDose] LIKE '%GLIPIZIDE%' OR
				[LocalDrugNameWithDose] LIKE '%GLYBURIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLAZAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%TOLBUTAMIDE%' OR
				[LocalDrugNameWithDose] LIKE '%CHLORPROPAMIDE%' OR

				[LocalDrugNameWithDose] LIKE '%ALOGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%LINAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SITAGLIPTIN%' OR
				[LocalDrugNameWithDose] LIKE '%SAXAGLIPTIN%' OR

				[LocalDrugNameWithDose] LIKE '%EXENATIDE%' OR
				[LocalDrugNameWithDose] LIKE '%LIRAGLUTIDE%' OR
				[LocalDrugNameWithDose] LIKE '%DULAGLUTIDE%' OR

				[LocalDrugNameWithDose] LIKE '%CANAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%DAPAGLIFLOZIN%' OR
				[LocalDrugNameWithDose] LIKE '%EMPAGLIFLOZIN%' OR

				[LocalDrugNameWithDose] LIKE '%METFORMIN%'
				)
				group by PatientSID
		);
	DISCONNECT FROM TUNNEL ;
QUIT ;

data new ;
	set data.hist;
	rename EXPRSSN = DispensedDate;
run;

data new;
	set new data.drug_all;
run;

proc sort data=new;
	 by patientSID DispensedDate;
run;

data new1;
	set new;
	by patientSID;
	if first.patientSID;
run;

data new1;
	set new1;
	keep patientSID DispensedDate;
run;

data x;
	set egfr.egfr2018;
	if egfr <= 30;
run;

data x;
	set x;
	if egfr ^= .;
run;

proc sort data=x;
	by scrssn res_date;
run;

data x;
	set x;
	by scrssn;
	if first.scrssn;
run;

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
	create table new_scrssn as
		select a.*, b.scrssn, b.patientsid
		from new1 as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

proc sort data=x;
	by scrssn res_date;
run;

data x;
	set x;
	by scrssn;
	if first.scrssn;
	if egfr ^= . or scrssn ^= '';
run;

proc sort data=new_scrssn;
	by scrssn DispensedDate;
run;

data new_scrssn;
	set new_scrssn;
	by scrssn;
	if first.scrssn;
	if scrssn ^= '' or dispenseddate ^= .;
run;

data new2;
	merge new_scrssn x;
	by scrssn;
run;

*56,097 observations;
*all kidney drug users with a history of advanced kidney disease;
data a;
	set new2;
	if res_date ^= . and res_date < DispensedDate;
run;

proc sql;
	create table test as
		select y.*, z.scrssn
		from data.drug_all as y 
		left join a as z
		on y.scrssn = z.scrssn
		where z.scrssn is NULL;
quit;

data data.drug_hclean;
	set test;
run;

data data.hist;
	set new_scrssn;
run;

/************************** type 1 diabetes ********************/

*Get a list of patients with ICD9 and ICD10 codes for type1 diabetes, get their earliest date;
*compare against data.hist to see if the type1 diabetes dates happen before data.hist dates;
*ouput the ones that do have history of type1 into table 'hist_type1';

*import inpatient;
/* 25 seconds - 13,699,661 records */
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. ) ;
	CREATE TABLE inpat AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT patientSID, AdmitDateTime, PrincipalDiagnosisICD10SID, PrincipalDiagnosisICD9SID
			FROM [ORD_AlAly_201403107D].[Src].[Inpat_Inpatient]
		);
	DISCONNECT FROM TUNNEL;
QUIT;

*import outpatient;
/* 36 minutes, 2,679,047,586 records */
*outpatient;
PROC SQL;
  	CONNECT TO SQLSVR AS TUNNEL (DATASRC=ORD_AlAly_201403107D &SQL_OPTIMAL. );
	CREATE TABLE outpat AS
  		SELECT  *
		FROM CONNECTION TO TUNNEL (
			SELECT patientSID, VisitDateTime, ICD10SID, ICD9SID
			FROM [ORD_AlAly_201403107D].[Src].[Outpat_VDiagnosis] 
		);
	DISCONNECT FROM TUNNEL;
QUIT;

PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=CDWWork_FY16_CDWRB01 &SQL_OPTIMAL.);
   	CREATE Table ICD9 AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT ICD9SID, ICD9Code
         	FROM Dim.ICD9
     	);
   	DISCONNECT FROM TUNNEL;
QUIT;

PROC SQL;
   	CONNECT TO SQLSVR as TUNNEL (Datasrc=CDWWork_FY16_CDWRB01 &SQL_OPTIMAL.);
   	CREATE Table ICD10 AS 
   		SELECT *
      	FROM CONNECTION TO TUNNEL (
      		SELECT ICD10SID, ICD10Code
         	FROM Dim.ICD10
     	);
   	DISCONNECT FROM TUNNEL;
QUIT;

*type1 history in all VA;
proc sql;
	create table inpat9 as 
		select a.*, b.ICD9SID, b.ICD9Code
		from inpat as a, ICD9 as b
		where a.PrincipalDiagnosisICD9SID=b.ICD9SID
		and icd9code in ('250.01','250.03','250.11','250.13','250.21','250.23','250.31','250.33','250.41','250.43',
						'250.51','250.53','250.61','250.63','250.71','250.73','250.81','250.83','250.91','250.93');
quit;

proc sql;
	create table inpat10 as 
		select a.*, b.ICD10SID, b.ICD10Code
		from inpat as a, ICD10 (where=(icd10code in:('E10'))) as b 
		where a.PrincipalDiagnosisICD10SID=b.ICD10SID;
quit;

proc sql;
	create table outpat9 as 
		select a.*, b.ICD9SID, b.ICD9Code
		from outpat as a, ICD9 as b
		where a.ICD9SID=b.ICD9SID
		and icd9code in ('250.01','250.03','250.11','250.13','250.21','250.23','250.31','250.33','250.41','250.43',
						'250.51','250.53','250.61','250.63','250.71','250.73','250.81','250.83','250.91','250.93');
quit;

proc sql;
	create table outpat10 as 
		select a.*, b.ICD10SID, b.ICD10Code
		from outpat as a, ICD10 (where=(icd10code in:('E10'))) as b
		where a.ICD10SID=b.ICD10SID;
quit;

data inout;
	set inpat9 inpat10 outpat9 outpat10;
run;

data inout;
	set inout;
	if admitdatetime ^= . then diag_date = datepart(admitdatetime);
	if visitdatetime ^= . then diag_date = datepart(visitdatetime);
	keep patientSID diag_date;
run;

proc sort data=inout;
	by PatientSID diag_date;
run;

data inout;
	set inout;
	by patientSID;
	if first.patientSID;
run;

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

*list of scrSSNs with history of type1 diabetes;
proc sql;
	create table inout as
		select a.*, b.scrssn
		from inout as a, spatient as b
		where a.patientsid=b.patientsid;
quit;

proc sort data=inout;
	by scrssn diag_date;
run;
data inout;
	set inout;
	by scrssn;
	if first.scrssn;
run;

proc sort data=data.hist;	
	by scrssn;
run;

data merger;
	merge inout data.hist;
	by scrssn;
run;

*73,284 observations;
*all kidney drug users with a history of type1 diabetes;
data test;
	set merger;
	if diag_date ^= . and diag_date < DispensedDate;
run;

proc sql;
	create table test1 as
		select y.*, z.scrssn
		from data.drug_hclean as y 
		left join test as z
		on y.scrssn = z.scrssn
		where z.scrssn is NULL;
quit;

data data.drug_hclean;
	set test1;
run;

data test;
	set data.drug_hclean;
	if scrssn ^= '';
run;

data data.drug_hclean;
	set test;
run;

