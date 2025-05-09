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


%% set parameters, organised into structures for ease of function calling

%general
    
    general.strain = "BARxxx";
    general.pars = "7_3_details";
    
    general.extract_from_mat = "FALSE";
    general.frame_rate = 9.9;

    general.wt_genotype_code = "wt"; %for r = 1
    general.mutant_genotype_code1 = "pdf1"; %for r = 2

  

%Colors
    % Define colors struct
    colors.purple = [0.6039 0.1961 0.8039];  % Purple RGB
    colors.gray = [0.7020 0.7020 0.7020];    % Gray RGB
    colors.blue = [179 204 255] / 255;       % Blue RGB
    colors.mockgray = [161 159 161] / 255;   % Mock gray RGB
    colors.avsvgreen = [40 243 40] / 255;    % Green RGB
    colors.sexcondpink = [249 138 122] / 255; % Pink RGB
    colors.pdf1purple = [120 0 169] / 255;   % PDF1 purple RGB
    
    % Define 3D color array for patch colors
    patchcolors = [colors.gray; colors.purple; colors.gray; colors.purple; colors.gray]; 
    patchcolors3d = patchcolors(:,1);
    patchcolors3d(:,:,2) = patchcolors(:,2);
    patchcolors3d(:,:,3) = patchcolors(:,3);
    
    % Add patchcolors3d to struct
    colors.patchcolors3d = patchcolors3d;
    clear patchcolors patchcolors3d %clear so as to not clutter workspace


%Y limits for plots

%for baseline-adjusted ratios (R0)
    plotting.R0ploty1  = -0.5; %lower y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty2  = +0.5; %upper y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty1avg  = -0.5; %lower y axis limit for avg traces plots
    plotting.R0ploty2avg  = +0.5; %upper y axis limit for avg traces plots
    plotting.R0hmy1    = -0.75; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.R0hmy2    = +0.75; %upper y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.R0name  = "badj";

%for maxmin normalised ratios (Fm)
    plotting.Fmploty1  = -0.1; %lower y axis limit for single traces plots maxmin normalised ratios
    plotting.Fmploty2  = +0.5; %upper y axis limit for single traces plots maxmin normalised ratios   
    plotting.Fmploty1avg  = -0.1; %lower y axis limit for avg traces plots
    plotting.Fmploty2avg  = +0.5; %upper y axis limit for avg traces plots
    plotting.Fmhmy1    = -0.1; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.Fmhmy2    = +0.75; %upper y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.Fmname  = "norm";


% Movie parameters

    % baseline and time for 220smovie, 10fps, 10sec baseline, 30sON-30sOFF-30sON-30sOFF
    moviepars.bstart = 792;%first frame of baseline
    moviepars.bend = 891; %last frame of baseline
    moviepars.mend = 2079; %last used frame of movie
    moviepars.full_movie_lengthS = 220; %full movie length in seconds
    moviepars.max_movie_length = ceil(general.frame_rate) * moviepars.full_movie_lengthS; % maximum possible frame of movie (this is frame rate were actually 10fps, which is not. in reality most movies around 2185 frames). 
    moviepars.timesecs = [80 90 120 150 180 210]; %vector containing timepoints in seconds (time since record start)
    moviepars.timeframes  = [792 892 1188 1485 1782 2079]; %vector containing timepoints in frames (time since record start)
    moviepars.timelabels=({'0' '10' '40' '70' '100' '130'});  %cell array containing timepoints in seconds (time since baseline start)
    moviepars.ycoords = [-10 -10 -10 -10 -10 ; +10 +10 +10 +10 +10; +10 +10 +10 +10 +10; -10 -10 -10 -10 -10 ]; %y coords for patch function
    moviepars.xcoords = [moviepars.timesecs(1:end-1); moviepars.timesecs(1:end-1); moviepars.timesecs(2:end); moviepars.timesecs(2:end)]; %x coords for patch function





%% data inputs


%set input and output directories 

%set path for mat files of each condition here: 
mock_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AVB/mock";
avsv_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AVB/avsv";
sexc_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AVB/sexc";

%set path for xlsx files of each condition here: 
mock_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/newAVBxls/mock";
avsv_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/newAVBxls/avsv";
sexc_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/newAVBxls/sexc";


%set path for overall analysis output
% subfolders inside this need to have exact name as the "codes" listed
% below for each group
analysis_output_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/newAVBoutput6";


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

if strcmp(general.extract_from_mat, "TRUE")
    cycle_to_extract_mat_files(all_mat_dirs, all_xlsx_dirs, general.frame_rate);
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
        [badjratios_avg, SEMbadj, normratios_avg, SEMnorm, all_secs] = process_this_group(all_xlsx_dirs{r, c}, analysis_output_dir, codes(r, c), general, colors, plotting, moviepars);
        

        %Save adjratios and SEM of each condition / genotype under different name
         % Store processed data dynamically based on genotype (or something else)
            if r == 1
                genotype = general.wt_genotype_code; % Wild-type
            elseif r == 2
                genotype = general.mutant_genotype_code1; % Mutant
            else
                error("Unexpected genotype row index: %d", r);
            end
            
            % Extract condition name from codes (e.g., "wt_mock_", "mt_avsv_")
            condition_name = codes(r, c);
            
            % Store baseline-adjusted ratios and SEM values
            bratio_data.(genotype).(condition_name) = badjratios_avg; 
            bSEM_data.(genotype).(condition_name) = SEMbadj;

            % Store minmax normalised ratios and SEM values
            nratio_data.(genotype).(condition_name) = normratios_avg; 
            nSEM_data.(genotype).(condition_name) = SEMnorm;


    end
end


%% Create plots showing multiple conditions

%3cond plots for baseline-adjusted (R0)
plot_avg_with_sem_3cond(all_secs, bratio_data, bSEM_data, "badjratios", analysis_output_dir,colors, plotting, moviepars, general);

%3cond plots for normalised (Fm)
plot_avg_with_sem_3cond(all_secs, nratio_data, nSEM_data, "normratios",analysis_output_dir, colors, plotting, moviepars, general);





%%%%%%% testing

plot_avg_with_sem_3cond(all_secs, bratio_data2, bSEM_data2, "badjratios", analysis_output_dir,colors, plotting, moviepars, general);
