%{
Extracts data from NEURON output .mat files and saves them to .xlsx files.

Inputs:
- input_dir: folder with .mat files
- output_dir: where .xlsx files should be saved
- frame_rate: recording frame rate (e.g., 9.9 Hz)

Automatically handles downsampling for older 20fps videos.
Will ignore files in subfolders of input_dir. 
%}

function extract_mat2xls(input_dir,output_dir,frame_rate)
%extract_mat2xls extracts required info from NEURON output .mat file
%   This information is then saved in .xls files in specified output
%   directory. Any .mat files that we want to exclude from analysis can
%   be placed in subfolder within input directory (eg with the name
%   "EXCLUDED"), as this function will ignore files in subfolders. 
%


%% load files and checks of directory and files not empty etc

% Ensure output directory exists, if not, make it
if ~exist(output_dir, 'dir') %check if there is a _folder_ at this directory
    mkdir(output_dir);       %if not, create it NB this wont work on server
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
    OG_green = data.leftvalues;        %green fluorescence 
    OG_red = data.rightvalues;         %red fluorescence
    ratios = data.ratios;   %green/red fluorescence ratio


    %Create new variables for time (frames and seconds)    
    numFrames = length(ratios);
    frames = (1:numFrames)'; % Frame numbers as column vector
    seconds = (0:numFrames-1)' / frame_rate; % Time in seconds, corresponding to each frame


    %% if clause for old 20fps videos which have only half of ratios data
    %for videos where ratios data is aproximately half of red and green, 
    % need to also extract only half of red and green to match the
    % previously extracted half of ratios vector

    if length(OG_green) == (length(ratios) * 2) || length(OG_green) == (length(ratios) * 2 - 1) 
    % if it is the case that this is only half of the ratio data, save only
    % half of the green and red raw fluorescence
        green = OG_green(1:2:end);
        red = OG_red(1:2:end);
        
        fprintf("This file was 20fps, saved only half of raw green and red: %s\n", filePath);
    
    %if not, save the red and green fluorescence as is
    else
        green = OG_green;
        red = OG_red;


    end



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


