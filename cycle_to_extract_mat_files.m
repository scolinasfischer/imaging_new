%%
% this function cycles through array of mat directories (mock, avsv, sexc
% and wt/mut) and then calls extract_mat2xls which extracts all mat files
% in that directory, saves required data to xls
function cycle_to_extract_mat_files(all_mat_dirs, all_xlsx_dirs, frame_rate)
    dir_size = size(all_mat_dirs);
    for r = 1:dir_size(1)
        for c = 1:dir_size(2)
            extract_mat2xls(all_mat_dirs{r, c}, all_xlsx_dirs{r, c}, frame_rate);
            fprintf("Extracted .mat files to xlsx: %s\n", all_xlsx_dirs{r, c});
        end
    end
end
