function plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, plotting, moviepars, general)


dataset.avg = {avg_type1, avg_type2};                   % Cell array of average data for each dataset
dataset.sem = {sem_type1, sem_type2};                   % Cell array of SEM data for each dataset
dataset.colors = {colors.lightblue, colors.darkblue};   % Cell array of colors for each dataset
dataset.labels = {'Type1', 'Type2'};                    % Cell array of dataset labels (used in legend and title)
dataset.plot_title = "example1_testT1T2";               % String for plot title and filename suffix





    % plot_avg_with_sem_multi_datasets
    %
    % Plots the average ratio with SEM shading for multiple datasets on the same plot.
    %
    % Parameters:
    %   all_secs       - Time vector for x-axis.
    %   data           - Structure containing the datasets (avg, sem, colors, labels, plot_title).
    %   ratiotype      - String specifying the type of ratio: 'badjratios' or 'normratios'.
    %   pdir           - Directory path where plots should be saved.
    %   plotting       - Struct with plot limits, labels, and other formatting info.
    %   moviepars      - Struct with timeframes, x-coordinates for patches, and axis labels.
    %   general        - Struct with genotype information and strain details.
    %
    % Outputs:
    %   - Saves the plot to the specified directory as PNG and EPS files.

    % === Set up y-axis limits and labels based on ratiotype ===
    switch ratiotype
        case "badjratios"
            ylims = [plotting.R0ploty1avg, plotting.R0ploty2avg];
            ylabel_text = 'R-R0/R0';
            plot_type = plotting.R0name;
        case "normratios"
            ylims = [plotting.Fmploty1avg, plotting.Fmploty2avg];
            ylabel_text = 'F-Fmin/Fmax';
            plot_type = plotting.Fmname;
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
        label = dataset.labels{i};
        
        % Calculate SEM shading for current dataset
        PlusSEM = avg + sem;
        MinusSEM = avg - sem;
        
        % Add SEM shading for the current dataset
        patch([all_secs(moviepars.timeframes(1):moviepars.timeframes(end))' ...
               flip(all_secs(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
              [PlusSEM(moviepars.timeframes(1):moviepars.timeframes(end))' ...
               flip(MinusSEM(moviepars.timeframes(1):moviepars.timeframes(1)))'], ...
              color, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
        
        % Plot the mean trace for the current dataset
        trace_legendHandles(i) = plot(all_secs, avg, 'LineWidth', 1.5, 'Color', color);
    end

    % Create small invisible patches for odour/buffer legend
    odour_patch = plot(nan, nan, 's', 'MarkerFaceColor', dataset.colors{end}, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    buffer_patch = plot(nan, nan, 's', 'MarkerFaceColor', dataset.colors{end-1}, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    
    % Combine all legends (dataset traces and odour/buffer)
    legend([trace_legendHandles, odour_patch, buffer_patch], ...
           [dataset.labels, {'Odour', 'Buffer'}], ...
           'Location', 'northeast', 'Interpreter', 'none');
    
    % Formatting
    xlabel('Time (s)');
    ylabel(ylabel_text);
    ylim(ylims);  
    xticks(moviepars.timesecs);
    xticklabels(moviepars.timelabels);
    xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
    
    % Save plot
    singleplotname = fullfile(pdir, strcat(general.pars, general.strain, '_', plot_title, '_', ratiotype));
    
    saveas(fig, strcat(singleplotname, '.png'));
    
    % Save as EPS (vector graphics)
    exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
    
    hold off;
    close(fig);
end
