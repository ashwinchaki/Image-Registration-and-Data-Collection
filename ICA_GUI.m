function varargout = ICA_GUI(varargin)

% TESTGUI2 MATLAB code for testGUI2.fig
%      TESTGUI2, by itself, creates a new TESTGUI2 or raises the existing
%      singleton*.
%
%      H = TESTGUI2 returns the handle to a new TESTGUI2 or the handle to
%      the existing singleton*.
%
%      TESTGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI2.M with the given input arguments.
%
%      TESTGUI2('Property','Value',...) creates a new TESTGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testGUI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testGUI2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testGUI2

% Last Modified by GUIDE v2.5 28-Jun-2016 15:20:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ICA_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ICA_GUI_OutputFcn, ...
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

% --- Executes just before testGUI2 is made visible.
function ICA_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testGUI2 (see VARARGIN)

% for i = 1:50
%     objStr{i} = ['IC #',num2str(i)];
% end

% Set image varargins:
fn = varargin{1}; % tif name
segLabels = varargin{2}; % seglabel
ica_segments = varargin{3}; % seglabel
ica_sig = varargin{4}; % seglabel
segIdx = find(segLabels==1); % Boundary for IC#1 

vidFrame = imread(fn,100); % show 100th frame


% Choose default command line output for testGUI2
handles.output = hObject;

% create extra variables to use
handles.ica_segments = ica_segments;
handles.segLabels = segLabels;
handles.fn = fn;
handles.ica_sig = ica_sig;
handles.saveCell = zeros(size(ica_sig,1),1); % change to number of ICAs
for i = 1:size(ica_sig,1)
    handles.stdThresh (i,1) = 0;
end
% handles.stdThresh = zeros(50,1); % peak standard deviation
handles.ICpeaks = cell(size(ica_sig,1),1); % initialize peak location, size data
handles.checkbox1;
handles.currentObj = 1;
% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using testGUI2.
if strcmp(get(hObject,'Visible'),'off')
    kImg = imshow(vidFrame,[0 max(max(vidFrame))]);
        hold on
    for j = 1:length(segIdx)
        [B,L,N] = bwboundaries(squeeze(ica_segments(segIdx(j),:,:)));
        plot(B{1}(:,2),B{1}(:,1),'Color',[0 0 1],'LineWidth',1.5);
    end
end

uiwait(gcf);
% UIWAIT makes testGUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ICA_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;
close(gcf)

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
popup_sel_index = handles.currentObj;
sVal = get(handles.slider1,'value');
axes(handles.axes1);
cla;
ICpeaks = getGUIpeaks(handles.ica_sig(popup_sel_index,:),sVal); % in z-score
handles.ICpeaks{popup_sel_index} = ICpeaks.data;
set(hObject,'Max',max(ICpeaks.sig)*.99) % keep slider in range
set(hObject,'Min',0)

% will update plots based on slider value
plot(ICpeaks.sig,'b')
hold on
vidLen = size(ICpeaks.sig,2);
line([0 vidLen],[sVal sVal],'Color',[0 0 0]);
plot(ICpeaks.data(:,1),ICpeaks.data(:,2),'r.')

% Plot Averages:
axes(handles.axes2);
cla
xVec = -1:1/15:2; % timecourse of average signal (-1 to 2sec)
avData = zeros(size(ICpeaks.data,1),length(xVec)); % 
for i = 1:size(ICpeaks.data,1)
    peakLoc = ICpeaks.data(i,1);
    if peakLoc<find(xVec==0) % If peak is early, pad with zeros
        xOffset = find(xVec==0)-peakLoc;
        avData(i,:) = [zeros(1,xOffset), ICpeaks.sig(peakLoc:peakLoc+length(xVec)-xOffset-1)];
    elseif peakLoc >= (size(ICpeaks.sig,2)-(length(xVec)-find(xVec==0))) % if peak is too late, pad end with zeros
        xOffset = length(xVec) - length((peakLoc-find(xVec==0)+1):size(ICpeaks.sig,2));
        avData(i,:) = [ICpeaks.sig(peakLoc-find(xVec==0)+1:end), zeros(1,xOffset)];
    else
        avData(i,:) = ICpeaks.sig((peakLoc-find(xVec==0)+1):(peakLoc+length(xVec)-find(xVec==0)));
    end
end
hold on        
plot(xVec,avData,'Color',[.9 .9 .9])
plot(xVec,nanmean(avData),'r')
handles.stdThresh(popup_sel_index) = get(handles.slider1,'value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1. VIDEO
function pushbutton1_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popup_sel_index = handles.currentObj
sVal = get(handles.slider1,'value')
ICpeaks = getGUIpeaks(handles.ica_sig(popup_sel_index,:),sVal) % in z-score
sz = size(imread(handles.fn,1))
vid = zeros(sz(1),sz(2),100);
pkFrame = ICpeaks.data(:,1)
pkFrame(find(pkFrame<10)) = [] %#ok<FNDSB>
peakTot = min(length(pkFrame),10) 
if peakTot<1
    disp('no peaks selected')
else
    % just play 10 peaks:
    count = 1;
    for peakNum = 1:peakTot
        pkFrames(count:count+9) = [pkFrame(peakNum)-9:pkFrame(peakNum)];
        count = count+10;
    end
    for i = 1:length(pkFrames)
        vid(:,:,i) = double(imread(handles.fn,pkFrames(i))); 
    end
    vid = vid/max(vid(:))*.8;% arbitrary scale seems to look good
    implay(vid)
end
    


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
popup_sel_index = handles.currentObj;
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.saveCell(popup_sel_index) = 1;
    handles.stdThresh(popup_sel_index) = get(handles.slider1,'value');
    guidata(hObject, handles);
else
    handles.saveCell(popup_sel_index) = 0;
    guidata(hObject, handles);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(gcf)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentObj = handles.currentObj-1;
if ((handles.currentObj) <= 0)
    errordlg('No previous cell exists!','Index Error')
    handles.currentObj = 0;
else
popup_sel_index = handles.currentObj;
set(handles.text2, 'String', num2str(popup_sel_index));
sVal = handles.stdThresh(popup_sel_index);
set(handles.slider1,'Value',sVal);
get(handles.slider1,'Value');
slider1_Callback(hObject, eventdata, handles);
if handles.saveCell(popup_sel_index) == 1
    set(handles.checkbox1,'Value',1);
else
    set(handles.checkbox1,'Value',0);
end
ICpeaks = getGUIpeaks(handles.ica_sig(popup_sel_index,:),sVal); % in z-score
% Saves toggle position of save cell:
% if handles.saveCell(popup_sel_index)==0
%     handles.checkbox1.Value = 0;
% else
%     handles.checkbox1.Value = 1;
% end
axes(handles.axes4);
cla;
segIdx = find(handles.segLabels==popup_sel_index);
vidFrame = imread(handles.fn,100);
imshow(vidFrame,[0 max(max(vidFrame))]);
hold on
for j = 1:length(segIdx)
    [B,L,N] = bwboundaries(squeeze(handles.ica_segments(segIdx(j),:,:)));
    plot(B{1}(:,2),B{1}(:,1),'Color',[0 0 1],'LineWidth',1.5);
end

axes(handles.axes1);
cla;
plot(ICpeaks.sig)
vidLen = size(handles.ica_sig,2);
set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
title('Full ICA trace');

handles.ICpeaks{popup_sel_index} = ICpeaks.data;
sVal;
% 
% % will update plots based on slider value
plot(ICpeaks.sig,'b')
hold on
vidLen = size(ICpeaks.sig,2);
line([0 vidLen],[sVal sVal],'Color',[0 0 0]);
plot(ICpeaks.data(:,1),ICpeaks.data(:,2),'r.')
end
guidata(hObject, handles);



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentObj = handles.currentObj+1;
if (handles.currentObj >= size(handles.ica_sig,1))
    errordlg('Cannot go to next cell!','Index Error')
    handles.currentObj = handles.currentObj-1;
else
popup_sel_index = handles.currentObj;
set(handles.text2, 'String', num2str(popup_sel_index));
sVal = handles.stdThresh(popup_sel_index);
set(handles.slider1,'Value',sVal);
get(handles.slider1,'Value');
slider1_Callback(hObject, eventdata, handles);
if handles.saveCell(popup_sel_index) == 1
    set(handles.checkbox1,'Value',1);
else
    set(handles.checkbox1,'Value',0);
end
ICpeaks = getGUIpeaks(handles.ica_sig(popup_sel_index,:),sVal); % in z-score
% Saves toggle position of save cell:
% if handles.saveCell(popup_sel_index)==0
%     handles.checkbox1.Value = 0;
% else
%     handles.checkbox1.Value = 1;
% end
axes(handles.axes4);
cla;
segIdx = find(handles.segLabels==popup_sel_index);
vidFrame = imread(handles.fn,100);
imshow(vidFrame,[0 max(max(vidFrame))]);
hold on
for j = 1:length(segIdx)
    [B,L,N] = bwboundaries(squeeze(handles.ica_segments(segIdx(j),:,:)));
    plot(B{1}(:,2),B{1}(:,1),'Color',[0 0 1],'LineWidth',1.5);
end

axes(handles.axes1);
cla;
plot(ICpeaks.sig)
vidLen = size(handles.ica_sig,2);
set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
title('Full ICA trace');

handles.ICpeaks{popup_sel_index} = ICpeaks.data;
sVal;
% 
% % will update plots based on slider value
plot(ICpeaks.sig,'b')
hold on
vidLen = size(ICpeaks.sig,2);
line([0 vidLen],[sVal sVal],'Color',[0 0 0]);
plot(ICpeaks.data(:,1),ICpeaks.data(:,2),'r.')
end
guidata(hObject, handles);
