
%% Plot: Average with SEM
function plot_avg_with_sem(all_secs, avg_all_adjratios,ratiotype, SEM, pdir, cond, colors, plotting, moviepars, general)
    
     switch ratiotype
        case "badjratios"
            these_ylims = [plotting.R0ploty1avg , plotting.R0ploty2avg];
            this_ylab = "R-R0/R0";
            this_plottype = plotting.R0name;
        case "normratios"
            these_ylims = [plotting.Fmploty1avg, plotting.Fmploty2avg];
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
       
        title(['Average all traces + SEM ', cond, general.strain]);
    
        % Add background shading
        patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
    
        % Create SEM shading
        meanPlusSEM = avg_all_adjratios + SEM;
        meanMinusSEM = avg_all_adjratios - SEM;
        patch([all_secs; flip(all_secs)], [meanPlusSEM; flip(meanMinusSEM)], colors.blue, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    
        % Plot mean
        plot(all_secs, avg_all_adjratios, 'LineWidth', 1);
    
        % Format axes
        xlabel('Time (s)');
        ylabel(this_ylab);
        ylim(these_ylims);
        xticks(moviepars.timesecs);
        xticklabels(moviepars.timelabels);
        xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
    

        % Set plot export name 
        singleplotname = strcat(pdir, cond, this_plottype, '_SEMplot');
         
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