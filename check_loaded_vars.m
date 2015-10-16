function overwrite_obs = check_loaded_vars( loaded_vars, newDS )

% set default return value
overwrite_obs = [];

% get the names of the loaded variables
loaded_var_names = fieldnames( loaded_vars );

% get the names of the newly loaded dataset
% newDS_var_names = get(newDS, 'VarNames');
newDS_var_names = newDS.Properties.VariableNames;

% query string to use for user dialog
qstring = ['New variable observations conflict with previously ' ...
    'loaded observations. Overwrite or keep previously loaded '...
    'observations where conflicts exist?'];

% for every loaded variable name
for i = 1:length(loaded_var_names)
    
    % get the name of the loaded variable
    old_var_name = loaded_var_names{i};
    
    % test to see if any of the new variables are already loaded
    TF = strcmp(old_var_name,newDS_var_names);
    
    % if any new variables are already loaded
    if any(TF)
        
        % get the date/time index of the new variable
        new_var_datetime = newDS.DateTime;
        
        % get the date/time index of the old variable
        old_var_datetime = loaded_vars.(old_var_name).DateTime;
        
        % if any of the old variable date/time indices are in the new
        % variable indices
        if any(ismember(old_var_datetime,new_var_datetime))
            
            % prompt the user for what to do
            button = questdlg(qstring, 'Overwite data', ...
                'Overwrite', ...
                'Keep', ...
                'Cancel', ...
                'Cancel');
            
            % set the corresponding code to the returned variable
            if strcmp(button,'Overwrite existing data')
                overwrite_obs = 1;
            elseif strcmp(button,'Keep existing data')
                overwrite_obs = 0;
            elseif strcmp(button,'Cancel')
                overwrite_obs = -1;
            end
            
            break;
            
        end
        
    end
    
end