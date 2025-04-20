%{
Main driver script for fluorescence analysis of calcium imaging data.

Workflow summary:
1. Set up analysis parameters: general info, plotting, movie timing, and toggles
2. Optionally extract raw `.mat` files into `.xlsx` spreadsheets (skip if already done)
3. Process each genotype × condition group:
    - Load per-worm data
    - Apply smoothing, bleach correction (if enabled), and ratio calculations
    - Save and plot traces
4. Generate plots for:
    - All conditions per genotype
    - All genotypes per condition
    - Bleach-corrected vs uncorrected data
5. Optionally classify traces by:
    - ON/OFF state (offHIGH, onLOW, bLOW)
    - Response type (Type1, Type2)

Notes:
- The entire script runs inside a `try-catch` block. 
If an error occurs, the full workspace is saved to a `.mat` file for debugging.

Inputs: (set inside script)
- Paths to raw/extracted data
- List of genotypes and conditions
- Parameter values for each stage of the analysis

Outputs:
- PNG/EPS plots
- Summary tables and Excel files
- Parameter log for reproducibility
%}



%%input

%% data inputs

%set input and output directories 

% set directories for wild-type data
%set path for mat files of each condition here: 
mock_mat_dir = "";
avsv_mat_dir = "";
sexc_mat_dir = "";

%set path for xlsx files of each condition here: 
mock_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBxls/wt/mock";
avsv_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBxls/wt/avsv";
sexc_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBxls/wt/sexc";



% set directories for mutant data

% %set path for mat files of each condition here: 
% mt_mock_mat_dir = "";
% mt_avsv_mat_dir = "";
% mt_sexc_mat_dir = "";
% 
% %set path for xlsx files of each condition here: 
% mt_mock_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/p1/mock";
% mt_avsv_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/p1/avsv";
% mt_sexc_xlsx_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIY/newAIYxls/p1/sexc";


%set path for overall analysis output
% subfolders inside this need to have exact name as the "codes" listed
% below for each group
analysis_output_dir = "/Volumes/groupfolders/DBIO_Barrios_Lab/IMAGING/feb2025_testing/AIB/newAIBoutput4";
                      
%% set parameters, organised into structures for ease of function calling

%general
    
    general.strain = "AIB";
    general.pars = "17_4_";
    
    general.frame_rate = 9.9;

    general.wt_genotype_code = "wt"; %for r = 1
%     general.mutant_genotype_code1 = "p1"; %for r = 2



 %set analysis parameters

    analysis_pars.extract_from_mat = false; %set to TRUE if its first time and need to extract mat to excel, FALSE if already done    
    analysis_pars.plot_single_worms = false; %set to TRUE if want all signle worm plots. will be slow. 
    analysis_pars.full_or_halfmovieplots = "half"; %set to full for full movie, half for half movie NB this only used to set plot ylim, not for anything else    
    analysis_pars.calculateR0 = true; %set to TRUE will calculate R0 (baseline-adjusted ratio R-R0/R0)
    analysis_pars.calculateFm = true; %set to TRUE will calculate Fm (minmax normalised ratio F-Fmin/Fmax)
    analysis_pars.export_eps = false;  %export plots as eps and png or only eps. eps takes long but is needed to edit in affinity
    analysis_pars.bleachcorrect = false; %set true if want to perform bleach correction (and show raw vs bleach corrected comparison plots)
    analysis_pars.furtheranalysis_Type1Type2 = false; %perform type1tpe2 analysis (like for AIY) and output sorted heatmaps, etc
    analysis_pars.furtheranalysis_ONOFFclassif = true; %perform ON/OFF classification analysis (like for RIM and AIB). 


    %Parameters for type1 and type 2 analysis
    analysis_pars.T1T2analysispars.T2cutoffinsecs = 15;
    analysis_pars.T1T2analysispars.thresholdFm = 0.4;
    analysis_pars.T1T2analysispars.thresholdR0 = 1;


    %Parameters for ON/OFF categorisation
    analysis_pars.ONOFFcategorisation.threshold = 0.5; %activity level (Fm) required to be classed as on / off (=> is on, <= is off). 

    

%Y limits and label for plots, depending on ratio type

%for baseline-adjusted ratios (R0)
    plotting.R0ploty1  = -3; %lower y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty2  = +6.5; %upper y axis limit for single traces plots baseline-adjusted ratios
    plotting.R0ploty1avg  = -2; %lower y axis limit for avg traces plots
    plotting.R0ploty2avg  = +2; %upper y axis limit for avg traces plots
    plotting.R0hmy1    = -0; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.R0hmy2    = +1; %upper y axis limit for heatmaps nb this sets limit within which scale colors


%for maxmin normalised ratios (Fm)
    plotting.Fmploty1  = -0.1; %lower y axis limit for single traces plots maxmin normalised ratios
    plotting.Fmploty2  = +1; %upper y axis limit for ssingle traces plots maxmin normalised ratios   
    plotting.Fmploty1avg  = 0; %lower y axis limit for avg traces plots
    plotting.Fmploty2avg  = +1; %upper y axis limit for avg traces plots
    plotting.Fmhmy1    = -0; %lower y axis limit for heatmaps nb this sets limit within which scale colors
    plotting.Fmhmy2    = +0.9; %upper y axis limit for heatmaps nb this sets limit within which scale colors





% Movie parameters

    moviepars.bstart = 792;%first frame of baseline
    moviepars.bend = 1089; %last frame of baseline
    moviepars.ONend = 1683; %last frame of 1st odour ON
    moviepars.OFFend = 2277; %last frame of 1st odour OFF
    moviepars.last10OFF = 990; %in case different from baseline start eg AIB
    moviepars.last10ON = 1584;  %to calculate onLOW neurons R0 
    moviepars.mend = 2277; %last used frame of movie (full movie)
    moviepars.halfmend =  2277    ; %last frame of 1st odour off
    moviepars.full_movie_lengthS = 370; %full movie length in seconds
    moviepars.max_movie_length = ceil(general.frame_rate) * moviepars.full_movie_lengthS; % maximum possible frame of movie (this is frame rate were actually 10fps, which is not. in reality most movies around 2185 frames). 
    moviepars.timesecs = [80 110 170 230 290 350]; %vector containing timepoints in seconds (time since record start)
    moviepars.timeframes  = [792 1089  1683  2277  2871  3465]; %vector containing timepoints in frames (time since record start)
    moviepars.timelabels=({'0'  '30'  '90'  '150'  '210'  '270'});  %cell array containing timepoints in seconds (time since baseline start)
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
    colors.purple      = [120 0 169] / 255;       % PDF1 purple RGB
    colors.lightblue   = [0.3010 0.7450 0.9330];  % Light blue (eg for type 1 neurons)
    colors.darkblue    = [0 0.4470 0.7410];       % Dark blue (eg for type 2 neurons)
    colors.darkgray    = [0.3216    0.3176    0.3176]; %Dark gray eg for non-bleach corrected ratios

    

    
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
%     "p1"
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



% Plot R0 and/or Fm: check at least one is TRUE
if ~analysis_pars.calculateR0 && ~analysis_pars.calculateFm
    error('At least one of analysis_pars.calculateR0 or analysis_pars.calculateFm must be "TRUE".');
end



% Save analysis parameters for future reference / reloading
save_analysis_params(analysis_output_dir, general, analysis_pars, plotting, moviepars, colors);


%% Real code starts here (in try-block to catch and save workspace if there is an error)
try 

    %% Extract .mat files to xlsx (if needed)
    
    if analysis_pars.extract_from_mat
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
            [ratios, notbc_ratios, all_secs, col_names] = process_this_group(all_xlsx_dirs{g, c}, analysis_output_dir, genotype, cond, general,analysis_pars, colors, plotting, moviepars);
    
    
                
            %store worm names
            worm_names.(genotype).(cond) = col_names;
    
            
            % Store baseline-adjusted ratios (R0) and SEM values                 
            bratio_all_data.(genotype).(cond) = ratios.badj.all; 
            bratio_avg_data.(genotype).(cond) = ratios.badj.avg; 
            bSEM_data.(genotype).(cond) = ratios.badj.SEM;
            
            % Store minmax normalised ratios (Fm)and SEM values
            nratio_all_data.(genotype).(cond) = ratios.norm.all;             
            nratio_avg_data.(genotype).(cond) = ratios.norm.avg; 
            nSEM_data.(genotype).(cond) = ratios.norm.SEM;
    
    
            
            if analysis_pars.bleachcorrect 
                if isempty(notbc_ratios)
                    warning("notbc_ratios is empty. it should contain pre bleach-corrected data")
                end
    
                % Store baseline-adjusted ratios (R0) and SEM values                 
                notbc_bratio_all_data.(genotype).(cond) = notbc_ratios.badj.all; 
                notbc_bratio_avg_data.(genotype).(cond) = notbc_ratios.badj.avg; 
                notbc_bSEM_data.(genotype).(cond) = notbc_ratios.badj.SEM;
                
                % Store minmax normalised ratios (Fm)and SEM values
                notbc_nratio_all_data.(genotype).(cond) = notbc_ratios.norm.all;             
                notbc_nratio_avg_data.(genotype).(cond) = notbc_ratios.norm.avg; 
                notbc_nSEM_data.(genotype).(cond) = notbc_ratios.norm.SEM;
            end
    
    
     
    
    
        end
    end
    
    
    %% Create plots showing multiple conditions and genotypes, if present
    
    
    %3cond plots for baseline-adjusted (R0)
    if analysis_pars.calculateR0
        loop_to_plot_all_conditions_per_genotype(all_secs, bratio_avg_data, bSEM_data, "badjratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
        loop_to_plot_all_genotypes_per_condition(all_secs, bratio_avg_data, bSEM_data, "badjratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
        
        if analysis_pars.bleachcorrect 
            loop_to_plot_bc_vs_nobc(all_secs, bratio_avg_data, bSEM_data, notbc_bratio_avg_data, notbc_bSEM_data,"badjratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars );
        end
    
    end
    
    
    
    if analysis_pars.calculateFm
        loop_to_plot_all_conditions_per_genotype(all_secs, nratio_avg_data, nSEM_data, "normratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
        loop_to_plot_all_genotypes_per_condition(all_secs, nratio_avg_data, nSEM_data, "normratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
    
        if analysis_pars.bleachcorrect
           loop_to_plot_bc_vs_nobc(all_secs, nratio_avg_data, nSEM_data, notbc_nratio_avg_data, notbc_nSEM_data,"normratios", analysis_output_dir, general, analysis_pars, colors, plotting, moviepars );
        end
    
    
    end
    
    
    
    
    %% OTher condition-specific analysis
    
    
    %% Type1 Type2 analysis (originally made for AIY)
    
     if analysis_pars.furtheranalysis_Type1Type2
        loop_to_run_type1type2_analysis(bratio_all_data, "badjratios", worm_names, analysis_pars, analysis_output_dir, general,colors, plotting, moviepars)
        loop_to_run_type1type2_analysis(nratio_all_data, "normratios", worm_names, analysis_pars, analysis_output_dir, general,colors, plotting, moviepars)
        
     end
    
    
    
    
    
    %% Categorise as ONOFF (originally made for AIB and RIM). 
    % Will use nratio_all_data (min max normalised, Fm) to categorise as
    % ON/OFF, but will produce plots for both normalised and baseline adjusted
    % ratio of categorised worms (categories are offHt functe IGH, onLOW, bLOW). 
    % also generates non-cumulative proportion plots
    
    if analysis_pars.furtheranalysis_ONOFFclassif
        loop_to_run_categorisebyONOFFstates(bratio_all_data, nratio_all_data, worm_names, analysis_output_dir, general,analysis_pars, colors, plotting, moviepars)
    
    end

catch ME
    % If an error occurs, save the workspace anyway
    disp('An error occurred. Saving the workspace...');

    % Save the current workspace
    output_file = fullfile(analysis_output_dir, strcat(general.strain, general.pars, 'workspace.mat'));
    save(output_file);

    % Display detailed error information
    fprintf('Error identifier: %s\n', ME.identifier);
    fprintf('Error message: %s\n', ME.message);
    for k = 1:length(ME.stack)
        fprintf('Error in %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
    end
end
