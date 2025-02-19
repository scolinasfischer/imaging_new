
function extract_mat2xls(input_dir,output_dir,frame_rate)
%extract_mat2xls extracts required info from NEURON output .mat file
%   This information is then saved in .xls files in specified output
%   directory. Any .mat files that we want to exclude from analysis can
%   be placed in subfolder within input directory (eg with the name
%   "EXCLUDED"), as this function will ignore files in subfolders. 
%   Frame rate (frame_rate). Until now have always used 10 frames per
%   second, but as camera is actually slightly slower, set value to 9.9.


% Get a list of all .mat files in the input folder (no subfolders)
matFiles = dir(fullfile(input_dir, '*.mat'));

%Cycle through list,  extract required info , save xls
for i = 1:length(matFiles)

    %Get full file path for this filename
    filePath = fullfile(input_dir, matFiles(i).name);
    %Load  file
    load(filePath)



    %Extract necessary variables
    green = leftvalues;  %green fluorescence 
    red = rightvalues; %red fluorescence
    ratio_greenred = ratios; %green/red fluorescence ratio


    %Create new variables for time (frames and seconds)
    frames = [1:1:length(ratios)]; %frame number
    frames = frames';               %transpose to get column vector    
    seconds = (1/frame_rate)*(0:(length(ratios)-1)); %calculates time in seconds corresponding to each frame and ratio
    seconds = seconds';             %transpose to get column vector
    


    
    %Save data

    %Create matrix to be saved
    data_to_save = horzcat (ratios,green,red,frames ,seconds);    

    %Create a short filename for this file (will be name of saved xls file)
    short_filename = erase(matFiles(i).name, '-analysisdata.mat');
    short_filename = strcat(output_dir,"/",short_filename);

    %Write to spreadsheet
    writematrix(data_to_save,short_filename,'Filetype', 'spreadsheet'); %write ratios variable to excel



end


