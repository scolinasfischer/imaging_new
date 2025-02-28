%process_this_group(all_xlsx_dirs{r, c}, analysis_output_dir, codes(r, c), general, colors, plotting, moviepars);
function [all_badjratios, check_frame_variation] = process_this_group(xlsx_dir, analysis_output_dir, cond, general, colors, plotting, moviepars)
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

    check_frame_variation = [];
    % Process each worm
    for i = 1:n
        
        [this_worm_raw, this_worm, badjratios, normratios] = process_single_worm(files_to_analyse(i),group_name,outputdir,colors,plotting,moviepars);
        if isempty(badjratios) || isempty(normratios)
            worm_names{i} = ""; % Give worm empty string name to keep indices aligned
            continue; % Skip if failed to load
        end
        

        %check size of badjratios
        num_rows = size(badjratios, 1);
    
        %Add the data from this worm to all-worm matrices (within group)
        % Ensure badjratios/normratios etc fit into the NaN matrixes
        all_badjratios(1:num_rows, i) = badjratios; % Assign badjratios to the first num_rows in the column
        all_normratios(1:num_rows, i) = normratios; 

        raw_ratios(1:num_rows,i)      = this_worm_raw(:,1);
        raw_greens(1:num_rows,i)      = this_worm_raw(:,2);
        raw_reds(1:num_rows,i)        = this_worm_raw(:,3);
       
        worm_names{i}                 = this_worm;
       
         
        % Append the num_rows value to the check_frame_variation array
        check_frame_variation(end + 1) = num_rows; % Append the value

    end


%     %Remove rows that are fully NaN 
%     % (probably frames between 2185-2200 )
%     all_badjratios = all_badjratios(~all(isnan(all_badjratios), 2), :);
%     all_normratios = all_normratios(~all(isnan(all_normratios), 2), :);



    %Within group plots:
    % Average + shaded SEM
    % All traces + average in bold
    % heatmap

%     plot_within_group()




    fprintf('Processed group %s\n', cond);
end
