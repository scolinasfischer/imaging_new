% this function accepts the filename for a single worm and processes the
% data in it: 
% - smooth, calculate adjratio, etc
% - plot
% - could add optional argument for whter to call bleach-correction

function data = process_single_worm(fname, bstart,bend,mend)

    %get a short filename for this file (filename only, no path or
    %extension)
    [~, short_fname, ~] = fileparts(fname);

    %load data for this worm
    [raw_ratios, raw_green, raw_red, frames, secs] = load_single_worm(fname);

    %smooth ratio to remove spikes generated as result of small
    %misalignment between led lighting and camera shutter
    ratios = smoothdata(raw_ratios,1,'movmedian',5); %smooth ratio with moving window of 5 frames median


    %calculate baseline-adjusted ratio 
    %Baseline-adjusted ratio is (R - R0 / R0)
    %where 
    % R = green/red ratio at each timepoint
    % R0 = average ratio during baseline period (bstart - bend)

    
    badjratio = calc_baseline_adj_ratio(ratios, bstart, bend);


    %calculate min/max normalised ratio
    %Calculate fmax/min normalised ratio (f-Fmin/Fmax)
    %Fmin = avg of lowest 5% of values in the trace
    %Fmax = avg of highest 5% of values in the trace

    normratio = calc_normalised_ratio(ratios, bstart, mend);



     




    fprintf('Processed worm %s\n', short_fname);

end


