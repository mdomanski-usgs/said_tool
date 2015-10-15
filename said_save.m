function said_save( handles )

% get global variables to save
advmParamStruct = getappdata(handles.figure1,'advmParamStruct');
loaded_var_struct = getappdata(handles.figure1,'loaded_var_struct');
CWD = getappdata(handles.figure1,'CWD');
surr_full_file = getappdata(handles.figure1,'surr_full_file');
const_full_file = getappdata(handles.figure1,'const_full_file');
trans_vars = getappdata(handles.figure1,'trans_vars');
bsPlotsFigNum   = getappdata(handles.figure1,'bsPlotsFigNum');
max_time_min = getappdata(handles.figure1,'max_time_min');
const_ds = getappdata(handles.figure1,'const_ds');
UpdateMatch = getappdata(handles.figure1,'UpdateMatch');
UpdateProc = getappdata(handles.figure1,'UpdateProc');
UpdateTrans = getappdata(handles.figure1,'UpdateTrans');
UpdateGUI = getappdata(handles.figure1,'UpdateGUI');
UpdateMDL = getappdata(handles.figure1,'UpdateMDL');
matched_ds = getappdata(handles.figure1,'matched_ds');
mdl = getappdata(handles.figure1,'mdl');
ExcludeDates = getappdata(handles.figure1,'ExcludeDates');
session_name = getappdata(handles.figure1,'session_name');

% if this is a new session, prompt the user with a new file name, otherwise
% give the user the current session name
if strcmp(session_name,'New')
    [FileName,PathName] = uiputfile(fullfile(CWD,'*.mat'));
else
    [FileName,PathName] = uiputfile(fullfile(CWD,[session_name '.mat']));
end

% if the path name is legit
if ischar(PathName) && exist(PathName,'dir')
    
    % set the current working directory to the path name
    CWD = PathName ;
    
    % use the root file name as the session name
    [~,session_name] = fileparts(FileName);
    
    % save a mat file with the information
    save(fullfile(PathName,FileName),...
        'advmParamStruct' ,...
        'loaded_var_struct', ...
        'CWD', ...
        'surr_full_file', ...
        'const_full_file', ...
        'trans_vars', ...
        'bsPlotsFigNum', ...
        'max_time_min', ...
        'const_ds', ...
        'UpdateMatch', ...
        'UpdateProc', ...
        'UpdateTrans' ,...
        'UpdateGUI', ...
        'UpdateMDL', ...
        'matched_ds', ...
        'mdl' ,...
        'ExcludeDates', ...
        'session_name' ...
        );
    
    % update the current sessions's information
    setappdata(handles.figure1,'CWD',CWD);
    setappdata(handles.figure1,'session_name',session_name);
    setappdata(handles.figure1,'UpdateGUI',true);
    
end
