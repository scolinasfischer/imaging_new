%{
Main wrapper for categorizing neurons into ON/OFF activity states:
- offHIGH: high activity at end of baseline
- onLOW: low activity at end of first odour pulse
- bLOW: low activity at start of baseline

It loops through all genotypes and conditions, calls the categorisation function,
plots and saves categorized data, and then computes average traces + proportions
for each group and state.

Inputs:
- bratio_all_data: baseline-adjusted ratios, structured by genotype/condition
- nratio_all_data: normalized ratios, structured by genotype/condition
- worm_names: struct of worm names per genotype/condition
- analysis_output_dir: base folder for saving
- general, analysis_pars, colors, plotting, moviepars: configuration structs

Output:
- No direct returned output (side effects only:
    Plots and Excel tables for categorized traces and proportions)
%}





function loop_to_run_categorisebyONOFFstates(bratio_all_data, nratio_all_data, worm_names, analysis_output_dir, general,analysis_pars, colors, plotting, moviepars)



fprintf('Starting categorise by ON-OFF state analysis. \n');

 


% Create struct to hold number of offHIGH/onLOW/bLOW neurons in each condition and genotype
categorised_bratio = struct;

genotypes = fieldnames(nratio_all_data);

row = 2; % Initialize counter to fill table with number neurons each catg (N_percond) row 2 (because row 1 will have headers) 

for g = 1:length(genotypes)
    genotype = genotypes{g};
    conditions = fieldnames(nratio_all_data.(genotype));
    N_percond = {}; % Initialize cell array for table data

    for c = 1:length(conditions)
        cond = conditions{c};
        
        % Extract ratios data 
        these_nratios = nratio_all_data.(genotype).(cond);
        these_bratios = bratio_all_data.(genotype).(cond);
        
        these_worm_names = worm_names.(genotype).(cond);
        

        
        % Call the analysis function (categorise bratio and normratio data by ON/OFF states in normratio data) 
        threshold = analysis_pars.ONOFFcategorisation.threshold;

        [offHIGH_norm, offHIGH_badj, cols_offHIGH, ...
         onLOW_norm, onLOW_badj, cols_onLOW, ...
         bLOW_norm, bLOW_badj, cols_bLOW] = ...
         categorisebyONOFFstates(threshold, these_nratios, these_bratios, these_worm_names, moviepars);
        fprintf('Completed categorisation for genotype %s, condition %s.\n', genotype, cond);

      
        
        %save baseline-adjusted data (R0) of categorised worms in struct
        categorised_bratio.(genotype).(cond).offHIGH = offHIGH_badj;
        categorised_bratio.(genotype).(cond).onLOW = onLOW_badj;
        categorised_bratio.(genotype).(cond).bLOW = bLOW_badj;

        %save normalised data (Fm) of categorised worms in struct
        categorised_nratio.(genotype).(cond).offHIGH = offHIGH_norm;
        categorised_nratio.(genotype).(cond).onLOW = onLOW_norm;
        categorised_nratio.(genotype).(cond).bLOW = bLOW_norm;

        %save organised worm names by category in similar struct
        catg_wormnames.(genotype).(cond).offHIGH = cols_offHIGH;
        catg_wormnames.(genotype).(cond).onLOW = cols_onLOW;
        catg_wormnames.(genotype).(cond).bLOW = cols_bLOW;
        
        
        % Add to spreadsheet data - this will give number of neurons in
        % each category (NB one worm/neuron can be in more than one
        % category)
        N_percond{row, 1} = cond;
        N_percond{row, 2} = length(catg_wormnames.(genotype).(cond).offHIGH);
        N_percond{row, 3} = length(catg_wormnames.(genotype).(cond).onLOW);
        N_percond{row, 4} = length(catg_wormnames.(genotype).(cond).bLOW);

        row = row + 1;

    end

    %% Save number of neurons in each catgeory for each condition (different spreadsheet for each genotype)
    
    
    % Prepare table for writing to Excel numbers of neurons in each category
    N_percond = [{'Condition', 'offHIGH', 'onLOW', 'bLOW'}; N_percond]; % Add headers
    
    % Convert to table
    data_table = cell2table(N_percond(2:end, :), 'VariableNames', N_percond(1, :));
    
    % Write to spreadsheet
    filename = fullfile(analysis_output_dir, genotype, strcat(general.strain, 'numberON-OFFneurons_allconds.xlsx'));
    writetable(data_table, filename);


end

fprintf('Categorisation and saving table complete\n');


%% Calculate avg+SEM, save, then Plot

%call function to organise bratio and nratio data and call: 
% calculate_plot_statistics, plot_avg_and_sem_flexible, and save_group_data

[nratio_avg, nratio_SEM, bratio_avg, bratio_SEM] = process_and_plot_categories_ONOFF(genotypes, conditions, categorised_nratio, categorised_bratio, catg_wormnames, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars);




fprintf('Categorise by ON-OFF state analysis, plotting, and saving complete. \n');

end

