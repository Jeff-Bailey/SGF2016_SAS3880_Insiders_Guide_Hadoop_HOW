/***************************************************************/
/* Exercise 05 - SAS3880                                       */
/* An Insider's Guide to SAS/ACCESS to Hadoop                  */
/*                                                             */
/* 32k string thing                                            */
/***************************************************************/

/* setup the environment  */
/* Copy single_string_column.txt to HDFS. */
proc hadoop username="cloudera" verbose;
   HDFS COPYFROMLOCAL="C:\HOW\bailey\data\single_string_column.txt" 
                  OUT='/user/cloudera/letters/single_string_column.txt';
run;

proc sql;
   connect to hadoop (server='quickstart.cloudera' user=cloudera password=cloudera);
   execute (create table letters (single_character string)
            row format delimited fields terminated by ','
            location '/user/cloudera/letters') by hadoop;
   disconnect from hadoop;
quit;

/********************************************************/
/* How many rows (a single character) are in the table? */
/********************************************************/
libname mycdh hadoop server='quickstart.cloudera' user=cloudera password=cloudera;

proc sql;
   select count(*) from mycdh.letters;
quit;

/****************************************************************/
/* Using implicit pass-thru, create a SAS data set from letters */
/****************************************************************/

data work.letters;
   set mycdh.letters;
run;

/***********************************************************/
/* Before they added the warning, this was a lot more fun. */
/* How big is the work.letters data set?                   */
/* Does the size (180 characters) seem reasonable?         */
/***********************************************************/
proc datasets library=work;
quit;

/****************/
/* Let's fix it */
/****************/
proc sql;
   connect to hadoop (server='quickstart.cloudera' user=cloudera password=cloudera);
   execute (alter table letters set tblproperties ('SASFMT:single_character'='CHAR(1)')) by hadoop;
quit;

/******************************/
/* Did the ALTER TABLE fix it */
/******************************/
data work.letters_fixed;
   set mycdh.letters;
run;

proc datasets library=work;
quit;

/*****************************************/
/* Now for something completly different */
/*****************************************/

data mycdh.letters_implicit (drop=i);
   do i = 1 to 180;
      single_character='a'; output;
   end;
run;

/********************************************************************/
/* copy the new table from Hive into Hadoop and check the file size */
/*                                                                  */
/* How large is the resulting work.letters_implicit                 */
/* SAS data set? Guess then run the following code.                 */
/********************************************************************/
data work.letters_implicit;
   set mycdh.letters_implicit;
run;

proc datasets library=work;
quit;

/********************/
/* Why did it work? */
/********************/
proc sql;
   connect to hadoop (server='quickstart.cloudera' user=cloudera password=cloudera);
   select * from connection to hadoop 
      (describe formatted letters_implicit);
   disconnect from hadoop;
quit;

/************************************************************/
/* Do you see it?                                           */
/* Checkout the data type for the single_character column.  */
/* It's funny that the above code generates the 32k message */
/************************************************************/

/************/
/* Clean up */
/************/
proc sql;
   drop table work.letters;
   drop table work.letters_fixed;
   drop table work.letters_implicit;
   drop table mycdh.letters;
   drop table mycdh.letters_implicit;
quit;

/*******************/
/* End Exercise 05 */
/*******************/

