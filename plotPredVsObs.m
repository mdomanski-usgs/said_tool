function h = plotPredVsObs(mdl,varargin)

if nargin > 1
    if ishandle(varargin{1})
        h = varargin{1};
        figure(h);
    else
        h = figure;
    end
else
    h = figure;
end

% index of observations included in the model
iIncluded = ~(mdl.ObservationInfo.Missing | mdl.ObservationInfo.Excluded);

% observation numbers
ObsNums = 1:length(mdl.Variables);
ObsNums = ObsNums(iIncluded);

% get the fitted response values
YPred = mdl.Fitted(iIncluded);

% get the observed response values
YObs = mdl.Variables.(mdl.ResponseName)(iIncluded);

% plot the predicted values against the observed values
plot(YObs,YPred,'bx');
hold on;

XLim = get(gca,'XLim');
YLim = get(gca,'YLim');

set(gca,'XLim',XLim,'YLim',YLim);

% plot the 1:1 line
h = plot(XLim,XLim,'k-');
set(h,'HitTest','off');
hB = hggetbehavior(h,'datacursor');
set(hB,'Enable',false);

title('Predicted vs. Observed');
xlabel(['Observed ' mdl.ResponseName],'interpreter','none');
ylabel(['Predicted ' mdl.ResponseName],'interpreter','none');

legend('Data','1:1 line','location','best');

% create and set up data cursor
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@dcm_updatefcn);

    function txt = dcm_updatefcn(~,event_obj)
        
        % get the event object target
        Target = get(event_obj,'Target');
        
        % if the target is not a line
        if ~strcmp(get(Target,'LineStyle'),'-')
            
            % get the position and data index of the target
            pos = get(event_obj,'Position');
            DI = get(event_obj,'DataIndex');
            
            % create text to return
            txt = {...
                ['Observation: ', num2str(ObsNums(DI))],...
                ['Observed: ', num2str(pos(1))],...
                ['Predicted: ', num2str(pos(2))]
                };
            
        else
            
            txt = {''};
            
        end
        
    end

end