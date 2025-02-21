%this function accepts as input the directory name and returns a list of 
% all .xls files in the input folder (will ignore other filetypes, 
% subfolders, and files in subfolders). 
% helps avoid calling dir repeatedly in main function (not efficient)

function filePaths = get_xlsx_filepaths(directory_name)
    filePaths = string(fullfile(directory_name, {dir(fullfile(directory_name, '*.xlsx')).name}))';
end
