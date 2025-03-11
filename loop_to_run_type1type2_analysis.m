function loop_to_run_type1type2_analysis(bratio_all_data, ratiotype, worm_names, T1T2analysispars, analysis_output_dir, colors, plotting, moviepars, general)

genotypes = fieldnames(bratio_all_data);
    for g = 1:length(genotypes)
        genotype = genotypes{g};
        conditions = fieldnames(bratio_all_data.(genotype));

        for c = 1:length(conditions)
            cond = conditions{c};

            % Extract data dynamically
            these_badjratios = bratio_all_data.(genotype).(cond);
            these_worm_names = worm_names.(genotype).(cond);

            % Create output directory
            pdir = fullfile(analysis_output_dir);
            if ~exist(pdir, 'dir')
                mkdir(pdir);
            end

            % Call the analysis function
            type1type2_analysis(these_badjratios, ratiotype, these_worm_names, T1T2analysispars, cond, pdir, colors, plotting, moviepars, general)

        
        end
    end
end
