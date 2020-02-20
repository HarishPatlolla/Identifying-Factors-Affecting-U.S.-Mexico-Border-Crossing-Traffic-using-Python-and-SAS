libname orion 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic';
libname orion_op 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\SAS_Datasets';


/**************************************************************************/
/*   CONSIDERING DATA FROM JAN 2009 ONWARDS
     DROPPING THE LOCATION and DATE COLUMNS
	 LOWERING THE CASE OF PORT NAME 
	 FORMATTING THE DATE COLUMN TO YYYYMM 
****************************************************************************/
DATA ORION_OP.BORDER_TRAFFIC_UPDATED(WHERE=(DATE_FORMATTED>='01JAN2009'D));
SET ORION_OP.BORDER_TRAFFIC_MAIN;
DROP  DATE;
PORT_NAME=LOWCASE(PORT_NAME);
DATE_FORMATTED=DATEPART(DATE);
MONTH = DATEPART(DATE);
FORMAT MONTH YYMMN6.;
FORMAT DATE_FORMATTED MMDDYY10.;
RUN;



/**************************************************************************/
/*      MERGING WEATHER DATA WITH URL DATA TO TAG THE PORTNAMES        
****************************************************************************/
PROC SQL;
CREATE TABLE ORION_OP.WEATHER_MERGE AS
SELECT A.MONTH,
A.URL,
A.AVG_AVG,
B.PORT_NAME,
B.STATE FROM 
	ORION_OP.WEATHER_MAIN A 
		JOIN 
	ORION_OP.URL B 
ON A.URL=B.URL;
QUIT;

/**************************************************************************/
/*    SUBSETTING THE REQUIRED COLUMNS
      LOWERING THE CASE OF PORTNAME
      FORMATTING THE DATE COLUMN TO YYYYMM
****************************************************************************/
DATA ORION_OP.WEATHER_FIN;
SET ORION_OP.WEATHER_MERGE;
PORT_NAME=LOWCASE(PORT_NAME);
KEEP MONTH_FORMAT PORT_NAME AVG_AVG STATE URL;
RENAME MONTH_FORMAT=MONTH;
MONTH_FORMAT =INPUT(MONTH, ANYDTDTE21.);
FORMAT MONTH_FORMAT YYMMN6.;
RUN;


/**************************************************************************/
/*      MERGING BORDER TRAFFIC MAIN WITH THE WEATHER DATA      
****************************************************************************/
PROC SQL;
CREATE TABLE ORION_OP.BORDER_TRAFFIC_WEATHER AS
SELECT A.*,
B.AVG_AVG,
B.URL FROM 
	ORION_OP.BORDER_TRAFFIC_UPDATED A
		LEFT JOIN 
	ORION_OP.WEATHER_FIN B
ON A.PORT_NAME=B.PORT_NAME
AND A.MONTH=B.MONTH;
QUIT;

PROC SORT DATA=ORION_OP.BORDER_TRAFFIC_WEATHER;BY MONTH;RUN;

/**************************************************************************/
/*    FORMATTING THE DATE COLUMN OF EXCHANGE RATE DATA TO YYYYMM
****************************************************************************/
DATA ORION_OP.EXCHANGERATE_FIN;
SET ORION_OP.EXCHANGERATE_MEXICO_MAIN;
DROP VAR1 MONTH;
RENAME _MXN_PESO=MEX_PESO MONTH_FORMAT=MONTH;
MONTH_FORMAT=DATEPART(MONTH);
FORMAT MONTH_FORMAT YYMMN6.;
RUN;


/**************************************************************************/
/*      MERGING BORDER_TRAFFIC_WEATHER WITH THE MEXICO EXCHANGE RATES DATA      
****************************************************************************/
PROC SQL;
CREATE TABLE ORION_OP.BORDER_WEATHER_EXCHANGE AS
SELECT A.*,B.MEX_PESO 
FROM ORION_OP.BORDER_TRAFFIC_WEATHER A
	LEFT JOIN 
ORION_OP.EXCHANGERATE_FIN B
ON A.MONTH=B.MONTH
AND A.BORDER='US-Mexico Border';
QUIT;

PROC SORT DATA=ORION_OP.BORDER_WEATHER_EXCHANGE;BY MONTH; RUN;



/**************************************************************************/
/*    FORMATTING THE DATE COLUMN OF UNEMPLOYMENT RATE TABLES TO YYYYMM
****************************************************************************/
/*Canada Unemployment Table*/
DATA ORION_OP.CANADA_UNEMPLOYMENT_UPDATED;
LENGTH MONTH 6;
SET ORION_OP.CANADA_UNEMPLOYMENT_MAIN;
MONTH=DATETIME;
FORMAT MONTH YYMMN6.;
RUN;

PROC SORT DATA=ORION_OP.CANADA_UNEMPLOYMENT_UPDATED;BY MONTH; RUN;


/*Mexico Unemployment Table*/
DATA ORION_OP.MEXICO_UNEMPLOYMENT_UPDATED;
LENGTH MONTH 6;
SET ORION_OP.MEXICO_UNEMPLOYMENT_MAIN;
MONTH=DATETIME;
FORMAT MONTH YYMMN6.;
RUN;

PROC SORT DATA=ORION_OP.MEXICO_UNEMPLOYMENT_UPDATED;BY MONTH; RUN;

/*USA Unemployment Table*/
DATA ORION_OP.US_UNEMPLOYMENT_UPDATED;
LENGTH MONTH 6;
SET ORION_OP.US_UNEMPLOYMENT_MAIN;
MONTH=DATETIME;
FORMAT MONTH YYMMN6.;
RUN;

PROC SORT DATA=ORION_OP.US_UNEMPLOYMENT_UPDATED;BY MONTH; RUN;

/**************************************************************************/
/*      MERGING BORDER_WEATHER_EXCHANGE WITH THE CANADA UNEMPLOYMENT RATE DATA      
****************************************************************************/
DATA ORION_OP.BORDER_UNEMPLOY_CAN;
DROP VAR1 COUNTRY DATETIME;
MERGE ORION_OP.BORDER_WEATHER_EXCHANGE(IN=ALL WHERE=(BORDER='US-Canada Border')) 
	  ORION_OP.CANADA_UNEMPLOYMENT_UPDATED(IN=ALL); 
BY MONTH GROUPFORMAT;
FORMAT MONTH YYMMN6.;
RUN;

/**************************************************************************/
/*      MERGING BORDER_WEATHER_EXCHANGE WITH THE MEXICO UNEMPLOYMENT RATE DATA      
****************************************************************************/
DATA ORION_OP.BORDER_UNEMPLOY_MEX;
DROP VAR1 COUNTRY DATETIME;
MERGE ORION_OP.BORDER_WEATHER_EXCHANGE(IN=ALL WHERE=(BORDER='US-Mexico Border')) 
	  ORION_OP.MEXICO_UNEMPLOYMENT_UPDATED(IN=ALL); 
BY MONTH GROUPFORMAT;
FORMAT MONTH YYMMN6.;
RUN;


/**************************************************************************/
/* /********COMBINING THE MEXICAN AND CANADA DATA FROM ABOVE TWO TABLES*/     
/*****************************************************************************/
PROC SQL;
CREATE TABLE ORION_OP.BORDER_UNEMPLOY AS
SELECT * FROM ORION_OP.BORDER_UNEMPLOY_CAN
UNION
SELECT * FROM ORION_OP.BORDER_UNEMPLOY_MEX;
QUIT;

PROC SORT DATA=ORION_OP.BORDER_UNEMPLOY;BY MONTH; RUN;


/**************************************************************************/
/*      MERGING BORDER_UNEMPLOY DATA WITH THE US UNEMPLOYMENT RATE DATA      
****************************************************************************/
DATA ORION_OP.BORDER_UNEMPLOY_FIN;
DROP COUNTRY DATETIME;
MERGE ORION_OP.BORDER_UNEMPLOY(IN=ALL) 
	  ORION_OP.US_UNEMPLOYMENT_UPDATED(IN=ALL); 
BY MONTH GROUPFORMAT;
FORMAT MONTH YYMMN6.;
RUN;

PROC SORT DATA=ORION_OP.BORDER_UNEMPLOY_FIN;BY MONTH; RUN;

/**************************************************************************/
/*    FORMATTING THE DATE COLUMN OF GDP TABLES TO YYYYMM
****************************************************************************/
DATA ORION_OP.US_GDP_MAIN_UPDATED;
SET ORION_OP.US_GDP_MAIN;
FORMAT MONTH YYMMN6.;
RUN;

PROC SORT DATA=ORION_OP.US_GDP_MAIN_UPDATED;BY MONTH; RUN;


/*DELETING THE EMPTY RECORDS*/

DATA ORION_OP.BORDER_UNEMPLOY_FIN_1;
SET ORION_OP.BORDER_UNEMPLOY_FIN;
IF PORT_NAME=' ' THEN DELETE;
RUN;

/**************************************************************************/
/*      MERGING BORDER_UNEMPLOY_FIN DATA WITH THE US_GDP_MAIN_UPDATED DATA      
**************************************************************************/
DATA ORION_OP.BORDER_UNEMPLOY_GDP_FIN(WHERE=(DATE_FORMATTED<'01JAN2019'D));
MERGE ORION_OP.BORDER_UNEMPLOY_FIN_1(IN=ALL) 
	  ORION_OP.US_GDP_MAIN_UPDATED(IN=ALL); 
BY MONTH GROUPFORMAT;
FORMAT MONTH YYMMN6.;
RUN;


