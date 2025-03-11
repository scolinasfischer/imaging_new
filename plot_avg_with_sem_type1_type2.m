


function plot_avg_with_sem_type1_type2(all_secs, avg_type1, sem_type1, avg_type2, sem_type2, ratiotype, pdir, colors, plotting, moviepars, general)
    
%% CURRENTLY NOT IN USE _ REPLACED BY plot_avg_with_sem_flexible


% plot_avg_with_sem_type1_type2
    %
    % Plots the average ratio with SEM shading for Type1 and Type2 neurons on the same plot.
    %
    % Parameters:
    %   all_secs   - Time vector for x-axis.
    %   avg_type1  - Average ratio data for Type1 neurons (vector).
    %   sem_type1  - SEM values for Type1 neurons (vector).
    %   avg_type2  - Average ratio data for Type2 neurons (vector).
    %   sem_type2  - SEM values for Type2 neurons (vector).
    %   ratiotype  - String specifying the type of ratio:
    %                'badjratios' (baseline adjusted, R0) or 
    %                'normratios' (minmax normalized, Fm).
    %   pdir       - Directory path where plots should be saved.
    %   colors     - Struct containing colors 
    %   plotting   - Struct with plot limits, labels, and other formatting info.
    %   moviepars  - Struct with timeframes, x-coordinates for patches, and axis labels.
    %   general    - Struct with genotype information and strain details.
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

    % Calculate SEM shading for Type1 and Type2
    type1_PlusSEM = avg_type1 + sem_type1;
    type1_MinusSEM = avg_type1 - sem_type1;
    type2_PlusSEM = avg_type2 + sem_type2;
    type2_MinusSEM = avg_type2 - sem_type2;
    
    % Create new figure
    fig = figure;
    ax = gca;
    ax.Box = 'on';
    hold on;
    
    % Title
    title([general.strain, ' ', plot_type, ' (Type1 vs Type2)', ' - ', ratiotype], 'Interpreter', 'none');
    
    % Add background shading
    patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
    
    % Add SEM shading for type1 and type2
    patch([all_secs(moviepars.timeframes(1):moviepars.timeframes(end))' ...
           flip(all_secs(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
          [type1_PlusSEM(moviepars.timeframes(1):moviepars.timeframes(end))' ...
           flip(type1_MinusSEM(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
          colors.lightblue, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    
    patch([all_secs(moviepars.timeframes(1):moviepars.timeframes(end))' ...
           flip(all_secs(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
          [type2_PlusSEM(moviepars.timeframes(1):moviepars.timeframes(end))' ...
           flip(type2_MinusSEM(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
          colors.darkblue, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    
    % Plot the mean traces for Type1 and Type2 and store the handles
    trace_legendHandles(1) = plot(all_secs, avg_type1, 'LineWidth', 1.5, 'Color', colors.lightblue);
    trace_legendHandles(2) = plot(all_secs, avg_type2, 'LineWidth', 1.5, 'Color', colors.darkblue);
    
    % Create small invisible patches for odour/buffer legend
    odour_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.paleblue, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    buffer_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.palegray, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
    
    % Combine both legends (traces and odour buffer) into one
    legend([trace_legendHandles(1), trace_legendHandles(2), odour_patch, buffer_patch], ...
           {'Type1 Neurons', 'Type2 Neurons', 'Odour', 'Buffer'}, ...
           'Location', 'northeast', 'Interpreter', 'none');
    
    % Formatting
    xlabel('Time (s)');
    ylabel(ylabel_text);
    ylim(ylims);  % Set y-limits based on ratiotype
    xticks(moviepars.timesecs);
    xticklabels(moviepars.timelabels);
    xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
    
    % Save plot
    singleplotname = fullfile(pdir, strcat(general.pars, general.strain, '_', ratiotype, '_Type1vsType2'));
    
    saveas(fig, strcat(singleplotname, '.png'));
    
    % Save as EPS (vector graphics)
    exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
    
    hold off;
    close(fig);
end
