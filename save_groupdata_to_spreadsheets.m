%{
Saves processed fluorescence ratio data for a single group (genotype × condition) to Excel:
- All individual traces (columns = worms)
- Group average, SEM, and time vector

Inputs:
- all_adjratios (matrix): Ratio traces for all worms. Size: [timepoints × worms]
- avg_all_adjratios (vector): Mean trace across all worms.
- ratiotype (string): 'badjratios' or 'normratios'; used in file names.
- name (string): Optional name suffix (e.g., 'not_bc', 'Type1').
- worm_names (cell array of strings): Labels for each worm trace column.
- SEM (vector): Standard error of the mean at each timepoint.
- pdir (string): Directory where Excel files are saved.
- all_secs (vector): Time vector (seconds).
- general (struct): Contains general.pars and general.strain for filename tags.

Outputs:
- Excel file with all individual traces.
- Excel file with [time, avg, SEM] matrix.
%}

%% Save data to spreadsheets
function save_groupdata_to_spreadsheets(all_adjratios, avg_all_adjratios, ratiotype,name, worm_names,SEM,pdir, all_secs, general)
    % Convert to table for saving
    
    Tall_adjratios = array2table(all_adjratios); % Convert adjratios to table
    worm_names = string(worm_names); % Convert to string array
    worm_names = matlab.lang.makeValidName(worm_names, 'Prefix', 'm'); % Ensure valid variable names
    Tall_adjratios.Properties.VariableNames(:) = worm_names; % Assign column names


    % Save all data
    allratios_filename = fullfile(pdir, strcat(general.pars,general.strain, ratiotype,name, '_all.xlsx'));
    writetable(Tall_adjratios, allratios_filename, 'FileType', 'spreadsheet');

    % Save average, timepoints, and SEM
    avg_SEM_data = [all_secs, avg_all_adjratios, SEM];
    avgratios_filename = fullfile(pdir, strcat(general.pars,general.strain, ratiotype, name, '_avg.xlsx'));
    writematrix(avg_SEM_data, avgratios_filename, 'FileType', 'spreadsheet');

end
