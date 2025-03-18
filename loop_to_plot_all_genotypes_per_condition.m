function loop_to_plot_all_genotypes_per_condition(all_secs, avgratiodata, semdata, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars)
    % plot_all_genotypes_per_condition
    %
    % Plots all available genotypes for each condition on the same plot.
    %
    % Parameters:
    %   avgratiodata  - Struct containing average ratio data (avgratiodata.genotype.condition).
    %   semdata       - Struct containing SEM data (semdata.genotype.condition).
    %   ratiotype     - Type of ratio ('badjratios' or 'normratios').
    %   pdir          - Path to save plots.
    %   general       - Struct with genotype information and strain details.
    %   analysis_pars - Struct with analysis parameters.
    %   colors        - Struct with color information for each condition.
    %   plotting      - Struct with plotting parameters (limits, labels, etc.).
    %   moviepars     - Struct with movie parameters (timeframes, labels, etc.).
    %
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
        plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars);
    end
end
