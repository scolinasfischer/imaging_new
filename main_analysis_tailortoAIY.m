%script to analyse basic neuron

% This scrip is meant to analyse the green/red fluorescence ratio.
% It accepts as input a list of .mat files produced by NEURON.
% The steps in analysis are:
%   - Extract desired features from .mat files and save as excels in new
%   directory
%   - For each condition: 
%        - Calculate the baseline-adjusted ratio for each worm
%        - Calculate the average baseline-adjusted ratio across all worms
%        - Plot: average + SEM, all traces, and heatmap
%   - Across conditions:
%        - Plot 3 conditions + SEM




%%input

%% data inputs

%set input and output directories 

% set directories for wild-type data
%set path for mat files of each condition here: 
mock_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR224/AIY MOCK MATS 10FPS";
avsv_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR224/AIY AV MATS 10FPS";
sexc_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR224/AIY SEX COND MATS 10FPS";

%set path for xlsx files of each condition here: 
mock_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/wt_mock_";
avsv_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/wt_avsv_";
sexc_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/wt_sexc_";



% set directories for mutant data

%set path for mat files of each condition here: 
mt_mock_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR227/BAR227 AIY MOCK pdf1 mut";
mt_avsv_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR227/BAR227 AIY AVERSIVE pdf1 mut";
mt_sexc_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR227/BAR227 AIY SEX COND pdf1 mut";

%set path for xlsx files of each condition here: 
mt_mock_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/pdf1_mock_";
mt_avsv_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/pdf1_avsv_";
mt_sexc_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/pdf1_sexc_";





%set path for overall analysis output
% subfolders inside this need to have exact name as the "codes" listed
% below for each group
analysis_output_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYoutput3";


%% set parameters, organised into structures for ease of function calling

%general
    
    general.strain = "AIYtest";
    general.pars = "11_3_details";
    
    general.extract_from_mat = "FALSE"; %set to TRUE if its first time and need to extract mat to excel, FALSE if already done
    general.frame_rate = 9.9;

    general.wt_genotype_code = "wt"; %for r = 1
    general.mutant_genotype_code1 = "pdf1"; %for r = 2

  

%Y limits and label for plots, depending on ratio type

%for baseline-adjusted ratios (R0)
    plotting.R0ploty1  = -1; %lower y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty2  = +3; %upper y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty1avg  = -0.2; %lower y axis limit for avg traces plots
    plotting.R0ploty2avg  = +1; %upper y axis limit for avg traces plots
    plotting.R0hmy1    = -0.5; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.R0hmy2    = +2; %upper y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.R0name  = "badj";

%for maxmin normalised ratios (Fm)
    plotting.Fmploty1  = -0.1; %lower y axis limit for single traces plots maxmin normalised ratios
    plotting.Fmploty2  = +1; %upper y axis limit for ssingle traces plots maxmin normalised ratios   
    plotting.Fmploty1avg  = 0; %lower y axis limit for avg traces plots
    plotting.Fmploty2avg  = +0.7; %upper y axis limit for avg traces plots
    plotting.Fmhmy1    = -0; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.Fmhmy2    = +0.9; %upper y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.Fmname  = "norm";




% Movie parameters

    % baseline and time for 220smovie, 10fps, 10sec baseline, 30sON-30sOFF-30sON-30sOFF
    moviepars.bstart = 792;%first frame of baseline
    moviepars.bend = 891; %last frame of baseline
    moviepars.mend = 2079; %last used frame of movie
%     moviepars.halfmend =      ; %last frame of 1st odour off
    moviepars.full_movie_lengthS = 220; %full movie length in seconds
    moviepars.max_movie_length = ceil(general.frame_rate) * moviepars.full_movie_lengthS; % maximum possible frame of movie (this is frame rate were actually 10fps, which is not. in reality most movies around 2185 frames). 
    moviepars.timesecs = [80 90 120 150 180 210]; %vector containing timepoints in seconds (time since record start)
    moviepars.timeframes  = [792 892 1188 1485 1782 2079]; %vector containing timepoints in frames (time since record start)
    moviepars.timelabels=({'0' '10' '40' '70' '100' '130'});  %cell array containing timepoints in seconds (time since baseline start)
    moviepars.ycoords = [-10 -10 -10 -10 -10 ; +10 +10 +10 +10 +10; +10 +10 +10 +10 +10; -10 -10 -10 -10 -10 ]; %y coords for patch function
    moviepars.xcoords = [moviepars.timesecs(1:end-1); moviepars.timesecs(1:end-1); moviepars.timesecs(2:end); moviepars.timesecs(2:end)]; %x coords for patch function


%Colors
    % Define colors struct
    colors.purple      = [0.6039 0.1961 0.8039];  % Purple RGB
    colors.palegray    = [0.7020 0.7020 0.7020];  % Pale Gray RGB (for shading)
    colors.paleblue    = [179 204 255] / 255;     % Pale Blue RGB (for shading)
    colors.mockgray    = [161 159 161] / 255;     % Mock gray RGB
    colors.avsvgreen   = [40 243 40] / 255;       % Green RGB
    colors.sexcondpink = [249 138 122] / 255;     % Pink RGB
    colors.pdf1purple  = [120 0 169] / 255;       % PDF1 purple RGB
    colors.lightblue   = [0.3010 0.7450 0.9330];  % Light blue (eg for type 1 neurons)
    colors.darkblue    = [0 0.4470 0.7410];       % Dark blue (eg for type 2 neurons)

    

    
    % Define 3D color array for patch colors
    patchcolors = [colors.palegray; colors.paleblue; colors.palegray; colors.paleblue; colors.palegray]; 
    patchcolors3d = patchcolors(:,1);
    patchcolors3d(:,:,2) = patchcolors(:,2);
    patchcolors3d(:,:,3) = patchcolors(:,3);
    
    % Add patchcolors3d to struct
    colors.patchcolors3d = patchcolors3d;
    clear patchcolors patchcolors3d %clear so as to not clutter workspace


%Parameters for type1 and type 2 analysis
    T1T2analysispars.T2cutoffinsecs = 15;
    T1T2analysispars.thresholdFm = 0.4;
    T1T2analysispars.thresholdR0 = 1;


%% Create cell arrays to hold input directories
% always use r, c for rows + columns.
%columns always used to indicate condition (mock/avsv/sexc)
%row not used in this case but can be used for genotype

all_mat_dirs = {
    mock_mat_dir avsv_mat_dir sexc_mat_dir;
    mt_mock_mat_dir mt_avsv_mat_dir mt_sexc_mat_dir
};


all_xlsx_dirs = {
    mock_xlsx_dir avsv_xlsx_dir sexc_xlsx_dir;
    mt_mock_xlsx_dir mt_avsv_xlsx_dir mt_sexc_xlsx_dir
};

clear mock_mat_dir avsv_mat_dir sexc_mat_dir
clear mock_xlsx_dir avsv_xlsx_dir sexc_xlsx_dir


%Create string array with the codes for each condition/genotype
%use columns for condition and rows for genotype

codes = [
    "wt_mock_" "wt_avsv_" "wt_sexc_";
    "pdf1_mock_" "pdf1_avsv_" "pdf1_sexc_"
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
        [all_badjratios, badjratios_avg, SEMbadj, all_normratios, normratios_avg, SEMnorm, all_secs, col_names] = process_this_group(all_xlsx_dirs{r, c}, analysis_output_dir, codes(r, c), general, colors, plotting, moviepars);



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
            
            %store worm names
            worm_names.(genotype).(condition_name) = col_names;

            % Store baseline-adjusted ratios and SEM values
            bratio_all_data.(genotype).(condition_name) = all_badjratios; 
            bratio_avg_data.(genotype).(condition_name) = badjratios_avg; 
            bSEM_data.(genotype).(condition_name) = SEMbadj;
            

            % Store minmax normalised ratios and SEM values
            nratio_all_data.(genotype).(condition_name) = all_normratios;             
            nratio_avg_data.(genotype).(condition_name) = normratios_avg; 
            nSEM_data.(genotype).(condition_name) = SEMnorm;



    end
end


%% Create plots showing multiple conditions

%3cond plots for baseline-adjusted (R0)
plot_avg_with_sem_3cond(all_secs, bratio_avg_data, bSEM_data, "badjratios", analysis_output_dir,colors, plotting, moviepars, general);

%3cond plots for normalised (Fm)
plot_avg_with_sem_3cond(all_secs, nratio_avg_data, nSEM_data, "normratios",analysis_output_dir, colors, plotting, moviepars, general);





%% OTher condition-specific analysis


%%Type1 Type2 analysis (originally set for AIY). Can only handle one
%%condition at a time, so need to cycle through

% if strcmp(analysisparams.T1T2analysis,"TRUE")
    loop_to_run_type1type2_analysis(bratio_all_data, "badjratios", worm_names, T1T2analysispars, analysis_output_dir, colors, plotting, moviepars, general)
    loop_to_run_type1type2_analysis(nratio_all_data, "normratios", worm_names, T1T2analysispars, analysis_output_dir, colors, plotting, moviepars, general)
    

% end






