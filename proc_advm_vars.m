function loaded_var_struct = proc_advm_vars(loaded_var_struct, advm_param_struct)

% field names present in a raw advm dataset
advm_ds_field_names = { ...
    'Vbeam'     ,...
    'ADVMTemp'  ,...
    'Amp1'      ,...
    'Amp2'      ,...
    'SNR1'      ,...
    'SNR2'      ,...
    };

% field names present in a processed advm dataset
proc_advm_ds_field_names = { ...
    'MB'        ,...
    'R'         ,...
    'WCB'       ,...
    'SCB'       ,...
    'alphaS'    ,...
    'MeanSCB'    ...
    };

% overwrite any conflicting observations in the advm variables
overwrite_obs = true;

% create an advm dataset from the loaded variables
advm_ds = get_advm_ds(loaded_var_struct);

% remove advm_ds variables from the variable structure
for i = 1:length(advm_ds_field_names)
    
    if isfield(loaded_var_struct,advm_ds_field_names{i})
        loaded_var_struct = ...
            rmfield(loaded_var_struct,advm_ds_field_names{i});
    end
    
end

% remove proc_advm_ds variables from the variable structure
for i = 1:length(proc_advm_ds_field_names)
    
    if isfield(loaded_var_struct,proc_advm_ds_field_names{i})
        loaded_var_struct = ...
            rmfield(loaded_var_struct,proc_advm_ds_field_names{i});
    end
    
end

% if any of the date/time index values are nan, assume there is bad
% data in the dataset and don't compute the advm parameters
if ~any(isnan(advm_ds.DateTime))
    
    % check for required information to calculate the advm parameters
    required_config = ~any([                                          ...
        isempty(advm_param_struct.RMin)               ...
        isempty(advm_param_struct.RMax)               ...
        isempty(advm_param_struct.MinCells)           ...
        isempty(advm_param_struct.Frequency)          ...
        isempty(advm_param_struct.SlantAngle)         ...
        isempty(advm_param_struct.BlankDistance)      ...
        isempty(advm_param_struct.CellSize)           ...
        isempty(advm_param_struct.MinVbeam)           ...
        ]);
    
    % if the nearfield correction option is selected, the effective
    % diameter value is necessary
    if advm_param_struct.NearField
        required_config = required_config & ...
            ~isempty(advm_param_struct.EffectiveDiameter);
    end
    
    % if backscatter counts is selected as the backscatter values, the
    % intensity scale factor is necessary
    if strcmp(advm_param_struct.BSValues,'Amp')
        required_config = required_config & ...
            ~isempty(advm_param_struct.IntenScale);
    end
    
    % combine the advm dataset with the loaded variable structure
    loaded_var_struct = combine_loaded_vars( loaded_var_struct, ...
        advm_ds, overwrite_obs);

    % if all required fields are present
    if required_config
        
        % process the advm dataset
        proc_advm_ds = proc_advmDS(advm_ds,advm_param_struct);
        
        % combine the processed advm dataset with the loaded variable
        % structure
        loaded_var_struct = ...
            combine_loaded_vars( ...
            loaded_var_struct, proc_advm_ds, overwrite_obs);
        
    end

end


function advm_ds = get_advm_ds(loaded_var_struct)

DateTime = NaN;

loaded_var_names = fieldnames(loaded_var_struct);

n_loaded_var_names = length(loaded_var_names);

% initialize logical arrays for variable indices
iAmpVar     = false(n_loaded_var_names,2);
iSNRVar     = false(n_loaded_var_names,2);
iADVMTemp   = false(n_loaded_var_names,1);
iVbeam      = false(n_loaded_var_names,1);

% initialize matrices for backscatter variables
AmpCellNumbers = nan(n_loaded_var_names,2);
SNRCellNumbers = nan(n_loaded_var_names,2);

for i = 1:n_loaded_var_names
    
    % get the current variable name
    var_name = loaded_var_names{i};
    
    % look for advm variable names
    kAmp    = regexp(var_name,'Cell[0-9][0-9]Amp[0-9]');
    kSNR    = regexp(var_name,'Cell[0-9][0-9]SNR[0-9]');
    kTemp   = regexp(var_name,'ADVMTemp');
    kVbeam  = regexp(var_name,'Vbeam');
    
    % if any are found
    if any([kAmp;kSNR;kTemp;kVbeam])
        
        % get the date/time index from the variable
        var_DateTime = loaded_var_struct.(var_name).DateTime;
        
        % if DateTime is still NaN
        if isnan(DateTime)
            
            % assign the DateTime variable of the current dataset to it
            DateTime = var_DateTime;
            
        else
            
            % find which date/time values are already in the cumulative
            % array
            Lia = ismember(var_DateTime, DateTime);
            
            % add the newly found date/time values to the cumulative array
            DateTime = [DateTime; var_DateTime(~Lia)];
            
            % sort the date/time values
            DateTime = sort(DateTime);
            
        end
        
        % mark the location of the variable
        if kAmp
            cellNumber = str2double(var_name(5:6));
            beamNumber = str2double(var_name(10));
            AmpCellNumbers(i,beamNumber) = cellNumber;
            iAmpVar(i,beamNumber) = true;
        elseif kSNR
            cellNumber = str2double(var_name(5:6));
            beamNumber = str2double(var_name(10));
            SNRCellNumbers(i,beamNumber) = cellNumber;
            iSNRVar(i,beamNumber) = true;
        elseif kTemp
            iADVMTemp(i) = true;
        elseif kVbeam
            iVbeam(i) = true;
        end
        
    end
    
end

% get the number of observations from the lenght of the date/time index
% array
mObs = length(DateTime);

% if there are non-nan values in the cells numbers
if ~all(isnan(AmpCellNumbers(:))) || ~all(isnan(SNRCellNumbers(:)))
    
    % assume the number of cells is the maximum cell number
    nCells = max(max(AmpCellNumbers(:)),max(SNRCellNumbers(:)));
    
else
    
    nCells = 1;
    
end

% allocate space for temperature and vbeam
ADVMTemp = nan(mObs,1);
Vbeam = nan(mObs,1);

% allocate space for backscatter variables
Amp = nan(mObs,nCells,2);
SNR = nan(mObs,nCells,2);


if any(iADVMTemp)
    
    % get the variable name
    temp_var = loaded_var_names{iADVMTemp};
    
    % assign appropriate values to temperature array
    [Lia,Locb] = ismember(loaded_var_struct.(temp_var).DateTime,DateTime);
    ADVMTemp(Locb(Lia)) = loaded_var_struct.(temp_var).(temp_var)(Lia);
    
end


if any(iVbeam)
    
    % get the variable name
    vbeam_var = loaded_var_names{iVbeam};
    
    % assign appropriate values to vbeam array
    [Lia,Locb] = ismember(loaded_var_struct.(vbeam_var).DateTime,DateTime);
    Vbeam(Locb(Lia)) = loaded_var_struct.(vbeam_var).(vbeam_var)(Lia);
    
end

if any(iAmpVar(:))
    
    % begin filling the backscatter array
    for k = 1:2
        
        % get the variable names
        AmpVars = loaded_var_names(iAmpVar(:,k));
        
        % get the cell numbers
        AmpCellNum = AmpCellNumbers(iAmpVar(:,k),k);
        
        % for all raw backscatter variables
        for i = 1:length(AmpVars)
            
            % get the cell number / column index
            j = AmpCellNum(i);
            
            % assign appropriate values to the raw backscatter column
            [Lia,Locb] = ismember(loaded_var_struct.(AmpVars{i}).DateTime,DateTime);
            Amp(Locb(Lia),j,k) = loaded_var_struct.(AmpVars{i}).(AmpVars{i})(Lia);
            
        end
        
    end
    
    
end

if any(iSNRVar(:))
    
    % begin filling the backscatter array
    for k = 1:2
        
        SNRVars = loaded_var_names(iSNRVar(:,k));
        
        % get the cell numbers
        SNRCellNum = SNRCellNumbers(iSNRVar(:,k),k);
        
        % for all signal to noise backscatter variables
        for i = 1:length(SNRVars)
            
            % get the cell number / column index
            j = SNRCellNum(i);
            
            % assign appropriate values to the signal to noise backscatter
            % column
            [Lia,Locb] = ismember(loaded_var_struct.(SNRVars{i}).DateTime,DateTime);
            SNR(Locb(Lia),j,k) = loaded_var_struct.(SNRVars{i}).(SNRVars{i})(Lia);
            
        end
        
    end
    
end

% create dataset to return
advm_ds = dataset(...
    {DateTime,  'DateTime'},...
    {Amp(:,:,1),'Amp1'},...
    {Amp(:,:,2),'Amp2'},...
    {SNR(:,:,1),'SNR1'},...
    {SNR(:,:,2),'SNR2'},...
    {ADVMTemp,  'ADVMTemp'},...
    {Vbeam,     'Vbeam'}...
    );


function procAdvmDS = proc_advmDS(advmDS, advmParamStruct)


% unpack processing options
BeamNumber      = advmParamStruct.BeamNumber;
RMin            = advmParamStruct.RMin;
RMax            = advmParamStruct.RMax;
MinCells        = advmParamStruct.MinCells;
BSValues        = advmParamStruct.BSValues;
NearField       = advmParamStruct.NearField;
IntenScale      = advmParamStruct.IntenScale;
Frequency       = advmParamStruct.Frequency;
SlantAngle      = advmParamStruct.SlantAngle;
BlankDistance   = advmParamStruct.BlankDistance;
CellSize        = advmParamStruct.CellSize;
BeamOrientation = advmParamStruct.BeamOrientation;
at              = advmParamStruct.EffectiveDiameter/2;
RemoveMinWCB    = advmParamStruct.RemoveMinWCB;
MinVbeam        = advmParamStruct.MinVbeam;
MovingAverageSpan = advmParamStruct.MovingAverageSpan;

% unpack the advm dataset values
DateTime    = advmDS.DateTime;
ADVMTemp    = advmDS.ADVMTemp;
Vbeam       = advmDS.Vbeam;

% get the dimensions of the backscatter matrices
[mSamples,nCells] = size(advmDS.SNR1);

% first and last cell mid-point distance
FirstCell   = BlankDistance + CellSize / 2;
LastCell    = FirstCell + (nCells - 1) * CellSize;

% mid-point cell distance along the beam
if nCells > 1
    R = (FirstCell:CellSize:LastCell)/cosd(SlantAngle);
else
    R = FirstCell;
end

% determine and extract the user selected measured backscatter values
if strcmp(BSValues,'SNR')
    if strcmp(BeamNumber,'1')
        MB = advmDS.SNR1;
    elseif strcmp(BeamNumber,'2')
        MB = advmDS.SNR2;
    elseif strcmp(BeamNumber,'Avg')
        AvgBackScat = nan(mSamples,nCells,2);
        AvgBackScat(:,:,1) = advmDS.SNR1;
        AvgBackScat(:,:,2) = advmDS.SNR2;
        MB = nanmean(AvgBackScat,3);
    end
elseif strcmp(BSValues,'Amp');
    if strcmp(BeamNumber,'1')
        MB = IntenScale*advmDS.Amp1;
    elseif strcmp(BeamNumber,'2')
        MB = IntenScale*advmDS.Amp2;
    elseif strcmp(BeamNumber,'Avg')
        AvgBackScat = nan(mSamples,nCells,2);
        AvgBackScat(:,:,1) = advmDS.Amp1;
        AvgBackScat(:,:,2) = advmDS.Amp2;
        MB = IntenScale*nanmean(AvgBackScat,3);
    end
else
    error('said:proc_advmDS:UnknownBeamNumber',...
        'Unknown value for BeamNumber');
end

% find observations that with vbeam lower than the user required and
% nullify
iVbeam = Vbeam < MinVbeam;
MB(iVbeam,:) = NaN;

% find the cells in the range given by the user
inRange = (R >= RMin) & (R <= RMax);

% remove the columns outside of the range - 20140221 MMD
MB(:,~inRange) = [];
R(~inRange) = [];

% if the beam is vertically oriented, find the cells that aren't fully
% submerged and set them to NaN
if strcmp(BeamOrientation,'Vertical')
    
    gtVbeam = bsxfun(@gt,R*cosd(SlantAngle)+CellSize/2,Vbeam);
    MB(gtVbeam) = NaN;
    
end

% get the moving average for each column of the measured backscatter
for i = 1:size(MB,2)
    MB(:,i) = smooth(MB(:,i),MovingAverageSpan);
end

% find observations and cells with all null values
% null_obs = all(isnan(MB),2);
% null_cell = all(isnan(MB),1);

% remove null observations 
% MB(null_obs,:) = [];
% DateTime(null_obs) = [];
% ADVMTemp(null_obs) = [];

% remove null cells
% MB(:,null_cell) = [];
% R(null_cell) = [];

% recompute the dimensions of the backscatter matrices
% [mSamples,nCells] = size(MB);

% temperature-dependent relaxation frequency
f_T = 21.9*10.^(6-1520./(ADVMTemp+273));

% water attenuation coefficient
alpha_W = 8.686*3.38e-6*Frequency^2./f_T;

% if the nearfield option is present
if NearField
    
    % Speed of sound in water (m/s) (Marczak 1997)
    c = 1.402385*10^3 + 5.038813*ADVMTemp -...
        (5.799136*10^-2)*ADVMTemp.^2 +...
        (3.287156*10^-4)*ADVMTemp.^3 -...
        (1.398845*10^-6)*ADVMTemp.^4 +...
        (2.787860*10^-9)*ADVMTemp.^5;
    
    % Wavelength, in meters
    lambda = c./(Frequency*1e3);
    
    % Critical range (aka near zone distance), in meters
    Rcrit = (pi * at^2) ./ lambda;
    
    % normalized range dependence
    Zz = bsxfun(@rdivide,R,Rcrit);
    
    % "function which accounts for the departer of the backscatter signal 
    % from spherical spreading in the near field of the transducer" 
    % Downing (1995)
    Psi = (1 + 1.35*Zz + (2.5*Zz).^3.2) ./...
        (1.35*Zz + (2.5*Zz).^3.2);
    
else
    
    Psi = ones(mSamples,1);
    
end

% two-way transmission loss
% twoTL = 2*20*log10(bsxfun(@times,Psi,R)) +...
%     2*bsxfun(@times,alpha_W,R);
twoTL = 20*log10(bsxfun(@times,Psi,R)) +...
    2*bsxfun(@times,alpha_W,R);


% water corrected backscatter
WCB = MB + twoTL;

% if the modification of the backscatter profile is to be done based on the
% minimum water corrected backscatter
if RemoveMinWCB
    
    % range matrix
    Rmat = repmat(R,mSamples,1);
    
    % find indices of the minimum water corrected backscatter
    [~,iMinWCB] = nanmin(WCB,[],2);
    
    % samples that have a minimum water corrected backscatter with more
    % than one valid cells, set the index back one to include cell with min wcb
    iMinWCB(sum(~isnan(WCB),2)>1 & iMinWCB > 1) = ...
        iMinWCB(sum(~isnan(WCB),2)>1 & iMinWCB > 1)-1;
    
    linearInd=sub2ind([mSamples nCells],(1:mSamples )',iMinWCB);
    
    iWCBgtMin = bsxfun(@gt,R,Rmat(linearInd));
    
    nBadCells = sum(iWCBgtMin,2);
    
    iWCBgtMin(nBadCells==1,end) = 0;
    
    MB(iWCBgtMin)   = NaN;
    WCB(iWCBgtMin)  = NaN;
    
end

% find the invalid cells
iMBValidCells       = ~isnan(MB);

% find the samples with valid cells above the threshold
iMinCells = (sum(iMBValidCells,2) >= MinCells);

% set the invalid samples to NaN
MB(~iMinCells,:)    = NaN;
WCB(~iMinCells,:)   = NaN;

% allocate space for the sediment attenuation coefficient
alphaS = zeros(mSamples,1);

% find alphaS by finding the slope of the SLR of SCB on R
for i = 1:mSamples
    iFit = ~isnan(WCB(i,:));
    xy = nanmean(R.*WCB(i,:));
    x = mean(R(iFit));
    y = nanmean(WCB(i,:));
    cov_xy = xy - x*y;
    var_x = var(R(iFit),1);
    alphaS(i) = -0.5*cov_xy/var_x;
end

% calculate sediment corrected backscatter
SCB = WCB + 2 * alphaS * R;

% set the sediment corrected backscatter with one valid cell to the value
% of the water corrected backscatter
SCB(sum(iMBValidCells,2)==1,:)=WCB(sum(iMBValidCells,2)==1,:);

% find the mean sediment corrected backscatter
MeanSCB = nanmean(SCB,2);

% create dataset object to return
procAdvmDS = dataset(...
    {DateTime,              'DateTime'  },...
    {repmat(R,mSamples,1),  'R'         },...
    {MB,                    'MB'        },...
    {WCB,                   'WCB'       },...
    {SCB,                   'SCB'       },...
    {alphaS,                'alphaS'    },...
    {MeanSCB,               'MeanSCB'   } ...
    );


