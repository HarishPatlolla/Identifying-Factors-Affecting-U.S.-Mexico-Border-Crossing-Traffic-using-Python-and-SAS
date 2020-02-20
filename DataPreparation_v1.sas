libname orion 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic';
libname orion_op 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\SAS_Datasets';

/**************************************************************************/
/*     Importing the Border Traffic Main file                               /
****************************************************************************/

proc import out=orion_op.Border_Traffic
datafile = 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\Border_Crossing_Entry_Data.csv'
dbms = csv;
getnames = yes;
run;

/**************************************************************************/
/*   subsetting the required columns and formatting the date columns 
****************************************************************************/

DATA orion_op.Border_Traffic_formatted(where=(Month1>='01JAN2009'd));
SET orion_op.Border_Traffic;
keep Port_Name State Border  Measure Value Month Month1;
Port_Name=lowcase(Port_Name);
Month1=datepart(Date);
Month = datepart(Date);
format Month yymmn6.;
format Month1 yymmdd9.;
RUN;


/**************************************************************************/
/*      Importing the Weather file                                       /
****************************************************************************/
proc import out=orion_op.Weather
datafile = 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\weather_symposium.xlsx'
dbms = xlsx;
getnames = yes;
run;

/**************************************************************************/
/*      Importing the Weather url file                                       /
****************************************************************************/
proc import out=orion_op.url
datafile = 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\weather_url.xlsx'
dbms = xlsx;
getnames = yes;
run;


/**************************************************************************/
/*      MERGING weather data with url data to tag the portnames       
****************************************************************************/

PROC SQL;
CREATE TABLE orion_op.weather_merge as
select a.Month,a.Url,a.Avg_Avg,b.Port_Name,b.State from 
		orion_op.Weather a join orion_op.Url b on a.Url=b.URL;
quit;

/**************************************************************************/
/*    subsetting the required columns and formatting the date column
****************************************************************************/
DATA orion_op.Weather_formatted;
SET orion_op.weather_merge;
Port_Name=lowcase(Port_Name);
keep Month_format Port_Name Avg_Avg State Url;
Month_format =input(Month, anydtdte21.);
format Month_format yymmn6.;
RUN;


/**************************************************************************/
/*      MERGING BORDER TRAFFIC WITH THE WEATHER DATA      
****************************************************************************/

PROC SQL;
CREATE TABLE orion_op.Border_Traffic_merge_1 as
select a.*,b.avg_avg,b.Url from orion_op.Border_Traffic_formatted a
							left join orion_op.Weather_formatted b
							on a.Port_Name=b.Port_Name
							and a.Month=b.Month_format;
quit;


/**************************************************************************/
/*      Importing the exchange rate data                                        /
****************************************************************************/

proc import out=orion_op.exchangerate
datafile = 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\Exchange_fin.csv'
dbms = csv;
getnames = yes;
run;


DATA orion_op.exchangerate1;
SET orion_op.exchangerate;
Month1=datepart(Month);
format Month1 yymmn6.;
RUN;

/**************************************************************************/
/*      MERGING BORDER TRAFFIC WITH THE exchange DATA      
****************************************************************************/

proc contents data=orion_op.exchangerate1;
run;

PROC SQL;
CREATE TABLE orion_op.Border_Traffic_merge_2 as
select a.*,b._MXN_Peso 
from orion_op.Border_Traffic_merge_1 a
							left join orion_op.exchangerate1 b
							on a.Month=b.Month1
and a.Border='US-Mexico Border';
quit;


data orion_op.US_Canada orion_op.US_Mexico;
set orion_op.Border_Traffic_merge_1;
if Border='US-Mexico Border' then output orion_op.US_Mexico;
else output orion_op.US_Canada;
run;


/**************************************************************************/
/*      Importing the articles data                                        /
****************************************************************************/

proc import out=orion.articles
datafile = 'D:\Sunny_Personal\OSU MSBA\Fall 2019\Symposium\Border-Traffic\Symposium_MediaArticles.xlsx'
dbms = Excel;
getnames = yes;
run;



/**************************************************************************/
/*       Merging Border Traffic with Weather Data                           /
****************************************************************************/


/*Grouping the text*/
proc sort data=ARTICLES_SUBSETTED;
by Date;run;

Data articles_group ;
format Combined_Articles $20000. ;
set ARTICLES_SUBSETTED ;
by Date;
if first.Date then CombinedVar2 = Article_Text ;
CombinedVar2 = Catx(" - ",CombinedVar2, Article_Text) ;
run;
proc print data=articles_group;
run;

 
