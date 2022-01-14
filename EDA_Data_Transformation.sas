proc import datafile = '/home/u57978559/sasuser.v94/heartfailure.csv'
out = work.heart
dbms = csv
;
run;

proc print data =work.heart;
run;

proc contents data=work.heart; run;


/*IDE Correlation*/
proc corr data=WORK.HEART pearson nosimple noprob plots=none;
	var creatinine_phosphokinase serum_creatinine serum_sodium;
	with DEATH_EVENT;
run;

/*to display all missing values of character type data*/
proc freq data=WORK.HEART;
	
	format _char_  _nmissprint.;
	tables _char_  / missing nocum;
run;

/*to display all missing values of numerical data*/\
proc freq data=WORK.HEART;
	
	format _numeric_  _nmissprint.;
	tables _numeric_  / missing nocum;
run;

/*summary statistics of numeric dataset*/
proc means data=WORK.HEART chartype mean std min max median n vardef=df 
		qmethod=os;
	var _numeric_;
run;

/*summarizes all the missing values for each variable*/
proc means data=WORK.HEART  nmiss 
		range vardef=df qmethod=os;
	var _numeric_;
run;


/*to find summary statistics by inputting column name*/
proc means data=WORK.HEART chartype mean std min max median n nmiss var mode 
		range vardef=df qmethod=os;
	var creatinine_phosphokinase ejection_fraction platelets serum_creatinine 
		serum_sodium age anaemia diabetes high_blood_pressure sex smoking time 
		DEATH_EVENT;
run;
/*to plot the frequency distribution histogram of each column*/
proc univariate data=WORK.HEART vardef=df noprint;
	var creatinine_phosphokinase ejection_fraction platelets serum_creatinine 
		serum_sodium age anaemia diabetes high_blood_pressure sex smoking time 
		DEATH_EVENT;
	histogram creatinine_phosphokinase ejection_fraction platelets 
		serum_creatinine serum_sodium age anaemia diabetes high_blood_pressure sex 
		smoking time DEATH_EVENT / normal(noprint);
run;

/*frequency of each categorical variables*/
proc freq data=WORK.HEART;
	tables anaemia age diabetes high_blood_pressure sex smoking DEATH_EVENT / 
		plots=(freqplot cumfreqplot);
run;

/*remember to bin values with missing value and all*/

/*FROM HERE ON ALL PRE-PROCESSING*/

/*Below is to replace missing values with the specific mode value of categorical data, based on summary table*/

proc stdize data=work.heart
	out=work.heart
	reponly missing=1;
        var sex ;
run;

proc freq data=WORK.HEART;
   tables sex ;
run;

proc stdize data=work.heart
	out=work.heart
	reponly missing=0;
        var diabetes ;
run;

proc stdize data=work.heart
	out=work.heart
	reponly missing=0;
        var smoking ;
run;

/*Now use mean to replace all the missing values of numerical data*/
proc stdize data=work.heart
	out=work.heart
	reponly method=mean;
        var creatinine_phosphokinase ejection_fraction platelets serum_creatinine serum_sodium time ;
run;

/*now run this chunk again for summarizing all the missing values*/
proc means data=WORK.HEART  nmiss 
		range vardef=df qmethod=os;
	var _numeric_;
run;


/*using if - then logic to relabel sex column to gender in the form of male and female.*/
data WORK.HEART;
set WORK.HEART;

length Gender $6;
if      sex = 0 then Gender = "Male";
else if sex = 1 then Gender = "Female";
else Gender = " ";
run;
 
proc freq data=WORK.HEART;
   tables sex Gender;
run;

/*The same method to transform other categorical values are done here*/
data WORK.HEART;
set WORK.HEART;

length anaemic_presence $20;
if      anaemia = 0 then anaemic_presence = "Not anaemic";
else if anaemia = 1 then anaemic_presence = "Anaemic";
else anaemic_presence = " ";
run;
 
proc freq data=WORK.HEART;
   tables anaemia anaemic_presence;
run;

data WORK.HEART;
set WORK.HEART;

length diabetes_presence $20;
if      diabetes = 0 then diabetes_presence = "Non diabetic";
else if diabetes = 1 then diabetes_presence = "Diabetic";
else diabetes_presence = " ";
run;
 
proc freq data=WORK.HEART;
   tables diabetes diabetes_presence;
run;


data WORK.HEART;
set WORK.HEART;

length hypertension $20;
if      high_blood_pressure = 0 then hypertension = "Non-hypertension";
else if high_blood_pressure = 1 then hypertension = "Hypertension";
else hypertension = " ";
run;
 
proc freq data=WORK.HEART;
   tables high_blood_pressure hypertension;
run;

data WORK.HEART;
set WORK.HEART;

length smoker_label $20;
if      smoking = 0 then smoker_label = "Non-smoker";
else if smoking = 1 then smoker_label = "Smoker";
else smoker_label = " ";
run;
 
proc freq data=WORK.HEART;
   tables smoking smoker_label;
run;

data WORK.HEART;
set WORK.HEART;

length patient_death $20;
if      DEATH_EVENT = 0 then patient_death = "Survive";
else if DEATH_EVENT = 1 then patient_death = "Deceased";
else smoker_label = " ";
run;
 
proc freq data=WORK.HEART;
   tables DEATH_EVENT patient_death;
run;

/*outlier detection, skewness*/
proc univariate data=work.heart robustscale plot;
var creatinine_phosphokinase serum_creatinine platelets ejection_fraction serum_sodium age time ;
run;

/*Transform data using log transform for skewed data */
data work.transform;
	set WORK.HEART;
	log_creatinine_phosphokinase=log(creatinine_phosphokinase);
	log_serum_creatinine=log(serum_creatinine);
	log_platelets=log(platelets);
run;

proc print data=work.transform(obs=10);
	title "Transformed data set - work.transform";
run;
/*Now check skewness and plot of log transformed data*/
proc univariate data=work.transform robustscale plot;
var log_creatinine_phosphokinase log_serum_creatinine log_platelets;
run;

/*EDA parts*/

/*first do summary stats for clean and transformed data*/
proc means data=WORK.TRANSFORM chartype mean std min max n vardef=df skewness 
		kurtosis;
	var creatinine_phosphokinase ejection_fraction platelets serum_creatinine 
		serum_sodium age  time 
		 log_creatinine_phosphokinase log_serum_creatinine log_platelets;
run;

proc univariate data=WORK.TRANSFORM vardef=df noprint;
	var creatinine_phosphokinase ejection_fraction platelets serum_creatinine 
		serum_sodium age  time 
		 log_creatinine_phosphokinase log_serum_creatinine log_platelets;
	histogram creatinine_phosphokinase ejection_fraction platelets serum_creatinine 
		serum_sodium age  time 
		 log_creatinine_phosphokinase 
		log_serum_creatinine log_platelets / normal(noprint);
run;

proc freq data=WORK.TRANSFORM;
   tables _char_;
run;
