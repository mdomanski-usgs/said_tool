function [EstDS, ResponseName] = smear_estimate(mdl, PredDS, varargin)

if nargin > 2
    Prediction = varargin{1};
else
    Prediction = 'curve';
end

alpha = 0.10;

% allocate space for predictor variables
if isa(PredDS, 'dataset')
    PredVarMatrix = zeros(length(PredDS),mdl.NumPredictors);
    var_names = PredDS.Properties.VarNames;
elseif isa(PredDS, 'table')
    PredVarMatrix = zeros(height(PredDS),mdl.NumPredictors); % changed for 2014a - MMD 20151015
    var_names = PredDS.Properties.VariableNames;
end

% determine inverse of response variable transformation
if strfind(mdl.ResponseName,'log10')==1
    ResponseName = strrep(mdl.ResponseName,'log10','');
    f_inv = @(x) 10.^x;
elseif strfind(mdl.ResponseName,'ln')==1
    ResponseName = strrep(mdl.ResponseName,'ln','');
    f_inv = @(x) exp(x);
elseif strfind(mdl.ResponseName,'pow')==1
    powerValue = str2double(mdl.ResponseName(4));
    ResponseName = mdl.ResponseName(5:end);
    f_inv = @(x) nthroot(x,powerValue);
elseif strfind(mdl.ResponseName,'root')==1
    rootValue = str2double(mdl.ResponseName(5));
    ResponseName = mdl.ResponseName(6:end);
    f_inv = @(x) power(x,rootValue);
else
    ResponseName = mdl.ResponseName;
    f_inv = @(x) x;
end

% check for the presence of the model predictors in the loaded dataset
for k = 1:mdl.NumPredictors
    
    PredictorName = mdl.PredictorNames{k};
    
    if ~ismember(PredictorName,var_names)
    
        if strfind(mdl.PredictorNames{1},'log10')==1
            LinearPredictorName = strrep(PredictorName,'log10','');
            f_pred = @(x) log10(x);
        elseif strfind(mdl.PredictorNames{1},'ln')==1
            LinearPredictorName = PredictorName(3:end);
            f_pred = @(x) log(x);
        elseif strfind(mdl.PredictorNames{1},'pow')==1
            powerValue = str2double(mdl.ResponseName(4));
            LinearPredictorName = PredictorName(5:end);
            f_pred = @(x) pow(x,powerValue);
        elseif strfind(mdl.PredictorNames{1},'root')==1
            rootValue = str2double(mdl.ResponseName(5));
            LinearPredictorName = PredictorName(6:end);
            f_pred = @(x) root(x,rootValue);
        else
            LinearPredictorName = PredictorName;
            f_pred = @(x) x;
        end
        
%         if ismember(LinearPredictorName,PredDS.Properties.VarNames)
        if ismember(LinearPredictorName, var_names) % changed for 2014a - MMD 20151015
            
            PredDS.(PredictorName) = f_pred(PredDS.(LinearPredictorName));
            
        end
        
    end
    
end
% if strfind(mdl.PredictorNames{1},'log10')==1
%     PredictorName = strrep(mdl.PredictorNames{1},'log10','');
%     f_inv_pred = @(x) 10.^x;
% elseif strfind(mdl.PredictorNames{1},'ln')==1
%     PredictorName = mdl.PredictorNames{1}(3:end);
%     f_inv_pred = @(x) exp(x);
% elseif strfind(mdl.PredictorNames{1},'pow')==1
%     powerValue = str2double(mdl.ResponseName(4));
%     PredictorName = mdl.PredictorNames{1}(5:end);
%     f_inv_pred = @(x) nthroot(x,powerValue);
% elseif strfind(mdl.PredictorNames{1},'root')==1
%     rootValue = str2double(mdl.ResponseName(5));
%     PredictorName = mdl.PredictorNames{1}(6:end);
%     f_inv_pred = @(x) power(x,rootValue);
% else
%     PredictorName = mdl.PredictorNames{1};
%     f_inv_pred = @(x) x;
% end

% if all predictor names aren't present in the passed data set, duplicate
% the error created by the LinearModel class
if ~all(ismember(mdl.PredictorNames,var_names))
    error('stats:classreg:regr:TermsRegression:MissingVariable',...
        ['X does not contain one or more predictor variables '...
        'needed for this model.']);
end

% put predictor variables in matrix
for k = 1:mdl.NumPredictors
    PredVarMatrix(:,k) = PredDS.(mdl.PredictorNames{k});
end

% get the predicted value and the confidence interval
[ypred,yci] = mdl.predict(PredDS,'Prediction',Prediction,'alpha',alpha);

% get the uppper and lower bounds of the predicted values
ypredLB = yci(:,1);
ypredUB = yci(:,2);

% add residuals to predicted values
% a = bsxfun(@plus,mdl.predict(PredDS),mdl.Residuals.Raw');
amean = bsxfun(@plus,ypred,mdl.Residuals.Raw');
aLB = bsxfun(@plus,ypredLB,mdl.Residuals.Raw');
aUB = bsxfun(@plus,ypredUB,mdl.Residuals.Raw');

% take inverse of transformation
bmean = f_inv(amean);
bLB = f_inv(aLB);
bUB = f_inv(aUB);

% get the sum of the inverse
cmean = nansum(bmean,2);
cLB = nansum(bLB,2);
cUB = nansum(bUB,2);

% get the new mean of the predicted values
PredMean = cmean/mdl.NumObservations;
PredLB = cLB/mdl.NumObservations;
PredUB = cUB/mdl.NumObservations;


% create dataset for predicted values
if ~strcmp(mdl.ResponseName, ResponseName)

    EstDS = dataset(...
        {ypred, mdl.ResponseName},...;
        {PredLB, [ResponseName 'L90']},...
        {PredMean, ResponseName},...
        {PredUB, [ResponseName 'U90']});

else

    EstDS = dataset(...
        {PredLB, [ResponseName 'L90']},...
        {PredMean, ResponseName},...
        {PredUB, [ResponseName 'U90']});
    
end

% addded for 2014a - MMD 20151015
% EstDS = dataset2table(EstDS);

if isa(PredDS, 'dataset')
    DateTime = PredDS(:,~cellfun(@isempty,strfind(PredDS.Properties.VarNames,'DateTime')));
elseif isa(PredDS, 'table')
    DateTime = PredDS(:,~cellfun(@isempty,strfind(PredDS.Properties.VariableNames,'DateTime'))); % changed for 2014a - MMD 20151015
end

if isa(DateTime, 'dataset')
    EstDS = [DateTime EstDS];
elseif isa(DateTime, 'table')
    EstDS = [table2dataset(DateTime) EstDS];
end

for k = 1:mdl.NumPredictors
    
    
    if strfind(mdl.PredictorNames{k},'log10')==1
        PredictorName = strrep(mdl.PredictorNames{k},'log10','');
        f_inv_pred = @(x) 10.^x;
    elseif strfind(mdl.PredictorNames{k},'ln')==1
        PredictorName = mdl.PredictorNames{1}(3:end);
        f_inv_pred = @(x) exp(x);
    elseif strfind(mdl.PredictorNames{k},'pow')==1
        powerValue = str2double(mdl.ResponseName(4));
        PredictorName = mdl.PredictorNames{1}(5:end);
        f_inv_pred = @(x) nthroot(x,powerValue);
    elseif strfind(mdl.PredictorNames{k},'root')==1
        rootValue = str2double(mdl.PredictorNames{k}(5));
        PredictorName = mdl.PredictorNames{k}(6:end);
        f_inv_pred = @(x) power(x,rootValue);
    else
        PredictorName = mdl.PredictorNames{k};
        f_inv_pred = @(x) x;
    end
    
    if ~strcmp(PredictorName,mdl.PredictorNames{k})
        EstDS.(PredictorName) = f_inv_pred(PredDS.(mdl.PredictorNames{k}));
    end

    EstDS.(mdl.PredictorNames{k}) = PredDS.(mdl.PredictorNames{k});
    
%     if ~strcmp(PredictorName,mdl.PredictorNames{k})
%         EstDS.(PredictorName) = f_inv_pred(PredDS.(mdl.PredictorNames{k}));
%     end
    
end



