/***************************************************************/
/* Exercise 04 - SAS3880                                       */
/* An Insider's Guide to SAS/ACCESS to Hadoop                  */
/*                                                             */
/* Explore BULKLOAD=                                           */
/***************************************************************/

/****************************************************************/
/* First:  bulkload=yes the sashelp.cars SAS data set into CDH  */
/* Second: bulkload=no sashelp.cars and compare to first.       */
/* Third:  bulkload=yes sashelp.cars underlying parquet file.   */
/****************************************************************/

libname mycdh hadoop server="quickstart.cloudera" user=cloudera password=cloudera;
options sastrace=',,,d' sastraceloc=saslog nostsuffix;

/* First we bulk load then we run a non-load append */

/**************************************************************************/
/* The following warning occurs because the cars data set has in index    */
/* defined on it. You can ignore it.                                      */
/*                                                                        */
/* WARNING: Engine HADOOP does not support SORTEDBY operations.  SORTEDBY */
/*          information cannot be copied.                                 */
/**************************************************************************/

proc append base=mycdh.cars (bulkload=yes)
            data=sashelp.cars;
run;

/****************************/
/* clean up so we can rerun */
/****************************/
proc sql;
   drop table mycdh.cars;
quit;

/*************************************************************/
/* How does bulkloading differ from non-bulkload loading?    */
/*************************************************************/

proc append base=mycdh.cars
            data=sashelp.cars;
run;

/****************************/
/* clean up so we can rerun */
/****************************/
proc sql;
   drop table mycdh.cars;
quit;

/*********************************************/
/* Is loading into a parquet file different? */
/*********************************************/

proc append base=mycdh.cars (dbcreate_table_opts='stored as parquetfile')
            data=sashelp.cars;
run;

/************/
/* Clean up */
/************/
proc sql;
   drop table mycdh.cars;
quit;


/*******************/
/* End Exercise 04 */
/*******************/
