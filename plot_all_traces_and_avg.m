%% Plot: All traces + average
function plot_all_traces_and_avg(all_secs, all_adjratios, avg_all_adjratios, ratiotype,pdir, cond, colors, plotting, moviepars, general)
    
    switch ratiotype
        case "badjratios"
            these_ylims = [plotting.R0ploty1 , plotting.R0ploty2];
            this_ylab = "R-R0/R0";
            this_plottype = plotting.R0name;
        case "normratios"
            these_ylims = [plotting.Fmploty1, plotting.Fmploty2];
            this_ylab = "F-Fmin/Fmax";
            this_plottype = plotting.Fmname;

        otherwise
            error("Unexpected ratiotype: %s", ratiotype);
    end
    

    fig = figure;

    try 
        ax = gca; % Get current axes
        ax.Box = 'on'; % Turn on the box
        hold on

        title(['Single Traces + AVG ', cond, general.strain]);
    
        % Plot all traces
        plot(all_secs, all_adjratios, 'Color', colors.gray, 'LineWidth', 0.6);
    
        % Plot average in bold black
        plot(all_secs, avg_all_adjratios, 'k', 'LineWidth', 1.5);
    
        % Add background shading
        patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
    
        % Format axes
        xlabel('Time (s)');
        ylabel(this_ylab);
        ylim(these_ylims);
        xticks(moviepars.timesecs);
        xticklabels(moviepars.timelabels);
        xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
    
    
        % Set plot export name 
        singleplotname = strcat(pdir, cond, this_plottype, '_all_traces_avg');
         
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));
    
        % Save as EPS (vector graphics)
        % exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');

    catch ME

        warning("%s: %s", ME.identifier, ME.message); % log the error if occurs


    end

    close(fig);
    hold off;
end
