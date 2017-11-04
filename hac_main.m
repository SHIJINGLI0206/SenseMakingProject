function varargout = hac_main(varargin)
% HAC_MAIN MATLAB code for hac_main.fig
%      HAC_MAIN, by itself, creates a new HAC_MAIN or raises the existing
%      singleton*.
%
%      H = HAC_MAIN returns the handle to a new HAC_MAIN or the handle to
%      the existing singleton*.
%
%      HAC_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HAC_MAIN.M with the given input arguments.
%
%      HAC_MAIN('Property','Value',...) creates a new HAC_MAIN or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hac_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hac_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hac_main

% Last Modified by GUIDE v2.5 02-Nov-2017 00:42:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hac_main_OpeningFcn, ...
                   'gui_OutputFcn',  @hac_main_OutputFcn, ...
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

% --- Executes just before hac_main is made visible.
function hac_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hac_main (see VARARGIN)

% Choose default command line output for hac_main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes hac_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hac_main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in build_model.
function build_model_Callback(hObject, eventdata, handles)
% hObject    handle to build_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% -- Clear previous model
set(handles.action_selected,'String','');
set(handles.action_predicted,'String','');
set(handles.text18,'Visible','off');
set(handles.text20,'Visible','off');
set(handles.score, 'String','Accuracy: ');
cla 

%% -- Show waiting animation
iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
iconsSizeEnums = javaMethod('values',iconsClassName);
SIZE_32x32 = iconsSizeEnums(4);  % (1) = 16x16,  (2) = 32x32
jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32, 'Training...');  % icon, label


jObj.setPaintsWhenStopped(true);  % default = false
jObj.useWhiteDots(false);         % default = false (true is good for dark backgrounds)
pos = getpixelposition(handles.build_model,true);
javacomponent(jObj.getComponent, [pos(1)+pos(3),pos(2),80,80], gcf);
jObj.start;
% Feature extraction.
drawnow
group_no = 1;
if( get(handles.rb_a9_16,'Value'))
    group_no = 2;
elseif(get(handles.rb_a17_24,'Value'))
    group_no = 3;
end
handles.group_no = group_no;
% Build CRC Model
[accuracy, F_train_model, F_train_size_model] = crc_build_model(group_no);
handles.F_train = F_train_model;
handles.F_train_size = F_train_size_model;
jObj.stop;
jObj.setBusyText('Done');

% Display accuracy
set(handles.score,'Visible','on');
str_accuracy = sprintf('Accuracy: %.2f', accuracy);
set(handles.score, 'String',str_accuracy);
guidata(hObject,handles)

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

axis off;

% Actions data name
handles.actions_name = ["Swipe Left","Swipe Right","Wave","Clap","Throw","Arm Cross","Basketball Shoot","Draw X","Draw Circle CW", "Draw Circle CCW","Draw Triangle","Bowling","Boxing","Baseball Swing","Tennis Swing","Arm Curl","Tennis Serve", "Push", "Knock","Catch","Pickup Throw","Jog","Walk","Sit to Stand","Stand to Sit","Lunge","Squat"];
 
% Set default train data set
set(handles.rb_a1_8, 'Value',1);
set(handles.rb_a9_16, 'Value',0);
set(handles.rb_a17_24, 'Value',0);

% Keep figure screen center
movegui(gcf,'center')

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes on button press in load_one_action.
function load_one_action_Callback(hObject, eventdata, handles)
% hObject    handle to load_one_action (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.action_selected,'String','');
set(handles.action_predicted,'String','');

% Load selected action file
root_path = 'Data2/Test/';
file_name = uigetfile(root_path);
if file_name==0
   return; 
end
handles.filename = file_name;

ind = strfind(file_name,'_');
action_no = file_name(2:ind(1)-1);
handles.action_no =  str2num(action_no);
if(length(action_no) == 1)
   action_name = strcat('a0', action_no);
elseif (length(action_no) == 2)
    action_name = strcat('a', action_no);
end
action_folder = strcat(root_path, action_name, '/');

% Show action name
set(handles.text18,'Visible','on');
set(handles.text20,'Visible','on');
set(handles.action_selected,'String',handles.actions_name(str2num(action_no)));

% Show the action animation
load(strcat(action_folder, file_name));
num_frame = size(d_depth,3);
for i = 1:num_frame
    imagesc(d_depth(:,:,i),'Parent',handles.axes1); axis off;
    pause(1/20);
end

guidata(hObject,handles)


% --- Executes on button press in predict.
function predict_Callback(hObject, eventdata, handles)
% hObject    handle to predict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

label = crc_1action_classifier(handles.F_train,handles.F_train_size,handles.filename,handles.group_no);

% Choose correct action name
if(handles.group_no == 1)
    if (label == 8)
       label = label + 1; 
    end
elseif (handles.group_no == 2)
    label = label + 1; 
elseif (handles.group_no == 3)
    if(label<6)
       label = label + 1;
    elseif(label>=6)
        label = label + 2;
    end
end

label = label + (handles.group_no - 1) * 8;
label
if(label>0 && label<28)
    set(handles.action_predicted,'String',handles.actions_name(label));
end

% --- Executes on button press in rb_a1_8.
function rb_a1_8_Callback(hObject, eventdata, handles)
% hObject    handle to rb_a1_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.rb_a1_8, 'Value',1);
set(handles.rb_a9_16, 'Value',0);
set(handles.rb_a17_24, 'Value',0);
% Hint: get(hObject,'Value') returns toggle state of rb_a1_8


% --- Executes on button press in rb_a9_16.
function rb_a9_16_Callback(hObject, eventdata, handles)
% hObject    handle to rb_a9_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.rb_a1_8, 'Value',0);
set(handles.rb_a9_16, 'Value',1);
set(handles.rb_a17_24, 'Value',0);
% Hint: get(hObject,'Value') returns toggle state of rb_a9_16


% --- Executes on button press in rb_a17_24.
function rb_a17_24_Callback(hObject, eventdata, handles)
% hObject    handle to rb_a17_24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.rb_a1_8, 'Value',0);
set(handles.rb_a9_16, 'Value',0);
set(handles.rb_a17_24, 'Value',1);
% Hint: get(hObject,'Value') returns toggle state of rb_a17_24
