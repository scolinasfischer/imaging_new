%{
Generates a comparison plot of bleach-corrected vs. non-corrected average traces
for each genotype and condition. Helpful for visually checking impact of bleach correction.

Inputs:
- all_secs (vector): Time in seconds.
- bratio_avg_data (struct): Average traces after bleach correction.
    Format: bratio_avg_data.(genotype).(condition)
- bSEM_data (struct): SEM for bleach-corrected data.
- notbc_bratio_avg_data (struct): Avg traces before bleach correction.
- notbc_bSEM_data (struct): SEM of non-corrected data.
- ratiotype (string): 'badjratios' or 'normratios'.
- analysis_output_dir (string): Where plots will be saved.
- general (struct): Strain and genotype info.
- analysis_pars (struct): Plot export settings (e.g., export_eps).
- colors (struct): Includes at .purple (for BC) and .darkgray (no BC).
- plotting (struct): Y-axis limits and labels.
- moviepars (struct): Time label and odour shading information.

Outputs:
- One plot per genotype × condition showing BC vs no-BC traces.
%}

function loop_to_plot_bc_vs_nobc(all_secs, bratio_avg_data, bSEM_data, notbc_bratio_avg_data, notbc_bSEM_data, ratiotype, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)

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





