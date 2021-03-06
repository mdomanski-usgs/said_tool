function data_loaded = load_const_text_data(ConstDSName, handles)

% get the global loaded file name list
% const_full_file = getappdata(handles.figure1,'const_full_file');

[PathName,NAME,EXT] = fileparts(ConstDSName);
FileName = [NAME EXT];

trans_vars = getappdata(handles.figure1,'trans_vars');
loaded_var_struct = getappdata(handles.figure1,'loaded_var_struct');
var_struct_names = fieldnames(loaded_var_struct);

% if the path and file names are successfully returned
% if all(FileName ~= 0) && all(PathName ~= 0)
if exist(ConstDSName,'file') == 2
    
    h = said_busy_dialog(handles.figure1,'Loading', 'Loading surrogate data...');
    
    % load the dataset
    const_ds = dataset('File',ConstDSName);
    const_ds = dataset2table(const_ds);
    
    % get a cell string of variable names
%     ConstDSVarNames = get(const_ds,'VarNames');
    ConstDSVarNames = const_ds.Properties.VariableNames;
    
    % if all date/time information is present
    if (any(strcmp('y',ConstDSVarNames)) && ...
            any(strcmp('m',ConstDSVarNames)) && ...
            any(strcmp('d',ConstDSVarNames)) && ...
            any(strcmp('H',ConstDSVarNames)) && ...
            any(strcmp('M',ConstDSVarNames)) && ...
            any(strcmp('S',ConstDSVarNames))) || ...
            (any(strcmp('Date',ConstDSVarNames)) && ...
            any(strcmp('Time',ConstDSVarNames)))  || ...
            any(strcmp('DateTime',ConstDSVarNames))
        
        % format the date/time variable
        const_ds = formatDSDate(const_ds);
        
        % set the displayed constituent dataset name
        set(handles.ConstDataSetName_edit,'String',FileName);
        
        % keep track of the full constituent dataset file path
        const_full_file = {ConstDSName};
        
        % set global parameters
        setappdata(handles.figure1,'const_ds',const_ds);
        
    % otherwise notifiy user and do not load constituent dataset
    else
        
        errordlg('File does not contain necessary date/time information!', ...
            'Error loading file');
        uiwait(gcf);
        
    end
    
    if ~isempty(var_struct_names)
        
        for i = 1:size(trans_vars,1)
            trans_var_name = [trans_vars{i,2} trans_vars{i,1}];
            if any(strcmp(trans_vars{i,1},ConstDSVarNames))
                if isfield(loaded_var_struct,trans_var_name)
                    loaded_var_struct = rmfield(loaded_var_struct,trans_var_name);
                end
            end
        end
        
    end
    
    setappdata(handles.figure1,'CWD',PathName);
    setappdata(handles.figure1,'const_full_file',const_full_file);
    setappdata(handles.figure1,'loaded_var_struct',loaded_var_struct);
    
    close(h);
    
    data_loaded = true;
    
else
    
    data_loaded = false;
    
end
