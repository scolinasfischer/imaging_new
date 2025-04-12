%{
Plots the average fluorescence trace with SEM shading for one or more datasets.
Includes background shading for stimulus periods (odour/buffer), and optional export to EPS.

Inputs:
- all_secs: (vector) Time in seconds (x-axis)
- dataset (struct): Contains data to plot. Format:
    - dataset.avg{i} (vector): Mean trace for condition i
    - dataset.sem{i} (vector): SEM trace for condition i
    - dataset.colors{i} (1×3 vector): RGB color for condition i
    - dataset.labels{i} (string): Label (used in legend) for condition i
    - dataset.plot_title (string): Title for plot
- ratiotype: (string) 'badjratios' or 'normratios'
- pdir: (string) Directory to save plot
- general: (struct) Strain and parameter labels
- analysis_pars: (struct) Here use to set eps/png export
- colors: (struct) Color definitions including odour shading
- plotting: (struct) Y-axis limits
- moviepars: (struct) X-axis ticks, shading coordinates, label times

Output:
- Saves plot as PNG and (optionally) EPS
%}


function plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir,general, analysis_pars, colors, plotting, moviepars)

    % === Set up y-axis limits and labels based on ratiotype ===
    switch ratiotype
        case "badjratios"
            ylims = [plotting.R0ploty1avg, plotting.R0ploty2avg];
            ylabel_text = 'R-R0/R0';

        case "normratios"
            ylims = [plotting.Fmploty1avg, plotting.Fmploty2avg];
            ylabel_text = 'F-Fmin/Fmax';

        otherwise
            error("Unexpected ratiotype: %s", ratiotype);
    end

    % Create new figure
    fig = figure;
    ax = gca;
    ax.Box = 'on';
    hold on;
    
    % Title (use the provided title for general description)
    title([general.strain, ' ', dataset.plot_title, ' - ', ratiotype], 'Interpreter', 'none');
    
    % Add background shading
    patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);


    % Initialize legend handles
    trace_legendHandles = gobjects(1, length(dataset.avg)); 

    % Loop over datasets and plot each
    for i = 1:length(dataset.avg)
        avg = dataset.avg{i};
        sem = dataset.sem{i};
        color = dataset.colors{i};
%         label = dataset.labels{i};
        
        % Calculate SEM shading for current dataset
        avgPlusSEM = avg + sem;
        avgMinusSEM = avg - sem;
        


        % Add SEM shading for the current dataset

        patch([all_secs(moviepars.timeframes(1):moviepars.plotendf)' ...
               flip(all_secs(moviepars.timeframes(1):moviepars.plotendf))'], ...
              [avgPlusSEM(moviepars.timeframes(1):moviepars.plotendf)' ...
               flip(avgMinusSEM(moviepars.timeframes(1):moviepars.plotendf))'], ...
              color, 'EdgeColor', 'none', 'FaceAlpha', 0.4);


        % Plot the mean trace for the current dataset
        trace_legendHandles(i) = plot(all_secs, avg, 'LineWidth', 1, 'Color', color);
    end

    % Create small invisible patches for odour/buffer legend
    odour_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.paleblue, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    buffer_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.palegray, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    
    % Combine all legends (dataset traces and odour/buffer)
    legend([trace_legendHandles, odour_patch, buffer_patch], ...
           [dataset.labels, {'Odour', 'Buffer'}], ...
           'Location', 'best', 'Interpreter', 'none');
    
    % Formatting
    xlabel('Time (s)');
    ylabel(ylabel_text);
    ylim(ylims);  
    xticks(moviepars.timesecs);
    xticklabels(moviepars.timelabels);
    xlim([moviepars.timesecs(1), moviepars.plotends]);
    
    % Save plot
    singleplotname = fullfile(pdir, strcat(general.pars, general.strain, '_', dataset.plot_title, ratiotype));
    
    saveas(fig, strcat(singleplotname, '.png'));
    
    % Save as EPS (vector graphics)
    if analysis_pars.export_eps
        exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
    end
    
    hold off;
    close(fig);
end
