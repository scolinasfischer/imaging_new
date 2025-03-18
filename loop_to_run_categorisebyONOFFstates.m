function loop_to_run_categorisebyONOFFstates(bratio_all_data, nratio_all_data, worm_names, analysis_output_dir, general, colors, plotting, moviepars)


%this function calls the function that categorises neurons by their on/off states. 

%It accepts as input the two structures containing normalised ratio data
%for all genotypes and conditions (one struct for normalised ratios and one
%struct for baseline-adjusted ratios). 
%Other inputs: worm_names (struct with worm names) 

%It also calls plotting function to plot the data separated by these categories, as well
%as saving xls files with the following: 
 

% Create struct to hold number of offHIGH/onLOW/bLOW neurons in each condition and genotype
categorised_bratio = struct;

genotypes = fieldnames(nratio_all_data);
all_data = {}; % Initialize cell array for table data
row = 2; % Start filling from row 2 (because row 1 will have headers)

for g = 1:length(genotypes)
    genotype = genotypes{g};
    conditions = fieldnames(nratio_all_data.(genotype));
    
    for c = 1:length(conditions)
        cond = conditions{c};
        
        % Extract ratios data 
        these_nratios = nratio_all_data.(genotype).(cond);
        these_bratios = bratio_all_data.(genotype).(cond);
        
        these_worm_names = worm_names.(genotype).(cond);
        
        % Create output directory
        pdir = fullfile(analysis_output_dir, genotype, cond);
        if ~exist(pdir, 'dir')
            mkdir(pdir);
        end
        
        % Call the analysis function (categorise bratio and normratio data by ON/OFF states in normratio data) 
        [offHIGH_norm, offHIGH_badj, cols_offHIGH, ...
         onLOW_norm, onLOW_badj, cols_onLOW, ...
         bLOW_norm, bLOW_badj, cols_bLOW] = ...
         categorisebyONOFFstates(these_nratios, these_bratios, these_worm_names,cond, pdir, general, colors, plotting, moviepars);
      
        
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
        all_data{row, 1} = cond;
        all_data{row, 2} = length(catg_wormnames.(genotype).(cond).offHIGH);
        all_data{row, 3} = length(catg_wormnames.(genotype).(cond).onLOW);
        all_data{row, 4} = length(catg_wormnames.(genotype).(cond).bLOW);

        row = row + 1;
    end
end


%% Calculate avg, SEM and then Plot

%call general SEM flexible





%% Save data


% Prepare table for writing to Excel numbers of neurons in each category
all_data = [{'Condition', 'offHIGH', 'onLOW', 'bLOW'}; all_data]; % Add headers

% Convert to table
data_table = cell2table(all_data(2:end, :), 'VariableNames', all_data(1, :));

% Write to spreadsheet
filename = fullfile(pdir, cond, strcat(general.strain, cond, 'numberON-OFFneurons.xlsx'));
writetable(data_table, filename);



% Also save using save_groupdata function, one xls per category





fprintf('%s: catgeorised ON-OFFneurons %s\n', filename);

end

