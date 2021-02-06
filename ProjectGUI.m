function varargout = ProjectGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProjectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProjectGUI_OutputFcn, ...
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



function ProjectGUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;


handles.version = '0.1';


set(handles.axes1,'XTickLabel',{});
set(handles.axes1,'YTickLabel',{});
set(handles.axes2,'XTick',[]);
set(handles.axes2,'YTick',[]);
set(handles.axes2,'XTickLabel',{});
set(handles.axes2,'YTickLabel',{});

handles = set_default(handles);


guidata(hObject, handles);





function varargout = ProjectGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


function handles = set_default(handles)


handles.record_obj = [];
handles.play_obj = [];
handles.my_rec = [];
handles.mani_rec = [];


handles.sound.reclen = [];
handles.fs = [];
handles.mani_fs = [];   



handles.status.isrecording = false;
handles.status.isplaying = false;
handles.status.isreset = false;
handles.status.issave = false;
handles.status.Xlim = [];
handles.status.Ylim = [];
handles.status.filename = '';


handles.status.isreset = true;
handles = update_GUI(handles);

function handles = update_GUI(handles)

if handles.status.isrecording
    set(handles.play_button,'enable','off');
    set(handles.record_button,'enable','off');
elseif handles.status.isplaying
    set(handles.play_button,'enable','off');
    set(handles.record_button,'enable','off');
else
    set(handles.play_button,'enable','on'); 
    set(handles.record_button,'enable','on');
end

function handles = update_plot(handles)

axes(handles.axes1);

function record_button_Callback(hObject, eventdata, handles)

try
    handles.status.isrecording = true;
    handles = update_GUI(handles);
    
    handles.fs = 8000;
    handles.mani_fs = 8000;
    handles.sound.reclen = 5;
    recLen = handles.sound.reclen;
    
    handles.record_obj = audiorecorder;
    disp('Start speaking.')
    recordblocking(handles.record_obj, recLen);
    disp('End of Recording.');
    
    myRecording = getaudiodata(handles.record_obj);
    handles.my_rec = myRecording;
    
    axes(handles.axes1);
    cla;
    plot(myRecording);
    title('Original');
    hold on;
    
    handles.status.isrecording = false;
    
    handles = update_GUI(handles);
    guidata(hObject, handles);
catch
    h = errordlg('Error starting audio input device!  Check sound card and microphone!','ERROR');
    waitfor(h);
    return
end


function play_button_Callback(hObject, eventdata, handles)

handles.status.isplaying = true;

handles = update_GUI(handles);
handles = update_plot(handles);

myRecording = handles.my_rec;

soundsc(myRecording);
pause(1);

handles.status.isplaying = false;
handles = update_GUI(handles);

guidata(hObject, handles);

function playmani_button_Callback(hObject, eventdata, handles)

handles.status.isplaying = true;

handles = update_GUI(handles);
handles = update_plot(handles);

myRecording = handles.mani_rec;

soundsc(myRecording);
pause(1);

handles.status.isplaying = false;
handles = update_GUI(handles);

guidata(hObject, handles);
        

function three_button_Callback(hObject, eventdata, handles)

myRecording = handles.my_rec;

f = [1/3 1/3 1/3]';
averagedRec = conv(myRecording, f);

handles.mani_rec = averagedRec;



axes(handles.axes2);

cla;

plot(handles.mani_rec, 'r');
title('Modified - Three point averager');
hold on;


handles = update_GUI(handles);
guidata(hObject, handles);


function fraction_button_Callback(hObject, eventdata, handles)

myRecording = handles.my_rec;

fraction = 50;
halvedRec = myRecording./fraction;

handles.mani_rec = halvedRec;
axes(handles.axes2);

cla;

plot(myRecording, 'g');
title('Modified - Fraction values');
hold on;


handles = update_GUI(handles);
guidata(hObject, handles);


function doubling_button_Callback(hObject, eventdata, handles)

myRecording = handles.my_rec;

doubleRec = repelem(myRecording, 2);

handles.mani_rec = doubleRec;
axes(handles.axes2);

cla;

plot(myRecording, 'o');
title('Modified - Double the length');
hold on;


handles = update_GUI(handles);
guidata(hObject, handles);


function reset_button_Callback(hObject, eventdata, handles)

close(gcbf);
ProjectGUI;

function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function speed_button_Callback(hObject, eventdata, handles)

fs = handles.fs;
handles.mani_rec = resample(handles.my_rec, fs, 12/10*fs);
handles.mani_fs = fs;

axes(handles.axes2);

cla;

plot(handles.mani_rec, 'b');
title('Speed Up');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 

function slow_button_Callback(hObject, eventdata, handles)

fs = handles.fs;
handles.mani_rec = resample(handles.my_rec, fs, 8/10*fs);
handles.mani_fs = fs;

axes(handles.axes2);

cla;

plot(handles.mani_rec, 'b');
title('Slow Down');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 


function copy_button_Callback(hObject, eventdata, handles)


handles.my_rec = handles.mani_rec;
handles.fs = handles.mani_fs;

axes(handles.axes1);
cla;
plot(handles.my_rec);
title('Original');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles);


function lower_button_Callback(hObject, eventdata, handles)

maxV = max(handles.my_rec);                       
handles.mani_rec = [2*maxV ; handles.my_rec(2:end)];  

axes(handles.axes2);

cla;

plot(handles.mani_rec, 'b');
title('Lower Volume');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 


function echo_button_Callback(hObject, eventdata, handles)

myRecording = handles.my_rec;


td = 0.2;
vecb = [1; zeros(round(td*handles.fs), 1); 1/3];
td = 0.3;
vecc = [1/2; zeros(round(td*handles.fs), 1); 1/4];

res = conv(vecb, myRecording);
res = conv(vecc, res);

handles.mani_rec = res;


axes(handles.axes2);

cla;

nc = size(res);
nc = 1:1:nc(1);
figxaxis = nc./handles.fs;

plot(figxaxis, handles.mani_rec, 'b');
title('Modified - Echoing the recording');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 

function high_pass_Callback(hObject, eventdata, handles)

a = [1];
b = [1 -2/3];
handles.mani_rec = filter(b, -a, handles.my_rec);
axes(handles.axes2);
cla;

plot(handles.mani_rec, 'r');
title('Modified - High Pass');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles);

