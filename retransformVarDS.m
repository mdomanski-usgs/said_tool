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