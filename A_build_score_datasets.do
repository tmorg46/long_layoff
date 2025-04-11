/* 

make one big dataset-building file, where, for each of our relevant specs:
	- the meet scores dataset with one observation per team-meet
	- the event scores dataset with one observation per team-event-meet
	- the individual scores dataset with one observation per gymnast-event-meet 
		- for each gymnast performing at a school in one of our specs on both sides of the 2021 gap
*/

discard
clear all

global route "C:/Users/toom/Desktop/long_layoff"


******************************
*Build the meet scores dataset
******************************
// done!
*open the full dataset
import delimited using "${route}/data/raw_data/all_scores_2015-2024.csv", varn(1) clear

gen datenum = date(date,"MDY") // this will let us sort meets correctly in order

gsort datenum meettitle team event -score // this groups each team's scores and puts the highest on top, accounting for multiple meets on one day, which sometimes happens in playoffs

bysort datenum meettitle team event: gen scorecount = _N // should be at least 5 for full team events at meets
bysort datenum meettitle team event: gen scoreorder = _n // only the top 5 scores get kept, so:

drop if scorecount < 5 | scoreorder > 5 // count<5 means individuals sent to meets, order>5 means dropped from team scores

collapse (sum) score, by(event team datenum year event_meet_id) // we gotta get these scores down to team scores within events by meets, correctly taking only the top 5 scores per event

gen meet_id = substr(event_meet_id, 5, .) // we need to sum up scores by meet after checking for full meet scores:

bysort meet_id team: egen eventcount = count(event) // this needs to be 4 in order to accurately compare total meet scores:
keep if eventcount==4
drop eventcount

collapse (sum) score, by(team datenum year meet_id) // now we have full meet scores!

merge m:1 team using "${route}/data/raw_data/team_divisions.dta", keep(1 3) nogen // we need division info!!

*make a marker for not having a 2021 season
gen no2021 = team=="UC Davis" 			///
		| team=="Sacramento State" 		/// the NorCal D1s...
		///
		| team=="Cornell" 				///
		| team=="Brown" 				///
		| team=="Yale" 					///
		| team=="Pennsylvania"			/// the Ivys...
		///
		| team=="Bridgeport"			///
		| team=="Southern Conn."		///
		| team=="West Chester"			/// the D2s...
		///
		| team=="Brockport"				///
		| team=="Cortland State"		///
		| team=="Ithaca College"		///
		| team=="Rhode Island College"	///
		| team=="Springfield College"	///
		| team=="Ursinus College"		//  and the D3s!

*make markers for the specs we're gonna be using
gen norcal = inlist(team, "San Jose State", "California", "Stanford", "UC Davis", "Sacramento State")

gen ivy = inlist(team, "Cornell", "Brown", "Yale", "Pennsylvania")

gen ne_nos = inlist(team, "New Hampshire", "Pittsburgh", "Penn State", "Temple", "Rutgers") // these are the D1 teams in the Northeast we're going to comp with the Ivys

gen d2 = division==2

gen d3 = division==3


sort team
gen team_id = 1
gen swapteam = team!=team[_n-1]
replace team_id = team_id[_n-1] + swapteam in 2/L // this block creates a numeric team id for later fixed effects
drop swapteam

*build the remaining diff-in-diff variables:
gen post 	  = year>2021
gen no21_post = year>2021 & no2021==1
gen ivy_post  = year>2021 & ivy==1

*save the meets dataset!!
sort datenum team
save "${route}/data/A_meet_scores.dta", replace
*/


*******************************
*Build the event scores dataset
*******************************
// done!
*open the full dataset
import delimited using "${route}/data/raw_data/all_scores_2015-2024.csv", varn(1) clear

gen datenum = date(date,"MDY") // this will let us sort meets correctly in order

gsort datenum meettitle team event -score // this groups each team's scores and puts the highest on top, accounting for multiple meets on one day, which sometimes happens in playoffs

bysort datenum meettitle team event: gen scorecount = _N // should be at least 5 for full team events at meets
bysort datenum meettitle team event: gen scoreorder = _n // only the top 5 scores get kept, so:

drop if scorecount < 5 | scoreorder > 5 // count<5 means individuals sent to meets, order>5 means dropped from team scores

collapse (sum) score, by(event team datenum year event_meet_id) // we gotta get these scores down to team scores within events by meets, now correctly taking only the top 5

merge m:1 team using "${route}/data/raw_data/team_divisions.dta", keep(1 3) nogen // we need division info!!

*make a marker for not having a 2021 season
gen no2021 = team=="UC Davis" 			///
		| team=="Sacramento State" 		/// the NorCal D1s...
		///
		| team=="Cornell" 				///
		| team=="Brown" 				///
		| team=="Yale" 					///
		| team=="Pennsylvania"			/// the Ivys...
		///
		| team=="Bridgeport"			///
		| team=="Southern Conn."		///
		| team=="West Chester"			/// the D2s...
		///
		| team=="Brockport"				///
		| team=="Cortland State"		///
		| team=="Ithaca College"		///
		| team=="Rhode Island College"	///
		| team=="Springfield College"	///
		| team=="Ursinus College"		//  and the D3s!

*make markers for the specs we're gonna be using
gen norcal = inlist(team, "San Jose State", "California", "Stanford", "UC Davis", "Sacramento State")

gen ivy = inlist(team, "Cornell", "Brown", "Yale", "Pennsylvania")

gen ne_nos = inlist(team, "New Hampshire", "Pittsburgh", "Penn State", "Temple", "Rutgers") // these are the D1 teams in the Northeast we're going to comp with the Ivys

gen d2 = division==2

gen d3 = division==3

sort team
gen team_id = 1
gen swapteam = team!=team[_n-1]
replace team_id = team_id[_n-1] + swapteam in 2/L // this block creates a numeric team id for later fixed effects
drop swapteam

*build the remaining diff-in-diff variables:
gen post 	  = year>2021
gen no21_post = year>2021 & no2021==1
gen ivy_post  = year>2021 & ivy==1

sort datenum team event
save "${route}/data/A_event_scores.dta", replace // done deal!
*/


**************************************************************************
*Narrow routines down to the gymnasts in our specs who played through 2021
**************************************************************************
// done!
*open the full dataset
import delimited using "${route}/data/raw_data/all_scores_2015-2024.csv", varn(1) clear

collapse score, by(gymnast team year) // we gotta get these down to gymnasts-by-year, saving team to check for switchers

sort gymnast year
gen teamswap = gymnast==gymnast[_n-1] & team!=team[_n-1] // now we're marking the times a gymnast changed teams, either within season or across seasons

bysort gymnast: egen changer = max(teamswap)
drop if changer==1 // no team switching allowed in this design!!

drop changer teamswap

reshape wide score, i(gymnast team) j(year) // we need to have the gymnasts as a single observation now and mark the years they have scores!!

keep if score2020!=. & score2022!=. // if they're not missing those scores, they played on both sides of the 2021 season

merge m:1 team using "${route}/data/raw_data/team_divisions.dta", keep(1 3) nogen // we need division info!!

*make a marker for not having a 2021 season
gen no2021 = team=="UC Davis" 			///
		| team=="Sacramento State" 		/// the NorCal D1s...
		///
		| team=="Cornell" 				///
		| team=="Brown" 				///
		| team=="Yale" 					///
		| team=="Pennsylvania"			/// the Ivys...
		///
		| team=="Bridgeport"			///
		| team=="Southern Conn."		///
		| team=="West Chester"			/// the D2s...
		///
		| team=="Brockport"				///
		| team=="Cortland State"		///
		| team=="Ithaca College"		///
		| team=="Rhode Island College"	///
		| team=="Springfield College"	///
		| team=="Ursinus College"		//  and the D3s!

*make markers for the specs we're gonna be using
gen norcal = inlist(team, "San Jose State", "California", "Stanford", "UC Davis", "Sacramento State")

gen ivy = inlist(team, "Cornell", "Brown", "Yale", "Pennsylvania")

gen ne_nos = inlist(team, "New Hampshire", "Pittsburgh", "Penn State", "Temple", "Rutgers") // these are the D1 teams in the Northeast we're going to comp with the Ivys

gen d2 = division==2

gen d3 = division==3

keep gymnast team no2021 ///
		norcal ivy ne_nos d2 d3 // these are the only vars we need right now to narrow the folks down


*now let's make a random id for the gymnasts so we can use that for fixed effects instead of the names:
gen gymnast_sort = runiform(0,1) // it's random on seed 46 from above.

sort gymnast_sort
drop gymnast_sort // now we're randomly sorted, so let's make an id:

gen gymnast_id = _n // there's a random id now!! yay!

tempfile sample			// now we can merge this into the full set of scores...
save `sample', replace 	// with a keep(3) for easy sample building!!

*open the full dataset back up and merge on our list from above:
import delimited using "${route}/data/raw_data/all_scores_2015-2024.csv", varn(1) clear

merge m:1 gymnast using `sample', keep(3) nogen // keep(3) keeps only scores from gymnasts we're keeping in our sample!!!
drop gymnast

*now we want to make a measure of the number of meets a gymnast has competed over her career
gen datenum = date(date,"MDY") // this will let us sort meets correctly in order
sort gymnast datenum

gen career_meetnum=1 									 //  this will be the career meet count...
gen swapmeet = date!=date[_n-1]							 //  so mark when a meet changes...
replace career_meetnum = career_meetnum[_n-1] + swapmeet /// and count up across meets...
	if gymnast==gymnast[_n-1] 							 //  and within gymnasts!
	
*build the remaining diff-in-diff variables:
gen post 	  = year>2021
gen no21_post = year>2021 & no2021==1
gen ivy_post  = year>2021 & ivy==1
	
drop swapmeet
sort datenum team gymnast_id event
save "${route}/data/A_routine_scores.dta", replace // done deal!
*/
