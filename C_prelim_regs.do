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
use "${route}/data/B_meet_scores.dta", clear

*let's go by spec:
reg score no21_post i.team_id i.year	if norcal==1	// NorCal D1 diff
reg score no21_post i.team_id i.year	if d2==1		// All 4 D2 teams
reg score no21_post i.team_id i.year	if d3==1		// All 15 D3 teams





*****pending:::

// NorCal event study:
foreach num of numlist 2015/2025 {
	gen dummy`num' = year==`num'
	gen reg`num' = no2021*dummy`num'
}

reg score ///
	reg2015 reg2016 reg2017 reg2018 reg2019 reg2020 ///
	reg2022 reg2023 reg2024 reg2025					///
	i.team_id ib2021.year if division==2, vce(hc3)
	
	

	
	
	




*open the event scores set
use "${route}/data/B_event_scores.dta", clear

*let's go by spec:
reg score no21_post i.team_id i.year i.event	if norcal==1	// NorCal D1 diff
reg score no21_post i.team_id i.year i.event	if d2==1		// All 4 D2 teams
reg score no21_post i.team_id i.year i.event	if d3==1		// All 15 D3 teams


*open the routine scores set
use "${route}/data/B_routine_scores.dta", clear

*let's go by spec:
areg score no21_post if thru21==1 & norcal==1, absorb(gymnast_id emnumid) cluster(emnumid) nolog // NorCal
areg score no21_post if thru21==1 & d2==1	 , absorb(gymnast_id emnumid) cluster(emnumid) nolog // D2
areg score no21_post if thru21==1 & d3==1	 , absorb(gymnast_id emnumid) cluster(emnumid) nolog // D3


// do this with full aregs on Stata19 after sync for the pre/post only girlies
areg score no2021 if pree21==1 & norcal==1, absorb(emnumid) cluster(emnumid) nolog // NorCal
areg score no2021 if pree21==1 & d2==1	  , absorb(emnumid) cluster(emnumid) nolog // D2
areg score no2021 if pree21==1 & d3==1	  , absorb(emnumid) cluster(emnumid) nolog // D3

areg score no2021 if post21==1 & norcal==1, absorb(emnumid) cluster(emnumid) nolog // NorCal
areg score no2021 if post21==1 & d2==1	  , absorb(emnumid) cluster(emnumid) nolog // D2
areg score no2021 if post21==1 & d3==1	  , absorb(emnumid) cluster(emnumid) nolog // D3


// event study??????????????
reg score no2021#ib2021.year, cluster(emnumid) // doesn't work i don't think



