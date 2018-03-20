function varargout = SolSys(varargin)
% SOLSYS MATLAB code for SolSys.fig
%      SOLSYS, by itself, creates a new SOLSYS or raises the existing
%      singleton*.
%
%      H = SOLSYS returns the handle to a new SOLSYS or the handle to
%      the existing singleton*.
%
%      SOLSYS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOLSYS.M with the given input arguments.
%
%      SOLSYS('Property','Value',...) creates a new SOLSYS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SolSys_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SolSys_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SolSys

% Last Modified by GUIDE v2.5 19-Mar-2018 20:35:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SolSys_OpeningFcn, ...
                   'gui_OutputFcn',  @SolSys_OutputFcn, ...
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


% --- Executes just before SolSys is made visible.
function SolSys_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SolSys (see VARARGIN)

% Choose default command line output for SolSys
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

SystemData=load(['' pwd '/systemDefault.mat']);

handles=guidata(hObject);
handles.Objects=SystemData.Objects;
handles.G=SystemData.G;
handles.dt=SystemData.dt;
handles.SpareObjects=SystemData.SpareObjects;
guidata(hObject,handles);

Objects=handles.Objects;
ObjectListboxString=[];
for ii=1:length(Objects)
     ObjectListboxString=[ObjectListboxString; cellstr(Objects(ii).name)];
end

SpareObjects=handles.SpareObjects;
SpareObjectListboxString=[];
for ii=1:length(SpareObjects)
    if isfield(SpareObjects,'name')
        SpareObjectListboxString=[SpareObjectListboxString; cellstr(SpareObjects(ii).name)];
    end
end

set(handles.ObjectList,'string',ObjectListboxString);
set(handles.SpareObjectsList,'string',SpareObjectListboxString);
drawnow

% UIWAIT makes SolSys wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SolSys_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ObjectList.
function ObjectList_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ObjectList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ObjectList

contents = cellstr(get(hObject,'String'));
Name=contents{get(hObject,'Value')};

Objects=handles.Objects;

set(handles.ObjectName,'string',Name);
% Mass in kg
Mass=Objects(get(hObject,'Value')).mass;
% Stripp mass of scientific exponential
MassStripped=Mass/(10^floor(log10(Mass)));

set(handles.ObjectMass,'string',['Mass: ' num2str(MassStripped) '*10^' num2str(floor(log10(Mass))-3) ' tons']);
set(handles.ObjectPosition,'string',['Initial Position: ' num2str(Objects(get(hObject,'Value')).position/1000) ' km']);
set(handles.ObjectVelocity,'string',['Initial Velocity: ' num2str(Objects(get(hObject,'Value')).velocity/1000) ' km/s']);

set(handles.PlotCenter,'string',Name);

% --- Executes during object creation, after setting all properties.
function ObjectList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ObjectList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in AddObject.
function AddObject_Callback(hObject, eventdata, handles)
% hObject    handle to AddObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VelString=get(handles.NewObjectVelocity,'string');
VelString=VelString(find(~isspace(VelString)));
VelFindComma=strfind(VelString,',');
VelX=str2double(VelString(1:VelFindComma(1)-1));
VelY=str2double(VelString(VelFindComma(1)+1:VelFindComma(2)-1));
VelZ=str2double(VelString(VelFindComma(2)+1:end));


PosString=get(handles.NewObjectPosition,'string');
PosString=PosString(find(~isspace(PosString)));
PosFindComma=strfind(PosString,',');
PosX=str2double(PosString(1:PosFindComma(1)-1));
PosY=str2double(PosString(PosFindComma(1)+1:PosFindComma(2)-1));
PosZ=str2double(PosString(PosFindComma(2)+1:end));

force=[0 0];
color=[0,0,0];

% For now only use X and Y coordinates
if isnan(str2double(get(handles.NewObjectMass,'string')))
    msgbox('The mass value is invalid. If you want to use scientific notation, use 2e12 for 2*10^12');
	return
end
NewObject={get(handles.NewObjectName,'string'),str2double(get(handles.NewObjectMass,'string'))*1000,[VelX VelY]*1000,[PosX PosY]*1000,force,color};

characteristics={'name','mass','velocity','position','force','color'};
Objects=struct2cell(handles.Objects)';
Objects=[Objects; NewObject];
Objects=cell2struct(Objects,characteristics,2);

handles=guidata(hObject);
handles.Objects=Objects;
guidata(hObject,handles);

ObjectListboxString=[];
for ii=1:length(Objects)
     ObjectListboxString=[ObjectListboxString; cellstr(Objects(ii).name)];
end

set(handles.ObjectList,'string',ObjectListboxString);
drawnow



function NewObjectMass_Callback(hObject, eventdata, handles)
% hObject    handle to NewObjectMass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewObjectMass as text
%        str2double(get(hObject,'String')) returns contents of NewObjectMass as a double


% --- Executes during object creation, after setting all properties.
function NewObjectMass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewObjectMass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NewObjectVelocity_Callback(hObject, eventdata, handles)
% hObject    handle to NewObjectVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewObjectVelocity as text
%        str2double(get(hObject,'String')) returns contents of NewObjectVelocity as a double


% --- Executes during object creation, after setting all properties.
function NewObjectVelocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewObjectVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NewObjectPosition_Callback(hObject, eventdata, handles)
% hObject    handle to NewObjectPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewObjectPosition as text
%        str2double(get(hObject,'String')) returns contents of NewObjectPosition as a double


% --- Executes during object creation, after setting all properties.
function NewObjectPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewObjectPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NewObjectName_Callback(hObject, eventdata, handles)
% hObject    handle to NewObjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewObjectName as text
%        str2double(get(hObject,'String')) returns contents of NewObjectName as a double


% --- Executes during object creation, after setting all properties.
function NewObjectName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewObjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NewObjectColor.
function NewObjectColor_Callback(hObject, eventdata, handles)
% hObject    handle to NewObjectColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SaveSystem.
function SaveSystem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Objects=handles.Objects;
G=handles.G;
dt=handles.dt;

save(['' pwd '/NewSystem.mat'],'Objects','G','dt');
msgbox(['Saved as' pwd '/NewSystem.mat']);


% --- Executes on button press in LoadSystem.
function LoadSystem_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,filepath]=uigetfile(pwd);

SystemData=load(strcat(filepath,filename));

handles=guidata(hObject);
handles.Objects=SystemData.Objects;
handles.G=SystemData.G;
handles.dt=SystemData.dt;
guidata(hObject,handles);

Objects=handles.Objects;
ObjectListboxString=[];
for ii=1:length(Objects)
     ObjectListboxString=[ObjectListboxString; cellstr(Objects(ii).name)];
end

set(handles.ObjectList,'string',ObjectListboxString);
drawnow


% --- Executes on button press in MoveObjectsRight.
function MoveObjectsRight_Callback(hObject, eventdata, handles)
% hObject    handle to MoveObjectsRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.ObjectList,'String'));
% Name of currently selected Object in ObjectList
Name=contents{get(handles.ObjectList,'Value')};

% Characteristics for cell2struct of objects and SpareObjects
characteristics={'name','mass','velocity','position','force','color'};

Objects=struct2cell(handles.Objects);
SpareObjects=struct2cell(handles.SpareObjects);
NewSpareObject=Objects(:,get(handles.ObjectList,'Value'));
Objects(:,get(handles.ObjectList,'Value'))=[];
Objects=cell2struct(Objects',characteristics,2);

SpareObjects=[SpareObjects'; NewSpareObject'];
SpareObjects=cell2struct(SpareObjects,characteristics,2);

handles=guidata(hObject);
handles.Objects=Objects;
handles.SpareObjects=SpareObjects;
guidata(hObject,handles);

ObjectListboxString=[];
for ii=1:length(Objects)
     ObjectListboxString=[ObjectListboxString; cellstr(Objects(ii).name)];
end

% Set Value of Listbox to 1. Otherwise it will disappear if you remove the
% last item in it.
set(handles.ObjectList,'Value',1);
set(handles.ObjectList,'string',ObjectListboxString);

SpareObjectListboxString=[];
for ii=1:length(SpareObjects)
    if isfield(SpareObjects,'name')
        SpareObjectListboxString=[SpareObjectListboxString; cellstr(SpareObjects(ii).name)];
    end
end

set(handles.SpareObjectsList,'string',SpareObjectListboxString);


% --- Executes on button press in MoveObjectsLeft.
function MoveObjectsLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MoveObjectsLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.ObjectList,'String'));
% Name of currently selected Object in ObjectList
Name=contents{get(handles.ObjectList,'Value')};

% Characteristics for cell2struct of objects and SpareObjects
characteristics={'name','mass','velocity','position','force','color'};

% Load current Objects struct and SpareObjects struct from handles
Objects=struct2cell(handles.Objects);
SpareObjects=struct2cell(handles.SpareObjects);

% Define Object that is to be moved
NewObject=SpareObjects(:,get(handles.SpareObjectsList,'Value'));

% Update SpareObjects List
SpareObjects(:,get(handles.SpareObjectsList,'Value'))=[];

% Update Objects List
Objects=[Objects'; NewObject'];

% Convert Objects List to struct
Objects=cell2struct(Objects,characteristics,2);

% Convert Spare Objects List to struct
SpareObjects=cell2struct(SpareObjects',characteristics,2);

handles=guidata(hObject);
handles.Objects=Objects;
handles.SpareObjects=SpareObjects;
guidata(hObject,handles);

ObjectListboxString=[];
for ii=1:length(Objects)
     ObjectListboxString=[ObjectListboxString; cellstr(Objects(ii).name)];
end

set(handles.ObjectList,'string',ObjectListboxString);

SpareObjectListboxString=[];
for ii=1:length(SpareObjects)
    if isfield(SpareObjects,'name')
        SpareObjectListboxString=[SpareObjectListboxString; cellstr(SpareObjects(ii).name)];
    end
end

set(handles.SpareObjectsList,'Value',1);
set(handles.SpareObjectsList,'string',SpareObjectListboxString);


% --- Executes on selection change in SpareObjectsList.
function SpareObjectsList_Callback(hObject, eventdata, handles)
% hObject    handle to SpareObjectsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SpareObjectsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SpareObjectsList

contents = cellstr(get(hObject,'String'));
Name=contents{get(hObject,'Value')};

SpareObjects=handles.SpareObjects;

set(handles.ObjectName,'string',Name);
% Mass in kg
Mass=SpareObjects(get(hObject,'Value')).mass;
% Stripp mass of scientific exponential
MassStripped=Mass/(10^floor(log10(Mass)));

set(handles.ObjectMass,'string',['Mass: ' num2str(MassStripped) '*10^' num2str(floor(log10(Mass))-3) ' tons']);
set(handles.ObjectPosition,'string',['Initial Position: ' num2str(SpareObjects(get(hObject,'Value')).position/1000) ' km']);
set(handles.ObjectVelocity,'string',['Initial Velocity: ' num2str(SpareObjects(get(hObject,'Value')).velocity/1000) ' km/s']);


% --- Executes during object creation, after setting all properties.
function SpareObjectsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpareObjectsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Run

Objects=handles.Objects;
G=handles.G;
dt=handles.dt;

scatx=[];
scaty=[];
ColorData=[];
for kk=1:length(Objects)
   scatx=[scatx Objects(kk).position(1)];
   scaty=[scaty Objects(kk).position(2)];
   ColorData=[ColorData; Objects(kk).color];
end

if get(handles.Run,'Value')
    set(handles.Run,'string','Stop')
    % Plot all objects
    % f1=figure;
    % ax1=axes(f1);
    scatter(handles.SimulationAxes,scatx,scaty,'filled','cdata',ColorData);
    if ~get(handles.CenterCoordinatesCheck,'Value')
        xlim(handles.SimulationAxes,[Objects(get(handles.ObjectList,'Value')).position(1)-str2double(get(handles.Xrange,'string'))/2*1000,Objects(get(handles.ObjectList,'Value')).position(1)+str2double(get(handles.Xrange,'string'))/2*1000]);
        ylim(handles.SimulationAxes,[Objects(get(handles.ObjectList,'Value')).position(2)-str2double(get(handles.Yrange,'string'))/2*1000,Objects(get(handles.ObjectList,'Value')).position(1)+str2double(get(handles.Yrange,'string'))/2*1000]);
    else
        CenterString=get(handles.CenterCoordinates,'string');
        CenterString=CenterString(find(~isspace(CenterString)));
        CenterFindComma=strfind(CenterString,',');
        CenterX=str2double(CenterString(1:CenterFindComma(1)-1))*1000;
        CenterY=str2double(CenterString(CenterFindComma(1)+1:CenterFindComma(2)-1))*1000;
        CenterZ=str2double(CenterString(CenterFindComma(2)+1:end))*1000;
        xlim(handles.SimulationAxes,[CenterX-str2double(get(handles.Xrange,'string'))/2*1000,CenterX+str2double(get(handles.Xrange,'string'))/2*1000]);
        ylim(handles.SimulationAxes,[CenterY-str2double(get(handles.Yrange,'string'))/2*1000,CenterY+str2double(get(handles.Yrange,'string'))/2*1000]);
    end
else
    set(handles.Run,'string','Run')
end

iter = 0;
while get(handles.Run,'Value')
    iter=iter+1;
    for ii=1:length(Objects)-1
        for jj=ii+1:length(Objects)
            % Compute absolute value of gravitational force
             distance=dist([Objects(ii).position',Objects(jj).position']);
             F=G*Objects(ii).mass*Objects(jj).mass/(distance(1,2)^2);
             
             % The direction of gravitational force from objects a onto
             % Object b is vector(a)-vector(b).
             FDir=Objects(jj).position-Objects(ii).position;
             F=F*FDir/norm(FDir,2);

             % Actio = reactio
             Objects(ii).force=Objects(ii).force+F;
             Objects(jj).force=Objects(jj).force-F;
        end
        
    end

    % Update trajectories
    for ll=1:length(Objects)
       Objects(ll).velocity=Objects(ll).velocity+dt*Objects(ll).force/Objects(ll).mass;
       Objects(ll).position=Objects(ll).position+dt*Objects(ll).velocity;
       
       % reset forces acting upon object
       Objects(ll).force=[0,0];
    end
    
    scatx=[];
    scaty=[];
    for kk=1:length(Objects)
       scatx=[scatx Objects(kk).position(1)];
       scaty=[scaty Objects(kk).position(2)];
    end

        % Plot all objects
        scatter(handles.SimulationAxes,scatx,scaty,'filled','cdata',ColorData);
    %     text(handles.SimulationAxes,100*10 ^9,200*10^9,['velocity eart: ' num2str(norm(Objects(2).velocity,2)/1000) ' km/s'])
        text(handles.SimulationAxes,100*10 ^9,250*10^9,['day ' num2str(iter) ' '])
    %     text(handles.SimulationAxes,100*10 ^9,180*10^9,['velocity Moon: ' num2str(norm(Objects(5).velocity(1))/1000) ',' num2str(norm(Objects(5).velocity(2))/1000) ' km/s'])
        % text(200*10 ^9,180*10^9,['velocityy eart: ' num2str(Objects{2}.velocity(2)) ''])
        if ~get(handles.CenterCoordinatesCheck,'Value')
            xlim(handles.SimulationAxes,[Objects(get(handles.ObjectList,'Value')).position(1)-str2double(get(handles.Xrange,'string'))/2*1000,Objects(get(handles.ObjectList,'Value')).position(1)+str2double(get(handles.Xrange,'string'))/2*1000]);
            ylim(handles.SimulationAxes,[Objects(get(handles.ObjectList,'Value')).position(2)-str2double(get(handles.Yrange,'string'))/2*1000,Objects(get(handles.ObjectList,'Value')).position(2)+str2double(get(handles.Yrange,'string'))/2*1000]);
        else
            xlim(handles.SimulationAxes,[CenterX-str2double(get(handles.Xrange,'string'))/2*1000,CenterX+str2double(get(handles.Xrange,'string'))/2*1000]);
            ylim(handles.SimulationAxes,[CenterY-str2double(get(handles.Yrange,'string'))/2*1000,CenterY+str2double(get(handles.Yrange,'string'))/2*1000]);
        end
        getframe;
   
end


% --- Executes on button press in Continue.
function Continue_Callback(hObject, eventdata, handles)
% hObject    handle to Continue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Continue

set(handles.Run,'Value',1.0);

Run_Callback(hObject, eventdata, handles);


% --- Executes on button press in CenterCoordinatesCheck.
function CenterCoordinatesCheck_Callback(hObject, eventdata, handles)
% hObject    handle to CenterCoordinatesCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CenterCoordinatesCheck



function CenterCoordinates_Callback(hObject, eventdata, handles)
% hObject    handle to CenterCoordinates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterCoordinates as text
%        str2double(get(hObject,'String')) returns contents of CenterCoordinates as a double


% --- Executes during object creation, after setting all properties.
function CenterCoordinates_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterCoordinates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Xplus.
function Xplus_Callback(hObject, eventdata, handles)
% hObject    handle to Xplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Xrange,'string',num2str(str2double(get(handles.Xrange,'string'))+50e6));

% --- Executes on button press in Xminus.
function Xminus_Callback(hObject, eventdata, handles)
% hObject    handle to Xminus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Xrange,'string',num2str(str2double(get(handles.Xrange,'string'))-50e6));

% --- Executes on button press in Yplus.
function Yplus_Callback(hObject, eventdata, handles)
% hObject    handle to Yplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Yrange,'string',num2str(str2double(get(handles.Yrange,'string'))+50e6));

% --- Executes on button press in Yminus.
function Yminus_Callback(hObject, eventdata, handles)
% hObject    handle to Yminus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Yrange,'string',num2str(str2double(get(handles.Yrange,'string'))-50e6));