# Imaging_new Pipeline Documentation

## Overview
This pipeline analyzes fluorescence imaging data from single neurons, comparing genotype and condition groups. It supports:

- Extraction of raw `.mat` files to `.xlsx`
- Ratio calculations (baseline-adjusted and min/max normalized)
- Optional bleach correction
- Visualization of single worms and group-level data
- Categorization into activity states (ON/OFF, Type1/Type2)
- Generation of summary statistics and spreadsheets

## Main Script: `main_analysis_tailortoRIA.m`
*(Currently named after use with RIA, but compatible with other neurons)*

Performs the full analysis from raw data extraction to plotting and summary statistics. It handles wild-type and mutant genotypes across multiple experimental conditions.

### **Key Features**
- Defines and saves all parameter structures: `general`, `analysis_pars`, `plotting`, `moviepars`, `colors`
- Controls toggles for optional steps:
  - Extracting `.mat` to `.xlsx`
  - Bleach correction
  - Per-worm plotting
  - Classification of neuron response patterns
- Iterates through all genotype × condition combinations
- Calls core functions for preprocessing, plotting, and classification


## Diagram of analysis

```text
START: main_analysis_tailortoRIA.m
│
├──> save_analysis_params               (saves general parameters)
│
├──> (optional): cycle_to_extract_mat_files
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
│           │           ├──> calc_normalised_ratio
│           │           └──> (optional) plot_single_worm
│           ├──> analyse_and_plot_group_ratios (×2: badj, norm)
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
├──> loop_to_run_type1type2_analysis (optional)
│     └──> type1type2_analysis
│           ├──> compute_plot_statistics
│           ├──> plot_heatmap
│           └──> plot_avg_with_sem_flexible
│
└──> loop_to_run_categorisebyONOFFstates (optional)
      ├──> categorisebyONOFFstates
      └──> process_and_plot_categories_ONOFF
            ├──> compute_plot_statistics
            ├──> plot_avg_with_sem_flexible
            ├──> compute_proportions_over_time
            └──> plot_prop_over_time
                  └──> save_plot

```

## Function Summaries (Grouped by Purpose)

---

### File Extraction & Input Utilities

#### `cycle_to_extract_mat_files`  
Loops over genotype/condition folders and calls `extract_mat2xls` to convert `.mat` to `.xlsx`.

#### `extract_mat2xls`  
Reads `.mat` files (from NEURON analysis), extracts green/red channels and ratio data, handles frame downsampling, and saves `.xlsx`.

#### `get_xlsx_filepaths`  
Returns list of all `.xlsx` files in a directory. Ignores subfolders.

#### `load_single_worm`  
Loads a worm’s `.xlsx` file, extracting ratio, green/red fluorescence, frame indices, and time (in seconds).

---

### Single Worm Processing

#### `process_single_worm`  
Loads and optionally bleach-corrects a single worm. Calculates baseline-adjusted and normalized ratios. Can plot single-worm traces.

#### `bleach_correct`  
Fits exponential decay to green/red channels, applies correction, computes corrected ratios, and generates plots/Excel summary.

#### `save_channel_data`  
Helper for `bleach_correct`. Structures and summarizes raw, nan-corrected, fit, and corrected channel data.

#### `calc_baseline_adj_ratio`  
Computes baseline-adjusted ratios: `(R - R0) / R0`, using a defined baseline window.

#### `calc_normalised_ratio`  
Computes normalized ratios: `(R - Fmin) / Fmax` using the 5% highest/lowest values from the trace.

#### `plot_single_worm`  
Plots a single worm’s trace with ratio over time and odor buffer overlays.

---

### Group-Level Analysis & Plotting

#### `process_this_group`  
Loops through all worms in a genotype × condition group. Applies per-worm processing, generates group matrices, and triggers `analyse_and_plot_group_ratios`.

#### `analyse_and_plot_group_ratios`  
Computes average and SEM across all worms. Generates plots:
- Avg ± SEM
- All traces + avg
- Heatmap  
Also saves group Excel files.

#### `compute_plot_statistics`  
Computes average, SEM, and time vector for a matrix of traces.

#### `plot_avg_with_sem_flexible`  
Plots one or more traces with SEM shading, flexible for any number of conditions/genotypes.

#### `plot_all_traces_and_avg`  
Plots all worm traces and overlays group average trace in bold.

#### `plot_heatmap`  
Generates heatmap of all traces, plus odor ON/OFF rows and average.

#### `save_groupdata_to_spreadsheets`  
Saves full group trace matrix, plus [time, avg, SEM] data to `.xlsx`.

#### `save_analysis_params`  
Saves the parameter structs (`general`, `plotting`, etc.) as both `.mat` and `.txt` (recursively handles nested structs).

---

### Summary Visualization (Multi-group)

#### `loop_to_plot_all_conditions_per_genotype`  
For each genotype, plots all 3 conditions (mock, avsv, sexc) on a shared plot.

#### `loop_to_plot_all_genotypes_per_condition`  
For each condition, plots all genotypes (e.g. wt, mutant) on a shared plot.

#### `loop_to_plot_bc_vs_nobc`  
Plots bleach-corrected vs uncorrected traces for all genotype × condition combinations.

---

### Classification: ON/OFF & Type1/Type2

#### `loop_to_run_categorisebyONOFFstates`  
Runs `categorisebyONOFFstates` and `process_and_plot_categories_ONOFF` to separate neurons into OFF-high, ON-low, or baseline-low states.

#### `categorisebyONOFFstates`  
Classifies each neuron based on its trace at specific key frames (end of baseline, end of first odor, etc.) into OFF-high, ON-low, or B-low categories.

#### `process_and_plot_categories_ONOFF`  
Computes averages and SEMs for each ON/OFF category, saves and plots category traces and proportion of active neurons over time.

#### `compute_proportions_over_time`  
Calculates the proportion of worms classified as active at each frame in the time series.

#### `plot_prop_over_time`  
Plots both non-cumulative and cumulative proportions of active neurons over time.

#### `save_plot`  
Helper function for `plot_prop_over_time`. Saves plot to both PNG and optional EPS.

---

### Classification: Type1 / Type2

#### `loop_to_run_type1type2_analysis`  
Runs `type1type2_analysis` for all genotype × condition combinations.

#### `type1type2_analysis`  
Classifies each neuron as Type 1 (early peak) or Type 2 (delayed peak) based on response timing and threshold.  
Generates:
- Sorted heatmap  
- Average traces  
- Category-wise Excel files

---



### Important notes: 


- ON/OFF categorisation	(AIB/RIM) analysis: things that are missing that could be added:
    - Option to set what time period using for R0, currently using baseline for everything but should be able to plot version using e.g. 10secs prior to odour off or 10 secs prior to odour on. 
    - Cumulative proportion plot
    - Maximum response calculation, save to excel +  plot

- Bleach-correction:
    - Could consider adding the option to bleach-correct depending on R2 value after fitting exponential. Currently this is not the case, bleach-correction is done for all neurons, regardless of R2 value. The problem with only correcting some neurons     though, is that , then, the ratio of neurons that have been bleach-corrected will have values that are much smaller in magnitude than those that have not been bleach corrected , so we would need to come up with a work
around for this.  




### Further thoughts: 
  - Timings:
    - Currently the analysis assumes that the frame rate is constant during the entire video, however, this is not the case. The frame rate is set manually to 10, but in reality it fluctuates around 9.9. 
    - This causes error to accumulate, because the frames are not timestamped: we assume that frame 792 corresponds to second  80, and that frame 2079 corresponds to frame 210 (assuming frame rate of               9.9). The final frame corresponds to second 220,          however, because the frame rate is variable, the total frame number is variable:
        - For movies of 220 seconds, which ideally would have 2200 frames, in reality only 2181-2187 frames. 
        - Average frame rate is therefore 2184/2200 = 0,992727273. 
    - I think the best thing to do is to record short videos to reduce the time over which the error can accumulate. 
    - If want to try to correct for this error, I would use an approach along the lines of script “test_timeresampling4” (but haven’t thought it through fully or executed it so make sure to check and think     if there is a better option).


  - Input parameters:
    - It would probably be more reliable to have set input parameters for each neuron, saved as a .mat file, and load it at the beggnining of the analysis, rather than inputting them manually in the script (especially for the infomration in the             structure "moviepars" . 

