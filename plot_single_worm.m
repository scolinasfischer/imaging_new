
function plot_single_worm(seconds, ratios,ratiotype, this_worm_dirs, analysis_pars, colors, plotting, moviepars)
    % PLOT_ADJRATIOS plots adjusted fluorescence ratios over time with shading.
    %
    % Inputs:
    %   seconds        - Time vector for x-axis in seconds
    %   ratios         - Fluorescence ratio values    
    %   this_worm_dirs - struct containing names for files and directories
    %   colors         - struct containing colors used in all plots
    %   plotting        - struct containing parameters for plotting
    %   moviepars      - struct containing time parameters related to movie
    %   ratiotype      - string, can be: "badjratios" or "normratios", determines ylim and ylab 
        
    %input argument validation 
    arguments
            seconds (:,1) double   % Ensures input is a column vector
            ratios (:,1) double    % Ensures input is a column vector
            ratiotype (1,1) string {mustBeMember(ratiotype, ["badjratios", "normratios"])}
            this_worm_dirs struct
            analysis_pars struct
            colors struct
            plotting struct
            moviepars struct
    end

    %set Ylim and Ylabel values according to ratiotype
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

    
    %Start plotting
    fig = figure;
    try

        ax = gca; % Get current axes
        ax.Box = 'on'; % Turn on the box
        hold on
    
        %plot ratios against time
        plot(seconds, ratios,'Color',[0 0.4470 0.7410], 'LineWidth', 1.5)
        
        
        % add shading for odour ON/OFF
        patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', .3,'EdgeAlpha',0 )
        
    
        %Set axes and labels
        ylim (these_ylims);
        xlim ([moviepars.timesecs(1), moviepars.timesecs(end)]);
        title(this_worm_dirs.short_fname);

        xticks(moviepars.timesecs) %s since baseline begins
        xticklabels(moviepars.timelabels) %time in secs since baseline begins
        xlabel('Time (s)')
        ylabel(this_ylab)
         
        
        % Set plot export name 
        singleplotname = strcat(this_worm_dirs.fullpath, this_plottype);
         
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));


    
        % Save as EPS (vector graphics)
%         if strcmp(analysis_pars.export_eps, "TRUE")
%             exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
%         end
        


    catch ME
    warning("%s: %s", ME.identifier, ME.message); % log the error if occurs

    
    
%     % Ensure figure is closed even if an error occurs
%     close(fig);
%     hold off;
    
    
    end


    close(fig);
    hold off;

end





