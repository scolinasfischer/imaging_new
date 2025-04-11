

%{
Returns a string array of .xlsx file paths from a given directory (ignores subfolders).

Input:
- directory_name: folder to search
Output:
- filePaths: string array of .xlsx paths

helps avoid calling dir repeatedly in main function (not efficient)

%}

function filePaths = get_xlsx_filepaths(directory_name)
    filePaths = string(fullfile(directory_name, {dir(fullfile(directory_name, '*.xlsx')).name}))';
end
