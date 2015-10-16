function data_loaded = load_arg_data(handles)

overwrite_obs = [];

surr_full_file = getappdata(handles.figure1,'surr_full_file');

% get the current working directory
CWD = getappdata(handles.figure1,'CWD');

% get the current advm parameter structure
advmParamStruct = getappdata(handles.figure1,'advmParamStruct');

% get the current loaded variable structure
loaded_var_struct = getappdata(handles.figure1,'loaded_var_struct');

% prompt the user for argonaut dataset names to load
arg_fnames = get_arg_fnames(CWD);

% get the number of argonaut dataset names
n_arg_fnames = length(arg_fnames);

% if there are any dataset names present
if n_arg_fnames > 0
    
    CWD = fileparts(arg_fnames{1});
    
    % get the current contents of the surrogate dataset listbox
    file_list = get(handles.SurrDataSetNames_listbox,'String');
    
    % if the current advm parameter structure doesn't contain the
    % necessary information, assume the user hasn't loaded or entered
    % advm information yet
    if any([isempty(advmParamStruct.Frequency), ...
            isempty(advmParamStruct.SlantAngle), ...
            isempty(advmParamStruct.BlankDistance), ...
            isempty(advmParamStruct.CellSize), ...
            isempty(advmParamStruct.NumberOfCells)  ...
            ])
        
        % load the first argonaut dataset ctl file and use fill the current
        % advmParamStruct with the information
        ps = read_arg_ctl( [arg_fnames{1} '.ctl'] );
        
        advmParamStruct.Frequency = ps.Frequency;
        advmParamStruct.EffectiveDiameter = ps.EffectiveDiameter;
        advmParamStruct.SlantAngle = ps.SlantAngle;
        advmParamStruct.BlankDistance = ps.BlankDistance;
        advmParamStruct.CellSize = ps.CellSize;
        advmParamStruct.NumberOfCells = ps.NumberOfCells;
        advmParamStruct.BeamOrientation = ps.BeamOrientation;
        
    end
    
    % check the argonaut datasets for compatibility
    TF = check_arg_ctl( advmParamStruct, arg_fnames );
    
    if any(~TF)
        
        listdlg(...
            'ListString',arg_fnames(~TF),...
            'ListSize',[500 100],...
            'PromptString',['Unable to load the following datasets due '...
                'to conflicts with current ADVM configuration:'],...
            'SelectionMode','single'...
            );
        
    end
    
    % if any of the datasets are loadable
    if any(TF)
        
        h = said_busy_dialog(handles.figure1,'Loading', 'Loading Argonaut data...');
        
        % get the dataset names to load
        load_arg_fnames = arg_fnames(TF);
        
        % get the number of datasets to load
        n_load_arg_fnames = length(load_arg_fnames);
        
        % for every dataset to load
        for i = 1:n_load_arg_fnames
            
            % load the argonaut dataset and add it as a field to the
            % structure
            argDS = read_arg_set(load_arg_fnames{i}, advmParamStruct );

            % if the user hasn't been prompted to overwrite variables yet
            if isempty(overwrite_obs)
                
                % check to see if there are any conflicts
                overwrite_obs = check_loaded_vars(loaded_var_struct,argDS);
                
                % if the user decided to cancel, break out of the loop and
                % abandon loading datasets
                if ~isempty(overwrite_obs) && (overwrite_obs == -1)
                    
                    break;
                    
                end
                
            end
            
            % if user decided to not to cancel or hasn't been prompted yet
            if (isempty(overwrite_obs)) || (overwrite_obs ~= -1)
                
                loaded_var_struct = ...
                    combine_loaded_vars(loaded_var_struct,...
                    argDS,...
                    overwrite_obs);
                
                % append the new filename to the file list
                surr_full_file{end+1} = ...
                    [load_arg_fnames{i} ' (Arg)'];
                
            end
            
        end
        
        close(h);
        
    end
    
    if isempty(overwrite_obs) || (overwrite_obs ~= -1)
        
        setappdata(handles.figure1,'loaded_var_struct',loaded_var_struct);
        setappdata(handles.figure1,'advmParamStruct',advmParamStruct);
        
    end
    
    setappdata(handles.figure1,'CWD',CWD);
    setappdata(handles.figure1,'surr_full_file',surr_full_file);
    
    data_loaded = true;
    
else
    
    data_loaded = false;
    
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
        
        % if the file names array is not empty
        if ~isempty(fnames)
            
            % prompt the user to select which data sets to load
            % ok is set to exit the while loop if a valid election has been
            % made
            [Selection,ok] = listdlg(...
                'ListString',fnames,...
                'ListSize',[300 300],...
                'Name','Select Data',...
                'SelectionMode','multiple'...
                );
            
            % create cell array to hold data set names
            argFnames = cell(size(Selection,2),1);
            
            % for each set in the selection
            for k = 1:size(Selection,2)
                
                % put the path and set name into cell array to be returned
                % by function
%                 argFnames{k,1} = gPathname;
%                 argFnames{k,2} = fnames{Selection(k)};
                argFnames{k} = fullfile(gPathname,fnames{Selection(k)});
                
            end
            
%             if ~isempty(argFnames)
%                 argFnames = fullfile(argFnames{:,1},argFnames{:,2});
%             end
            
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

function advmDS = read_arg_set(ArgBaseFName, ArgCtl )

% .dat columns
Year        =  1;
Month       =  2;
Day         =  3;
Hour        =  4;
Minute      =  5;
Second      =  6;
VBeam       =  9;
Temperature = 29;

% counted from number of columns in header - 20140430 MMD
% % number of columns in .dat file
% N_dat = 38;

% number of columns read from .dat file
N_datOut = 3;

% number of columns in .snr file
N_snr = 7 + 4 * ArgCtl.NumberOfCells;

% number of columns read from .snr file
N_snrOut = 4*ArgCtl.NumberOfCells;

% Counter for number of samples
NSamples = 0;

datFname = [ArgBaseFName '.dat'];
snrFname = [ArgBaseFName '.snr'];

% Get number of samples from .dat file

% open file
fid = fopen(datFname);

% throw away header line
fgetl(fid);

% begin counting samples (lines)
while ~feof(fid)
    fgetl(fid);
    NSamples = NSamples + 1;
end

%return to beginning of file
fseek(fid,0,-1);

% dataset cell array
advmDSCell = cell(NSamples+1,N_datOut+N_snrOut);

% initialize dataset cell array header
advmDSCell{1,1} = 'DateTime';
advmDSCell{1,2} = 'Vbeam';
advmDSCell{1,3} = 'ADVMTemp';


for i = 1:ArgCtl.NumberOfCells
    advmDSCell{1,N_datOut+i} ...
        = ['Cell' num2str(i,'%02i') 'SNR1'];
    advmDSCell{1,N_datOut+ArgCtl.NumberOfCells+i} ...
        = ['Cell' num2str(i,'%02i') 'SNR2'];
    advmDSCell{1,N_datOut+2*ArgCtl.NumberOfCells+i} ...
        = ['Cell' num2str(i,'%02i') 'Amp1'];
    advmDSCell{1,N_datOut+3*ArgCtl.NumberOfCells+i} ...
        = ['Cell' num2str(i,'%02i') 'Amp2'];
end


% Read .dat information

% allocate matrix for .dat file info
datMatrix = zeros(NSamples, N_datOut);

% % throw away header line
% fgetl(fid);

% changed to count number of coulumns based on number of lines in header
% 20140430 MMD

% read header line and count the number of columns
linein = fgetl(fid);
headerCols = regexp(linein,' ','split');
N_dat = length(headerCols) - 1;

% read samples info
for k = 1:NSamples
    
    linein = fscanf(fid,'%f',N_dat);
    
    dateVector = [ linein(Year) linein(Month) linein(Day) linein(Hour) ...
        linein(Minute) linein(Second) ];
    
    datMatrix(k,:) = [ datenum(dateVector) ...
        linein(VBeam) ...
        linein(Temperature)];
    
end

fclose(fid);

% Read .snr file

snrMatrix = zeros(NSamples, N_snrOut);

fid = fopen(snrFname);

% throw away frist two header lines
fgetl(fid);fgetl(fid);

% read sample info
for k = 1:NSamples
    
    linein = fscanf(fid, '%f', N_snr);
    
    for j = 1:4
        
        for i = 1:ArgCtl.NumberOfCells
            
            snrMatrix(k,(j-1)*ArgCtl.NumberOfCells+i) = ...
                linein(i*j+(i-1)*(4-j)+7);
            
        end
        
    end
    
end

fclose(fid);

advmDSCell(2:end,:) = num2cell([datMatrix snrMatrix]);

advmDS = cell2dataset(advmDSCell);
advmDS = dataset2table(advmDS);

end



function ArgCtl = read_arg_ctl( ctlFname )

ArgTypeLine = 10;
FreqLine = 12;
SlantAngleLine = 16;
BlankDistanceLine = 44;
CellSizeLine = 45;
NCellsLine = 46;

ArgCtl = default_advm_param_struct();

ctlFileLines = read_txt_lines(ctlFname);

SpltLine = regexp(ctlFileLines{ArgTypeLine}, ' ', 'split');
ArgType = SpltLine{3};

if strcmp(ArgType,'SL')
    ArgCtl.BeamOrientation = 'Horizontal';
elseif strcmp(ArgType,'SW')
    ArgCtl.BeamOrientation = 'Vertical';
end

SpltLine = regexp(ctlFileLines{FreqLine}, ' ', 'split');
ArgCtl.Frequency = str2double(SpltLine{5});

% transducer radius (m)
if ArgCtl.Frequency == 3000 % 3000 kHz SL and SW
    ArgCtl.EffectiveDiameter = 0.015;
elseif ArgCtl.Frequency == 1500 % 1500 kHz SL
    ArgCtl.EffectiveDiameter = 0.030;
elseif ArgCtl.Frequency == 500 % 500 kHz SL
    ArgCtl.EffectiveDiameter = 0.090;
elseif isnan(ArgCtl.Frequency)
    ArgCtl.EffectiveDiameter = [];
end

SpltLine = regexp(ctlFileLines{SlantAngleLine}, ' ', 'split');
ArgCtl.SlantAngle = str2double(SpltLine{5});

SpltLine = regexp(ctlFileLines{BlankDistanceLine}, ...
    ' ', 'split');
ArgCtl.BlankDistance = str2double(SpltLine{4});

SpltLine = regexp(ctlFileLines{CellSizeLine}, ' ', 'split');
ArgCtl.CellSize = str2double(SpltLine{5});

SpltLine = regexp(ctlFileLines{NCellsLine}, ' ', 'split');
ArgCtl.NumberOfCells = str2double(SpltLine{5});

ArgCtl.MovingAverageSpan = 1;

end

function TF = check_arg_ctl( arg_ctl_struct, arg_fnames )

% get the number of argonaut files passed
n_arg_fnames = length(arg_fnames);

% create false array to return by default
TF = false(n_arg_fnames,1);

% for each passed file name set
for i = 1:n_arg_fnames
    
    % get the name of the ctl file
    ctl_fname = [arg_fnames{i} '.ctl'];
    
    % read the ctl file
    new_arg_ctl_struct = read_arg_ctl( ctl_fname );
    
    % compare the necessary fields and set element in TF array accordingly
    TF(i) = ~any([...
        (arg_ctl_struct.Frequency        ~= new_arg_ctl_struct.Frequency)        ...
        (arg_ctl_struct.SlantAngle       ~= new_arg_ctl_struct.SlantAngle)       ...
        (arg_ctl_struct.BlankDistance    ~= new_arg_ctl_struct.BlankDistance)    ...
        (arg_ctl_struct.CellSize         ~= new_arg_ctl_struct.CellSize)         ...
        (arg_ctl_struct.NumberOfCells    ~= new_arg_ctl_struct.NumberOfCells)    ...
        ]);
    
end

end

