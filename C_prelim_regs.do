/* 

playground for some baseline regression results, preliminary stuff?

*/

discard
clear all

global route "/Users/tmorg46/Desktop/long_layoff"


****************************************
*Regs on specs with the full meet scores
****************************************
// pending
*open the meet scores set
use "${route}/data/B_meet_scores.dta", clear

*let's go by spec:
reg score no21_post i.team_id i.year	if norcal==1	// NorCal D1 diff
reg score no21_post i.team_id i.year	if d2==1		// All 4 D2 teams
reg score no21_post i.team_id i.year	if d3==1		// All 15 D3 teams


*open the event scores set
use "${route}/data/B_event_scores.dta", clear

*let's go by spec:
reg score no21_post i.team_id i.year i.event	if norcal==1	// NorCal D1 diff
reg score no21_post i.team_id i.year i.event	if d2==1		// All 4 D2 teams
reg score no21_post i.team_id i.year i.event	if d3==1		// All 15 D3 teams


*open the routine scores set
use "${route}/data/B_routine_scores.dta", clear

*let's go by spec:
areg score no21_post if thru21==1 & norcal==1, absorb(gymnast_id emnumid) nolog // NorCal
areg score no21_post if thru21==1 & d2==1	 , absorb(gymnast_id emnumid) nolog // D2
areg score no21_post if thru21==1 & d3==1	 , absorb(gymnast_id emnumid) nolog // D3


// do this with full aregs on Stata19 after sync for the pre/post only girlies
areg score no2021 if pree21==1 & norcal==1, absorb(emnumid) cluster(emnumid) nolog // NorCal
areg score no2021 if pree21==1 & d2==1	  , absorb(emnumid) cluster(emnumid) nolog // D2
areg score no2021 if pree21==1 & d3==1	  , absorb(emnumid) cluster(emnumid) nolog // D3

areg score no2021 if post21==1 & norcal==1, absorb(emnumid) cluster(emnumid) nolog // NorCal
areg score no2021 if post21==1 & d2==1	  , absorb(emnumid) cluster(emnumid) nolog // D2
areg score no2021 if post21==1 & d3==1	  , absorb(emnumid) cluster(emnumid) nolog // D3


// event study??????????????
reg score no2021##ib2020.year, cluster(emnumid) // doesn't work i don't think



