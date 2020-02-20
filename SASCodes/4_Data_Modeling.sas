libname orion 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic';
libname orion_op 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\SAS_Datasets';

               /****************** *******************************************************************/ 
                /* PANEL REGRESSION FOR MEXICAN COMMERCIAL VEHICLE DURING OBAMA PRESIDENCY */
              /***************************************************************************************/
   
/*PROC CONTENTS DATA=ORION_OP.US_MEX_COMMERCIAL_OBAMA;*/
/*RUN;*/
/**/
/*PROC MEANS DATA=ORION_OP.US_MEX_COMMERCIAL_OBAMA MEAN SKEWNESS KURTOSIS N; */
/*VAR AVG_AVG GDP MEX_PESO US_UNEMP_RATE UNEMPLOYMENT_RATE; RUN;*/
/**/
/*PROC CORR DATA=ORION_OP.US_MEX_COMMERCIAL_OBAMA;*/
/*RUN;*/

PROC SORT DATA=ORION_OP.US_MEX_COMMERCIAL_OBAMA;
BY PORT_NAME MONTH;
RUN;

PROC PANEL DATA= ORION_OP.US_MEX_COMMERCIAL_OBAMA;
ID  PORT_NAME MONTH;
instruments correlated=(US_UNEMP_RATE UNEMPLOYMENT_RATE);
MODEL VEH_COUNT = AVG_AVG MEX_PESO US_UNEMP_RATE UNEMPLOYMENT_RATE GDP /htaylor;
RUN;

                /****************** *******************************************************************/ 
                /* PANEL REGRESSION FOR MEXICAN COMMERCIAL VEHICLES DURING TRUMP PRESIDENCY */
              /***************************************************************************************/
  
/**************************************************************************/
/*      Importing the articles effects output from text analytics*/ 
/****************************************************************************/

PROC IMPORT OUT=ORION_OP.TEXT_ANALYTICS
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\Trump_articles_lag_2months.xlsx'
DBMS = XLSX REPLACE;
GETNAMES = YES;
RUN;

PROC SORT DATA=ORION_OP.US_MEX_COMMERCIAL_TRUMP; 
BY  MONTH;RUN;

PROC SORT DATA=ORION_OP.TEXT_ANALYTICS; 
BY  MONTH;RUN;

DATA ORION_OP.US_MEX_COMMERCIAL_TRUMP_MERGED;
MERGE ORION_OP.US_MEX_COMMERCIAL_TRUMP(IN=ALL) 
	  ORION_OP.TEXT_ANALYTICS(IN=ALL); 
BY MONTH GROUPFORMAT;
FORMAT MONTH YYMMN6.;
RUN;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_COMMERCIAL_TRUMP_MERGED
WHERE PORT_NAME=' ';
QUIT;

PROC SORT DATA=ORION_OP.US_MEX_COMMERCIAL_TRUMP_MERGED;
BY PORT_NAME MONTH;
RUN;

PROC PANEL DATA= ORION_OP.US_MEX_COMMERCIAL_TRUMP_MERGED;
CLASS ARTICLE_EFFECT;
ID  PORT_NAME MONTH;
instruments correlated=(US_UNEMP_RATE UNEMPLOYMENT_RATE);
MODEL VEH_COUNT = AVG_AVG MEX_PESO US_UNEMP_RATE UNEMPLOYMENT_RATE GDP ARTICLE_EFFECT/htaylor;
RUN;



              /****************** *******************************************************************/ 
                /* PANEL REGRESSION FOR MEXICAN NON-COMMERCIAL VEHICLES DURING OBAMA PRESIDENCY */
              /***************************************************************************************/
  

PROC SORT DATA=ORION_OP.US_MEX_NONCOMMERCIAL_OBAMA;
BY PORT_NAME MONTH;
RUN;

PROC PANEL DATA= ORION_OP.US_MEX_NONCOMMERCIAL_OBAMA;
ID  PORT_NAME MONTH;
instruments correlated=(US_UNEMP_RATE UNEMPLOYMENT_RATE);
MODEL VEH_COUNT = AVG_AVG MEX_PESO US_UNEMP_RATE UNEMPLOYMENT_RATE GDP /htaylor;
RUN;


                /********************************************************/ 
                  /*PANEL REGRESSION FOR TRUMP NON-COMMERCIAL VEHICLES*/
                /*********************************************************/

PROC SORT DATA=ORION_OP.US_MEX_NONCOMMERCIAL_TRUMP;
BY MONTH;
RUN;

DATA ORION_OP.US_MEX_NONCOMM_TRUMP_MERGED;
MERGE ORION_OP.US_MEX_NONCOMMERCIAL_TRUMP(IN=ALL) 
	  ORION_OP.TEXT_ANALYTICS(IN=ALL); 
BY MONTH GROUPFORMAT;
FORMAT MONTH YYMMN6.;
RUN;

PROC SQL;
DELETE FROM  ORION_OP.US_MEX_NONCOMM_TRUMP_MERGED WHERE BORDER IS NULL;
QUIT;

PROC SORT DATA=ORION_OP.US_MEX_NONCOMM_TRUMP_MERGED;
BY PORT_NAME MONTH;
RUN;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_NONCOMM_TRUMP_MERGED
	WHERE  PORT_NAME='otay mesa' AND INPUT(PUT(MONTH,YYMMN6.),8.)=201709
/*TRIM(PUT(MONTH,8.))='201709'*/
AND AVG_AVG=62.93;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_NONCOMM_TRUMP_MERGED
	WHERE  PORT_NAME='lukeville' ;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_NONCOMM_TRUMP_MERGED
	WHERE PORT_NAME='presido' OR PORT_NAME='san luis'  ;
QUIT;


PROC PANEL DATA= ORION_OP.US_MEX_NONCOMM_TRUMP_MERGED;
CLASS ARTICLE_EFFECT;
ID  PORT_NAME MONTH;
instruments correlated=(US_UNEMP_RATE UNEMPLOYMENT_RATE);
MODEL VEH_COUNT = AVG_AVG MEX_PESO US_UNEMP_RATE UNEMPLOYMENT_RATE GDP ARTICLE_EFFECT/htaylor;
RUN;

