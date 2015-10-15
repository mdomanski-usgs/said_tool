function h = plotResVsTime(mdl,dateVarName,varargin)

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

% date/time variable to plot residuals against
ResTime = mdl.Variables.(dateVarName);

% raw residuals
RawRes = mdl.Residuals.Raw;

% plot the raw residuals against time
% figure;
plot(ResTime,RawRes,'bx');
hold on;

% set the date tick on the x axis
% datetick('x','mm/dd HH:MM','keeplimits','keepticks');
datetick('x');

% x axis limits
XLim = get(gca,'XLim');

% plot zero line
h = plot(XLim,[0 0],'k:');
set(h,'HitTest','off');
hB = hggetbehavior(h,'datacursor');
set(hB,'Enable',false);

xlabel('Observation Time');
ylabel('Residual');
title('Plot of residual vs. time');

dcm_obj = datacursormode(gcf);
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
                ['Observation: ', num2str(DI)],...
                ['Time: ', datestr(pos(1),'mm/dd/yyyy HH:MM')],...
                ['Residual: ', num2str(pos(2))]
                };
            
        else

            % otherwise, return an empty string to display            
            txt = {''};
            
        end
        
    end
end