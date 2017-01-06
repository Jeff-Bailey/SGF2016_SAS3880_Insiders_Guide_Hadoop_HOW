/************************************************************/
/* Exercise 00 - SAS3880                                    */
/* An Insider's Guide to SAS/ACCESS to Hadoop               */
/*                                                          */
/* This is a very basic LIBNAME statement test.             */
/* It is not a trick. It should work.                       */
/************************************************************/

libname mycdh hadoop server='quickstart.cloudera' 
                     user=cloudera password=cloudera;
