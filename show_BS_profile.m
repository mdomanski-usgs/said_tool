function show_BS_profile(handles,varargin)

p = inputParser;
defaultFigNum = 1;

validateFigNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);

addOptional(p,'figNum',defaultFigNum,validateFigNum);

parse(p,varargin{:});

FigNum = p.Results.figNum;

% get the advm configuration/processing structure
advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

% get the model object
mdl = getappdata(handles.figure1,'mdl');

% get the matched data set
matchedDS = mdl.Variables;

% name of date/time index variable
DateTimeVar = 'DateTime';

% get indices for observations included in the model
iObs = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

% get the number of observations
NObs = mdl.NumObservations;

% assign observation numbers
ObservationNumbers = (1:size(matchedDS,1))';

% get the distance along beam axis profile
R = unique(matchedDS.R(all(~isnan(matchedDS.R),2),:),'rows');

% get the distance between cells
RSize =  advmParamStruct.CellSize/cosd(advmParamStruct.SlantAngle);

% get the backscatter profiles
MB  = matchedDS.MB;
WCB = matchedDS.WCB;
SCB = matchedDS.SCB;

% find range of valid values to plot
ValidI = ~all(isnan(MB));

% get values to plot
Rplot = R(ValidI);
MBplot = MB(iObs,ValidI);
WCBplot = WCB(iObs,ValidI);
SCBplot = SCB(iObs,ValidI);

% get limits of plot
if ~isempty(Rplot)
    XLim = [min(Rplot)-RSize max(Rplot)+RSize];
else
    XLim = [min(R)-RSize max(R)+RSize];
end


% create a string array of the observation number with corresponding
% date/time
ListStr = [ num2str(ObservationNumbers(iObs)) ...
    repmat('   ',NObs,1) ...
    datestr(matchedDS.(DateTimeVar)(iObs),'mm/dd/yyyy HH:MM:SS')];

% Figure position
mainFigUnits = get(handles.figure1,'Units');
set(handles.figure1,'Units','pixels');
mainFigPos = get(handles.figure1,'Position');
set(handles.figure1,'Units',mainFigUnits);

ScreenSize = get(0,'ScreenSize');

FigPosW = 815;
FigPosH = 700;

FigPosX = (mainFigPos(1)+mainFigPos(3)/2) - FigPosW/2;

if FigPosX < 20
    FigPosX = 20;
elseif (FigPosX + FigPosW) > ScreenSize(3)
    FigPosX = ScreenSize(3) - (FigPosW+20);
end

FigPosY = (mainFigPos(2)+mainFigPos(4)/2) - FigPosH/2;

if FigPosY < 20
    FigPosY = 20;
elseif (FigPosY + FigPosH) > ScreenSize(4)
    FigPosY = ScreenSize(4) - (FigPosH+50);
end

FigPos = [FigPosX FigPosY FigPosW FigPosH];

HSpc = 0.05;

AxesY = 0.07;
AxesW = 0.6;
AxesVSpc = 0.025;
AxesH = (1-3*AxesVSpc-AxesY)/3;
AxesX = (1-AxesW-HSpc);

ListboxW = AxesX-3*HSpc;
ListboxH = 0.5;
ListboxX = HSpc;
ListboxY = 0.5-ListboxH/2;

RmMinWCBcbW = 100/FigPosW;
RmMinWCBcbH = 30 /FigPosH;
RmMinWCBcbX = (ListboxX+ListboxW/2)-RmMinWCBcbW/2;
RmMinWCBcbY = ListboxY - 2*RmMinWCBcbH;

MBAxesPos = [AxesX AxesY AxesW AxesH];
WCBAxesPos = [AxesX ...
    (AxesY+AxesVSpc+AxesH) ...
    AxesW AxesH];
SCBAxesPos = [AxesX ...
    (AxesY+2*(AxesVSpc+AxesH)) ...
    AxesW AxesH];

ListboxPos = [ListboxX ListboxY ListboxW ListboxH];

WriteBSpbH = 0.05;

WriteBSpbPos = [ListboxX ListboxY-WriteBSpbH-0.05 ListboxW WriteBSpbH];

%  set up figure

FigColor = get(handles.figure1,'color');

h = figure(FigNum);
set(h,...
    'Position',FigPos,...
    'Menubar','none',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Color',FigColor);%,...
%     'WindowStyle','modal');


hMBAxes = axes('Parent',h,...
    'Units','normalized',...
    'XLim',XLim,...
    'XTick',Rplot,...
    'XGrid','on',...
    'Position',MBAxesPos,...
    'Tag','axes1');
ylabel('Measured Backscatter (dB)');
xlabel('Cell Distance Along Acoustic Axis of Beam (m)');

hWCBAxes = axes('Parent',h,...
    'Units','normalized',...
    'XLim',XLim,...
    'XTick',Rplot,...
    'XGrid','on',...
    'XTickLabel','',...
    'Position',WCBAxesPos,...
    'Tag','axes2');
ylabel('Water Corrected Backscatter (dB)');

hSCBAxes = axes('Parent',h,...
    'Units','normalized',...
    'XLim',XLim,...
    'XTick',Rplot,...
    'XGrid','on',...
    'XTickLabel','',...
    'Position',SCBAxesPos,...
    'Tag','axes3');
ylabel('Sediment Corrected Backscatter (dB)');

hListbox = uicontrol('Parent',h,...
    'Style','listbox',...
    'BackgroundColor',[1 1 1],...
    'String',ListStr,...
    'Min',0,...
    'Max',2,...
    'Units','normalized',...
    'Position',ListboxPos,...
    'Tag','listbox1',...
    'Callback',@listbox1_Callback);

hwriteBSpb = uicontrol('Parent',h,...
    'Style','pushbutton',...
    'String','Write Backscatter',...
    'Units','normalized',...
    'Position',WriteBSpbPos,...
    'Tag','writeBSpb',...
    'Callback',@writeBSpb_Callback);

% set up lines

LineSpec = get_line_spec(NObs);

for k = 1:NObs
    
    line('Parent',hMBAxes,...
        'XData',Rplot,...
        'YData',MBplot(k,:),...
        'Color',LineSpec{k,1},...
        'LineStyle',LineSpec{k,2},...
        'Marker','d',...
        'MarkerFaceColor',LineSpec{k,1},...
        'Visible','off');
    
    line('Parent',hWCBAxes,...
        'XData',Rplot,...
        'YData',WCBplot(k,:),...
        'Color',LineSpec{k,1},...
        'LineStyle',LineSpec{k,2},...
        'Marker','o',...
        'MarkerFaceColor',LineSpec{k,1},...        
        'Visible','off');
    
    line('Parent',hSCBAxes,...
        'XData',Rplot,...
        'YData',SCBplot(k,:),...
        'Color',LineSpec{k,1},...
        'LineStyle',LineSpec{k,2},...
        'Marker','*',...
        'MarkerFaceColor',LineSpec{k,1},...            
        'Visible','off');
    
end

MBLines = get(hMBAxes,'Children');
WCBLines = get(hWCBAxes,'Children');
SCBLines = get(hSCBAxes,'Children');

%

% create a data cursor mode object
dcm = datacursormode(h);
set(dcm,...
    'DisplayStyle','datatip',...
    'SnapToDataVertex','off',...
    'UpdateFcn',@dcm_updatefcn);

%

    function listbox1_Callback(hObject,eventdata)
        
        % hide all lines
        hide_lines(hMBAxes);
        hide_lines(hWCBAxes);
        hide_lines(hSCBAxes);
        
        % get selected values in the listbox
        index_selected = get(hObject,'Value')';
        
        % reset the line width on all lines
        for j = 1:length(MBLines)
            set(MBLines(j),'LineWidth',1);
            set(WCBLines(j),'LineWidth',1);
            set(SCBLines(j),'LineWidth',1);
        end
        
        % show corresponding lines selected
        for i = 1:length(index_selected)
            set(MBLines(length(MBLines)-index_selected(i)+1),'Visible','on');
            set(WCBLines(length(MBLines)-index_selected(i)+1),'Visible','on');
            set(SCBLines(length(MBLines)-index_selected(i)+1),'Visible','on');
        end
        
    end

    function writeBSpb_Callback(hObject,eventdata)
        
        CWD = getappdata(handles.figure1,'CWD');
        
        DateTime = datestr(matchedDS.(DateTimeVar),'mm/dd/yyyy HH:MM:SS');
        
        bsDS = dataset(...
            {DateTime,'DateTime'},...
            {ObservationNumbers,'ObservationNumber'},...
            {repmat(R,length(ObservationNumbers),1), 'r'},...
            {MB,'MeasuredBackscatter'},...
            {WCB,'WaterCorrectedBackscatter'},...
            {SCB,'SedimentCorrectedBackscatter'}...
            );

        write_backscatter(bsDS,CWD)
    
    end

% data tip update function
    function txt = dcm_updatefcn(~,event_obj)
        
        LineObsNums = ObservationNumbers(iObs);
        LineDates   = matchedDS.(DateTimeVar)(iObs);
        
        % reset all line widths
        for j = 1:length(MBLines)
            set(MBLines(j),'LineWidth',1);
            set(WCBLines(j),'LineWidth',1);
            set(SCBLines(j),'LineWidth',1);
        end
        
        % get the selected target
        Target = get(event_obj,'Target');
        
        % get all of the lines from the target axes
        LineSet = get(get(Target,'Parent'),'Children');
        
        % find the index of the selected line
        iLine = find(Target==LineSet);
        iSample = length(LineObsNums)-iLine+1;
        
        % make the selected lines bold
        set(MBLines(iLine),'LineWidth',5);
        set(WCBLines(iLine),'LineWidth',5);
        set(SCBLines(iLine),'LineWidth',5);
        
        % get the time of the sample for the corresponding line
        Time = datestr(LineDates(iSample),...
            'mm/dd/yyyy HH:MM:SS');
        
        % get the observation number of the selected line
        Observation = num2str(LineObsNums(iSample));
        
        % return the following text
        txt = {...
            ['Observation: ' Observation]...
            ['Time: ' Time]};
        
        
    end

end

function hide_lines(hAxes)

% get all axes children
children = get(hAxes,'Children');

% switch off the visibility of all axes children
for k = 1:length(children)
    set(children(k),'Visible','off');
end

end

function LineSpec = get_line_spec(nLines)

% initialize counters
j = 1;
k = 1;

% line styles/colors
LineStyles = {'-'; '--'; ':'; '-.'};
LineColors = {'b'; 'g'; 'r'; 'm'; 'y'; 'k'};

% initialize cell array to hold LineSpecs
LineSpec = cell(nLines,2);

% for each line line
for i = 1:nLines
    
    % set line spec combination
    LineSpec{i,1} = LineColors{j};
    LineSpec{i,2} = LineStyles{k};
    
    % adjust counters
    if j < size(LineColors,1)
        j = j + 1;
    else
        j = 1;
        if k < size(LineStyles,1)
            k = k + 1;
        else
            k = 1;
        end
    end
    
end

end

function write_backscatter(bsDS,CWD)

[FileName,PathName] = uiputfile(fullfile(CWD,'*.csv'));

export(bsDS,'file',fullfile(PathName,FileName),'Delimiter',',');

end