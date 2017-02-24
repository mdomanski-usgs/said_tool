function varargout = said(varargin)
% SAID MATLAB code for said.fig
%      SAID, by itself, creates a new SAID or raises the existing
%      singleton*.
%
%      H = SAID returns the handle to a new SAID or the handle to
%      the existing singleton*.
%
%      SAID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAID.M with the given input arguments.
%
%      SAID('Property','Value',...) creates a new SAID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before said_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to said_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help said

% Last Modified by GUIDE v2.5 15-Jan-2015 08:08:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @said_OpeningFcn, ...
    'gui_OutputFcn',  @said_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

default_install_dir = [getenv('PROGRAMFILES') '\U.S. Geological Survey\said'];

if isdir(default_install_dir)
    CWD = default_install_dir;
else
    CWD = getenv('USERPROFILE');
end


try
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    
catch err
    
    msgbox(['Unexpected error occurred: ' err.identifier],...
        'Unexpected Error',...
        'error');
    
    if isdeployed
            
        [major, minor] = mcrversion;
        errLogFileName = fullfile(CWD,...
            ['SAIDerrorLog' datestr(now,'yyyymmddHHMMSS') '.txt']);
        fid = fopen(errLogFileName,'W');
        fprintf(fid,'SAID v 1.1\n');
        fprintf(fid,['MCR version ' num2str(major) '.' num2str(minor) '\n']);
        fwrite(fid,err.getReport('extended','hyperlinks','off'));
        fclose(fid);
    else
        rethrow(err);
    end
    
end
% End initialization code - DO NOT EDIT


% --- Executes just before said is made visible.
function said_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to said (see VARARGIN)

% Choose default command line output for said
handles.output = hObject;

% initialize the default empty advm parameter structure
advmParamStruct = default_advm_param_struct();

% const_ds = dataset();
const_ds = table();
matched_ds = table();
CWD = getenv('USERPROFILE');

version = '1.1';

% set initial values
setappdata(hObject,'advmParamStruct',advmParamStruct);
setappdata(hObject,'loaded_var_struct',struct);
setappdata(hObject,'CWD',CWD);
setappdata(hObject,'surr_full_file',{});
setappdata(hObject,'const_full_file',{});
setappdata(hObject,'trans_vars',{});
setappdata(hObject,'max_time_min',5);
setappdata(hObject,'bsPlotsFigNum',50);
setappdata(hObject,'const_ds',const_ds);
% setappdata(hObject,'matched_ds',dataset());
setappdata(hObject,'matched_ds',matched_ds);
setappdata(hObject,'ExcludeDates',[]);
setappdata(hObject,'version', version);
setappdata(hObject,'session_name','New');

% set GUI update flag
setappdata(hObject,'UpdateGUI',true);

% Update handles structure
guidata(hObject, handles);

% call gui update function
update(handles);

% UIWAIT makes said wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = said_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in SurrDataSetNames_listbox.
function SurrDataSetNames_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to SurrDataSetNames_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SurrDataSetNames_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SurrDataSetNames_listbox


% --- Executes during object creation, after setting all properties.
function SurrDataSetNames_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SurrDataSetNames_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadTxtData_pushbutton.
function LoadTxtData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadTxtData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% call the function to load surrogate text data and get flag that indicates
% whether or not data was loaded
[data_loaded, advm_data_loaded] = load_surr_text_data(handles);

% if data was loaded
if (data_loaded || advm_data_loaded)
    
    % set the flag to update the processing of the advm data
    setappdata(handles.figure1,'UpdateProc',advm_data_loaded);
    
    % set the flag to update the transformed data
    setappdata(handles.figure1,'UpdateTrans',data_loaded);
    
    % call update function
    update(handles);
    
end


% --- Executes on button press in clearAllData_pushbutton.
function clearAllData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearAllData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% call function to clear surrogate data
clear_surr_data(handles);

% set the flag to update processing
setappdata(handles.figure1,'UpdateProc',true);

% call update function
update(handles);


% --- Executes on selection change in responseVar_popupmenu.
function responseVar_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to responseVar_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns responseVar_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from responseVar_popupmenu

% set the model update flag
setappdata(handles.figure1,'UpdateMDL',true);

% call update function
update(handles);


% --- Executes during object creation, after setting all properties.
function responseVar_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to responseVar_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in viewTable_pushbutton.
function viewTable_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to viewTable_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(getappdata(handles.figure1,'mdl'))
    FigColor = get(handles.figure1,'Color');
    show_obs_table(handles,'color',FigColor);
end


% --- Executes on button press in displayModel_pushbutton.
function displayModel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to displayModel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FigColor = get(handles.figure1,'Color');

if ~isempty(getappdata(handles.figure1,'mdl'));
    show_mdl_disp(handles,FigColor);
end


% --- Executes on button press in writeReport_pushbutton.
function writeReport_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to writeReport_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if the model object variable isn't an empty matrix, write the report
if ~isempty(getappdata(handles.figure1,'mdl'))
    
    % write the report
    write_report(handles);
    
end


% --- Executes on selection change in predictVariables_listbox.
function predictVariables_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to predictVariables_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns predictVariables_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from predictVariables_listbox

% set the update model flag
setappdata(handles.figure1,'UpdateMDL',true);

% call update function
update(handles);


% --- Executes during object creation, after setting all properties.
function predictVariables_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to predictVariables_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxTime_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxTime_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxTime_edit as text
%        str2double(get(hObject,'String')) returns contents of maxTime_edit as a double

% read the current entered value
max_time_min = str2double(get(hObject,'String'));

% set global variable
setappdata(handles.figure1,     'max_time_min',       max_time_min);

% set the match update flag
setappdata(handles.figure1,     'UpdateMatch',   true);

% run update function
update(handles);


% --- Executes during object creation, after setting all properties.
function maxTime_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxTime_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in matchVariable_popupmenu.
function matchVariable_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to matchVariable_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns matchVariable_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from matchVariable_popupmenu

% get the current falue of the popupmenu
dateVarValue = get(hObject,'Value');

% set global variables
setappdata(handles.figure1,     'dateVarValue',  dateVarValue);

% set the match update flag
setappdata(handles.figure1,     'UpdateMatch',   true);

% run update function
update(handles);


% --- Executes during object creation, after setting all properties.
function matchVariable_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matchVariable_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in transformVariable_pushbutton.
function transformVariable_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to transformVariable_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FigColor = get(handles.figure1,'Color');

% get global variables
matched_ds = getappdata(handles.figure1,'matched_ds');
trans_vars = getappdata(handles.figure1,'trans_vars');

% if the matched dataset isn't empty
if ~isempty(matched_ds)
    
    % get the variable to transform from the user
    trans_var = transform_var(matched_ds,'color',FigColor);
    
    % if the user selected a variable to transform
    if ~isempty(trans_var)
        
        % get the new variable name
        trans_var_name = [trans_var{2} trans_var{1}];
        
        if isa(matched_ds, 'dataset')
            var_names = get(matched_ds,'VarNames');
        elseif isa(matched_ds, 'table')
            var_names = matched_ds.Properties.VariableNames;
        end
        
        % if the new variable name isn't already in the matched dataset
        if ~any(strcmp(trans_var_name,var_names))
            
            % add the new transformed variable to the global list of
            % transformations
            trans_vars = [trans_vars; trans_var];
            
            % update global parameters
            setappdata(handles.figure1,'trans_vars',trans_vars);
            setappdata(handles.figure1,'UpdateTrans',true);
            
            % call update function
            update(handles);
            
        end
        
    end
    
end


% --- Executes on button press in ADVMConfiguration_pushbutton.
function ADVMConfiguration_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ADVMConfiguration_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get global variables
oldAdvmParamStruct = getappdata(handles.figure1,'advmParamStruct');

% prompt user for configuration changes
newAdvmParamStruct = editADVMConfig('advmParamStruct',oldAdvmParamStruct);

% if changes were made to the parameter structure
if ~isequal(oldAdvmParamStruct,newAdvmParamStruct)
    
    % update the advm parameter structure
    setappdata(handles.figure1,'advmParamStruct',newAdvmParamStruct);
    
    % set update process flag
    setappdata(handles.figure1,'UpdateProc',true);
    
    % call update function
    update(handles);
    
end



% --- Executes on button press in plots_pushbutton.
function plots_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plots_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get global variables
mdl = getappdata(handles.figure1,'mdl');

% if mdl is actually an object of the linear model class, call the linear
% model plot dialog
if isa(mdl,'LinearModel')
    linearModelPlots(handles.figure1);
end


% --- Executes during object creation, after setting all properties.
function nObservations_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nObservations_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in plotBackScatter_pushbutton.
function plotBackScatter_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotBackScatter_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the backscatter plot figure number to use
bsPlotsFigNum = getappdata(handles.figure1,'bsPlotsFigNum');

% if a model exists
if ~isempty(getappdata(handles.figure1,'mdl'))
    
    % if the figure is already present, bring it to foreground
    if ishandle(bsPlotsFigNum)
        figure(bsPlotsFigNum)
    else
        % otherwise show the backscatter plot figure
        show_BS_profile(handles,'figNum',bsPlotsFigNum);
    end
    
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the backscatter plot figure number
bsPlotsFigNum = getappdata(handles.figure1,'bsPlotsFigNum');

% if the backscatter plots figure is showing, close it
if ishandle(bsPlotsFigNum)
    close(bsPlotsFigNum);
end

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% call save function
said_save(handles);

% call update function
update(handles);

% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% call load function
said_load(handles);

% call update function
update(handles);


% --- Executes on button press in timeSeries_pushbutton.
function timeSeries_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to timeSeries_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get global variables
CWD = getappdata(handles.figure1,'CWD');
advm_param_struct = getappdata(handles.figure1,'advmParamStruct');
trans_vars = getappdata(handles.figure1,'trans_vars');
mdl = getappdata(handles.figure1,'mdl');

% set the filter spec to look for text files
FilterSpec = [CWD '\*.txt'];

% prompt user for file to load
[FileName,PathName,~] = uigetfile(FilterSpec,'MultiSelect','on');

% if filenames and pathname are valid
if (ischar(FileName) || iscell(FileName)) && all(PathName ~= 0)
    
    [EstDS, ResponseName] = pred_const_ts(FileName, PathName, ...
        mdl, advm_param_struct, trans_vars);
    
    % if an estimated dataset is returned
    if ~isempty(EstDS)
        
        % initialize predictor NaN index array
        iEstNaN = false(size(EstDS,1),1);
        
        % for each predictor
        for k = 1:mdl.NumPredictors
            % 'or' the results of the isnan function
            iEstNaN = iEstNaN | isnan(EstDS.(mdl.PredictorNames{k}));
        end
        
        % set the invalid values to NaN so they don't plot
        EstDS(iEstNaN,:) = [];
        
        % plot time series
        figure;
        plot(EstDS.DateTime,EstDS.(ResponseName),'bx');
        hold on;
        %         plot(EstDS.DateTime,EstDS.([ResponseName 'L90']),'k--');
        %         plot(EstDS.DateTime,EstDS.([ResponseName 'U90']),'k--');
        plot(EstDS.DateTime,EstDS.([ResponseName 'L90']),...
            'LineStyle','none',...
            'Marker','.',...
            'MarkerSize',3,...
            'MarkerEdgeColor',[0.5 0.5 0.5]);
        plot(EstDS.DateTime,EstDS.([ResponseName 'U90']),...
            'LineStyle','none',...
            'Marker','.',...
            'MarkerSize',3,...
            'MarkerEdgeColor',[0.5 0.5 0.5]);
        datetick('x');
        xlabel('Date/time of prediction');
        ylabel(['Predicted ' ResponseName], 'interpreter','none');
        
        EstDS.DateTime = datestr(EstDS.DateTime,'mm/dd/yyyy HH:MM:SS');
        
        % get a file name to write the predicted dataset to
        [FileName,PathName]=uiputfile([getappdata(handles.figure1,'CWD') '\*.txt']);
        
        % if the file name is valid, write the time series to a
        % tab-delimited file
        % EstDS = table2dataset(EstDS);
        if FileName ~= 0
            export(EstDS,'file',fullfile(PathName,FileName),'Delimiter','\t');
        end
        
    end
    
end


% --- Executes on button press in LoadArgData_pushbutton.
function LoadArgData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadArgData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CWD = getappdata(handles.figure1,'CWD');

argFnames = get_arg_fnames(CWD);

% call function to load argonaut data and get data loaded flag
data_loaded = load_arg_data(argFnames, handles);

% if argonaut data was loaded
if data_loaded
    
    % set the update process flag
    setappdata(handles.figure1,'UpdateProc',true);
    
    % call update function
    update(handles);
    
end


function ConstDataSetName_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ConstDataSetName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ConstDataSetName_edit as text
%        str2double(get(hObject,'String')) returns contents of ConstDataSetName_edit as a double


% --- Executes during object creation, after setting all properties.
function ConstDataSetName_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConstDataSetName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadConstData_pushbutton.
function LoadConstData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadConstData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the current working directory
CWD = getappdata(handles.figure1,'CWD');

% set the filter spec to look for text files
FilterSpec = [CWD '\*.txt'];

% prompt user for file to load
[FileName,PathName,~] = uigetfile(FilterSpec);

% put together the path and file names
ConstDSName = fullfile(PathName,FileName);

% call function to load constituent data and get data loaded flag
data_loaded = load_const_text_data(ConstDSName, handles);

% const_ds = getappdata(handles.figure1,'const_ds');

% const_var_names = get(const_ds,'VarNames');
% const_var_names = const_ds.Properties.VariableNames;


% if data was loaded
if data_loaded
    
    % set the update transform function
    setappdata(handles.figure1,'UpdateTrans',true);
    
    % call update function
    update(handles);
    
end


% --- Executes on button press in SAIDNew_pushbutton.
function SAIDNew_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SAIDNew_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the default advm parameter structure
advmParamStruct = default_advm_param_struct();

matched_ds = table();

% clear global variables and set to default values
setappdata(handles.figure1,'matched_ds',matched_ds);
setappdata(handles.figure1,'advmParamStruct',advmParamStruct);
setappdata(handles.figure1,'max_time_min', 5);
setappdata(handles.figure1,'trans_vars',{});
setappdata(handles.figure1,'session_name','New');

% clear surrogate and constituent data
clear_surr_data(handles);
clear_const_data(handles);

% call update function
update(handles);

% --- Executes on button press in SAIDSave_pushbutton.
function SAIDSave_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SAIDSave_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% call save function
said_save(handles);

% call update function
update(handles);

% --- Executes on button press in SAIDLoad_pushbutton.
function SAIDLoad_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SAIDLoad_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the current working directory
CWD = getappdata(handles.figure1,'CWD');

% prompt user to select a mat file to load
[saidStateMat,PathName] = uigetfile(fullfile(CWD,'*.mat'));

% get the full file name
saidStateFullFile = fullfile(PathName,saidStateMat);

% call load function
said_load(handles,saidStateFullFile);

% call update function
update(handles);

% set the current working directory to the path name chosen by the user
setappdata(handles.figure1,'CWD',PathName);

% --- Executes on button press in SAIDExit_pushbutton.
function SAIDExit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SAIDExit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

% --- Executes on button press in ADVMProcessing_pushbutton.
function ADVMProcessing_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ADVMProcessing_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the current advm parameter structure
oldAdvmParamStruct = getappdata(handles.figure1,'advmParamStruct');

% prompt user to make changes to the advm parameter structure
newAdvmParamStruct = editADVMProc('advmParamStruct',oldAdvmParamStruct);

% if changes were made
if ~isequal(oldAdvmParamStruct,newAdvmParamStruct)
    
    % set the global structure to the updated structure
    setappdata(handles.figure1,'advmParamStruct',newAdvmParamStruct);
    
    % set update process flag
    setappdata(handles.figure1,'UpdateProc',true);
    
    % call update function
    update(handles);
    
end

% --- Executes during object creation, after setting all properties.
function SAIDSave_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SAIDSave_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
