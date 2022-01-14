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
data work.heart;
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
   tables _char_ _numeric_ ;
run;


/*FEATURE ENGINEERING PART*/

/*Binning of ejection fraction to ranges and indicators*/

data work.heart;
set work.heart;

length EF_indicator $ 20;
if ejection_fraction < 41 then EF_indicator = 'Low';
else if ejection_fraction >= 41 and ejection_fraction <= 49 then EF_indicator = 'Borderline';
else if ejection_fraction > 49 and ejection_fraction <= 75 then EF_indicator = 'Normal';
else if ejection_fraction > 75 then EF_indicator = 'High';
run;




/*Binning of serum creatinine to ranges*/
data work.heart;
set work.heart;

length SC_indicator $ 20;
if serum_creatinine < 0.84 then SC_indicator = 'Low';
else if serum_creatinine >= 0.84 and serum_creatinine <= 1.21 then SC_indicator = 'Normal';
else if serum_creatinine > 1.21 then SC_indicator = 'High';
run;

/*Binning of creatinine phosphokinase*/
data work.heart;
set work.heart;

length CPK_indicator $ 20;
if creatinine_phosphokinase < 10 then CPK_indicator = 'Low';
else if creatinine_phosphokinase >= 10 and creatinine_phosphokinase <= 120 then CPK_indicator = 'Normal';
else if creatinine_phosphokinase > 120 then CPK_indicator = 'Elevated';
run;

/*Binning of age*/
data work.heart;
set work.heart;

length Age_group $ 20;
if age <= 12 then Age_group = 'Children';
else if age >12 and age <= 18 then Age_group = 'Teenager';
else if age > 18 and age <=35 then Age_group = 'Young Adult';
else if age >35 and age <60 then Age_group = 'Adult';
else if age >= 60 then Age_group = 'Senior';
run;



/*one hot encoding*/
/*new columns for categories added, number of columns based on instances possible*/
proc sql;
ALter table work.heart
add EF_indicator1 int
add EF_indicator2 int
add EF_indicator3 int
add EF_indicator4 int

add SC_indicator1 int
add SC_indicator2 int
add SC_indicator3 int
 
add CPK_indicator1 int
add CPK_indicator2 int
add CPK_indicator3 int

add Age_group1 int
add Age_group2 int
add Age_group3 int
add Age_group4 int
add Age_group5 int;

QUIT;

/*one hot encoding for ejection fraction*/
data work.heart;
set work.heart;
if EF_indicator = 'Low' then EF_indicator1 = "1";
else EF_indicator1 = "0";
run;

data work.heart;
set work.heart;
if EF_indicator = 'Borderline' then EF_indicator2 = "1";
else EF_indicator2 = "0";
run;

data work.heart;
set work.heart;
if EF_indicator = 'Normal' then EF_indicator3 = "1";
else EF_indicator3 = "0";
run;

data work.heart;
set work.heart;
if EF_indicator = 'High' then EF_indicator4 = "1";
else EF_indicator4 = "0";
run;

/*one hot encoding for Serum Creatinine*/
data work.heart;
set work.heart;
if SC_indicator = 'Low' then SC_indicator1 = "1";
else SC_indicator1 = "0";
run;

data work.heart;
set work.heart;
if SC_indicator = 'Normal' then SC_indicator2 = "1";
else SC_indicator2 = "0";
run;

data work.heart;
set work.heart;
if SC_indicator = 'High' then SC_indicator3 = "1";
else SC_indicator3 = "0";
run;

/*one hot encoding for Creatinine Phosphokinase*/
data work.heart;
set work.heart;
if CPK_indicator = 'Low' then CPK_indicator1 = "1";
else CPK_indicator1 = "0";
run;

data work.heart;
set work.heart;
if CPK_indicator = 'Normal' then CPK_indicator2 = "1";
else CPK_indicator2 = "0";
run;

data work.heart;
set work.heart;
if CPK_indicator = 'High' then CPK_indicator3 = "1";
else CPK_indicator3 = "0";
run;


/*ONE HOT ENCODING FOR AGE GROUP*/
data work.heart;
set work.heart;
if Age_group = 'Children' then Age_group1 = "1";
else Age_group1 = "0";
run;

data work.heart;
set work.heart;
if Age_group = 'Teenager' then Age_group2 = "1";
else Age_group2 = "0";
run;

data work.heart;
set work.heart;
if Age_group = 'Young Adult' then Age_group3 = "1";
else Age_group3 = "0";
run;

data work.heart;
set work.heart;
if Age_group = 'Adult' then Age_group4 = "1";
else Age_group4 = "0";
run;

data work.heart;
set work.heart;
if Age_group = 'Senior' then Age_group5 = "1";
else Age_group5 = "0";
run;



