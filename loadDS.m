function RDBFullFile = loadDS(handles,varargin)
%

if nargin > 1
    exclude = varargin{1};
else
    exclude = true;
end

% get the current working directory
CWD = getappdata(handles.figure1,'CWD');

FigColor = get(handles.figure1,'Color');

% initialize main figure
MainFig = figure(...
    'Units',            'normalized',...
    'Position',         [0.2 0.5 0.4 0.25],...
    'Color',            FigColor,...
    'MenuBar',          'none',...
    'Name',             'Load datasets',...
    'NumberTitle',      'off',...
    'CloseRequestFcn',  @MainFig_CloseRequestFcn,...
    'WindowStyle',      'modal');%,...

% get the color of the main figure
MainFigColor = get(MainFig,'Color');

% initialize RDBFullFile as an empty string
RDBFullFile = cellstr('');

% text field to show current working directory
CurrentDirText = uicontrol( ...
    'Style',                'text',...
    'Units',                'normalized',...
    'Position',             [0.05 0.9 0.7 0.05],...
    'BackgroundColor',      MainFigColor,...
    'HorizontalAlignment',  'left');

% button to select working directory
BrowseDirButton = uicontrol( ...
    'Style',    'pushbutton',...
    'Units',    'normalized',...
    'String',   'Select New Directory',...
    'Position', [0.05 0.75 0.21 0.13],...
    'Callback', @BrowseDirButton_Callback);

% button to select the highlighted file to load
LoadFileButton = uicontrol( ...
    'Style',    'pushbutton',...
    'Units',    'normalized',...
    'String',   'Load Selected Dataset',...
    'Position', [0.05 0.57 0.21 0.13],...
    'Callback', @LoadFileButton_Callback);

% button to load argonaut data
LoadArgDataButton = uicontrol( ...
    'Style',    'pushbutton',...
    'Units',    'normalized',...
    'String',   'Load Argonaut Dataset',...
    'Position', [0.05 0.39 0.21 0.13],...
    'Callback', @LoadArgDataButton_Callback);

% cancel button
CancelButton = uicontrol( ...
    'Style',    'pushbutton',...
    'Units',    'normalized',...
    'String',   'Cancel',...
    'Position', [0.05 0.21 0.21 0.13],...
    'Callback', @CancelButton_Callback);

% listbox that displays selectable files
FileListBox = uicontrol( ...
    'Style',    'listbox',...
    'Units',    'normalized',...
    'Position', [0.30 0.05 0.25 0.83],...
    'BackgroundColor', [1 1 1],...
    'Callback', @FileListBox_Callback);

% listbox that displays variables
VariableListBox = uicontrol( ...
    'Style',    'listbox',...
    'Units',    'normalized',...
    'Position', [0.65 0.05 0.25 0.83],...
    'BackgroundColor', [1 1 1]);

% get contents of current working directory
DirListTxt = getDirList(CWD,'txt');
DirListRdb = getDirList(CWD,'rdb');
DirList = [DirListTxt; DirListRdb];

set(FileListBox,'String',DirList);
set(CurrentDirText,'String',['CWD: ' CWD]);

% assign graphics handles as appdata to the main figure
setappdata(MainFig,'CurrentDirText',CurrentDirText);
setappdata(MainFig,'BrowseDirButton',BrowseDirButton);
setappdata(MainFig,'FileListBox',FileListBox);
setappdata(MainFig,'VariableListBox',VariableListBox);
setappdata(MainFig,'handles',handles);
setappdata(MainFig,'CWD',CWD);
setappdata(MainFig,'RDBFullFile',RDBFullFile);
setappdata(MainFig,'exclude',exclude);

% wait for main figure to close
uiwait(MainFig);

% if the RDBFullFile variable isn't an empty matrix, return a dataset
% loaded from the file, otherwise return an empty matrix
if ~isempty(RDBFullFile)
    
    % get the last warning that was issued
    [msgstr, msgid] = lastwarn;
    
    % if it's the warning we're looking for
    if strcmp(msgid,'stats:dataset:genvalidnames:ModifiedVarnames')
        
        % warn the user with a dialog box
        h = warndlg(msgstr,msgid);
        
        % wait for the dialog box to be closed
        uiwait(h);
        
        % clear the last warning
        lastwarn('','');
        
    end
    
    % else
    
end

    function MainFig_CloseRequestFcn(src, event)
        
        RDBFullFile = cellstr(getappdata(MainFig,'RDBFullFile'));
        
        delete(MainFig);
        
    end

end

%%%% Callback functions %%%%

function BrowseDirButton_Callback(hObject, ~)

% get the main figure handle
MainFig = get(hObject,'Parent');

% get graphics handles
CurrentDirText  = getappdata(MainFig,'CurrentDirText');
FileListBox     = getappdata(MainFig,'FileListBox');
VariableListBox = getappdata(MainFig,'VariableListBox');

% get the current working directory
CWD = getappdata(MainFig,'CWD');

% prompt user to choose a folder
folder_name = uigetdir(CWD);

% if a folder was selected
if all(folder_name ~= 0)
    
    % set current working directory to selected folder
    CWD = folder_name;
    
    % get a directory listing of txt and rdb files in the folder
    DirListTxt = getDirList(CWD,'txt');
    DirListRdb = getDirList(CWD,'rdb');
    
    DirList = [DirListTxt; DirListRdb];
    
    % display the current directory
    set(CurrentDirText,'String',['CWD: ' CWD]);
    
    % show the files contained in the directory
    set(FileListBox,'String',DirList);
    
    % clear the variable list box
    set(VariableListBox,'String','');
    
    % set the new current working directory
    setappdata(MainFig,'CWD',CWD);
    
    % clear the selected file name
    setappdata(MainFig,'RDBFullFile','');
    
end

end

function FileListBox_Callback(hObject, ~)

% get the main figure handle
MainFig = get(hObject,'Parent');

% get graphics handles
VariableListBox = getappdata(MainFig,'VariableListBox');

% get the current working directory
CWD = getappdata(MainFig,'CWD');

% get the rdb file name
contents = cellstr(get(hObject,'String'));
RDBFileName = contents{get(hObject,'Value')};

% get the full rdb file name
viewRDBFullFile = fullfile(CWD,RDBFileName);

% get the file header
Header = getFileHeader(viewRDBFullFile);

% display the variables
set(VariableListBox,'String',Header);

setappdata(MainFig,'viewRDBFullFile',viewRDBFullFile);

end

function LoadFileButton_Callback(hObject, ~)

% main figure handle
MainFig = get(hObject,'Parent');

% parent gui handles structure
handles = getappdata(MainFig,'handles');

mdl = getappdata(handles.figure1,'mdl');

exclude = getappdata(MainFig,'exclude');

% update RDBFullFile
loadRDBFullFile = getappdata(MainFig,'viewRDBFullFile');

% if the selected file isn't empty
if ~isempty(loadRDBFullFile)
    
    % variable names in global data set
    gDSVarNames = getappdata(handles.figure1,'gDSVarNames');
    
    % get the file header contents
    Header = getFileHeader(loadRDBFullFile);
    
    % get the name of the data set file
    [~,name] = fileparts(loadRDBFullFile);
    
    % set the load data set flag
    loadDataSet = true;
    
    if exclude
        % if the data set duplicates any variables already loaded, clear the
        % load data set flag
        for i = 1:length(gDSVarNames)
            if any(strcmp(gDSVarNames{i},Header))
                loadDataSet = false;
                break;
            end
        end
        
        
        % if the load data set flag is set
        if loadDataSet
            
            % if the required time variables are present
            if all([...
                    ismember('y',Header) ...
                    ismember('m',Header) ...
                    ismember('d',Header) ...
                    ismember('H',Header) ...
                    ismember('M',Header) ...
                    ismember('S',Header) ...
                    ]) || ...
                    ismember('DateTime',Header)
                
                % set the full file variable
                setappdata(MainFig,'RDBFullFile',loadRDBFullFile);
                
                % close the main figure
                close(MainFig);
                
            else
                
                msgbox(['Date and time variables must be present in the form ' ...
                    '''y m d H M S'' in order to load the dataset'], ...
                    'Date and Time Information',...
                    'error');
                
            end
            
        else
            
            msgbox(['Unable to load ' name ', duplicate variable names'],...
                'Duplicate variable names', 'error');
            
        end
        
    elseif ~exclude
        
        % if the required time variables are present
        if all([...
                ismember('y',Header) ...
                ismember('m',Header) ...
                ismember('d',Header) ...
                ismember('H',Header) ...
                ismember('M',Header) ...
                ismember('S',Header) ...
                ]) || ...
                ismember('DateTime',Header)
            
            % set the full file variable
            setappdata(MainFig,'RDBFullFile',loadRDBFullFile);
            
            % close the main figure
            close(MainFig);
            
        else
            
            msgbox(['Date and time variables must be present in the form ' ...
                '''y m d H M S'' in order to load the dataset'], ...
                'Date and Time Information',...
                'error');
            
        end
        
    end
    
else
    
    msgbox('Select a file to load.',...
        'Select file',...
        'warn');
    
end

end % function

function LoadArgDataButton_Callback(hObject,~)

% main figure handle
MainFig = get(hObject,'Parent');

handles = getappdata(MainFig,'handles');

exclude     = getappdata(MainFig,'exclude');

% variable names in global data set
gDSVarNames = getappdata(handles.figure1,'gDSVarNames');

CWD         = getappdata(handles.figure1,'CWD');

loadDataSet = true;

advmVarNames = { ...
    'Cell'      ,...
    'Vbeam'     ,...
    'ADVMTemp'  ...
    };

% if the data set duplicates any variables already loaded, clear the
% load data set flag
for i = 1:length(gDSVarNames)
    if any(cell2mat(strfind(advmVarNames,gDSVarNames{i}))) && exclude
        loadDataSet = false;
        break;
    end
end

if loadDataSet
    
    set(MainFig,'Visible','off');
    
    % get argonaut fnames
    argFnames = get_arg_fnames(CWD);
    
    if ~isempty(argFnames)
        setappdata(MainFig,'RDBFullFile',argFnames);
        % close the main figure
        close(MainFig);
    else
        set(MainFig,'Visible','on');
    end
    
else
    
    msgbox(['Unable to load Argonaut data: '...
        'ADVM variables already present'],...
        'Duplicate variable names', 'error');
    
end



end

function CancelButton_Callback(hObject, ~)

% main figure handle
MainFig = get(hObject,'Parent');

% set the full file name to an empty string
RDBFullFile = '';

% update the full file name variable
setappdata(MainFig,'RDBFullFile',RDBFullFile);

% close the main figure
close(MainFig);

end

%%%% Utility functions %%%%

function DirList = getDirList(directory, Extension)
%

% define the file extension to look for
% Extension = 'rdb';

% get a full file name to dir
name = fullfile(directory,['*.' Extension]);

% get a directory listing of the files with the defined extension
DirList = dir(name);

% get an index array of the non-directory listing
isNotDir = ~cell2mat({DirList.isdir});

% return the names of the files
DirList = {DirList(isNotDir).name}';

end

function Header = getFileHeader(RDBFullFile)

if ~isempty(RDBFullFile)
    
    % open rdb file
    fid = fopen(RDBFullFile,'r');
    
else
    
    fid = -1;
    
end

% if fid is valid
if fid > 0
    
    % read the first line of the text file
    FirstLine = fgetl(fid);
    
    % close the file
    fclose(fid);
    
    Header = regexp(FirstLine,'\t','split');
    
else
    
    Header = [];
    
end

end


function argFnames = get_arg_fnames(CWD)
% returns list of qualifying file names
% in order for data to be processed, .snr, .dat, and .ctl files
% must be present

% set okay to false
ok = 0;

% initialize file name cell array
fnames = {};


while ~ok
    
    % get directory to search from user
    pathname_new = uigetdir(CWD);
    
    % if a valid path name has been returned
    if pathname_new ~= 0
        
        % set the path name to the new path name
        gPathname = pathname_new;
        
        % get the list of snr files in the current path
        snrDirList = dir(fullfile(gPathname,'*.snr'));
        
        % begin indexing data sets
        ll = 1;
        
        % loop through each snr file in the directory lists
        for k = 1:size(snrDirList,1)
            
            % get the base name of the snr file
            [~,name] = fileparts(snrDirList(k).name);
            
            % guess the ctl and dat file names
            ctlFname = fullfile(gPathname,[name '.ctl']);
            datFname = fullfile(gPathname,[name '.dat']);
            
            % if the ctl and dat files exist
            if exist(ctlFname,'file') && exist(datFname,'file')
                
                % add them to the data set names list
                fnames{ll} = name;%#ok<AGROW> %[gPathname '\' name];
                
                % increment data set list index
                ll = ll + 1;
                
            end % if
            
        end % for
        
        % if the file names array is empty
        if ~isempty(fnames)
            
            % prompt the user to select which data sets to load
            % ok is set to exit the while loop if a valid election has been
            % made
            [Selection,ok] = listdlg(...
                'ListString',fnames,...
                'ListSize',[300 300],...
                'Name','Select Data',...
                'SelectionMode','single'...
                );
            
            % create cell array to hold data set names
            argFnames = cell(size(Selection,2),1);
            
            % for each set in the selection
            for k = 1:size(Selection,2)
                
                % put the path and set name into cell array to be returned
                % by function
                argFnames{k,1} = gPathname;
                argFnames{k,2} = fnames{Selection(k)};
                
            end
            
            if ~isempty(argFnames)
                argFnames = fullfile(argFnames{:,1},argFnames{:,2});
            end
            
        % otherwise notify user that no qualifiying files were found
        else
            
            h = errordlg(...
                ['No data sets were found in ' gPathname],...
                'No Data Sets Found');
            
            % wait for user response
            uiwait(h);
            
        end % if
        
    % if a valid path name hasn't been returned
    else
        
        % signal to exit the while loop
        ok = 1;
        
        % set the returned data set names to an empty matrix
        argFnames = [];
        
    end
    
    % set the data set names cell array to empty
    fnames = {};
    
end % while

end % getargfnames