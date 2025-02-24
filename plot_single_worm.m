
function plot_single_worm(seconds, ratios, timesecs, timelabels, ycoords, colors3d, ploty1, ploty2, worm_name, group_name, pdir)
    % PLOT_ADJRATIOS plots adjusted fluorescence ratios over time with shading.
    %
    % Inputs:
    %   seconds     - Time vector for x-axis in seconds
    %   ratios      - Fluorescence ratio values
    %   timesecs    - Time points for x-axis ticks and shading
    %   timelabels  - Labels for x-axis ticks
    %   ycoords     - Y-coordinates for shaded regions (odour on/off)
    %   colors      - Color matrix for shaded regions (odour on/off)
    %   ploty1      - Lower y-axis limit
    %   ploty2      - Upper y-axis limit
    %   worm_name   - Title of the figure (has number of worm and date)
    %   group_name  - Prefix for saved file name (strain, cond, pars)
    %   pdir        - Directory to save the plot


    fig = figure
    hold on

    %plot ratios against time
    plot(seconds, ratios,'Color',[0 0.4470 0.7410], 'LineWidth', 1.5)
    
    
    % add shading for odour ON/OFF
    xcoords = [timesecs(1:end-1); timesecs(1:end-1); timesecs(2:end); timesecs(2:end)];
    
    
    patch(xcoords, ycoords, colors3d, 'FaceAlpha', .3,'EdgeAlpha',0 )
    

    %Set axes and labels
    ylim ([ploty1,ploty2]);
    xlim ([timesecs(1), timesecs(end)]);
    title(worm_name)
    xticks(timesecs) %s since baseline begins
    xticklabels(timelabels) %time in secs since baseline begins
    xlabel('Time (s)')
    ylabel('(R - R0)/R0')
     
    
    % Set plot export name 
    singleplotname = fullfile(pdir, strcat(group_name, worm_name));
     
    % Save as PNG
    saveas(fig, strcat(singleplotname, '.png'));

    % Save as EPS (vector graphics)
    exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');

    

    close(fig)

    hold off



end


% plot_adjratios(seconds, badjratios, timesecs, timelabels, ycoords, colors, ploty1, ploty2, short_fname, group_name, pdir);
