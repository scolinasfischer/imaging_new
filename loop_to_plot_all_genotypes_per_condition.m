%{
Plots avg ± SEM traces for all genotypes (e.g. wt, mutants) under the same condition
on one figure. Each condition gets its own plot, useful for highlighting genotype differences.
Mutant is plotted slightly darker than the corresponding wild-type colour. 

Inputs:
- all_secs (vector): Time in seconds.
- avgratiodata (struct): avg traces for each genotype/condition.
    Format: avgratiodata.(genotype).(condition) = [vector]
- semdata (struct): SEM traces in the same structure.
- ratiotype (string): 'badjratios' or 'normratios'.
- analysis_output_dir (string): Directory where plots are saved.
- general (struct): Strain info and parameter descriptors.
- analysis_pars (struct): Plot export toggles.
- colors (struct): Color settings, used for each condition and background.
- plotting (struct): Y-axis and style settings.
- moviepars (struct): Plot axis/time parameters and shading regions.

Output:
- One plot per condition showing all genotypes. PNG + optional EPS.
%}


function loop_to_plot_all_genotypes_per_condition(all_secs, avgratiodata, semdata, ratiotype, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)

    % Outputs:
    %   - Saves plots to the specified directory.

    % === Step 1: Create internal color struct ===
    colorstruct.mock = colors.mockgray;
    colorstruct.avsv = colors.avsvgreen;
    colorstruct.sexc = colors.sexcondpink;

    % === Step 2: Get list of genotypes and conditions ===
    genotypes = fieldnames(avgratiodata);
    conditions = fieldnames(avgratiodata.(genotypes{1}));

    % === Step 3: Loop over conditions ===
    for c = 1:length(conditions)
        cond = conditions{c};

        % === Step 4: Create struct for dataset ===
        dataset = struct();
        dataset.avg = cell(1, length(genotypes));
        dataset.sem = cell(1, length(genotypes));
        dataset.colors = cell(1, length(genotypes));
        dataset.labels = cell(1, length(genotypes));
        dataset.plot_title = strcat("All genotypes for ", cond);

        % === Step 5: Fill dataset struct ===
        for g = 1:length(genotypes)
            genotype = genotypes{g};
            dataset.avg{g} = avgratiodata.(genotype).(cond);   % Average data
            dataset.sem{g} = semdata.(genotype).(cond);         % SEM data

            % Use internal color struct + darkening for mutants
            if strcmp(genotype, 'wt')
                dataset.colors{g} = colorstruct.(cond);  % WT color
            else
                dataset.colors{g} = colorstruct.(cond) * 0.8; % Darken for mutant
            end

            dataset.labels{g} = genotype;  % Label for current genotype
        end

        % === Step 6: Call the general plotting function ===
        pdir = fullfile(analysis_output_dir, genotype, cond);
        plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars);
    end
end
