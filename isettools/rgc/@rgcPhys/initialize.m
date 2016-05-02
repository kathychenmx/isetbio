function obj = initialize(obj, varargin)
% Initializes the rgcPhys object by loading a mosaic of GLM fits from an
% experiment in the Chichilnisky lab.
% 
% This function is only called by rgcPhys, which itself is only called by irPhys.
% 
%             rgcPhys = rgcPhys.initialize(rgc, varargin{:});   
% Inputs: 
%       rgc: an isetbio rgcPhys object
% 
% Outputs: the mosaic object, where each cell has a location, linear spatial
% and temporal receptive fields, a DC offest, a generator function, a
% post-spike filter, coupling filters if necessary, and empty fields for
% the linear, voltage and spiking responses.
% 
% 
% See also rgcPhys, irPhys.
% 
% (c) isetbio
% 09/2015 JRG

namesCellTypes = {'onParasol';'offParasol';'onMidget';'offMidget';'smallBistratified'};
obj.cellType = namesCellTypes{1};

obj.generatorFunction = @exp;

obj.numberTrials = 10;

glmFitPath = pwd;%'/Users/james/Documents/matlab/NSEM_data/';

% % % % % % % % % % 
% 
% client = RdtClient('isetbio');
% % client.credentialsDialog();
% client.crp('/resources/data/rgc');
% [data, artifact] = client.readArtifact('parasol_on_1205', 'type', 'mat');
% 
% % glmFitPath = '/Users/james/Documents/matlab/NSEM_data/';
% % 
% % expdate = '2012-08-09-3/';
% % glmFitPath = ['/Users/james/Documents/MATLAB/akheitman/NSEM_mapPRJ/' expdate];
% 
% matFileNames = dir([glmFitPath '/ON*.mat']);


% % % % % % 

expdate = '2013-08-19-6';
% 1205 121 1276
% cell = 'ONPar_1276';%1276';%1';%841';
fitname = 'rk2_MU_PS_CP_p8IDp8';
% type = 'NSEM';
% type = 'WN';


% glmFitPath = '/Users/james/Documents/matlab/NSEM_data/';
% matFileNames = dir([glmFitPath '/ON*.mat']);

% glmFitPath = '/Users/james/Documents/matlab/akheitman/NSEM_mapPRJ/';
% glmFitPath = '/Users/james/Documents/matlab/akheitman/WN_mapPRJ/';

glmFitPath = '/Users/james/Documents/matlab/akheitman/WN_mapPRJ/Test_NSEM/';
matFileNames = dir([glmFitPath expdate '/ON*.mat']);


% % % % % % 
% Loop through mat files and load parameters
for matFileInd = 1%:length(matFileNames)
     
%     loadStr = sprintf('matFileNames(%d).name', matFileInd);
% %     eval(sprintf('load([glmFitPath %s])',loadStr))

%     fittedGLM = data.fittedGLM;

    cell = matFileNames(2).name(1:end-4);

    load([glmFitPath expdate '/' cell '.mat']);
    
%     
%     nameStr = eval(loadStr);
%     sind1 = strfind(nameStr,'_'); sind2 = strfind(nameStr,'.');
%     if isfield(fittedGLM.linearfilters,'Coupling')
% 
%         lookupIndex(matFileInd) = str2num(nameStr(sind1+1:sind2-1));
%     end
% %     lookupIndex(matFileInd) = 1205;
% %     fittedGLM = data.fittedGLM;
    
%     filterStimulus{matFileInd} = fittedGLM.linearfilters.Stimulus.Filter;
    obj.postSpikeFilter{matFileInd} = fittedGLM.linearfilters.PostSpike.Filter;
    if isfield(fittedGLM.linearfilters,'Coupling')

        obj.couplingFilter{matFileInd} = fittedGLM.linearfilters.Coupling.Filter;
    end
    
    obj.tonicDrive{matFileInd} = fittedGLM.linearfilters.TonicDrive.Filter;
    
    obj.sRFcenter{matFileInd} = fittedGLM.linearfilters.Stimulus.space_rk1;
    obj.sRFsurround{matFileInd} = 0*fittedGLM.linearfilters.Stimulus.space_rk1;
    obj.tCenter{matFileInd} = fittedGLM.linearfilters.Stimulus.time_rk1;
    obj.tSurround{matFileInd} = 0*fittedGLM.linearfilters.Stimulus.time_rk1;
    
    if isfield(fittedGLM.linearfilters,'Coupling')

        couplingMatrixTemp{matFileInd} = fittedGLM.cellinfo.pairs;
    end
    
    % NEED TO CHECK IF X AND Y ARE BEING SWITCHED INCORRECTLY HERE
    % figure; for i = 1:39; hold on; scatter(rgc2.mosaic{1}.cellLocation{i}(1), rgc2.mosaic{1}.cellLocation{i}(2)); end
    obj.cellLocation{matFileInd} = [fittedGLM.cellinfo.slave_centercoord.x_coord fittedGLM.cellinfo.slave_centercoord.y_coord];
    
%     % figure; imagesc(filterSpatial{matFileInd})
%     magnitude1STD = max(filterSpatial{matFileInd}(:))*exp(-1);
%     [cc,h] = contour(filterSpatial{matFileInd},[magnitude1STD magnitude1STD]);% close;
%     %         ccCell{rfctr} = cc(:,2:end);
%     cc(:,1) = [NaN; NaN];
%     spatialContours{matFileInd} = cc;
end

obj.rfDiameter = size(fittedGLM.linearfilters.Stimulus.Filter,1);
% if isfield(fittedGLM.linearfilters,'Coupling')
% 
% for matFileInd = 1:length(matFileNames)
% %     coupledCells = zeros(6,1);
%     for coupledInd = 1:length(couplingMatrixTemp{matFileInd})
%         coupledCells(coupledInd) = find(couplingMatrixTemp{matFileInd}(coupledInd)== lookupIndex);
%     end
%     obj.couplingMatrix{matFileInd} = coupledCells;    
%     
% end
% end
obj.couplingMatrix{1} = [17     3    11    34    12     9];

% % g = fittype('a*exp(-0.5*(x^2/Q1 + y^2/Q2)) + b*exp(-0.5*(x^2/Q1 + y^2/Q2))','independent',{'x','y'},'coeff',{'a','b','Q1','Q2'})
% 
%     ft = fittype( 'a*exp(-0.5*((x - x0)^2/Q1 + (y - y0)^2/Q2)) + b*exp(-0.5*((x - x0)^2/Q1 + (y - y0)^2/Q2)) + c0','independent',{'x','y'}, 'dependent', 'z', 'coeff',{'a','b','Q1','Q2','x0','y0','c0'});
%         opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
%     opts.Display = 'Off';
%     opts.StartPoint = [0.323369521886293 0.976303691832645];
%     
%     % Fit a curve between contrast level (x) and probability of correction
%     % detection.
%     % bootWeibullFit(stimLevels, nCorrect, nTrials, varargin)
%     % in computationaleyebrain/simulations/Pixel Visibility/ ...
%     [xsz,ysz] = size(srf1); 
%    [xc,yc] = meshgrid(1:xsz,1:ysz);
%     [fitresult, gof] = fit([xc(:),yc(:)], srf1(:), ft);, opts );
% 
% % Loop through mat files and plot contours
% figure; hold on;
% for matFileInd = 1:length(matFileNames)
%     plot(filterCenter{matFileInd}(1) + spatialContours{matFileInd}(1,2:end), filterCenter{matFileInd}(2) + spatialContours{matFileInd}(2,2:end))
%     
% end