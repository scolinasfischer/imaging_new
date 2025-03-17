function [offHIGH, cols_offHIGH, onLOW, cols_onLOW,bLOW, cols_bLOW] = categorisebyONOFFstates(these_ratios, these_worm_names,pdir, general, colors, plotting, moviepars)


% This function receives normratio data (Fm) for one condition and genotype.
% It catgerorises neurons as to whether they fit into any of the below
% categories:
% -offHIGH: at the end of the odour off period (baseline) neuron is HIGH
% -onLOW  : at the end of the 1st odour on period, neuron is LOW
% -bLOW   : at the beggnining of the baseline perios, neuron is LOW
% LOW and HIGH activity states are defined as:
%    - Low: normalised (Fm) ratio at timepoint is 0.5 or below
%    - High:normalised (Fm) ratio at timepoint is 0.5 or above 


%inputs:
% these_ratios has to be normalised ratio for 


      % offHIGH
        %create matrices to hold this data
         cols_offHIGH = {};
        %for loop to cycle through and pull out column of data and name
        for s = 1:e
            if these_ratios(bend+1,s)>= 0.5 %check if value of F at baseline end frame over 0.5 (use agv of window of 1 second ie 10frames)
                offHIGHD = [offHIGHD all_adjratios_D(:,s)];  %if it is, add adjratioD (deltaF/Fmax to adequate  matrix)
                offHIGHog = [offHIGHog all_adjratios(:,s)];  %if it is, add adjratio (R-R0/R0 to adequate  matrix)
                cols_offHIGH = [cols_offHIGH col_names(s)]; %if it is, add neuron to OFF HIGH list
            end
        end
        clear s



end




      
        % offHIGH
        %create matrices to hold this data
        offHIGHD = [];
        offHIGHog = []; %original R-R0/R0 data but only that which deltaF/Fmax is HIGH at end of off
        cols_offHIGH = {};
        %for loop to cycle through and pull out column of data and name
        for s = 1:e
            if all_adjratios_D(bend+1,s)>= 0.5 %check if value of F at baseline end frame over 0.5 (use agv of window of 1 second ie 10frames)
                offHIGHD = [offHIGHD all_adjratios_D(:,s)];  %if it is, add adjratioD (deltaF/Fmax to adequate  matrix)
                offHIGHog = [offHIGHog all_adjratios(:,s)];  %if it is, add adjratio (R-R0/R0 to adequate  matrix)
                cols_offHIGH = [cols_offHIGH col_names(s)]; %if it is, add neuron to OFF HIGH list
            end
        end
        clear s
        
        
        
        % onLOW
        onLOWD = [];
        onLOWog = []; %original R-R0/R0 data but only that which deltaF/Fmax is LOW at end of on
        cols_onLOW = {};
        for s = 1:e
             if all_adjratios_D(ONend+1,s)<= 0.5 %check if value of F at odor on last frame is under 0.5 (use agv of window of 1 second ie 10frames)
                onLOWD = [onLOWD all_adjratios_D(:,s)]; %if it is, add adjratioD (deltaF/Fmax to adequate  matrix)
                onLOWog = [onLOWog all_adjratios(:,s)];  %if it is, add adjratio (R-R0/R0 to adequate  matrix)
                cols_onLOW = [cols_onLOW col_names(s)];%if it is, add neuron to ON LOW  list
            end
        end
        
        clear s
        
        %bLOW
        bLOWD = [];
        bLOWog = []; %original R-R0/R0 data but only that which deltaF/Fmax is LOW at end of on
        cols_bLOW = {};
        for s = 1:e
            if all_adjratios_D(bstart+1,s)<= 0.5 %check if value of F at odor on last frame is under 0.5 (use agv of window of 1 second ie 10frames)
                bLOWD = [bLOWD all_adjratios_D(:,s)]; %if it is, add adjratioD (deltaF/Fmax to adequate  matrix)
                bLOWog = [bLOWog all_adjratios(:,s)];  %if it is, add adjratio (R-R0/R0 to adequate  matrix)
                cols_bLOW = [cols_bLOW col_names(s)];%if it is, add neuron to ON LOW  list
            end
        end
        
        clear s
        