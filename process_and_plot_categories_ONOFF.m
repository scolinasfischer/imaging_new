function process_and_plot_categories_ONOFF(genotypes, conditions, categorised_nratio, categorised_bratio, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)
    % This function processes average ratios and SEM for different genotypes, conditions, and categories
    % and then calls a plotting function to visualize the results.
    %
    % Parameters:
    %   genotypes      - List of genotypes to process
    %   conditions     - List of conditions (e.g., 'mock', 'avsv', 'sexc')
    %   categorised_nratio - Structure with categorized normalized ratios
    %   categorised_bratio - Structure with categorized baseline-adjusted ratios
    %   analysis_output_dir - Directory for saving output plots
    %   general        - General information for plotting (e.g., strain info)
    %   analysis_pars  - Analysis parameters for plotting
    %   colors         - Struct containing colors for different conditions
    %   plotting       - Struct containing plotting settings (limits, labels, etc.)
    %   moviepars      - Movie parameters (e.g., frame rate)

    %% Internal color struct and categories/ratiotypes
    colorstruct.mock = colors.mockgray;
    colorstruct.avsv = colors.avsvgreen;
    colorstruct.sexc = colors.sexcondpink;

    categories = {'offHIGH', 'onLOW', 'bLOW'};
    ratiotypes = {'badjratios', 'normratios'};  % Define ratiotypes to loop over

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
            
            % Loop through categories (offHIGH, onLOW, bLOW)
            for cat = 1:length(categories)
                category = categories{cat};
                
                % Create dataset for this category and genotype
                dataset = struct();
                dataset.avg = cell(1, length(conditions));
                dataset.sem = cell(1, length(conditions));
                dataset.colors = cell(1, length(conditions));
                dataset.labels = conditions;
                dataset.plot_title = strcat(genotype, ' - ', category, ' neurons (', ratiotype, ')');
                
                % Loop through conditions and compute statistics for each category
                for c = 1:length(conditions)
                    cond = conditions{c};
                    
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
                    [avg_ratios, SEM_ratios, all_secs] = compute_plot_statistics(these_ratios, moviepars.frame_rate);
                    
                    % Save the results in appropriate structures
                    switch ratiotype
                        case 'normratios'
                            nratio_avg.(genotype).(cond).(category) = avg_ratios;
                            nratio_sem.(genotype).(cond).(category) = SEM_ratios;
                        case 'badjratios'
                            bratio_avg.(genotype).(cond).(category) = avg_ratios;
                            bratio_sem.(genotype).(cond).(category) = SEM_ratios;
                    end
                    
                    % Fill dataset for plotting
                    dataset.avg{c} = avg_ratios;
                    dataset.sem{c} = SEM_ratios;
                    dataset.colors{c} = colorstruct.(cond);
                end
                
                % Output directory for plots
                plotdir = fullfile(analysis_output_dir, genotype, category, ratiotype);
                if ~exist(plotdir, 'dir')
                    mkdir(plotdir);
                end
                
                % Call the general plotting function for the current ratiotype
                plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, plotdir, general, analysis_pars, colors, plotting, moviepars);
            end
        end
    end
end
