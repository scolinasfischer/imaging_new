%{
Plots the ratio trace for a single worm. Includes background shading for odour/buffer periods.
Currently function is set to not export as eps, as rarely need eps of
single worms and it is very slow. But you can un-comment the section at the
bottom to allow for this function to save both eps and png plots. 


Inputs:
- seconds: (vector) Time in seconds
- ratios: (vector) Ratio trace for this worm
- ratiotype: (string) 'badjratios' or 'normratios'
- this_worm_dirs: (struct) Contains filenames and output paths
- analysis_pars:(struct) used to set export eps/png
- colors: (struct)Plot colors
- plotting: (struct)Y-axis range settings
- moviepars: (struct)Timing windows and shading info

Output:
- Saves trace plot as PNG (and optionally EPS)
%}




function plot_single_worm(seconds, ratios,ratiotype, this_worm_dirs, analysis_pars, colors, plotting, moviepars)
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
        case "normratios"
            these_ylims = [plotting.Fmploty1, plotting.Fmploty2];
            this_ylab = "F-Fmin/Fmax";

        otherwise
            error("Unexpected ratiotype: %s", ratiotype);
    end

    
    %Start plotting
%     fig = figure('visible','off');
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
        singleplotname = strcat(this_worm_dirs.fullpath, ratiotype);
         
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));


    
        % Save as EPS (vector graphics)
%         if strcmp(analysis_pars.export_eps, "TRUE")
%             exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
%         end
        


    catch ME
    warning("%s: %s", ME.identifier, ME.message); % log the error if occurs


    
    end


    close(fig);
    hold off;

end





