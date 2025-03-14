% Define constants
videolength = 100; % seconds
ideal_frame_rate = 1; 
maxframes = videolength * ideal_frame_rate; 

% Sample raw data (3 videos with different frame counts)
raw_ratios1 = linspace(1, 80, 80)';  % 80 frames
raw_ratios2 = linspace(1, 90, 90)';  % 90 frames
raw_ratios3 = linspace(1, 100, 100)'; % 100 frames

% Store in all_raw_ratios (filled with NaNs initially)
all_raw_ratios = NaN(maxframes, 3);
all_raw_ratios(1:length(raw_ratios1), 1) = raw_ratios1;
all_raw_ratios(1:length(raw_ratios2), 2) = raw_ratios2;
all_raw_ratios(1:length(raw_ratios3), 3) = raw_ratios3;




% Define frame_numbers vector
frame_numbers = [length(raw_ratios1), length(raw_ratios2), length(raw_ratios3)];

time_adjusted_ratios = nan(size(all_raw_ratios));




% % % % 
% % % % % Define constants
% % % % videolength = 220; % seconds
% % % % ideal_frame_rate = 10; 
% % % % maxframes = videolength * ideal_frame_rate; 
% % % % 
% % % % % Get list of filenames (assumes all .xls files are in the directory)
% % % % filenames = dir('*.xls');
% % % % num_files = length(filenames);
% % % % 
% % % % % Initialize matrices with NaNs
% % % % all_raw_ratios = NaN(maxframes, num_files);
% % % % time_adjusted_ratios = NaN(maxframes, num_files);
% % % % 
% % % % % Initialize frame numbers list
% % % % frame_numbers = zeros(num_files, 1);
% % % % 
% % % % % Load data from each file
% % % % for i = 1:num_files
% % % %     data = readmatrix(filenames(i).name); % Load .xls file
% % % %     raw_ratios = data(:, 1); % Assuming first column contains the relevant data
% % % %     
% % % %     frame_number = length(raw_ratios);
% % % %     frame_numbers(i) = frame_number; % Store the number of frames
% % % % 
% % % %     % Store raw data in all_raw_ratios
% % % %     all_raw_ratios(1:frame_number, i) = raw_ratios;
% % % % end
% % % % 


%check if video is within 1% of frames expected from max video length
% if so, apply time correction, if not no. 


% Determine median frame number
median_frame_number = median(frame_numbers);

% Adjust each column in all_raw_ratios
for i = 1:length(frame_numbers)
    raw_ratios = all_raw_ratios(:, i);
    frame_number = frame_numbers(i);
    
    if frame_number == median_frame_number
        % If already at median frame number, copy as is
        time_adjusted_ratios(1:frame_number, i) = raw_ratios(1:frame_number);
    
    elseif frame_number > median_frame_number
        % If more frames than the median, remove evenly spaced indices
        diff = frame_number - median_frame_number;
        indices_to_remove = round(linspace(1, frame_number, diff+2));
        
        % Remove those indices from raw_ratios
        adjusted_ratios = raw_ratios(~isnan(raw_ratios));
        adjusted_ratios(indices_to_remove(2:end-1)) = [];
        
        % Store in time_adjusted_ratios
        time_adjusted_ratios(1:median_frame_number, i) = adjusted_ratios;
        
    elseif frame_number < median_frame_number
        % If fewer frames than the median, add NaNs at evenly spaced indices
        diff = median_frame_number - frame_number;
        indices_to_add = round(linspace(1, frame_number, diff+2));
        
        adjusted_ratios = NaN(median_frame_number, 1); % Start with NaNs
        insert_index = 1;
        raw_index = 1;
        
        for j = 1:median_frame_number
            if ismember(j, indices_to_add(2:end-1))
                adjusted_ratios(j) = NaN; % Insert NaN at designated index
            else
                adjusted_ratios(j) = raw_ratios(raw_index); % Copy raw data
                raw_index = raw_index + 1;
            end
        end
        
        % Store in time_adjusted_ratios
        time_adjusted_ratios(1:median_frame_number, i) = adjusted_ratios;
    end
end

time_adjusted_ratios = time_adjusted_ratios(1:median_frame_number, :);
