function var_struct = trans_struct_vars(var_struct, trans_vars)

% get the variable names
struct_var_names = fieldnames(var_struct);

overwrite_obs = true;

% for each variable transformation
for i = 1:size(trans_vars,1)
    
    % get the variable name
    transform_var = trans_vars{i,1};
    
    % get the transformation
    trans = trans_vars{i,2};
    
    % if the variable exists in the structure
    if any(strcmp(transform_var,struct_var_names))
        
        % get the value of the variable observations
        trans_val = var_struct.(transform_var).(transform_var);
        
        % get the name of the transformed variable
        trans_val_name = [trans transform_var];
        
        % find the transformation and transform the variable
        if strfind(trans,'pow')==1
            powerValue=str2double(trans(end));
            trans_val=power(trans_val,powerValue);
        elseif strfind(trans,'root')==1
            rootValue=str2double(trans(end));
            trans_val(trans_val < 0) = NaN;
            trans_val=nthroot(trans_val,rootValue);
        elseif strcmp(trans,'ln')
            trans_val(trans_val < 0) = NaN;
            trans_val=log(trans_val);
        elseif strcmp(trans,'log10')
            trans_val(trans_val < 0) = NaN;
            trans_val=log10(trans_val);
        end
        
        % add the transformed variable dataset to the structure
        trans_var_ds = dataset( ...
            {var_struct.(transform_var).DateTime, 'DateTime'}, ...
            {trans_val, trans_val_name} );
        var_struct.(trans_val_name) = trans_var_ds;
%         var_struct = ...
%             combine_loaded_vars(var_struct,trans_var_ds,overwrite_obs);
        
    end
    
end