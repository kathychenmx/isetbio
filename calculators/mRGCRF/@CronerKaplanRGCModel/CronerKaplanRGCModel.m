classdef CronerKaplanRGCModel < handle
    % Create a CronerKaplan RGC Model
    
    % References:
    %    Croner&Kaplan (1994). 'Receptive fields of P and M Ganglion cells 
    %    across the primate retina.',Vis. Res, (35)(1), pp.7-24
    % History:
    %    11/8/19  NPC, ISETBIO Team     Wrote it.
    
    properties (SetAccess = private)
        % Digitized data from Figure 4 & 5
        centerData;
        surroundData;
        
        % Synthesized data
        synthesizedData;
        
        % Model of center radius with eccentricity
        centerRadiusFunction;
        centerRadiusParams;
        centerRadiusParamsSE;
        
        % Model of surround radius with eccentricity
        surroundRadiusFunction;
        surroundRadiusParams;
        surroundRadiusParamsSE;
        
        % Model of center sensitivity with center radius
        centerPeakSensitivityFunction;
        centerPeakSensitivityParams;
        centerPeakSensitivityParamsSE;
        
        % Model of surround sensitivity with surround radius
        surroundPeakSensitivityFunction;
        surroundPeakSensitivityParams;
        surroundPeakSensitivityParamsSE;
        
        % Directory with psf deconvolution results
        psfDeconvolutionDir;
        
        synthesisOptions;
        
        plotlabOBJ;
    end
    
    methods
        % Constructor
        function obj = CronerKaplanRGCModel(varargin) 
            % Parse input
            p = inputParser;
            p.addParameter('generateAllFigures', true, @islogical);
            p.addParameter('instantiatePlotLab', true, @islogical);
            p.addParameter('dataSetToFit', 'medians', @(x)(ismember(x, {'medians', 'raw', 'paperFormulas'})));
            p.parse(varargin{:});
            
            obj.psfDeconvolutionDir = strrep(fileparts(which(mfilename())), ...
                '@CronerKaplanRGCModel', 'VisualToRetinalCorrectionData');
            
            obj.loadRawData();
            obj.fitModel('dataset', p.Results.dataSetToFit);
            
            obj.synthesisOptions = struct( ...
                'randomizeCenterRadii', true, ...
                'randomizeCenterSensitivities', true, ...
                'randomizeSurroundRadii', true, ...
                'randomizeSurroundSensitivities', true);
            
            if (p.Results.instantiatePlotLab)
                obj.setupPlotLab();
            end
            
            if (p.Results.generateAllFigures)
                obj.plotDigitizedData();
            end
        end
        
        % Fit the model to a data set, either 'medians', or 'raw'
        fitModel(obj, varargin);
        
        % Method to synthesize data for a sample of eccentricity values
        synthesizeData(obj, eccDegs, synthesisOptions);
        
        % Method to plot different aspects of the synthesized data
        [hFig1, hFig2, hFig3, hFig4] = plotSynthesizedData(obj);
        
        % Method to simulate the Croner&Kaplan results
        simulateCronerKaplanResults(obj, varargin);
        
        % Method to generate retinal RF params given the retinal center radius
        % and eccentricity as inputs. This is to be used with mRGC mosaics
        % whose centers are determined by connectivity to an underlying
        % cone mosaic
        synthesizedRFParams = synthesizeRetinalRFparamsConsistentWithVisualRFparams(obj, retinalCenterRadii, retinalCenterMicrons);
    end
    
    methods (Static)
        plotSensitivities(theAxes, d, model, pointSize, color,displayYLabel, theLabel);
        plotRadii(theAxes, d, model, pointSize, color, displayYLabel, theLabel);
        [hEcc, vEcc, thePSFs, thePSFsupportDegs] = psfAtEccentricity(goodSubjects, imposedRefractionErrorDiopters, eccXrange, eccYrange, deltaEcc);
    end
    
    methods (Access=private)
        setupPlotLab(obj);
        
        % Method to compute the visual->retinal deconvolution model
        % based on the convolution results with the Polans data
        deconvolutionModel = computeDeconvolutionModel(obj);
    end
    
end

