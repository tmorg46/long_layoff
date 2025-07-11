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
use "${route}/data/A_all_base_scores.dta", clear

drop if inlist(team, ///
	"Clemson", 			///
	"Fisk", 			///
	"Greenville", 		///
	"LIU", 				///
	"Seattle Pacific", 	///
	"Simpson", 			///
	"Talladega", 		///
	"UIC", 				///
	"Utica")			// these teams are either newer than 2020 or didn't last through 2021

gsort datenum meettitle team event -score // this groups each team's scores and puts the highest on top, accounting for multiple meets on one day, which sometimes happens in playoffs

bysort datenum meettitle team event: gen scorecount = _N // should be at least 5 for full team events at meets
bysort datenum meettitle team event: gen scoreorder = _n // only the top 5 scores get kept, so:

drop if scorecount < 5 | scoreorder > 5 // count<5 means individuals sent to meets, order>5 means dropped from team scores

collapse (sum) score (mean) division, by(event team datenum year event_meet_id) // we gotta get these scores down to team scores within events by meets, correctly taking only the top 5 scores per event, keeping division info (they don't move)

gen meet_id = substr(event_meet_id, 5, .) // we need to sum up scores by meet after checking for full meet scores:

bysort meet_id team: egen eventcount = count(event) // this needs to be 4 in order to accurately compare total meet scores:
keep if eventcount==4
drop eventcount

collapse (sum) score (mean) division, by(team datenum year meet_id) // now we have full meet scores!

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
save "${route}/data/B_meet_scores.dta", replace
*/


*******************************
*Build the event scores dataset
*******************************
// done!
*open the full dataset
use "${route}/data/A_all_base_scores.dta", clear

drop if inlist(team, ///
	"Clemson", 			///
	"Fisk", 			///
	"Greenville", 		///
	"LIU", 				///
	"Seattle Pacific", 	///
	"Simpson", 			///
	"Talladega", 		///
	"UIC", 				///
	"Utica")			// these teams are either newer than 2020 or didn't last through 2021

gsort datenum meettitle team event -score // this groups each team's scores and puts the highest on top, accounting for multiple meets on one day, which sometimes happens in playoffs

bysort datenum meettitle team event: gen scorecount = _N // should be at least 5 for full team events at meets
bysort datenum meettitle team event: gen scoreorder = _n // only the top 5 scores get kept, so:

drop if scorecount < 5 | scoreorder > 5 // count<5 means individuals sent to meets, order>5 means dropped from team scores

collapse (sum) score (mean) division, by(event team datenum year event_meet_id) // we gotta get these scores down to team scores within events by meets, now correctly taking only the top 5

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
save "${route}/data/B_event_scores.dta", replace // done deal!
*/


***************************************
*Narrow routines down and mark gymnasts
***************************************
// done!
*open the full dataset to make a list of gymnasts for this part of the spec:
use "${route}/data/A_all_base_scores.dta", clear

drop if inlist(team, ///
	"Clemson", 			///
	"Fisk", 			///
	"Greenville", 		///
	"LIU", 				///
	"Seattle Pacific", 	///
	"Simpson", 			///
	"Talladega", 		///
	"UIC", 				///
	"Utica")			// these teams are either newer than 2020 or didn't last through 2021

collapse score division, by(gymnast team year) // we gotta get these down to gymnasts-by-year, saving team to check for switchers

sort gymnast year
gen teamswap = gymnast==gymnast[_n-1] & team!=team[_n-1] // now we're marking the times a gymnast changed teams, either within season or across seasons

bysort gymnast: egen changer = max(teamswap)
drop if changer==1 // no team switching allowed in this design!!

drop changer teamswap

*we can make a list of gymnasts after marking the lengths of their careers:
bysort gymnast: egen firstyear = min(year)
bysort gymnast: egen lastyear  = max(year)

keep if gymnast!=gymnast[_n-1]

*mark the gymnasts by their career relation to 2021:
gen pree21 = lastyear<2021 // I added an e to 'pre' to make them all 6 characters long lol
gen post21 = firstyear>2021
gen thru21 = firstyear<2021 & lastyear>2021

drop if pree21==0 & post21==0 & thru21==0 // if people ended/began in 2021, yikes for us!

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

keep gymnast team no2021 		///
		norcal ivy ne_nos d2 d3 ///
		pree21 post21 thru21	// these are the only vars we need right now to narrow the folks down
		
*now let's make a random id for the gymnasts so we can use that for fixed effects instead of the names:
gen gymnast_sort = runiform(0,1) // it's random on seed 46 from above.

sort gymnast_sort
drop gymnast_sort // now we're randomly sorted, so let's make an id:

gen gymnast_id = _n // there's a random id now!! yay!

tempfile sample			// now we can merge this into the full set of scores...
save `sample', replace 	// with a keep(3) for easy sample building!!

*open the full dataset back up and merge on our list from above:
use "${route}/data/A_all_base_scores.dta", clear

merge m:1 gymnast using `sample', keep(3) nogen // keep(3) keeps only scores from gymnasts we're keeping in our sample!!!
drop gymnast
	
*build the remaining diff-in-diff variables:
gen post 	  = year>2021
gen no21_post = year>2021 & no2021==1
gen ivy_post  = year>2021 & ivy==1
	
sort datenum team gymnast_id event
save "${route}/data/B_routine_scores.dta", replace // done deal!
*/
