%process_this_group(all_xlsx_dirs{r, c}, analysis_output_dir, codes(r, c), general, colors, plotting, moviepars);
function [ratios, notbc_ratios, all_secs, worm_names] = process_this_group(xlsx_dir, analysis_output_dir, genotype, cond, general, analysis_pars, colors, plotting, moviepars)
% Get file list    
    files_to_analyse = get_xlsx_filepaths(xlsx_dir);
    n = length(files_to_analyse);
    group_name = strcat(general.strain, genotype, cond, general.pars);
    
    % Check for output directory
    output_dir = fullfile(analysis_output_dir, genotype, cond);
    if ~exist(output_dir, 'dir') %NB on server dont have write permissions so need to make sure directory already created
        mkdir(output_dir);
    end
    
    % Preallocate matrix for all worms
    all_badjratios = NaN(moviepars.max_movie_length, n);
    all_normratios = NaN(moviepars.max_movie_length, n);

    raw_ratios     = NaN(moviepars.max_movie_length, n);
    raw_greens     = NaN(moviepars.max_movie_length, n);
    raw_reds       = NaN(moviepars.max_movie_length, n);


    notbc_all_badjratios = NaN(moviepars.max_movie_length, n);
    notbc_all_normratios = NaN(moviepars.max_movie_length, n);

    %Create cell array of strings to hold column names to use for output xlsx of all_adjratios
    worm_names = cell(1, n);


    % Process each worm
    for i = 1:n
        
        [this_worm_raw, this_worm, badjratios, normratios, notbc_badjratios, notbc_normratios] = process_single_worm(files_to_analyse(i),group_name,genotype, cond,output_dir,analysis_output_dir,analysis_pars, colors,plotting,moviepars);
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
       
        if analysis_pars.bleachcorrect 
            notbc_all_badjratios(1:num_rows, i) = notbc_badjratios; 
            notbc_all_normratios(1:num_rows, i) = notbc_normratios; 
        end
        
         
       

    end




    %Within group plots:
    % Average + shaded SEM
    % All traces + average in bold
    % heatmap

%call function once for badjratios and once for normratios
    [badj_avg, SEMbadj,all_secs] = analyse_and_plot_group_ratios(all_badjratios, "badjratios", worm_names, general, analysis_pars, colors, plotting, moviepars, output_dir, genotype, cond, "");                                                   
    [norm_avg, SEMnorm,all_secs] = analyse_and_plot_group_ratios(all_normratios, "normratios", worm_names, general, analysis_pars, colors, plotting, moviepars, output_dir, genotype, cond, "");

    if analysis_pars.bleachcorrect 
        [notbc_badj_avg, notbc_SEMbadj, all_secs] = analyse_and_plot_group_ratios(notbc_all_badjratios, "badjratios", worm_names, general, analysis_pars, colors, plotting, moviepars, output_dir, genotype, cond, "not_bc");            
        [notbc_norm_avg, notbc_SEMnorm, all_secs] = analyse_and_plot_group_ratios(notbc_all_normratios, "normratios", worm_names, general, analysis_pars, colors, plotting, moviepars, output_dir, genotype, cond, "not_bc"); 
    end
 

    ratios.badj.all = all_badjratios;
    ratios.badj.avg = badj_avg;
    ratios.badj.SEM = SEMbadj;
    ratios.norm.all = all_normratios;    
    ratios.norm.avg = norm_avg;
    ratios.norm.SEM = SEMnorm;

    if analysis_pars.bleachcorrect 
        notbc_ratios.badj.all = notbc_all_badjratios;
        notbc_ratios.badj.avg = notbc_badj_avg;
        notbc_ratios.badj.SEM = notbc_SEMbadj;
        notbc_ratios.norm.all = notbc_all_normratios;       
        notbc_ratios.norm.avg = notbc_norm_avg;
        notbc_ratios.norm.SEM = notbc_SEMnorm;
    else 
        notbc_ratios = struct();

    end

    
    fprintf('Processed group %s\n', genotype, cond);
end
