% 3plots for within group


function [avg_all_adjratios, SEM, all_secs]= analyse_and_plot_group_ratios(all_adjratios, ratiotype, worm_names, general, analysis_pars, colors, plotting, moviepars, pdir, genotype, cond)
    % Ensure output directory exists
    if ~exist(pdir, 'dir')
        mkdir(pdir);
    end

    % Compute statistics for both Fm and R0.
    [avg_all_adjratios, SEM, all_secs] = compute_plot_statistics(all_adjratios, general.frame_rate);

    

    %Need to check current ratiotype and whether need plots for that case
    switch ratiotype
                case "badjratios"
                    if strcmp(analysis_pars.calculateR0, "TRUE") 
                        makeplots = "TRUE";
                    else
                        makeplots = "FALSE";
                    end

                case "normratios"
                    if strcmp(analysis_pars.calculateFm, "TRUE") 
                        makeplots = "TRUE";
                    else
                        makeplots = "FALSE";
                    end
        
                otherwise
                    error("Unexpected ratiotype: %s", ratiotype);
    end

    
    if strcmp(makeplots, "TRUE") 
        % Plot 1: Average with SEM
            %create structure to call general plot_avg_with_SEM_flexible
            dataset.avg = {avg_all_adjratios};
            dataset.sem = {SEM};
            dataset.colors = {[0 0.4470 0.7410]};
            dataset.labels = {'Mean ± SEM'};
            dataset.plot_title = strcat('Average all traces + SEM',cond,genotype);
    
        
            plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars);
        
        % Plot 2: All traces + average
        plot_all_traces_and_avg(all_secs, all_adjratios, avg_all_adjratios, ratiotype,pdir, genotype, cond, general, analysis_pars, colors, plotting, moviepars);

        % Plot 3: Heatmap
        heatmapname = strcat(genotype, "_", cond);
        plot_heatmap(all_adjratios, avg_all_adjratios, ratiotype, heatmapname, worm_names, pdir,  general, analysis_pars, plotting, moviepars);

        % Save data to spreadsheets
        savingname = strcat(genotype, "_", cond); 
        save_groupdata_to_spreadsheets(all_adjratios, avg_all_adjratios, ratiotype, savingname, worm_names,SEM,pdir, all_secs, general);
        
    
        fprintf('Plots complete for group: %s\n', genotype, cond, ratiotype);

    

    end


end



