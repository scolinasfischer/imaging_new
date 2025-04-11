# imaging_new
## New and improved code for analysing Ca2+ imaging data

The script "main_analysis" coordinates parameter input and calling of all other functions to conduct processing and analysis of calcium imaging data. 

Options include whether to carry out bleach-correction, plot baseline-adjusted and/or minmax normalised ratios.
There is also the option to carry out type 1 type 2 analysis as developed for AIY, as well as ON/OFF categorisation as developed for RIM and AIB. 

Important notes: 


- ON/OFF categorisation	(AIB/RIM) analysis: things that are missing that could be added:
    - Option to set what time period using for R0, currently using baseline for everything but should be able to plot version using e.g. 10secs prior to odour off or 10 secs prior to odour on. 
    - Cumulative proportion plot
    - Maximum response calculation, save to excel +  plot

- Bleach-correction:
    - Could consider adding the option to bleach-correct depending on R2 value after fitting exponential. Currently this is not the case, bleach-correction is done for all neurons, regardless of R2 value. The problem with only correcting some neurons     though, is that , then, the ratio of neurons that have been bleach-corrected will have values that are much smaller in magnitude than those that have not been bleach corrected , so we would need to come up with a workaround for this.  




Further thoughts: 
  - Timings:
    - Currently the analysis assumes that the frame rate is constant during the entire video, however, this is not the case. The frame rate is set manually to 10, but in reality it fluctuates around 9.9. 
    - This causes error to accumulate, because the frames are not timestamped: we assume that frame 792 corresponds to second  80, and that frame 2079 corresponds to frame 210 (assuming frame rate of               9.9). The final frame corresponds to second 220,          however, because the frame rate is variable, the total frame number is variable:
        - For movies of 220 seconds, which ideally would have 2200 frames, in reality only 2181-2187 frames. 
        - Average frame rate is therefore 2184/2200 = 0,992727273. 
    - I think the best thing to do is to record short videos to reduce the time over which the error can accumulate. 
    - If want to try to correct for this error, I would use an approach along the lines of script “test_timeresampling4” (but haven’t thought it through fully or executed it so make sure to check and think     if there is a better option).


  - Input parameters:
    - It would probably be more reliable to have set input parameters for each neuron, saved as a .mat file, and load it at the beggnining of the analysis, rather than inputting them manually in the script (especially for the infomration in the             structure "moviepars" . 




## Diagram of analysis flow and how different functions are called

START: main_analysis_tailortoRIA.m
│
├──> save_analysis_params               (saves general parameters)
│
├──> OPTIONAL: cycle_to_extract_mat_files
│     └──> extract_mat2xls             (extracts .mat to .xlsx)
│
├──> FOR EACH genotype × condition:
│     └──> process_this_group
│           ├──> get_xlsx_filepaths
│           ├──> FOR EACH worm:
│           │     └──> process_single_worm
│           │           ├──> load_single_worm
│           │           ├──> (optional) bleach_correct
│           │           │     └──> save_channel_data
│           │           ├──> calc_baseline_adj_ratio
│           │           └──> calc_normalised_ratio
│           ├──> analyse_and_plot_group_ratios (x2: badj, norm)
│           │     ├──> compute_plot_statistics
│           │     ├──> plot_avg_with_sem_flexible
│           │     ├──> plot_all_traces_and_avg
│           │     ├──> plot_heatmap
│           │     └──> save_groupdata_to_spreadsheets
│           └──> (optional bleach-correction): same above for notbc_*
│
├──> loop_to_plot_all_conditions_per_genotype
│     └──> plot_avg_with_sem_flexible
│
├──> loop_to_plot_all_genotypes_per_condition
│     └──> plot_avg_with_sem_flexible
│
├──> loop_to_plot_bc_vs_nobc
│     └──> plot_avg_with_sem_flexible
│
├──> loop_to_run_type1type2_analysis
│     └──> type1type2_analysis
│           ├──> compute_plot_statistics
│           ├──> plot_heatmap
│           └──> plot_avg_with_sem_flexible
│
└──> loop_to_run_categorisebyONOFFstates
      ├──> categorisebyONOFFstates
      └──> process_and_plot_categories_ONOFF
            ├──> compute_plot_statistics
            ├──> plot_avg_with_sem_flexible
            ├──> compute_proportions_over_time
            └──> plot_prop_over_time




## Overview of entire analysis: 

 Overview
This pipeline analyzes fluorescence imaging data from single neurons, comparing genotype and condition groups. It supports:
•	Extraction of raw .mat files to .xlsx
•	Ratio calculations (baseline-adjusted and min/max normalized)
•	Optional bleach correction
•	Visualization of single worms and group-level data
•	Categorization into activity states (ON/OFF, Type1/Type2)
•	Generation of summary statistics and spreadsheets
 
Main Script: main_analysis_tailortoRIA.m (last used on RIA, but can also just call it main_analysis)
Purpose
Performs the full analysis from raw data extraction to plotting and summary statistics. It handles wild-type and mutant genotypes across multiple experimental conditions.
Key Features
•	Defines and saves all parameter structures: general, analysis_pars, plotting, moviepars, colors
•	Controls toggles for optional steps:
o	Extracting .mat to .xlsx
o	Bleach correction
o	Per-worm plotting
o	Classification of neuron response patterns
•	Iterates through all genotype × condition combinations
•	Calls core functions for preprocessing, plotting, and classification
 
Full Function Overview 
1. Data Extraction & Loading
cycle_to_extract_mat_files
Loops through all genotype × condition directories and extracts .mat files using extract_mat2xls.
extract_mat2xls
Extracts raw green/red values and ratio data from .mat files. Converts to .xlsx with time annotations. Handles 20fps downsampling.
get_xlsx_filepaths
Returns a list of .xlsx files in a given folder (ignores subfolders).
load_single_worm
Loads a single worm’s .xlsx file and returns raw ratio, green/red values, and time.
 
2. Single Worm Processing
process_single_worm
Processes a single worm:
•	Smooths the ratio trace
•	Optionally applies bleach correction
•	Calculates R0 and Fm ratios
•	Optionally plots the worm trace
bleach_correct
Fits an exponential decay to the green/red channels, applies correction, and generates diagnostic plots.
save_channel_data
Creates summary statistics and structured outputs for each corrected channel.
plot_single_worm
Plots a worm’s ratio trace over time with odour ON/OFF shading.
 
3. Group-Level Analysis
process_this_group
Core per-group analysis function:
•	Loads all worms
•	Calls process_single_worm
•	Aggregates data
•	Plots group average, heatmaps, and all traces
analyse_and_plot_group_ratios
Wraps the full workflow for a single group and ratiotype:
•	Calls compute_plot_statistics
•	Plots average + SEM, all traces, heatmap
•	Saves spreadsheets
compute_plot_statistics
Calculates average, SEM, and time vector from a matrix of worm traces.
save_groupdata_to_spreadsheets
Exports full trace matrix and summary stats to .xlsx.
 
4. Plotting Functions
plot_avg_with_sem_flexible
Generic plotting function for average + SEM across datasets. Used for genotype/condition comparisons.
plot_all_traces_and_avg
Plots all worm traces with the group average overlaid.
plot_heatmap
Creates a heatmap of activity per worm with optional odour annotation and average trace.
plot_prop_over_time
Plots proportion of active neurons over time (non-cumulative).
save_plot
Helper to save plots as .png and .eps.
 
5. Comparison Across Groups
loop_to_plot_all_conditions_per_genotype
Compares all conditions for each genotype on a single plot.
loop_to_plot_all_genotypes_per_condition
Compares all genotypes for each condition on one plot.
loop_to_plot_bc_vs_nobc
Compares bleach-corrected vs non-corrected traces for each group.
 
6. ON/OFF Classification
loop_to_run_categorisebyONOFFstates
Runs categorisebyONOFFstates across all groups. Saves results and plots.
categorisebyONOFFstates
Classifies neurons into:
•	offHIGH: high at end of baseline
•	onLOW: low at end of 1st odour ON
•	bLOW: low at beginning of baseline
process_and_plot_categories_ONOFF
Aggregates classified neurons across genotypes and plots averages + proportions.
compute_proportions_over_time
(Used by above) Calculates binary activation mask and proportion active across time.
 
7. Type1 / Type2 Classification
loop_to_run_type1type2_analysis
Runs type1type2_analysis for each group, saves counts and plots.
type1type2_analysis
Classifies neurons as:
•	Type 1: Peak before time cutoff or below activity threshold 
•	Type 2: Peak after time cutoff and  activity above threshold
•	 Generates:
o	Sorted heatmap
o	Type1/Type2 average traces
o	Spreadsheets of timing/peaks
 
8. Utilities
save_analysis_params
Saves parameter structs to .mat and readable .txt with nested formatting.
writeStructToFile
Helper for recursive structured text saving (handles nested structs).
 
![image](https://github.com/user-attachments/assets/16cfebec-0459-4d60-ad7d-4dce819df41f)
