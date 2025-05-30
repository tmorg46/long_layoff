/* 

playground for some baseline regression results, preliminary stuff?

*/

discard
clear all

global route "C:/Users/toom/Desktop/long_layoff"


****************************************
*Regs on specs with the full meet scores
****************************************
// pending
*open the meet scores set
use "${route}/data/A_meet_scores.dta", clear

*let's go by spec:
reg score no21_post i.team_id i.year	if norcal==1	// NorCal D1 diff
reg score no21_post i.team_id i.year	if d2==1		// All 4 D2 teams
reg score no21_post i.team_id i.year	if d3==1		// All 15 D3 teams


*open the event scores set
use "${route}/data/A_event_scores.dta", clear

*let's go by spec:
reg score no21_post i.team_id i.year i.event	if norcal==1	// NorCal D1 diff
reg score no21_post i.team_id i.year i.event	if d2==1		// All 4 D2 teams
reg score no21_post i.team_id i.year i.event	if d3==1		// All 15 D3 teams


*open the routine scores set
use "${route}/data/A_routine_scores.dta", clear

*let's go by spec:
areg score no21_post i.gymnast_id	if thru21==1 & norcal==1, absorb(emnumid) // NorCal
areg score no21_post i.gymnast_id	if thru21==1 & d2==1	, absorb(emnumid) // D2
areg score no21_post i.gymnast_id	if thru21==1 & d3==1	, absorb(emnumid) // D3

// do this with full aregs on Stata19 after sync for the pre/post only girlies



