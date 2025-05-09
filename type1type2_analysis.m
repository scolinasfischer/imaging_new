
    %{
Classifies worms as Type1 or Type2 based on:
- time to peak response  during odour ON 1
- amplitude of max response during odour ON 1

Type1: peak occurs before cutoff or is below threshold  
Type2: peak occurs after cutoff AND above threshold

Also:
- Sorts worms by time to peak and plots a heatmap
- Saves max times, values, average traces, and summary stats

Inputs:
- all_adjratios: matrix of adjusted ratios for all neurons (rows: time, cols: worms)
- ratiotype: - String specifying the type of ratio 
                       ('badjratios' (baseline adjusted, R0) or 
                       'normratios' (minmax normalised, Fm)).
- col_names: cell array of worm(neuron) names
- analysis_pars: struct defining activity thresholds and time cutoff
- genotype, cond: for labels and saving
- pdir: output directory
- general, colors, plotting, moviepars: structs with general and plotting info

Outputs:
- nT1, nT2: number of Type1 and Type2 neurons
- Side effects: heatmap, avg plots, Excel exports
%}


function [nT1, nT2 ]=  type1type2_analysis(all_adjratios, ratiotype, col_names, analysis_pars, genotype, cond, pdir,general, colors, plotting, moviepars )
    

%Set threshold depending on whether using badjratios or normratios

     switch ratiotype
        case "badjratios"
            threshold = analysis_pars.T1T2analysispars.thresholdR0;
        case "normratios"
            threshold = analysis_pars.T1T2analysispars.thresholdFm;
        otherwise
            error("Unexpected ratiotype: %s", ratiotype);
    end


    %% Step 1: Sort Data by Time to Peak
    % Transpose all_adjratios and avg_all_adjratios to have worms in rows, frames in columns
    all_adjratiosT = all_adjratios';
    avg_all_adjratiosT = mean(all_adjratios, 2, 'omitnan')';


    % Extract the window fof all_adjratiosT that will be sorted (odour ON window)
    window = all_adjratiosT(:, moviepars.timeframes(2):moviepars.timeframes(3));
    
    % Calculate mean and peak values during odour ON
    meanvalues = mean(window, 2, 'omitnan'); %returns, for each row(worm) the average  across all columns ie avg activation in that window
    [maxvalues, maxindex] = max(window, [], 2); %returns, for each row(worm) the max  across all columns ie max activation in that window

    % Sort by time to peak
    [~, index] = sort(maxindex);
    sorted_all_adjratiosT = all_adjratiosT(index, :);
    sorted_col_names = col_names(index);



    %% Step 2: Categorize into Type1 and Type2
    framerate = general.frame_rate;  % or wherever you store it globally
    T2cutoff = round(framerate * analysis_pars.T1T2analysispars.T2cutoffinsecs);



    type1 = [];
    type2 = [];
    % nb these matrices are not transposed, same format as all_adjratios:
    % (worms are columns, frames as rows)

    cols_T1 = {};
    cols_T2 = {};

    for s = 1:size(all_adjratiosT, 1) %cycle through each individual worm
        this_maxindex = maxindex(s) + moviepars.bend; %this_maxindex is frame number at which max point occurs. 
                                       % is the index within odour ON  window (maxindex(s)) 
                                       % + frames until baseline ends (moviepars.bend)

        if maxindex(s) > T2cutoff && all_adjratios(this_maxindex,s) >= threshold
            % Classify as Type2 
            type2 = [type2 all_adjratios(:, s)];
            cols_T2 = [cols_T2 col_names(s)];
        else
            % Classify as Type1
            type1 = [type1 all_adjratios(:, s)];
            cols_T1 = [cols_T1 col_names(s)];
        end
    end

    % Save number of type 1 and type 2 to output variables:
    nT1 = length(cols_T1);
    nT2 = length(cols_T2);

    %% Step 3: Save Data to Spreadsheet
    % Save maxindex and maxvalues
    maxindexs = maxindex / framerate; % Convert frames to seconds
    maxindexs_maxvals = [maxindexs, maxvalues];
    maxindexsname = fullfile(pdir, strcat(general.strain, genotype, cond, ratiotype, 'timetomax_maxvalue'));
   
    writematrix(maxindexs_maxvals, maxindexsname, 'FileType', 'spreadsheet');


    %save all traces and avg separated in type 1 type 2. 

    %calculate average and SEM 
    [type1avg, SEM_T1, all_secs] = compute_plot_statistics(type1, general.frame_rate);
    [type2avg, SEM_T2, all_secs] = compute_plot_statistics(type2, general.frame_rate);

    %save using groupdata_to_spreadsheet function
    save_groupdata_to_spreadsheets(type1, type1avg, ratiotype, "Type1", cols_T1,SEM_T1, pdir, all_secs, general)
    save_groupdata_to_spreadsheets(type2, type2avg, ratiotype, "Type2",cols_T2,SEM_T2, pdir, all_secs, general)

    

    %% Step 4: Plot Sorted Heatmap
    plot_heatmap(sorted_all_adjratiosT', avg_all_adjratiosT', ratiotype, "Sorted timetomax",sorted_col_names, pdir, general, analysis_pars, plotting, moviepars);


    %% Step 5: Plot Average of All Traces + SEM (Type1 and Type2) on same plot. 
%     plot_avg_with_sem_T1T2(all_secs, avg_type1, t1SEM, avg_type2, t2SEM, ratiotype, pdir, colors, plotting, moviepars, general);
    
    %Create struct with data we want to plot
    dataset.avg = {type1avg, type2avg};                           % Cell array of average data for each dataset
    dataset.sem = {SEM_T1, SEM_T2};                               % Cell array of SEM data for each dataset
    dataset.colors = {colors.lightblue, colors.darkblue};         % Cell array of colors for each dataset
    dataset.labels = {'Type1', 'Type2'};                          % Cell array of dataset labels (used in legend and title)
    dataset.plot_title = strcat("type1type2 ", genotype, cond);   % String for plot title and filename suffix


    %Call general plotting function with above dataset
    plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir,general, analysis_pars, colors, plotting, moviepars);




end
