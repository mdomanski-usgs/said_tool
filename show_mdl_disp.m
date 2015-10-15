function show_mdl_disp( handles, varargin )

p = inputParser;
defaultColor = [0.8 0.8 0.8];

addOptional(p,'color',defaultColor,@(x) (length(x)==3));

parse(p,varargin{:});

FigColor = p.Results.color;

% get the model object
mdl = getappdata(handles.figure1,'mdl');

% get the plot handle structure
% plts = getappdata(handles.figure1,'plts');

% get text to dipslay from the linear model object
mdlTxt = get_mdl_disp(mdl);

% get the position of the main figure
mainFigUnits = get(handles.figure1,'Units');
set(handles.figure1,'Units','pixels');
mainFigPos = get(handles.figure1,'Position');
set(handles.figure1,'Units',mainFigUnits);

% adjust the size of the display figure based on the number of predictor
% variables (adjust for the added column due to the VIF)
if mdl.NumPredictors > 1
    FigPosW = 831;
else
    FigPosW = 719;
end

% figure position values
FigPosH = 400;
FigPosX = (mainFigPos(1)+mainFigPos(3)/2) - FigPosW/2;
FigPosY = (mainFigPos(2)+mainFigPos(4)/2) - FigPosH/2;
FigPos = [FigPosX FigPosY FigPosW FigPosH];

%%%%%
% code modified from
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/148773
h = figure(                     ...
    'Menubar',      'none',     ...
    'Toolbar',      'none',     ...
    'Color',        FigColor,   ...
    'WindowStyle',	'modal',    ...        
    'NumberTitle',  'off',      ...
    'Position',     FigPos,     ...
    'Units',        'normalized',...
    'CloseRequestFcn', @CloseRequestFcn);

hEdit = uicontrol(h,            ...
    'Style',        'edit',     ...
    'FontSize',     10,         ...
    'FontName',     'FixedWidth',...
    'Min',          0,          ...
    'Max',          2,          ...
    'HorizontalAlignment','left',...
    'Units',        'normalized',...
    'Position',     [0 0 1 1],  ...
    'String',       mdlTxt,     ...
    'CreateFcn',    @hEdit_CreateFcn);

%# enable horizontal scrolling
jEdit = findjobj(hEdit);
jEditbox = jEdit.getViewport().getComponent(0);
jEditbox.setWrapping(false);                %# turn off word-wrapping
jEditbox.setEditable(false);                %# non-editable
set(jEdit,'HorizontalScrollBarPolicy',30);  %# HORIZONTAL_SCROLLBAR_AS_NEEDED

%# maintain horizontal scrollbar policy which reverts back on component resize
hjEdit = handle(jEdit,'CallbackProperties');
set(hjEdit, 'ComponentResizedCallback',...
    'set(gcbo,''HorizontalScrollBarPolicy'',30)')
%%%%% end of modified code

% update the plot handle structure
% setappdata(handles.figure1,'plts',plts);

    function hEdit_CreateFcn(hObject,eventdata)
        
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
        
    end

end

function CloseRequestFcn(hObject,eventdata)

    % Hint: delete(hObject) closes the figure
    % delete(hObject);
%         if isequal(get(hObject,'waitstatus'),'waiting')
%             uiresume(hObject);
%         else
        delete(hObject);
%         end

end