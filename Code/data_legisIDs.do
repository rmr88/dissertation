
cd "C:\Users\Robbie\Documents\dissertation\Data\working"
use "govTrackIDs.dta", clear

drop first
drop if strpos(name, "Res.Comm.") > 0 | strpos(name, "Del.") > 0
ren icpsrID icpsrID2

gen nameLast = strupper(substr(name, 1, strpos(name, "[")-2))
replace nameLast = subinstr(nameLast, " JR.", "", .)
replace nameLast = subinstr(nameLast, " II", "", .)
replace nameLast = strtrim(substr(nameLast, strrpos(nameLast, " "), .))

gen nameFirst = strtrim(substr(name, strpos(name, ".")+1, .))
replace nameFirst = strupper(substr(nameFirst, 1, strpos(nameFirst, " ")))

gen state = substr(name, strpos(name, ",")+2, 2)

**HARDCODES**
replace nameLast = "ANDREWS" if govTrackID == 400008
replace nameFirst = "ROBERT" if govTrackID == 400008
replace state = "NJ" if govTrackID == 400008
replace nameLast = "WATT" if govTrackID == 400424
replace nameFirst = "MELVIN" if govTrackID == 400424
replace state = "NC" if govTrackID == 400424
replace nameLast = "COWAN" if govTrackID == 412586
replace nameFirst = "WILLIAM" if govTrackID == 412586
replace state = "MA" if govTrackID == 412586
replace nameLast = "OBAMA" if govTrackID == 400629
replace state = "IL" if govTrackID == 400629
replace nameLast = "CANTOR" if govTrackID == 400060
replace state = "VA" if govTrackID == 400060
replace nameLast = "CHIESA" if govTrackID == 412597
replace state = "NJ" if govTrackID == 412597
replace nameLast = "EMERSON" if govTrackID == 400121
replace nameFirst = "JO ANN" if govTrackID == 400121
replace state = "MO" if govTrackID == 400121
replace nameLast = "BONNER" if govTrackID == 400038
replace state = "AL" if govTrackID == 400038
replace nameLast = "ALEXANDER" if govTrackID == 400006
replace state = "LA" if govTrackID == 400006
replace nameLast = "RADEL" if govTrackID == 412528
replace state = "FL" if govTrackID == 412528
replace nameLast = "HERRERA" if govTrackID == 412486
replace nameLast = "GUTIERREZ" if govTrackID == 400163
replace nameLast = "VAN HOLLEN" if govTrackID == 400415
replace nameLast = "JACKSON-LEE" if govTrackID == 400199
replace nameLast = "LUJAN" if govTrackID == 412293
replace nameLast = "MCMORRIS" if govTrackID == 400659
replace nameLast = "WASSERMAN-SCHULTZ" if govTrackID == 400623
replace nameLast = "VELAZQUEZ" if govTrackID == 400416
//end hardcodes

joinby nameLast state using "icpsrIDs.dta", unmatched(both)

**HARDCODES**
drop if govTrackID == 400067 & nameFull == "CARSON, ANDRE"
drop if govTrackID == 400095 & nameFull == "DAVIS, THOMAS M."
drop if govTrackID == 400096 & nameFull == "DAVIS, LINCOLN"
drop if govTrackID == 400098 & nameFull == "DAVIS, JO ANN"
drop if govTrackID == 400107 & nameFull == "DIAZ-BALART, M."
drop if govTrackID == 400108 & nameFull == "DIAZ-BALART, LINCOLN"
drop if govTrackID == 400160 & nameFull == "GREEN, AL"
drop if govTrackID == 400191 & nameFull == "HUNTER, DUNCAN D."
drop if govTrackID == 400204 & nameFull == "JOHNSON, SAM"
drop if govTrackID == 400206 & nameFull == "JOHNSON, EDDIE BERNICE"
drop if govTrackID == 400243 & nameFull == "LIPINSKI, DANIEL"
drop if govTrackID == 400256 & nameFull == "MATSUI, DORIS"
drop if govTrackID == 400277 & nameFull == "MILLER, GEORGE"
drop if govTrackID == 400278 & nameFull == "MILLER, GARY G."
drop if govTrackID == 400285 & nameFull == "MURPHY, PATRICK J."
drop if govTrackID == 400306 & nameFull == "OWENS, BILL"
drop if govTrackID == 400312 & icpsrID2 != icpsrID //Donald Payne
drop if govTrackID == 400356 & nameFull == "SANCHEZ, LINDA"
drop if govTrackID == 400363 & nameFull == "SCOTT, AUSTIN"
drop if govTrackID == 400630 & nameFull == "LIPINSKI, WILLIAM O."
drop if govTrackID == 400653 & nameFull == "GREEN, GENE"
drop if govTrackID == 400663 & nameFull == "MATSUI, ROBERT TAKEO"
drop if govTrackID == 405823 & icpsrID2 != icpsrID //Allan Hunter
drop if govTrackID == 406058 & icpsrID2 != icpsrID //Lyndon Johnson
drop if govTrackID == 407701 & icpsrID2 != icpsrID //Clement Miller
drop if govTrackID == 407706 & nameFull == "MILLER, GARY G."
drop if govTrackID == 408052 & icpsrID2 != icpsrID //Austin Murphy
drop if govTrackID == 412233 & nameFull == "MURPHY, TIM"
drop if govTrackID == 412258 & nameFull == "CARSON, JULIA"
drop if govTrackID == 412283 & nameFull == "HUNTER, DUNCAN L."
drop if govTrackID == 412383 & nameFull == "OWENS, MAJOR ROBERT ODELL"
drop if govTrackID == 412417 & nameFull == "SCOTT, DAVID"
drop if govTrackID == 403231 & icpsrID2 != icpsrID //Clifford Davis
drop if govTrackID == 404954 & icpsrID2 != icpsrID //Sam Hall
drop if govTrackID == 412235 & nameFull == "DAVIS, LINCOLN"
drop if govTrackID == 412277 & icpsrID == 90901
drop if govTrackID == 400006 & icpsrID == 90327
drop if govTrackID == 400165 & icpsrID == 94828
drop if govTrackID == 400510 //Dan Miller
drop if govTrackID == 400096 //Lincoln Davis
drop if govTrackID == 410067 //Linda Smith
drop if govTrackID == 402284 //Walter Capps
drop if govTrackID == 406024 //Clete Johnson
drop if govTrackID == 400619 //Ken Salazar
drop if govTrackID == 400511 //Carrie Meek
drop if govTrackID == 300153 //Jean Carnahan
//end hardcodes

replace icpsrID2 = icpsrID if missing(icpsrID2) //don't do this until resolving duplicates
drop if icpsrID2 != icpsrID & !missing(icpsrID)
drop if missing(icpsrID) & missing(icpsrID2)

drop icpsrID
ren icpsrID2 icpsrID
drop if missing(govTrackID)

save "idsMerged.dta", replace
