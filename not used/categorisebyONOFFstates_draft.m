function [offHIGH_norm, offHIGH_badj, cols_offHIGH, ...
         onLOW_norm, onLOW_badj, cols_onLOW, ...
         bLOW_norm, bLOW_badj, cols_bLOW] = ...
         categorisebyONOFFstates(these_nratios, these_bratios, these_worm_names,pdir, general, colors, plotting, moviepars)


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
% these_nratios is normalised ratios (each column 1 worm)
% these bratios is baseline-adjusted ratios (each column 1 worm) 

%check that these_nratios and these_bratios are the same size and shape, and length of
%these_worm_names is equal to number of columns in nratios and bratios

    % Check that these_nratios and these_bratios are the same size and shape
    if ~isequal(size(these_nratios), size(these_bratios))
        error('these_nratios and these_bratios must have the same size and shape.');
    end
    
    % Check that the length of these_worm_names matches the number of columns
    if length(these_worm_names) ~= size(these_nratios, 2)
        error('Number of elements in these_worm_names must equal the number of columns in these_nratios and these_bratios.');
    end


    %Check that moviepars indices are not too big
    if any([moviepars.bend, moviepars.ONend, moviepars.last10OFF] > size(these_nratios, 1))
    error('moviepars indices exceed matrix dimensions.');
    end


%Set threshold for on/off categorisation
threshold = 0.5;


%Pull out worms that meet offHIGH category

    %create matrices to hold this data
     cols_offHIGH = {}; %names of worms that are in offHIGH category
     offHIGH_norm = []; %normalised ratios of worms that are in offHIGH category
     offHIGH_badj = []; %baseline-adj ratios of worms that are in offHIGH category
    %for loop to cycle through and pull out column of data and name
    for s = 1:length(these_worm_names)
        if these_nratios(moviepars.bend+1,s)>= threshold %check if value of F at baseline end frame is equal/over 0.5 
            offHIGH_norm = [offHIGH_norm these_nratios(:,s)];  %if it is, add normratio (deltaF/Fmax to adequate  matrix)
            offHIGH_badj = [offHIGH_badj these_bratios(:,s)];  %if it is, add badjratio (R-R0/R0 to adequate  matrix)
            cols_offHIGH = [cols_offHIGH these_worm_names(s)]; %if it is, add neuron name to OFF HIGH list
        end
    end


%Pull out worms that meet onLOW category
    %create matrices to hold this data
     cols_onLOW = {}; %names of worms that are in offHIGH category
     onLOW_norm = []; %normalised ratios of worms that are in offHIGH category
     onLOW_badj = []; %baseline-adj ratios of worms that are in offHIGH category
    %for loop to cycle through and pull out column of data and name
    for s = 1:length(these_worm_names)
        if these_nratios(moviepars.ONend+1,s)<= threshold %check if value of F at odour on end frame is equal/smaller 0.5 
            onLOW_norm = [onLOW_norm these_nratios(:,s)];  %if it is, add normratio (deltaF/Fmax to adequate  matrix)
            onLOW_badj = [onLOW_badj these_bratios(:,s)];  %if it is, add badjratio (R-R0/R0 to adequate  matrix)
            cols_onLOW = [cols_onLOW these_worm_names(s)]; %if it is, add neuron name to OFF HIGH list
        end
    end




%Pull out worms that meet bLOW category
    %create matrices to hold this data
     cols_bLOW = {}; %names of worms that are in offHIGH category
     bLOW_norm = []; %normalised ratios of worms that are in offHIGH category
     bLOW_badj = []; %baseline-adj ratios of worms that are in offHIGH category
    %for loop to cycle through and pull out column of data and name
    for s = 1:length(these_worm_names)
        if these_nratios(moviepars.last10OFF+1,s)<= threshold  %check if value of F at baseline start frame is equal/smaller 0.5 . called last10off cause use 10s prior to odour on, and in AIB is different from baseline start time
            bLOW_norm = [bLOW_norm these_nratios(:,s)];  %if it is, add normratio (deltaF/Fmax to adequate  matrix)
            bLOW_badj = [bLOW_badj these_bratios(:,s)];  %if it is, add badjratio (R-R0/R0 to adequate  matrix)
            cols_bLOW = [cols_bLOW these_worm_names(s)]; %if it is, add neuron name to OFF HIGH list
        end
    end

    



end




      