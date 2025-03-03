%% script with bits to plot check_frame_variation


figure;
boxplot(all_frames, 'Symbol', 'o'); % Standard boxplot
hold on;

% Generate random jitter for x-axis
x_jitter = 1 + (rand(size(all_frames)) - 0.5) * 0.2; % Small random shift around x = 1

% Scatter plot with jittered x-coordinates
scatter(x_jitter, all_frames, 'filled', 'MarkerFaceAlpha', 0.5);

% Count occurrences of each unique y-value
[unique_y, ~, idx] = unique(all_frames);
counts = accumarray(idx, 1); % Get count of each unique value

% Add text labels next to each unique y-value
for i = 1:length(unique_y)
    text(1.2, unique_y(i), num2str(counts(i)), 'FontSize', 10, 'FontWeight', 'bold'); 
end

% Set y-axis ticks to only include integers
yticks(min(all_frames):1:max(all_frames));

hold off;
