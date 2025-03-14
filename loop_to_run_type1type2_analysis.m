function loop_to_run_type1type2_analysis(ratio_all_data, ratiotype, worm_names, T1T2analysispars, analysis_output_dir, colors, plotting, moviepars, general)

% Create struct to hold number of type1type2 neurons in each condition and genotype
nT1T2 = struct;

genotypes = fieldnames(ratio_all_data);
all_data = {}; % Initialize cell array for table data
row = 2; % Start filling from row 2 (because row 1 will have headers)

for g = 1:length(genotypes)
    genotype = genotypes{g};
    conditions = fieldnames(ratio_all_data.(genotype));
    
    for c = 1:length(conditions)
        cond = conditions{c};
        
        % Extract data dynamically
        these_adjratios = ratio_all_data.(genotype).(cond);
        these_worm_names = worm_names.(genotype).(cond);
        
        % Create output directory
        pdir = fullfile(analysis_output_dir);
        if ~exist(pdir, 'dir')
            mkdir(pdir);
        end
        
        % Call the analysis function
        [nT1, nT2] = type1type2_analysis(these_adjratios, ratiotype, these_worm_names, T1T2analysispars, cond, pdir, colors, plotting, moviepars, general);
        
        nT1T2.(genotype).(cond).nT1 = nT1;
        nT1T2.(genotype).(cond).nT2 = nT2;
        
        % Add to spreadsheet data
        all_data{row, 1} = cond;
        all_data{row, 2} = nT1;
        all_data{row, 3} = nT2;
        row = row + 1;
    end
end

% Prepare table for writing to Excel
all_data = [{'Condition', 'nT1', 'nT2'}; all_data]; % Add headers

% Convert to table
data_table = cell2table(all_data(2:end, :), 'VariableNames', all_data(1, :));

% Write to spreadsheet
filename = fullfile(analysis_output_dir, strcat(ratiotype, 'nT1T2_data.xlsx'));
writetable(data_table, filename);

fprintf(ratiotype, 'nT1T2 data saved to ', filename);

end

