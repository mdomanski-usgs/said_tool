function varargout = editADVMConfig(varargin)
% EDITADVMCONFIG MATLAB code for editADVMConfig.fig
%      EDITADVMCONFIG, by itself, creates a new EDITADVMCONFIG or raises the existing
%      singleton*.
%
%      H = EDITADVMCONFIG returns the handle to a new EDITADVMCONFIG or the handle to
%      the existing singleton*.
%
%      EDITADVMCONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITADVMCONFIG.M with the given input arguments.
%
%      EDITADVMCONFIG('Property','Value',...) creates a new EDITADVMCONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before editADVMConfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to editADVMConfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help editADVMConfig

% Last Modified by GUIDE v2.5 24-Jun-2013 15:48:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @editADVMConfig_OpeningFcn, ...
                   'gui_OutputFcn',  @editADVMConfig_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before editADVMConfig is made visible.
function editADVMConfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to editADVMConfig (see VARARGIN)

structFieldNames = {                  ...
        'Frequency',            ...
        'EffectiveDiameter',    ...
        'BeamOrientation',      ...
        'SlantAngle',           ...
        'Nbeams',               ...
        'BlankDistance',        ...
        'CellSize',             ...
        'NumberOfCells',        ...
        'BeamNumber',           ...
        'MovingAverageSpan',    ...
        'BSValues',             ...
        'IntenScale',           ...
        'RMin',                 ...
        'RMax',                 ...
        'MinCells',             ...
        'MinVbeam',             ...
        'NearField',            ...
        'RemoveMinWCB'          ...
        };

BeamOrientation = cellstr(get(handles.beamOrientation_popupmenu,'String'));
% BSValues        = cellstr(get(handles.backscatter_popupmenu,'String'));
% BeamNumber      = cellstr(get(handles.beam_popupmenu,'String'));
    
% attempt to find 'advmParamStruct' in arguments
paramStructInput = find(strcmp(varargin,'advmParamStruct'));

% if 'advmParamStruct' isn't found, the number of arguments isn't long
% enough, paramStructInput+1 isn't a structure, or the structure doesn't
% have the required field names, create a structure with empty values
if isempty(paramStructInput) || ...
        (length(varargin) <= paramStructInput) || ...
        ~isstruct(varargin{paramStructInput+1}) || ...
        ~all(isfield(varargin{paramStructInput+1},structFieldNames))
    
    advmParamStruct = default_advm_param_struct();
    
else
    
    % set advmParamStruct as the input argument
    advmParamStruct = varargin{paramStructInput+1};
    
    % set NaNs as an empty matrix
    for k = 1:length(structFieldNames)
        if any(isnan(advmParamStruct.(structFieldNames{k})))
            advmParamStruct.(structFieldNames{k}) = [];
        end
    end
    
    % set the uicontrol properties
    set(handles.freq_edit,...
        'String',   advmParamStruct.Frequency);
    set(handles.transDiameter_edit,...
        'String',   advmParamStruct.EffectiveDiameter);
    set(handles.beamOrientation_popupmenu,...
        'Value',    ...
        find(strcmp(advmParamStruct.BeamOrientation,BeamOrientation)));
    set(handles.slantAngle_edit,...
        'String',   advmParamStruct.SlantAngle);
    set(handles.Nbeams_edit,...
        'String',   advmParamStruct.Nbeams);
    set(handles.blankingDistance_edit,...
        'String',   advmParamStruct.BlankDistance);
    set(handles.cellSize_edit,...
        'String',   advmParamStruct.CellSize);
    set(handles.numCells_edit,...
        'String',   advmParamStruct.NumberOfCells);
    
    setappdata(handles.figure1,'inputStruct',advmParamStruct);
    
end


% Choose default command line output for editADVMConfig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(hObject,'advmParamStruct',advmParamStruct);
setappdata(hObject,'saveStruct',false);

% UIWAIT makes editADVMConfig wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = editADVMConfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

advmParamStruct = getappdata(hObject,'advmParamStruct');
inputStruct     = getappdata(hObject,'inputStruct');

saveStruct      = getappdata(hObject,'saveStruct');

structFieldNames = fieldnames(advmParamStruct);

for k = 1:length(structFieldNames)
    if any(isnan(advmParamStruct.(structFieldNames{k})))
        advmParamStruct.(structFieldNames{k}) = [];
    end
end

if saveStruct

    outputStruct = advmParamStruct;
    
else
    
    outputStruct = inputStruct;

end

varargout{1} = outputStruct;

delete(hObject);



function freq_edit_Callback(hObject, eventdata, handles)
% hObject    handle to freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq_edit as text
%        str2double(get(hObject,'String')) returns contents of freq_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.Frequency = str2double(get(hObject,'String'));

% default transducer radius based on sontek argonaut sl advms
% % at - transducer radius (m)
% if advmParamStruct.Frequency == 3000 % 3000 kHz SL and SW
%     advmParamStruct.EffectiveDiameter = 0.015;
% elseif advmParamStruct.Frequency == 1500 % 1500 kHz SL
%     advmParamStruct.EffectiveDiameter = 0.030;
% elseif advmParamStruct.Frequency == 500 % 500 kHz SL
%     advmParamStruct.EffectiveDiameter = 0.090;
% elseif isnan(advmParamStruct.Frequency)
%     advmParamStruct.EffectiveDiameter = [];
% end

set(handles.transDiameter_edit,'String',advmParamStruct.EffectiveDiameter);

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function freq_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function transDiameter_edit_Callback(hObject, eventdata, handles)
% hObject    handle to transDiameter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of transDiameter_edit as text
%        str2double(get(hObject,'String')) returns contents of transDiameter_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.EffectiveDiameter = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);


% --- Executes during object creation, after setting all properties.
function transDiameter_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transDiameter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slantAngle_edit_Callback(hObject, eventdata, handles)
% hObject    handle to slantAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slantAngle_edit as text
%        str2double(get(hObject,'String')) returns contents of slantAngle_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.SlantAngle = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function slantAngle_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slantAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Nbeams_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Nbeams_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nbeams_edit as text
%        str2double(get(hObject,'String')) returns contents of Nbeams_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.Nbeams = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function Nbeams_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nbeams_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function blankingDistance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to blankingDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blankingDistance_edit as text
%        str2double(get(hObject,'String')) returns contents of blankingDistance_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.BlankDistance = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function blankingDistance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blankingDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cellSize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cellSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellSize_edit as text
%        str2double(get(hObject,'String')) returns contents of cellSize_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.CellSize = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function cellSize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numCells_edit_Callback(hObject, eventdata, handles)
% hObject    handle to numCells_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numCells_edit as text
%        str2double(get(hObject,'String')) returns contents of numCells_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.NumberOfCells = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function numCells_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numCells_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function movAvgSpan_edit_Callback(hObject, eventdata, handles)
% hObject    handle to movAvgSpan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of movAvgSpan_edit as text
%        str2double(get(hObject,'String')) returns contents of movAvgSpan_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

MovingAverageSpan = floor(str2double(get(hObject,'String')));

if MovingAverageSpan <= 0 || isnan(MovingAverageSpan)
    MovingAverageSpan = 1;
end

% force span to be odd
MovingAverageSpan = MovingAverageSpan-1+mod(MovingAverageSpan,2);

set(hObject,'String',num2str(MovingAverageSpan));

advmParamStruct.MovingAverageSpan = MovingAverageSpan;

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);


% --- Executes during object creation, after setting all properties.
function movAvgSpan_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movAvgSpan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function intenScaleFactor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to intenScaleFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intenScaleFactor_edit as text
%        str2double(get(hObject,'String')) returns contents of intenScaleFactor_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

IntenScale = str2double(get(hObject,'String'));

if isempty(IntenScale)
    IntenScale = NaN;
end

advmParamStruct.IntenScale = IntenScale;

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function intenScaleFactor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intenScaleFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minCellMidPoint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to minCellMidPoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minCellMidPoint_edit as text
%        str2double(get(hObject,'String')) returns contents of minCellMidPoint_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.RMin = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function minCellMidPoint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minCellMidPoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxCellMidPoint_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxCellMidPoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxCellMidPoint_edit as text
%        str2double(get(hObject,'String')) returns contents of maxCellMidPoint_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.RMax = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function maxCellMidPoint_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxCellMidPoint_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minNumCells_edit_Callback(hObject, eventdata, handles)
% hObject    handle to minNumCells_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minNumCells_edit as text
%        str2double(get(hObject,'String')) returns contents of minNumCells_edit as a double


% --- Executes during object creation, after setting all properties.
function minNumCells_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minNumCells_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in backscatter_popupmenu.
function backscatter_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to backscatter_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns backscatter_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from backscatter_popupmenu

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

contents = cellstr(get(hObject,'String'));

advmParamStruct.BSValues = contents{get(hObject,'Value')};

if strcmp(advmParamStruct.BSValues,'SNR')
    set(handles.intenScaleFactor_text,'enable','off');
    set(handles.intenScaleFactor_edit,...
        'enable','off',...
        'String','');
    if isempty(advmParamStruct.IntenScale) || ...
            isnan(advmParamStruct.IntenScale)
        advmParamStruct.IntenScale = 0.43;
    end
elseif strcmp(advmParamStruct.BSValues,'Amp')
    set(handles.intenScaleFactor_text,'enable','on');
    set(handles.intenScaleFactor_edit,...
        'enable','on',...
        'String',advmParamStruct.IntenScale);
end

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function backscatter_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backscatter_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minVbeam_edit_Callback(hObject, eventdata, handles)
% hObject    handle to minVbeam_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minVbeam_edit as text
%        str2double(get(hObject,'String')) returns contents of minVbeam_edit as a double

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.MinVbeam = str2double(get(hObject,'String'));

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);


% --- Executes during object creation, after setting all properties.
function minVbeam_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minVbeam_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nearField_checkbox.
function nearField_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to nearField_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nearField_checkbox

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.NearField = get(hObject,'Value');

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);


% --- Executes on selection change in minCells_popupmenu.
function minCells_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to minCells_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns minCells_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from minCells_popupmenu

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

contents = cellstr(get(hObject,'String'));

advmParamStruct.MinCells = str2double(contents{get(hObject,'Value')});

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function minCells_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minCells_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotBackscatter_pushbutton.
function plotBackscatter_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotBackscatter_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plotBeam_pushbutton.
function plotBeam_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotBeam_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in beamOrientation_popupmenu.
function beamOrientation_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to beamOrientation_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns beamOrientation_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from beamOrientation_popupmenu

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

contents = cellstr(get(hObject,'String'));

advmParamStruct.BeamOrientation = contents{get(hObject,'Value')};

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function beamOrientation_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamOrientation_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set the save structure flag
setappdata(handles.figure1,'saveStruct',true);

close(handles.figure1);


% --- Executes on button press in cancel_pushbutton.
function cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% clear the save structure flag
setappdata(handles.figure1,'saveStruct',false);

% close the figure
close(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% delete(hObject);
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end


% --- Executes on selection change in beam_popupmenu.
function beam_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to beam_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns beam_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from beam_popupmenu

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

contents = cellstr(get(hObject,'String'));

advmParamStruct.BeamNumber = contents{get(hObject,'Value')};

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);

% --- Executes during object creation, after setting all properties.
function beam_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beam_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in removeMinWCB_checkbox.
function removeMinWCB_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to removeMinWCB_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of removeMinWCB_checkbox

advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

advmParamStruct.RemoveMinWCB = get(hObject,'Value');

setappdata(handles.figure1,'advmParamStruct',advmParamStruct);
