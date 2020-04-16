use "\\Client\C$\Users\mohon\Desktop\hw3\c_ls.dta"
merge m:m ls folio using "\\Client\C$\Users\mohon\Desktop\hw3\iiia_tb.dta"
drop if ls12==.
gen worked_dummy = 0
replace worked_dummy =1 if ls12==1
list worked_dummy ls12 in 1/5
keep if ls02_2>15 & ls02_2<66
gen male_dummy = 0
replace male_dummy=1 if ls04==1
la de male_dummy 0 "Female" 1 "Male"
list male_dummy ls04 in 1/5
drop if worked_dummy==.|male_dummy==.
tabstat worked_dummy, by(male_dummy)
tab male_dummy worked_dummy, row nofreq
egen agegroup = cut(ls02_2), at(15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65)
list agegroup ls02_2 in 1/10
tabstat worked_dummy, by(agegroup)
drop if tb24_26p_cmo==.
gen informal_dummy = 0
replace informal_dummy=1 if tb24_26p_cmo==41 | tb24_26p_cmo==54 | tb24_26p_cmo==72 | tb24_26p_cmo==81 | tb24_26p_cmo==82
list informal_dummy tb24_26p_cmo in 1/10 if tb24_26p_cmo==41 | tb24_26p_cmo==54 | tb24_26p_cmo==72 | tb24_26p_cmo==81 | tb24_26p_cmo==82
tabstat informal_dummy, by(male_dummy)
tab male_dummy informal_dummy, sum(tb44p_2) means
gen monthly_hours = tb44p_2*4.3
gen Hourly_wage = tb35a_2/monthly_hours
tab male_dummy informal_dummy, sum(tb35a_2) means
tab male_dummy informal_dummy, sum(Hourly_wage) means