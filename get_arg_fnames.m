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