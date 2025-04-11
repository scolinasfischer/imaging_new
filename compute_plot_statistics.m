%{
Computes average, SEM, and time vector from a matrix of fluorescence ratios.

Inputs:
- all_adjratios: matrix (rows: time, cols: neurons)
- frame_rate: frames per second (used for time vector)

Outputs:
- avg_all_adjratios: mean ratio over neurons
- SEM: standard error of the mean
- all_secs: time in seconds
%}

function [avg_all_adjratios, SEM, all_secs] = compute_plot_statistics(all_adjratios, frame_rate)
%% Compute statistics
    % Number of non-NaN values per time point
    n = sum(~isnan(all_adjratios),2);

    % Compute mean while ignoring NaNs
    avg_all_adjratios = mean(all_adjratios, 2, 'omitnan');

    % Compute Standard Error of the Mean (SEM)
    SEM = std(all_adjratios, 0, 2, 'omitnan') ./ sqrt(n);

    % Generate time vector
    maxl = size(all_adjratios, 1);
    all_secs = (1/frame_rate) * (0:(maxl-1))';
end
