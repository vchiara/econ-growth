*change working directory
cd \\tsclient\val\Documents\Stata\growth

*create log file
log using growth.log, replace

*set manual scrolling off
set more off

*open dataset
use growth_data

*inspect dataset
sum

*declare data as panel
encode countrycode, gen (country)
xtset country time

*1.  Compute an index of tourism specialization TS_E3 as the ratio between tourism expenditure and total GDP:
gen TS_E3 = int_tou_exp / gdp_curr

*2. Codify a variable called Income_Group:
*calculate average income per capita by country
bysort country (time): egen gdp_avg = mean(gdppc_ppp_cons)

*generate income groups based on the avg gdp per capita of each country
recode gdp_avg (min/3000 = 1) (3001/9000 = 2) (9001/20000 = 3) (20001/max = 4), gen(income_group)

*3. Build a table with the average value of the index TS_E3 of each group and for each period of five years:
*generate variable for 5-year periods
bysort country (time): gen period = ceil(_n/5)

*calculate the average value of TS_E3 for each period and income group
bysort income_group period: egen TS_avg = mean(TS_E3) if income_group!=.
sort country time

*label variable for table presentation
label variable income_group "Income Group"

*display table
tabdisp period income_group, c(TS_avg)

*4. Build the growth rate of income per capita (gdppc_cons) and run a regression in which it depends on TS_E3
*calculate yearly growth rate of income per capita
bysort country (time): gen growth_rate = D.gdppc_cons/L.gdppc_cons

*run regression model for growth rate of income per capita
reg growth_rate TS_E3 inv_gdp gov_gdp int_edu_lab L.gdppc_cons fdi_in_gdp

*order final dataset
order time period countryname countrycode country, first

*inspect final dataset
sum

*save final dataset
save growth.dta, replace
