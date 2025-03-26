function save_analysis_params(pdir, general, analysis_pars, plotting, moviepars, colors)
    % Save parameters to .mat, .txt, and .xls files
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
    
    % === Save as .xls file ===
    xls_filename = fullfile(pdir, 'analysis_parameters.xlsx');
    struct_to_xls(xls_filename, general, analysis_pars, plotting, moviepars, colors);

    fprintf('Analysis parameters saved to:\n  - %s\n  - %s\n  - %s\n', mat_filename, txt_filename, xls_filename);
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
            valueStr = formatValueForTxt(value);
            fprintf(fid, '%s%s:%s %s\n', indent, fieldName, padding, valueStr);
        end
    end
end

function struct_to_xls(filename, varargin)
    % Converts structs to a cell array and writes to an Excel file using writecell.
    data = {};

    for i = 1:length(varargin)
        s = varargin{i};
        struct_name = inputname(i + 1);
        data = [data; {struct_name, ''}]; %#ok<AGROW>
        data = [data; {'Parameter', 'Value'}]; %#ok<AGROW>
        data = [data; struct_to_cell(s)]; %#ok<AGROW>
        data = [data; {'' ''}]; %#ok<AGROW> % Blank row for spacing
    end

    % Save to Excel using writecell (handles mixed data types properly)
    writecell(data, filename);
end

function cellArray = struct_to_cell(s, prefix)
    % Converts a structure to a cell array for writing to Excel
    if nargin < 2
        prefix = '';
    end
    
    cellArray = {};
    fields = fieldnames(s);
    
    for i = 1:numel(fields)
        fieldName = fields{i};
        fullFieldName = strcat(prefix, fieldName);
        value = s.(fieldName);
        
        % Handle different data types correctly
        if ischar(value) || isstring(value)
            valueStr = char(value);
        elseif isnumeric(value) && isscalar(value)
            valueStr = value;  % Scalars can be directly stored
        elseif isnumeric(value) && isvector(value)
            valueStr = sprintf('[%s]', num2str(value(:)')); % Ensure row vector format
        elseif isnumeric(value) && ismatrix(value)
            valueStr = sprintf('[%dx%d Matrix]', size(value,1), size(value,2));
        elseif ndims(value) == 3
            sz = size(value);
            valueStr = sprintf('[%dx%dx%d 3D Matrix]', sz(1), sz(2), sz(3));
        elseif islogical(value)
            valueStr = sprintf('[%s]', num2str(value(:)')); % Convert logical array to string of 1s and 0s
        elseif iscell(value)
            valueStr = '[Cell Array]'; % Just indicate it's a cell array
        elseif isstruct(value)
            nestedCells = struct_to_cell(value, strcat(fullFieldName, '.'));
            cellArray = [cellArray; nestedCells]; %#ok<AGROW>
            continue; % Skip adding it as a normal value
        else
            valueStr = '[Unsupported Type]';
        end
        
        cellArray = [cellArray; {fullFieldName, valueStr}]; %#ok<AGROW>
    end
end

function valueStr = formatValueForTxt(value)
    % Formats values properly for text file output
    if isnumeric(value)
        if ndims(value) == 3 && size(value, 2) == 1 && size(value, 3) == 3
            % Convert Nx1x3 matrix into Nx3 format (RGB triplets)
            rgbValues = reshape(value, [], 3);  % Convert to Nx3
            valueStr = sprintf('\n  RGB values:\n%s', mat2str(rgbValues));
        else
            valueStr = mat2str(value);
        end
    elseif islogical(value)
        valueStr = mat2str(value); % Converts logical values to 1/0
    elseif iscell(value)
        valueStr = '[Cell Array]'; % Represent cell arrays in text file
    elseif isstring(value) || ischar(value)
        valueStr = char(value);
    elseif isstruct(value)
        valueStr = '[Nested Struct]'; % Avoid printing entire nested struct as a single value
    else
        valueStr = '[Unsupported Type]';
    end
end
