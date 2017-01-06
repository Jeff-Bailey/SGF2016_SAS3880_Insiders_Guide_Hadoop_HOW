/***************************************************************/
/* Exercise 03 - SAS3880                                       */
/* An Insider's Guide to SAS/ACCESS to Hadoop                  */
/*                                                             */
/* Explore CREATE TABLE AS and multi-libname Join Processing   */
/***************************************************************/

/***********************************************/
/* Setup the Cloudera environment              */
/* Move data from SASHELP to CDH               */
/* Create schemas using explicit pass-thru     */
/* CTAS - CREATE TABLE AS                      */
/***********************************************/

/* create the test tables */
/* Create two simple tables */
libname cdh hadoop server="quickstart.cloudera" user=cloudera password=cloudera;

data cdh.table1;
   x=3; output;
   x=2; output;
   x=1; output;
run;

data cdh.table2;
   x=3; y=3.3; z='three'; output;
   x=2; y=2.2; z='two'; output;
   x=1; y=1.1; z='one'; output;
   x=4; y=4.4; z='four'; output;
   x=5; y=5.5; z='five'; output;
run;

/****************************************/
/* verify that both tables were created */
/****************************************/

/******************************************************/
/* TEST: change the following line to display the SQL */
/* that is being passed to Hive.                      */
/*                                                    */
/* type in correct code and submit it.                */
/******************************************************/
* options ???????=',,,d' sastraceloc=?????? nostsuffix;
options sastrace=',,,d' sastraceloc=saslog nostsuffix;

/* single schema join - does Hive process the join? */
proc sql;
   select t1.x, t2.y, t2.z
     from cdh.table1 t1
        , cdh.table2 t2
    where t1.x=t2.x;
quit; 

/****************************************************/
/* multi-LIBNAME join                               */
/*    - does Hive process the join?                 */
/*    - if not, why?                                */
/****************************************************/

libname cdh1 hadoop server="quickstart.cloudera" user=cloudera password=cloudera;
libname cdh2 hadoop server="quickstart.cloudera" user=cloudera password=cloudera;

proc sql;
   select t1.x, t2.y, t2.z
     from cdh1.table1 t1
        , cdh2.table2 t2
    where t1.x=t2.x;
quit; 

/****************************************************/
/* multi-LIBNAME join                               */
/*    - does Hive process the join?                 */
/*    - if not, why?                                */
/****************************************************/
libname cdh1 hadoop server="quickstart.cloudera" ;
libname cdh2 hadoop server="quickstart.cloudera"  user=cloudera password=cloudera;

proc sql;
   select t1.x, t2.y, t2.z
     from cdh1.table1 t1
        , cdh2.table2 t2
    where t1.x=t2.x;
quit; 

/****************************************************/
/* multi-LIBNAME join                               */
/*    - does Hive process the join?                 */
/*    - if not, why?                                */
/****************************************************/
libname cdh1 hadoop server="quickstart.cloudera" ;
libname cdh2 hadoop server="quickstart2.cloudera" ;

proc sql;
   select t1.x, t2.y, t2.z
     from cdh1.table1 t1
        , cdh2.table2 t2
    where t1.x=t2.x;
quit; 

/**************************/
/* Setup Multischema Test */
/**************************/

/***************************************/
/* create two Hive schemas for testing */
/***************************************/
proc sql;
   connect to hadoop (server="quickstart.cloudera" user=cloudera password=cloudera);
   execute(create schema schema1) by hadoop;
   execute(create schema schema2) by hadoop;
quit;

/************************************************/
/* CREATE TABLE AS                              */
/*   - view the SQL that is passed to Hive and  */
/*     describe how they are different.         */
/*   - which is better?                         */
/************************************************/
libname cdhsch1 hadoop server="quickstart.cloudera" user=cloudera password=cloudera schema=schema1;
libname cdhsch2 hadoop server="quickstart.cloudera" user=cloudera password=cloudera schema=schema2;

options dbidirectexec;
proc sql;
   create table cdhsch1.table1 as select * from cdh.table1;
quit;

options nodbidirectexec;
proc sql;
   create table cdhsch2.table2 as select * from cdh.table2;
quit;

/****************************************************/
/* multi-LIBNAME multi-SCHEMA join                  */
/*    - do you think Hive will process the join     */
/*      when SCHEMA= values are different?          */
/****************************************************/

libname cdhsch1 hadoop server="quickstart.cloudera" user=cloudera password=cloudera schema=schema1;
libname cdhsch2 hadoop server="quickstart.cloudera" user=cloudera password=cloudera schema=schema2;

proc sql;
   select t1.x, t2.y, t2.z
     from cdh1.table1 t1
        , cdh2.table2 t2
    where t1.x=t2.x;
quit; 

/************/
/* Clean up */
/************/
proc sql;
    drop table cdh.table1;
	drop table cdh.table2;
    drop table cdhsch1.table1;
	drop table cdhsch2.table2;
quit;

/*********************/
/* drop Hive schemas */
/*********************/
proc sql;
   connect to hadoop (server="quickstart.cloudera" user=cloudera password=cloudera);
   execute(drop schema schema1) by hadoop;
   execute(drop schema schema2) by hadoop;
quit;


/*******************/
/* End Exercise 03 */
/*******************/
