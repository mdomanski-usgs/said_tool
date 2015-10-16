function update(handles)
%
% update(handles) - update function for the SAID GUI
%
% input
% handles - GUIDE handles structure

% get update flags
UpdateProc      = getappdata(handles.figure1,'UpdateProc');
UpdateTrans     = getappdata(handles.figure1,'UpdateTrans');
UpdateMatch     = getappdata(handles.figure1,'UpdateMatch');
UpdateGUI       = getappdata(handles.figure1,'UpdateGUI');
UpdateMDL       = getappdata(handles.figure1,'UpdateMDL');


% if the dataset needs to be processed
if UpdateProc
    
    % call function to update the processed dataset
    update_proc(handles);
    
    % clear the update flag
    UpdateProc = false;
    
    % set update transform flag
    UpdateTrans = true;
    
end

% if the transformation 
if UpdateTrans
    
    % call function to update the transformed data
    update_trans(handles);
    
    % clear the update flag
    UpdateTrans = false;
    
    % set update match flag
    UpdateMatch = true;
    
end

% if the datasets need to be matched
if UpdateMatch
    
    % call function to update the matched dataset
    update_match(handles);
    
    % clear the update flag
    UpdateMatch = false;
    
%     UpdateGUI = true;
    UpdateMDL = true;
    
end

% if the model needs to be updated
if UpdateMDL
    
    % call function to update the model
    update_mdl(handles);

    % clear the update flag
    UpdateMDL = false;
    
    % set subsequent update flag
    UpdateGUI = true;
    
end

% if the gui needs to be updated
if UpdateGUI
    
    % call function to update the gui
    update_gui(handles);
    
    % clear the update flag
    UpdateGUI = false;
    
end

 
% set update flags
setappdata(handles.figure1,     'UpdateMatch',   UpdateMatch);
setappdata(handles.figure1,     'UpdateProc',    UpdateProc);
setappdata(handles.figure1,     'UpdateTrans',   UpdateTrans);
setappdata(handles.figure1,     'UpdateGUI',     UpdateGUI);
setappdata(handles.figure1,     'UpdateMDL',     UpdateMDL);

end

%%% update functions

function update_proc(handles)

% get global variables
loaded_var_struct = getappdata(handles.figure1,'loaded_var_struct');
advm_param_struct = getappdata(handles.figure1,'advmParamStruct');

% initialize busy dialog
h = said_busy_dialog(handles.figure1, 'Processing', 'Processing AVDM Data');

% process the advm variables
loaded_var_struct = proc_advm_vars(loaded_var_struct,advm_param_struct);

% close the busy dialog figure
close(h);

% update the loaded variable structure
setappdata(handles.figure1,'loaded_var_struct',loaded_var_struct);

end


function update_trans(handles)

% get global variables
trans_vars = getappdata(handles.figure1,'trans_vars');
const_ds = getappdata(handles.figure1,'const_ds');
loaded_var_struct = getappdata(handles.figure1,'loaded_var_struct');

% constituent transformed variables
const_trans_vars = {};

% surrogate transformed variables
surr_trans_vars = {};

% get the constituent variable names
% const_vars = get(const_ds,'VarNames');
const_vars = const_ds.Properties.VariableNames;

% get the surrogate variable names
surr_vars = fieldnames(loaded_var_struct);

% for every variable to transform
for i = 1:size(trans_vars,1)
    
    % get the constituent and surrogate variable names and transformations
    if any(strcmp(trans_vars{i,1},const_vars))
        const_trans_vars = [const_trans_vars; trans_vars(i,:)];
    elseif any(strcmp(trans_vars{i,1},surr_vars))
        surr_trans_vars = [surr_trans_vars; trans_vars(i,:)];
    end
    
end

% transform the constituent variables
const_ds = trans_ds_vars(const_ds, const_trans_vars);

% transform the surrogate variables
loaded_var_struct = trans_struct_vars(loaded_var_struct,surr_trans_vars);

% update modified global variables
setappdata(handles.figure1,'const_ds',const_ds);
setappdata(handles.figure1,'loaded_var_struct',loaded_var_struct);

end


function update_match(handles)

% get global variables
const_ds = getappdata(handles.figure1,'const_ds');
loaded_var_struct = getappdata(handles.figure1,'loaded_var_struct');
max_time_min = getappdata(handles.figure1,'max_time_min');

% if there is data to match
if ~isempty(fieldnames(loaded_var_struct)) || ...
        ~isempty(const_ds)

    % initialize busy dialog
    h = said_busy_dialog(handles.figure1, 'Matching', 'Matching data...');
    
    % match the data
    matched_ds = match_data( const_ds, loaded_var_struct, max_time_min);
    
    % close busy dialog
    close(h);
    
else
    
    % otherwise set matched dataset to empty
%     matched_ds = dataset();
    matched_ds = table();
    
end

% update global variables
setappdata(handles.figure1,'matched_ds',matched_ds);

end


function update_mdl(handles)

% get the global dataset
matched_ds   = getappdata(handles.figure1,'matched_ds');

% get the dates of values to exclude
ExcludeDates = getappdata(handles.figure1,'ExcludeDates');

% get the selected predictor variables
listboxcontents = ...
    cellstr(get(handles.predictVariables_listbox,'String'));
PredictorVars = ...
    listboxcontents(get(handles.predictVariables_listbox,'Value'));

% get the selected response variable
popupmenucontents = ...
    cellstr(get(handles.responseVar_popupmenu,'String'));
ResponseVar = ...
    popupmenucontents{get(handles.responseVar_popupmenu,'Value')};

% if there a dataset to build a model with
if ~isempty(matched_ds)
    
    mdlDS = matched_ds;
%     mdlDSVarNames = mdlDS.Properties.VarNames;
    mdlDSVarNames = mdlDS.Properties.VariableNames;
    
    % if the predictor and response variables aren't empty and are valid
    if (~isempty(PredictorVars) && ~isempty(ResponseVar))   && ...
            all(ismember(PredictorVars,mdlDSVarNames))      && ...
            ismember(ResponseVar,mdlDSVarNames)             && ...
            ~any(strcmp(ResponseVar,PredictorVars))
        
        % find occurences of the model date serial numbers in the list of
        % excluded values
        Lia = ismember(mdlDS.DateTime,ExcludeDates);

        % create a linear model with the selected variables
        mdl = LinearModel.fit(mdlDS,...
            'PredictorVars',    PredictorVars   ,...
            'ResponseVar',      ResponseVar     ,...
            'Exclude',          Lia);
    else
        
        % otherwise set mdl to an empty matrix
        mdl = [];
        
    end
    
else
    
    mdl = [];
    
end

% update the value for mdl
setappdata(handles.figure1,'mdl',mdl);

end


function update_gui(handles)

% define names not to show in the variable lists
BannedVarnames = {...
    'R'     ,...
    'MB'    ,...
    'WCB'   ,...
    'SCB'    ...
    };

% get global variables
version = getappdata(handles.figure1,'version');
session_name = getappdata(handles.figure1,'session_name');
surr_full_file = getappdata(handles.figure1,'surr_full_file');
const_full_file = getappdata(handles.figure1,'const_full_file');
matched_ds = getappdata(handles.figure1,'matched_ds');
const_ds = getappdata(handles.figure1,'const_ds');
mdl = getappdata(handles.figure1,'mdl');
bsPlotsFigNum = getappdata(handles.figure1,'bsPlotsFigNum');
max_time_min = getappdata(handles.figure1,'max_time_min');
% trans_vars = getappdata(handles.figure1,'trans_vars');

% close the backscatter plots figure
if ishandle(bsPlotsFigNum)
    close(bsPlotsFigNum);
end

% if the model is not empty
if ~isempty(mdl)

    % get the model predictor variables
    PredictorVars = mdl.PredictorNames;
    
    % get the model response variable
    ResponseVar = mdl.ResponseName;
    
else
    
    % set the predictor and response variables to an empty matrix
    PredictorVars = [];
    ResponseVar = [];
    
end

% get the variable names from the constituent dataset
% const_var_names = get(const_ds,'VarNames');
const_var_names = const_ds.Properties.VariableNames;

% get the variable names from the matched dataset
% surr_var_names = get(matched_ds,'VarNames');
surr_var_names = matched_ds.Properties.VariableNames;

% for i = 1:size(trans_vars,1)
%     
%     if any(strcmp(trans_vars{i,1},const_var_names))
%         const_var_names{end+1} = [trans_vars{i,2} trans_vars{i,1}];
%     elseif any(strcmp(trans_vars{i,1},surr_var_names))
%         surr_var_names{end+1} = [trans_vars{i,2} trans_vars{i,1}];
%     end
%         
% end

% remove the DateTime variable from the constituent variable name list
iDateTime = strcmp('DateTime',const_var_names);
const_var_names(iDateTime) = [];
if isempty(const_var_names)
    const_var_names = {'-'};
end

% remove the DateTime variable from the surrogate variable name list
iDateTime = strcmp('DateTime',surr_var_names);
surr_var_names(iDateTime) = [];

% remove any advm and constituent variables that aren't supposed to show up 
% in the list
for i = length(surr_var_names):-1:1
    if any(strcmp(surr_var_names{i},[BannedVarnames const_var_names]))
        surr_var_names(i) = [];
    end
end

% get the locations of predictor variables
predictVariables_value = [];
for k = 1:length(surr_var_names)
    if any(strcmp(surr_var_names{k},PredictorVars))
        predictVariables_value(end+1)=k;
    end
end

% get the location of the response variable
responsVar_value = find(strcmp(ResponseVar,const_var_names),1);
if isempty(responsVar_value)
    responsVar_value = 1;
end

% surrogate file information
if ~isempty(surr_full_file)
    surr_listbox_str = {};
    for i = 1:length(surr_full_file)
        [~, name,ext] = fileparts(surr_full_file{i});
        surr_listbox_str = [surr_listbox_str;[name ext]];
    end
else
    surr_listbox_str = char.empty(1,0);
end

% constituent file information
if ~isempty(const_full_file)
    [~,name,ext] = fileparts(const_full_file{1});
    const_text_str = [name ext];
else
    const_text_str = '';
end

% update pushbutton functionality

if ~isempty(matched_ds)
    set(handles.transformVariable_pushbutton,'enable','on');
else
    set(handles.transformVariable_pushbutton,'enable','off');
end

if ~isempty(mdl)
    totalSamples = size(mdl.ObservationInfo,1);
    nObservations = mdl.NumObservations;
    set(handles.viewTable_pushbutton, 'enable', 'on');
    set(handles.displayModel_pushbutton, 'enable', 'on');
    set(handles.writeReport_pushbutton, 'enable', 'on');
    set(handles.plots_pushbutton, 'enable', 'on');
    if any(strcmp('R',mdl.VariableNames))
        set(handles.plotBackScatter_pushbutton, 'enable', 'on');
    end
    set(handles.timeSeries_pushbutton, 'enable', 'on');
else
    nObservations = 0;
    totalSamples = 0;
    set(handles.viewTable_pushbutton, 'enable', 'off');
    set(handles.displayModel_pushbutton, 'enable', 'off');
    set(handles.writeReport_pushbutton, 'enable', 'off');
    set(handles.plots_pushbutton, 'enable', 'off');
    set(handles.plotBackScatter_pushbutton, 'enable', 'off');
    set(handles.timeSeries_pushbutton, 'enable', 'off');    
end


% update gui text
set(handles.ConstDataSetName_edit,'String',const_text_str);

set(handles.SurrDataSetNames_listbox,'String',surr_listbox_str);
set(handles.SurrDataSetNames_listbox,'Value',1);

set(handles.maxTime_edit,'String',max_time_min);

set(handles.predictVariables_listbox,'String',surr_var_names);
set(handles.predictVariables_listbox,'Value',predictVariables_value);

set(handles.responseVar_popupmenu,'String',const_var_names);
set(handles.responseVar_popupmenu,'Value',responsVar_value);

set(handles.nObservations_text,'String',nObservations);

set(handles.nSamples_text,'String',totalSamples);

set(handles.figure1,'Name',['SAID v ' version ': ' session_name]);

end


%%% utility functions

function matched_ds = match_data( master_ds, loaded_var_struct, max_time_min)

% variables to skip
advm_vars = { ...
    'Amp1'      ,...
    'Amp2'      ,...
    'SNR1'      ,...
    'SNR2'       ...
    };

% master_vars = get(master_ds,'VarNames');
master_vars = master_ds.Properties.VariableNames;

% convert max_time_min from minutes to MATLAB date serial number
max_time_sn = datenum([0 0 0 0 max_time_min 0]);

% create a copy of the master dataset to add variables to
matched_ds = master_ds;

% get the names of the loaded variables
loaded_var_names = fieldnames(loaded_var_struct);

% for every loaded variable
for i = 1:length(loaded_var_names)
    
    % current variable name
    var_name = loaded_var_names{i};
    
    % look for advm variable names
    kAmp    = regexp(var_name,'Cell[0-9][0-9]Amp[0-9]');
    kSNR    = regexp(var_name,'Cell[0-9][0-9]SNR[0-9]');
    kadvm   = any(strcmp(var_name,advm_vars));
    
    % look for master dataset variable names
    kmvar   = any(strcmp(var_name,master_vars));
    
    % if var_name is not any variable that should be kept from the linear
    % model object, match it
    if ~any([kAmp;kSNR;kadvm;kmvar])
        
        % initialize variable observations to nan
%         matched_ds.(var_name) = nan(length(matched_ds),...
        matched_ds.(var_name) = nan(height(matched_ds),...
            size(loaded_var_struct.(var_name).(var_name),2));
        
        % for every observation in the matched dataset
        for j = 1:height(matched_ds)
            
            % find the value and index of the minimum absolute time
            % difference
            [min_time_sn,min_time_index] = ...
                min(abs(matched_ds.DateTime(j) - ...
                loaded_var_struct.(var_name).DateTime));
            
            % if the minimum absolute time is less than than the maximum
            % allowable time then fill the observation value
            if min_time_sn < max_time_sn
                
                matched_ds.(var_name)(j,:) = ...
                    loaded_var_struct.(var_name).(var_name)(min_time_index,:);
                
            end
            
        end
                
    end
    
end

end

