function h = plotStanSerialCorr(mdl,dateVarName,varargin)

if nargin > 2
    if ishandle(varargin{1})
        h = varargin{1};
        figure(h);
    else
        h = figure;
    end
else
    h = figure;
end

% raw residuals
RawRes = mdl.Residuals.Raw;

% model time variable
ResTime = mdl.Variables.(dateVarName);

% sort time and residuals by time
[ResTime,IX]=sort(ResTime);
RawRes=RawRes(IX);

% remove invalid values
iNaN = isnan(RawRes);
RawRes(iNaN) = [];
ResTime(iNaN) = [];

% find mean and variance
ResMean = mean(RawRes);
ResVar = var(RawRes);

% create residual matrix
ResMat = repmat(RawRes,1,size(RawRes,1));

% create tau matrix (tau(i,j) = t(i)-t(j))
taumat = bsxfun(@minus,ResTime,ResTime');

% set all values where tau(i,j) <= 0 to NaN
ResMat(taumat<=0) = NaN;
taumat(taumat<=0) = NaN;

% compute the standardized serial correlation
StanSerialCorr = bsxfun(@times,(RawRes-ResMean)',(ResMat-ResMean))/ResVar;

% get the invalid values
iNaN = isnan(taumat);
tau = taumat;

% clear invalid values
tau(iNaN)=[];
StanSerialCorr(iNaN)=[];

[tau,IX]=sort(tau);
StanSerialCorr=StanSerialCorr(IX);

yy = smooth(tau,StanSerialCorr,0.65,'lowess');

plot(tau,StanSerialCorr,'x');
hold on;
XLim = get(gca,'XLim');
h = plot(XLim,[0 0],'k:');
h = [h plot(tau,yy,'k-')];
xlabel('Difference in time, in Days');
ylabel('Standardized serial correlation');
title('Standardized serial correlation Vs. difference in time');

for k = 1:length(h)
    set(h(k),'HitTest','off');
    hB = hggetbehavior(h(k),'datacursor');
    set(hB,'Enable',false);
end