/*

https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2023&layergroup=States+%28and+equivalent%29

*/

ssc install shp2dta

global route "C:/Users/toom/Desktop/long_layoff"


cd "$route/data/cb_2018_us_state_500k"

shp2dta using cb_2018_us_state_500k, data(data) coord(coords) replace

use coords, clear

merge m:1 _ID using data, keep(1 3) nogen

drop if inlist(STUSPS, "AK", "AS", "GU", "HI", "MP", "PR", "VI")

append using "$route/data/school_coords.dta"

gen states = STATEFP!=""



twoway ///
	area _Y _X if states==1				///
		, cmiss(n) fi(25) col(gray) 	///
		leg(off) ysc(off) yla(,nogrid)	/// 
		xla(,nogrid) xsc(off) 			///
		graphr(fc(white)) 				///
	|| ///
	scatter _Y _X if states==0 & division!=1 & had2021==1	///
		, m(T) mcolor(green)								///
	|| ///
	scatter _Y _X if states==0 & division!=1 & had2021==0	///
		, m(T) mcolor(red)




/* NorCal Teams:
	Y San Jose State 
	Y California
	Y Stanford
	N UC Davis
	N Sacramento State	*/
	
/* Northeast Teams:
	Y New Hampshire
	Y Pittsburgh
	Y Penn State
	Y Temple
	Y LIU* (but no pre-2021 seasons, so yeet)
	Y Rutgers
	N Brockport
	N Cortland State
	N Cornell
	N Ithaca College
	N Springfield College
	N Rhode Island College
	N Brown
	N Southern Conn.
	N Yale
	N Bridgeport
	N Ursinus College
	N West Chester
	N Pennsylvania */
	
