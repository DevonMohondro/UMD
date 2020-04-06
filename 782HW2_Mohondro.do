use "\\Client\C$\Users\mohon\Desktop\Stata\i_cs.dta", clear
local weeklyvar "cs02a_12 cs02a_22 cs02a_32 cs02a_42 cs02a_52 cs02a_62 cs02a_72 cs02a_82"
foreach x in `weeklyvar' {
generate ics_monthly_`x' = `x' * 4.3
}
local 1month_var "cs16a_2 cs16b_2 cs16c_2 cs16d_2 cs16e_2 cs16f_2 cs16g_2 cs16h_2 cs16i_2"
foreach x in `1month_var' {
generate ics_monthly_`x' = `x' 
}
merge m:m folio using "\\Client\C$\Users\mohon\Desktop\Stata\i_cs1.dta"
local 3month_var "cs22a_2 cs22b_2 cs22c_2 cs22d_2 cs22e_2 cs22f_2 cs22g_2 cs22h_2"
foreach x in `3month_var' {
generate ics1_monthly_`x' = `x' /3
}
egen total_cons = rowtotal(ics1_monthly_cs22a_2 ics1_monthly_cs22b_2 ics1_monthly_cs22c_2 ics1_monthly_cs22d_2 ics1_monthly_cs22e_2 ics1_monthly_cs22f_2 ics1_monthly_cs22g_2 ics1_monthly_cs22h_2 ics_monthly_cs02a_12 ics_monthly_cs02a_22 ics_monthly_cs02a_32 ics_monthly_cs02a_42 ics_monthly_cs02a_52 ics_monthly_cs02a_62 ics_monthly_cs02a_72 ics_monthly_cs02a_82 ics_monthly_cs16a_2 ics_monthly_cs16b_2 ics_monthly_cs16c_2 ics_monthly_cs16d_2 ics_monthly_cs16e_2 ics_monthly_cs16f_2 ics_monthly_cs16g_2 ics_monthly_cs16h_2 ics_monthly_cs16i_2)
sum total_cons
egen total_cons_sd =std(total_cons)
histogram total_cons if total_cons_sd<3, bin(10)
drop _merge
merge m:m folio using "\\Client\C$\Users\mohon\Desktop\Stata\c_ls.dta"
egen family_members = count(ls), by(folio)
histogram family_members, bin(10) title(Family members) xtitle(# of family members) 
gen percap_consum = total_cons / family_members
egen percap_consum_sd = std(percap_consum)
histogram percap_consum  if percap_consum_sd <3, bin(100)
gen poverty_line = 500
gen p0 =percap_consum <poverty_line
la var p0 "poverty incidence"
la de p0 0 "non-poor" 1 "poor"
sum p0
local p0_tot=r(mean)
display "Percentage living under povtery: `p0_tot'"
gen p1= (poverty_line-percap_consum)*p0
egen p1_sum = sum(p1) 
count if p0==1
local poverty_observations = r(N)
display `poverty_observations'
gen avg_pov_gap = p1_sum/ `poverty_observations'
list avg_pov_gap in 1/1
gen p2= (poverty_line-percap_consum)^2*p0
egen p2_sum = sum(p2) 
count if p0==1
local poverty_observations = r(N)
display `poverty_observations'
gen avg_pov_gap_sq = p2_sum/ `poverty_observations'
list avg_pov_gap_sq in 1/1
drop _merge
merge m:m folio using "\\Client\C$\Users\mohon\Desktop\Stata\c_portad.dta"
tab estrato p0, row
gen rural = 0 
replace rural = 1 if estrato==3 
replace rural = 1 if estrato==4
egen p1_sum_rural = sum(p1) if rural==1
count if rural==1
local poverty_observations_rural = r(N)
display `poverty_observations_rural'
gen avg_pov_gap_rural = p1_sum_rural/ `poverty_observations_rural'
list avg_pov_gap_rural in 1/1
gen urban = 0 
replace urban = 1 if estrato==1 
replace  urban = 1 if estrato==2
egen p1_sum_urban = sum(p1) if urban==1
count if urban==1
local poverty_observations_urban = r(N)
display `poverty_observations_urban'
gen avg_pov_gap_urban= p1_sum_rural/ `poverty_observations_urban'
list avg_pov_gap_urban in 1/1
sort percap_consum
gen rank_percap_consum  =_n
cumul percap_consum, generate(cum_percap_consum)
egen total_percap_consum =total(percap_consum)
sort percap_consum
xtile q5=percap_consum, n(5)
sum percap_consum
scalar percap_consum_sum=r(sum)
 forvalues i = 1/5 {
	quietly sum percap_consum if q5==`i'
	scalar percap_consum_`i'_sum=r(sum)
	scalar percap_consum_`i'_share=percap_consum_`i'_sum/percap_consum_sum
	}
scalar list  percap_consum_1_share  percap_consum_2_share  percap_consum_3_share  percap_consum_4_share  percap_consum_5_share


gen cum_total_conspc=0
replace cum_total_conspc=  percap_consum if _n==1
local N=_N
forvalues k=2/`N' {
	quietly replace cum_total_conspc = percap_consum+cum_total_conspc[_n-1] if _n==`k'
	}
gen cuml_conspc=cum_total_conspc/total_percap_consum
count
local observations = r(N)
gen pop_share = rank_percap_consum/`observations'
line cuml_conspc pop_share ||line pop_share pop_share, title("lorenz curve") xtitle("cum. % of households") ytitle("cum. % of consumption per capita")
correlate percap_consum cuml_conspc, covariance
scalar conspc_cov=r(cov_12)
su percap_consum
scalar conspc_mean=r(mean)
scalar gini=2*conspc_cov/conspc_mean
display gini