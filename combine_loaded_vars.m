function loaded_var_struct = combine_loaded_vars( loaded_var_struct, newDS, overwrite_obs)

% get the names of the loaded variables
loaded_var_names = fieldnames(loaded_var_struct);

% get the names of the newly loaded dataset
% new_var_names = get(newDS,'VarNames');
new_var_names = newDS.Properties.VariableNames;

% if the overwrite observation flag is empty, assume the user hasn't been
% prompted, and set it to false
if isempty(overwrite_obs)
    overwrite_obs = false;
end

% for every new variable name
for i = 1:length(new_var_names)
    
    % get the name of the variable
    var_name = new_var_names{i};
    
    % skip the date/time index variable
    if ~strcmp(var_name,'DateTime')
        
        % create a dataset of the variable for the recently loaded dataset
        new_var_ds = dataset({newDS.DateTime,'DateTime'},...
            {newDS.(var_name),var_name});
        
        % if the variable has multiple columns, assume it's backscatter and
        % skip it
%         if ~(size(new_var_ds.(var_name),2) > 1)
            
            % remove null observations from dataset
%             iNaN = all(isnan(new_var_ds.(var_name)),2);
%             new_var_ds(iNaN,:) = [];
        
%         end
        
        % check to see if the variable is alreadly loaded
        TF = strcmp(var_name,loaded_var_names);
        
        % if the variable is already loaded
        if any(TF)
            
            % check to see if any simultaneous observations exist
            [Lia,Locb] = ...
                ismember(loaded_var_struct.(var_name).DateTime,new_var_ds.DateTime);
            
            % if the overwrite observation flag is set to true
            if overwrite_obs
                
                % overwrite existing observations with newly loaded
                % simultaneous observations
                loaded_var_struct.(var_name).(var_name)(Lia) = ...
                    new_var_ds.(var_name)(Locb(Lia));
                
            end
            
            % concatenate the existing variable dataset with the
            % non-simultaneous observations of the new dataset
            loaded_var_struct.(var_name) = vertcat( ...
                loaded_var_struct.(var_name), ...
                new_var_ds(~ismember(1:length(new_var_ds),Locb),:));
            
        % if the variable is not already loaded
        else
            
            % add a field to the structure and assign the new variable
            % dataset to it
            loaded_var_struct.(var_name)= new_var_ds;
            
        end
        
        % sort the dataset by the data/time serial number
        loaded_var_struct.(var_name) = ...
            sortrows(loaded_var_struct.(var_name),'DateTime');
        
    end
    
end
