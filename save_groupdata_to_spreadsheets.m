
%% Save data to spreadsheets
function save_groupdata_to_spreadsheets(all_adjratios, avg_all_adjratios, SEM, all_secs, general, pdir)
    % Convert to table for saving
    Tall_adjratios = array2table(all_adjratios);

    % Save all data
    allratios_filename = fullfile(pdir, strcat(general.strain, '_all.xlsx'));
    writetable(Tall_adjratios, allratios_filename, 'FileType', 'spreadsheet');

    % Save average, timepoints, and SEM
    avg_SEM_data = [all_secs, avg_all_adjratios, SEM];
    avgratios_filename = fullfile(pdir, strcat(general.strain, '_avg.xlsx'));
    writematrix(avg_SEM_data, avgratios_filename, 'FileType', 'spreadsheet');
end
