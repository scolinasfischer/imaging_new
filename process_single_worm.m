% this function accepts the filename for a single worm and processes the
% data in it: 
% - smooth, calculate adjratio, etc
% - plot
% - could add optional argument for whter to call bleach-correction

function data = process_single_worm(fname)

    %get a short filename for this file (filename only, no path or
    %extension)
    [~, short_fname, ~] = fileparts(fname);

    %load data in try-catch block to catch errors
    try
        data = readmatrix(fname);
    catch ME %ME will save info on error if one occurs
        warning("Failed to read file: %s. Error: %s", fname, ME.message); %this prints error message (stored in ME)
        data = []; % Return empty to indicate failure
    end
    



end


