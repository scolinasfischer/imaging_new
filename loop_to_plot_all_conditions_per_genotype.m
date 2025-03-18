function loop_to_plot_all_conditions_per_genotype(all_secs, avgratiodata, semdata, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars)
    % plot_all_conditions_per_genotype
    %
    % Plots all available conditions for each genotype on the same plot.
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

    %create internal color struct:
    colorstruct.mock = colors.mockgray;
    colorstruct.avsv = colors.avsvgreen;
    colorstruct.sexc = colors.sexcondpink;


    % === Step 1: Get list of genotypes ===
    genotypes = fieldnames(avgratiodata);
   

    % === Step 2: Loop over genotypes ===
    for g = 1:length(genotypes)
        genotype = genotypes{g};
        conditions = fieldnames(avgratiodata.(genotype));

        % === Step 3: Create struct for dataset ===
        dataset = struct();
        dataset.avg = cell(1, length(conditions));
        dataset.sem = cell(1, length(conditions));
        dataset.colors = cell(1, length(conditions));
        dataset.labels = cell(1, length(conditions));
        dataset.plot_title = strcat("3cond plot ",genotype);

        % === Step 4: Fill dataset struct ===
        for c = 1:length(conditions)
            cond = conditions{c};
            dataset.avg{c} = avgratiodata.(genotype).(cond);    % Average data for current condition
            dataset.sem{c} = semdata.(genotype).(cond);          % SEM data for current condition
            dataset.colors{c} = colorstruct.(cond);                   % Color for current condition
            dataset.labels{c} = cond;                            % Label for current condition
        end

        % === Step 5: Call the general plotting function ===
        plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, genotype, general, analysis_pars, colors, plotting, moviepars);
    end
end
