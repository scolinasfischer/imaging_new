function [propON] =  compute_proportions_over_time(ratiotype, these_ratios,these_worms,  category,analysis_pars, moviepars)
%this function calculates the proportion of neurons that are on at each
%timepoint of the relevant periods for each category:
% offHIGH: during 1st odour on period 
% onLOW:   during 1st odour off period
% bLOW:    during baseline period 

    % INPUTS:
    %   ratiotype       - (string) Type of ratio data ('normratios' or 'badjratios').
    %   these_ratios    - (matrix) Time-series ratio data, where rows = time points, columns = neurons.
    %   these_worms     - (cell array) List of neurons to analyze.
    %   category        - (string) Category defining the time period ('offHIGH', 'onLOW', 'bLOW').
    %   analysis_pars   - (struct) Parameters for analysis, including threshold for ON/OFF state.
    %   moviepars       - (struct) Movie parameters, including time window definitions.


%this function should only be running on normratios data, as we use the
%minmax normalised ratio with threshold of 0.5 to decide if a neuron is on
%or off.

%if try to run on anything other than normratios, throw warning and exit function
if  ~strcmp(ratiotype, "normratios") 
    warning("compute_proportions_over_time should only be run on normratios data.");
    return;
end
    

switch category
    case "offHIGH"
        start_time = moviepars.bend;
        end_time = moviepars.ONend;

    case "onLOW"
        start_time = moviepars.ONend;
        end_time = moviepars.OFFend;

    
    case "bLOW"
        start_time = moviepars.bstart;
        end_time = moviepars.bend;  

    otherwise
        error("Unexpected category: %s", category);
end


threshold = analysis_pars.ONOFFcategorisation.threshold;


propON = nan(moviepars.mend,1); %empty matrix to hold total number of neurons on at each time point

for t = start_time:end_time
    neurons_ON_now = find(these_ratios(t,:)>= threshold); %indices of neurons that are on at this time point 
    propON(t) = length(neurons_ON_now)/numel(these_worms); %divide neurons on now by number of total neurons (these_worms) to get proportion on at this time point


end





end