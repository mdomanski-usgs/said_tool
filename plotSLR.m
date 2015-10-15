

% S = load('Z:\Sediment\Acoustic Data\said\Example data\said SLR.mat');
% mdl = S.mdl;

function h = plotSLR(mdl,varargin)

if length(varargin) == 1
    h = varargin{1};
else
    h = figure;
end

alpha = 0.1;

mdlDS = mdl.Variables;
p = mdl.NumCoefficients;
n = mdl.NumObservations;
ObsNumber = (1:length(mdlDS))';
ObsNumber(mdl.ObservationInfo.Missing) = [];

y = mdlDS.(mdl.ResponseName);
y(mdl.ObservationInfo.Missing) = [];

X = [...
    ones(n,1)...
    double(mdlDS(~mdl.ObservationInfo.Missing,mdl.VariableInfo.InModel'))...
    ];

beta = (X'*X)^-1*X'*y;

y_hat = X*beta;

e = y - y_hat;

s = sqrt(sum(e.^2)/(n-2));

x0 = [ones(100,1) linspace(min(X(:,2)),max(X(:,2)))'];
y0_hat = x0*beta;

t = tinv(1-alpha/2,n-p);

l = zeros(size(x0(:,1)));
u = zeros(size(l));

for i = 1:length(l)
    l(i) = y0_hat(i) - tinv(1-alpha/2,n-p)*sqrt(s^2*x0(i,:)*(X'*X)^-1*x0(i,:)');
    u(i) = y0_hat(i) + tinv(1-alpha/2,n-p)*sqrt(s^2*x0(i,:)*(X'*X)^-1*x0(i,:)');
end

figure;
plot(X(:,2),y,'bx');
hold on;
h = plot(x0(:,2),y0_hat,'k-');
h(end+1) = plot(x0(:,2),l,'r:');
h(end+1) = plot(x0(:,2),u,'r:');

for k = 1:length(h)
    set(h(k),'HitTest','off');
    hB = hggetbehavior(h(k),'datacursor');
    set(hB,'Enable',false);
end



legend('Data','Fit','Confidence bounds','location','best');
title([mdl.ResponseName ' vs.' mdl.PredictorNames{1}]);
xlabel(mdl.PredictorNames{1});
ylabel(mdl.ResponseName);

% create data cursor object
dcm_obj = datacursormode(gcf);

% set the update function of the data cursor
set(dcm_obj,'UpdateFcn',@dcm_updatefcn);

    function txt = dcm_updatefcn(~,event_obj)
        
        % get the target of the data cursor selection
        Target = get(event_obj,'Target');
        
        % if the line is not selected
        if ~strcmp(get(Target,'LineStyle'),'-')
            
            % get the position of the selection
            pos = get(event_obj,'Position');
            
            % get the data index
            DI = get(event_obj,'DataIndex');
            
            % set the returned text to indicate observation number and
            % position
            txt = {...
                ['Observation: ', num2str(ObsNumber(DI))],...
                ['X: ', num2str(pos(1))],...
                ['Y: ', num2str(pos(2))]
                };
            
        else
            
            % otherwise, return an empty string to display
            txt = {''};
            
        end
        
    end

end