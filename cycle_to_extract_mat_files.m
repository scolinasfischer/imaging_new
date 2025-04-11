%{
Loops through all genotype × condition directories and extracts .mat files to .xlsx using extract_mat2xls.

Inputs:
- all_mat_dirs: cell array of .mat directories
- all_xlsx_dirs: matching output directories for .xlsx files
- frame_rate: frames per second of movie
%}

function cycle_to_extract_mat_files(all_mat_dirs, all_xlsx_dirs, frame_rate)
    dir_size = size(all_mat_dirs);
    for r = 1:dir_size(1)
        for c = 1:dir_size(2)
            extract_mat2xls(all_mat_dirs{r, c}, all_xlsx_dirs{r, c}, frame_rate);
            fprintf("Extracted .mat files to xlsx: %s\n", all_xlsx_dirs{r, c});
        end
    end
end
