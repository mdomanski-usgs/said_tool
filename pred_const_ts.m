function [est_ds, response_name] = pred_const_ts(FileName, PathName, ...
    mdl, advm_param_struct, trans_vars)

% variables that require advm data processing
advm_proc_var_names = {'alphaS', 'MeanSCB'};

% inizialize empty structure to hold variable datasets
var_struct = struct();

% initialize flags
advm_proc_vars = false;
overwrite_obs = true;

% get model predictor names
predictor_names = mdl.PredictorNames;

% find out if advm parameters are in the predictor names
for i = 1:length(advm_proc_var_names)
    if any(cellfun(@any,strfind(predictor_names,advm_proc_var_names{i})))
        advm_proc_vars = true;
        continue;
    end
end

% make sure FileName is a cell array
FileName = cellstr(FileName);

% for each file name
for i = 1:length(FileName)
    
    % load the dataset
    ds_name = fullfile(PathName,FileName{i});
    ds = dataset('File',ds_name);
    ds = dataset2table(ds);
    
    % convert the date/time to a MATLAB serial number
    ds = formatDSDate(ds);
    
    % get the variable names in the dataset
%     ds_var_names = get(ds,'VarNames');
    ds_var_names = ds.Properties.VariableNames;
    
    % if the date/time index is found in the newly loaded dataset, load
    % add the variables to the loaded variable structure
    if any(strcmp('DateTime',ds_var_names))
        var_struct = combine_loaded_vars(var_struct,ds,overwrite_obs);
        
        % otherwise notifiy user and do not load dataset
    else
        h = errordlg([FileName{i} ' does not contain necessary date/time information!'], ...
            'Error loading file');
        uiwait(gcf);
    end
    
end

% if advm parameters are in the predictor variables, calculate the
% parameters
if advm_proc_vars
    var_struct = proc_advm_vars(var_struct,advm_param_struct);
end

% transform the necessary variables
var_struct = trans_struct_vars(var_struct,trans_vars);

% convert the loaded variable structure to a dataset to pass to the linear
% model
pred_ts_ds = lvs_to_ds(var_struct);

% attempt to build a linear model with the dataset
try
    
    % estimate loaded data series and smear if necessary
    [est_ds, response_name] = smear_estimate(mdl, pred_ts_ds, 'observation');
% catch error
catch err
    % if the error is expected, handle it
    if strcmp(err.identifier,...
            'stats:classreg:regr:TermsRegression:MissingVariable')
        msgbox(['The dataset selected does not contain one or more '...
            'predictor variables needed for this model.'],...
            'Missing Variables','error');
        
        est_ds = [];
        response_name = [];
        
        return;
        
    % otherwise rethrow the error
    else
        rethrow(err);
    end
end

end % pred_const_ts


function loaded_var_ds = lvs_to_ds(loaded_var_struct)

loaded_var_names = fieldnames(loaded_var_struct);

DateTime = NaN;

for i = 1:length(loaded_var_names)
    
    var_name = loaded_var_names{i};
    
    var_DateTime = loaded_var_struct.(var_name).DateTime;
    
    % if DateTime is still NaN
    if isnan(DateTime)
        
        % assign the DateTime variable of the current dataset to it
        DateTime = var_DateTime;
        
    else
        
        % find which date/time values are already in the cumulative
        % array
        Lia = ismember(var_DateTime, DateTime);
        
        % add the newly found date/time values to the cumulative array
        DateTime = [DateTime; var_DateTime(~Lia)];
        
        % sort the date/time values
        DateTime = sort(DateTime);
        
    end
    
end

% number of observations (rows)
mObs = length(DateTime);

% number of variables (columns)
% include one for the date/time index
nVars = length(loaded_var_names) + 1;

% create a nan array to hold values
var_array = nan(mObs,nVars);

% fill first column with date/time index
var_array(:,1) = DateTime;

% loop through variables and fill array
for i = 1:length(loaded_var_names)
    
    var_name = loaded_var_names{i};
    
    var_DateTime = loaded_var_struct.(var_name).DateTime;
    var_obs_values = loaded_var_struct.(var_name).(var_name);
    
    [Lia,Locb] = ismember(var_DateTime, DateTime);
    
    var_array(Locb(Lia),i+1) = var_obs_values(Lia);
    
end

col_names = [{'DateTime'} loaded_var_names'];

loaded_var_ds = dataset([var_array col_names]);

end % lvs_to_ds