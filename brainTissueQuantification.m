function varargout = brainTissueQuantification(varargin)
% BRAINTISSUEQUANTIFICATION MATLAB code for brainTissueQuantification.fig
%      BRAINTISSUEQUANTIFICATION, by itself, creates a new BRAINTISSUEQUANTIFICATION or raises the existing
%      singleton*.
%
%      H = BRAINTISSUEQUANTIFICATION returns the handle to a new BRAINTISSUEQUANTIFICATION or the handle to
%      the existing singleton*.
%
%      BRAINTISSUEQUANTIFICATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRAINTISSUEQUANTIFICATION.M with the given input arguments.
%
%      BRAINTISSUEQUANTIFICATION('Property','Value',...) creates a new BRAINTISSUEQUANTIFICATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before brainTissueQuantification_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to brainTissueQuantification_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help brainTissueQuantification

% Last Modified by GUIDE v2.5 09-Dec-2015 14:42:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @brainTissueQuantification_OpeningFcn, ...
                   'gui_OutputFcn',  @brainTissueQuantification_OutputFcn, ...
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


% --- Executes just before brainTissueQuantification is made visible.
function brainTissueQuantification_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to brainTissueQuantification (see VARARGIN)

% Choose default command line output for brainTissueQuantification
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes brainTissueQuantification wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = brainTissueQuantification_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start T2 Relaxation with two echos\n\n')

[T2file, T2path] = uigetfile('*.nii', 'Pick T2 Weighted Nifti File');
[PDfile, PDpath] = uigetfile('*.nii', 'Pick PD Weighted Nifti File');
T2image = spm_read_vols(spm_vol([T2path '\', T2file]));
PDimage = spm_read_vols(spm_vol([PDpath '\', PDfile]));

% response = inputdlg({'Number of slices' 'Row dimension' 'Column dimension' },...
%                  'Enter your parameters',3,{'50' '256' '256'});
%                  fr = str2num(response{1});
%                  row = str2num(response{2});
%                  col = str2num(response{3});

response1 = inputdlg({'Echo time of T2 weighted image' 'Echo time of PD weighted image'},'Enter parameter values',2,{'123' '12'});
                TE2 = str2num(response1{1});
                TE1 = str2num(response1{2});

response = inputdlg({'Celing' 'Threshold'},'Enter parameter values',2,{'500' '40'});
                ceiling = str2num(response{1});
                thresh = str2num(response{2});
                
[x, y, z] = size(T2image);
T2relax = 0 * T2image;

% Compute T2 relaxation values
for i = 1:x
    for j = 1:y
        for k = 1:z
            if T2image(i, j, k) > thresh & PDimage(i, j, k) > thresh 
                T2relax(i, j, k) = (TE2 - TE1)/log(PDimage(i, j, k)/T2image(i, j, k));
                if T2relax(i, j, k) > ceiling
                    T2relax(i, j, k) = ceiling;
                end
                if T2relax(i, j, k) < 0
                    T2relax(i, j, k) = 0;
                end    
            end
        end
    end
end

ref = spm_vol([T2path '\', T2file]);

filename = [T2path, '\', [T2file(1:end-4), 'T2RelaxationMap', '.nii']];

% Write T2 map as a nii file
Vo = struct('fname', filename, 'dim', ref(1).dim(1:3), 'dt', [spm_type('float32'), 0], 'mat', ref(1).mat, 'pinfo', [1.0,0,0]', 'descrip', 'T2RelaxationMap');
Vo = spm_create_vol(Vo);
spm_write_vol(Vo, T2relax);
fprintf('T2RelaxationMap was Generated\n');
                


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start T1 Relaxation with variable flip angles\n\n');

[flip1file, flip1path] = uigetfile('*.nii', 'Pick Nifti for first Flip Angle');
[flip2file, flip2path] = uigetfile('*.nii', 'Pick Nifti for first Second Angle');

response1 = inputdlg({'Noise Threshold'},'Enter parameter value',1,{'20'});

th = str2double(response1{1});

flip1Image = spm_read_vols(spm_vol([flip1path, '\', flip1file]));
flip1Image(flip1Image < th) = 0;
flip2Image = spm_read_vols(spm_vol([flip2path, '\', flip2file]));
flip2Image(flip2Image < th) = 0;

response = inputdlg({'Flip Angle 1' 'Flip Angle 2' 'Repetetion Time'},'Enter parameter values',3,{'5' '26' '15'});
                
a1 = str2double(response{1}); a2 = str2double(response{2}); TR = str2double(response{3});

c2 = sind(a1)/sind(a2);
c1 = flip1Image./flip2Image;
C = c2./c1;
T1map = -TR/log((1-C)./(cosd(a1)-(C.*cosd(a2))));
T1map(T1map < 0) = 0;

ref = spm_vol([flip1path '\', flip1file]);

filename = [flip1path, '\', [flip1file(1:end-4), 'T1RelaxationMap', '.nii']];

% Write T2 map as a nii file
Vo = struct('fname', filename, 'dim', ref(1).dim(1:3), 'dt', [spm_type('float32'), 0], 'mat', ref(1).mat, 'pinfo', [1.0,0,0]', 'descrip', 'T1RelaxationMap');
Vo = spm_create_vol(Vo);
spm_write_vol(Vo, T1map);
fprintf('T1RelaxationMap was Generated\n');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start T2* Relaxation echos\n\n')

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start Magnetization Transfer Imaging\n\n')

[MTonfile, MTonpath] = uigetfile('*.nii', 'Pick Nifti for MTon Image');
[MTofffile, MToffpath] = uigetfile('*.nii', 'Pick Nifti for MToff Image');

response1 = inputdlg({'Noise Threshold'},'Enter parameter value',1,{'30'});

th = str2double(response1{1});

MTonImage = spm_read_vols(spm_vol([MTonpath, '\', MTonfile]));
MTonImage(MTonImage < th) = 0;
MToffImage = spm_read_vols(spm_vol([MToffpath, '\', MTofffile]));
MToffImage(MToffImage < th) = 0;


MTR = (1- (MTonImage./MToffImage))*100;
MTR(MTR > 90) = 0;
MTR(MTR < 0) = 0;

ref = spm_vol([MTonpath '\', MTonfile]);

filename = [MTonpath, '\', [MTonfile(1:end-4), 'MTRmap', '.nii']];

% Write T2 map as a nii file
Vo = struct('fname', filename, 'dim', ref(1).dim(1:3), 'dt', [spm_type('float32'), 0], 'mat', ref(1).mat, 'pinfo', [1.0,0,0]', 'descrip', 'MTRmap');
Vo = spm_create_vol(Vo);
spm_write_vol(Vo, MTR);
fprintf('MTR map was Generated\n');


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start T2 Relaxation with multiple echos\n\n')

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start T1 Relaxation with variable TRs\n\n')

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start T1/T2 Mapping (Myelin Contrast)\n\n')

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Start Entropy Mapping\n\n')


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
