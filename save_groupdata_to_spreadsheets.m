
%% Save data to spreadsheets
    function save_groupdata_to_spreadsheets(all_adjratios, avg_all_adjratios, ratiotype, worm_names,SEM,pdir, cond, all_secs, general)
    % Convert to table for saving
%     Tall_adjratios = array2table(all_adjratios, 'VariableNames', worm_names);
    
    Tall_adjratios = array2table(all_adjratios); % Convert adjratios to table
    worm_names = string(worm_names); % Convert to string array
    worm_names = matlab.lang.makeValidName(worm_names, 'Prefix', 'm'); % Ensure valid variable names
    Tall_adjratios.Properties.VariableNames(:) = worm_names; % Assign column names


    % Save all data
    allratios_filename = fullfile(pdir, cond, strcat(general.strain, ratiotype, '_all.xlsx'));
    writetable(Tall_adjratios, allratios_filename, 'FileType', 'spreadsheet');

    % Save average, timepoints, and SEM
    avg_SEM_data = [all_secs, avg_all_adjratios, SEM];
    avgratios_filename = fullfile(pdir, cond, strcat(general.strain, ratiotype, '_avg.xlsx'));
    writematrix(avg_SEM_data, avgratios_filename, 'FileType', 'spreadsheet');
end
