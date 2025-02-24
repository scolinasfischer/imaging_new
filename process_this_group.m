function process_this_group(xlsx_dir, analysis_output_dir, cond, strain, pars, frame_rate, max_movie_length)
% Get file list    
    files_to_analyse = get_xlsx_filepaths(xlsx_dir);
    n = length(files_to_analyse);
    group_name = strcat(strain, cond, pars);
    
    % Check for output directory
    outputdir = fullfile(analysis_output_dir, cond);
    if ~exist(outputdir, 'dir') %NB on server dont have write permissions so need to make sure directory already created
        mkdir(outputdir);
    end
    
    % Preallocate matrix for all worms
    all_adjratios = NaN(max_movie_length, n);

    %Create cell array of strings to hold column names to use for output xlsx of all_adjratios
    col_names = cell(1, n);

    
    % Process each worm
    for i = 1:n
        data = process_single_worm(files_to_analyse(i));
        if isempty(data)
            continue; % Skip if failed to load
        end
        
        
        %add this worm and name to all_adjratios and col_names

        

    end


    %plotting


    fprintf('Processed group %s\n', cond);
end
