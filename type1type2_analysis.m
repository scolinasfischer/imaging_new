function type1type2_analysis(all_adjratios, ratiotype, col_names, T1T2analysis, cond, pdir, colors, plotting, moviepars, general)
    % Function to carry out Type1Type2 analysis and save/plot results.
    % Inputs:
    %   all_adjratios - matrix of adjusted ratios for all worms
    %   ratiotype     - String specifying the type of ratio 
    %                   ('badjratios' (baseline adjusted, R0) or 
    %                   'normratios' (minmax normalised, Fm)).
    %   col_names - cell array of worm names
    %   T1T2analysis - structure containing
    %                   T2cutoffinsecs: cutoff for Type2 classification (in seconds)
    %                   thresholdFm: minimum activation to be Type2 for minmax normalised ratios
    %                   thresholdR0: minimum activation to be Type2 for baseline-adjusted ratios
    %   pdir          - Directory path where plots should be saved.
    %   colors        - Struct containing color definitions for each condition and background.
    %   plotting      - Struct with plot limits, labels, and other formatting info.
    %   moviepars     - Struct with timeframes, x-coordinates for patches, and axis labels.
    %   general       - Struct with genotype information and strain details.



    %As is, function will categorise neurons into two types (based on activity during 1st odour ON period):
    % - type 1: has a peak of amplitude > "threshold" occurring before time "T2cutoffinsecs"
    % - type 2: the rest


%Set threshold depending on whether using badjratios or normratios

     switch ratiotype
        case "badjratios"
            threshold = T1T2analysis.thresholdR0;
        case "normratios"
            threshold = T1T2analysis.thresholdFm;
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
    T2cutoff = round(9.9 * T1T2analysis.T2cutoffinsecs);
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

    %% Step 3: Save Data to Spreadsheet
    % Save maxindex and maxvalues
    maxindexs = maxindex / 9.9; % Convert frames to seconds
    maxindexs_maxvals = [maxindexs, maxvalues];
    maxindexsname = fullfile(pdir, cond, strcat(general.strain, ratiotype, 'timetomax_maxvalue'));
   
    writematrix(maxindexs_maxvals, maxindexsname, 'FileType', 'spreadsheet');


    %save all traces and avg separated in type 1 type 2. 

    %calculate average and SEM 
    [type1avg, SEM_T1, all_secs] = compute_plot_statistics(type1, general.frame_rate);
    [type2avg, SEM_T2, all_secs] = compute_plot_statistics(type2, general.frame_rate);

    %save using groupdata_to_spreadsheet function
    save_groupdata_to_spreadsheets(type1, type1avg, "Type1", ratiotype, cols_T1,SEM_T1,pdir, cond, all_secs, general)
    save_groupdata_to_spreadsheets(type2, type2avg, "Type2", ratiotype, cols_T2,SEM_T2,pdir, cond, all_secs, general)
    

    %% Step 4: Plot Sorted Heatmap
    plot_heatmap(sorted_all_adjratiosT', avg_all_adjratiosT', ratiotype, sorted_col_names, pdir, cond, plotting, moviepars, general);


    %% Step 5: Plot Average of All Traces + SEM (Type1 and Type2) on same plot. 
%     plot_avg_with_sem_T1T2(all_secs, avg_type1, t1SEM, avg_type2, t2SEM, ratiotype, pdir, colors, plotting, moviepars, general);
    
    %Create struct with data we want to plot
    dataset.avg = {type1avg, type2avg};                   % Cell array of average data for each dataset
    dataset.sem = {SEM_T1, SEM_T2};                   % Cell array of SEM data for each dataset
    dataset.colors = {colors.lightblue, colors.darkblue};   % Cell array of colors for each dataset
    dataset.labels = {'Type1', 'Type2'};                    % Cell array of dataset labels (used in legend and title)
    dataset.plot_title = "type1type2";               % String for plot title and filename suffix


    %Call general plotting function with above dataset
    plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir,cond,colors, plotting, moviepars, general);




end
