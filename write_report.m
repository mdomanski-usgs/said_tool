function write_report(handles)

CWD = getappdata(handles.figure1,'CWD');

% get the file name and location for the report from the user
[ filename, pathname ] = uiputfile(fullfile(CWD,'*.csv'));

% if a valid file and path names were returned
if ischar(filename) && ischar(pathname)
    
    % get the model object
    mdl = getappdata(handles.figure1,'mdl');
    
    % get the advm configuration structure
    advmParamStruct = getappdata(handles.figure1,'advmParamStruct');
    
    if isempty(advmParamStruct)
        
        advmParamStruct = struct( ...
            'Frequency',    [],...
            'EffectiveDiameter',    [],...
            'BeamOrientation',      [],...
            'SlantAngle',           [],...
            'Nbeams',               [],...
            'BlankDistance',        [],...
            'CellSize',             [],...
            'NumberOfCells',        [],...
            'BeamNumber',           [],...
            'MovingAverageSpan',    [],...
            'BSValues',             [],...
            'IntenScale',           [],...
            'RMin',                 [],...
            'RMax',                 [],...
            'MinCells',             [],...
            'MinVbeam',             [],...
            'NearField',            [] ...
            );
        
    end
    
    % get the global full file list of data sets
%     gDSFullFile = getappdata(handles.figure1,'gDSFullFile');
    const_full_file = getappdata(handles.figure1,'const_full_file');
    surr_full_file = getappdata(handles.figure1,'surr_full_file');
    gDSFullFile = [const_full_file surr_full_file];
    
    % get text to write for the advm data file names
    DataSetTxt = [ ...
        'Dataset File Locations';...
        '----------------------';...
        gDSFullFile'...
        ];
    
    % get object text to write
    mdlDispTxt = get_mdl_disp(mdl);
    VariableStatsTxt = get_var_stats_txt(mdl);
    mdlDSTxt = get_mdlDSTxt(handles);
    
    mdlCoeffCovTxt = cell(size(mdl.CoefficientCovariance,1)+1,1);
    
    mdlCoeffCovTxt{1} = 'Variance-covariance matrix';
    
    for i = 1:length(mdl.CoefficientNames)
        mdlCoeffCovTxt{2} = [mdlCoeffCovTxt{2} ',' mdl.CoefficientNames{i}];
    end
    
    for i = 1:size(mdl.CoefficientCovariance,1)
        mdlCoeffCovTxt{i+2} = ...
            [mdl.CoefficientNames{i} ',' ...
            num2str(mdl.CoefficientCovariance(i,1))];
        for j = 2:size(mdl.CoefficientCovariance,2)
            mdlCoeffCovTxt{i+2} = ...
                [ mdlCoeffCovTxt{i+2} ',' ...
                num2str(mdl.CoefficientCovariance(i,j)) ];
        end
    end

    % convert everything in mdlDispTxt to csv
    k = strfind(mdlDispTxt{6},' ');
    k = [k(diff(k)>1) k(end)];
    for i = length(k):-1:2
        subStrRange = k(i-1)+1:k(i);
        j = strfind(mdlDispTxt{6}(subStrRange),' ');
        mdlDispTxt{6} = [mdlDispTxt{6}(1:subStrRange(j(1)-1)) ...
            ',' mdlDispTxt{6}((subStrRange(end)+1):end)];
    end
    mdlDispTxt{6} = [',' mdlDispTxt{6}(k(1)+1:end)];
    
    for i = 1:mdl.NumCoefficients
        k = strfind(mdlDispTxt{6+i},' ');
        k = [k(diff(k)>1) k(end)];
        for j = length(k):-1:2
            subStrRange = k(j-1)+1:k(j);
            l = strfind(mdlDispTxt{6+i}(subStrRange),' ');
            mdlDispTxt{6+i} = [mdlDispTxt{6+i}(1:subStrRange(l(1)-1)) ...
                ',' mdlDispTxt{6+i}((subStrRange(end)+1):end)];
        end
        subStrRange = 1:k(1);
        l = strfind(mdlDispTxt{6+i}(subStrRange),' ');
        mdlDispTxt{6+i} = [mdlDispTxt{6+i}(1:subStrRange(l(1)-1)) ...
            ',' mdlDispTxt{6+i}((subStrRange(end)+1):end)];
    end
    
    % handle remainding statistics
    for i = length(mdlDispTxt):-1:(6+mdl.NumCoefficients+3)
        if any(strfind(mdlDispTxt{i},','))
            splitstr = regexp(mdlDispTxt{i},',','split');
            mdlDispTxt = [mdlDispTxt(1:i-1); ...
                strrep(strrep(strtrim(splitstr'),': ',','),' = ',','); ...
                mdlDispTxt(i+1:end)];
        else
            mdlDispTxt{i} = strrep(mdlDispTxt{i},': ',',');
        end
    end
    
    % find Adjusted R-squared and make sure it's comma separated
    % (for some reason it doesn't have a colon)
    for i = 1:length(mdlDispTxt)
        if any(strfind(mdlDispTxt{i},'Adjusted R-Squared'))
            mdlDispTxt{i}(19) = ',';
        end
    end
     
    % change -Inf to '-Inf because Excel has a problem with displaying -Inf
    advmParamStructFieldNames = fieldnames(advmParamStruct);
    for i = 1:length(advmParamStructFieldNames)
         if any(advmParamStruct.(advmParamStructFieldNames{i}) == -Inf)
             advmParamStruct.(advmParamStructFieldNames{i}) = '''-Inf';
         end
    end
    
    advmParamTxt = { ...
        ['Frequency (kHz):,'        num2str(advmParamStruct.Frequency)];...
        ['Effective Diameter (m):,' num2str(advmParamStruct.EffectiveDiameter)];...
        ['Beam Orientation:,'       num2str(advmParamStruct.BeamOrientation)];...
        ['Slant Angle (deg):,'      num2str(advmParamStruct.SlantAngle)];...
        ['Nbeams:,'                 num2str(advmParamStruct.Nbeams)];...
        ['Blanking Distance (m):,'  num2str(advmParamStruct.BlankDistance)];...
        ['Cell Size (m):,'          num2str(advmParamStruct.CellSize)];...
        ['Number of Cells:,'        num2str(advmParamStruct.NumberOfCells)];...
        ['Beam Number:,'            num2str(advmParamStruct.BeamNumber)];...
        ['Moving Average Span:,'    num2str(advmParamStruct.MovingAverageSpan)];...
        ['Backscatter Values:,'     num2str(advmParamStruct.BSValues)];...
        ['Intensity Scale Factor:,' num2str(advmParamStruct.IntenScale)];...
        ['RMin (m):,'               num2str(advmParamStruct.RMin)];...
        ['RMax (m):,'               num2str(advmParamStruct.RMax)];...
        ['Min Cells:,'              num2str(advmParamStruct.MinCells)];...
        ['Min Vbeam (m):,'          num2str(advmParamStruct.MinVbeam)];...
        ['Near Field Correction:,'  num2str(advmParamStruct.NearField)]; ...
        ['Remove Minimum WCB:,'     num2str(advmParamStruct.RemoveMinWCB)] ...
        };
    
    % put cells to write in an array
    mdlWriteTxt = [ ...
        advmParamTxt; ' ';
        DataSetTxt; ' ';
        mdlDispTxt; ' ';
        mdlCoeffCovTxt; ' ';
        VariableStatsTxt; ' ';
        'Observations';
        mdlDSTxt];    
    
    % open the report file for writing
    fid = fopen(fullfile(pathname,filename),'w');
    
    % if the file was successfully opened, write it
    if fid > 0
        
        % write every line in the array
        for k = 1:length(mdlWriteTxt)
            fprintf(fid,'%s\r\n',mdlWriteTxt{k});
        end
        
        % close the file
        fclose(fid);
        
        [~,name]=fileparts(filename);
        
        write_mdl_output(mdl,fullfile(pathname,name));
        
    else
        
        % if the file wasn't successfully opened, notify the user
        msgbox(['Unable to write ' fullfile(pathname,filename)],...
            'Write Error','error');
    end
    
end

end

function mdlDSTxt = get_mdlDSTxt(handles)

mdl = getappdata(handles.figure1,'mdl');

% dateVarNames = getappdata(handles.figure1,'dateVarNames');
% dateVarValue = getappdata(handles.figure1,'dateVarValue');

% get the model variable dataset
% mdlDS = mdl.Variables;
mdlDS = table2dataset(mdl.Variables);


% dateVarName = dateVarNames{dateVarValue-1};
dateVarName = 'DateTime';

% find the indices for the included observations
iObs = ~mdl.ObservationInfo.Missing;

% find the indices for the excluded observations
iExcluded = mdl.ObservationInfo.Excluded;

% iInModel = iObs & ~iExcluded;


% initialize cell array to hold data set text
mdlDSTxt = cell(size(mdlDS,1)+1,1);

% assign observation numbers
ObservationNumbers = (1:size(mdlDS,1))';
% ObservationNumbers = ObservationNumbers(iObs);

mdlDSVarNames = mdlDS.Properties.VarNames;
% mdlDSVarNames = mdlDS.Properties.VariableNames;

for k = 1:length(mdlDSVarNames)
%     
%     % convert the sample date and times to text
%     if strfind(mdlDSVarNames{k},'DateTime')
%         mdlDS.(mdlDSVarNames{k}) = ...
%             datestr(mdlDS.(mdlDSVarNames{k}),'mm/dd/yyyy HH:MM:SS');
        
    % remove variables that are too long (e.g. R, MB, WCB, SCB,...)
%     elseif size(mdlDS.(mdlDSVarNames{k})) > 1
    if size(mdlDS.(mdlDSVarNames{k})) > 1
        mdlDS.(mdlDSVarNames{k}) = [];
    end
% 
end

% create fitted response name variable
% mdlDS.(['Fitted' mdl.ResponseName]) = mdl.Fitted(iObs);
mdlDS.(['Fitted' mdl.ResponseName]) = mdl.Fitted;

% get the raw residual values
% mdlDS.RawResiduals = mdl.Residuals.Raw(iObs);
mdlDS.RawResiduals = mdl.Residuals.Raw;

mdlDS.NormalQuantile = nan(length(mdlDS),1);
% mdlDS.NormalQuantile = nan(height(mdlDS),1);

% if the response variable is transformed, get estimated values in
% linear space
if ~isempty([strfind(mdl.ResponseName,'log10')
        strfind(mdl.ResponseName,'ln')
        strfind(mdl.ResponseName,'pow')
        strfind(mdl.ResponseName,'root')])
    [EstDS, ResponseBaseName] = smear_estimate(mdl,mdlDS);
    mdlDS.(['Estimated' ResponseBaseName]) = EstDS.(ResponseBaseName);
end

% get the standardized residuals
mdlDS.StandardizedResiduals = mdl.Residuals.Standardized;
mdlDS.Leverage=mdl.Diagnostics.Leverage;
mdlDS.CooksD=mdl.Diagnostics.CooksDistance;
mdlDS.Dffits=mdl.Diagnostics.Dffits;

[mdlDS,idx] = sortrows(mdlDS,'RawResiduals');

ObservationNumbers = ObservationNumbers(idx);
iObs = iObs(idx);
iExcluded = iExcluded(idx);

% get the length of the remaining residual vector
n = sum(~isnan(mdlDS.RawResiduals));

% calculate the plotting position
ppos = ((1:n)'-0.4)/(n+0.2);

% get the quantiles
q = norminv(ppos);

mdlDS.NormalQuantile(~isnan(mdlDS.RawResiduals)) = q;

[mdlDS,idx] = sortrows(mdlDS,dateVarName);

for k = 1:length(mdlDSVarNames)
    
    % convert the sample date and times to text
    if strfind(mdlDSVarNames{k},'DateTime')
        mdlDS.(mdlDSVarNames{k}) = ...
            datestr(mdlDS.(mdlDSVarNames{k}),'mm/dd/yyyy HH:MM:SS');
        
%     remove variables that are too long (e.g. R, MB, WCB, SCB,...)
%     elseif size(mdlDS.(mdlDSVarNames{k})) > 1
%         mdlDS.(mdlDSVarNames{k}) = [];
    end

end

ObservationNumbers = ObservationNumbers(idx);
iObs = iObs(idx);
iExcluded = iExcluded(idx);

% get string representations of the data set
mdlDS = datasetfun(@(x)num2str(x,'%g'),mdlDS,'DatasetOutput',true);
% mdlDS = rowfun(@(x)num2str(x,'%g'),mdlDS);
% mdlDS = varfun(@(x)num2str(x,'%g'),mdlDS);

% remove 'Fun_' from the variable names that varfun adds for some reason...
% for i = 1:width(mdlDS)
%     
%     oldVarName = mdlDS.Properties.VarNames{i};
%     newVarName = strrep(oldVarName,'Fun_','');
%     
%     mdlDS.Properties.VarNames{oldVarName} = newVarName;
%     
% end


% get the number of data set variables
nDSVars = size(mdlDS,2);

% convert the data set to a cell array
mdlDScell = dataset2cell(mdlDS);
% mdlDScell = table2cell(mdlDS);

mdlDScell = strtrim(mdlDScell);

for i = 1:size(mdlDScell,1)
    for j = 1:size(mdlDScell,2)
        if ~isempty(strfind(mdlDScell{i,j},'NaN'))
            mdlDScell{i,j} = ' ';
        end
    end
end

mdlDScell = [ ...
    ['Observation Number'; cellstr(num2str(ObservationNumbers))]...
    ['Missing'; cellstr(num2str(~iObs))]...
    ['Excluded'; cellstr(num2str(iExcluded))]...
    mdlDScell
%     [mdlDS.Properties.VariableNames; mdlDScell]...
    ];

% header line
mdlDSTxt{1} = sprintf(['%s' repmat(',%s',1,nDSVars+2)],mdlDScell{1,:});

for k = 2:size(mdlDScell,1)
    mdlDSTxt{k} = sprintf(['%s' repmat(',%s',1,nDSVars+2)],...
        mdlDScell{k,1},mdlDScell{k,2:end});
end

end

function excludeDSTxt = get_excludeDSTxt(handles)

excludeDS = getappdata(handles.figure1,'excludeDS');

if ~isempty(excludeDS)
    
    % initialize cell array to hold data set text
    excludeDSTxt = cell(length(excludeDS)+1,1);
    
    excludeDSVarNames = excludeDS.Properties.VarNames;
    
    for k = 1:length(excludeDSVarNames)
        
        % convert the sample date and times to text
        if strfind(excludeDSVarNames{k},'DateTime')
            excludeDS.(excludeDSVarNames{k}) = ...
                datestr(excludeDS.(excludeDSVarNames{k}),'mm/dd/yyyy HH:MM:SS');
            
            % remove variables that are too long (e.g. R, MB, WCB, SCB,...)
        elseif size(excludeDS.(excludeDSVarNames{k}),2) > 1
            excludeDS.(excludeDSVarNames{k}) = [];
        else
            excludeDS.(excludeDSVarNames{k}) = ...
                num2str(excludeDS.(excludeDSVarNames{k}),'%g');
        end
        
    end
    
    % get string representations of the data set
%     excludeDS = datasetfun(@(x)num2str(x,'%g'),excludeDS,'DatasetOutput',true);
    
    % get the number of data set variables
    nDSVars = size(excludeDS,2);
    
    % convert the data set to a cell array
    excludeDScell = dataset2cell(excludeDS);
    
    % header line
    excludeDSTxt{1} = sprintf(['%s' repmat(',%s',1,nDSVars-1)],excludeDScell{1,:});
    
    for k = 2:length(excludeDS)+1
        excludeDSTxt{k} = sprintf(['%s' repmat(',%s',1,nDSVars-1)],...
            excludeDScell{k,1},excludeDScell{k,2:end});
    end

else
    excludeDSTxt = {};
end

% excludeDSTxt = dataset2cell(excludeDS);

end

function write_mdl_output(mdl,outputFullFile)

% alpha value for t distribution
% alpha = 1 - 0.95;
alpha = 1 - 0.90;

% number of observations in the model
n = mdl.NumObservations;

% number of parameters in the model
p = mdl.NumCoefficients;

% open output file for writing
fid = fopen(outputFullFile,'w');

% get the name of the predictor variable
PredictorNames = mdl.PredictorNames;

% allocate space for the X matrix
X = zeros(mdl.NumObservations,mdl.NumPredictors+1);

% fill intercept column
X(:,1) = ones(1,mdl.NumObservations);

% fill other variable columns with observation values
for k = 1:length(PredictorNames)
    X(:,k+1) = mdl.Variables.(PredictorNames{k})(...
        ~mdl.ObservationInfo.Missing & ~mdl.ObservationInfo.Excluded);
end

% compute the X prime X inverse matrix
XprimeXinverseMat = (X'*X)^-1;

% get the raw residuals
% RawResiduals = mdl.Residuals.Raw(~mdl.ObservationInfo.Missing);
RawResiduals = mdl.Residuals.Raw(...
        ~mdl.ObservationInfo.Missing & ~mdl.ObservationInfo.Excluded);

%%%%% begin writing to file

% write number of observations and number of coefficients to file
% fprintf(fid,'%i\n',p);
% fprintf(fid,'%i\n',n);
% change newline to comma - 20140331 MMD
fprintf(fid,'%i,',p);
fprintf(fid,'%i,',n);

% write intercept to file
fprintf(fid,'%f',mdl.Coefficients.Estimate(1));

% write variable coefficients to file
for k = 2:length(mdl.Coefficients.Estimate)
    fprintf(fid,',%f',mdl.Coefficients.Estimate(k));
end
% fprintf(fid,'\n');
% change newline to comma - 20140331 MMD
fprintf(fid,',');


% write t-value to file
% fprintf(fid,'%f\n', tinv(1-alpha/2,n-p));
% change newline to comma - 20140331 MMD
fprintf(fid,'%f,',tinv(1-alpha/2,n-p));

% write the model mean sqaured error
% fprintf(fid,'%f\n',mdl.MSE);
% change newline to comma - 20140331 MMD
fprintf(fid,'%f,',mdl.MSE);

% write X prime X inverse matrix to file
for k = 1:size(XprimeXinverseMat,1)
    fprintf(fid,'%f',XprimeXinverseMat(k,1));
    for j = 2:size(XprimeXinverseMat,2)
        fprintf(fid,',%f',XprimeXinverseMat(k,j));
    end
%     fprintf(fid,'\n');
    % change newline to comma - 20140331 MMD
    fprintf(fid,',');
end

fprintf(fid,'%f',RawResiduals(1));

% write raw residuals to file
for k = 2:length(RawResiduals)
%     fprintf(fid,'%f\n',RawResiduals(k));
    % change newline to comma - 20140331 MMD
    fprintf(fid,',%f',RawResiduals(k));
end

% close file
fclose(fid);

end

function VariableStatsTxt = get_var_stats_txt(mdl)

VariableStatsTxt = {'Explanatory variable summary statistics'};

iObs = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

PredictorNames = mdl.PredictorNames;

for i = 1:length(PredictorNames)
    
    predictorStatsTxt = cell(7,1);
    
    predictorStatsTxt{1} = ' ';
    predictorStatsTxt{2} = 'Minimum';
    predictorStatsTxt{3} = '1st Quartile';
    predictorStatsTxt{4} = 'Median';
    predictorStatsTxt{5} = 'Mean';
    predictorStatsTxt{6} = '3rd Quartile';
    predictorStatsTxt{7} = 'Maximum';
    
    name = PredictorNames{i};
    
    VAR = mdl.Variables.(name)(iObs);
    
    VarDS = dataset({VAR,name});
    
    ntVarDS = retransformVarDS(VarDS);
    
    VarDSNames = ntVarDS.Properties.VarNames;
    
    for j = 1:length(VarDSNames)
        
        predictorStatsTxt{1} = [predictorStatsTxt{1} ',' VarDSNames{j}];
        
        Y = quantile(ntVarDS.(VarDSNames{j}),[0 0.25 0.5 0.75 1]);
        
        predictorStatsTxt{2} = [predictorStatsTxt{2} ',' num2str(Y(1))];
        predictorStatsTxt{3} = [predictorStatsTxt{3} ',' num2str(Y(2))];
        predictorStatsTxt{4} = [predictorStatsTxt{4} ',' num2str(Y(3))];
        predictorStatsTxt{5} = [predictorStatsTxt{5} ',' num2str(mean(ntVarDS.(VarDSNames{j})))];
        predictorStatsTxt{6} = [predictorStatsTxt{6} ',' num2str(Y(4))];
        predictorStatsTxt{7} = [predictorStatsTxt{7} ',' num2str(Y(5))];
        
    end
    
    VariableStatsTxt = [VariableStatsTxt; ' '; predictorStatsTxt];
    
end

responseStatsTxt = cell(7,1);

responseStatsTxt{1} = ' ';
responseStatsTxt{2} = 'Minimum';
responseStatsTxt{3} = '1st Quartile';
responseStatsTxt{4} = 'Median';
responseStatsTxt{5} = 'Mean';
responseStatsTxt{6} = '3rd Quartile';
responseStatsTxt{7} = 'Maximum';

name = mdl.ResponseName;

VAR = mdl.Variables.(name)(iObs);

VarDS = dataset({VAR,name});

ntVarDS = retransformVarDS(VarDS);

VarDSNames = ntVarDS.Properties.VarNames;

for k = 1:length(VarDSNames)
    
    responseStatsTxt{1} = [responseStatsTxt{1} ',' VarDSNames{k}];
    
    Y = quantile(ntVarDS.(VarDSNames{k}),[0 0.25 0.5 0.75 1]);
    
    responseStatsTxt{2} = [responseStatsTxt{2} ',' num2str(Y(1))];
    responseStatsTxt{3} = [responseStatsTxt{3} ',' num2str(Y(2))];
    responseStatsTxt{4} = [responseStatsTxt{4} ',' num2str(Y(3))];
    responseStatsTxt{5} = [responseStatsTxt{5} ',' num2str(mean(ntVarDS.(VarDSNames{k})))];
    responseStatsTxt{6} = [responseStatsTxt{6} ',' num2str(Y(4))];
    responseStatsTxt{7} = [responseStatsTxt{7} ',' num2str(Y(5))];
    
end

VariableStatsTxt = [VariableStatsTxt; ' ';...
    'Response variable summary statistics'; ' '; ...
    responseStatsTxt];

end

function ntVarDS = retransformVarDS(VarDS)

VarNames = VarDS.Properties.VarNames;
ntVarDS = VarDS;

for i = 1:length(VarNames)
    if any(strfind(VarNames{i},'pow5'))
        finv = @(x) x.^(1/5);
        name = VarNames{i}(5:end);
        tf = true;
    elseif any(strfind(VarNames{i},'pow4'))
        finv = @(x) x.^(1/4);
        name = VarNames{i}(5:end);
        tf = true;
    elseif any(strfind(VarNames{i},'pow3'))
        finv = @(x) x.^(1/3);
        name = VarNames{i}(5:end);
        tf = true;
    elseif any(strfind(VarNames{i},'pow2'))
        finv = @(x) x.^(1/2);
        name = VarNames{i}(5:end);
        tf = true;
    elseif any(strfind(VarNames{i},'root2'))
        finv = @(x) x.^2;
        name = VarNames{i}(6:end);
        tf = true;
    elseif any(strfind(VarNames{i},'root3'))
        finv = @(x) x.^3;
        name = VarNames{i}(6:end);
        tf = true;
    elseif any(strfind(VarNames{i},'root4'))
        finv = @(x) x.^4;
        name = VarNames{i}(6:end);
        tf = true;
    elseif any(strfind(VarNames{i},'root5'))
        finv = @(x) x.^5;
        name = VarNames{i}(6:end);
        tf = true;
    elseif any(strfind(VarNames{i},'ln'))
        finv = @(x) exp(x);
        name = VarNames{i}(3:end);
        tf = true;
    elseif any(strfind(VarNames{i},'log10'))
        finv = @(x) 10.^x;
        name = VarNames{i}(6:end);
        tf = true;
    else
        tf = false;
    end
    
    if tf
        VAR = finv(VarDS.(VarNames{i}));
        ntVarDS = [ntVarDS dataset({VAR,name})];
    end
    
end

end