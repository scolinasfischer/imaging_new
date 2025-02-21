%script to analyse AVB

% This scrip is meant to analyse the green/red fluorescence ratio of the
% AVB neurons. It accepts as input a list of .mat files produced by NEURON.
% The steps in analysis are:
%   - Extract desired features from .mat files and save as excels in new
%   directory
%   - For each condition: 
%        - Calculate the baseline-adjusted ratio for each worm
%        - Calculate the average baseline-adjusted ratio across all worms
%        - Plot: average + SEM, all traces, and heatmap
%   - Across conditions:
%        - Plot 3 conditions + SEM
%


%% set parameters

%general
    
    strain = "BARxxx";
    pars = "20_2_details";
    
    extract_from_mat = "FALSE";
    frame_rate = 9.9;



%colors
    purplergb = [0.6039 0.1961 0.8039]; %colors in rgb code /255
    grayrgb = [0.7020 0.7020 0.7020];
    bluergb     = [179 204 255]/255;
    
    mockgray    = [161 159 161]/255;
    avsvgreen   = [40 243 40]/255;
    sexcondpink = [249 138 122]/255;
    pdf1purple  = [120 0 169]/255;
    
    %Set colors for plot background
    colors = [grayrgb; purplergb; grayrgb; purplergb; grayrgb]; 
    colors3d = colors( :,1);
    colors3d(:,:,2) = colors(:,2);
    colors3d(:,:,3) = colors(:,3);


% % ylimits for plots
    ploty1  = -0.5; %lower y axis limit for single traces plots
    ploty2  = +0.5; %upper y axis limit for single traces plots
    ploty1avg  = -0.5; %lower y axis limit for avg traces plots
    ploty2avg  = +0.5; %upper y axis limit for avg traces plots
    hmy1    = -0.75; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    hmy2    = +0.75; %upper y axis limit for heatmaps nb this sets limit within which scale colors



% Movie parameters
% baseline and time for 220smovie, 10fps, 10sec baseline, 30sON-30sOFF-30sON-30sOFF
    bstart = 792;%first frame of baseline
    bend = 891; %last frame of baseline
    mend = 2079; %last used frame of movie
    full_movie_length = 220; %full movie length in seconds
    max_movie_length = ceil(frame_rate) * full_movie_length; % maximum possible frame of movie (this is frame rate were actually 10fps, which is not. in reality most movies around 2185 frames). 
    timesecs = [80 90 120 150 180 210]; %vector containing timepoints in seconds (time since record start)
    timeframes  = [792 892 1188 1485 1782 2079]; %vector containing timepoints in frames (time since record start)
    timelabels=({'0' '10' '40' '70' '100' '130'});  %cell array containing timepoints in seconds (time since baseline start)
    ycoords = [-10 -10 -10 -10 -10 ; +10 +10 +10 +10 +10; +10 +10 +10 +10 +10; -10 -10 -10 -10 -10 ]; %for patch function





%% data inputs


%set input and output directories 

%set path for mat files of each condition here: 
mock_mat_dir = "/Users/glia/Documents/neuroUCL/phd/current/project/imaging/feb2025_testing/BAR184 AIB copy_mats/mock";
avsv_mat_dir = "/Users/glia/Documents/neuroUCL/phd/current/project/imaging/feb2025_testing/BAR184 AIB copy_mats/avsv";
sexc_mat_dir = "/Users/glia/Documents/neuroUCL/phd/current/project/imaging/feb2025_testing/BAR184 AIB copy_mats/sexc";


%set path for xlsx files of each condition here: 
mock_xlsx_dir = "/Users/glia/Documents/neuroUCL/phd/current/project/imaging/feb2025_testing/xls files/mock";
avsv_xlsx_dir = "/Users/glia/Documents/neuroUCL/phd/current/project/imaging/feb2025_testing/xls files/avsv";
sexc_xlsx_dir = "/Users/glia/Documents/neuroUCL/phd/current/project/imaging/feb2025_testing/xls files/sexc";


%set path for overall analysis output (will need to make subfolders inside)
analysis_output_dir = "/Users/glia/Documents/neuroUCL/phd/current/project/imaging/feb2025_testing/analysis_output";


%% Create cell arrays to hold input directories
% always use r, c for rows + columns.
%columns always used to indicate condition (mock/avsv/sexc)
%row not used in this case but can be used for genotype

all_mat_dirs = {
    mock_mat_dir avsv_mat_dir sexc_mat_dir;
};


all_xlsx_dirs = {
    mock_xlsx_dir avsv_xlsx_dir sexc_xlsx_dir;
};

clear mock_mat_dir avsv_mat_dir sexc_mat_dir
clear mock_xlsx_dir avsv_xlsx_dir sexc_xlsx_dir


%Create string array with the codes for each condition/genotype
%use columns for condition and rows for genotype

codes = [
    "wt_mock_" "wt_avsv_" "wt_sexc_";
    ];



%% if needed, extract .mat files to xlsx

if strcmp(extract_from_mat, "TRUE")
    cycle_to_extract_mat_files(all_mat_dirs, all_xlsx_dirs, frame_rate);
end



%% Process data within each group, call function to process individual worms
% processing means:
%   load data
%   smooth, adjust ratios, etc
%   plot single worms
%   plot accross worm within group

dir_size = size(all_xlsx_dirs);
for r = 1:dir_size(1)
    for c = 1:dir_size(2)
        process_this_group(all_xlsx_dirs{r, c}, analysis_output_dir, codes(r, c), strain, pars, frame_rate, max_movie_length);
    end
end



