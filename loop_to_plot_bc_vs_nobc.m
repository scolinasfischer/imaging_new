
function loop_to_plot_bc_vs_nobc(all_secs, bratio_avg_data, bSEM_data, notbc_bratio_avg_data, notbc_bSEM_data, ratiotype, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)

    %
    % Plots bleach-corrected vs non-bleach-corrected data for all genotypes and conditions on the same plot.
    %
    % Parameters:
    %   bratio_avg_data    - Struct containing average bleach-corrected data (bratio_avg_data.genotype.condition).
    %   bSEM_data          - Struct containing SEM bleach-corrected data (bSEM_data.genotype.condition).
    %   notbc_bratio_avg_data - Struct containing average non-bleach-corrected data (notbc_bratio_avg_data.genotype.condition).
    %   notbc_bSEM_data    - Struct containing SEM non-bleach-corrected data (notbc_bSEM_data.genotype.condition).
    %   ratiotype          - Type of ratio ('badjratios' or 'normratios').
    %   analysis_output_dir - Path to save plots.
    %   general            - Struct with genotype information and strain details.
    %   analysis_pars      - Struct with analysis parameters.
    %   colors             - Struct with color information for each condition.
    %   plotting           - Struct with plotting parameters (limits, labels, etc.).
    %   moviepars          - Struct with movie parameters (timeframes, labels, etc.).
    %
    % Outputs:
    %   - Saves plots to the specified directory.

    % === Step 1: Get list of genotypes ===
    genotypes = fieldnames(bratio_avg_data);

    % === Step 2: Loop over genotypes ===
    for g = 1:length(genotypes)
        genotype = genotypes{g};
        conditions = fieldnames(bratio_avg_data.(genotype));

        % === Step 3: Loop over conditions ===
        for c = 1:length(conditions)
            cond = conditions{c};

            % === Step 4: Create struct for dataset ===
            dataset = struct();
            dataset.avg = cell(1, 2);  % Two entries: one for BC and one for No BC
            dataset.sem = cell(1, 2);
            dataset.colors = cell(1, 2);
            dataset.labels = cell(1, 2);
            dataset.plot_title = strcat("BC_vs_NotBC for ", genotype, " - ", cond);

            % Fill dataset struct for bleach-corrected data
            dataset.avg{1} = bratio_avg_data.(genotype).(cond);  % Average bleach-corrected data
            dataset.sem{1} = bSEM_data.(genotype).(cond);        % SEM bleach-corrected data
            dataset.colors{1} = colors.purple;                   % Color for bleach-corrected
            dataset.labels{1} = "Bleach-corrected";              % Label for bleach-corrected

            % Fill dataset struct for non-bleach-corrected data
            dataset.avg{2} = notbc_bratio_avg_data.(genotype).(cond);  % Average non-bleach-corrected data
            dataset.sem{2} = notbc_bSEM_data.(genotype).(cond);        % SEM non-bleach-corrected data
            dataset.colors{2} = colors.darkgray;                       % Color for non-bleach-corrected
            dataset.labels{2} = "Not bleach-corrected";                % Label for non-bleach-corrected

            % === Step 5: Call the general plotting function ===
            pdir = fullfile(analysis_output_dir, genotype, cond);
            plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars);
        end
    end
end





