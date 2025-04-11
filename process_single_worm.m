
function [this_worm_raw, short_fname, badjratios, normratios, notbc_badjratios, notbc_normratios] = process_single_worm(fname, group_name, genotype, cond,pdir,analysis_output_dir, analysis_pars, colors, plotting, moviepars)

%{
This function processes the data for a single worm experiment. It performs the following steps:
- Loads the worm data.
- Smooths the ratios to remove spikes caused by misalginment between LED and camera timings.
- Optionally applies bleach correction.
- Calculates baseline-adjusted(R0) and normalized (Fm) ratios.
- Optionally plots the calculated ratios.

Inputs:
- fname: (string) Full filename of the worm data to process.
- group_name: (string) Name of the group (strain+condition+genotype+parameters of analysis)
- genotype: (string) Genotype (wt/other)
- cond: (string) mock/avsv/sexc
- pdir: (string)  Directory where this worm data is stored  -usually inside
genotype + cond
- analysis_output_dir: (string) Directory where output from the analysis
should be stored (contains pdir) 
- analysis_pars: (struct) Parameters controlling which analysis steps to perform (e.g., bleach correction, plotting).
- colors: (struct) Colors used for plotting.
- plotting: (struct) Parameters for plotting.
- moviepars: (struct) Time points for baseline and analysis (e.g., bstart, bend).

Outputs:
- this_worm_raw: (matrix) Raw worm data for further analysis [raw_ratios, raw_green, raw_red].
- short_fname: (string) Short filename of the worm (no path or extension).
- badjratios: (R - R0) / R0
- normratios: (F - Fmin) / Fmax
- notbc_badjratios, notbc_normratios: same as above, before bleach correction (if applied)


NB if bleach correction was performed, the next two are bleach-corrected,
if not, they are not:
- badjratios: (vector) Baseline-adjusted ratios of the worm - may or may
not be bleach-corrected, depending on parameters. 
- normratios: (vector) Normalized ratios of the worm - may or may
not be bleach-corrected, depending on parameters.

If bleach-correction was performed, these outputs contain the non-bleach
corrected adjusted ratios:
- notbc_badjratios: Baseline-adjusted ratios (before bleach correction)
- notbc_normratios: Normalized ratios (before bleach correction)


%}
    %get a short filename for this file (filename only, no path or
    %extension)
    [~, short_fname, ~] = fileparts(fname);

    %create struct to hold directory and filenames for this worm / group
    this_worm_dirs.short_fname = short_fname;
    this_worm_dirs.group_name = group_name;
    this_worm_dirs.pdir = pdir;
    this_worm_dirs.fullpath = fullfile(pdir, strcat(group_name, short_fname));


    %load data for this worm
    [raw_ratios, raw_green, raw_red, frames, secs] = load_single_worm(fname);
    this_worm_raw = [raw_ratios(1:moviepars.mend) raw_green(1:moviepars.mend) raw_red(1:moviepars.mend)];

    %smooth ratio to remove spikes generated as result of small
    %misalignment between led lighting and camera shutter
    ratios = smoothdata(raw_ratios,1,'movmedian',5); %smooth ratio with moving window of 5 frames median
    ratios = ratios(1:moviepars.mend); %keep only ratios until movie end point
    secs = secs(1:moviepars.mend);
    frames = frames(1:moviepars.mend);

    if analysis_pars.bleachcorrect 
        %run bleach correction and assign data accordingly
        [bc_ratios] = bleach_correct(this_worm_raw, frames, secs,genotype, cond,this_worm_dirs, analysis_output_dir,analysis_pars, colors, plotting, moviepars);

        smoothraw_ratios = ratios;
        ratios = bc_ratios;
        
        notbc_badjratios = calc_baseline_adj_ratio(smoothraw_ratios, moviepars);
        notbc_normratios = calc_normalised_ratio(smoothraw_ratios, moviepars);


    end


    %calculate baseline-adjusted ratio 
    %Baseline-adjusted ratio is (R - R0 / R0)
    %where 
    % R = green/red ratio at each timepoint
    % R0 = average ratio during baseline period (bstart - bend)

    
    badjratios = calc_baseline_adj_ratio(ratios, moviepars);


    %calculate min/max normalised ratio
    %Calculate fmax/min normalised ratio (f-Fmin/Fmax)
    %Fmin = avg of lowest 5% of values in the trace
    %Fmax = avg of highest 5% of values in the trace

    normratios = calc_normalised_ratio(ratios, moviepars);


    %Plot baseline-adj ratio - ensure Y label matches ratio plotted
    % badjratios should be "R-R0/R0"
    % normratios should be "F-Fmin/Fmax"
    
    if analysis_pars.plot_single_worms
        
        if analysis_pars.calculateR0 
            plot_single_worm(secs, badjratios, "badjratios", this_worm_dirs, analysis_pars, colors, plotting, moviepars);
        end
    
        if analysis_pars.calculateFm 
            plot_single_worm(secs, normratios, "normratios", this_worm_dirs, analysis_pars, colors, plotting, moviepars);
        end


    end

    

    fprintf('Processed worm %s\n', this_worm_dirs.short_fname);

end


