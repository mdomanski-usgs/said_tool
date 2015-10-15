function clear_surr_data(handles)

setappdata(handles.figure1,'loaded_var_struct',struct);
setappdata(handles.figure1,'surr_full_file',{});

setappdata(handles.figure1,'UpdateProc',true);