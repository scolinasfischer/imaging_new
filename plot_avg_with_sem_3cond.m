function plot_avg_with_sem_3cond(all_secs, avgratio_data, SEM_data, ratiotype, colors, plotting, moviepars, general)
  

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


    
        
        % Loop over wt and mt groups
        for group = {'wt', 'mt'}
            group_name = group{1};  % 'wt' or 'mt'

            % Skip group if no data is available for that group (eg if no
            % mutant)
            if ~isfield(avgratio_data, group_name) || ~isfield(SEM_data, group_name)
                continue; % Skip this group if no data exists
            end

            % Set up figure
            fig = figure;
            
            ax = gca; % Get current axes
            ax.Box = 'on'; % Turn on the box
            hold on
            
            % Title
            title(['3cond+ SEM', general.strain, ' ', group_name], 'Interpreter', 'none');
        
            % Add background shading
            patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
            
            % Loop over the conditions (mock, avsv, sexc)
            for i = 1:3
                % Get the current condition name
                cond = {'mock', 'avsv', 'sexc'}{i};
                
                % Extract data for wt or mt group
                group_ratio = avgratio_data.(group_name).(strcat(group_name, '_', cond));
                group_SEM = SEM_data.(group_name).(strcat(group_name, '_', cond));

                % Create SEM shading for the current condition
                meanPlusSEM = group_ratio + group_SEM;
                meanMinusSEM = group_ratio - group_SEM;

                % Set color based on group
                if strcmp(cond, 'mock')
                    group_color = colors.mockgray; % gray for mock
                elseif strcomp(cond, 'avsv')
                    group_color = colors.avsvgreen; % green for avsv
                elseif strcomp(cond, 'sexc')
                    group_color = colors.sexcondpink; %pink for sexcond
                end
                

                % Patch for SEM shading
                patch([all_secs(moviepars.timeframes(1):moviepars.timeframes(end))' flip(all_secs(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
                    [meanPlusSEM(moviepars.timeframes(1):moviepars.timeframes(end))' flip(meanMinusSEM(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
                    group_color, 'EdgeColor', 'none', 'FaceAlpha', 0.4);

                
                % Plot the average (mean trace) for the current condition
                plot(all_secs, group_ratio, 'LineWidth', 1, 'Color', group_color);
            end



        % Format axes
        xlabel('Time (s)');
        ylabel(this_ylab);
        ylim(these_ylims);
        xticks(moviepars.timesecs);
        xticklabels(moviepars.timelabels);
        xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
    
        % Set plot export name 
        singleplotname = fullfile(general.pars, strcat(general.strain, this_plottype, '_3condSEMplot_', group_name));
         
        
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));
        
        % Save as EPS (vector graphics)
        % exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');

    

        close(fig);
        hold off;


        end
        
        
end
