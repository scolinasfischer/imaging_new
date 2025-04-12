%{
Generates line plots (avg ± SEM) showing all conditions (mock, avsv, sexc)
for each genotype on the same figure.



Inputs:
- all_secs (vector): Time in seconds (x-axis).
- avgratiodata (struct): Nested structure of average ratio traces.
    Format: avgratiodata.(genotype).(condition) = [vector]
- semdata (struct): Same structure as avgratiodata, but contains SEM vectors.
- ratiotype (string): 'badjratios' or 'normratios'; used to configure labels/ylimits.
- analysis_output_dir (string): Base directory to save plots.
- general (struct): Includes strain name, genotype labels, and parameter descriptors.
- analysis_pars (struct): Toggles and export settings (e.g., export_eps).
- colors (struct): Color definitions (mockgray, avsvgreen, sexcondpink).
- plotting (struct): Plot limits and labels.
- moviepars (struct): Timepoints, label positions, and x-coordinates for odour shading.

Outputs:
- Saves PNG and (optionally) EPS plots comparing conditions per genotype.
%}



function loop_to_plot_all_conditions_per_genotype(all_secs, avgratiodata, semdata, ratiotype, analysis_output_dir, general, analysis_pars, colors, plotting, moviepars)


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
        pdir = fullfile(analysis_output_dir, genotype);
        plot_avg_with_sem_flexible(all_secs, dataset, ratiotype, pdir, general, analysis_pars, colors, plotting, moviepars);
    end
end
