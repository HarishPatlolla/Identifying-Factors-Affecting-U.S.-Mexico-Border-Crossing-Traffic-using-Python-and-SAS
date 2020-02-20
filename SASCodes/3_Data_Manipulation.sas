libname orion 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic';
libname orion_op 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\SAS_Datasets';

DATA ORION_OP.US_MEXICO;
SET ORION_OP.BORDER_UNEMPLOY_GDP_FIN;
IF BORDER='US-Mexico Border' THEN OUTPUT ORION_OP.US_MEXICO;
RUN;

PROC MEANS DATA=ORION_OP.US_MEXICO NMISS;
RUN;

/*REPLACING THE MISSING VALUES WITH THE MEAN*/
PROC STDIZE DATA=ORION_OP.US_MEXICO OUT=ORION_OP.US_MEXICO_IMP METHOD=MEAN REPONLY;
VAR AVG_AVG;
RUN;


               /****************** ********************************************************/ 
                   /* /*CLASSIFYING THE COMMERCIAL AND NON-COMMERCIAL VEHICLES*/
             /******************************************************************************/
DATA ORION_OP.US_MEXICO_COMMERCIAL ORION_OP.US_MEXICO_NONCOMMERCIAL ;
SET ORION_OP.US_MEXICO_IMP;
IF MEASURE='Bus Passengers' OR MEASURE='Pedestrians' OR MEASURE='Personal Vehicle Passengers' 
OR MEASURE='Train Passengers'
THEN OUTPUT  ORION_OP.US_MEXICO_NONCOMMERCIAL;
IF MEASURE='Rail Containers Empty' OR MEASURE='Rail Containers Full' OR MEASURE='Truck Containers Empty' OR 
MEASURE='Truck Containers Full' OR MEASURE='Trucks' THEN OUTPUT ORION_OP.US_MEXICO_COMMERCIAL;
RUN;

/**********************************************************************************************************/
/*************************         COMMERCIAL VEHICLES          ********************************************/
/***********************************************************************************************************'\

/* AGGREGATING THE COUNT OF VEHICLES FOR MEXICO COMMERCIAL VEHICLES*/

PROC SQL;
CREATE TABLE ORION_OP.US_MEXICO_COMMERCIAL_GROUPED AS
			SELECT AVG_AVG, BORDER, DATE_FORMATTED, GDP, LOCATION, MEX_PESO, MONTH,
                    PORT_NAME, STATE, US_UNEMP_RATE, UNEMPLOYMENT_RATE, 
                   SUM(VALUE) AS VEH_COUNT 
            FROM ORION_OP.US_MEXICO_COMMERCIAL
GROUP BY AVG_AVG, BORDER, DATE_FORMATTED, GDP, LOCATION, MEX_PESO, MONTH,
          PORT_NAME, STATE, US_UNEMP_RATE, UNEMPLOYMENT_RATE; 
QUIT;

PROC SQL;
DELETE FROM  ORION_OP.US_MEXICO_COMMERCIAL_GROUPED WHERE VEH_COUNT=0;
QUIT;

PROC SORT DATA=ORION_OP.US_MEXICO_COMMERCIAL_GROUPED; 
BY PORT_NAME MONTH; 
RUN;


/**********************************************************************************************************/
/*************************   NON-COMMERCIAL VEHICLES          ********************************************/
/***********************************************************************************************************'\

/* AGGREGATING THE COUNT OF VEHICLES FOR MEXICO NON-COMMERCIAL VEHICLES*/
PROC SQL;
CREATE TABLE ORION_OP.US_MEXICO_NONCOMMERCIAL_GROUPED AS
			SELECT AVG_AVG, BORDER, DATE_FORMATTED, GDP, LOCATION, MEX_PESO, MONTH,
                    PORT_NAME, STATE, US_UNEMP_RATE, UNEMPLOYMENT_RATE, 
                   SUM(VALUE) AS VEH_COUNT 
            FROM ORION_OP.US_MEXICO_NONCOMMERCIAL
GROUP BY AVG_AVG, BORDER, DATE_FORMATTED, GDP, LOCATION, MEX_PESO, MONTH,
          PORT_NAME, STATE, US_UNEMP_RATE, UNEMPLOYMENT_RATE; 
QUIT;

PROC SQL;
DELETE FROM  ORION_OP.US_MEXICO_NONCOMMERCIAL_GROUPED WHERE VEH_COUNT=0;
QUIT;

PROC SORT DATA=ORION_OP.US_MEXICO_NONCOMMERCIAL_GROUPED;
BY PORT_NAME MONTH; RUN;


               /**************************************************************************************/
               /****************** *******************************************************************/ 
                /* CLASSIFYING THE COMMERCIAL VEHICLES DATA INTO OBAMA AND TRUMP PRESIDENCY */
              /***************************************************************************************/
             /****************************************************************************************/

DATA ORION_OP.US_MEX_COMMERCIAL_OBAMA ORION_OP.US_MEX_COMMERCIAL_TRUMP;
SET ORION_OP.US_MEXICO_COMMERCIAL_GROUPED;
IF DATE_FORMATTED < '01FEB2017'd THEN OUTPUT ORION_OP.US_MEX_COMMERCIAL_OBAMA;
ELSE OUTPUT ORION_OP.US_MEX_COMMERCIAL_TRUMP;
RUN;


/*Deleting the garbage values from Obama dataset*/
PROC SQL;
DELETE FROM  ORION_OP.US_MEX_COMMERCIAL_OBAMA WHERE BORDER IS NULL;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_COMMERCIAL_OBAMA
	WHERE  PORT_NAME='otay mesa' AND INPUT(PUT(MONTH,YYMMN6.),8.)=201709
/*TRIM(PUT(MONTH,8.))='201709'*/
AND AVG_AVG=62.93;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_COMMERCIAL_OBAMA
	WHERE  PORT_NAME='lukeville' ;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_COMMERCIAL_OBAMA
	WHERE PORT_NAME='presido' OR PORT_NAME='san luis'  ;
QUIT;


/*Deleting the garbage values from Trump dataset*/
PROC SQL;
DELETE FROM  ORION_OP.US_MEX_COMMERCIAL_TRUMP WHERE BORDER IS NULL;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_COMMERCIAL_TRUMP
	WHERE  PORT_NAME='otay mesa' AND INPUT(PUT(MONTH,YYMMN6.),8.)=201709
/*TRIM(PUT(MONTH,8.))='201709'*/
AND AVG_AVG=62.93;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_COMMERCIAL_TRUMP
	WHERE  PORT_NAME='lukeville' ;
QUIT;

PROC SQL;
DELETE FROM ORION_OP.US_MEX_COMMERCIAL_TRUMP
	WHERE PORT_NAME='presido' OR PORT_NAME='san luis'  ;
QUIT;


                    /****************** ********************************************************/ 
                   /* CLASSIFYING THE MEXICO NON-COMMERCIAL VEHICLE DATA INTO OBAMA AND TRUMP PRESIDENCY */
                   /******************************************************************************/


DATA ORION_OP.US_MEX_NONCOMMERCIAL_OBAMA ORION_OP.US_MEX_NONCOMMERCIAL_TRUMP;
SET ORION_OP.US_MEXICO_NONCOMMERCIAL_GROUPED;
IF DATE_FORMATTED < '01FEB2017'd THEN OUTPUT ORION_OP.US_MEX_NONCOMMERCIAL_OBAMA;
ELSE OUTPUT ORION_OP.US_MEX_NONCOMMERCIAL_TRUMP;
RUN;
