function varargout = dffVSlider_withSignal_2(varargin)
% DFFVSLIDER_WITHSIGNAL_2 MATLAB code for dffVSlider_withSignal_2.fig
% Created by Hemanth Mohan, modified by Hermione Xu (added AllenMap overlay)
%      DFFVSLIDER_WITHSIGNAL_2, by itself, creates a new DFFVSLIDER_WITHSIGNAL_2 or raises the existing
%      singleton*.
%
%      H = DFFVSLIDER_WITHSIGNAL_2 returns the handle to a new DFFVSLIDER_WITHSIGNAL_2 or the handle to
%      the existing singleton*.
%
%      DFFVSLIDER_WITHSIGNAL_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFFVSLIDER_WITHSIGNAL_2.M with the given input arguments.
%
%      DFFVSLIDER_WITHSIGNAL_2('Property','Value',...) creates a new DFFVSLIDER_WITHSIGNAL_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dffVSlider_withSignal_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dffVSlider_withSignal_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dffVSlider_withSignal_2

% Last Modified by GUIDE v2.5 15-May-2023 19:26:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dffVSlider_withSignal_2_OpeningFcn, ...
                   'gui_OutputFcn',  @dffVSlider_withSignal_2_OutputFcn, ...
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


% --- Executes just before dffVSlider_withSignal_2 is made visible.
function dffVSlider_withSignal_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dffVSlider_withSignal_2 (see VARARGIN)

% Choose default command line output for dffVSlider_withSignal_2

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dffVSlider_withSignal_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dffVSlider_withSignal_2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function fileLocation_Callback(hObject, eventdata, handles)
% hObject    handle to fileLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileLocation as text
%        str2double(get(hObject,'String')) returns contents of fileLocation as a double


% --- Executes during object creation, after setting all properties.
function fileLocation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
% Align Allen Map is disabled (it's only enabled when warpped data is
% loaded)
set(handles.overlayAllenMapButton,'Enable','off')

set(handles.figure1, 'pointer', 'watch')
set(hObject,'string','Loading..');
drawnow;
handles.cmap = load(['D:\Scripts\SupportScripts\cmap2.mat']);
handles.Fs = 30;
reduceRatio = str2num(get(handles.reduceRatioInput,'String'));
handles.pltScl = str2num(get(handles.plotScaleInput,'String'));
handles.tempSmFac = str2double(get(handles.temporalSmoothInput,'String'));
dffV = load(get(handles.fileLocation,'String'));
handles.dffV = imresize(dffV.dffV,reduceRatio);
handles.tm = linspace(0,size(handles.dffV,3)*(1/handles.Fs),size(handles.dffV,3));
handles.dffVsm = smoothdata(handles.dffV,3,'movmean',handles.tempSmFac);
handles.imScl = str2num(get(handles.scaleInput,'String'));
handles.smFac = str2double(get(handles.spatialSmoothInput,'String'));
axes(handles.frameDispAxes);
imagesc(imgaussfilt(handles.dffVsm(:,:,1),handles.smFac),handles.imScl);
hold on
% Overlay the Allen map (XHX)
filenameSplit = split(get(handles.fileLocation,'String'),'\');
dorsalMapPath = [filenameSplit{1} filesep filenameSplit{2} filesep ...
    filenameSplit{4} filesep filenameSplit{5} filesep 'HX3_dorsalMap.mat']; % Filename needs more work TODO
handles.dorsalMaps = load(dorsalMapPath);
[rows,cols] = find(handles.dorsalMaps.dorsalMaps.edgeMapScaled);
rows = floor(rows*reduceRatio);
cols = floor(cols*reduceRatio);
handles.rows = rows;
handles.cols=cols;
plot(cols,rows,'b.')

axis image
colormap(handles.cmap.cmap2); colorbar
text(3,3,num2str(1),'color','w')
set(handles.figure1, 'pointer', 'arrow')
set(hObject,'string','Load Data');
%% update slider values 
maxNumberOfImages = size(handles.dffV,3);
set(handles.frameSlider, 'Min', 1);
set(handles.frameSlider, 'Max', maxNumberOfImages);
set(handles.frameSlider, 'Value', 1);
set(handles.frameSlider, 'SliderStep', [1/(maxNumberOfImages-1) , 10/(maxNumberOfImages-1) ]);
catch
    set(hObject,'string','Error. Load Again.');
    set(handles.figure1, 'pointer', 'arrow')
end
guidata(hObject, handles);


% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = floor(get(hObject,'Value'));
axes(handles.frameDispAxes)
imagesc(imgaussfilt(handles.dffVsm(:,:,idx),handles.smFac),handles.imScl);
axis image
colormap(handles.cmap.cmap2); colorbar
text(3,4,num2str(idx),'color','w')
text(3,12,num2str(idx/30),'color','w')
drawnow limitrate
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function scaleInput_Callback(hObject, eventdata, handles)
% hObject    handle to scaleInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleInput as text
%        str2double(get(hObject,'String')) returns contents of scaleInput as a double


% --- Executes during object creation, after setting all properties.
function scaleInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in scaleUpdate.
function scaleUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to scaleUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imScl = str2num(get(handles.scaleInput,'String'));
guidata(hObject, handles);



function spatialSmoothInput_Callback(hObject, eventdata, handles)
% hObject    handle to spatialSmoothInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatialSmoothInput as text
%        str2double(get(hObject,'String')) returns contents of spatialSmoothInput as a double


% --- Executes during object creation, after setting all properties.
function spatialSmoothInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatialSmoothInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spatialSmoothFacUpdate.
function spatialSmoothFacUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to spatialSmoothFacUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.smFac = str2double(get(handles.spatialSmoothInput,'String'));
guidata(hObject, handles);



function temporalSmoothInput_Callback(hObject, eventdata, handles)
% hObject    handle to temporalSmoothInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temporalSmoothInput as text
%        str2double(get(hObject,'String')) returns contents of temporalSmoothInput as a double


% --- Executes during object creation, after setting all properties.
function temporalSmoothInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temporalSmoothInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in temporalSmoothUpdate.
function temporalSmoothUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to temporalSmoothUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.tempSmFac = str2double(get(handles.temporalSmoothInput,'String'));
handles.dffVsm = smoothdata(handles.dffV,3,'movmean',handles.tempSmFac);
guidata(hObject, handles);


% --- Executes on button press in plotSignalButton.
function plotSignalButton_Callback(hObject, eventdata, handles)
[lx,ly] = ginput(1);
axes(handles.frameDispAxes)
hold on
p1 = plot(lx,ly,'.','MarkerSize',14);
hold off
sigIn = squeeze(handles.dffVsm(round(ly),round(lx),:));
axes(handles.signalAxes);
if get(handles.HoldOnBox,'Value') == 0
    plot(handles.tm,sigIn,'LineWidth',1,'color',p1.Color)
else
    hold on
    plot(handles.tm,sigIn,'LineWidth',1,'color',p1.Color)
    hold off
end
ylim([handles.pltScl]);
% hObject    handle to plotSignalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);


% --- Executes on button press in HoldOnBox.
function HoldOnBox_Callback(hObject, eventdata, handles)
% hObject    handle to HoldOnBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HoldOnBox



function plotScaleInput_Callback(hObject, eventdata, handles)
% hObject    handle to plotScaleInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plotScaleInput as text
%        str2double(get(hObject,'String')) returns contents of plotScaleInput as a double


% --- Executes during object creation, after setting all properties.
function plotScaleInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotScaleInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updatePlotScaleButton.
function updatePlotScaleButton_Callback(hObject, eventdata, handles)
handles.pltScl = str2num(get(handles.plotScaleInput,'String'));
axes(handles.signalAxes);
ylim([handles.pltScl]);
% hObject    handle to updatePlotScaleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);


% --- Executes on button press in InsertLineButton.
function InsertLineButton_Callback(hObject, eventdata, handles)
% hObject    handle to InsertLineButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fidx = floor(get(handles.frameSlider,'Value'));
frmTm = fidx* (1/handles.Fs);
axes(handles.signalAxes);
hold on
plot([frmTm,frmTm],[handles.pltScl(1),handles.pltScl(2)],'k--')
hold off



function reduceRatioInput_Callback(hObject, eventdata, handles)
% hObject    handle to reduceRatioInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reduceRatioInput as text
%        str2double(get(hObject,'String')) returns contents of reduceRatioInput as a double


% --- Executes during object creation, after setting all properties.
function reduceRatioInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reduceRatioInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectFileButton.
function selectFileButton_Callback(hObject, eventdata, handles)
[fname,fpath] = uigetfile('*.mat');
set(handles.fileLocation,'String',fullfile(fpath,fname))

% hObject    handle to selectFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in playbutton.
function playbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = floor(get(handles.frameSlider,'Value'));
dffVsz3 = size(handles.dffVsm,3);
axes(handles.frameDispAxes)
imScl = handles.imScl;
smFac = handles.smFac;
cmap2 = handles.cmap.cmap2;
ii = idx;
while get(hObject,'Value')
    if ii>=dffVsz3
        break
    end
%     imagesc(handles.frameDispAxes,imgaussfilt(handles.dffVsm(:,:,ii),smFac),imScl);%
    imagesc(imgaussfilt(handles.dffVsm(:,:,ii),smFac),imScl);%
    ii = ii+1;
    axis image
    colormap(cmap2); colorbar
    text(3,4,num2str(ii),'color','w')
    text(3,12,num2str(ii/30),'color','w')
    pause(0.034)
end
set(handles.frameSlider,'Value',ii);
drawnow limitrate


% --- Executes on button press in overlayAllenMapButton.
function overlayAllenMapButton_Callback(hObject, eventdata, handles)
% hObject    handle to overlayAllenMapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold on
plot(handles.cols,handles.rows,'b.')


% --- Executes on button press in warpDataButton.
function warpDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to warpDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
set(handles.figure1, 'pointer', 'watch')
set(hObject,'string','Loading..');
drawnow;
handles.cmap = load(['D:\Scripts\SupportScripts\cmap2.mat']);
handles.Fs = 30;
reduceRatio = str2num(get(handles.reduceRatioInput,'String'));
handles.pltScl = str2num(get(handles.plotScaleInput,'String'));
handles.tempSmFac = str2double(get(handles.temporalSmoothInput,'String'));

% Check if the selected dff raw file has a warped version (XHX)
tempPath=split(get(handles.fileLocation,'String'),'.');
if isfile([tempPath{1} '_warpped.mat'])
    load([tempPath{1} '_warpped.mat']);
else
    dffV_warpped = warpToAllen(get(handles.fileLocation,'String'));
end


% dffV = load(get(handles.fileLocation,'String')); 
handles.dffV = imresize(dffV_warpped,reduceRatio);
handles.tm = linspace(0,size(handles.dffV,3)*(1/handles.Fs),size(handles.dffV,3));
handles.dffVsm = smoothdata(handles.dffV,3,'movmean',handles.tempSmFac);
handles.imScl = str2num(get(handles.scaleInput,'String'));
handles.smFac = str2double(get(handles.spatialSmoothInput,'String'));
axes(handles.frameDispAxes);
imagesc(imgaussfilt(handles.dffVsm(:,:,1),handles.smFac),handles.imScl);
hold on
% Overlay the Allen map (XHX)
filenameSplit = split(get(handles.fileLocation,'String'),'\');
dorsalMapPath = [filenameSplit{1} filesep filenameSplit{2} filesep ...
    filenameSplit{4} filesep filenameSplit{5} filesep 'HX3_dorsalMap.mat']; % Filename needs more work TODO
handles.dorsalMaps = load(dorsalMapPath);
[rows,cols] = find(handles.dorsalMaps.dorsalMaps.edgeMapScaled);
rows = floor(rows*reduceRatio);
cols = floor(cols*reduceRatio);
handles.rows = rows;
handles.cols=cols;
plot(cols,rows,'b.')

axis image
colormap(handles.cmap.cmap2); colorbar
text(3,3,num2str(1),'color','w')
set(handles.figure1, 'pointer', 'arrow')
set(hObject,'string','Load Warpped Data');
%% update slider values 
maxNumberOfImages = size(handles.dffV,3);
set(handles.frameSlider, 'Min', 1);
set(handles.frameSlider, 'Max', maxNumberOfImages);
set(handles.frameSlider, 'Value', 1);
set(handles.frameSlider, 'SliderStep', [1/(maxNumberOfImages-1) , 10/(maxNumberOfImages-1) ]);
catch
    set(hObject,'string','Error. Load Again.');
    set(handles.figure1, 'pointer', 'arrow')
end
guidata(hObject, handles);
