library(tidyverse)

# Read the 2 files
owid <- read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv")
demographics <- read_csv("demographics.csv")
# View(owid)
# View(demographics)


# Remove all rows where country_code not exactly 3 letters

owid_filtered <- owid %>% filter(nchar(iso_code) == 3)
demographics_filtered <- demographics %>% filter(nchar(`Country Code`) == 3)
# View(demographics_filtered)
# View(owid_filtered)


# Remove all countries where total population less than 1 million

#demographics_filtered %>% filter(`Series Code` == 'SP.POP.TOTL', YR2015 < 1000000) %>% select(`Country Name`) %>% View()
excluded_countries <- demographics_filtered %>% filter(`Series Code` == 'SP.POP.TOTL', YR2015 < 1000000) %>% select(`Country Name`)
demographic_filtered <- demographics_filtered %>% anti_join(excluded_countries, by = "Country Name")
# View(demographic_filtered)


# Remove all "deaths" columns other than new_deaths_smoothed and remove "excess mortality"

# view(owid_filtered)
# print(colnames(owid_filtered))
owid_filtered <- owid_filtered %>% select(-contains("deaths"), new_deaths_smoothed, -contains("excess_mortality"))
# View(owid_filtered)


# Add a new column new_deaths_smoothed_2wk that has the same values as new_deaths_smoothed but two weeks ahead 

owid_copy <- owid_filtered %>% select(iso_code, date, new_deaths_smoothed)
owid_copy <- owid_copy %>% rename(new_deaths_smoothed_2wk = new_deaths_smoothed)
owid_copy <- owid_copy %>% mutate(date = date + 14)
owid_final <- owid_filtered %>% left_join(owid_copy)
# View(owid_final)

# Tidy tables, as needed. (Hint: only the demographics data is not tidy.)

demographics_filtered1 <- demographic_filtered %>% pivot_longer(cols = YR2015, names_to = "Year", names_prefix = "YR")
demographics_final <- demographics_filtered1 %>% pivot_wider(id_cols = c(`Country Name`, `Country Code`, Year), names_from = `Series Code`, values_from = value)
# View(demographics_final)


# Merge the tables (Hint: join using the 3-letter ISO code)

merged_data <- owid_final %>% inner_join(demographics_final, by = c(iso_code = "Country Code")) 
merged_data <- merged_data %>% select(-`Country Name`, -Year, -continent)
# View(merged_data)


# Print column names of the merged dataset

colnames(merged_data)


# Calculate urban population percentage, fully vaccinated rate, and boosters rate and add these as new columns in the dataset

merged_data <- merged_data %>% mutate(urban_population_percentage = as.numeric(SP.URB.TOTL) / as.numeric(SP.POP.TOTL)) 
merged_data <- merged_data %>% mutate(fully_vaccinated_rate = people_fully_vaccinated / population) 
merged_data <- merged_data %>% mutate(boosters_rate= total_boosters / population)


# Filter out data for the year 2022 and 2023

merged_data_recent <- merged_data %>% filter(date >= as.Date("2022-01-01"))
merged_data_2022 <- merged_data %>% filter(date >= as.Date("2022-01-01"), date < as.Date("2023-01-01"))
merged_data_2023 <- merged_data %>% filter(date >= as.Date("2023-01-01")) 


# Build linear regression models using different sets of predictors and print the summary for each model

#"tests" variables are all NA, many NA for icu_patients, hosp_patients, stringency_index, positive_rate, and some others
model1 <- lm(data = merged_data_2022, new_deaths_smoothed_2wk~icu_patients+hosp_patients+people_fully_vaccinated+population+total_vaccinations)
summary(model1) #Adjusted R-squared = 0.7376

model2 <- lm(data = merged_data_2022, new_deaths_smoothed_2wk~people_fully_vaccinated+icu_patients+hosp_patients+population+extreme_poverty+gdp_per_capita)
summary(model2) #Adjusted R-squared = 0.7286

model3 <- lm(data = merged_data_2022, new_deaths_smoothed_2wk~icu_patients+hosp_patients+human_development_index+SP.URB.TOTL+population)
summary(model3) #Adjusted R-squared = 0.7294

model4 <- lm(data = merged_data_2022, new_deaths_smoothed_2wk~weekly_hosp_admissions+weekly_icu_admissions+hosp_patients+total_vaccinations+extreme_poverty+total_cases)
summary(model4) #Adjusted R-squared = 0.7878

model5 <- lm(data = merged_data_2022, new_deaths_smoothed_2wk~icu_patients+hosp_patients+urban_population_percentage+new_cases_smoothed+people_fully_vaccinated)
summary(model5) #Adjusted R-squared = 0.7377


# Compute RMSE of each model on the 2023 data

library(modelr)
rmse(model1, merged_data_2023) #79.50902
rmse(model2, merged_data_2023) #118.2365
rmse(model3, merged_data_2023) #68.61702
rmse(model4, merged_data_2023) #14.79848
rmse(model5, merged_data_2023) #103.3189

# Calculate RMSE of each model for each country in the 2023 data and sort the results in descending order

merged_data_2023 %>% group_by(iso_code) %>% summarise(rmse = rmse(model1, cur_data())) %>% arrange(desc(rmse), na.last = TRUE) %>% View()
merged_data_2023 %>% group_by(iso_code) %>% summarise(rmse = rmse(model2, cur_data())) %>% arrange(desc(rmse), na.last = TRUE) %>% View()
merged_data_2023 %>% group_by(iso_code) %>% summarise(rmse = rmse(model3, cur_data())) %>% arrange(desc(rmse), na.last = TRUE) %>% View() # best model
merged_data_2023 %>% group_by(iso_code) %>% summarise(rmse = rmse(model4, cur_data())) %>% arrange(desc(rmse), na.last = TRUE) %>% View()
merged_data_2023 %>% group_by(iso_code) %>% summarise(rmse = rmse(model5, cur_data())) %>% arrange(desc(rmse), na.last = TRUE) %>% View()

# Generate plots
most_recently_available <- merged_data_recent %>% group_by(iso_code) %>% top_n(-1, date)
most_recently_available %>% ggplot() + geom_point(mapping = aes(x = new_cases_smoothed, y = new_deaths_smoothed_2wk)) + labs(x = "New Cases Smoothed", y = "New Deaths Smoothed 2 Weeks Ahead")
most_recently_available %>% ggplot() + geom_point(mapping = aes(x = SP.URB.TOTL, y = new_deaths_smoothed)) + labs(x = "Urban Population", y = "New Deaths Smoothed")
