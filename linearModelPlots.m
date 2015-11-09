function varargout = linearModelPlots(varargin)
%LINEARMODELPLOTS M-file for linearModelPlots.fig
%      LINEARMODELPLOTS, by itself, creates a new LINEARMODELPLOTS or raises the existing
%      singleton*.
%
%      H = LINEARMODELPLOTS returns the handle to a new LINEARMODELPLOTS or the handle to
%      the existing singleton*.
%
%      LINEARMODELPLOTS('Property','Value',...) creates a new LINEARMODELPLOTS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to linearModelPlots_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LINEARMODELPLOTS('CALLBACK') and LINEARMODELPLOTS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LINEARMODELPLOTS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help linearModelPlots

% Last Modified by GUIDE v2.5 10-Apr-2015 15:56:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @linearModelPlots_OpeningFcn, ...
    'gui_OutputFcn',  @linearModelPlots_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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

end


% --- Executes just before linearModelPlots is made visible.
function linearModelPlots_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

if ishghandle(varargin{1})
    saidFigh = varargin{1};
    mdl = getappdata(saidFigh,'mdl');
end

if isa(mdl,'LinearModel')
    
    % create plots figure handle structure
    plts = struct(...
        'mdlscatter',   figure('visible','off'),...
        'LinearScale',  figure('visible','off'),...
        'WhlMdlAV',     figure('visible','off'),...
        'ExVarCmp',     figure('visible','off'),...
        'PredVsObs',    figure('visible','off'),...
        'PredVsObsLin', figure('visible','off'),...
        'ResRawVsFit',  figure('visible','off'),...
        'ResProb',      figure('visible','off'),...
        'StanSerCorr',  figure('visible','off'),...
        'ResVsTime',    figure('visible','off') ...
        );
    
    structfun(@close,plts);
    
    % set plts structure
    setappdata(handles.figure1,'plts',plts);
    
    % set the global mdl variable to the model
    setappdata(handles.figure1,'mdl',mdl);
    
    setappdata(handles.figure1,'saidFigh',saidFigh);
    
    % Choose default command line output for linearModelPlots
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Set waiting flag in appdata
    setappdata(handles.figure1,'waitstatus','waiting')
    % UIWAIT makes linearModelPlots wait for user response (see UIRESUME)
    uiwait(handles.figure1);
else
    disp('linearModelPlots: mdl is not of the class ''LinearModel''');
end

end

% --- Outputs from this function are returned to the command line.
function varargout = linearModelPlots_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = [];

delete(hObject);

end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plts = getappdata(handles.figure1,'plts');

pltsFieldNames = fieldnames(plts);

for k = 1:length(pltsFieldNames)
    if ishandle(plts.(pltsFieldNames{k}))
        close(plts.(pltsFieldNames{k}));
    end
end

% Hint: delete(hObject) closes the figure
% delete(hObject);
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

end

% --- Executes on button press in rawVsFitted_pushbutton.
function rawVsFitted_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rawVsFitted_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the plot handle structure
plts = getappdata(handles.figure1,'plts');

% get the model object
mdl = getappdata(handles.figure1,'mdl');

% if the model variable isn't an empty matrix
if ~isempty(mdl)
    
    % create figure, or make it the current
    figure(plts.ResRawVsFit);
    
    % call LinearModel residual plot function
    plotResiduals(mdl,'fitted');
    
    % update the plot handle structure
    setappdata(handles.figure1,'plts',plts);
    
end

end

% --- Executes on button press in probability_pushbutton.
function probability_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to probability_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the plot figure handle structure
plts = getappdata(handles.figure1,'plts');

% get the model object
mdl = getappdata(handles.figure1,'mdl');

% if the model object isn't an empty matrix
if ~isempty(mdl)
    
    % create figure, or make it the current
    figure(plts.ResProb);
    
    % call LinearModel plot function
    plotResiduals(mdl,'probability');
    
    % update plots handle structure
    setappdata(handles.figure1,'plts',plts);
    
end

end

% --- Executes on button press in StanSerCorr_pushbutton.
function StanSerCorr_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StanSerCorr_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the plot figure handle structure
plts = getappdata(handles.figure1,'plts');

% date/time variable name
dateVarName = 'DateTime';

% get the model object
mdl = getappdata(handles.figure1,'mdl');

% if the model object isn't an empty matrix
if ~isempty(mdl)
    
    % create figure, or make it the current
    figure(plts.StanSerCorr);
    
    % call the standardized serial correlation plot
    plotStanSerialCorr(mdl,dateVarName,plts.StanSerCorr);
    
    % update the plot handle structure
    setappdata(handles.figure1,'plts',plts);
    
end

end

% --- Executes on button press in modelScatter_pushbutton.
function modelScatter_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to modelScatter_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the plot handle structure
plts = getappdata(handles.figure1,'plts');

% get the LinearModel object
mdl = getappdata(handles.figure1,'mdl');

% if the number of predictors is one (a simple linear regression), show
% the default LinearModel plot, and plot it in linear space if it's
% transformed
if mdl.NumPredictors == 1
    
    % create figure, or make it current
    figure(plts.mdlscatter);
    
    % call LinearModel plot function
    plot(mdl);
    
    % if the response variable is tranformed
    if ~isempty(strfind(mdl.ResponseName,'log10')==1) || ...
            ~isempty(strfind(mdl.ResponseName,'ln')==1) || ...
            ~isempty(strfind(mdl.ResponseName,'pow')==1) || ...
            ~isempty(strfind(mdl.ResponseName,'root')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'log10')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'ln')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'pow')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'root')==1)
        
        % create figure, or make it current
        figure(plts.LinearScale);
        
        % show the model in linear space
        plotLinearScale(mdl);
        
    end
    
    % otherwise, show added variable plots
else
    
    % for each predictor variable
    for k = 1:mdl.NumPredictors
        
        % get the figure numbers from the plot handle structure
        c = struct2cell(plts);
        
        % find the current maximum figure number
        MaxFigNum = max(cell2mat(c));
        
        % get the predictor name
        PredictorName = mdl.PredictorNames{k};
        
        % create field for plots structure
        pltName = [PredictorName 'AV'];
        
        % if the figure doesn't exist, create it, and increment the
        % figure numbers
        if ~isfield(plts,pltName)
            PltFigNum = MaxFigNum+1;
            plts.(pltName) = PltFigNum;
        end
        
        % create a figure to show plot
        figure(plts.(pltName));
        
        % call LinearModel plotting function
        plotPartialResiduals(mdl,PredictorName,plts.(pltName));
        
    end
    
end

% update the plot handle structure
setappdata(handles.figure1,'plts',plts);

end

% --- Executes on button press in predVsObs_pushbutton.
function predVsObs_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to predVsObs_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the plot handle structure
plts = getappdata(handles.figure1,'plts');

% get the model object
mdl = getappdata(handles.figure1,'mdl');

% if the model variable isn't an empty matrix
if ~isempty(mdl)
    
    % create figure, or make it current
    h = figure(plts.PredVsObs);
    
    % plot the predicted against the observed response values
    plotPredVsObs(mdl,h);
    
    % if the response variable is tranformed
    if ~isempty(strfind(mdl.ResponseName,'log10')==1) || ...
            ~isempty(strfind(mdl.ResponseName,'ln')==1) || ...
            ~isempty(strfind(mdl.ResponseName,'pow')==1) || ...
            ~isempty(strfind(mdl.ResponseName,'root')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'log10')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'ln')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'pow')==1) || ...
            ~isempty(strfind(mdl.PredictorNames{1},'root')==1)
        
        % create figure, or make it current
        h = figure(plts.PredVsObsLin);
        
        % show the model in linear space
        plotPredVsObsLin(mdl,h);
        
    end
    
    % update the plot handle structure
    setappdata(handles.figure1,'plts',plts);
    
end

end


% --- Executes on button press in vsTime_pushbutton.
function vsTime_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to vsTime_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get global variables
mdl = getappdata(handles.figure1,'mdl');
plts = getappdata(handles.figure1,'plts');

% date/time index variable
dateVarName = 'DateTime';

% if the model isn't empty
if ~isempty(mdl)
    
    % get figure number to plot
    h = figure(plts.ResVsTime);
    
    % plot residuals vs. time
    plotResVsTime(mdl,dateVarName,h);
    
end

end

%%%%%% plotting functions

function plotLinearScale(mdl)

% make sure that the LinearModel is a simple linear regression
if length(mdl.PredictorNames) > 1
    error('said:plotLinearScale',...
        'plotLinearScale works for SLR models only');
end

if strfind(mdl.ResponseName,'log10')==1
    ResponseName = strrep(mdl.ResponseName,'log10','');
    f_inv = @(x) 10.^x;
elseif strfind(mdl.ResponseName,'ln')==1
    ResponseName = mdl.ResponseName(3:end);
    f_inv = @(x) exp(x);
elseif strfind(mdl.ResponseName,'pow')==1
    powerValue = str2double(mdl.ResponseName(4));
    ResponseName = mdl.ResponseName(5:end);
    f_inv = @(x) nthroot(x,powerValue);
elseif strfind(mdl.ResponseName,'root')==1
    rootValue = str2double(mdl.ResponseName(5));
    ResponseName = mdl.ResponseName(6:end);
    f_inv = @(x) power(x,rootValue);
else
    ResponseName = mdl.ResponseName;
    f_inv = @(x) x;
end



if strfind(mdl.PredictorNames{1},'log10')==1
    PredictorName = strrep(mdl.PredictorNames{1},'log10','');
    f_inv_pred = @(x) 10.^x;
elseif strfind(mdl.PredictorNames{1},'ln')==1
    PredictorName = mdl.PredictorNames{1}(3:end);
    f_inv_pred = @(x) exp(x);
elseif strfind(mdl.PredictorNames{1},'pow')==1
    powerValue = str2double(mdl.ResponseName(4));
    PredictorName = mdl.PredictorNames{1}(5:end);
    f_inv_pred = @(x) nthroot(x,powerValue);
elseif strfind(mdl.PredictorNames{1},'root')==1
    rootValue = str2double(mdl.PredictorNames{1}(5));
    PredictorName = mdl.PredictorNames{1}(6:end);
    f_inv_pred = @(x) power(x,rootValue);
else
    PredictorName = mdl.PredictorNames{1};
    f_inv_pred = @(x) x;
end


% get the plotting range
minPred = min(mdl.Variables.(mdl.PredictorNames{1}));
maxPred = max(mdl.Variables.(mdl.PredictorNames{1}));

% create a dataset for the predictor plot values
xDS = dataset({linspace(minPred,maxPred)',mdl.PredictorNames{1}});
xDS = dataset2table(xDS);

% get the observed predictor variable values
XObs = f_inv_pred(mdl.Variables.(mdl.PredictorNames{1}));

% compute the inverse transform of the response variable values
YObs = f_inv(mdl.Variables.(mdl.ResponseName));

% call smearing function
SmearedLineDS = smear_estimate(mdl,xDS);

% plot the values in linear space
plot(XObs,YObs,'bx');
hold on;
h = plot(SmearedLineDS.(PredictorName),SmearedLineDS.(ResponseName),'r-');
h = [h plot(SmearedLineDS.(PredictorName),SmearedLineDS.([ResponseName 'L90']),'r:')];
h = [h plot(SmearedLineDS.(PredictorName),SmearedLineDS.([ResponseName 'U90']),'r:')];

% from stats\internal.stats.addLabelDataTip
for k = 1:length(h)
    set(h(k),'HitTest','off');
    hB = hggetbehavior(h(k),'datacursor');
    set(hB,'Enable',false);
end

title([ResponseName ' vs. ' PredictorName], 'interpreter','none');

xlabel(PredictorName,'interpreter','none');
ylabel(ResponseName,'interpreter','none');

legend('Data','Fit','Confidence bounds','Location','best');

% create data cursor object
dcm_obj = datacursormode(gcf);

% set the update function of the data cursor
set(dcm_obj,'UpdateFcn',@dcm_updatefcn);

    function txt = dcm_updatefcn(~,event_obj)
        
        % get the target of the data cursor selection
        Target = get(event_obj,'Target');
        
        % if the line is not selected
        if ~strcmp(get(Target,'LineStyle'),'-')
            
            % get the position of the selection
            pos = get(event_obj,'Position');
            
            % get the data index
            DI = get(event_obj,'DataIndex');
            
            % set the returned text to indicate observation number and
            % position
            txt = {...
                ['Observation: ', num2str(DI)],...
                ['X: ', num2str(pos(1))],...
                ['Y: ', num2str(pos(2))]
                };
            
        else
            
            % otherwise, return an empty string to display
            txt = {''};
            
        end
        
    end

end % plotLinearScale


function h = plotPartialResiduals(mdl,PredictorVariableName,varargin)

if length(varargin) == 1
    h = varargin{1};
else
    h = figure;
end

% get index of observations that are included in the model
iObs = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

% get the model dataset
mdlDS = mdl.Variables;

% number of coeffients and observations
p = mdl.NumCoefficients;
n = mdl.NumObservations;

% observation number array
% ObsNumber = (1:length(mdlDS))';
ObsNumber = (1:height(mdlDS))';
ObsNumber(~iObs) = [];

% y variable from the dataset
y = mdlDS.(mdl.ResponseName);
y(~iObs) = [];

% initialize empty X matrix from model
% fullmodelX = [ ones(n,1) double(mdlDS(iObs , mdl.VariableInfo.InModel')) ];
fullmodelX = [ ones(n,1) table2array(mdlDS(iObs , mdl.VariableInfo.InModel')) ];

% find the column of the predictor variable
i = find(strcmp(PredictorVariableName,mdl.PredictorNames))+1;

% get the predictor observations
x = fullmodelX(:,i);

% the rest of predictor observations
X = fullmodelX(:,[1:i-1 i+1:p]);

% coefficient estimates
betax = (X'*X)^-1*X'*x;
betay = (X'*X)^-1*X'*y;

% partial residuals
r = y - X*betay;
xr = x - X*betax;

% fit line to plot
P = polyfit(xr,r,1);
yplot = polyval(P,xr);

% plot partial residuals
plot(xr,r,'bx');
hold on;

% plot fit line
[minxr,minI] = min(xr);
[maxxr,maxI] = max(xr);
minyplot = yplot(minI);
maxyplot = yplot(maxI);
a = plot([minxr maxxr] ,[minyplot maxyplot],'r-');

set(a,'HitTest','off');
hB = hggetbehavior(a,'datacursor');
set(hB,'Enable',false);

xlabel(['Adjusted ' mdl.PredictorNames{i-1}]);
ylabel('Partial residual');
title(['Partial residual plot for ' mdl.PredictorNames{i-1}]);

legend('Adjusted data',['Fit: y=' num2str(P(1)) 'x'],'location','best');

% create data cursor object
dcm_obj = datacursormode(gcf);

% set the update function of the data cursor
set(dcm_obj,'UpdateFcn',@dcm_updatefcn);

    function txt = dcm_updatefcn(~,event_obj)
        
        % get the target of the data cursor selection
        Target = get(event_obj,'Target');
        
        % if the line is not selected
        if ~strcmp(get(Target,'LineStyle'),'-')
            
            % get the position of the selection
            pos = get(event_obj,'Position');
            
            % get the data index
            DI = get(event_obj,'DataIndex');
            
            % set the returned text to indicate observation number and
            % position
            txt = {...
                ['Observation: ', num2str(ObsNumber(DI))],...
                ['X: ', num2str(pos(1))],...
                ['Y: ', num2str(pos(2))]
                };
            
        else
            
            % otherwise, return an empty string to display
            txt = {''};
            
        end
        
    end

end % plotPartialResiduals


function h = plotPredVsObs(mdl,varargin)

if nargin > 1
    if ishandle(varargin{1})
        h = varargin{1};
        figure(h);
    else
        h = figure;
    end
else
    h = figure;
end

% index of observations included in the model
iIncluded = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

% observation numbers
% ObsNums = 1:length(mdl.Variables);
ObsNums = 1:height(mdl.Variables); % changed for 2014a - MMD 20151015
ObsNums = ObsNums(iIncluded);

% get the fitted response values
YPred = mdl.Fitted(iIncluded);

% get the observed response values
YObs = mdl.Variables.(mdl.ResponseName)(iIncluded);

% plot the predicted values against the observed values
plot(YObs,YPred,'bx');
hold on;

XLim = get(gca,'XLim');
YLim = get(gca,'YLim');

set(gca,'XLim',XLim,'YLim',YLim);

% plot the 1:1 line
h = plot(XLim,XLim,'k-');
set(h,'HitTest','off');
hB = hggetbehavior(h,'datacursor');
set(hB,'Enable',false);

title('Predicted vs. Observed');
xlabel(['Observed ' mdl.ResponseName],'interpreter','none');
ylabel(['Predicted ' mdl.ResponseName],'interpreter','none');

legend('Data','1:1 line','location','best');

% create and set up data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@dcm_updatefcn);

    function txt = dcm_updatefcn(~,event_obj)
        
        % get the event object target
        Target = get(event_obj,'Target');
        
        % if the target is not a line
        if ~strcmp(get(Target,'LineStyle'),'-')
            
            % get the position and data index of the target
            pos = get(event_obj,'Position');
            DI = get(event_obj,'DataIndex');
            
            % create text to return
            txt = {...
                ['Observation: ', num2str(ObsNums(DI))],...
                ['Observed: ', num2str(pos(1))],...
                ['Predicted: ', num2str(pos(2))]
                };
            
        else
            
            txt = {''};
            
        end
        
    end

end % plotPredVsObs


function h = plotPredVsObsLin(mdl,varargin)

if nargin > 1
    if ishandle(varargin{1})
        h = varargin{1};
        figure(h);
    else
        h = figure;
    end
else
    h = figure;
end

% mdlVariables = table2dataset(mdl.Variables);

if strfind(mdl.ResponseName,'log10')==1
    ResponseName = strrep(mdl.ResponseName,'log10','');
    f_inv = @(x) 10.^x;
elseif strfind(mdl.ResponseName,'ln')==1
    ResponseName = mdl.ResponseName(3:end);
    f_inv = @(x) exp(x);
elseif strfind(mdl.ResponseName,'pow')==1
    powerValue = str2double(mdl.ResponseName(4));
    ResponseName = mdl.ResponseName(5:end);
    f_inv = @(x) nthroot(x,powerValue);
elseif strfind(mdl.ResponseName,'root')==1
    rootValue = str2double(mdl.ResponseName(5));
    ResponseName = mdl.ResponseName(6:end);
    f_inv = @(x) power(x,rootValue);
else
    ResponseName = mdl.ResponseName;
    f_inv = @(x) x;
end

% index of observations included in the model
iIncluded = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

% call smearing function
SmearedLineDS = smear_estimate(mdl,mdl.Variables);
% SmearedLineDS = smear_estimate(mdl,mdlVariables);

% observation numbers
ObsNums = 1:height(mdl.Variables); % changed for 2014a - MMD 20151015
ObsNums = ObsNums(iIncluded);

% get the fitted response values
YPred = SmearedLineDS.(ResponseName)(iIncluded);

% get the observed response values
% YObs = f_inv(mdlVariables.(mdl.ResponseName)(iIncluded));
YObs = f_inv(mdl.Variables.(mdl.ResponseName)(iIncluded));

% plot the predicted values against the observed values
plot(YObs,YPred,'bx');
hold on;

XLim = get(gca,'XLim');
YLim = get(gca,'YLim');

set(gca,'XLim',XLim,'YLim',YLim);

% plot the 1:1 line
h = plot(XLim,XLim,'k-');
set(h,'HitTest','off');
hB = hggetbehavior(h,'datacursor');
set(hB,'Enable',false);

title('Predicted vs. Observed');
xlabel(['Observed ' ResponseName],'interpreter','none');
ylabel(['Predicted ' ResponseName],'interpreter','none');

legend('Data','1:1 line','location','best');

% create and set up data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@dcm_updatefcn);

    function txt = dcm_updatefcn(~,event_obj)
        
        % get the event object target
        Target = get(event_obj,'Target');
        
        % if the target is not a line
        if ~strcmp(get(Target,'LineStyle'),'-')
            
            % get the position and data index of the target
            pos = get(event_obj,'Position');
            DI = get(event_obj,'DataIndex');
            
            % create text to return
            txt = {...
                ['Observation: ', num2str(ObsNums(DI))],...
                ['Observed: ', num2str(pos(1))],...
                ['Predicted: ', num2str(pos(2))]
                };
            
        else
            
            txt = {''};
            
        end
        
    end

end % plotPredVsObsLin


function h = plotResVsTime(mdl,dateVarName,varargin)

if nargin > 2
    if ishandle(varargin{1})
        h = varargin{1};
        figure(h);
    else
        h = figure;
    end
else
    h = figure;
end

mdlVariables = table2dataset(mdl.Variables);

% date/time variable to plot residuals against
ResTime = mdlVariables.(dateVarName);

% raw residuals
RawRes = mdl.Residuals.Raw;

% plot the raw residuals against time
% figure;
plot(ResTime,RawRes,'bx');
hold on;

% set the date tick on the x axis
% datetick('x','mm/dd HH:MM','keeplimits','keepticks');
datetick('x');

% x axis limits
XLim = get(gca,'XLim');

% plot zero line
h = plot(XLim,[0 0],'k:');
set(h,'HitTest','off');
hB = hggetbehavior(h,'datacursor');
set(hB,'Enable',false);

xlabel('Observation Time');
ylabel('Residual');
title('Plot of residual vs. time');

dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@dcm_updatefcn);

    function txt = dcm_updatefcn(~,event_obj)
        
        % get the target of the data cursor selection
        Target = get(event_obj,'Target');
        
        % if the line is not selected        
        if ~strcmp(get(Target,'LineStyle'),'-')

            % get the position of the selection
            pos = get(event_obj,'Position');
            
            % get the data index            
            DI = get(event_obj,'DataIndex');

            % set the returned text to indicate observation number and
            % position
            txt = {...
                ['Observation: ', num2str(DI)],...
                ['Time: ', datestr(pos(1),'mm/dd/yyyy HH:MM')],...
                ['Residual: ', num2str(pos(2))]
                };
            
        else

            % otherwise, return an empty string to display            
            txt = {''};
            
        end
        
    end
end % plotResVsTime


function h = plotStanSerialCorr(mdl,dateVarName,varargin)

if nargin > 2
    if ishandle(varargin{1})
        h = varargin{1};
        figure(h);
    else
        h = figure;
    end
else
    h = figure;
end

% raw residuals
RawRes = mdl.Residuals.Raw;

% model time variable
ResTime = mdl.Variables.(dateVarName);

% sort time and residuals by time
[ResTime,IX]=sort(ResTime);
RawRes=RawRes(IX);

% remove invalid values
iNaN = isnan(RawRes);
RawRes(iNaN) = [];
ResTime(iNaN) = [];

% find mean and variance
ResMean = mean(RawRes);
ResVar = var(RawRes);

% create residual matrix
ResMat = repmat(RawRes,1,size(RawRes,1));

% create tau matrix (tau(i,j) = t(i)-t(j))
taumat = bsxfun(@minus,ResTime,ResTime');

% set all values where tau(i,j) <= 0 to NaN
ResMat(taumat<=0) = NaN;
taumat(taumat<=0) = NaN;

% compute the standardized serial correlation
StanSerialCorr = bsxfun(@times,(RawRes-ResMean)',(ResMat-ResMean))/ResVar;

% get the invalid values
iNaN = isnan(taumat);
tau = taumat;

% clear invalid values
tau(iNaN)=[];
StanSerialCorr(iNaN)=[];

[tau,IX]=sort(tau);
StanSerialCorr=StanSerialCorr(IX);

yy = smooth(tau,StanSerialCorr,0.65,'lowess');

plot(tau,StanSerialCorr,'x');
hold on;
XLim = get(gca,'XLim');
h = plot(XLim,[0 0],'k:');
h = [h plot(tau,yy,'k-')];
xlabel('Difference in time, in Days');
ylabel('Standardized serial correlation');
title('Standardized serial correlation Vs. difference in time');

for k = 1:length(h)
    set(h(k),'HitTest','off');
    hB = hggetbehavior(h(k),'datacursor');
    set(hB,'Enable',false);
end

end % plotStanSerialCorr
