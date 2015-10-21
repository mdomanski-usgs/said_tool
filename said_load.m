function said_load( handles )

% get the current working directory
CWD = getappdata(handles.figure1,'CWD');

% prompt user to select a mat file to load
[saidStateMat,PathName] = uigetfile(fullfile(CWD,'*.mat'));

% get the full file name
saidStateFullFile = fullfile(PathName,saidStateMat);

% if the file exists
if exist(saidStateFullFile,'file')
    
    % load the .mat file into a structure
    S = load(saidStateFullFile);
    
    % if the .mat file contains all of the required information
    if all(isfield(S, {        ...
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
            'mdl', ...
            'ExcludeDates', ...
            'session_name' ...
            }))
        
        if isa(S.const_ds,'dataset')
            S.const_ds = dataset2table(S.const_ds);
        end
        
        if isa(S.matched_ds,'dataset')
            S.matched_ds = dataset2table(S.matched_ds);
        end
        
        ld_var_names = fieldnames(S.loaded_var_struct);
        
        for i = 1:length(ld_var_names)
            if isa(S.loaded_var_struct.(ld_var_names{i}),'dataset')
                S.loaded_var_struct.(ld_var_names{i}) = ...
                    dataset2table(S.loaded_var_struct.(ld_var_names{i}));
            end
        end
        
        if ~isdir(S.CWD)
            S.CWD = getenv('USERPROFILE');
        end
        
        % set current session global variables
        setappdata(handles.figure1,'advmParamStruct', S.advmParamStruct);
        setappdata(handles.figure1,'loaded_var_struct', S.loaded_var_struct);
        setappdata(handles.figure1,'CWD', S.CWD);
        setappdata(handles.figure1,'surr_full_file', S.surr_full_file);
        setappdata(handles.figure1,'const_full_file', S.const_full_file);
        setappdata(handles.figure1,'trans_vars', S.trans_vars);
        setappdata(handles.figure1,'bsPlotsFigNum', S.bsPlotsFigNum);
        setappdata(handles.figure1,'max_time_min', S.max_time_min);
        setappdata(handles.figure1,'const_ds', S.const_ds);
        setappdata(handles.figure1,'UpdateMatch', S.UpdateMatch);
        setappdata(handles.figure1,'UpdateProc', S.UpdateProc);
        setappdata(handles.figure1,'UpdateTrans', S.UpdateTrans);
        setappdata(handles.figure1,'UpdateMDL', S.UpdateMDL);
        setappdata(handles.figure1,'matched_ds', S.matched_ds);
        setappdata(handles.figure1,'mdl', S.mdl);
        setappdata(handles.figure1,'ExcludeDates', S.ExcludeDates);
        setappdata(handles.figure1,'session_name',S.session_name);
        
        % set flag to update gui
        setappdata(handles.figure1,'UpdateGUI',true);
        
    else
        
        % tell the user that said wasn't able to open the .mat file
        msgbox(['Unable to open ' saidStateFullFile],...
            'Error Opening',...
            'error');
        
    end
    
    % set the current working directory to the path name chosen by the user
    setappdata(handles.figure1,'CWD',PathName);
    
end