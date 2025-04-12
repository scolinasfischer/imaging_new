%{
Plots a heatmap of all worm traces in a group, with average trace and odour timing also shown.
Can be used by group plots, ON/OFF categories, or sorted by peak time (type1 type2).

Inputs:
- all_adjratios: (matrix) Each worm's trace (rows: time, cols: worms)
- avg_all_adjratios: (vector) Average trace
- ratiotype: (string) 'badjratios' or 'normratios'
- heatmapname: (string) Used in title and output file name
- worm_names: (cell array) Labels for heatmap y-axis
- pdir: (string) Save path
- general, analysis_pars, plotting, moviepars:  structs with general and
plotting info

Output:
- Heatmap saved as PNG and optional EPS
%}


%% Plot: Heatmap
function plot_heatmap(all_adjratios, avg_all_adjratios, ratiotype, heatmapname, worm_names, pdir, general, analysis_pars, plotting, moviepars)
    
    switch ratiotype
            case "badjratios"
                these_ylims = [plotting.R0hmy1 , plotting.R0hmy2];
                this_plottitle = "R-R0/R0";
                
            case "normratios"
                these_ylims = [plotting.Fmhmy1 , plotting.Fmhmy2];
                this_plottitle = "F-Fmin/Fmax";
                
    
            otherwise
                error("Unexpected ratiotype: %s", ratiotype);
    end

    fig = figure;
        
%%%% super important! never include hold on in heatmap , as will mess with
%%%% how imagesc plots data (it was being inverted here)

    try
        ax = gca; % Get current axes
        ax.Box = 'on'; % Turn on the box


        title(['Heatmap',heatmapname, this_plottitle, general.strain],'Interpreter', 'none');
    
        % Transpose data for heatmap
        all_adjratiosT = all_adjratios';
        avg_all_adjratiosT = avg_all_adjratios';
    
        % Append avg trace and odour indicator (optional)
        odour = zeros(1, length(avg_all_adjratiosT)); 
        odour(moviepars.timeframes(1):moviepars.timeframes(2)) = these_ylims(1); % Odour off (baseline)
        odour(moviepars.timeframes(2):moviepars.timeframes(3)) = these_ylims(2); % Odour on 1
        odour(moviepars.timeframes(3):moviepars.timeframes(4)) = these_ylims(1); % Odour off 1
        odour(moviepars.timeframes(4):moviepars.timeframes(5)) = these_ylims(2); % Odour on 2
        odour(moviepars.timeframes(5):moviepars.timeframes(6)) = these_ylims(1); % Odour off 1
        
    
        all_adjratiosT = [ odour; avg_all_adjratiosT; all_adjratiosT];
        n = size(all_adjratiosT);
    
        % Create transparency mask for NaNs
        nanmatrix = ones(size(all_adjratiosT));
        nanmatrix(isnan(all_adjratiosT)) = 0;
    
        % Plot heatmap
        imagesc(all_adjratiosT, 'AlphaData', nanmatrix);
        colormap parula;
        colorbar;
        caxis(these_ylims);
        xlim([moviepars.bstart moviepars.plotendf])
        ylim([0.5, (n(1)+0.5)]);
        xlabel('Time (s)');
        ylabel('Neuron');
        yticks(1:n(1))
        yticklabels([{'ODOUR'} {'AVERAGE'} worm_names ])


    
        % Format axes
        xticks(moviepars.timeframes);
        xticklabels(moviepars.timelabels);

      
        % Set plot export name 
        singleplotname = fullfile(pdir, strcat(general.strain, ratiotype,heatmapname, '_heatmap'));

         
        % Save as PNG
        saveas(fig, strcat(singleplotname, '.png'));
    
        % Save as EPS (vector graphics)
        
        if analysis_pars.export_eps
            exportgraphics(fig, strcat(singleplotname, '.eps'), 'ContentType', 'vector');
        end

    catch ME
        warning("%s: %s", ME.identifier, ME.message); % log the error if occurs
    
    end

    close(fig);
    hold off;

end