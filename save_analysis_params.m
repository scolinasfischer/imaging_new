function save_analysis_params(pdir, general, analysis_pars, plotting, moviepars, colors)
    % Save parameters to both a .mat file and a .txt file
    %
    % Parameters:
    %   pdir - Output directory path
    %   general, analysis_pars, plotting, moviepars, colors - Structures to save

    % === Save as .mat file ===
    mat_filename = fullfile(pdir, 'analysis_parameters.mat');
    save(mat_filename, 'general', 'analysis_pars', 'plotting', 'moviepars', 'colors');
    
    % === Save as .txt file ===
    txt_filename = fullfile(pdir, 'analysis_parameters.txt');
    fid = fopen(txt_filename, 'w');
    
    if fid == -1
        error('Could not open file for writing: %s', txt_filename);
    end

    try
        writeStructToFile(fid, 'General Parameters', general, 0);
        writeStructToFile(fid, 'Analysis Parameters', analysis_pars, 0);
        writeStructToFile(fid, 'Plotting Parameters', plotting, 0);
        writeStructToFile(fid, 'Movie Parameters', moviepars, 0);
        writeStructToFile(fid, 'Colors', colors, 0);
    catch ME
        fclose(fid);
        rethrow(ME);
    end

    fclose(fid);
    fprintf('Analysis parameters saved to:\n  - %s\n  - %s\n', mat_filename, txt_filename);
end

function writeStructToFile(fid, title, s, indentLevel)
    % Helper function to write struct data to a text file (handles nested structs)
    indent = repmat('  ', 1, indentLevel);  % Indentation for readability
    fprintf(fid, '\n%s=== %s ===\n', indent, title);
    
    fields = fieldnames(s);
    maxFieldLength = max(cellfun(@length, fields));  % Find longest field name

    for i = 1:length(fields)
        fieldName = fields{i};
        value = s.(fieldName);
        
        % Add spaces to align values
        padding = repmat(' ', 1, maxFieldLength - length(fieldName));

        if isstruct(value)
            % Recursively write nested structs
            fprintf(fid, '\n%s%s:\n', indent, fieldName);
            writeStructToFile(fid, '', value, indentLevel + 1);
        else
            if isnumeric(value)
                if ndims(value) == 3 && size(value, 2) == 1 && size(value, 3) == 3
                    % Convert Nx1x3 matrix into Nx3 format (RGB triplets)
                    rgbValues = reshape(value, [], 3);  % Convert to Nx3
                    valueStr = sprintf('\n%s  RGB values:\n%s', indent, mat2str(rgbValues));
                else
                    valueStr = mat2str(value);
                end
            elseif islogical(value)
                valueStr = mat2str(value); % Converts logical values to 1/0
            else
                valueStr = char(value);
            end
            fprintf(fid, '%s%s:%s %s\n', indent, fieldName, padding, valueStr);
        end
    end
end
