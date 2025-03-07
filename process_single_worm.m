% this function accepts the filename for a single worm and processes the
% data in it: 
% - smooth, calculate adjratio, etc
% - plot
% - could add optional argument for whter to call bleach-correction

%data =
%process_single_worm(files_to_analyse(i),group_name,pdir,colors,plotting,moviepars);
function [this_worm_raw, short_fname, badjratios, normratios] = process_single_worm(fname, group_name, pdir, colors, plotting, moviepars)

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
    this_worm_raw = [raw_ratios raw_green raw_red];

    %smooth ratio to remove spikes generated as result of small
    %misalignment between led lighting and camera shutter
    ratios = smoothdata(raw_ratios,1,'movmedian',5); %smooth ratio with moving window of 5 frames median


    %calculate baseline-adjusted ratio 
    %Baseline-adjusted ratio is (R - R0 / R0)
    %where 
    % R = green/red ratio at each timepoint
    % R0 = average ratio during baseline period (bstart - bend)

    
    badjratios = calc_baseline_adj_ratio(ratios, moviepars.bstart, moviepars.bend);


    %calculate min/max normalised ratio
    %Calculate fmax/min normalised ratio (f-Fmin/Fmax)
    %Fmin = avg of lowest 5% of values in the trace
    %Fmax = avg of highest 5% of values in the trace

    normratios = calc_normalised_ratio(ratios, moviepars.bstart, moviepars.mend);


    %Plot baseline-adj ratio - ensure Y label matches ratio plotted
    % badjratios should be "R-R0/R0"
    % normratios should be "F-Fmin/Fmax"
    plot_single_worm(secs, badjratios, "badjratios", this_worm_dirs, colors, plotting, moviepars);

    plot_single_worm(secs, normratios, "normratios", this_worm_dirs, colors, plotting, moviepars);


     

    




    fprintf('Processed worm %s\n', this_worm_dirs.short_fname);

end


