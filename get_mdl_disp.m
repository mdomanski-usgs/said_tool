function mdlTxt = get_mdl_disp( mdl )

% get the estimated coefficient values
Coeff = mdl.Coefficients.Estimate;

% get the 90% confidence interval of the coefficients
ci = mdl.coefCI(0.10);

% number of coefficients in the model
p = mdl.NumCoefficients;

% number of observations
n = mdl.NumObservations;

% get strings of the upper and lower coefficient confidence interval values
Lower90 = num2str(ci(:,1),'%g');
Upper90 = num2str(ci(:,2),'%g');

% get the variance inflation factor
VIF = num2str(get_VIF(mdl),'%g');

% get the linear correlation coefficient
r = get_corr_coeff(mdl);

% initialize a string to hold the linear model equation
mdlEqn = [mdl.ResponseName ' = ' num2str(Coeff(1),'%.3g')];

% for each predictor variable coefficient
for k = 2:length(Coeff)
    
    % if the coefficient is negative, give it a minus sign
    if Coeff(k) < 0
        CoeffSign = ' - ';
    % otherwise, give it a plus sign
    else
        CoeffSign = ' + ';
    end
    
    % add the new string to the equation
    mdlEqn = [mdlEqn CoeffSign ...
        num2str(abs(Coeff(k)),'%.3g') mdl.PredictorNames{k-1}]; %#ok<AGROW>
    
end

% calculate alignment values
lL90 = length(Lower90);
aL90 = 13-lL90;
bL90 = 13-(aL90+9);

lU90 = length(Upper90);
aU90 = 13-lU90;
bU90 = 13-(aU90+9);

lVIF = length(VIF);
aVIF = 13-lVIF;
bVIF = 13-(aVIF+3);

% get the 'disp' output of the LinearModel object
mdlTxt = evalc('disp(mdl)');

% added for 2014a - MMD 20151015
mdlTxt = strrep(mdlTxt,'<strong>','');
mdlTxt = strrep(mdlTxt,'</strong>','');

% break up the 'disp' output by newline characters
mdlTxt = textscan(mdlTxt, '%s', 'Delimiter', '\n');
mdlTxt = mdlTxt{1};

% mdlTxt{6} = [];
mdlTxt(7) = [];
mdlTxt(7) = [];

% set the new equation to the formatted
mdlTxt{3} = mdlEqn;

mdlTxt{5} = 'Estimated Model Coefficients';

% add lower and upper bound to the header
mdlTxt{6} = ['               ' mdlTxt{6} ...
    repmat(' ',1,aL90) ' Lower90%' repmat(' ',1,bL90+aU90)...
    ' Upper90%' repmat(' ',1,bU90)];

% add the coefficients with confidence intervals to the output
for k = 0:length(Coeff)-1
    mdlTxt{7+k} = [mdlTxt{7+k} ...
        repmat(' ',1,aL90) Lower90(k+1,:) ...
        repmat(' ',1,aU90) Upper90(k+1,:)];
end

mdlTxt{10+length(Coeff)} = ...
    ['Root Mean Squared Error (Standard Error of Regression): ' num2str(mdl.RMSE)];

if mdl.NumPredictors == 1
    mdlTxt{end+1} = ['Linear correlation coefficient: ' num2str(r)];
end

if ~isempty(strfind(mdl.ResponseName,'log10'))
    BCF = nansum(10.^(mdl.Residuals.Raw))/mdl.NumObservations;
    RMSE_pct = 100*sqrt(exp(log(10)^2*mdl.MSE) - 1);
    mdlTxt{end+1} = ' ';
    mdlTxt{end+1} = ['RMSE(%): ' num2str(RMSE_pct)];
    mdlTxt{end+1} = ' ';
    mdlTxt{end+1} = ['Non-parametric smearing bias correction factor: ' num2str(BCF)];
elseif ~isempty(strfind(mdl.ResponseName,'ln'))
    BCF = nansum(exp(mdl.Residuals.Raw))/mdl.NumObservations;
    RMSE_pct = 100*sqrt(exp(mdl.MSE) - 1);
    mdlTxt{end+1} = ' ';
    mdlTxt{end+1} = ['RMSE(%): ' num2str(RMSE_pct)];
    mdlTxt{end+1} = ' ';
    mdlTxt{end+1} = ['Non-parametric smearing bias correction factor: ' num2str(BCF)];
end

ppcc = getPPCC(mdl);

mdlTxt{end+1} = ' ';
mdlTxt{end+1} = ['Probability plot correlation coefficient: ' num2str(ppcc)];

% if the model is a multiple linear regression, add the variance inflation
% factor to the output
if mdl.NumPredictors > 1
    
    mdlTxt{6} = [ mdlTxt{6} repmat(' ',1,bU90+aVIF) 'VIF' repmat(' ',1,bVIF) ];
    
    for k = 1:length(Coeff)-1
        mdlTxt{7+k} = [ mdlTxt{7+k} repmat(' ',1,aVIF) VIF(k,:) ];
    end
    
end

% mdlTxt{end+1}=' ';
% mdlTxt{end+1}=['High leverage:              ' num2str(3*p/n)];
% mdlTxt{end+1}=['High influence (Cook''s D):  ' num2str(finv(1-0.1,p+1,n+p))];
% mdlTxt{end+1}=['High influence (DFFITS):    ' num2str(2*sqrt(p/n))];

mdlTxt{end+1}=' ';
mdlTxt{end+1}=['High leverage:                           ' num2str(3*p/n)];
mdlTxt{end+1}=['Extreme outlier (Standardized residual): 3 (absolute value)'];
mdlTxt{end+1}=['High influence (Cook''s D):               ' num2str(finv(1-0.1,p+1,n+p))];
mdlTxt{end+1}=['High influence (DFFITS):                 ' num2str(2*sqrt(p/n))];


function r = get_corr_coeff(mdl)

iObs = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

if mdl.NumPredictors == 1
%     
%     X = double(mdl.Variables(iObs,mdl.PredictorNames{1}));
%     Y = double(mdl.Variables(iObs,mdl.ResponseName));
    
%     X = table2dataset(mdl.Variables(iObs,mdl.PredictorNames{1}));
%     Y = table2dataset(mdl.Variables(iObs,mdl.ResponseName));
    
%     X = double(X);
%     Y = double(Y);
    
    X = table2array(mdl.Variables(iObs,mdl.PredictorNames{1}));
    Y = table2array(mdl.Variables(iObs,mdl.ResponseName));
    
    Xmean = mean(X);
    Ymean = mean(Y);
    
    SSx = sum((X-Xmean).^2);
    SSy = sum((Y-Ymean).^2);
    
    SSxy = (X-Xmean)'*(Y-Ymean);
    
    r = SSxy/sqrt(SSx*SSy);
    
else
    r = [];
end

function VIF = get_VIF(mdl)

% if there are more than one predictor values (a multiple linear
% regression)
if mdl.NumPredictors > 1
    
    % allocate space for the VIF
    VIF = zeros(mdl.NumPredictors,1);
    
    % get the variable dataset from the model object
    mdlDS = mdl.Variables;
    
    % for each predictor value
    for k = 1:mdl.NumPredictors
        
        % create a linear regression of the selected predictor variable
        % against the other predictor variables
        vifmdl = LinearModel.fit(mdlDS,...
            'Response',mdl.PredictorNames{k},...
            'PredictorVars',mdl.PredictorNames([1:k-1 k+1:mdl.NumPredictors]));
        
        % compute the variance inflation factor for the selected predictor
        % variable
        VIF(k) = 1/(1-vifmdl.Rsquared.Ordinary);
        
    end
    
% otherwise, set the variance inflation factor to an empty matrix    
else
    
    VIF = [];
    
end

function ppcc = getPPCC(mdl)

% sort the residuals
x = sort(mdl.Residuals.Raw);

% remove NaNs
x(isnan(x)) = [];

% get the length of the remaining residual vector
n = length(x);

% calculate the plotting position
ppos = ((1:n)'-0.4)/(n+0.2);

% get the quantiles
q = norminv(ppos);

% calculate probability plot correlation coefficient
ppcc = corr(x,q);
