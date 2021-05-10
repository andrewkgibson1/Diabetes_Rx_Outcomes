* Rx History Sequences ;

libname r '/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/SGLT2/Data';

/**************************** Clean up Cohort ****************************/

*comes after SGLT2_Cohort;
data rx;
	set r.drug_hclean;
	rename DispensedDate = r1_dt; 
	rename class1 = rx_class;
	r2_dt = DispensedDate + DaysSupply - 1;
	format r2_dt date9.;
	keep ScrSSN DispensedDate class1 class2 r2_dt;
run;

data rx1;
	set rx;
	if class2 ^= '' then do;
		output;
		rx_class = class2;
		output;
	end;
	else output;
run;

data rx1;
	retain ScrSSN rx_class r1_dt r2_dt;
	set rx1;
	drop class2;
run; 
*17,861,451 records in rx1;

data r.rx;
	set rx1;
run;

/**************************** Start Date ****************************/

*Start with 1 prescription record per row (rxptsd), get the first prescription date per drugname per person;
proc summary data=r.rx(keep=ScrSSN rx_class r1_dt r2_dt) nway;
  class ScrSSN rx_class;
  var r1_dt;
  output out=outr1(drop=_type_ _freq_) min(r1_dt)=min_r1; *1,594,914 records;
run;

*(outr1) starts with first Rx date per drugname per person per row, build start date from start of washout;
%let back=0; * Enter 0 if no need for washout;
data start; 
  set outr1;
  start_dt=min_r1-&back;  
  format start_dt mmddyy10.;
run;

/**************************** End Date ****************************/

*get last prescription date within study period;
proc summary data=r.rx(keep=ScrSSN rx_class r1_dt r2_dt) nway;
  class ScrSSN rx_class;
  var r2_dt;
  output out=end(drop=_type_ _freq_) max(r2_dt)=max_r2; * * 851;
run;

*Max of r2_dt if it's > 09/30/2018, or 09/30/2018 if it's <= 09/30/2018;
*end of fy 2018 is end of study period but drug medication may continue on after this;
data end2; * n=851;
  set end;
  if max_r2 <= '30SEP2018'd then do;
    end_dt='30SEP2018'd;
    pad0=1; * Indicate patient not on meds from end of last prescription to end of study;
  end;
  else end_dt=max_r2;
  format end_dt mmddyy10.;
run;

/**************************** Create dts ****************************/

proc sort data=start;
  by ScrSSN rx_class;
run;

*merge start and end dates;
data dts; * n=1,594,914;
  merge start(in=a) end2(in=b); 
  by ScrSSN rx_class;
  if a and b and missing(start_dt)=0 & missing(end_dt)=0;
run;

proc sql; * n=1,039,441 ScrSSNs;
  create table cnt as
  select distinct ScrSSN
  from dts;
quit;

* Set Start_dt and End_dt for each ScrSSN, using the smallest Start_dt and largest End_dt;
proc summary data=dts nway;
  class ScrSSN;
  var start_dt end_dt;
  output out=outdt min(start_dt)=ScrSSN_start_dt max(end_dt)=ScrSSN_end_dt; * n=1,039,441 ScrSSNs;
run;
data r.dts; * n=1,594,914;
  merge dts outdt(keep=ScrSSN ScrSSN_start_dt ScrSSN_end_dt);
  by ScrSSN;
  len_win=ScrSSN_end_dt-ScrSSN_start_dt+1;
run;

/************************ Set up & build Rx history string ****************************/

*find longest med history = nvar among all patients;
proc summary data=r.dts(keep=len_win);
  var len_win;
  output out=tmp max=nvar; *nvar=1958;
run;

*put nvar in macro variable;
data _null_;
  set tmp;
  call symput('nvar',put(left(nvar),5.));
run;
%put &nvar; * 1958; * This is the longest medication history of the patients in the study cohort;

proc sort data=r.dts; * This dataset has start and end dates of each drug name and patient (1 row = drug name/patient);
  by ScrSSN rx_class;
run;
proc sort data=r.rx; * This data has all the individual prescriptions for the patients (1 row = 1 prescription);
  by ScrSSN rx_class r1_dt r2_dt;
run;

*41 minutes, 1,594,914 observations;
data r.rxstr(drop=i r1_dt r2_dt d_1-d_&nvar x1-x&nvar s1-s&nvar);
  merge r.rx(in=a) r.dts(in=b);
  by ScrSSN  rx_class;
  if a and b;

  length rxstr $ &nvar; *define length of prescription string as length of longest med history among all patients;
  retain s1-s&nvar;

  array d[*] d_1-d_&nvar; *define arrays used;
  array x[*] 3 x1-x&nvar;
  array s[*] 3 s1-s&nvar;

  *initiate array as length of longest med history among all patients;
  if first.rx_class then
    do i=1 to &nvar;
	  s[i]=0;
	end;
   
  *loop through med history of unique patients, among all their prescriptions; 
  *len_win = longest med history/person;
  do i=1 to len_win; 

    *BUILD ARRAY OF DATES;
    if i=1 then d[i]=ScrSSN_start_dt;
    else d[i]=d[i-1]+1;
	
	*BUILD ARRAY OF DRUG USE;
	*if current index date is during days on medication, insert a '1' into array x;
	if r1_dt <= d[i] <= r2_dt then x[i]=1; * Inside each fill range;
	else if start_dt <= d[i] <= end_dt then x[i]=0; * Inside each Rx range;
	else x[i]=.; * Inside ScrSSN range;

	*BUILD ARRAY OF OVERLAP OF REFILLS;
	*if have another prescription for the same drug during this day, add 1 to show # of overlap of refills;
    if x[i]=1 then s[i]=s[i]+x[i]; 
	if last.rx_class then do;
      if s[i]>9 then s[i]=9; *cap the overlap number at 9;
	end;

  end; 

  if last.rx_class then do;
    c=max(of s1-s&nvar); *show max overlap per drug per person;
    rxstr=substr(cats(of s1-s&nvar),1,len_win); *removes blanks between 0s and 1s and converts them into character string;
    output r.rxstr; * n=851;
  end;
  format d_: mmddyy10.; *format date array;
run; 

* Distribution of # of overlapping prescriptons in one day;
proc freq data=r.rxstr(keep=c);
  table c;
run; 

/********************* Allowing surplus from overlapping pre to carryover into the future ****************************/

*1 hr, 40 min, 1,594,914 observations;
* Carryover leftover pills;
data r.rxstrl(drop=i k r1_dt r2_dt d_1-d_&nvar x1-x&nvar s1-s&nvar);
  merge r.rx(in=a) r.dts(in=b);
  by ScrSSN  rx_class;
  if a and b;

  length nfill extra 3 rxstr $ &nvar; *define length of prescription string as length of longest med history among all patients;
  retain nfill extra s1-s&nvar;

  array d[*] d_1-d_&nvar; *define arrays used;
  array x[*] 3 x1-x&nvar;
  array s[*] 3 s1-s&nvar;

  * Initiate fill #, leftover pill balance, summary string;
  * initiate array as length of longest med history among all patients;
  if first.rx_class then do;
    nfill=1;
    do i=1 to &nvar;
	  s[i]=0;
	end;
  end;
  else nfill+1;

  * For each refill data;
  *loop through med history of unique patients, among all their prescriptions; 
  *len_win = longest med history/person;
  do i=1 to len_win;

    *BUILD ARRAY OF DATES;
    if i=1 then do;
      d[i]=ScrSSN_start_dt;
	  extra=0;
	end;
      else d[i]=d[i-1]+1;

	*BUILD ARRAY OF DRUG USE;
	*if current index date is during days on medication, insert a '1' into array x;
	if r1_dt <= d[i] <= r2_dt then x[i]=1; * Inside each fill range;
	else if start_dt <= d[i] <= end_dt then x[i]=0; * Inside each Rx range;
	else x[i]=.; * Inside ScrSSN range;

	*BUILD ARRAY OF OVERLAP OF REFILLS - CONVERT TO EXTRA MEDICATION;
	*if have another prescription for the same drug during this day, add 1 to show # of overlap of refills;
    if x[i]=1 then s[i]=s[i]+x[i]; 
	* If there is overlap/extra;
	if (nfill > 1 & s[i]=2) then do;
	  s[i]=1;
      extra+1;
	end;

	* Move position of r2_dt of the latter refill based on extra medication;
	if i = intck('day',ScrSSN_start_dt,r2_dt)+1 then do;
      do k=0 to extra;
	    if i+k <= len_win then s[i+k]=1;
      end;
	end; 

  end;

  if last.rx_class then do;
    c=max(of s1-s&nvar); *show max overlap per drug per person;
    rxstr=substr(cats(of s1-s&nvar),1,len_win); *removes blanks between 0s and 1s and converts them into character string;
    output r.rxstrl; * n=1,594,914;
  end;
  format d_: mmddyy10.; *format date array;
run; 

proc freq data=r.rxstrl(keep=c);
  table c;  * Should only be 1 with carrying over;
run; 

/************************* Distribution of multiple drug class users in study period **********************************/

proc sql ;
	create table Rxcount as 
		select ScrSSN, count(*) as NumRx
			from r.rxstrl
			group by ScrSSN;
quit;

title Distribution of Multiple Drug Class Users;
proc freq data=Rxcount;
	table NumRx;
run;
title;

/********************************* Total overlap of different drug classes ****************************************/

*find longest med history = nvar among all patients;
proc summary data=r.dts(keep=len_win);
  var len_win;
  output out=tmp max=nvar; *nvar=1958;
run;

*put nvar in macro variable;
data _null_;
  set tmp;
  call symput('nvar',put(left(nvar),5.));
run;
%put &nvar; * 1958; * This is the longest medication history of the patients in the study cohort;

data r.rxstro(drop=i a1-a&nvar b1-b&nvar rxstr);
  set r.rxstrl;
  by ScrSSN;

  length rxstro $ &nvar; *define length of prescription string as length of longest med history among all patients;
  retain a1-a&nvar;

  array a[*] 3 a1-a&nvar; *define arrays used;
  array b[*] 3 b1-b&nvar;

  *initiate array as length of longest med history among all patients;
  if first.ScrSSN then
    do i=1 to &nvar;
	  a[i]=0;
	end;
  
  *loop through med history of unique patients, among all their prescriptions; 
  *len_win = longest med history/person;
  do i=1 to len_win;
	b[i] = substr(rxstr,i,1);
	a[i] = a[i] + b[i];
  end; 

  if last.ScrSSN then do;
    c=max(of a1-a&nvar); *show max overlap per drug per person;
    rxstro=substr(cats(of a1-a&nvar),1,len_win); *removes blanks between 0s and 1s and converts them into character string;
    output r.rxstro; * n=1,039,441;
  end;
run; 

* Distribution of # of overlapping prescriptons in one day;
proc freq data=r.rxstro(keep=c);
  table c;
run; 

/********************************* History of different drug class overlap ****************************************/

*5 minutes;
*sort by ScrSSN and then min_r1;
proc sort data=r.rxstrl out=a;
	by ScrSSN min_r1;
run;

data r.rxstrch(drop=i a1-a&nvar b1-b&nvar rxstr rx_class);
  set a;
  by ScrSSN min_r1;

  length rxstrch $ &nvar; *define length of prescription string as length of longest med history among all patients;
  length class_hs $ 500;
  retain a1-a&nvar class_hs;

  array a[*] 3 a1-a&nvar; *define arrays used;
  array b[*] 3 b1-b&nvar;

  *initiate array as length of longest med history among all patients;
  if first.ScrSSN then
    do i=1 to &nvar;
	  a[i]=0;
	end;
  
  *loop through med history of unique patients, among all their prescriptions; 
  *len_win = longest med history/person;
  do i=1 to len_win;
	b[i] = substr(rxstr,i,1);
	a[i] = a[i] + b[i];
  end; 

  if first.ScrSSN then
	class_hs = rx_class;
  else
  	class_hs = catx('-',class_hs,rx_class);

/*  if lag(min_r1) ^= . and lag(min_r1) = min_r1 then*/
/*  	class_hs = class_hs || 'x' || rx_class;*/
/*  else class_hs = class_hs || ' - ' || rx_class;*/
   
  c=max(of a1-a&nvar); *show max overlap per drug per person;
  rxstrch=substr(cats(of a1-a&nvar),1,len_win); *removes blanks between 0s and 1s and converts them into character string;
  output r.rxstrch; * n=1,594,914;
run; 

/********************  class history  ******************/

data test;
	set r.rxstrch;
	by scrssn;
	if last.scrssn; *n= 1,039,441;
run;

data r.rxstrch;
	set test;
run;

title "Class History";
ods output nlevels=charlevels;
proc freq data=r.rxstrch nlevels;
	table class_hs;
run;
ods output close;
title;

/********************  Metformin history  ******************/

data test1;
	set test;
	if class_hs =: 'Biguanides-'; *n= 1,039,441;
run;

title "Metformin History";
ods output nlevels=charlevels;
proc freq data=test1 nlevels;
	table class_hs;
run;
ods output close;
title;

/********************  Second-line drug after Metformin - Work in Progress ******************/

proc sql;
	create table test2 as 
		select a.*, b.scrssn
		from r.rxstrl as a, test1 as b
		where a.scrssn=b.scrssn;
quit;

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

proc sql;
	create table test3 as 
		select a.*, b.scrssn, b.dod
		from test2 as a, death as b
		where a.scrssn=b.scrssn;
quit;

*censoring guidelines;
data test4(drop=(dt1 dt2 dt3 dt4 dtA dtB);
	set test3;
	by ScrSSN;

	retain dtA;

	dt1 = ScrSSN_end_dt;
	dt2 = ScrSSN_end_dt;
	dt3 = ScrSSN_end_dt;
	dt4 = dod;

	if not first.ScrSSN then do;
		*30 days off Rx;
		do i=1 to len_win-31;
			if index(substr(rxstr,i,31),'10') ^= 0 and 
		if 
		substr(rxstr,index(rxstr,'10'),30)
		when substr(rxstr,index(rxstr,'10'),30) do;
			dt1 = ScrSSN_start_dt + index(substr()) - 1;
		end;

		*new drug;
		dt2 = ScrSSN_start_dt + index(substr()) - 1;
	end;

	dtA = min(dt1,dt2,dt3,dt4);

	if not first.ScrSSN then do;
		dtB = ;
		censor = min(dtA,dtB);
	end;

run;

data test5;
	set test4;
	by ScrSSN;
	if not first.ScrSSN;
run;

data test6;
	set test5;
	by ScrSSN;
	if first.ScrSSN;
run;

proc freq data=test5;
/*	by time;*/
run;
