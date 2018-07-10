*****************************************************
***   TINDAK WORK: 9/7/2018						  ***
***   for johor baru analysis only: 1-on-1 fight  ***
***   using initial saluran release data	      ***
***   to analyze 
*****************************************************
*** 1. Merge on kodeDM13 and kodeDM14 results in 4 unmerged
***    of UDAMAHSURI; ULUAYERMOLEK; KEBUNTEH; SRITEBRAU(2)
*** 2. Merging unmerged using nameDM13 and nameDM14
***    results in 3 merged, 1 unmerged
***    Details: ULUAYERMOLEK/KEBUNTEH: from Pulai
***	            SRITEBRAU(2) skipped 1604517/miscoded as 
***				1604518 in kodDM13. It's coded correctly 
*** 			(?) as 1604517 in kodDM14
***	    

clear all
set more off
cd "C:\Users\gedeo\Dropbox\Tindak\build\input"
global output "C:\Users\gedeo\Dropbox\Tindak\build\output"

*Use GE14 DM-level data as base (saluran-level is also available)
*Given (quiet) redelineations (in early 2016) 
#d;
import excel "C:\Users\gedeo\Dropbox\Tindak\build\input\AKMAL -LIST OF SALURAN P160 N44 N45.xlsx",
			  sheet("RESULT 9 MAY") cellrange(A5:J48) firstrow allstring clear;
drop No;
ren (KODDAERAHMENGUNDI AREA PUSATMENGUNDI BN PH 
	 JUMLAHUNDIAN UNDIDITOLAK KERTASUNDIXMASUKPETI 
	 JUMLAHKERTASUNDIDIKELUARKAN) 
	(kodDM14 nameDM14 nameVotingCentre14 bn_14 ph_14
	 totalVotesValid14 votesRej14 votesNotInBox14 totalVotes14);
replace kodDM14=subinstr(kodDM14,"/","",.);
replace nameDM14 = subinstr(nameDM14," ","",.);
destring kodDM14 bn_14 ph_14 totalVotesValid14 votesRej14 
		 votesNotInBox14 totalVotes14, replace;
drop if nameVotingCentre14=="JUMLAH";
*wonky totalVotes14 fails to include votesNotInBox14 
*from time-to-time. drop original and egen replacement
drop totalVotes14
egen totalVotes14 = rowtotal(totalVotesValid14 votesRej14 votesNotInBox14)
cou;
local numDM14 = `r(N)' - 2;
di as text "*********`numDM14' GE14 DM's to be matched to GE13******";
#d cr
/*quick checks: all fine
foreach v in BN14 PH14 totalVotesValid14 votesRej14 votesNotInBox14 totalVotes14 {
	egen total`v' = total(`v') if nameVotingCentre14!="JUMLAH"
	}
cap drop total*
*/
*Try merging on KODDMs: clean up GE13 first
preserve
use "$output/ge2013Parliament.dta", clear
keep if state13=="JOHOR"
destring kodDM13, replace
*keep kodDM13 nameDM13 kodPar13 namePar13 kodDUN13 nameDUN13 namePollCentre13
ren kodDM13 kodDM14
tempfile t
save `t', replace
restore
drop if kodDM14==. /* 2 obs of UNDI AWAL/UNDI POS */ 
merge 1:1 kodDM14 using `t', gen(_mergeKodDM)
order kodDM14 nameDM13 nameDM14 kodPar13 namePollCentre13 ///
	  nameVotingCentre14 namePar13 kodDUN13 nameDUN13 ///
	  totalVotesValid14 totalVotesValid13 votesRej14 votesRej13 ///
	  votesNotInBox14 votesUnreturned13 totalVotes14 votesinBox13 ///
	  bn_14 bn_13 ph_14 pr1_13 pr2_13 other1_13 ///
	  other2_13 other3_13 other4_13 other5_13 
keep if _mergeKodDM==1 | _mergeKodDM==3
gen diffDMName = nameDM13 != nameDM14 if _mergeKodDM==3

preserve
use "$output/ge2013Parliament.dta", clear
keep if state13=="JOHOR"
destring kodDM13, replace
*keep kodDM13 nameDM13 kodPar13 namePar13 kodDUN13 nameDUN13 namePollCentre13
ren nameDM13 nameDM14
duplicates drop nameDM14, force /* small merge: drop duplicate nameDM13 since none of these are relevant*/
tempfile t
save `t', replace
restore

/* try merging on names */
merge 1:1 nameDM14 using `t', update
keep if inlist(_merge,1,3,4)

order _merge _mergeKodDM kodDM14 nameDM13 nameDM14 kodPar13 namePollCentre13 ///
	  nameVotingCentre14 namePar13 kodDUN13 nameDUN13 ///
	  totalVotesValid14 totalVotesValid13 votesRej14 votesRej13 ///
	  votesNotInBox14 votesUnreturned13 totalVotes14 votesinBox13 ///
	  bn_14 bn_13 ph_14 pr1_13 pr2_13 other1_13 ///
	  other2_13 other3_13 other4_13 other5_13 
keep totalVotesValid14 totalVotesValid13 diffVotes _merge ///
	_mergeKodDM kodDM14 nameDM13 nameDM14 kodPar13 ///
	namePollCentre13 nameVotingCentre14	  


