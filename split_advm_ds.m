function [advmDS,matchedDS] = split_advm_ds(matchedDS)
%
% [advmDS,matchedDS] = split_advm_ds(matchedDS)
%
% input
% matchedDS -   dataset object from match_data()
%
% output
% advmDS    -   dataset object containing advm variables
% matchedDS -   same dataset object as the input but with advm variables
%               removed

% convert matched dataset to cell array
DSCell  = dataset2cell(matchedDS);

% convert numerical values of cell array to matrix
DSMat   = cell2mat(DSCell(2:end,:));

% get the dataset variable names
DSVarNames = DSCell(1,:);

% initialize logical arrays for variable indices
iAmpVar     = false(length(DSVarNames),2);
iSNRVar     = false(length(DSVarNames),2);
iADVMTemp   = false(length(DSVarNames),1);
iVbeam      = false(length(DSVarNames),1);

% initialize matrices for backscatter variables
AmpCellNumbers = nan(length(DSVarNames),2);
SNRCellNumbers = nan(length(DSVarNames),2);

% for every variable
for i = 1:length(DSVarNames)

    % look for advm variable names
    kAmp    = regexp(DSVarNames{i},'Cell[0-9][0-9]Amp[0-9]');
    kSNR    = regexp(DSVarNames{i},'Cell[0-9][0-9]SNR[0-9]');
    
    % do not remove temperature or vertical beam measurement - MMD
    % 2013-11-22
    kTemp   = regexp(DSVarNames{i},'ADVMTemp');
    kVbeam  = regexp(DSVarNames{i},'Vbeam');
%     kTemp = false;
%     kVbeam = false;
    
    % if any are found
    if any([kAmp;kSNR;kTemp;kVbeam])       
        
        % mark the location of the variable
        if kAmp
            cellNumber = str2double(DSVarNames{i}(5:6));
            beamNumber = str2double(DSVarNames{i}(10));
            AmpCellNumbers(i,beamNumber) = cellNumber;
            iAmpVar(i,beamNumber) = true;
            % remove variable from matchedDS
            matchedDS.(DSVarNames{i}) = [];
        elseif kSNR
            cellNumber = str2double(DSVarNames{i}(5:6));
            beamNumber = str2double(DSVarNames{i}(10));
            SNRCellNumbers(i,beamNumber) = cellNumber;
            iSNRVar(i,beamNumber) = true;
            % remove variable from matchedDS
            matchedDS.(DSVarNames{i}) = [];
        elseif kTemp
            iADVMTemp(i) = true;
        elseif kVbeam
            iVbeam(i) = true;
        end
       
%         % remove variable from matchedDS
%         matchedDS.(DSVarNames{i}) = [];
        
    end
    
end

% get the number of observations
mObs = size(matchedDS,1);

% if there are non-nan values in the cells numbers
if ~all(isnan(AmpCellNumbers(:))) || ~all(isnan(SNRCellNumbers(:)))
    
    % assume the number of cells is the maximum cell number
    nCells = max(max(AmpCellNumbers(:)),max(SNRCellNumbers(:)));
    
else
    
    nCells = 1;
    
end

% allocate space for backscatter variables
Amp1 = nan(mObs,nCells);
Amp2 = nan(mObs,nCells);
SNR1 = nan(mObs,nCells);
SNR2 = nan(mObs,nCells);

% extract the backscatter variables
Amp1(:,AmpCellNumbers(iAmpVar(:,1),1)) = DSMat(:,iAmpVar(:,1));
Amp2(:,AmpCellNumbers(iAmpVar(:,2),2)) = DSMat(:,iAmpVar(:,2));
SNR1(:,SNRCellNumbers(iSNRVar(:,1),1)) = DSMat(:,iSNRVar(:,1));
SNR2(:,SNRCellNumbers(iSNRVar(:,2),2)) = DSMat(:,iSNRVar(:,2));

% if any temperature values were detected
if any(iADVMTemp)
    
    % extract the values
    ADVMTemp = DSMat(:,iADVMTemp);
    
else
    
    ADVMTemp = nan(mObs,1);
    
end

% if any Vbeam values were detected
if any(iVbeam)
    
    % extract the values
    Vbeam = DSMat(:,iVbeam);
    
else
    
    Vbeam = nan(mObs,1);
    
end

% create dataset to return
advmDS = dataset(...
    {Amp1,      'Amp1'},...
    {Amp2,      'Amp2'},...
    {SNR1,      'SNR1'},...
    {SNR2,      'SNR2'},...
    {ADVMTemp,  'ADVMTemp'},...
    {Vbeam,     'Vbeam'}...
    );