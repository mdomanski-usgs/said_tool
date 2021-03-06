function h = said_busy_dialog(hMainFig, step, step_string)

% figure width and height, normalize units
figW = 0.20;
figH = 0.05;

% get the units of the main said figure
mainFigUnits = get(hMainFig,'Units');

% get normalized main said figure units
set(hMainFig,'Units','normal');
mainFigPos = get(hMainFig,'Position');
set(hMainFig,'Units',mainFigUnits);

% get the color of the main figure
mainFigColor = get(hMainFig,'Color');

% calculate the position of busy dialog
figX = (mainFigPos(1)+mainFigPos(3)/2)-figW/2;
figY = (mainFigPos(2)+mainFigPos(4)/2)-figH/2;

% initialize figure
h = figure(...
    'Units'         ,	'normal'                ,...
    'Position'      ,	[figX figY figW figH]   ,...
    'NumberTitle'   ,   'off'                   ,...
    'Name'          ,   step                    ,...
    'Color'         ,   mainFigColor            ,...
    'WindowStyle'   ,	'modal'                  ...
    );

% initialize text
uicontrol(...
    'Parent'        ,   h                       ,...
    'Style'         ,   'text'                  ,...
    'Units'         ,   'normal'                ,...
    'Position'      ,   [0.25 0.35 0.50 0.35]   ,...
    'String'        ,   step_string             ,...
    'FontSize'      ,   10                      ,...
    'BackgroundColor',  mainFigColor             ...
    );

drawnow

end
