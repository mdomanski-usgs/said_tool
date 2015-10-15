function oDS = formatDSDate(iDS)

% create a copy for the output data set
oDS = iDS;

ds_var_names = get(iDS,'VarNames');

% if the date/information is in columns
if (any(strcmp('y',ds_var_names)) && ...
        any(strcmp('m',ds_var_names)) && ...
        any(strcmp('d',ds_var_names)) && ...
        any(strcmp('H',ds_var_names)) && ...
        any(strcmp('M',ds_var_names)) && ...
        any(strcmp('S',ds_var_names)))

    % convert the date/time values to MATLAB serial number
    oDS.DateTime = datenum([iDS.y iDS.m iDS.d iDS.H iDS.M iDS.S]);

    % remove the date time variables
    oDS.y = [];
    oDS.m = [];
    oDS.d = [];
    oDS.H = [];
    oDS.M = [];
    oDS.S = [];
    
elseif (any(strcmp('Date',ds_var_names)) && ...
        any(strcmp('Time',ds_var_names)))
    
    [y, m, d] = datevec(iDS.Date);
    [~, ~, ~, H, M, S] = datevec(iDS.Time);
    
    oDS.DateTime = datenum([y m d H M S]);
    
    oDS.Date = [];
    oDS.Time = [];

% otherwise, if the DateTime variable is already present
elseif any(strcmp('DateTime',ds_var_names))
    
    % convert the string to a matlab serial number
    oDS.DateTime = datenum(iDS.DateTime);
    
end
