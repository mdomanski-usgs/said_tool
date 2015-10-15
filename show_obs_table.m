function show_obs_table(handles,varargin)

p = inputParser;
defaultColor = [0.8 0.8 0.8];

addOptional(p,'color',defaultColor,@(x) (length(x)==3));

parse(p,varargin{:});

FigColor = p.Results.color;

% name of primary date and time
DateTimeVar = 'DateTime';

% get the model object
mdl = getappdata(handles.figure1,'mdl');

% call function to create table data structure
TableData = get_mdl_tbl(mdl,DateTimeVar);

% mainFigPos = get(handles.figure1,'Position');
ScreenSize = get(0,'ScreenSize');

% get figure position width
FigPosW = 1.15*sum(cell2mat(TableData.ColumnWidth))/ScreenSize(3);

% if the width is greater than 95 percent of the screen, set it to 95
% percent
if FigPosW > 0.95
    FigPosW = 0.95;
end

% compute figure dimensions
FigPosH = 400/ScreenSize(4); % figure height
FigPosX = 0.5-FigPosW/2;    % figure x position
FigPosY = 0.5-FigPosH/2;    % figure y position

% create figure position array
FigPos = [FigPosX FigPosY FigPosW FigPosH];

% number of pushbuttons
Npb = 2;

% pushbutton dimensions
pushbuttonW     = 130;
pushbuttonH     = 30;
pushbuttonSpc   = 30;    % pushbutton spacing
pushbutton1X    = FigPos(3)*ScreenSize(3)/Npb - (pushbuttonSpc/2 + pushbuttonW);
pushbutton1Y    = 0.5*(0.20*FigPos(4)*ScreenSize(4)-pushbuttonH);
pushbutton2X    = pushbutton1X + pushbuttonW + pushbuttonSpc;
pushbutton2Y    = pushbutton1Y;
pushbutton1Pos  = [pushbutton1X pushbutton1Y pushbuttonW pushbuttonH];
pushbutton2Pos  = [pushbutton2X pushbutton2Y pushbuttonW pushbuttonH];

% create observation table figure
h = figure(...
    'Units',        'normalized',...
    'Position',     FigPos,...
    'Menubar',      'none',...
    'Toolbar',      'none',...
    'WindowStyle',  'modal',...
    'Color',        FigColor,...
    'NumberTitle',  'off', ...
    'CloseRequestFcn', @CloseRequestFcn);

% create observation table
hTable = uitable(...
    'Parent',        h,...
    'Units',        'normalized',...
    'Position',     [0.04 0.20 0.92 0.75],...
    'ColumnName',   TableData.ColumnName,...
    'RowName',[],...
    'ColumnEditable',TableData.ColumnEditable,...
    'ColumnWidth',TableData.ColumnWidth,...
    'Data',TableData.Data,...
    'Tag','uitable1');

% create pushbuttons
pushbutton1 = uicontrol(h,...
    'String',       'Remove Observation',...
    'Position',     pushbutton1Pos,...
    'Callback',     @(hObject,eventdata) ...
        pushbutton1_callback(hObject,handles),...
    'Tag',          'pushbutton1');
pushbutton2 = uicontrol(h,...
    'String',       'Restore All Observations',...
    'Position',     pushbutton2Pos,...
    'Callback',     @(hObject,eventdata) ...
    pushbutton2_callback(hObject,handles),...
    'Tag',          'pushbutton2');

% set the pushbutton units to normalized to allow easy resizing of the
% table figure
set(pushbutton1,'Units','normalized');
set(pushbutton2,'Units','normalized');


function pushbutton1_callback(hObject,handles)

% get the current contents of the ExcludeDates variable
ExcludeDates = getappdata(handles.figure1,'ExcludeDates');

% get the handle of the table figure
h = get(hObject,'Parent');

% get the handle of the table
uitable1 = findobj(h,'Tag','uitable1');

% get the data currently held in the table
TableData = get(uitable1,'Data');

% get the index of the currently selected values
SelectedIndex = logical(cell2mat(TableData(:,1)));

if any(SelectedIndex)
    
    % extract the date strings
    SelectedDates = datenum(TableData(SelectedIndex,3),'mm/dd/yyyy HH:MM:SS');
    
    % add the selected dates to the global exclude dates
    ExcludeDates = unique([ExcludeDates; SelectedDates]);
    
    % update the exclude dates value
    setappdata(handles.figure1,'ExcludeDates',ExcludeDates);
    
    % set the update model flag
    setappdata(handles.figure1,'UpdateMDL',true);
    
end

% update said
update(handles);

% close the table figure
close(h);


function pushbutton2_callback(hObject,handles)

h = get(hObject,'Parent');

setappdata(handles.figure1,'ExcludeDates',[]);

setappdata(handles.figure1,'UpdateMDL',true);

update(handles);

close(h);

function CloseRequestFcn(hObject,eventdata)

% Hint: delete(hObject) closes the figure
% delete(hObject);
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end


function TableData = get_mdl_tbl( mdl, DateTimeVar )

% number of coefficients
p = mdl.NumCoefficients;

% number of observations
n = mdl.NumObservations;

% get the dataset of variables from the model
mdlDS = mdl.Variables;

% get the number of observations
NumObservations = mdl.NumObservations;

% assign observation numbers
ObservationNumbers = (1:size(mdlDS,1))';

% get an index of observations that are included in the model
ObservationIndex = ...
    ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

% get the names of the response variables from the model
ResponseName = mdl.ResponseName;

% get the names of the predictor variable from the model
PredictorNames = mdl.PredictorNames;

% create a cell array to hold the predictor value names
PredictorVals = cell(NumObservations,length(PredictorNames));

% initialize cell array for the check box column of the observation table
ChkBxClmn = num2cell(false(mdl.NumObservations,1));

% create cell array containing the observation numbers of the included
% observations
ObservationNum = num2cell(ObservationNumbers(ObservationIndex));

% primary date and time values
% DateTimeVal = num2cell(mdlDS.(DateTimeVar)(ObservationIndex));
DateTimeVal = mdlDS.(DateTimeVar)(ObservationIndex);
DateTimeVal = cellstr(datestr(DateTimeVal,'mm/dd/yyyy HH:MM:SS'));


% create cell array containing response values
ResponseVal = num2cell(mdlDS.(ResponseName)(ObservationIndex));

% for each explanatory variable
for k = 1:length(PredictorNames)
    
    % put the name of the explanatory variable in the cell array to write
    PredictorVals(:,k) = ...
        num2cell(mdlDS.(PredictorNames{k})(ObservationIndex));
    
end

% influence factors
Leverage=num2cell(mdl.Diagnostics.Leverage(ObservationIndex));
CooksD=num2cell(mdl.Diagnostics.CooksDistance(ObservationIndex));
Dffits=num2cell(mdl.Diagnostics.Dffits(ObservationIndex));

% critical values for influence
critLeverage=3*p/n;
critCooksD=finv(1-0.1,p+1,n-p);
critDffits=2*sqrt(p/n);

for k=1:length(Leverage)
    if Leverage{k}>critLeverage
        Leverage{k}=['<html><table border=0 width=65 bgcolor=#FF0000>'...
            '<TR><TD align="right">' num2str(Leverage{k}) ...
            '</TD></TR> </table></html>'];
    end
    if CooksD{k}>critCooksD
        CooksD{k}=['<html><table border=0 width=65 bgcolor=#FF0000>'...
            '<TR><TD align="right">' num2str(CooksD{k}) ...
            '</TD></TR> </table></html>'];
    end
    if abs(Dffits{k})>=critDffits
        Dffits{k}=['<html><table border=0 width=65 bgcolor=#FF0000>'...
            '<TR><TD align="right">' num2str(Dffits{k}) ...
            '</TD></TR> </table></html>'];
    end
end

% begin creating structure to hold table data

% column names
TableData.ColumnName = {'','Observation', DateTimeVar, ResponseName};

% add explanatory variable names
TableData.ColumnName = [ TableData.ColumnName PredictorNames' ];

% add influence indicators
TableData.ColumnName = ...
    [ TableData.ColumnName 'Leverage' 'Cook''s D' 'Dffits'];

% table data to display
TableData.Data = [...
    ChkBxClmn,...
    ObservationNum,...
    DateTimeVal,...
    ResponseVal,...
    PredictorVals,...
    Leverage,...
    CooksD,...
    Dffits ];

% set editable column flags
TableData.ColumnEditable = logical([1 false(1,3+length(PredictorNames))]);

% column widths
TableData.ColumnWidth = ...
    [20 70 120 65 num2cell(repmat(65,1,length(PredictorNames))) 65 65 65];
