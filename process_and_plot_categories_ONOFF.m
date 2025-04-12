%{
For each ON/OFF category and ratio type, this function:
- Computes average + SEM traces per condition
- Plots avg + SEM traces
- Saves traces and stats to Excel
It also computes and plots proportion of neurons active over time(Fm)

Inputs:
Inputs:
- genotypes (cell array of strings): List of genotype names.
- conditions (cell array of strings): List of experimental conditions.
- categorised_nratio (struct): Normalised ratio traces per category:
    Format: categorised_nratio.(genotype).(condition).(category) = matrix of [time (rows) × worms (columns)]
- categorised_bratio (struct): Same structure, but for baseline-adjusted ratios.
- catg_wormnames (struct): Names of worms in each category:
    Format: catg_wormnames.(genotype).(condition).(category) = {cell array of names}
- analysis_output_dir(string): Directory for saving output plots
- general, analysis_pars, colors, plotting, moviepars: structs with general
and plotting info
    %   general        - General information for plotting (e.g., strain info)
    %   analysis_pars  - Analysis parameters for plotting
    %   colors         - Struct containing colors for different conditions
    %   plotting       - Struct containing plotting settings (limits, labels, etc.)
    %   moviepars      - Movie parameters (e.g., frame rate)

Outputs:
- nratio_avg, nratio_SEM, bratio_avg, bratio_SEM: Structs with format:
    xxx.genotype.condition.category = [vector]

- Plots and Excel spreadsheets saved:
    - Per-category Excel spreadsheets of data
    - PNG and (optionally) EPS plots
    - Excel file of proportion ON over time (normratios only)
%}


function [nratio_avg, nratio_SEM, bratio_avg, bratio_SEM] = process_and_plot_categories_ONOFF(genotypes, conditions, categorised_nratio, categorised_bratio, catg_wormnames, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)

    % Internal color struct and categories/ratiotypes
    colorstruct = struct("mock", colors.mockgray, ...
                         "avsv", colors.avsvgreen, ...
                         "sexc", colors.sexcondpink);

    % Define variables that will be looped over
    categories = ["offHIGH", "onLOW", "bLOW"];
    ratiotypes = ["badjratios", "normratios"];  

    % Structures to store the average and SEM values for normratios and bratio
    nratio_avg = struct();
    nratio_SEM = struct();
    bratio_avg = struct();
    bratio_SEM = struct();

    % Loop through genotypes
    for g = 1:numel(genotypes)
        genotype = genotypes{g};
        
        % Loop through ratiotypes (normratios or badjratios)
        for r = 1:numel(ratiotypes)
            ratiotype = ratiotypes{r};
            fprintf('Now ready to process ratiotype %s\n', ratiotype);

            % Loop through categories (offHIGH, onLOW, bLOW)
            for cat = 1:numel(categories)
                category = categories{cat};
                fprintf('Now ready to process category %s\n', category);
                
                % Create dataset for this category and genotype
                dataset = struct();
                dataset.avg = cell(1, numel(conditions));
                dataset.sem = cell(1, numel(conditions));
                dataset.colors = cell(1, numel(conditions));
                dataset.labels = cell(1, numel(conditions));
                dataset.plot_title = strcat(genotype, " - ", category);
                
                %create struct to hold prop ON (normratios only)
                proportions = struct();
                totalN = struct();

                % Loop through conditions and compute statistics for each category
                for c = 1:numel(conditions)
                    cond = conditions{c};                    
                    these_worms = catg_wormnames.(genotype).(cond).(category);

                    % Extract the appropriate data based on ratiotype using switch/case
                    switch ratiotype
                        case "normratios"
                            these_ratios = categorised_nratio.(genotype).(cond).(category);
                        case "badjratios"
                            these_ratios = categorised_bratio.(genotype).(cond).(category);
                        otherwise
                            error("Unexpected ratiotype: %s", ratiotype);
                    end
                    
                    % Compute avg and SEM for current ratiotype
                    fprintf("  -> Computing statistics for %s, %s, %s\n", genotype, cond, category);
                    [avg_ratios, SEM, all_secs] = compute_plot_statistics(these_ratios, general.frame_rate);


                    % Fill dataset for plotting
                    dataset.avg{c} = avg_ratios;
                    dataset.sem{c} = SEM;
                    dataset.colors{c} = colorstruct.(cond);
                    dataset.labels{c} = cond;  

                    
                    % Output directory for within condition saving data
                    pdir = fullfile(analysis_output_dir, genotype, cond);
                    
                    % Save the results in appropriate structures
                    switch ratiotype
                        case "normratios"
                            nratio_avg.(genotype).(cond).(category) = avg_ratios;
                            nratio_SEM.(genotype).(cond).(category) = SEM;
                            [propON] =  compute_proportions_over_time(ratiotype, these_ratios, these_worms, category,analysis_pars, moviepars);
                            
                           % Calculate proportion ON using normratios data and save
                            propON_filename = fullfile(analysis_output_dir, genotype, cond, strcat(general.pars,general.strain, category, cond, '_propON.xlsx'));
                            writematrix(propON, propON_filename, 'FileType', 'spreadsheet');   


                           % save propON data per cond to struct
                            proportions.(cond) = propON;
                            totalN.(cond) = numel(these_worms);

    
        
                         case "badjratios"
                            bratio_avg.(genotype).(cond).(category) = avg_ratios;
                            bratio_SEM.(genotype).(cond).(category) = SEM;
                    end
                    
                  
                   

                    %Call the saving function for the current group to save
                    %spreadsheet with all data and spreadsheet with avg, time, SEM
                    save_groupdata_to_spreadsheets(these_ratios, avg_ratios, ratiotype, category, these_worms,SEM,pdir, all_secs, general)
                    fprintf('  -> Data saved for %s, %s, %s\n', genotype, cond, category);


                end
                

                %% 3 cond plots


                % Call the avg+SEM plotting function for the current group
                fprintf('   Plot  %s, %s, %s\n', genotype, cond, category);
                pdir = fullfile(analysis_output_dir, genotype);
                plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars);
                
                


                % Plot  ncprop plots if this is normratios data
                switch ratiotype
                        case "normratios"

                            % duplicate dataset and replace avgSEM data with prop data for the proportions plot
                            dataset_2 = dataset;
                            dataset_2 = rmfield(dataset_2, "sem");
                            dataset_2 = rmfield(dataset_2, "avg");
                            dataset_2.plot_title = strcat(genotype, " - ", category, "propON");
        
                            %briefly fill prop and totalN fields using cond
                            %loop
                            for c = 1:numel(conditions)
                                cond = conditions{c}; 
    
                                dataset_2.prop{c} = proportions.(cond);
                                dataset_2.totalN{c} = totalN.(cond);
                                
                            end

                            
                            plot_prop_over_time(all_secs, dataset_2, category, pdir, general, colors, moviepars, analysis_pars)
                end

            end

        end
    end
end
