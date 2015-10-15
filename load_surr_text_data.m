function [data_loaded, advm_data_loaded] = load_surr_text_data(handles)

% get the global loaded file name list
surr_full_file = getappdata(handles.figure1,'surr_full_file');

% get the current working directory
CWD = getappdata(handles.figure1,'CWD');

% get the current loaded variable structure
loaded_var_struct = getappdata(handles.figure1,'loaded_var_struct');

% set the filter spec to look for text files
FilterSpec = [CWD '\*.txt'];

% prompt user for file to load
[FileName,PathName,~] = uigetfile(FilterSpec,'MultiSelect','on');

% create empty array for overwrite observation flag
overwrite_obs = [];

% flag to return that indicates if new data was loaded
data_loaded = false;

% flag to return to indicate if advm data has been loaded
advm_data_loaded = false;

% if the path and file names are successfully returned
if (ischar(FileName) || iscell(FileName)) && all(PathName ~= 0)
    
    % get the current contents of the surrogate dataset listbox
    file_list = get(handles.SurrDataSetNames_listbox,'String');
    
    % make sure FileName is a cell array
    FileName = cellstr(FileName);
    
    % for every item in the FileName cell array
    for i = 1:length(FileName)
        
        % put together the path and file names
        newDSName = fullfile(PathName,FileName{i});
        
        % load the dataset
        newDS = dataset('File',newDSName);
        
        % format the date/time variable
        newDS = formatDSDate(newDS);
        
        % get a cell string of variable names
        newDSVarNames = get(newDS,'VarNames');
        
        % if all date/time is present
        if any(strcmp('DateTime',newDSVarNames))
            
            % if the user hasn't been prompted to overwrite variables
            if isempty(overwrite_obs)
            
                % check for variable conflicts
                overwrite_obs = check_loaded_vars( loaded_var_struct, newDS );
                
                % exit the loop and abandon loading new data if the user
                % chooses to cancel
                if ~isempty(overwrite_obs) && (overwrite_obs == -1)
                    break;
                end
            
            end
            
            % if user decided to not to cancel or hasn't been prompted yet
            if (isempty(overwrite_obs)) || (overwrite_obs ~= -1)
                
                for j = 1:length(newDSVarNames)
                    
                    var_name = newDSVarNames{j};
                    
                    % look for advm variable names
                    kAmp    = regexp(var_name,'Cell[0-9][0-9]Amp[0-9]');
                    kSNR    = regexp(var_name,'Cell[0-9][0-9]SNR[0-9]');
                    kTemp   = regexp(var_name,'ADVMTemp');
                    kVbeam  = regexp(var_name,'Vbeam');
                    
                    if any([kAmp;kSNR;kTemp;kVbeam])
                        
                        advm_data_loaded = true;
                        break;
                        
                    end
                
                end
                
                % combine the new variable dataset with the 
                loaded_var_struct = ...
                    combine_loaded_vars(loaded_var_struct,...
                    newDS,...
                    overwrite_obs);
                
                % keep track of the full dataset file path
                surr_full_file{end+1} = newDSName;
                
            end
            
        % otherwise notifiy user and do not load surrogate dataset
        else
            
            errordlg([FileName{i} ' does not contain necessary date/time information!'], ...
                'Error loading file');
            uiwait(gcf);
            
        end
        
    end
    
    % after all files are loaded, if the overwrite observation indcates 
    % that the user hasn't cancelled loading
    if (isempty(overwrite_obs) || (overwrite_obs ~= -1))
        
        % update the loaded variable structure
        setappdata(handles.figure1,'loaded_var_struct',loaded_var_struct);
        
        % update the full path list of the loaded surrogate data
        setappdata(handles.figure1,'surr_full_file',surr_full_file);
        
        % set the loaded data flag
        data_loaded = true;
        
        % update the current working directory
        setappdata(handles.figure1,'CWD',PathName);
        
    end
  
end
