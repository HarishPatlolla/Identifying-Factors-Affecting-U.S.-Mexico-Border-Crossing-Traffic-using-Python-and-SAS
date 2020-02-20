libname orion 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic';
libname orion_op 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\SAS_Datasets';

/**************************************************************************/
/*     IMPORTING THE BORDER TRAFFIC MAIN FILE                               /
****************************************************************************/

PROC IMPORT OUT=ORION_OP.BORDER_TRAFFIC_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\BORDER_CROSSING_ENTRY_DATA.CSV'
DBMS = CSV;
GETNAMES = YES;
RUN;

/**************************************************************************/
/*      IMPORTING THE WEATHER FILE                                       /
****************************************************************************/
PROC IMPORT OUT=ORION_OP.WEATHER_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\WEATHER_SYMPOSIUM.XLSX'
DBMS = XLSX;
GETNAMES = YES;
RUN;

/**************************************************************************/
/*      IMPORTING THE WEATHER URL FILE                                       /
****************************************************************************/
PROC IMPORT OUT=ORION_OP.URL
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\WEATHER_URL.XLSX'
DBMS = XLSX;
GETNAMES = YES;
RUN;


/**************************************************************************/
/*      IMPORTING THE EXCHANGE RATE DATA                                        /
****************************************************************************/

PROC IMPORT OUT=ORION_OP.EXCHANGERATE_MEXICO_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\EXCHANGE_FIN.CSV'
DBMS = CSV;
GETNAMES = YES;
RUN;



/**************************************************************************/
/*      IMPORTING THE CANADA UNEMPLOYMENT DATA                           /
****************************************************************************/

PROC IMPORT OUT=ORION_OP.CANADA_UNEMPLOYMENT_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\CANADA_UNEMPLOYMENT_RATE_CLEANED.CSV'
DBMS = CSV;
GETNAMES = YES;
RUN;


/**************************************************************************/
/*      IMPORTING THE MEXICO UNEMPLOYMENT DATA                           /
****************************************************************************/

PROC IMPORT OUT=ORION_OP.MEXICO_UNEMPLOYMENT_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\MEXICO_UNEMPLOYMENT_RATE_CLEANED.CSV'
DBMS = CSV;
GETNAMES = YES;
RUN;



/**************************************************************************/
/*      IMPORTING THE US UNEMPLOYMENT DATA                           /
****************************************************************************/

PROC IMPORT OUT=ORION_OP.US_UNEMPLOYMENT_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\US_UNEMPLOYMENT_RATE.XLSX'
DBMS = EXCEL;
GETNAMES = YES;
RUN;

/**************************************************************************/
/*      IMPORTING THE GDP DATA                           /
****************************************************************************/

PROC IMPORT OUT=ORION_OP.US_GDP_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\US_GDP.XLSX'
DBMS = EXCEL;
GETNAMES = YES;
RUN;



/**************************************************************************/
/*      IMPORTING THE ARTICLES DATA                                        /*/
/*****************************************************************************/

PROC IMPORT OUT=ORION_OP.ARTICLES_MAIN
DATAFILE = 'D:\SUNNY_PERSONAL\OSU MSBA\FALL 2019\SYMPOSIUM\BORDER-TRAFFIC\SYMPOSIUM_MEDIAARTICLES.XLSX'
DBMS = EXCEL;
GETNAMES = YES;
RUN;

