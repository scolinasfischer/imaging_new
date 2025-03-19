function [offHIGH_norm, offHIGH_badj, cols_offHIGH, ...
          onLOW_norm, onLOW_badj, cols_onLOW, ...
          bLOW_norm, bLOW_badj, cols_bLOW] = ...
          categorisebyONOFFstates(threshold, these_nratios, these_bratios, these_worm_names, moviepars)
%  Classifies neurons based on activity states during odour presentation.
%
% This function categorises neurons into one of three activity states based 
% on normalised ratio (Fm) data:
%   - offHIGH: High activity at the end of baseline period (odour off)
%   - onLOW : Low activity at the end of the first odour on period
%   - bLOW  : Low activity at the beginning of the baseline period
%
% INPUTS:
%   these_nratios     - Normalised ratios (Fm) (each column is 1 worm)
%   these_bratios     - Baseline-adjusted ratios (R0)(each column is 1 worm)
%   these_worm_names  - Cell array of worm(neuron) names 
%   moviepars         - Struct with timing parameters
%
% OUTPUTS:
% (normalised ratios, baseline-adjusted ratios, worm names)
%   offHIGH_norm, offHIGH_badj, cols_offHIGH - Data for offHIGH state 
%   onLOW_norm, onLOW_badj, cols_onLOW       - Data for onLOW state
%   bLOW_norm, bLOW_badj, cols_bLOW          - Data for bLOW state

% -----------------------------------
% Validate Inputs
% -----------------------------------

    % Check that these_nratios and these_bratios are the same size and shape
    if ~isequal(size(these_nratios), size(these_bratios))
        error('these_nratios and these_bratios must have the same size and shape.');
    end
    
    % Check that the length of these_worm_names matches the number of columns
    if length(these_worm_names) ~= size(these_nratios, 2)
        error('Number of elements in these_worm_names must equal the number of columns in these_nratios and these_bratios.');
    end
    
    % Check that moviepars indices are valid
    if any([moviepars.bend, moviepars.ONend, moviepars.last10OFF] > size(these_nratios, 1))
        error('moviepars indices exceed matrix dimensions.');
    end
    


    
    % -----------------------------------
    % Initialise outputs
    % -----------------------------------
    cols_offHIGH = {};
    offHIGH_norm = [];
    offHIGH_badj = [];
    
    cols_onLOW = {};
    onLOW_norm = [];
    onLOW_badj = [];
    
    cols_bLOW = {};
    bLOW_norm = [];
    bLOW_badj = [];
    
    % -----------------------------------
    % LOOP TO CLASSIFY STATES
    % -----------------------------------
    %loop through each single worm and check if meets any of 3 categories
    for s = 1:length(these_worm_names)
        this_nratio = these_nratios(:, s);
        this_bratio = these_bratios(:, s);
        this_name = these_worm_names{s};
    
        % OFF HIGH: High activity at the end of the baseline period
        if this_nratio(moviepars.bend + 1) >= threshold
            offHIGH_norm = [offHIGH_norm this_nratio];
            offHIGH_badj = [offHIGH_badj this_bratio];
            cols_offHIGH = [cols_offHIGH this_name];
        end
    
        % ON LOW: Low activity at the end of the first odour on period
        if this_nratio(moviepars.ONend + 1) <= threshold
            onLOW_norm = [onLOW_norm this_nratio];
            onLOW_badj = [onLOW_badj this_bratio];
            cols_onLOW = [cols_onLOW this_name];
        end
    
        % BASELINE LOW: Low activity at the beginning of the baseline period
        if this_nratio(moviepars.bstart + 1) <= threshold 
            bLOW_norm = [bLOW_norm this_nratio];
            bLOW_badj = [bLOW_badj this_bratio];
            cols_bLOW = [cols_bLOW this_name];
        end
    end

end