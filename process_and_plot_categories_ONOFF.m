function process_and_plot_categories_ONOFF(genotypes, conditions, categorised_nratio, categorised_bratio, catg_wormnames, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
    % This function processes average ratios and SEM for different genotypes, conditions, and categories
    % and then calls a plotting function to visualize the results.
    %
    % Parameters:
    %   genotypes      - List of genotypes to process
    %   conditions     - List of conditions (e.g., 'mock', 'avsv', 'sexc')
    %   categorised_nratio - Structure with categorized normalized ratios
    %   categorised_bratio - Structure with categorized baseline-adjusted ratios
    %   catg_wormnames     - Structure with worm names separated by category 
    %   analysis_output_dir - Directory for saving output plots
    %   general        - General information for plotting (e.g., strain info)
    %   analysis_pars  - Analysis parameters for plotting
    %   colors         - Struct containing colors for different conditions
    %   plotting       - Struct containing plotting settings (limits, labels, etc.)
    %   moviepars      - Movie parameters (e.g., frame rate)

    % Internal color struct and categories/ratiotypes
    colorstruct.mock = colors.mockgray;
    colorstruct.avsv = colors.avsvgreen;
    colorstruct.sexc = colors.sexcondpink;

    % Define variables that will be looped over
    categories = {'offHIGH', 'onLOW', 'bLOW'};
    ratiotypes = {'badjratios', 'normratios'};  

    % Structures to store the average and SEM values for normratios and bratio
    nratio_avg = struct();
    nratio_sem = struct();
    bratio_avg = struct();
    bratio_sem = struct();

    % Loop through genotypes
    for g = 1:length(genotypes)
        genotype = genotypes{g};
        
        % Loop through ratiotypes (normratios or badjratios)
        for r = 1:length(ratiotypes)
            ratiotype = ratiotypes{r};
            fprintf('Now ready to process ratiotype %s\n', ratiotype);
            % Loop through categories (offHIGH, onLOW, bLOW)
            for cat = 1:length(categories)
                category = categories{cat};
                fprintf('Now ready to process category %s\n', category);
                
                % Create dataset for this category and genotype
                dataset = struct();
                dataset.avg = cell(1, length(conditions));
                dataset.sem = cell(1, length(conditions));
                dataset.colors = cell(1, length(conditions));
                dataset.labels = cell(1, length(conditions));
                dataset.plot_title = strcat(genotype, ' - ', category);
                
                % Loop through conditions and compute statistics for each category
                for c = 1:length(conditions)
                    cond = conditions{c};                    
                    these_worms = catg_wormnames.(genotype).(cond).(category);

                    % Extract the appropriate data based on ratiotype using switch/case
                    switch ratiotype
                        case 'normratios'
                            these_ratios = categorised_nratio.(genotype).(cond).(category);
                        case 'badjratios'
                            these_ratios = categorised_bratio.(genotype).(cond).(category);
                        otherwise
                            error('Unexpected ratiotype: %s', ratiotype);
                    end
                    
                    % Compute avg and SEM for current ratiotype
                    fprintf('  -> Computing statistics for %s, %s, %s\n', genotype, cond, category);
                    [avg_ratios, SEM, all_secs] = compute_plot_statistics(these_ratios, general.frame_rate);
                    
                    % Save the results in appropriate structures
                    switch ratiotype
                        case 'normratios'
                            nratio_avg.(genotype).(cond).(category) = avg_ratios;
                            nratio_sem.(genotype).(cond).(category) = SEM;
                        case 'badjratios'
                            bratio_avg.(genotype).(cond).(category) = avg_ratios;
                            bratio_sem.(genotype).(cond).(category) = SEM;
                    end
                    
                    % Fill dataset for plotting
                    dataset.avg{c} = avg_ratios;
                    dataset.sem{c} = SEM;
                    dataset.colors{c} = colorstruct.(cond);
                    dataset.labels{c} = cond;  
                    


                    % Output directory for within condition saving data
                    pdir = fullfile(analysis_output_dir, genotype, cond);
                    if ~exist(pdir, 'dir')
                        mkdir(pdir);
                    end


                    %Call the saving function for the current group to save
                    %spreadsheet with all data and spreadsheet with avg, time, SEM
                    save_groupdata_to_spreadsheets(these_ratios, avg_ratios, ratiotype, category, these_worms,SEM,pdir, all_secs, general)
                    fprintf('  -> Data saved for %s, %s, %s\n', genotype, cond, category);

                end
                

                
                % Call the general plotting function for the current group
                fprintf('   Plot  %s, %s, %s\n', genotype, cond, category);
                plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars);
                

            end

        end
    end
end
