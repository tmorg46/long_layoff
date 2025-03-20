/*

https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2023&layergroup=States+%28and+equivalent%29

ssc install shp2dta
ssc install geo2xy
ssc install schemepack

*/

discard
clear all

global route "C:/Users/toom/Desktop/long_layoff"


cd "${route}/data/raw_data/cb_2018_us_state_500k"

shp2dta using cb_2018_us_state_500k, data(data) coord(coords) replace

use coords, clear

merge m:1 _ID using data, keep(1 3) nogen

drop if inlist(STUSPS, "AK", "AS", "GU", "HI", "MP", "PR", "VI")

append using "${route}/data/raw_data/school_coords.dta"

gen states = STATEFP!=""


// the Cali:
*keep if inlist(STUSPS, "CA")

// the northeast:
*keep if inlist(STUSPS, "PA", "NY", "NH", "VT", "ME", "MA", "RI", "CT", "NJ")

geo2xy _Y _X, replace proj(albers_sphere)


qui sum _X, meanonly
	local xmin = r(min)
	local xmax = r(max)
qui sum _Y, meanonly
	local ymin = r(min)
	local ymax = r(max)


*the DI graph:
twoway ///
	line _Y _X if states==1											///
		, cmiss(n) lcolor(gs10) lwidth(thin) 						///
		legend(off) yscale(r(`ymin' `ymax') off) ylabel(,nogrid)	/// 
		xlabel(,nogrid) xscale(r(`xmin' `xmax') off) 				///		
	|| ///
	scatter _Y _X if states==0 & division==1 & had2021==1	///
		, m(oh) mcolor(gs4) 								///
	|| ///
	scatter _Y _X if states==0 & division==1 & had2021==0	///
		, m(X) mcolor(orange_red)

graph rename DI

*the DII graph:
twoway ///
	line _Y _X if states==1											///
		, cmiss(n) lcolor(gs10) lwidth(thin) 						///
		legend(off) yscale(r(`ymin' `ymax') off) ylabel(,nogrid)	/// 
		xlabel(,nogrid) xscale(r(`xmin' `xmax') off) 				///		
	|| ///
	scatter _Y _X if states==0 & division==2 & had2021==1	///
		, m(oh) mcolor(gs4) 								///
	|| ///
	scatter _Y _X if states==0 & division==2 & had2021==0	///
		, m(X) mcolor(orange_red)

graph rename DII
		
*the DIII graph:
twoway ///
	line _Y _X if states==1											///
		, cmiss(n) lcolor(gs10) lwidth(thin) 						///
		legend(off) yscale(r(`ymin' `ymax') off) ylabel(,nogrid)	/// 
		xlabel(,nogrid) xscale(r(`xmin' `xmax') off) 				///		
	|| ///
	scatter _Y _X if states==0 & division==3 & had2021==1	///
		, m(oh) mcolor(gs4) 								///
	|| ///
	scatter _Y _X if states==0 & division==3 & had2021==0	///
		, m(X) mcolor(orange_red)

graph rename DIII


/* NorCal D1 Teams:
	Y San Jose State 
	Y California
	Y Stanford
	N UC Davis
	N Sacramento State */
	
/* Northeast D1 Teams:
	Y New Hampshire
	Y Pittsburgh
	Y Penn State
	Y Temple
	Y Rutgers
	N Cornell
	N Brown
	N Yale
	N Pennsylvania */
	
	
/* All non-D1 Teams:
	Y Winona State			3
	Y UW-Whitewater			3
	Y UW-Stout				3
	Y UW-Oshkosh			3
	Y UW-La Crosse			3
	Y UW-Eau Claire			3
	Y Texas Woman's				2
	Y Simpson				3
	Y Hamline				3
	Y Gustavus Adolphus		3
	Y Greenville			3
	Y Centenary College		3
	N Bridgeport 				2
	N Brockport				3
	N Cortland State		3
	N Ithaca College		3
	N Rhode Island College	3
	N Southern Conn.			2
	N Springfield College	3
	N Ursinus College		3
	N West Chester				2
*/
	
