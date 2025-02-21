
function extract_mat2xls(input_dir,output_dir,frame_rate)
%extract_mat2xls extracts required info from NEURON output .mat file
%   This information is then saved in .xls files in specified output
%   directory. Any .mat files that we want to exclude from analysis can
%   be placed in subfolder within input directory (eg with the name
%   "EXCLUDED"), as this function will ignore files in subfolders. 
%   Frame rate (frame_rate). Until now have always used 10 frames per
%   second, but as camera is actually slightly slower, set value to 9.9.


%% load files and checks of directory and files not empty etc

% Ensure output directory exists, if not, make it
if ~exist(output_dir, 'dir') %check if there is a _folder_ at this directory
    mkdir(output_dir);       %if not, create it
    warning('output directory not found, created %s', output_dir);
end


% Get a list of all .mat files in the input folder (no subfolders)
matFiles = dir(fullfile(input_dir, '*.mat'));


% Exit early if no files found
if isempty(matFiles)
    warning('No .mat files found in %s. Exiting function.', input_dir);
    return;
end



%% Cycle through list,  extract required info , save xls
for i = 1:length(matFiles)

    %Get full file path for this filename
    filePath = fullfile(input_dir, matFiles(i).name);




    %% checks
    
    % Load file
    %use try-catch block to make sure that all files can be loaded, if not
    %will throw error
    try
        data = load(filePath);
    catch
        warning('Could not load file: %s. Skipping.', filePath);
        continue;
    end
    
    % Ensure required variables exist
    if ~isfield(data, 'leftvalues') || ~isfield(data, 'rightvalues') || ~isfield(data, 'ratios')
        warning('Missing required variables in %s. Skipping.', filePath);
        continue;
    end
    



    %% get variables
    % Extract necessary variables 
    green = data.leftvalues;        %green fluorescence 
    red = data.rightvalues;         %red fluorescence
    ratios = data.ratios;   %green/red fluorescence ratio


    %Create new variables for time (frames and seconds)    
    numFrames = length(ratios);
    frames = (1:numFrames)'; % Frame numbers as column vector
    seconds = (0:numFrames-1)' / frame_rate; % Time in seconds, corresponding to each frame





    %% save and write to spreadsheet

    %Save data

    %Create matrix to be saved
    data_to_save = horzcat (ratios,green,red,frames ,seconds);    

    %Create a short filename for this file (will be name of saved xls file)
    short_filename = erase(matFiles(i).name, '-analysisdata.mat');
    output_filename = fullfile(output_dir, short_filename + ".xlsx");


    %Write to spreadsheet
    writematrix(data_to_save,output_filename,'Filetype', 'spreadsheet'); %write ratios variable to excel


    %% display text confirming this file was processed
    fprintf('Saved: %s\n', output_filename);

end


