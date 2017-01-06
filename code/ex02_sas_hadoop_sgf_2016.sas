/************************************************************/
/* Exercise 02 - SAS3880                                    */
/* An Insider's Guide to SAS/ACCESS to Hadoop               */
/*                                                          */
/* Explore Hive tables, HDFS files, and how they relate.    */
/************************************************************/

/******************************************************************/
/* We used to have to do this type of thing... now we don't       */
/* filename cfg 'C:\SAS_HADOOP_CONFIG_PATH\core-hdfs-merged.xml'; */
/******************************************************************/

/***********************************************/
/* Setup the Cloudera environment              */
/* PROC HADOOP is great for setup and clean up */
/***********************************************/

/*********************************************************/
/* - create a directory in the Hadoop File System (HDFS) */
/* - copy a file to HDFS                                 */
/*********************************************************/
proc hadoop username="cloudera" verbose;
   HDFS mkdir='/user/cloudera/textfile';
   HDFS copyfromlocal='C:\HOW\bailey\data\sgf_characters.txt'
                  out='/user/cloudera/textfile/sgf_characters.txt';
run;

/***************************************************/
/* Locate the HDFS file using the HUE file browser */
/* and login                                       */
/*                                                 */
/* http://quickstart.cloudera:8888                 */
/* cloudera/cloudera                               */
/***************************************************/

/******************************************************************/
/* Display the contents of the  sgf_characters.txt file using SAS */
/******************************************************************/

/********************************************************/
/* Open core-hdfs-merged.xml using NOTEPAD.             */
/* What do you think the purpose of the file is?        */
/* Why do you think SAS requires the file?              */
/* Where does the sgf_characters.txt file live?         */
/********************************************************/

filename sgftext hadoop '/user/cloudera/textfile/sgf_characters.txt' user=cloudera; 

data _null_;
   infile sgftext;
   input mycharacter $1.;
   put mycharacter;
run;

/**************************/
/* Using ACCESS to Hadoop */
/**************************/

/*****************************************/
/* Create a table using ACCESS to Hadoop */
/*****************************************/
proc sql;
   connect to hadoop(server='quickstart.cloudera' user=cloudera);
   execute (create external table mytext(c1 varchar(1))
               stored as textfile
               location '/user/cloudera/textfile') by hadoop;
quit;

/* let's verify that the table is there and SAS can read it. */

libname mycdh hadoop server='quickstart.cloudera' user=cloudera;
options fullstimer;

/***********************************************/
/* We created a table but did not load it.     */
/* - Where did the data come from?             */
/***********************************************/
proc sql;
   connect to hadoop(server='quickstart.cloudera' user=cloudera);
   select count(*) from connection to hadoop
      (select * from mytext);
quit;

/************************************************************/
/* Let's ask the same question in a slightly different way. */
/* - Passing the count() function to Hadoop should make     */
/*   the query perform better, right?                       */
/* - Do the results match your expectations?                */
/* - Why is there a performance difference?                 */
/************************************************************/
proc sql;
   connect to hadoop(server='quickstart.cloudera' user=cloudera);
   select * from connection to hadoop
      (select count(*) from mytext);
quit;

/* Why is the second version is much faster. Point out that */
/* the count(*) was passed to Hive. Or was it? How do we know?    */
/* Revisit this. It will keep their attention.                    */

/******************************************/
/* Drop the table.                        */
/* - What happens to the HDFS file?       */
/* - Why would this behavior be valuable? */
/******************************************/ 

proc sql;
   drop table mycdh.mytext;
quit;

/**************************************************************************/
/* View the mycdh library in SAS Explorer to make sure the table is gone. */
/**************************************************************************/

/*******************************************************/
/* Run the DATA step again.                            */
/* - Does the DATA step work? If so, why? If not, why? */
/*******************************************************/
data _null_;
   infile sgftext;
   input mycharacter $1.;
   put mycharacter;
run;

/*************************************************/
/* delete the textfile HDFS directory.           */
/* What happens to the sgf_characters.txt file?  */
/*************************************************/

proc hadoop username="cloudera" verbose;
   HDFS delete='/user/cloudera/textfile';
run;

/*************************************************/
/* Now for something really interesting...       */
/* Run the following code describe what happens. */
/* - Why is this a big deal?                     */
/*************************************************/

proc hadoop username="cloudera" verbose;
   HDFS mkdir='/user/cloudera/digitsfile';
   HDFS copyfromlocal='C:\HOW\bailey\data\sgf_digits.txt'
                  out='/user/cloudera/digitsfile/sgf_digits.txt';
run;

proc sql;
   connect to hadoop(server='quickstart.cloudera' user=cloudera);
   execute (create table mydigits(myint int)
               stored as textfile
               location '/user/cloudera/digitsfile') by hadoop;
quit;

proc sql;
   select * from mycdh.mydigits;
quit;

/*************************************************************/
/* If this works it may help you see what this is a big deal */
/*************************************************************/

filename sgfdigit hadoop '/user/cloudera/digitsfile/sgf_digits.txt' user=cloudera; 

data _null_;
   infile sgfdigit;
   input mydigits $1.;
   put mydigits;
run;

/************/
/* Clean up */
/************/

proc sql;
    drop table mycdh.mydigits;
quit;

/*******************/
/* End Exercise 02 */
/*******************/