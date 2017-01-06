/***************************************************************/
/* Exercise 06 - SAS3880                                       */
/* An Insider's Guide to SAS/ACCESS to Hadoop                  */
/*                                                             */
/* In-Database PROC Example                                    */
/***************************************************************/

libname mycdh hadoop server='quickstart.cloudera' user=cloudera password=cloudera schema='default';

data mycdh.class;
   set sashelp.class;
run;

/**************************************************/
/* Run RANK procedure in-database                 */
/* How can you tell it was processed in-database? */
/**************************************************/
options sastrace=',,,d' sastraceloc=saslog nostsuffix;

/**********************************/
/* By default it runs in-database */
/**********************************/
proc rank data=mycdh.class out=work.class_rank;
  by descending weight;
run;

/****************************************/
/* You can turn it off.                 */
/* But you probably should not do that. */
/****************************************/
options sqlgeneration=(DBMS EXCLUDEDB='HADOOP');

proc rank data=mycdh.class out=work.class_rank;
  by descending weight;
run;

proc print data=work.class_rank;
run;

/************/
/* Clean up */
/************/
proc sql;
   drop table work.class_rank; 
   drop table mycdh.class;
quit;

/*******************/
/* End Exercise 06 */
/*******************/

