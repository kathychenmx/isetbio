% t_rgcAverage
% 
% An experimental dataset that represents an RGC mosaic of a peripheral
% patch is loaded from Chichilnisky Lab data, and a mosaic of the average
% RGC is created that completely tiles the space. The cone spacing and RGC
% size can be scaled to an eccentricity input by the user.
% 
% The experimental recordings used are from the dataset RPE 201602171.
% 
% There is a dependency on the repository isetbio/EJLFigureReproduction.
% This must be added to the Matlab path.
% 
% See also:
%   EJLFigureReproduction/t_rgcNaturalScenesFig2.m
%   t_rgcCascade.m
%   t_rgcPeriphery.m
% 
% 6/2016 JRG (c) isetbio team

%% Initialize 
clear
% ieInit;

%% Initialize parameters for RGC mosaic

ecc = 0.03; % in mm, ecc = 1 deg
fov = 3*0.25;

experimentI   = 1;       % Choose dataset to load parameters and spikes
cellTypeI     = 1;       % Choose 1. OnPar, 2. OffPar, 3. OnMidg, 4. OffMidg, 5. SBC
stimulusTestI = 1;       % Choose 1. Moving bar, 

%% Moving bar stimulus

paramsStim.barwidth = 2;
paramsStim.meanLuminance = 200;
paramsStim.row = 64; params.col = 64;

paramsStim.expTime = 0.001;
paramsStim.timeInterval = 0.001;
paramsStim.nSteps = 150;     % Number of stimulus frames

upSampleFactor = 10;
paramsStim.timeInterval = .001;%(1/125)/upSampleFactor;%0.001; % sec
paramsStim.expTime      = .001;%(1/125)/upSampleFactor;%0.001; % sec

paramsStim.fov = fov;
paramsStim.radius = ecc;
paramsStim.theta = 0;  % 3 oclock on the retina
paramsStim.side = 'left';

iStim = ieStimulusBar(paramsStim);
sensor = iStim.absorptions;

%% Outer segment calculation - biophysical model
% The iStim structure generates the movie, the scene, the oi and the
% cone absorptions. The next step is to get the outer segment current. The
% biophysical outer segment model is employed here.

% % Initialize
osB = osCreate('biophys');

% Set size of retinal patch based on absorptions sensor object
patchSize = sensorGet(sensor,'width','m');
osB = osSet(osB, 'patch size', patchSize);

% Set time step of simulation equal to absorptions sensor object
timeStep = sensorGet(sensor,'time interval','sec');
osB = osSet(osB, 'time step', timeStep);

sensorVolts = sensorGet(sensor,'volts');
paramsOS.bgVolts = 1*mean(sensorVolts(:));
paramsOS.ecc = ecc; % mm
clear sensorVolts

osBSub = osB;
% Compute the outer segment response to the absorptions with the linear
% model.
osB = osCompute(osB,sensor,paramsOS);

% % Plot the photocurrent for a pixel.
osPlot(osB,sensor);

% Subsample outer segment current
% osB.osSet('coneCurrentSignal',osB.coneCurrentSignal(:,:,1:8:end));


%% Find bipolar responses
clear bp
% os = osBSub;
switch cellTypeI
    case 1
        bpParams.cellType = 'onDiffuse';
    case 2
        bpParams.cellType = 'offDiffuse';
    case 3
        bpParams.cellType = 'onMidget';
    case 4
        bpParams.cellType = 'offMidget';
    case 5
        bpParams.cellType = 'onDiffuse';
end
% sets filter as theoretical, mean physiology, or individual phys:
bpParams.filterType = 1; 
% sets linear, on half-wave rectification, or on and off half-wave rect
bpParams.rectifyType = 1;
% bpParams.rectifyType = 3;

bpParams.ecc = ecc;

bp = bipolar(osB, bpParams);

bp = bipolarCompute(bp, osB);

% bipolarPlot(bp,'response');

%%
% experimentI   = 1;       % Choose dataset to load parameters and spikes
% cellTypeI     = 1;       % Choose 1. OnPar, 2. OffPar, 3. OnMidg, 4. OffMidg, 5. SBC
% stimulusTestI = 1;       % Choose WN test stimulus (1) or NSEM test stimulus (2)
    
% Switch on the conditions indices
% Experimental dataset
switch experimentI
    case 1; experimentID = 'RPE_201602171';
    otherwise; error('Data not yet available');
end
% The other experimental data will be added to the RDT in the future.

% Stimulus: white noise or natural scene movie with eye movements
switch stimulusTestI
    case 1; stimulusTest = 'WN';
    case 2; stimulusTest = 'NSEM';
end

% Cell type: ON or OFF Parasol
switch cellTypeI
    case 1; 
        cellType = 'On Parasol RPE';      
%         fov = 4*0.25;
    case 2; 
        cellType = 'Off Parasol RPE';              
%         fov = 6*0.25;
    case 3; 
        cellType = 'On Midget RPE';        
%         fov = 1*0.25;
    case 4; 
        cellType = 'Off Midget RPE';
%         fov = 1*0.25;
    case 5; 
        cellType = 'SBC RPE';
%         fov = 6*0.25;
end

%%
% Set parameters
clear params innerRetinaSU
params.name = 'macaque phys';
params.eyeSide = 'left'; 
params.eyeRadius = ecc; 
params.fov = fov;
params.eyeAngle = 0; ntrials = 0;

% Determined at beginning to allow looping
params.experimentID = experimentID; % Experimental dataset
params.stimulusTest = stimulusTest; % WN or NSEM
params.cellType = cellType;         % ON or OFF Parasol;

params.cellIndices = 10;

params.averageMosaic = 1;

params.inputScale = size(bp.sRFcenter,1);
params.inputSize = size(bp.responseCenter);

% Create object
innerRetinaSU = irPhys(bp, params);
nTrials = 30; innerRetinaSU = irSet(innerRetinaSU,'numberTrials',nTrials);
%% Compute the inner retina response

% Linear convolution
innerRetinaSU = irCompute(innerRetinaSU, bp); 

% innerRetinaSU = irComputeContinuous(innerRetinaSU, bp); 
% innerRetinaSU = irNormalize(innerRetinaSU, innerRetina);
% innerRetinaSU = irComputeSpikes(innerRetinaSU); 

% Get the PSTH from the object
innerRetinaSUPSTH = mosaicGet(innerRetinaSU.mosaic{1},'responsePsth');

figure; plot(vertcat(innerRetinaSUPSTH{:})')
title(sprintf('%s Simulated Mosaic at %1.1f\\circ Ecc\nMoving Bar Response',cellType(1:end-4),fov));
xlabel('Time (msec)'); ylabel('PSTH (spikes/sec)');
set(gca,'fontsize',14);
axis([0 length(innerRetinaSUPSTH{1}) 0 130]);
grid on;

%% Plot the cone, bipolar and RGC mosaics

mosaicPlot(innerRetinaSU,bp,sensor,params,cellType,ecc);

%% Make a movie of the PSTH response

psthMovie = mosaicMovie(innerRetinaSUPSTH,innerRetinaSU, params);

% ieMovie(psthMovie);
