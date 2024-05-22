/*

get our scores together and 

*/

discard
clear all

global route "C:\Users\morganto\Desktop\gap_year"


***************************************************************
*Narrow the teams down in the full dataset from Morgan & Cannon
***************************************************************
// pending
*open the full dataset
use "$route/data/all_scores_cleaned.dta", clear


*mark gymnasts that ever change teams (for later)
sort gymnast year team
gen teamchange = gymnast==gymnast[_n-1] & team!=team[_n-1]

bysort gymnast: egen changed = max(teamchange) // marks gymnasts that ever change teams
drop if changed==1 // we want gymnasts who stayed on just one team

drop teamchange changed


*keep only the gymnasts from teams in NorCal and the Northeast
gen norcal = inlist(team, "San Jose State", "California", "Stanford", "UC Davis", "Sacramento State")

gen northeast = inlist(team, "New Hampshire", "Pittsburgh", "Penn State", "Temple", "Rutgers", "Brockport", "Cortland State", "Cornell", "Ithaca College")
replace northeast = inlist(team, "Springfield College", "Rhode Island College", "Brown", "Southern Conn.", "Yale", "Bridgeport", "Ursinus College", "West Chester", "Pennsylvania")

keep if norcal==1 | northeast==1

