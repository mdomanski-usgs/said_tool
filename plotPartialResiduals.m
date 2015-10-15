function h = plotPartialResiduals(mdl,PredictorVariableName,varargin)

if length(varargin) == 1
    h = varargin{1};
else
    h = figure;
end

iObs = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

mdlDS = mdl.Variables;
p = mdl.NumCoefficients;
n = mdl.NumObservations;
ObsNumber = (1:length(mdlDS))';
ObsNumber(~iObs) = [];

y = mdlDS.(mdl.ResponseName);
y(~iObs) = [];

fullmodelX = [ ones(n,1) double(mdlDS(iObs , mdl.VariableInfo.InModel')) ];

i = find(strcmp(PredictorVariableName,mdl.PredictorNames))+1;

x = fullmodelX(:,i);
X = fullmodelX(:,[1:i-1 i+1:p]);

betax = (X'*X)^-1*X'*x;
betay = (X'*X)^-1*X'*y;

r = y - X*betay;
xr = x - X*betax;

P = polyfit(xr,r,1);
yplot = polyval(P,xr);

% h = figure;

plot(xr,r,'bx');
hold on;

[minxr,minI] = min(xr);
[maxxr,maxI] = max(xr);
minyplot = yplot(minI);
maxyplot = yplot(maxI);
a = plot([minxr maxxr] ,[minyplot maxyplot],'r-');

set(a,'HitTest','off');
hB = hggetbehavior(a,'datacursor');
set(hB,'Enable',false);

xlabel(['Adjusted ' mdl.PredictorNames{i-1}]);
ylabel('Partial residual');
title(['Partial residual plot for ' mdl.PredictorNames{i-1}]);

legend('Adjusted data',['Fit: y=' num2str(P(1)) 'x'],'location','best');

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