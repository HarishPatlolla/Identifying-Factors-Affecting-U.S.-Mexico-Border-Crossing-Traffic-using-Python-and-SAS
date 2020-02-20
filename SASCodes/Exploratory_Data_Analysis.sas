libname orion 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic';
libname orion_op 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\SAS_Datasets';


/*GROUPING NON-COMMERCIAL DATA FOR GENERATING LINE CHARTS*/

PROC SUMMARY DATA=ORION_OP.US_MEXICO_NONCOMMERCIAL NWAY;
  CLASS YEAR ;
  FORMAT YEAR YEAR4.;
  VAR VALUE;
  OUTPUT OUT=ORION_OP.US_MEXICO_DATA_NONCOMM_YEAR (DROP=_:) SUM=/AUTONAME;
RUN;

/*Scaling the data*/

DATA US_MEXICO_DATA_NONCOMM_YEAR1;
SET ORION_OP.US_MEXICO_DATA_NONCOMM_YEAR;
Passenger_count = Value_sum/1e6;
RUN;


/*Grouping Commercial data for generating line charts*/

proc summary data=ORION_OP.US_MEXICO_COMMERCIAL nway;
  class YEAR ;
  format YEAR Year4.;
  var Value;
  output out=ORION_OP.US_MEXICO_DATA_COMM_YEAR (drop=_:) sum=/autoname;
run;

/*Scaling the data*/
DATA US_MEXICO_DATA_COMM_YEAR1;
SET ORION_OP.US_MEXICO_DATA_COMM_YEAR;
Passenger_count = Value_sum/1e6;
RUN;


/* Trend chart for passenger vehicles from 2008 to 2018*/


ods listing close;
ods html file='bmi.html' path='.' style=styles.bmi;
ods graphics / reset width=600px height=400px imagename="Passengers_Trend" imagefmt=gif;

 TITLE 'Passengers from 2008 to 2018';

PROC SGPLOT DATA = US_MEXICO_DATA_NONCOMM_YEAR1;
 SERIES X = Year Y =Passenger_count/
 lineattrs=(pattern=solid thickness=2px)  
          markerattrs=(symbol=circlefilled)
			datalabel=Passenger_count;
 Xaxis label='Year';
 Yaxis label='Number of Passengers ( in Millions )';
RUN; 

ods html close;
ods listing;


/* Trend chart for Commercial vehicles from 2008 to 2018*/

ods listing close;
ods html file='bmi.html' path='.' style=styles.bmi;
ods graphics / reset width=600px height=400px imagename="CommercialVehicles_Trend" imagefmt=gif;

TITLE 'Commercial Vehicle Trends from 2008 to 2018';


PROC SGPLOT DATA = US_MEXICO_DATA_COMM_YEAR1;
 SERIES X = Year Y = Passenger_count/
 lineattrs=(pattern=solid thickness=2px)  
          markerattrs=(symbol=circlefilled)
			datalabel=Passenger_count;
 Xaxis label='Year';
 Yaxis label='Number of Commercial Vehicles ( in Millions )';
RUN; 

ods html close;
ods listing;



/**************************************************************************/    
/* STATE WISE DISTRIBUTION OF PASSENGER AND COMMERCIAL VEHICLES*/ 
/****************************************************************************/


/**************************************************************************/
/*     IMPORTING THE STATES DUMMY FILE                               /
****************************************************************************/

PROC IMPORT OUT=ORION_OP.states_dummy
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\OtherStates.xlsx'
DBMS = xlsx ;
GETNAMES = YES;
RUN;

DATA ORION_OP.states_dummy1;
SET ORION_OP.states_dummy;
FORMAT Avg_Avg 8. DATE_FORMATTED 8.
GDP 8. MEX_PESO 8. 
MONTH 8.
Port_Code 8.
State 8.
US_Unemp_Rate 8.
Unemployment_Rate 8.Value 8.;
RUN;



data  orion_op.us_mexico1;
set orion_op.US_MEXICO_NONCOMMERCIAL;
if State='Arizona' then State1=4;
if State='California' then State1=6;
if State='New Mexico' then State1=35;
if State='Texas' then State1=48; 
run;

data  orion_op.us_mexico2;
set orion_op.us_mexico1;
drop State;
rename State1=State;
run;


DATA orion_op.us_mexico3;
SET orion_op.us_mexico2  ORION_OP.states_dummy1;
RUN;


proc summary data=orion_op.us_mexico3 nway;
  class State ;
  var Value;
  output out=orion_op.us_mexico4 (drop=_:) sum=/autoname;
run;


DATA orion_op.us_mexico5;
SET ORION_OP.us_mexico4;
Passenger_count = Value_sum/1e6;
RUN;

/*goptions reset=all border;*/
/*title1 ls=1.5 "State Wise Traffic";*/
/*legend1 label=(position=top) shape=bar(.1in,.1in);*/

data anno_labels; set maps.uscenter;
length function $8 color $8;
retain flag 0;
xsys='2'; ysys='2'; hsys='3'; when='a';
function='label'; color='blue'; size=2.3;
if ocean^='Y' and flag^=1 then do;
text=trim(left(fipstate(state))); position='5'; output;
end;
else if ocean='Y' then do;
text=trim(left(fipstate(state))); position='6'; output;
function='move'; text=''; position=''; output;
flag=1;
end;
else if flag=1 then do;
function='draw'; size=.25; output;
flag=0;
end;
run;

ods listing close;
ods html file='bmi.html' path='.' style=styles.bmi;
ods graphics / reset width=600px height=400px imagename="StateWise Passengers Distribution" imagefmt=gif;

proc gmap data=orion_op.us_mexico5 map=maps.us anno=anno_labels ;
id state;
choro Passenger_count/coutline=black nolegend ;
run;
quit;

ods html close;
ods listing;
