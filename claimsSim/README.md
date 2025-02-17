# Overview
This project is a basic Frequency/Severity simulation and analyzer. You can use it to simulate and visualize basic claims data.

## Requirements
- Microsoft Excel with VBA enabled
- Mac
    + Mac is required because the VBA that runs when the "Run Simulation" button is clicked uses the AppleScriptTask function to run an AppleScript file that runs an R script to generate the CSV data that populates the dashboard.

## Dashboard Output
There are 4 sections on the dashboard:
- Inputs
    - User-configurable distribution parameters for claim frequency and severity
- Frequency
    - Bar chart displaying the Probability Distribution Function (PDF) of claim counts per policy.
    - Distribution Summary
        + Note: "0-claim Policies" refers to the number of policies that had 0 claims.
    - Percentiles
        + Note: users can change which percentiles are shown
- Severity
    - boxplot and CDF (Cumulative Distribution Function) charts of claim amounts
    - Distribution summary
        + Note: the "Total Losses" statistic is the total claim amount across all policies
    - Largest claims
        + This table holds the top 5 largest individual claims, along with Policy ID and Claim Date
    - Percentiles
        + Note: Users can change which percentiles are shown
- Policy-Level Loss
    - Boxplot and CDF chart of total losses per policy.
    - Distribution summary
    - Top Policies by Loss Amount
        + This table holds the 5 policies with the highest total losses
    - Percentiles
        + Users can change which percentiles are shown

## How to Use
1. Run the setup script (claimsSim/setup.sh)
    - The setup script copies an AppleScript (runRScript.scpt - the compiled version of runRScript.applescript) to a directory Excel looks in when the AppleScriptTask method is used in VBA.
2. Open ClaimsAnalysis.xlsm
    - Click "Enable Macros"
    - Click "Enable Content" on the warning that says "Security Warning External Data Connections have been disabled"
    - Launch the powerquery editor, click "Options", then under "Project" click "Privacy" and check "Allow combining data from multiple sources. This could expose sensitive or confidential data to an unauthorized person" and click "Okay"
3. Go to the "Settings" sheet and:
    - Update the Rscript path to be where Rscript is installed on your computer
        - To find this, run ```which Rscript``` from your terminal
        - If this returns "Rscript not found", then you'll need to install it (https://cran.r-project.org/bin/macosx/). Once it's installed, run ```which Rscript``` to see where Rscript is on your computer, and then update the "Rscript path" setting in the spreadsheet if it's different
    - (Optional) Update the "Max Claim Amount" setting if you want to - this is just the policy limit for each claim - when the simulation is run and powerquery pulls in the claims data, it will cap claims with this amount
    - The "Num Policies" setting is currently hardcoded in the simulation code, so this setting is not adjustable. Support for changing this might be added in the future.
4. In the two tables in the top-left of the "Dashboard" sheet, choose your frequency and severity distribution parameters.
5. Click **Run Simulation.**
    - An R script will run to generate simulated claims data and save it to a csv.
    - PowerQuery loads the csv and processes it so that the dashboard can use it.
6. Summary statistics and charts are updated with the data from the generated csv.
7. (Optional) Click **Generate PDF** to export the dashboard as a PDF.
