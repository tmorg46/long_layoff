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
reg score no21_post i.team_id i.year	if d2==1		// All 7 D2 teams
reg score no21_post i.team_id i.year	if d3==1		// 