function [bc_ratio] = bleach_correct(this_worm_raw, frames, secs, genotype, cond,this_worm_dirs, analysis_output_dir, analysis_pars, colors, plotting, moviepars)
%{
This function performs bleach correction on the green and red channel data for a single worm. It fits an exponential curve to the green and red channels separately, and then uses that fit to bleach-correct the data. The function also saves the results (including bleach-corrected data and summary) and plots the bleach-corrected ratio vs the raw ratio.

Inputs:
- this_worm_raw: (matrix) Raw data of the worm, with columns representing raw_ratios, green_channel, and red_channel.
- frames: (vector) Frame numbers corresponding to the worm data.
- secs: (vector) Time in seconds corresponding to each frame.
- genotype: (string) Genotype of the worm.
- cond: (string) Experimental condition (mock/avsv/sexc).
- this_worm_dirs: (struct) Directory information for the worm, including short filename and parent directory.
- analysis_output_dir: (string) Parent directory for analysis.
- analysis_pars: (struct) Analysis parameters.
- colors: (struct) Colors used for plotting.
- plotting: (struct) Plotting parameters. 
- moviepars: (struct) Movie parameters, including start and end frames for bleach correction.

Outputs:
- bc_ratio: (vector) Bleach-corrected ratio calculated as green_channel ./ red_channel.
%}

%save and organise data inputs
raw_ratio = this_worm_raw(:,1);
raw_greenred = [this_worm_raw(:,2),this_worm_raw(:,3)];
    
smooth_rawratio = smoothdata(raw_ratio,1,'movmedian',5); %smooth ratio with moving window of 5 frames median

frames_to_fit = frames(moviepars.bstart:moviepars.mend);
secs_to_fit   = secs(moviepars.bstart:moviepars.mend);


%Set pdir to be within the bleach_correct folder 
pdirbc = fullfile(analysis_output_dir, genotype, bleach_correct);

    for ch = 1:2
    
        %% select data
        %the variable "channel" indicates whether currently analysing
        %red or green channel
        if ch == 1
            channel = "GREEN";
        elseif ch == 2
            channel = "RED";
    
        end

        % select raw data to fit to be either red or green (column 1 or 2), and only
        % required frames (bstart to mend)
        raw_data_to_fit = raw_greenred(moviepars.bstart:moviepars.mend,ch);

        %smooth raw data of this channel
        raw_data_to_fit = smoothdata(raw_data_to_fit,1,'movmedian',5);
    
        %save vector with indices of all nans in raw data
        all_nans = find(isnan(raw_data_to_fit));


        
        %% Interpolate all nans to be able to fit a curve (nancorrected data)
        nc_data = fillmissing(raw_data_to_fit, 'linear', 'EndValues', 'nearest');
    


        %% Fit and calculate exponential
        %fit exponential curve to nan-corrected data
        [params,gof] = fit(frames_to_fit,nc_data,'exp1'); 
        %time on x, raw ratios with interpolated nans is y
        a = params.a;
        k = params.b; %will be negative bc its exponential decay
        R2 = gof.rsquare; %gof returns structure with 5 parameter relating to goodness-of-fit

            
            
        %calculate fitted exponential
        expY=a*exp(k*frames_to_fit); 


        %% Bleach correct: divide raw trace of this channel by fitted exponential

        %calculate bleach corrected data (bc_data) by dividing by fitted exponential
        bc_data = nc_data ./ expY; 
        bc_data(all_nans) = NaN;


        %% Save results of each channel and summary using helper function
        [channel_data, summary] = save_channel_data(channel, raw_data_to_fit, nc_data, expY, bc_data, all_nans, a, k, R2);

        % Store the results into corresponding channel variables
        if ch == 1
            green_data = channel_data;
            output_summary_green = summary;
        elseif ch == 2
            red_data = channel_data;
            output_summary_red = summary;
        end


        %% Plots per channel 

        % Plot smoothed and nan-corrected data and fitted exponential 
        figure();
        plot(frames_to_fit,nc_data); %plot time vs nan-corrected data
        hold on
        plot(frames_to_fit,expY); %plot time vs exponential
        title(strcat(this_worm_dirs.short_fname,' - ', channel,' - Raw nan-corrected & Fitted exp vs Time.', 'R2=', string(R2)));
        xlim([moviepars.bstart moviepars.mend]);
        hold off
        
        rawexpYplotname = strcat(this_worm_dirs.short_fname, 'raw_expY', ' - ', channel);
        rawexpYplotname = fullfile(pdirbc,"plots", rawexpYplotname);
        saveas(gcf,rawexpYplotname,'png');
        close
                


        % Bleach-correction: Plot bleach-corrected data 
        figure();
        hold on
        title(strcat(this_worm_dirs.short_fname, 'bc - ', channel, '  vs Time'));
        xlim([moviepars.bstart moviepars.mend]);
        plot(frames_to_fit,bc_data); %plot time vs bleach corrected data in blue

        bleach_correctedplotname = strcat(short_fname, 'bc',' - ', channel);
        bleach_correctedplotname = fullfile(pdirbc,"plots",bleach_correctedplotname);
        saveas(gcf,bleach_correctedplotname,'png');
        close


        

    end


    %% Calculate bleach-corrected ratio from green and red data
    bc_ratio = green_data.bc_GREEN ./ red_data.bc_RED;


    %% Plot Bleach-corrected ratio vs raw ratio for single worm, save plot

    figure()
    hold on
    title(strcat(this_worm_dirs.short_fname, ' - Bleach-corrected and raw ratio vs Time'))
    xlim([fstart mend])
    plot(frames_to_fit,bc_ratio, 'Color' ,[255 102 0]/255, 'DisplayName', 'Bleach-corrected Ratio') 
    plot(frames_to_fit,smooth_rawratio,'b', 'DisplayName', 'Raw Ratio') 
    legend('show') 
    both_ratiosname = strcat(short_fname,'BC_vs_RAW ratio');
    both_ratiosname = fullfile(pdirbc,"sumplots",both_ratiosname);
    saveas(gcf,both_ratiosname,'png');
    close
    


    %% Bleach-correction: Save output of bleach-correction data & bleach-correction summary to excel
    % Prepare the data to save into tables
    data_vars = [ "frames_to_fit", "secs_to_fit", "green_data_to_fit", "red_data_to_fit", ...
                  "nan_removed_green", "nan_removed_red", "fitted_exp_green", ...
                  "fitted_exp_red", "bc_green", "bc_red", "bc_ratio"];
    output_data = table(frames_to_fit, secs_to_fit, green_data.raw_GREEN_to_fit, red_data.raw_RED_to_fit, ...
                        green_data.nc_GREEN, red_data.nc_RED, green_data.expY_GREEN, red_data.expY_RED, ...
                        green_data.bc_GREEN, red_data.bc_RED, bc_ratio, 'VariableNames', data_vars);

    % Save tables to Excel
    output_fname = strcat(this_worm_dirs.short_fname, '_bc_output.xls');
    output_fname = fullfile(pdirbc, "xls", output_fname);
    
    writetable(output_data, output_fname, 'Sheet', 'data');
    writetable(output_summary_green, output_fname, 'Sheet', 'summary_green');
    writetable(output_summary_red, output_fname, 'Sheet', 'summary_red');

    
    
    


end



    
    

function [channel_data, summary] = save_channel_data(channel, raw_data_to_fit, nc_data, expY, bc_data, all_nans, a, k, R2)
% Create a structure for the channel-specific data
channel_data = struct();

% Store the variables in the structure with dynamic field names
channel_data.(['raw_', channel, '_to_fit']) = raw_data_to_fit;
channel_data.(['nc_', channel]) = nc_data;
channel_data.(['expY_', channel]) = expY;
channel_data.(['bc_', channel]) = bc_data;

% Create a summary table for this channel
summary = table(length(all_nans), a, k, R2, 'VariableNames', ["total_NaNs", "a", "k", "R2"]);
end
              
            