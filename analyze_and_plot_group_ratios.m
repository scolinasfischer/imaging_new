% 3plots for within group


function analyze_and_plot_group_ratios(all_adjratios, general, colors, plotting, moviepars, pdir, cond)
    % Ensure output directory exists
    if ~exist(pdir, 'dir')
        mkdir(pdir);
    end

    % Compute statistics
    [avg_all_adjratios, SEM, all_secs] = compute_plot_statistics(all_adjratios, general.frame_rate);

    % Plot 1: Average with SEM
    plot_avg_with_sem(all_secs, avg_all_adjratios, SEM, colors, plotting, moviepars, general, pdir);

    % Plot 2: All traces + average
    plot_all_traces_and_avg(all_secs, all_adjratios, avg_all_adjratios, colors, plotting, moviepars, general, pdir);

    % Plot 3: Heatmap
    plot_heatmap(all_adjratios, avg_all_adjratios, colors, plotting, moviepars, general, pdir);

    % Save data to spreadsheets
    save_data_to_spreadsheets(all_adjratios, avg_all_adjratios, SEM, all_secs, general, pdir);

    fprintf('Analysis complete for group: %s\n', cond);
end

% 
% %% Plot: Average with SEM
% function plot_avg_with_sem(all_secs, avg_all_adjratios, SEM, colors, plotting, moviepars, general, pdir)
%     figure;
%     hold on;
%     title(['Average all traces + SEM ', general.strain]);
% 
%     % Add background shading
%     patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
% 
%     % Create SEM shading
%     meanPlusSEM = avg_all_adjratios + SEM;
%     meanMinusSEM = avg_all_adjratios - SEM;
%     patch([all_secs; flip(all_secs)], [meanPlusSEM; flip(meanMinusSEM)], colors.blue, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
% 
%     % Plot mean
%     plot(all_secs, avg_all_adjratios, 'LineWidth', 1);
% 
%     % Format axes
%     xlabel('Time (s)');
%     ylabel('(R - R0)/R0');
%     ylim([plotting.ploty1avg, plotting.ploty2avg]);
%     xticks(moviepars.timesecs);
%     xticklabels(moviepars.timelabels);
%     xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
% 
%     % Save plot
%     saveas(gcf, fullfile(pdir, strcat(general.strain, '_SEMplot.png')));
%     close(gcf);
% end
% 
% %% Plot: All traces + average
% function plot_all_traces_and_avg(all_secs, all_adjratios, avg_all_adjratios, colors, plotting, moviepars, general, pdir)
%     figure;
%     hold on;
%     title(['Single Traces + AVG ', general.strain]);
% 
%     % Plot all traces
%     plot(all_secs, all_adjratios, 'Color', colors.gray, 'LineWidth', 0.6);
% 
%     % Plot average in bold black
%     plot(all_secs, avg_all_adjratios, 'k', 'LineWidth', 1.5);
% 
%     % Add background shading
%     patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
% 
%     % Format axes
%     xlabel('Time (s)');
%     ylabel('(R - R0)/R0');
%     ylim([plotting.ploty1, plotting.ploty2]);
%     xticks(moviepars.timesecs);
%     xticklabels(moviepars.timelabels);
%     xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
% 
%     % Save plot
%     saveas(gcf, fullfile(pdir, strcat(general.strain, '_all_traces.png')));
%     close(gcf);
% end
% 
% %% Plot: Heatmap
% function plot_heatmap(all_adjratios, avg_all_adjratios, colors, plotting, moviepars, general, pdir)
%     figure;
% 
%     % Transpose data for heatmap
%     all_adjratiosT = all_adjratios';
%     avg_all_adjratiosT = avg_all_adjratios';
% 
%     % Append avg trace and odour indicator (optional)
%     odour = zeros(1, length(avg_all_adjratiosT)); 
%     odour(moviepars.timeframes(1):moviepars.timeframes(2)) = plotting.hmy1; % Odour off (baseline)
%     odour(moviepars.timeframes(2):moviepars.timeframes(3)) = plotting.hmy2; % Odour on 1
%     odour(moviepars.timeframes(3):moviepars.timeframes(4)) = plotting.hmy1; % Odour off 1
% 
%     all_adjratiosT = [avg_all_adjratiosT; all_adjratiosT; odour];
% 
%     % Create transparency mask for NaNs
%     nanmatrix = ones(size(all_adjratiosT));
%     nanmatrix(isnan(all_adjratiosT)) = 0;
% 
%     % Plot heatmap
%     imagesc(all_adjratiosT, 'AlphaData', nanmatrix);
%     colormap parula;
%     colorbar;
%     caxis([plotting.hmy1, plotting.hmy2]);
%     xlabel('Time (s)');
%     ylabel('Neuron');
% 
%     % Format axes
%     xticks(moviepars.timesecs);
%     xticklabels(moviepars.timelabels);
% 
%     % Save heatmap
%     saveas(gcf, fullfile(pdir, strcat(general.strain, '_heatmap.png')));
%     close(gcf);
% end
% 
% %% Save data to spreadsheets
% function save_data_to_spreadsheets(all_adjratios, avg_all_adjratios, SEM, all_secs, general, pdir)
%     % Convert to table for saving
%     Tall_adjratios = array2table(all_adjratios);
% 
%     % Save all data
%     allratios_filename = fullfile(pdir, strcat(general.strain, '_all.xlsx'));
%     writetable(Tall_adjratios, allratios_filename, 'FileType', 'spreadsheet');
% 
%     % Save average, timepoints, and SEM
%     avg_SEM_data = [all_secs, avg_all_adjratios, SEM];
%     avgratios_filename = fullfile(pdir, strcat(general.strain, '_avg.xlsx'));
%     writematrix(avg_SEM_data, avgratios_filename, 'FileType', 'spreadsheet');
% end
