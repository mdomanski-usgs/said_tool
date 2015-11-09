function clear_const_data(handles)

% const_ds = dataset();
const_ds = table();
% const_ds.DateTime = NaN;
% setappdata(handles.figure1,'const_ds',const_ds);

setappdata(handles.figure1,'const_full_file',{});
setappdata(handles.figure1,'const_ds',const_ds);

