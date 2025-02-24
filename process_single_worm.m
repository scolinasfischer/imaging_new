% this function accepts the filename for a single worm and processes the
% data in it: 
% - smooth, calculate adjratio, etc
% - plot
% - could add optional argument for whter to call bleach-correction

function data = process_single_worm(fname)

    %get a short filename for this file (filename only, no path or
    %extension)
    [~, short_fname, ~] = fileparts(fname);

       



    fprintf('Processed worm %s\n', short_fname);

end


