%{
For each genotype × condition:
- Calls `type1type2_analysis` to split traces into Type1/Type2
- Saves number of neurons in each category
- Outputs summary table of neuron counts

Inputs:
- ratio_all_data: structured baseline-adjusted or normratios
- ratiotype: string ('badjratios' or 'normratios')
- worm_names: structured worm name list
- analysis_pars, analysis_output_dir, general, colors, plotting, moviepars

Output:
- Summary table saved to Excel (nT1 and nT2 per condition)
%}



function loop_to_run_type1type2_analysis(ratio_all_data, ratiotype, worm_names, analysis_pars, analysis_output_dir, general, colors, plotting, moviepars)

% Create struct to hold number of type1type2 neurons in each condition and genotype
nT1T2 = struct;

genotypes = fieldnames(ratio_all_data);
all_data = {}; % Initialize cell array for table data (save number typ1 type2 neurons)
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
        pdir = fullfile(analysis_output_dir,genotype,cond);
        if ~exist(pdir, 'dir')
            mkdir(pdir);
        end
        
        % Call the analysis function
        [nT1, nT2] = type1type2_analysis(these_adjratios, ratiotype, these_worm_names, analysis_pars, genotype,cond, pdir, general, colors, plotting, moviepars);

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

