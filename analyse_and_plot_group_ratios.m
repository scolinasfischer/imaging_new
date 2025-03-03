% 3plots for within group


function analyse_and_plot_group_ratios(all_adjratios, ratiotype, worm_names, general, colors, plotting, moviepars, pdir, cond)
    % Ensure output directory exists
    if ~exist(pdir, 'dir')
        mkdir(pdir);
    end

    % Compute statistics
    [avg_all_adjratios, SEM, all_secs] = compute_plot_statistics(all_adjratios, general.frame_rate);

    % Plot 1: Average with SEM
    plot_avg_with_sem(all_secs, avg_all_adjratios, ratiotype, SEM, pdir, cond, colors, plotting, moviepars, general);

    % Plot 2: All traces + average
    plot_all_traces_and_avg(all_secs, all_adjratios, avg_all_adjratios, ratiotype,pdir, cond, colors, plotting, moviepars, general);

    % Plot 3: Heatmap
    plot_heatmap(all_adjratios, avg_all_adjratios, ratiotype, worm_names, pdir, cond, plotting, moviepars, general);

    % Save data to spreadsheets
    save_groupdata_to_spreadsheets(all_adjratios, avg_all_adjratios, ratiotype, SEM,pdir, cond, all_secs, general);

    fprintf('Analysis complete for group: %s\n', cond);
end



