%{
Plots the proportion of neurons active over time in a given ON/OFF category (non-cumulative).

Inputs:
- all_secs: (vector) Time in seconds
- dataset: (struct) Contains:
    - prop: cell array of proportion active (over time)
    - totalN: number of neurons per condition
    - colors, labels, plot_title
- category: (string) 'offHIGH' | 'onLOW' | 'bLOW'
- pdir: (string) Directory to save
- general, colors, moviepars, analysis_pars: structs with general and
plotting info

Output:
- Saves non-cumulative proportion plots as PNG and optional EPS
%}


function plot_prop_over_time(all_secs, dataset, category, pdir, general, colors, moviepars, analysis_pars)


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

    % Save non-cumulative proportion plot
    save_plot(fig_nc, pdir, general, dataset.plot_title, 'propON', analysis_pars);
    close(fig_nc);


end

function save_plot(fig, pdir, general, plot_title, suffix, analysis_pars)
    % Helper function to save the plot as PNG and EPS
    plotname = fullfile(pdir, strcat(general.pars, general.strain, '_', plot_title, '_', suffix));
    saveas(fig, strcat(plotname, '.png'));
    if analysis_pars.export_eps 
        exportgraphics(fig, strcat(plotname, '.eps'), 'ContentType', 'vector');
    end
end
