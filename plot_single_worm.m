
function plot_single_worm(seconds, ratios, YLAB, this_worm_dirs, colors, plotting, moviepars)
    % PLOT_ADJRATIOS plots adjusted fluorescence ratios over time with shading.
    %
    % Inputs:
    %   seconds        - Time vector for x-axis in seconds
    %   ratios         - Fluorescence ratio values
    %   YLAB           - label for y axis, usually "R-R0/R0" or "F-Fmin/Fmax"
    %   this_worm_dirs - struct containing names for files and directories
    %   colors         - struct containing colors used in all plots
    %   ploting        - struct containing parameters for plotting
    %   moviepars      - struct containing time parameters related to movie
    

    fig = figure;
    hold on

    %plot ratios against time
    plot(seconds, ratios,'Color',[0 0.4470 0.7410], 'LineWidth', 1.5)
    
    
    % add shading for odour ON/OFF
    patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', .3,'EdgeAlpha',0 )
    

    %Set axes and labels
    ylim ([plotting.ploty1,plotting.ploty2]);
    xlim ([moviepars.timesecs(1), moviepars.timesecs(end)]);
    title(this_worm_dirs.short_fname)
    xticks(moviepars.timesecs) %s since baseline begins
    xticklabels(moviepars.timelabels) %time in secs since baseline begins
    xlabel('Time (s)')
    ylabel(YLAB)
     
    
    % Set plot export name 
    singleplotname = fullfile(this_worm_dirs.pdir, strcat(this_worm_dirs.group_name, this_worm_dirs.short_fname));
     
    % Save as PNG
    saveas(fig, strcat(singleplotname, '.png'));

    % Save as EPS (vector graphics)
    exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');

    

    close(fig)

    hold off



end

