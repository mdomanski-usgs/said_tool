function var_ds = trans_ds_vars(var_ds, trans_vars)

for i = 1:size(trans_vars,1)
    
    transform_var = trans_vars{i,1};
    trans = trans_vars{i,2};
    
    trans_val = var_ds.(transform_var);
    
    trans_val_name = [trans transform_var];
    
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
    
    var_ds.(trans_val_name) = trans_val;
    
end