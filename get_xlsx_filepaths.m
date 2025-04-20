
%{
Returns a string array of full file paths to all `.xlsx` files in the specified directory.

This function ignores subfolders and non-`.xlsx` file types. 
If no `.xlsx` files are found, it throws a warning to alert the user.

Inputs:
- directory_name (string): Path to the directory to search for `.xlsx` files.

Outputs:
- filePaths (string array): Full paths to each `.xlsx` file found in the directory. 
                            If none are found, this will be an empty array.

Side effects:
- Displays a warning in the command window if no `.xlsx` files are found in the directory.
%}


function filePaths = get_xlsx_filepaths(directory_name)
    % Get all .xlsx files in the directory
    file_list = dir(fullfile(directory_name, '*.xlsx'));

    % Throw warning if no files found
    if isempty(file_list)
        warning('No .xlsx files found in directory: %s', directory_name);
    end    


filePaths = string(fullfile(directory_name, {dir(fullfile(directory_name, '*.xlsx')).name}))';




end
