function procAdvmDS = proc_advmDS(advmDS, advmParamStruct)
%

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

% unpack the advm dataset values
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

iVbeam = Vbeam < MinVbeam;
MB(iVbeam,:) = NaN;

% find the cells in the range given by the user
inRange = (R >= RMin) & (R <= RMax);

% set the cell values outside of the range to NaN
% MB(:,~inRange) = NaN;

% remove the columns outside of the range - 20140221 MMD
MB(:,~inRange) = [];
R(~inRange) = [];

% if the beam is vertically oriented, find the cells that aren't fully
% submerged and set them to NaN
if strcmp(BeamOrientation,'Vertical')
    
    gtVbeam = bsxfun(@gt,R*cosd(SlantAngle)+CellSize/2,Vbeam);
    MB(gtVbeam) = NaN;
%     MB = reshape(MB,mSamples,nCells);
    
end

% temperature-dependent relaxation frequency
f_T = 21.9*10.^(6-1520./(ADVMTemp+273));

% water attenuation coefficient
alpha_W = 8.686*3.38e-6*Frequency^2./f_T;

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

% "function which accounts for the departer of the backscatter signal from
% spherical spreading in the near field of the transducer" Downing (1995)
if NearField
    Psi = (1 + 1.35*Zz + (2.5*Zz).^3.2) ./...
        (1.35*Zz + (2.5*Zz).^3.2);
else
    Psi = ones(mSamples,1);
end

% two-way transmission loss
twoTL = 20*log10(bsxfun(@times,Psi,R)) +...
    2*bsxfun(@times,alpha_W,R);

% water corrected backscatter
WCB = MB + twoTL;

if RemoveMinWCB
    
    Rmat = repmat(R,mSamples,1);

    % find indices of the minimum water corrected backscatter
%     [~,iMinWCB] = min(WCB,[],2);
    [~,iMinWCB] = nanmin(WCB,[],2);
    
    % samples that have a minimum water corrected backscatter with more
    % than one valid cells, set the index back one to include cell with min wcb
%     iMinWCB(sum(~isnan(WCB),2)>1)=iMinWCB(sum(~isnan(WCB),2)>1)-1;
    iMinWCB(sum(~isnan(WCB),2)>1 & iMinWCB > 1)=iMinWCB(sum(~isnan(WCB),2)>1 & iMinWCB > 1)-1;
    
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

% % create dataset object to return
% procAdvmDS = dataset(...
%     {ADVMTemp,              'ADVMTemp'  },...
%     {Vbeam,                 'Vbeam'     },...
%     {repmat(R,mSamples,1),  'R'         },...
%     {MB,                    'MB'        },...
%     {WCB,                   'WCB'       },...
%     {SCB,                   'SCB'       },...
%     {alphaS,                'alphaS'    },...
%     {MeanSCB,               'MeanSCB'   } ...
%     );

% do not include ADVMTemp and Vbeam in returned dataset
% create dataset object to return
procAdvmDS = dataset(...
    {repmat(R,mSamples,1),  'R'         },...
    {MB,                    'MB'        },...
    {WCB,                   'WCB'       },...
    {SCB,                   'SCB'       },...
    {alphaS,                'alphaS'    },...
    {MeanSCB,               'MeanSCB'   } ...
    );
