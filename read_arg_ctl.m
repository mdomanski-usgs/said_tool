function ArgCtl = read_arg_ctl( ctlFname )

ArgTypeLine = 10;
FreqLine = 12;
SlantAngleLine = 16;
BlankDistanceLine = 44;
CellSizeLine = 45;
NCellsLine = 46;

v = [];

ArgCtl = struct( ...
    'Frequency',            v           ,...
    'EffectiveDiameter',    v           ,...
    'BeamOrientation',      'Horizontal',...
    'SlantAngle',           v           ,...
    'Nbeams',               v           ,...
    'BlankDistance',        v           ,...
    'CellSize',             v           ,...
    'NumberOfCells',        v           ,...
    'BeamNumber',           'Avg'       ,...
    'MovingAverageSpan',    1           ,...
    'BSValues',             'SNR'       ,...
    'IntenScale',           0.43        ,...
    'RMin',                 -Inf        ,...
    'RMax',                 Inf         ,...
    'MinCells',             2           ,...
    'MinVbeam',             -Inf        ,...
    'NearField',            false       ,...
    'RemoveMinWCB',         false        ...
    );

ctlFileLines = read_txt_lines(ctlFname);

SpltLine = regexp(ctlFileLines{ArgTypeLine}, ' ', 'split');
ArgType = SpltLine{3};

if strcmp(ArgType,'SL')
    ArgCtl.BeamOrientation = 'Horizontal';
elseif strcmp(ArgType,'SW')
    ArgCtl.BeamOrientation = 'Vertical';
end

SpltLine = regexp(ctlFileLines{FreqLine}, ' ', 'split');
ArgCtl.Frequency = str2double(SpltLine{5});

% transducer radius (m)
if ArgCtl.Frequency == 3000 % 3000 kHz SL and SW
    ArgCtl.EffectiveDiameter = 0.015;
elseif ArgCtl.Frequency == 1500 % 1500 kHz SL
    ArgCtl.EffectiveDiameter = 0.030;
elseif ArgCtl.Frequency == 500 % 500 kHz SL
    ArgCtl.EffectiveDiameter = 0.090;
elseif isnan(ArgCtl.Frequency)
    ArgCtl.EffectiveDiameter = [];
end

SpltLine = regexp(ctlFileLines{SlantAngleLine}, ' ', 'split');
ArgCtl.SlantAngle = str2double(SpltLine{5});

SpltLine = regexp(ctlFileLines{BlankDistanceLine}, ...
    ' ', 'split');
ArgCtl.BlankDistance = str2double(SpltLine{4});

SpltLine = regexp(ctlFileLines{CellSizeLine}, ' ', 'split');
ArgCtl.CellSize = str2double(SpltLine{5});

SpltLine = regexp(ctlFileLines{NCellsLine}, ' ', 'split');
ArgCtl.NumberOfCells = str2double(SpltLine{5});

ArgCtl.MovingAverageSpan = 1;

end