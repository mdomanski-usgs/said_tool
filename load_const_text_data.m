function data_loaded = load_const_text_data(handles)

% get the global loaded file name list
const_full_file = getappdata(handles.figure1,'const_full_file');

% get the current working directory
CWD = getappdata(handles.figure1,'CWD');

% set the filter spec to look for text files
FilterSpec = [CWD '\*.txt'];

% prompt user for file to load
[FileName,PathName,~] = uigetfile(FilterSpec);

% put together the path and file names
ConstDSName = fullfile(PathName,FileName);

% if the path and file names are successfully returned
if all(FileName ~= 0) && all(PathName ~= 0)
    
    h = said_busy_dialog(handles.figure1,'Loading', 'Loading surrogate data...');
    
    % load the dataset
    const_ds = dataset('File',ConstDSName);
    
    % get a cell string of variable names
    ConstDSVarNames = get(const_ds,'VarNames');
    
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
    
    setappdata(handles.figure1,'CWD',PathName);
    setappdata(handles.figure1,'const_full_file',const_full_file);
    
    close(h);
    
    data_loaded = true;
    
else
    
    data_loaded = false;
    
end
