/*

get our scores together and 

*THINK ABOUT MATERNITY LEAVE***** // Joey Waite

*/

discard
clear all

global route "C:\Users\tmorg\Desktop\gap_year"


***************************************************************
*Narrow the teams down in the full dataset from Morgan & Cannon
***************************************************************
// pending
*open the full dataset
import delimited using "$route/data/all_scores_2015-2024.csv", varn(1) clear


*keep only the gymnasts from teams in NorCal and the Northeast
gen norcal = inlist(team, "San Jose State", "California", "Stanford", "UC Davis", "Sacramento State")

gen northeast = inlist(team, "New Hampshire", "Pittsburgh", "Penn State", "Temple", "Rutgers", "Brockport", "Cortland State", "Cornell", "Ithaca College")
replace northeast = inlist(team, "Springfield College", "Rhode Island College", "Brown", "Southern Conn.", "Yale", "Bridgeport", "Ursinus College", "West Chester", "Pennsylvania") // it takes two lines to do because inlist only allows 10 strings per command

keep if norcal==1 | northeast==1


*make a marker for not having a 2021 season, or for having a gap
gen gap = team=="UC Davis" ///
		| team=="Sacramento State" ///
		| team=="Brockport" ///
		| team=="Cortland State" ///
		| team=="Cornell" ///
		| team=="Ithaca College" ///
		| team=="Springfield College" ///
		| team=="Rhode Island College" ///
		| team=="Brown" /// 
		| team=="Southern Conn." ///
		| team=="Yale" ///
		| team=="Bridgeport" ///
		| team=="Ursinus College" ///
		| team=="West Chester" ///
		| team=="Pennsylvania"
		



		
