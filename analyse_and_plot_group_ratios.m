%{
Computes average and SEM for all traces in a group and generates group-level plots:
- Avg ± SEM
- All individual traces + avg
- Heatmap of all worms
Also saves data tables.

Inputs:
- all_adjratios: matrix of adjusted ratios (rows: time, cols: worms)
- ratiotype: "badjratios" or "normratios"
- worm_names: list of worm IDs
- general, analysis_pars, colors, plotting, moviepars: parameter structs
- pdir: saving directory
- genotype, cond: for filenames
- name: suffix to use for plots/files

Outputs:
- avg_all_adjratios: mean trace
- SEM: standard error of the mean
- all_secs: time vector
%}


function [avg_all_adjratios, SEM, all_secs]= analyse_and_plot_group_ratios(all_adjratios, ratiotype, worm_names, general, analysis_pars, colors, plotting, moviepars, pdir, genotype, cond,name)
    % Ensure output directory exists
    if ~exist(pdir, 'dir')
        mkdir(pdir);
    end

    % Compute statistics for both Fm and R0.
    [avg_all_adjratios, SEM, all_secs] = compute_plot_statistics(all_adjratios, general.frame_rate);

    

    %Need to check current ratiotype and whether need plots for that case
    switch ratiotype
                case "badjratios"
                    if analysis_pars.calculateR0
                        makeplots = true;
                    else
                        makeplots = false;
                    end

                case "normratios"
                    if analysis_pars.calculateFm
                        makeplots = true;
                    else
                        makeplots = false;
                    end
        
                otherwise
                    error("Unexpected ratiotype: %s", ratiotype);
    end

    savingname = strcat(genotype, cond, name); 


    if makeplots
        % Plot 1: Average with SEM
            %create structure to call general plot_avg_with_SEM_flexible
            dataset.avg = {avg_all_adjratios};
            dataset.sem = {SEM};
            dataset.colors = {[0 0.4470 0.7410]};
            dataset.labels = {'Mean ± SEM'};
            dataset.plot_title = strcat('Average all traces + SEM',savingname);
    
        
            plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars);
        
        % Plot 2: All traces + average
        plot_all_traces_and_avg(all_secs, all_adjratios, avg_all_adjratios, ratiotype,savingname,pdir, general, analysis_pars, colors, plotting, moviepars);

        % Plot 3: Heatmap
        plot_heatmap(all_adjratios, avg_all_adjratios, ratiotype, savingname, worm_names, pdir,  general, analysis_pars, plotting, moviepars);

        % Save data to spreadsheets
        save_groupdata_to_spreadsheets(all_adjratios, avg_all_adjratios, ratiotype, savingname, worm_names,SEM,pdir, all_secs, general);
        
    
        fprintf('Plots complete for group: %s\n', genotype, cond, ratiotype);

    

    end


end



