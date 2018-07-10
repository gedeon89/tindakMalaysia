clear all
set more off
cd "C:\Users\gedeo\Dropbox\Tindak\build\input"
global output "C:\Users\gedeo\Dropbox\Tindak\build\output"
**key ID vars: nameDM13 kodDM13 state13 kodPar13 namePar13 kodDUN13 nameDUN13 namePollCentre13
**key VOI    : *Calon_13  totalVotesValid13
**use KODANDDM and (generated) KODDM where possible. KODLOKALITI + NAMADAERAHMENGUNDI all
**appear to have small mistakes
**data checks done:
**1. all salurans (correctly) run within polling centres (TEMPATMENGUNDI) only even 
**   if >1 polling district (DAERAHMENGUNDI) within a single TEMPATMENGUNDI
**
**2. checked that sum of votes for all candidates = all valid votes (egen total= () = UNDIBAIK) 

**bring in GE13 saluran-level parliamentary results: export to .dta format
#d;
import excel 
		"C:\Users\gedeo\Dropbox\Tindak\build\input\GE13 - Saluran Results_ Combined_undi biasa_Undi Awal_Undi Pos.xlsx", sheet("PAR-ALL") firstrow allstring clear;
#d cr
cap drop AN AO AP AQ AR AS AT
saveold "$output\ge2013Parliament.dta", v(12) replace

**clean clean clean**
use "$output\ge2013Parliament.dta", clear
replace KODANDDM = strltrim(KODANDDM)
replace KODANDDM = strrtrim(KODANDDM)
gen KODDM = regexs(0) if(regexm(KODANDDM, "[0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]"))
replace KODDM=subinstr(KODDM,"/","",.)
replace KODLOKALITI=subinstr(KODLOKALITI,"/","",.)
gen check = KODDM!=KODLOKALITI if KODDM!="" /* e.g. br if check==1 & kodPAR=="P094"
											   4 problem cases,
											   generated KODDM's seem better,
											   let's stick w them */
drop KODLOKALITI check
order KODDM KODANDDM
gen reverseNameDM13 = reverse(KODANDDM)
gen nameDM13 = substr(reverseNameDM13, strpos(reverseNameDM13, " "), .)
order nameDM13
replace nameDM13=reverse(nameDM13)
drop reverseNameDM13
replace nameDM13 = subinstr(nameDM13," ","",.)
replace TEMPATMENGUNDI = subinstr(TEMPATMENGUNDI," ","",.)
#d;
drop NAMADAERAHMENGUNDI /* identical to constructed TEMPATMENGUNDI*/;
ren (nameDM13 KODDM KODANDDM NEGERI KATEGORI kodPAR namaPAR kodDUN namaDUN
	 TEMPATMENGUNDI SALURAN 
	 KERTASUNDIDALAMTONGUNDI UNDIBAIK UNDIROSAK UNDITIDAKDILETAKBALIK)
	(nameDM13 kodDM13 kodandDM13 state13 voteCat13 kodPar13 namePar13 
	kodDUN13 nameDUN13 namePollCentre13 saluranNum13
	votesinBox13 totalVotesValid13 votesRej13 votesUnreturned13);
foreach v in BN PR_1 PR_2 OTHER1 OTHER2 OTHER3 OTHER4 OTHER5 {;
	rename `v' `= lower("`v'")';
	rename `v'_CALON `= lower("`v'_CALON")';
	rename `v'_VOTE `= lower("`v'_VOTE")';
	};
forval i = 1/2 {;
	ren (pr_`i' pr_`i'_calon pr_`i'_vote) (pr`i' pr`i'_calon pr`i'_vote);
	};	
foreach v in bn pr1 pr2 other1 other2 other3 other4 other5 {;
	rename (`v' `v'_calon `v'_vote) (`v'Party_13 `v'Calon_13 `v'_13);
	};
destring saluranNum13 votesinBox13 totalVotesValid13 votesRej13 votesUnreturned13 
			   bn_13 pr1_13 pr2_13 other1_13 other2_13 other3_13 
			   other4_13 other5_13, replace;
#d cr
**check if all salurans (correctly?) run within TEMPATMENGUNDI only
/*
sort NEGERI kodPAR kodDUN KODDM TEMPATMENGUNDI SALURAN
cap ssc install tsspell
tsspell TEMPATMENGUNDI
*/
**collapse to DM (voting centre) level
preserve
#d;
collapse (sum) votesinBox13 totalVotesValid13 votesRej13 votesUnreturned13 
			   bn_13 pr1_13 pr2_13 other1_13 other2_13 other3_13 other4_13 
			   other5_13, by(kodDM13);
tempfile t;
save `t', replace;
#d cr
restore
duplicates drop kodDM13, force
#d;
drop votesinBox13 totalVotesValid13 votesRej13 votesUnreturned13 
			   bn_13 pr1_13 pr2_13 other1_13 other2_13 other3_13 other4_13 
			   other5_13;
#d cr
merge 1:1 kodDM13 using `t'
drop _merge saluranNum13
order kodDM13
saveold "$output\ge2013Parliament.dta", v(12) replace


