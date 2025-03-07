function plot_avg_with_sem_3cond(all_secs, avgratio_data, SEM_data, ratiotype, pdir, colors, plotting, moviepars, general)
  

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
        for group = {general.wt_genotype_code, general.mutant_genotype_code1}
            group_name = group{1};  % 'wt' or others eg pdf1

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
            title(['3cond+ SEM', general.strain, group_name], 'Interpreter', 'none');
        
            % Add background shading
            patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
            
            % Loop over the conditions (mock, avsv, sexc)
            for i = 1:3
                % Get the current condition name
                conditions = {'mock', 'avsv', 'sexc'};
                curr_cond = conditions{i};
                
                % Extract data for wt or mt group
                group_ratio = avgratio_data.(group_name).(strcat(group_name, '_', curr_cond, '_'));
                group_SEM = SEM_data.(group_name).(strcat(group_name, '_', curr_cond, '_'));

                % Create SEM shading for the current condition
                meanPlusSEM = group_ratio + group_SEM;
                meanMinusSEM = group_ratio - group_SEM;

                % Set color based on group
                if strcmp(curr_cond, 'mock')
                    group_color = colors.mockgray; % gray for mock
                elseif strcmp(curr_cond, 'avsv')
                    group_color = colors.avsvgreen; % green for avsv
                elseif strcmp(curr_cond, 'sexc')
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


        % Add a legend for the conditions
        legend({'Mock', 'AVSV', 'SEXC'}, 'Location', 'best', 'Interpreter', 'none');
    
        % Set plot export name 
        singleplotname = fullfile(pdir, strcat(general.pars,general.strain, this_plottype, '_3condSEMplot_', group_name));
         
        
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));
        
        % Save as EPS (vector graphics)
        % exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');

    
        
        close(fig);
        hold off;


        end

        disp("finished first half")
        
         % === NEW FEATURE: PLOT wt vs mutant of each condition ===

    % Check if both wt and mutant data exist
    if isfield(avgratio_data, general.wt_genotype_code) && isfield(avgratio_data, general.mutant_genotype_code1)
        conditions = {'mock', 'avsv', 'sexc'};

        %Cycle through 3 conditions and make 3 new plots
        for i = 1:3
            curr_cond = conditions{i};

            % Check if ratio data for wt and mutant exist
            wt_exists = isfield(avgratio_data.(general.wt_genotype_code), strcat(general.wt_genotype_code, '_', curr_cond, '_'));
            mt_exists = isfield(avgratio_data.(general.mutant_genotype_code1), strcat(general.mutant_genotype_code1, '_', curr_cond, '_'));

            % Skip if either is missing
            if ~wt_exists || ~mt_exists
                continue;
            end

            % Get data
            wt_ratio = avgratio_data.(general.wt_genotype_code).(strcat(general.wt_genotype_code, '_',curr_cond, '_'));
            wt_SEM = SEM_data.(general.wt_genotype_code).(strcat(general.wt_genotype_code, '_',curr_cond, '_'));
            mt_ratio = avgratio_data.(general.mutant_genotype_code1).(strcat(general.mutant_genotype_code1, '_',curr_cond, '_'));
            mt_SEM = SEM_data.(general.mutant_genotype_code1).(strcat(general.mutant_genotype_code1, '_',curr_cond, '_'));

            % Calculate SEM shading
            wt_PlusSEM = wt_ratio + wt_SEM;
            wt_MinusSEM = wt_ratio - wt_SEM;
            mt_PlusSEM = mt_ratio + mt_SEM;
            mt_MinusSEM = mt_ratio - mt_SEM;

            % Set wt color based on group
            if strcmp(curr_cond, 'mock')
                wt_color = colors.mockgray; % gray for mock
            elseif strcmp(curr_cond, 'avsv')
                wt_color = colors.avsvgreen; % green for avsv
            elseif strcmp(curr_cond, 'sexc')
                wt_color = colors.sexcondpink; %pink for sexcond
            end

            
            %Set slightly darker color for the mutant in each condition
            darkening_factor = 0.8;
            mt_color1 = wt_color * darkening_factor;


            % Create new figure
            fig = figure;
            ax = gca;
            ax.Box = 'on';
            hold on;
            
            % Title
            title([general.wt_genotype_code, ' vs ',general.mutant_genotype_code1, general.strain, curr_cond], 'Interpreter', 'none');


            % Add SEM shading for both
            patch([all_secs(moviepars.timeframes(1):moviepars.timeframes(end))' ...
                   flip(all_secs(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
                  [wt_PlusSEM(moviepars.timeframes(1):moviepars.timeframes(end))' ...
                   flip(wt_MinusSEM(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
                  wt_color, 'EdgeColor', 'none', 'FaceAlpha', 0.4);

            patch([all_secs(moviepars.timeframes(1):moviepars.timeframes(end))' ...
                   flip(all_secs(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
                  [mt_PlusSEM(moviepars.timeframes(1):moviepars.timeframes(end))' ...
                   flip(mt_MinusSEM(moviepars.timeframes(1):moviepars.timeframes(end)))'], ...
                  mt_color1, 'EdgeColor', 'none', 'FaceAlpha', 0.4);

            % Plot the mean traces
            plot(all_secs, wt_ratio, 'LineWidth', 1.5, 'Color', wt_color);
            plot(all_secs, mt_ratio, 'LineWidth', 1.5, 'Color', mt_color1);

            % Formatting
            xlabel('Time (s)');
            ylabel(this_ylab);
            ylim(these_ylims);
            xticks(moviepars.timesecs);
            xticklabels(moviepars.timelabels);
            xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
            legend({general.wt_genotype_code, general.mutant_genotype_code1,}, 'Location', 'best', 'Interpreter', 'none');

            % Save plot
            singleplotname = fullfile(pdir, strcat(general.pars, general.strain, this_plottype, general.wt_genotype_code,'vs', general.mutant_genotype_code1, curr_cond));
            saveas(fig, strcat(singleplotname, '.png'));

            hold off;
            close(fig);
        end
    end
end
