/* 

clean up the scores dataset from github.com/tmorg46/ncaa_wag_scores

*/

discard
clear all

global route "C:/Users/toom/Desktop/long_layoff"


*******************************
*get that data in and clean!!!!
*******************************
// done!
import delimited using ///
	"${route}/data/raw_data/cleaned_scores.csv" ///
	, varn(1) bindquote(strict) clear

merge m:1 team using "${route}/data/raw_data/team_divisions.dta", keep(1 3) nogen // we need division info!!

egen event_meet_id = concat(event date host meettitle), punct(" / ") // and now we have a unique event-within-meet identifier! but we'll want a numeric version for fixed effects later as well:

sort event_meet_id
gen emnumid  = 1
gen emchange = event_meet_id!=event_meet_id[_n-1]
replace emnumid = emnumid[_n-1] + emchange in 2/L // this block creates a unique group id (called emnumid for event-meet-numeric-id) for each event-by-meet identifier, allowing it to be used as a factor variable easily
drop emchange

sort team
gen teamid = 1
gen swaps  = team!=team[_n-1]
replace teamid = teamid[_n-1] + swaps in 2/L // and now we've got one for teams as well!
drop swaps


*now we want to make a measure of the number of meets a gymnast has competed over her career
gen datenum = date(date,"MDY") // this will let us sort meets correctly in order
sort gymnast datenum

gen career_meetnum=1 									 //  this will be the career meet count...
gen swapmeet = date!=date[_n-1]							 //  so mark when a meet changes...
replace career_meetnum = career_meetnum[_n-1] + swapmeet /// and count up across meets...
	if gymnast==gymnast[_n-1] 							 //  and within gymnasts!
drop swapmeet


*and now we're done with cleaning and adding info to the base set, so:
compress
sort team year meetnum event score
save "${route}/data/A_all_base_scores.dta", replace // and we're done!
*/


