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


**************************************************************
*build the dataset of unique scores that we'll aggregate later
**************************************************************
// make an empty file that we'll use as an append base
clear
tempfile appender
save `appender', emptyok

*define the local with all the csv files
cd "${route}/data/raw_data/scrapes"
local files: dir "${route}/data/raw_data/scrapes" files "*.csv"

*run through each csv file and append it to the ever growing append tempfile
foreach f of local files {
	import delimited using `"`f'"', varn(1) clear
	append using `appender'
	save `appender', replace
}

*drop the scores that eventually will be added that are after 2025:
drop if year>2025


**************************************
*fix name inconsistencies and errors!!
**************************************
// there's a bunch of gymnasts whose names are missing or weird on RTN:

*some gymnasts are blank on RTN, let's fix those:
replace gymnast = "Grace Woolfolk" if gymnast=="" & team=="Iowa State"
replace gymnast = "Polina Poliakova" if gymnast=="" & team=="Rutgers"
replace gymnast = "Carleigh Stillwagon" if gymnast=="" & team=="Western Michigan" // these are the missing names

*fixing typos and misspellings:
replace gymnast = "Desire' Stephens" if gymnast=="DesirÃ© Stephens" // obvious weird thing
replace gymnast = "Marie Priest" if gymnast=="Narah Priest" // this was a weird typo on one single meet, there is no Narah Priest as far as I can find
replace gymnast = "Ava Kelley" if (gymnast=="Ava Kelly" | gymnast=="Ava Kelly") & team=="Springfield College" // they spelled her name wrong and there's another Ava Kelly at Southern Conn, plus in 2025 there's a weird escaped character in her name, hence the ( | )
replace gymnast = "Jessica Miley" if gymnast=="Jessisca Miley" // this is just a raw extra-S typo
replace gymnast = "Maddie Vitolo" if gymnast=="Maddie Viltolo" // and an extra-L classic
replace gymnast = "Kaitlin DeGuzman" if gymnast=="Kaitlin Deguzman" // they didn't capitalize her name at Kentucky but did at Clemson
replace gymnast = "Sophia LeBlanc" if gymnast=="Sophia Leblanc" // another caps issue here
replace gymnast = subinstr(gymnast, "  ", " ", .) // there's a bunch of double space gaps for no reason

*gymnasts with name changes across teams or over time:
replace gymnast = "Sunny Hasebe" if gymnast=="Haruka Hasebe" // this is a Winona State gymnast with two names she's used for scores
replace gymnast = "Lindsey Hunter-Kempler" if team=="BYU" & (gymnast=="Linsey Hunter-Kempler" | gymnast=="Lindsey Hunter") // she got married and hyphenated her name
replace gymnast = "Natasha Marsh" if team=="BYU" & gymnast=="Natasha Trejo" // she got married and changed her name
replace gymnast = "Shannon Evans" if team=="BYU" & gymnast=="Shannon Hortman" // so did she

*there are two different Abbie Thompson:
replace gymnast = "Abbie Thompson (Cornell)" if gymnast=="Abbie Thompson" & team=="Cornell"
replace gymnast = "Abbie Thompson (Denver)" if gymnast=="Abbie Thompson" & team=="Denver"

*there are two different Emily Anderson:
replace gymnast = "Emily Anderson (Gustavus Adolphus)" if gymnast=="Emily Anderson" & team=="Gustavus Adolphus"
replace gymnast = "Emily Anderson (Hamline)" if gymnast=="Emily Anderson" & team=="Hamline"

*there are two different Emily Leese:
replace gymnast = "Emily Leese (Rutgers)" if gymnast=="Emily Leese" & team=="Rutgers"
replace gymnast = "Emily Leese (UW-Eau Claire)" if gymnast=="Emily Leese" & team=="UW-Eau Claire"

*there are two different Emily White:
replace gymnast = "Emily White (North Carolina)" if gymnast=="Emily White" & team=="North Carolina"
replace gymnast = "Emily White (Arizona State)" if gymnast=="Emily White" & team=="Arizona State"

*there are two different Emma Brown:
replace gymnast = "Emma Brown (Ursinus College)" if gymnast=="Emma Brown" & team=="Ursinus College"
replace gymnast = "Emma Brown (Denver)" if gymnast=="Emma Brown" & team=="Denver"

*there are two different Gabrielle Johnson:
replace gymnast = "Gabrielle Johnson (Central Michigan)" if gymnast=="Gabrielle Johnson" & team=="Central Michigan"
replace gymnast = "Gabrielle Johnson (Winona State)" if gymnast=="Gabrielle Johnson" & team=="Winona State"

*there are two different Jordan William:
replace gymnast = "Jordan Williams (UCLA)" if gymnast=="Jordan Williams" & team=="UCLA"
replace gymnast = "Jordan Williams (S.E. Missouri)" if gymnast=="Jordan Williams" & team=="S.E. Missouri"

*there are two different Katie Bailey:
replace gymnast = "Katie Bailey (Alabama)" if gymnast=="Katie Bailey" & team=="Alabama"
replace gymnast = "Katie Bailey (Lindenwood)" if gymnast=="Katie Bailey" & team=="Lindenwood"

*there are two different Lauren Miller:
replace gymnast = "Lauren Miller (Air Force)" if gymnast=="Lauren Miller" & team=="Air Force"
replace gymnast = "Lauren Miller (LIU)" if gymnast=="Lauren Miller" & team=="LIU"

*there are two different Lauren Wong:
replace gymnast = "Lauren Wong (Cornell)" if gymnast=="Lauren Wong" & team=="Cornell"
replace gymnast = "Lauren Wong (Utah)" if gymnast=="Lauren Wong" & team=="Utah"

*there are two different Leah Smith:
replace gymnast = "Leah Smith (Towson)" if gymnast=="Leah Smith" & team=="Towson"
replace gymnast = "Leah Smith (Arkansas)" if gymnast=="Leah Smith" & team=="Arkansas"

*there are two different Maya Davis:
replace gymnast = "Maya Davis (Brown)" if gymnast=="Maya Davis" & team=="Brown"
replace gymnast = "Maya Davis (Lindenwood)" if gymnast=="Maya Davis" & team=="Lindenwood"

*there are two different Olivia Williams:
replace gymnast = "Olivia Williams (Centenary College)" if gymnast=="Olivia Williams" & team=="Centenary College"
replace gymnast = "Olivia Williams (Bowling Green)" if gymnast=="Olivia Williams" & team=="Bowling Green"

*there are two different Payton Murphy:
replace gymnast = "Payton Murphy (Cornell)" if gymnast=="Payton Murphy" & team=="Cornell"
replace gymnast = "Payton Murphy (Western Michigan)" if gymnast=="Payton Murphy" & team=="Western Michigan"

*there are two different Payton Smith:
replace gymnast = "Payton Smith (Rhode Island College)" if gymnast=="Payton Smith" & team=="Rhode Island College"
replace gymnast = "Payton Smith (Auburn)" if gymnast=="Payton Smith" & team=="Auburn"

*there are two different Samantha Henry:
replace gymnast = "Samantha Henry (Cornell)" if gymnast=="Samantha Henry" & team=="Cornell"
replace gymnast = "Samantha Henry (Kent State)" if gymnast=="Samantha Henry" & team=="Kent State"

*there are two different Shannon Farrell:
replace gymnast = "Shannon Farrell (Rutgers)" if gymnast=="Shannon Farrell" & team=="Rutgers"
replace gymnast = "Shannon Farrell (Alaska)" if gymnast=="Shannon Farrell" & team=="Alaska"

*there are two different Sophie Schmitz:
replace gymnast = "Sophie Schmitz (Centenary College)" if gymnast=="Sophie Schmitz" & team=="Centenary College"
replace gymnast = "Sophie Schmitz (Gustavus Adolphus)" if gymnast=="Sophie Schmitz" & team=="Gustavus Adolphus"

*there are two different Sydney Smith:
replace gymnast = "Sydney Smith (Fisk)" if gymnast=="Sydney Smith" & team=="Fisk"
replace gymnast = "Sydney Smith (Southern Conn.)" if gymnast=="Sydney Smith" & team=="Southern Conn."

*there are two different Sydney Ewing:
replace gymnast = "Sydney Ewing (LSU)" if gymnast=="Sydney Ewing" & team=="LSU"
replace gymnast = "Sydney Ewing (Michigan State)" if gymnast=="Sydney Ewing" & team=="Michigan State"


********************************************
*fix meet title inconsistencies and errors!!
********************************************
// there's a bunch of meets whose titles are missing on RTN:
*fix the BIG 5 Meet from 2024:
replace meettitle = "BIG 5 Meet" if date=="Feb-23-2024" & host==""

*fix the Alabama-Auburn Elevate the Stage from 2015:
replace meettitle = "Elevate The Stage" if date=="Mar-08-2015" & host==""

*fix the West Chester Pink Invite from 2019:
replace meettitle = "Pink Invite" if date=="Feb-22-2019" & host==""

*fix the Cancun Classic from 2019:
replace meettitle = "Cancun Classic" if date=="Jan-04-2019" & host==""

// there are two untitled meets involving Georgia in March 2023 (their 10th & 11th meets, which were also Arkansas' 9th and Michigan's 10th, respectively). They had to do some emergency repairs to their arena so they went to a semi-neutral site nearby... so they /kinda/ hosted, but not enough to mark them as hosts (for the purposes of this project) or to title the meet. their event_meet_id made below is still unique for both of the meets due to the different dates of the meets and due to those two meets being the only two (untitled & no-host) meets in the sample.


***********************************************
*final formatting: reshape & numeric ids & save
***********************************************
// now we'd like to generate a string that uniquely identifies events within meets, but it needs a reshape:
rename (vault bars beam floor) (score1 score2 score3 score4)
reshape long score, i(meettitle date host gymnast) j(event)
drop if score==. // good stuff, now let's move along:

merge m:1 team using "${route}/data/raw_data/team_divisions.dta", keep(1 3) nogen // we need division info!!

egen event_meet_id = concat(event date host meettitle), punct(" / ") // and now we have a unique event-within-meet identifier! but we'll want a numeric version for fixed effects later as well:

sort event_meet_id
gen emnumid  = 1
gen emchange = event_meet_id!=event_meet_id[_n-1]
replace emnumid = emnumid[_n-1] + emchange in 2/L // this block creates a unique group id (called emnumid for event-meet-numeric-id) for each event-by-meet identifier!
drop emchange

sort team
gen teamid = 1
gen swaps  = team!=team[_n-1]
replace teamid = teamid[_n-1] + swaps in 2/L // and now we've got one for teams as well, again for fixed effects later. We'll also make one for gymnasts in do-file 2 once we get race predictions on there
drop swaps


*now we want to make a measure of the number of meets a gymnast has competed over her career
gen datenum = date(date,"MDY") // this will let us sort meets correctly in order
sort gymnast datenum

gen career_meetnum=1 									 //  this will be the career meet count...
gen swapmeet = date!=date[_n-1]							 //  so mark when a meet changes...
replace career_meetnum = career_meetnum[_n-1] + swapmeet /// and count up across meets...
	if gymnast==gymnast[_n-1] 							 //  and within gymnasts!
drop swapmeet


*and now we're done!
compress
sort team year meetnum event score
export delimited using "${route}/data/raw_data/all_scores_2015-2025.csv", replace // and we're done!


******************************
*Build the meet scores dataset
******************************
// done!
*open the full dataset
import delimited using "${route}/data/raw_data/all_scores_2015-2025.csv", varn(1) clear

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
import delimited using "${route}/data/raw_data/all_scores_2015-2025.csv", varn(1) clear

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


***************************************
*Narrow routines down and mark gymnasts
***************************************
// done!
*open the full dataset to make a list of gymnasts for this part of the spec:
import delimited using "${route}/data/raw_data/all_scores_2015-2025.csv", varn(1) clear

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

collapse score, by(gymnast team year) // we gotta get these down to gymnasts-by-year, saving team to check for switchers

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

*let's get the division info in!
merge m:1 team using "${route}/data/raw_data/team_divisions.dta", keep(1 3) nogen // we need division info!!

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
import delimited using "${route}/data/raw_data/all_scores_2015-2025.csv", varn(1) clear

merge m:1 gymnast using `sample', keep(3) nogen // keep(3) keeps only scores from gymnasts we're keeping in our sample!!!
drop gymnast
	
*build the remaining diff-in-diff variables:
gen post 	  = year>2021
gen no21_post = year>2021 & no2021==1
gen ivy_post  = year>2021 & ivy==1
	
sort datenum team gymnast_id event
save "${route}/data/A_routine_scores.dta", replace // done deal!
*/
