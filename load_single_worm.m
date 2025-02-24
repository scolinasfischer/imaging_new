
%This function accepts as input filename for single worm. It loads the data
%for that worm, saves each column to a variable in workspace, and then
%returns those as outputs. 

function [raw_ratio, raw_green, raw_red, frames, secs] = load_single_worm(filename)


 %load data in try-catch block to catch errors
        try
            data = readmatrix(filename);
        catch ME %ME will save info on error if one occurs
            warning("Failed to read file: %s. Error: %s", filename, ME.message); %this prints error message (stored in ME)
            data = []; % Return empty to indicate failure
        end
        

        raw_ratio = data(:,1); % raw GFP/RFP ratio
        raw_green = data(:,2); % raw green fluorescence
        raw_red   = data(:,3); % raw red fluorescence
        frames    = data(:,4); % time in frames 
        secs      = data(:,5); % time in seconds
        
        
