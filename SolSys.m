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

% Last Modified by GUIDE v2.5 21-Mar-2018 14:43:31

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

ThisFile=mfilename('fullpath');
ThisDir=strcat(ThisFile(1:end-length(mfilename)));
SystemData=load(['' ThisDir '/systemDefault.mat']);

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
set(handles.ObjectList,'Value',1);
drawnow
ObjectList_Callback(hObject,eventdata,handles)

set(handles.ObjectList,'UserData',1);
set(handles.SpareObjectsList,'UserData',0);


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

% This specifies if ListBox is selected or not
set(handles.ObjectList,'UserData',1);
set(handles.SpareObjectsList,'UserData',0);

contents = cellstr(get(handles.ObjectList,'String'));
Name=contents{get(handles.ObjectList,'Value')};

Objects=handles.Objects;

set(handles.ObjectName,'string',Name);
% Mass in kg
Mass=Objects(get(handles.ObjectList,'Value')).mass;
% Stripp mass of scientific exponential
MassStripped=Mass/(10^floor(log10(Mass)));

set(handles.ObjectMass,'string',['Mass: ' num2str(MassStripped) 'e' num2str(floor(log10(Mass))-3) ' tons']);
set(handles.ObjectPosition,'string',['Initial Position: ' num2str(Objects(get(handles.ObjectList,'Value')).position/1000) ' km']);
set(handles.ObjectVelocity,'string',['Initial Velocity: ' num2str(Objects(get(handles.ObjectList,'Value')).velocity/1000) ' km/s']);

set(handles.PlotCenter,'string',Name);
set(handles.PlotCenter,'Value',get(handles.ObjectList,'Value') );

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

% --- Executes during object creation, after setting all properties.
function PlotCenter_CreateFcn(hObject, eventdata, handles)
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
NewObject={get(handles.NewObjectName,'string'),str2double(get(handles.NewObjectMass,'string'))*1000,[VelX VelY]*1000,[PosX PosY]*1000,force,get(handles.NewObjectColor,'UserData')};

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

ObjectColor=uisetcolor;
set(handles.NewObjectColor,'UserData',ObjectColor);


% --- Executes on button press in SaveSystem.
function SaveSystem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Objects=handles.Objects;
G=handles.G;
dt=handles.dt;
SpareObjects=handles.SpareObjects;

save(['' pwd '/NewSystem.mat'],'Objects','G','dt','SpareObjects');
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

set(handles.Continue,'Visible','Off');
set(handles.Continue,'Value',0);
set(handles.Run,'Value',0);

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

% This specifies if ListBox is selected or not
set(handles.ObjectList,'UserData',0);
set(handles.SpareObjectsList,'UserData',1);

contents = cellstr(get(hObject,'String'));
Name=contents{get(hObject,'Value')};

SpareObjects=handles.SpareObjects;

set(handles.ObjectName,'string',Name);
% Mass in kg
Mass=SpareObjects(get(hObject,'Value')).mass;
% Stripp mass of scientific exponential
MassStripped=Mass/(10^floor(log10(Mass)));

set(handles.ObjectMass,'string',['Mass: ' num2str(MassStripped) 'e' num2str(floor(log10(Mass))-3) ' tons']);
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

% This callback function can be called upon button press RUN or it is
% called upon button press Continue.

if get(handles.Continue,'Value') % Callback was called upon button press "Continue"
    Objects=handles.CurrentSimulationObjects;
    iter=handles.CurrentSimulationIter;
    set(handles.Continue,'Value',0);
else % Callback was called upon button press "Run"
    Objects=handles.Objects;
    iter=0;
end

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

if get(handles.Run,'Value') % Simulation is running
    set(handles.Run,'string','Stop')
    set(handles.Continue,'Visible','Off')
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
    grid on
else % Simulation is paused
    set(handles.Run,'string','Run')
    set(handles.Continue,'Visible','On');
end

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
    
    % Save current values to handles
    handles=guidata(hObject);
    handles.CurrentSimulationObjects=Objects;
    handles.CurrentSimulationIter=iter;
    guidata(hObject,handles);
    
    scatx=[];
    scaty=[];
    for kk=1:length(Objects)
       scatx=[scatx Objects(kk).position(1)];
       scaty=[scaty Objects(kk).position(2)];
    end

        % Plot all objects
        scatter(handles.SimulationAxes,scatx,scaty,'filled','cdata',ColorData);
    %     text(handles.SimulationAxes,100*10 ^9,200*10^9,['velocity eart: ' num2str(norm(Objects(2).velocity,2)/1000) ' km/s'])
%         text(handles.SimulationAxes,100*10 ^9,250*10^9,['day ' num2str(iter) ' '])
    %     text(handles.Simul                                                                                                                                                                                                                    ationAxes,100*10 ^9,180*10^9,['velocity Moon: ' num2str(norm(Objects(5).velocity(1))/1000) ',' num2str(norm(Objects(5).velocity(2))/1000) ' km/s'])
        % text(200*10 ^9,180*10^9,['velocityy eart: ' num2str(Objects{2}.velocity(2)) ''])
        if ~get(handles.CenterCoordinatesCheck,'Value')
            xlim(handles.SimulationAxes,[Objects(get(handles.ObjectList,'Value')).position(1)-str2double(get(handles.Xrange,'string'))/2*1000,Objects(get(handles.ObjectList,'Value')).position(1)+str2double(get(handles.Xrange,'string'))/2*1000]);
            ylim(handles.SimulationAxes,[Objects(get(handles.ObjectList,'Value')).position(2)-str2double(get(handles.Yrange,'string'))/2*1000,Objects(get(handles.ObjectList,'Value')).position(2)+str2double(get(handles.Yrange,'string'))/2*1000]);
        else
            xlim(handles.SimulationAxes,[CenterX-str2double(get(handles.Xrange,'string'))/2*1000,CenterX+str2double(get(handles.Xrange,'string'))/2*1000]);
            ylim(handles.SimulationAxes,[CenterY-str2double(get(handles.Yrange,'string'))/2*1000,CenterY+str2double(get(handles.Yrange,'string'))/2*1000]);
        end
        grid on
        getframe;
        set(handles.SimulationDay,'String',['Day ' num2str(iter) '']);
        set(handles.StatusInfo,'string',['Velocity ' get(handles.PlotCenter,'string') ': ' num2str(round(Objects(get(handles.PlotCenter,'Value')).velocity(1)/1000,1)) ',' num2str(round(Objects(get(handles.PlotCenter,'Value')).velocity(2)/1000,1)) 'km/s.']);
   
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

incr=10e8;

if str2double(get(handles.Xrange,'string'))+incr > 0
    set(handles.Xrange,'string',num2str(str2double(get(handles.Xrange,'string'))+incr));
end

% --- Executes on button press in Xminus.
function Xminus_Callback(hObject, eventdata, handles)
% hObject    handle to Xminus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

incr=10e8;

if str2double(get(handles.Xrange,'string'))-incr>0
    set(handles.Xrange,'string',num2str(str2double(get(handles.Xrange,'string'))-incr));
end

% --- Executes on button press in Yplus.
function Yplus_Callback(hObject, eventdata, handles)
% hObject    handle to Yplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

incr=10e8;

if str2double(get(handles.Yrange,'string'))+incr > 0
    set(handles.Yrange,'string',num2str(str2double(get(handles.Yrange,'string'))+incr));
end

% --- Executes on button press in Yminus.
function Yminus_Callback(hObject, eventdata, handles)
% hObject    handle to Yminus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

incr=10e8;

if str2double(get(handles.Yrange,'string'))-incr > 0
    set(handles.Yrange,'string',num2str(str2double(get(handles.Yrange,'string'))-incr));
end


% --- Executes on button press in RemoveSparePart.
function RemoveSparePart_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveSparePart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.ObjectList,'String'));
% Name of currently selected Object in ObjectList
Name=contents{get(handles.ObjectList,'Value')};

% Characteristics for cell2struct of objects and SpareObjects
characteristics={'name','mass','velocity','position','force','color'};

% Load current SpareObjects struct from handles
SpareObjects=struct2cell(handles.SpareObjects);

% Update SpareObjects List
SpareObjects(:,get(handles.SpareObjectsList,'Value'))=[];

% Convert Spare Objects List to struct
SpareObjects=cell2struct(SpareObjects',characteristics,2);

handles=guidata(hObject);
handles.SpareObjects=SpareObjects;
guidata(hObject,handles);

SpareObjectListboxString=[];
for ii=1:length(SpareObjects)
    if isfield(SpareObjects,'name')
        SpareObjectListboxString=[SpareObjectListboxString; cellstr(SpareObjects(ii).name)];
    end
end

set(handles.SpareObjectsList,'Value',1);
set(handles.SpareObjectsList,'string',SpareObjectListboxString);


% --- Executes on button press in ObjectName.
function ObjectName_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.ObjectList,'UserData')
    contents = cellstr(get(handles.ObjectList,'String'));
    Name=contents{get(handles.ObjectList,'Value')};
elseif get(handles.SpareObjectsList,'UserData')
    contents = cellstr(get(handles.SpareObjectsList,'String'));
    Name=contents{get(handles.SpareObjectsList,'Value')};
end

ObjectName = inputdlg('Choose Object Name','Object Name',1,{Name});

Objects=handles.Objects;
SpareObjects=handles.SpareObjects;

if get(handles.ObjectList,'UserData')
    Objects(get(handles.ObjectList,'Value')).name=ObjectName;
    handles=guidata(hObject);
    handles.Objects=Objects;
    guidata(hObject,handles);
    
    ObjectListboxString=[];
    for ii=1:length(Objects)
         ObjectListboxString=[ObjectListboxString; cellstr(Objects(ii).name)];
    end
    set(handles.ObjectList,'string',ObjectListboxString);
    ObjectList_Callback(hObject, eventdata, handles)
elseif get(handles.SpareObjectsList,'UserData')
    SpareObjects(get(handles.SpareObjectsList,'Value')).name=ObjectName;
    handles=guidata(hObject);
    handles.SpareObjects=SpareObjects;
    guidata(hObject,handles);
    
    SpareObjectListboxString=[];
    for ii=1:length(SpareObjects)
        if isfield(SpareObjects,'name')
            SpareObjectListboxString=[SpareObjectListboxString; cellstr(SpareObjects(ii).name)];
        end
    end
    set(handles.SpareObjectsList,'string',SpareObjectListboxString);
    SpareObjectsList_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in ObjectMass.
function ObjectMass_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectMass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if get(handles.ObjectList,'UserData')
    Objects=handles.Objects;
    Mass=Objects(get(handles.ObjectList,'Value')).mass;
elseif get(handles.SpareObjectsList,'UserData')
    SpareObjects=handles.SpareObjects;
    Mass=SpareObjects(get(handles.SpareObjectsList,'Value')).mass;
end

ObjectMass = inputdlg('Object Mass (kg)','Object Mass (kg)',1,{num2str(Mass)});
ObjectMass=str2double(ObjectMass{1});

if get(handles.ObjectList,'UserData')
    Objects(get(handles.ObjectList,'Value')).mass=ObjectMass;
    handles=guidata(hObject);
    handles.Objects=Objects;
    guidata(hObject,handles);
    ObjectList_Callback(hObject, eventdata, handles)
elseif get(handles.SpareObjectsList,'UserData')
    SpareObjects(get(handles.SpareObjectsList,'Value')).mass=ObjectMass;
    handles=guidata(hObject);
    handles.SpareObjects=SpareObjects;
    guidata(hObject,handles);
    SpareObjectsList_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in ObjectVelocity.
function ObjectVelocity_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.ObjectList,'UserData')
    Objects=handles.Objects;
    Velocity=Objects(get(handles.ObjectList,'Value')).velocity;
elseif get(handles.SpareObjectsList,'UserData')
    SpareObjects=handles.SpareObjects;
    Velocity=SpareObjects(get(handles.SpareObjectsList,'Value')).velocity;
end

ObjectVelocity = inputdlg('Object Velocity (m/s)','Object Velocity (m/s)',1,{num2str(Velocity)});
ObjectVelocity=strsplit(ObjectVelocity{1},' ');
ObjectVelocity=[str2double(ObjectVelocity(1)) str2double(ObjectVelocity(2)) ];

if get(handles.ObjectList,'UserData')
    Objects(get(handles.ObjectList,'Value')).velocity=ObjectVelocity;
    handles=guidata(hObject);
    handles.Objects=Objects;
    guidata(hObject,handles);
    ObjectList_Callback(hObject, eventdata, handles)
elseif get(handles.SpareObjectsList,'UserData')
    SpareObjects(get(handles.SpareObjectsList,'Value')).velocity=ObjectVelocity;
    handles=guidata(hObject);
    handles.SpareObjects=SpareObjects;
    guidata(hObject,handles);
    SpareObjectsList_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in ObjectPosition.
function ObjectPosition_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if get(handles.ObjectList,'UserData')
    Objects=handles.Objects;
    Position=Objects(get(handles.ObjectList,'Value')).position;
elseif get(handles.SpareObjectsList,'UserData')
    SpareObjects=handles.SpareObjects;
    Position=SpareObjects(get(handles.SpareObjectsList,'Value')).position;
end

ObjectPosition = inputdlg('Object position (m)','Object Position (m)',1,{num2str(Position)});
ObjectPosition=strsplit(ObjectPosition{1},' ');
ObjectPosition=[str2double(ObjectPosition(1)) str2double(ObjectPosition(2)) ];

if get(handles.ObjectList,'UserData')
    Objects(get(handles.ObjectList,'Value')).position=ObjectPosition;
    handles=guidata(hObject);
    handles.Objects=Objects;
    guidata(hObject,handles);
    ObjectList_Callback(hObject, eventdata, handles)
elseif get(handles.SpareObjectsList,'UserData')
    SpareObjects(get(handles.SpareObjectsList,'Value')).position=ObjectPosition;
    handles=guidata(hObject);
    handles.SpareObjects=SpareObjects;
    guidata(hObject,handles);
    SpareObjectsList_Callback(hObject, eventdata, handles)
end
