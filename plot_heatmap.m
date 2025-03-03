

%% Plot: Heatmap
function plot_heatmap(all_adjratios, avg_all_adjratios, ratiotype, worm_names, pdir, cond, plotting, moviepars, general)
    
    switch ratiotype
            case "badjratios"
                these_ylims = [plotting.R0plothmy1 , plotting.R0plothmy2];
                this_plottitle = "R-R0/R0";
                this_plottype = plotting.R0name;
            case "normratios"
                these_ylims = [plotting.Fmplothmy1, plotting.Fmplothmy2];
                this_plottitle = "F-Fmin/Fmax";
                this_plottype = plotting.Fmname;
    
            otherwise
                error("Unexpected ratiotype: %s", ratiotype);
    end

        
    try
        ax = gca; % Get current axes
        ax.Box = 'on'; % Turn on the box
        hold on

        title(['Heatmap', cond, this_plottitle, general.strain]);
    
        % Transpose data for heatmap
        all_adjratiosT = all_adjratios';
        avg_all_adjratiosT = avg_all_adjratios';
    
        % Append avg trace and odour indicator (optional)
        odour = zeros(1, length(avg_all_adjratiosT)); 
        odour(moviepars.timeframes(1):moviepars.timeframes(2)) = plotting.hmy1; % Odour off (baseline)
        odour(moviepars.timeframes(2):moviepars.timeframes(3)) = plotting.hmy2; % Odour on 1
        odour(moviepars.timeframes(3):moviepars.timeframes(4)) = plotting.hmy1; % Odour off 1
        odour(moviepars.timeframes(4):moviepars.timeframes(5)) = plotting.hmy2; % Odour on 2
        odour(moviepars.timeframes(5):moviepars.timeframes(6)) = plotting.hmy1; % Odour off 1
        
    
        all_adjratiosT = [avg_all_adjratiosT; all_adjratiosT; odour];
    
        % Create transparency mask for NaNs
        nanmatrix = ones(size(all_adjratiosT));
        nanmatrix(isnan(all_adjratiosT)) = 0;
    
        % Plot heatmap
        imagesc(all_adjratiosT, 'AlphaData', nanmatrix);
        colormap parula;
        colorbar;
        caxis(these_ylims);
        xlabel('Time (s)');
        ylabel('Neuron');
        yticks(1:length(all_adjratios))
        yticklabels([{'AVERAGE'} worm_names {'ODOUR'}])

    
        % Format axes
        xticks(moviepars.timesecs);
        xticklabels(moviepars.timelabels);


    
        % Set plot export name 
        singleplotname = strcat(pdir, cond, this_plottype, '_heatmap');
         
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));
    
        % Save as EPS (vector graphics)
        % exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');

    catch ME
        warning("%s: %s", ME.identifier, ME.message); % log the error if occurs
    
    end
end