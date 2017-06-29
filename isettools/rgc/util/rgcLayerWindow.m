function varargout = rgcLayerWindow(varargin)
% RGCLAYERWINDOW MATLAB code for rgcLayerWindow.fig
%      RGCLAYERWINDOW, by itself, creates a new RGCLAYERWINDOW or raises the existing
%      singleton*.
%
%      H = RGCLAYERWINDOW returns the handle to a new RGCLAYERWINDOW or the handle to
%      the existing singleton*.
%
%      RGCLAYERWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RGCLAYERWINDOW.M with the given input arguments.
%
%      RGCLAYERWINDOW('Property','Value',...) creates a new RGCLAYERWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rgcLayerWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rgcLayerWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rgcLayerWindow

% Last Modified by GUIDE v2.5 28-Jun-2017 15:55:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rgcLayerWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @rgcLayerWindow_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before rgcLayerWindow is made visible.
function rgcLayerWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rgcLayerWindow (see VARARGIN)

% check inputs and get the rgcMosaic object
if isempty(varargin) || ~isa(varargin{1}, 'rgcMosaic')
    error('rgc mosaic object required');
end
rgcM = varargin{1};
rgcM.figureHandle = hObject;   % Store this figure handle

% Choose default command line output for rgcLayerWindow
handles.output = hObject;
handles.rgcMosaic = varargin{1};
handles.spikesMovie = [];  % spike movie

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rgcLayerWindow wait for user response (see UIRESUME)
% uiwait(handles.rgcLayerWindow);

% Refresh/Initialize window information
mosaicWindowRefresh(handles);

% Very important for good rendering speed
set(hObject, 'Renderer', 'OpenGL')

handles.linearMov = [];
handles.psthMov = [];
end

% --- Outputs from this function are returned to the command line.
function varargout = rgcLayerWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to menuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.linearMov = [];
handles.psthMov = [];
end

% --------------------------------------------------------------------
function menuPlot_Callback(hObject, eventdata, handles)
% hObject    handle to menuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function menuMosaic_Callback(hObject, eventdata, handles)
% hObject    handle to menuMosaic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function menuAnalyze_Callback(hObject, eventdata, handles)
% hObject    handle to menuAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on selection change in popupResponseSelect.
function popupResponseSelect_Callback(hObject, eventdata, handles)
% Popup over main response window
%
% hObject    handle to popupResponseSelect (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupResponseSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupResponseSelect

% These are all the strings in the popup
contents = cellstr(get(hObject,'String'));

% This is the selected string
str = contents{get(hObject,'Value')};

% Clear the axis in the image
cla

% Perform the action given the selection
% Some of the selections (e.g., PSTH mean image) are weird and should be
% deleted, IMHO.
% The PSTH movie seems good.  Spike movie less good, but OK.
switch str
    case 'Receptive field mosaic'
        % Should be extended to include case of ellipsoidal RFs
        handles.rgcMosaic.plot('mosaic');
        
    case 'Spike movie'
        % Spike movie pulldown
        handles.rgcMosaic.plot('spike movie');
        
    case 'Linear movie'
        % Linear movie, needs units if possible, colorbar if possible        
        handles.rgcMosaic.plot('linear movie');

    case 'Spike mean (image)'
        handles.rgcMosaic.plot('spike mean image');
                         
    case 'PSTH movie'
        % PSTH movie shows all the cells as a PSTH
        responsePsth = handles.rgcMosaic.get('psth');
        if isempty(responsePsth), disp('No Spikes'); return; end
        
        clear vParams; vParams = [];
        vParams.FrameRate = 30; vParams.show = true; %vParams.step = 2;
        frameSkip = round(1./handles.rgcMosaic.get('dt'));
        
        % We might build in the movie control parameters as cone mosaic
        ieMovie(responsePsth(:,:,1:frameSkip:end),vParams);
        
    otherwise
        error('Unknown string %s\n',str);
end

end

% --- Executes during object creation, after setting all properties.
function popupResponseSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupResponseSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% Plot Menu
% --------------------------------------------------------------------
function menuPlotPSTH_Callback(hObject, eventdata, handles)
% Plot | PSTH
%
% hObject    handle to menuPlotPSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% disp('Plot | PSTH')
    
% TURN THIS INTO A CALL TO RGC MOSAIC PLOT!!
rgcMosaic = handles.rgcMosaic;
vcNewGraphWin;

% Try to force this into a new window with a flag.
rgcMosaic.plot('psth');

% Plots the psth of all the cells combined.  Kind of weird.
% rgcMosaic = handles.rgcMosaic;
% timeStep  = rgcMosaic.dt;
% psth      = rgcMosaic.get('psth');
% resp      = RGB2XWFormat(psth);    % Each cell is in a row
% 
% vcNewGraphWin;
% plot(timeStep*(1:size(resp,2)),resp');
% grid on;
% xlabel('Time (sec)');
% ylabel(sprintf('Spikes per %d ms',timeStep*1e3));

end

% --------------------------------------------------------------------
function menuLinearPreSpike_Callback(hObject, eventdata, handles)
% hObject    handle to menuLinearPreSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Plots the psth of all the cells combined.  Kind of weird.
responseLinear = handles.rgcMosaic.get('responseLinear');

vcNewGraphWin;
plot(RGB2XWFormat(responseLinear)');       

end

% File Menu
% --------------------------------------------------------------------
function menuFileSave_Callback(hObject, eventdata, handles)
% File | Save
%
% hObject    handle to menuFileSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Save')
end

% --------------------------------------------------------------------
function menuFileRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mosaicWindowRefresh(handles)
end

% --------------------------------------------------------------------
function menuFileClose_Callback(hObject, eventdata, handles)
% File | Close
% hObject    handle to menuFileClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rgcM.figureHandle = [];
delete(handles.mosaicWindow);
end

%% Internal functions

function mosaicWindowRefresh(handles)
% Update all the text fields and such with the data in the mosaic

rgcM  = handles.rgcMosaic;
fig   = figure(rgcM.figureHandle);
gdata = guidata(fig);

% Show the appropriate response axis plot
axes(gdata.axisResponse);
cla(gdata.axisResponse,'reset');

% Selected string in the popup
contents = cellstr(get(gdata.popupResponseSelect,'String'));
str = contents{get(gdata.popupResponseSelect,'Value')};
switch(str)
    case 'Receptive field mosaic'
        gdata.rgcMosaic.plot('mosaic');
    case 'Spike mean (image)'
        gdata.rgcMosaic.plot('spike mean image');
    case 'PSTH mean (image)'
        gdata.rgcMosaic.plot('psth mean image');
        %     case 'PSTH plot'
        %         gdata.rgcMosaic.plot('psth');
    case 'Linear movie'
        gdata.rgcMosaic.plot('linear movie');        
    case 'Spike movie'
        gdata.rgcMosaic.plot('spike movie');
    case 'PSTH movie'
        %
        disp('PSTH movie NYI.  Showing spike movie')
        gdata.rgcMosaic.plot('spike movie');
    otherwise
        error('Unknown plot type %s\n',str);
end

% Make a button for rfOverlay.  ALways false, for now.
rfOverlay = false;
if rfOverlay, rgcM.plot('mosaic'); end

% Text description - implemented in rgcMosaic base class.
set(gdata.rgcProperties,'string',rgcM.describe);

end


% --- Executes on button press in btnPlayPause.
function btnPlayPause_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlayPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnPlayPause
end

% --- Executes on slider movement.
function sliderMovieProgress_Callback(hObject, eventdata, handles)
% hObject    handle to sliderMovieProgress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function sliderMovieProgress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderMovieProgress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% --- Executes on selection change in listMosaic.
function listMosaic_Callback(hObject, eventdata, handles)
% hObject    handle to listMosaic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listMosaic contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listMosaic

end

% --- Executes during object creation, after setting all properties.
function listMosaic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listMosaic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end