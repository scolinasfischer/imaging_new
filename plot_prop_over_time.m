function plot_prop_over_time(all_secs, dataset, category, pdir, general, colors, moviepars, analysis_pars)
    % plot_prop_over_time
    %
    % Plots the proportion of active neurons over time for multiple datasets,
    % including both non-cumulative and cumulative proportions.
    %
    % Parameters:
    %   all_secs       - Time vector for x-axis.
    %   dataset        - Structure containing datasets (prop, totalN, colors, labels, plot_title).
    %   category       - String defining the condition (offHIGH, onLOW, bLOW).
    %   pdir           - Directory path where plots should be saved.
    %   general        - Struct with genotype information and strain details.
    %   colors         - Struct with color definitions.
    %   moviepars      - Struct with timeframes, x-coordinates for patches, and axis labels.
    %   analysis_pars  - Struct containing export settings.
    %
    % Outputs:
    %   - Saves the proportion and cumulative proportion plots as PNG and EPS files.

    % === Set x-axis limits based on category ===
    switch category
        case "offHIGH"
            start_time = moviepars.bend;
            end_time = moviepars.ONend;
        case "onLOW"
            start_time = moviepars.ONend;
            end_time = moviepars.OFFend;
        case "bLOW"
            start_time = moviepars.bstart;
            end_time = moviepars.bend;
        otherwise
            error("Unexpected category: %s", category);
    end

    

    % === Plot Non-Cumulative Proportion (prop) ===
    fig_nc = figure;
    ax = gca;
    ax.Box = 'on';
    hold on;
    title([general.strain, ' ', dataset.plot_title, ' - non-cumulative Proportion Active'], 'Interpreter', 'none');
    
    % Background shading
    patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
    
    % Initialize legend handles
    trace_legendHandles = gobjects(1, length(dataset.prop));

    % Plot non-cumulative proportion for each dataset
    conditions = numel(dataset.labels);
    for c = 1:conditions
        prop_values = dataset.prop{c};
        color = dataset.colors{c};
        time = all_secs(1:moviepars.mend);
        trace_legendHandles(c) = plot(time, prop_values, 'Color', color, 'LineWidth', 1.5);
    end
    
    
    
    % Formatting
    xlabel('Time (s)');
    ylabel('Proportion of Neurons Active');
    ylim([0, 1]);
    xticks(moviepars.timesecs);
    xticklabels(moviepars.timelabels);
    xlim([start_time/9.9, end_time/9.9]);

    % Add legend for odour/buffer
    odour_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.paleblue, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    buffer_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.palegray, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);

    legend([trace_legendHandles, odour_patch, buffer_patch], ...
           [dataset.labels, {'Odour', 'Buffer'}], ...
           'Location', 'best', 'Interpreter', 'none');

    % Save non-cumulative plot
    save_plot(fig_nc, pdir, general, dataset.plot_title, 'propON', analysis_pars);
    close(fig_nc);
    clear c

    % === Calculate and Plot Cumulative Proportion (cumprop) ===
    fig_cum = figure;
    ax = gca;
    ax.Box = 'on';
    hold on;
    title([general.strain, ' ', dataset.plot_title, ' - Cumulative Proportion Active'], 'Interpreter', 'none');
    
    % Background shading
    patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
    
    % Initialize legend handles
    trace_legendHandles = gobjects(1, length(dataset.prop));

    % Compute and plot cumulative proportion
    for c = 1:conditions
        prop_values = dataset.prop{c};
        cumprop_values = cumsum(prop_values) / dataset.totalN{c}; % Normalize by total observations
        color = dataset.colors{c};
        time = all_secs(1:moviepars.mend);
        trace_legendHandles(c) = plot(time, cumprop_values, 'Color', color, 'LineWidth', 1.5);
    end

    % Formatting
    xlabel('Time (s)');
    ylabel('Cumulative Proportion of Neurons Active');
    ylim([0, 1]);
    xticks(moviepars.timesecs);
    xticklabels(moviepars.timelabels);
    xlim([start_time/9.9, end_time/9.9]);
    
    % Add legend for odour/buffer
    odour_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.paleblue, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    buffer_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.palegray, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);

    legend([trace_legendHandles, odour_patch, buffer_patch], ...
           [dataset.labels, {'Odour', 'Buffer'}], ...
           'Location', 'best', 'Interpreter', 'none');

    

    % Save cumulative proportion plot
    save_plot(fig_cum, pdir, general, dataset.plot_title, 'cumprop', analysis_pars);
    close(fig_cum);
end

function save_plot(fig, pdir, general, plot_title, suffix, analysis_pars)
    % Helper function to save the plot as PNG and EPS
    plotname = fullfile(pdir, strcat(general.pars, general.strain, '_', plot_title, '_', suffix));
    saveas(fig, strcat(plotname, '.png'));
    if analysis_pars.export_eps == "TRUE"
        exportgraphics(fig, strcat(plotname, '.eps'), 'ContentType', 'vector');
    end
end
