# Overview
This project is a basic Frequency/Severity simulation and analyzer

## Requirements
- Microsoft Excel with VBA enabled
- Mac
    + Can't use another OS because the VBA that runs when the "Run Simulation" button is clicked uses the "AppleScriptTask" function to run an AppleScript file that runs the R script that generates the csv that the dashboard pulls data from
        - Note: it seems like it's not too bad to add support to windows because there's the wscript thing that seems nicer than the applescript fxnality
    + Note: I think it would work on windows if you didn't use the "Run Simulation" button
        - You could run the R script separately, and then click "Data > Refresh All" to update all the data
        - TODO: give an example for how to run the Rscript from the terminal

## How to Use
1. TODO: run the setup script.
2. TODO: enter the settings in the "Settings" page.
3. In the two tables in the top-left of the "Dashboard" sheet, choose which distribution parameters you want to use.
4. Click **Run Simulation.**
    - An R script will run to generate simulated claims data in a csv.
    - PowerQuery will load the csv and clean it up so it's usable.
5. Summary statistics and charts are shown using the data from the generated csv.
6. (optional) Click **Generate PDF** to export the dashboard as a PDF.

## Dashboard Output
There are 4 sections on the dashboard. The first is for user inputs, and the last three hold the following:

- Frequency
    - Chart of the PDF
    - Distribution summary
        + Note: "0-claim Policies" refers to the number of policies that had 0 claims
    - Percentiles
        + Note: users can change which percentiles are shown
- Severity
    - boxplot and empirical CDF charts
    - Distribution summary
        + Note: the "Total Losses" statistic is the total claim amount across all policies
    - Largest claims
        + This table holds the top 5 largest claims, along with their policy ID's and the date they occurred on
    - Percentiles
        + Note: Users can change which percentiles are shown
- Policy-Level Loss
    - boxplot and empirical CDF charts
    - Distribution summary
    - Top Policies by Loss Amount
        + This table holds the 5 policies with the highest total losses
    - Percentiles
        + Users can change which percentiles are shown
- Export dashboard to PDF functionality
