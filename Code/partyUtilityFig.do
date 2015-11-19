*** Party Utility Figure ***

*Setup
global options `"xline(0, lcolor(gs14)) xtitle("Ideology") xscale(range(-4 1)) xlab(-4(1)1) yline(0, lcolor(gs14)) ytitle("Utility") ylab(-2(0.5)1, nogrid) graphregion(color(white)) leg(region(lcolor(white)))"'
global activOpts "lcolor(black) leg(lab(1 Activist))"
global estabOpts "lcolor(gs10) leg(lab(2 Establishment))"
global dir "C:\Users\Robbie\Documents\dissertation\Figs"

*Graphs
foreach ip in 0 -0.5 -1 -1.5 -2 -2.5 {
	local u = `ip' + 1
	local l = `ip' - 1
	local ip2 = abs(`ip'*10)
	twoway (function y = 1 - abs(x-`ip') - abs(x) + (abs(x) * abs(x-`ip')), ///
		range(`l' `u') $activOpts) (function y = 1 - abs(x-`ip'), ///
		range(`l' `u') $estabOpts), $options name("Ip`ip2'", replace) ///
		title("Ip = `ip'", color(black)) xline(`ip', lcolor(gs14) lpattern(dash))
}

*Combine, save
grc1leg Ip0 Ip5 Ip10 Ip15 Ip20 Ip25, graphregion(color(white)) ///
	title("Utility Functions with Different District Median Ideologies", color(black)) ///
	note("Establishment utility = 1 - |i - Ip| ; Activist utility = 1 - |i - Ip| - |i| + |i^2 - iIp|")
graph export "$dir\partyUtilities.png", width(800) replace
graph export "$dir\partyUtilities.eps", replace

