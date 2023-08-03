\# COVID-19 Data Analysis in R

This project involves an in-depth analysis of COVID-19 data using R. The datasets used include the [OWID (Our World in Data) COVID-19 dataset](https://github.com/owid/covid-19-data) and a demographic dataset.

## Objectives

- Importing and cleaning datasets.
- Performing data transformation operations.
- Creating new variables.
- Conducting predictive modeling using linear regression.
- Evaluating model performance.
- Visualizing relationships between various data points.

## Methodology

1. Imported and cleaned the OWID COVID-19 dataset and a demographic dataset, implementing filters based on ISO code and population size to focus on relevant countries.

2. Transformed the data to meet the needs of the analysis. This included reshaping the demographic data, merging it with the main dataset, and creating new time-shifted variables.

3. Engineered new features such as urban population percentage, fully vaccinated rate, and boosters rate.

4. Built multiple linear regression models using a variety of predictors such as ICU and hospital patients, vaccination data, and socioeconomic factors.

5. Evaluated the performance of each model using Adjusted R-squared and Root Mean Square Error (RMSE). This enabled identification of the best-performing model based on RMSE.

6. Visualized the relationships between variables like new cases, new deaths, and urban population using the ggplot2 package in R.

## Conclusions

The analysis provided valuable insights into the factors influencing COVID-19 outcomes. The best model was identified based on the lowest RMSE, and this model could potentially be used for further studies or to inform policy decisions.

---

To reproduce the analysis, clone the repository, ensure the required R packages are installed, and execute the R scripts in your preferred R environment.
