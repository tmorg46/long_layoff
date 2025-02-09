/*

get our scores together and 

think about it as a "long layoff" re:
https://yaledailynews.com/blog/2021/12/10/gymnastics-yale-ready-to-flip-into-new-season/

// we can do a D1 in Norcal, a D1 in the northeast, and maybe a broad level D2/D3?

*/

discard
clear all

global route "C:/Users/toom/Desktop/long_layoff"


********************************************************************
*Narrow the gymnasts down from the full dataset from Morgan & Cannon
********************************************************************
// pending
*open the full dataset
import delimited using "$route/data/all_scores_2015-2024.csv", varn(1) clear

collapse score, by(gymnast team year) // we gotta get these down to gymnasts-by-year, saving team to check for switchers

sort gymnast year
gen teamswap = gymnast==gymnast[_n-1] & team!=team[_n-1] // now we're marking the times a gymnast changed teams, either within season or across seasons

bysort gymnast: egen changer = max(teamswap)
drop if changer==1 // no team switching allowed in this design!!

drop changer teamswap

reshape wide score, i(gymnast team) j(year) // we need to have the gymnasts as a single observation now and mark the years they have scores!!

keep if score2020!=. & score2022!=.


*keep only the gymnasts from teams in NorCal, the Northeast, or DII/DIII
gen norcal = inlist(team, "San Jose State", "California", "Stanford", "UC Davis", "Sacramento State")

gen northeast = inlist(team, "New Hampshire", "Pittsburgh", "Penn State", "Temple", "Rutgers", "Brockport", "Cortland State", "Cornell", "Ithaca College")
replace northeast = 1 if inlist(team, "Springfield College", "Rhode Island College", "Brown", "Southern Conn.", "Yale", "Bridgeport", "Ursinus College", "West Chester", "Pennsylvania") // it takes two lines to do because inlist only allows 10 strings per command

merge m:1 team using "${route}/data/team_divisions.dta", keep(1 3) nogen
gen d2d3 = division!=1

replace northeast = 0 if d2d3==1 // these are going to be different specifications

keep if norcal==1 | northeast==1 | d2d3==1


*make a marker for not having a 2021 season, or for having 'been laid off'
gen layoff = team=="UC Davis" 			///
		| team=="Sacramento State" 		///
		| team=="Cornell" 				///
		| team=="Ithaca College" 		///
		| team=="Springfield College" 	///
		| team=="Rhode Island College" 	///
		| team=="Brown" 				/// 
		| team=="Southern Conn." 		///
		| team=="Yale" 					///
		| team=="Bridgeport" 			///
		| team=="Ursinus College" 		///
		| team=="West Chester"			///
		| team=="Pennsylvania"
		
keep gymnast team norcal northeast d2d3 layoff


*now let's make a random id for the gymnasts so we can use that for fixed effects instead of the names:
gen gymnast_sort = runiform(0,1) // it's random on seed 46 from above.

sort gymnast_sort
drop gymnast_sort // now we're randomly sorted, so let's make an id:

gen gymnast_id = _n // there's a random id now!! yay!


tempfile sample			// now we can merge this into the full set of scores...
save `sample', replace 	// with a keep(3) for easy sample building!!


**********************************************
*Narrow the sample down from the full dataset!
**********************************************
*open the full dataset and merge on our list from above
import delimited using "$route/data/all_scores_2015-2024.csv", varn(1) clear

merge m:1 gymnast using `sample', keep(3) nogen // keep(3) keeps only scores from gymnasts we're keeping in our sample!!!
drop gymnast

*now we want to make a measure of the number of meets a gymnast has competed over her career
gen datenum = date(date,"MDY") // this will let us sort meets correctly in order
sort gymnast datenum

gen career_meetnum=1 									  // this will be the career meet count...
gen swapmeet = date!=date[_n-1]							  // this marks when a meet changes...
replace career_meetnum = career_meetnum[_n-1] + swapmeet /// we count up across meets...
	if gymnast==gymnast[_n-1] 							  // within gymnasts!

drop datenum swapmeet


*now let's get our classic diff-in-diff variables. first, layoff is our TREAT measure, so:
gen post 	  = year>2021 		// the years after the treatment (POST) are any years after 2021!
gen post_laid = layoff * post 	// and this is the TREAT*POST measure!

save "${route}/data/analysis_sample.dta", replace // done deal!

		
