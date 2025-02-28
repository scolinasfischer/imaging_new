
function plot_single_worm(seconds, ratios, plot_params, this_worm_dirs, colors, plotting, moviepars)
    % PLOT_ADJRATIOS plots adjusted fluorescence ratios over time with shading.
    %
    % Inputs:
    %   seconds        - Time vector for x-axis in seconds
    %   ratios         - Fluorescence ratio values
    %   plot.params    - struct to contain name-value input arguments
    %                    *ratiotype: "badjratios" or "normratios", determines ylim and ylab 
    %   this_worm_dirs - struct containing names for files and directories
    %   colors         - struct containing colors used in all plots
    %   ploting        - struct containing parameters for plotting
    %   moviepars      - struct containing time parameters related to movie
        
    arguments
        seconds (:,1) double    %ensures input is column vector
        ratios (:,1) double     %ensures input is column vector
        plot_params.ratiotype (1,1) string {mustBeMember(plot_params.ratiotype, ["badjratios", "normratios"])} 
                                %ensures input is single string and is one of those two options!
        
        this_worm_dirs struct   %ensures input is struct
        colors struct           %ensures input is struct
        plotting struct         %ensures input is struct
        moviepars struct        %ensures input is struct
    end


    %set Ylim and Ylabel values according to ratiotype

    if strcmp(plot_params.ratiotype, "badjratios")
        these_ylims = [plotting.ploty1R0,plotting.ploty2R0];
        this_ylab   = "R-R0/R0";
    elseif strcmp(plot_params.ratiotype, "normratios")
        these_ylims = [plotting.ploty1Fm,plotting.ploty2Fm];
        this_ylab   = "F-Fmin/Fmax";
    else
        error("Unexpected ratiotype: %s", plot_params.ratiotype);
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
        title(this_worm_dirs.short_fname, 'Interpreter', 'none') %interpreter none avoids latex formatting
        xticks(moviepars.timesecs) %s since baseline begins
        xticklabels(moviepars.timelabels) %time in secs since baseline begins
        xlabel('Time (s)')
        ylabel(this_ylab)
         
        
        % Set plot export name 
        singleplotname = this_worm_dirs.fullpath;
         
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));
    
        % Save as EPS (vector graphics)
       % exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
    
        


    catch ME
    warning("Error during plotting: %s", ME.message); % Log the error
    end

    % Ensure figure is closed to free memory, even if error in plotting
    close(fig);
    hold off;


end





