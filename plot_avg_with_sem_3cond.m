function plot_avg_with_sem_3cond(all_secs, avgratio_data, SEM_data, ratiotype, pdir, colors, plotting, moviepars, general)
%% plot_avg_with_sem_3cond
% Plots the average ratio with SEM shading for three conditionings 
% (mock, aversive, and sexually conditioning) for both wild-type (WT) and 
% mutant (MT) genotypes (if present). Additionally, if mutant data is present, 
% it generates comparative plots of WT vs. mutant data for each condition.
%
% Parameters:
%   all_secs      - Time vector for x-axis.
%   avgratio_data - Struct containing average ratio data for each genotype 
%                   and condition.
%   SEM_data      - Struct containing SEM values for each genotype and condition.
%   ratiotype     - String specifying the type of ratio 
%                   ('badjratios' (baseline adjusted, R0) or 
%                   'normratios' (minmax normalised, Fm)).
%   pdir          - Directory path where plots should be saved.
%   colors        - Struct containing color definitions for each condition and background.
%   plotting      - Struct with plot limits, labels, and other formatting info.
%   moviepars     - Struct with timeframes, x-coordinates for patches, and axis labels.
%   general       - Struct with genotype information and strain details.
%
% Functionality:
% 1. Plots mean ratio values with SEM shading for each genotype (WT & mutant) 
%    across the three conditions.
% 2. Generates separate plots comparing WT and MT in each condition (if
%       mutant data is present)
% 3. Saves all plots as PNG and EPS files.
%
% Outputs:
% - Figures are saved but not returned to the workspace.  




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

            
            % Initialize an array to store plot handles for the legend
            trace_legendHandles = gobjects(1,3);  

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
                trace_legendHandles(i) = plot(all_secs, group_ratio, 'LineWidth', 1.5, 'Color', group_color);

            end
          
            % Format axes
            xlabel('Time (s)');
            ylabel(this_ylab);
            ylim(these_ylims);
            xticks(moviepars.timesecs);
            xticklabels(moviepars.timelabels);
            xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);
    
            %Add legend for traces and odour/buffer blocks

%                 % Add the legend for traces using the stored plot handles
%                 legend(legendHandles, {'Mock', 'Aversive', 'Sex Cond'}, 'Location', 'northeast', 'Interpreter', 'none');
%         
%     
                % Create small invisible patches for odour/buffer
                odour_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.blue, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
                buffer_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.gray, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
                
                % Combine trace handles and odour/buffer patches in one legend
                legend([trace_legendHandles, odour_patch, buffer_patch], ...
                       {'Mock', 'Aversive', 'Sex Cond', 'Odour', 'Buffer'}, ...
                       'Location', 'northeast', 'Interpreter', 'none');

        
            % Set plot export name 
            singleplotname = fullfile(pdir, strcat(general.pars,general.strain, this_plottype, '_3condSEMplot_', group_name));
             
            
            % Save as PNG
            saveas(fig, strcat(singleplotname, '.png'));
            
            % Save as EPS (vector graphics)
            exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
    
        
            
            close(fig);
            hold off;


        end

        
         % === NEW FEATURE: PLOT wt vs mutant of each condition ===

    % Check if both wt and mutant data exist
    if isfield(avgratio_data, general.wt_genotype_code) && isfield(avgratio_data, general.mutant_genotype_code1)
        conditions = {'mock', 'avsv', 'sexc'};


    % Store plot handles for legend (2 rows for wt & mt, 3 columns for conditions)
    trace_legendHandles = gobjects(2,3);

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
            title([general.wt_genotype_code ' vs ' general.mutant_genotype_code1, general.strain, curr_cond], 'Interpreter', 'none');

            % Add background shading
            patch(moviepars.xcoords, moviepars.ycoords, colors.patchcolors3d, 'FaceAlpha', 0.3, 'EdgeAlpha', 0);


            % Add SEM shading for wt and mutant
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


 
            
            % Plot the mean traces and store the handles
            trace_legendHandles(1, i) = plot(all_secs, wt_ratio, 'LineWidth', 1.5, 'Color', wt_color);
            trace_legendHandles(2, i) = plot(all_secs, mt_ratio, 'LineWidth', 1.5, 'Color', mt_color1);
        
            
            % Create small invisible patches for odour/buffer legend
            odour_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.blue, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
            buffer_patch = plot(nan, nan, 's', 'MarkerFaceColor', colors.gray, 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
            
            % Combine both legends (traces and odour buffer) into one
            legend([trace_legendHandles(1, i), trace_legendHandles(2, i), odour_patch, buffer_patch], ...
                   {general.wt_genotype_code, general.mutant_genotype_code1, 'Odour', 'Buffer'}, ...
                   'Location', 'northeast', 'Interpreter', 'none');


            % Formatting
            xlabel('Time (s)');
            ylabel(this_ylab);
            ylim(these_ylims);
            xticks(moviepars.timesecs);
            xticklabels(moviepars.timelabels);
            xlim([moviepars.timesecs(1), moviepars.timesecs(end)]);

            % Save plot
            singleplotname = fullfile(pdir, strcat(general.pars, general.strain, this_plottype, '_', general.wt_genotype_code,'vs', general.mutant_genotype_code1, curr_cond));
            
            saveas(fig, strcat(singleplotname, '.png'));

            % Save as EPS (vector graphics)
            exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');


            hold off;
            close(fig);
        end
    end
end
