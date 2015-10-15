function plotLinearScale(mdl)

% make sure that the LinearModel is a simple linear regression
if length(mdl.PredictorNames) > 1
    error('said:plotLinearScale',...
        'plotLinearScale works for SLR models only');
end

if strfind(mdl.ResponseName,'log10')==1
    ResponseName = strrep(mdl.ResponseName,'log10','');
    f_inv = @(x) 10.^x;
elseif strfind(mdl.ResponseName,'ln')==1
    ResponseName = mdl.ResponseName(3:end);
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



if strfind(mdl.PredictorNames{1},'log10')==1
    PredictorName = strrep(mdl.PredictorNames{1},'log10','');
    f_inv_pred = @(x) 10.^x;
elseif strfind(mdl.PredictorNames{1},'ln')==1
    PredictorName = mdl.PredictorNames{1}(3:end);
    f_inv_pred = @(x) exp(x);
elseif strfind(mdl.PredictorNames{1},'pow')==1
    powerValue = str2double(mdl.ResponseName(4));
    PredictorName = mdl.PredictorNames{1}(5:end);
    f_inv_pred = @(x) nthroot(x,powerValue);
elseif strfind(mdl.PredictorNames{1},'root')==1
    rootValue = str2double(mdl.PredictorNames{1}(5));
    PredictorName = mdl.PredictorNames{1}(6:end);
    f_inv_pred = @(x) power(x,rootValue);
else
    PredictorName = mdl.PredictorNames{1};
    f_inv_pred = @(x) x;
end


% get the plotting range
minPred = min(mdl.Variables.(mdl.PredictorNames{1}));
maxPred = max(mdl.Variables.(mdl.PredictorNames{1}));

% create a dataset for the predictor plot values
xDS = dataset({linspace(minPred,maxPred)',mdl.PredictorNames{1}});

% get the observed predictor variable values
XObs = f_inv_pred(mdl.Variables.(mdl.PredictorNames{1}));

% compute the inverse transform of the response variable values
YObs = f_inv(mdl.Variables.(mdl.ResponseName));

% call smearing function
SmearedLineDS = smear_estimate(mdl,xDS);

% plot the values in linear space
plot(XObs,YObs,'bx');
hold on;
h = plot(SmearedLineDS.(PredictorName),SmearedLineDS.(ResponseName),'r-');
h = [h plot(SmearedLineDS.(PredictorName),SmearedLineDS.([ResponseName 'L90']),'r:')];
h = [h plot(SmearedLineDS.(PredictorName),SmearedLineDS.([ResponseName 'U90']),'r:')];

% from stats\internal.stats.addLabelDataTip
for k = 1:length(h)
    set(h(k),'HitTest','off');
    hB = hggetbehavior(h(k),'datacursor');
    set(hB,'Enable',false);
end

title([ResponseName ' vs. ' PredictorName], 'interpreter','none');

xlabel(PredictorName,'interpreter','none');
ylabel(ResponseName,'interpreter','none');

legend('Data','Fit','Confidence bounds','Location','best');

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
                ['Observation: ', num2str(DI)],...
                ['X: ', num2str(pos(1))],...
                ['Y: ', num2str(pos(2))]
                };
            
        else
            
            % otherwise, return an empty string to display
            txt = {''};
            
        end
        
    end


end