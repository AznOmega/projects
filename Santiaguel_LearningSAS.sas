*this file is a personal learning sheet for use by Lanz Santiaguel to add or edit as they learn SAS*;

data class_report;
	set sashelp.class;
run;

*sort procedure and means procudere to create summary statistics of sashelp.class*;
proc sort data=class_report;
	by Sex;
run;

proc means data=class_report chartype mean std min max n vardef=df;
	var Age Height Weight;
	by Sex;
run;

*add column and learning how to use retain statements*;
data class_report_new;
   set sashelp.class;
   if sex = "M" then delete;
   
   if age = 12 AND height < 60.6 then Average = "Below" ;
   if age = 13 AND height < 61.8 then Average = "Below";
   if age = 14 AND height < 62.6 then Average = "Below";
   if age = 15 AND height < 63.4 then Average = "Below";
   if age = 16 AND height < 63.8 then Average = "Below";

   else if age = 12 AND height > 60.6 then Average = "Taller" ;
   else if age = 13 AND height > 61.8 then Average = "Taller";
   else if age = 14 AND height > 62.6 then Average = "Taller";
   else if age = 15 AND height > 63.4 then Average = "Taller";
   else if age = 16 AND height > 63.8 then Average = "Taller";
   
   if age = 11 then Average = "Young";
run;

data class_report_EX;
   set class_report_new;
   *calculates total height for all girls in dataset*;
   retain total 0; 
   total = total + height;
run;




