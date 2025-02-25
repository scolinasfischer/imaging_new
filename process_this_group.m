%process_this_group(all_xlsx_dirs{r, c}, analysis_output_dir, codes(r, c), general, colors, plotting, moviepars);
function process_this_group(xlsx_dir, analysis_output_dir, cond, general, colors, plotting, moviepars)
% Get file list    
    files_to_analyse = get_xlsx_filepaths(xlsx_dir);
    n = length(files_to_analyse);
    group_name = strcat(general.strain, cond, general.pars);
    
    % Check for output directory
    outputdir = fullfile(analysis_output_dir, cond);
    if ~exist(outputdir, 'dir') %NB on server dont have write permissions so need to make sure directory already created
        mkdir(outputdir);
    end
    
    % Preallocate matrix for all worms
    all_badjratios = NaN(moviepars.max_movie_length, n);
    all_normratios = NaN(moviepars.max_movie_length, n);
    raw_ratios     = NaN(moviepars.max_movie_length, n);
    raw_greens     = NaN(moviepars.max_movie_length, n);
    raw_reds       = NaN(moviepars.max_movie_length, n);

    %Create cell array of strings to hold column names to use for output xlsx of all_adjratios
    worm_names = cell(1, n);

    
    % Process each worm
    for i = 1:n
        
        [this_worm_raw, this_worm, badjratios, normratios] = process_single_worm(files_to_analyse(i),group_name,outputdir,colors,plotting,moviepars);
        if isempty(badjratios)
            worm_names{i} = ""; % Give worm empty string name to keep indices aligned
            continue; % Skip if failed to load
        end
        

        %Add the data from this worm to all-worm matrix (within group)
        all_badjratios(:,i) = badjratios;
        all_normratios(:,i) = normratios;

        worm_names{i}       = this_worm;

        raw_ratios(:,i)     = this_worm_raw(:,1);
        raw_greens(:,i)     = this_worm_raw(:,2);
        raw_reds(:,i)       = this_worm_raw(:,3);
          

    end


    %Within group plots:
    % Average + shaded SEM
    % All traces + average in bold
    % heatmap

    plot_within_group()




    fprintf('Processed group %s\n', cond);
end
