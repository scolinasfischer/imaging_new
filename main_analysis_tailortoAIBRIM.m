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
mock_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIB/BAR184/AIBlong/AIB MOCK long";
avsv_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIB/BAR184/AIBlong/AIB AV long";
sexc_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIB/BAR184/AIBlong/AIB SEX COND long half";

%set path for xlsx files of each condition here: 
mock_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBxls/wt/mock";
avsv_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBxls/wt/avsv";
sexc_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBxls/wt/sexc";



% % set directories for mutant data
% 
% %set path for mat files of each condition here: 
% mt_mock_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR227/BAR227 AIY MOCK pdf1 mut";
% mt_avsv_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR227/BAR227 AIY AVERSIVE pdf1 mut";
% mt_sexc_mat_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/matfiles/AIY/BAR227/BAR227 AIY SEX COND pdf1 mut";
% 
% %set path for xlsx files of each condition here: 
% mt_mock_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/pdf1_mock_";
% mt_avsv_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/pdf1_avsv_";
% mt_sexc_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/pdf1_sexc_";


%set path for overall analysis output
% subfolders inside this need to have exact name as the "codes" listed
% below for each group
analysis_output_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBoutput2";


%% set parameters, organised into structures for ease of function calling

%general
    
    general.strain = "AIBtest";
    general.pars = "18_3";
    
    general.frame_rate = 9.9;

    general.wt_genotype_code = "wt"; %for r = 1
%     general.mutant_genotype_code1 = "pdf1"; %for r = 2

  

 %set analysis parameters

    analysis_pars.extract_from_mat = "FALSE"; %set to TRUE if its first time and need to extract mat to excel, FALSE if already done    
    analysis_pars.plot_single_worms = "FALSE"; %set to TRUE id
    analysis_pars.full_or_halfmovieplots = "half"; %set to full for full movie, half for half movie NB this only used to set plot ylim, not for anything else    
    analysis_pars.calculateR0 = "TRUE"; %set to TRUE will calculate R0 (baseline-adjusted ratio R-R0/R0)
    analysis_pars.calculateFm = "TRUE"; %set to TRUE will calculate Fm (minmax normalised ratio F-Fmin/Fmax)
    analysis_pars.export_eps = "FALSE";  %export plots as eps and png or only eps. eps takes long but is needed to edit in affinity
%     analysis_pars.bleach_correct = "TRUE"; %set true if want to perform bleach correction (and show raw vs bleach corrected comparison plots)
    analysis_pars.furtheranalysis_Type1Type2 = "FALSE"; %perform type1tpe2 analysis (like for AIY) and output sorted heatmaps, etc
    analysis_pars.furtheranalysis_ONOFFclassif = "TRUE"; %perform ON/OFF classification analysis (like for RIM and AIB). 


    %Parameters for type1 and type 2 analysis
    analysis_pars.T1T2analysispars.T2cutoffinsecs = 15;
    analysis_pars.T1T2analysispars.thresholdFm = 0.4;
    analysis_pars.T1T2analysispars.thresholdR0 = 1;


    %Parameters for ON/OFF categorisation
    analysis_pars.ONOFFcategorisation.threshold = 0.5; %activity level (Fm) required to be classed as on / off (=> is on, <= is off). 

    
    % need to make save of these parameters to output folder^^^^^


%Y limits and label for plots, depending on ratio type

%for baseline-adjusted ratios (R0)
    plotting.R0ploty1  = -1; %lower y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty2  = +6.5; %upper y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty1avg  = -2; %lower y axis limit for avg traces plots
    plotting.R0ploty2avg  = +2; %upper y axis limit for avg traces plots
    plotting.R0hmy1    = -0; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.R0hmy2    = +1; %upper y axis limit for heatmaps nb this sets limit within which scale colors


%for maxmin normalised ratios (Fm)
    plotting.Fmploty1  = -0; %lower y axis limit for single traces plots maxmin normalised ratios
    plotting.Fmploty2  = +1; %upper y axis limit for ssingle traces plots maxmin normalised ratios   
    plotting.Fmploty1avg  = 0; %lower y axis limit for avg traces plots
    plotting.Fmploty2avg  = +1; %upper y axis limit for avg traces plots
    plotting.Fmhmy1    = -0; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.Fmhmy2    = +1; %upper y axis limit for heatmaps nb this sets limit within which scale colors





% Movie parameters

%     % baseline and time for 220smovie, 10fps, 10sec baseline, 30sON-30sOFF-30sON-30sOFF
%     moviepars.bstart = 792;%first frame of baseline
%     moviepars.bend = 891; %last frame of baseline
%     moviepars.mend = 2079; %last used frame of movie (full movie)
%     moviepars.halfmend =  1485    ; %last frame of 1st odour off
%     moviepars.full_movie_lengthS = 220; %full movie length in seconds
%     moviepars.max_movie_length = ceil(general.frame_rate) * moviepars.full_movie_lengthS; % maximum possible frame of movie (this is frame rate were actually 10fps, which is not. in reality most movies around 2185 frames). 
%     moviepars.timesecs = [80 90 120 150 180 210]; %vector containing timepoints in seconds (time since record start)
%     moviepars.timeframes  = [792 891 1188 1485 1782 2079]; %vector containing timepoints in frames (time since record start)
%     moviepars.timelabels=({'0' '10' '40' '70' '100' '130'});  %cell array containing timepoints in seconds (time since baseline start)
%     moviepars.ycoords = [-10 -10 -10 -10 -10 ; +10 +10 +10 +10 +10; +10 +10 +10 +10 +10; -10 -10 -10 -10 -10 ]; %y coords for patch function
%     moviepars.xcoords = [moviepars.timesecs(1:end-1); moviepars.timesecs(1:end-1); moviepars.timesecs(2:end); moviepars.timesecs(2:end)]; %x coords for patch function


% baseline and time for 370smovie, 10fps, 30sec baseline,60sON-60sOFF-60sON-60sOFF (or half of this)
    moviepars.bstart = 792;%first frame of baseline
    moviepars.bend = 1089; %last frame of baseline
    moviepars.ONend = 1683; %last frame of 1st odour ON
    moviepars.OFFend = 2277; %last frame of 1st odour OFF
    moviepars.last10OFF = 990; %in case different from baseline start eg AIB
    moviepars.last10ON = 1584;  %to calculate onLOW neurons R0 
    moviepars.mend = 3465; %last used frame of movie (full movie)
    moviepars.halfmend =  2277    ; %last frame of 1st odour off
    moviepars.full_movie_lengthS = 370; %full movie length in seconds
    moviepars.max_movie_length = ceil(general.frame_rate) * moviepars.full_movie_lengthS; % maximum possible frame of movie (this is frame rate were actually 10fps, which is not. in reality most movies around 2185 frames). 
    moviepars.timesecs = [80 110 170 230 290 350]; %vector containing timepoints in seconds (time since record start)
    moviepars.timeframes  = [792 1089 1683 2277 2871 3465]; %vector containing timepoints in frames (time since record start)
    moviepars.timelabels=({'0' '30' '90' '150' '210' '270'});  %cell array containing timepoints in seconds (time since baseline start)
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





%% Create cell arrays to hold input directories
% always use r, c for rows + columns.
%columns always used to indicate condition (mock/avsv/sexc)
%row not used in this case but can be used for genotype

all_mat_dirs = {
    mock_mat_dir avsv_mat_dir sexc_mat_dir;
%     mt_mock_mat_dir mt_avsv_mat_dir mt_sexc_mat_dir
};


all_xlsx_dirs = {
    mock_xlsx_dir avsv_xlsx_dir sexc_xlsx_dir;
%     mt_mock_xlsx_dir mt_avsv_xlsx_dir mt_sexc_xlsx_dir
};

clear mock_mat_dir avsv_mat_dir sexc_mat_dir
clear mock_xlsx_dir avsv_xlsx_dir sexc_xlsx_dir


%Create string array with the codes for each condition/genotype
%use columns for condition and rows for genotype

conditions = [
    "mock" "avsv" "sexc"
    ];

genotypes = [
    "wt";
];



%% apply designated anaylsis parameters

%full or half movie
if strcmp(analysis_pars.full_or_halfmovieplots, "full")
    moviepars.plotendf = moviepars.mend; %sets upper xlim for plot in frames
elseif strcmp(analysis_pars.full_or_halfmovieplots, "half")
    moviepars.plotendf = moviepars.halfmend; %sets upper xlim for plot in frames
else
    disp("Unexpected value at analysis_pars.full_or_halfmovieplots. Must be either half or full.")
end

moviepars.plotends = moviepars.plotendf / 9.9; %set xlim for plot in seconds



% Calculate R0 and/or Fm: check at least one is TRUE
if ~(strcmp(analysis_pars.calculateR0, "TRUE") || strcmp(analysis_pars.calculateFm, "TRUE"))
    error('At least one of analysis_pars.calculateR0 or analysis_pars.calculateFm must be "TRUE".');
end




%% Extract .mat files to xlsx (if needed)

if strcmp(analysis_pars.extract_from_mat, "TRUE")
    cycle_to_extract_mat_files(all_mat_dirs, all_xlsx_dirs, general.frame_rate);
end






%% Process data within each group, call function to process individual worms
% processing means:
%   load data
%   smooth, adjust ratios, etc
%   plot single worms
%   plot accross worm within group

dir_size = size(all_xlsx_dirs);
for g = 1:length(genotypes)
    genotype = genotypes(g);


    for c = 1:length(conditions)
        cond = conditions(c);
        [all_badjratios, badjratios_avg, SEMbadj, all_normratios, normratios_avg, SEMnorm, all_secs, col_names] = process_this_group(all_xlsx_dirs{g, c}, analysis_output_dir, genotype, cond, general,analysis_pars, colors, plotting, moviepars);


            
        %store worm names
        worm_names.(genotype).(cond) = col_names;

        
        if strcmp(analysis_pars.calculateR0, "TRUE")
            % Store baseline-adjusted ratios (R0) and SEM values                 
            bratio_all_data.(genotype).(cond) = all_badjratios; 
            bratio_avg_data.(genotype).(cond) = badjratios_avg; 
            bSEM_data.(genotype).(cond) = SEMbadj;
        end


        if strcmp(analysis_pars.calculateFm, "TRUE")
            % Store minmax normalised ratios (Fm)and SEM values
            nratio_all_data.(genotype).(cond) = all_normratios;             
            nratio_avg_data.(genotype).(cond) = normratios_avg; 
            nSEM_data.(genotype).(cond) = SEMnorm;
        end


    end
end


%% Create plots showing multiple conditions and genotypes, if present


%3cond plots for baseline-adjusted (R0)
if strcmp(analysis_pars.calculateR0, "TRUE")
    loop_to_plot_all_conditions_per_genotype(all_secs, bratio_avg_data, bSEM_data, "badjratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
    loop_to_plot_all_genotypes_per_condition(all_secs, bratio_avg_data, bSEM_data, "badjratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
end





if strcmp(analysis_pars.calculateFm, "TRUE")
    loop_to_plot_all_conditions_per_genotype(all_secs, nratio_avg_data, nSEM_data, "normratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
    loop_to_plot_all_genotypes_per_condition(all_secs, nratio_avg_data, nSEM_data, "normratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
end




%% OTher condition-specific analysis


%% Type1 Type2 analysis (originally made for AIY)

 if strcmp(analysis_pars.furtheranalysis_Type1Type2,"TRUE")
    loop_to_run_type1type2_analysis(bratio_all_data, "badjratios", worm_names, analysis_pars, analysis_output_dir, general,colors, plotting, moviepars)
    loop_to_run_type1type2_analysis(nratio_all_data, "normratios", worm_names, analysis_pars, analysis_output_dir, general,colors, plotting, moviepars)
    

 end





%% Categorise as ONOFF (originally made for AIB and RIM). 
% Will use nratio_all_data (min max normalised, Fm) to categorise as
% ON/OFF, but will produce plots for both normalised and baseline adjusted
% ratio of categorised worms (categories are offHIGH, onLOW, bLOW). 

if analysis_pars.furtheranalysis_ONOFFclassif == "TRUE"
    loop_to_run_categorisebyONOFFstates(bratio_all_data, nratio_all_data, worm_names, analysis_output_dir, general,analysis_pars, colors, plotting, moviepars)

end
