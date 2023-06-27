function varargout = fix_tree_UI(varargin)
% FIX_TREE_UI MATLAB code for fix_tree_UI.fig
%      FIX_TREE_UI, by itself, creates a new FIX_TREE_UI or raises the existing
%      singleton*.
%
%      H = FIX_TREE_UI returns the handle to a new FIX_TREE_UI or the handle to
%      the existing singleton*.
%
%      FIX_TREE_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIX_TREE_UI.M with the given input arguments.
%
%      FIX_TREE_UI('Property','Value',...) creates a new FIX_TREE_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fix_tree_UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fix_tree_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fix_tree_UI

% Last Modified by GUIDE v2.5 26-Jun-2023 11:07:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fix_tree_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @fix_tree_UI_OutputFcn, ...
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


% --- Executes just before fix_tree_UI is made visible.
function fix_tree_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fix_tree_UI (see VARARGIN)
cla;
% tempoary 
% use to check statistics with intentionally cut trees
global tree;
uiwait(msgbox('Upload an input tree to be repaired.'));
tree = load_tree();
if iscell(tree)
    tree = tree{1};
end

uiwait(msgbox('Upload a reference tree. Can be the sames as the input tree!'));
referencetree = load_tree();
if iscell(referencetree)
    referencetree = referencetree{1};
end
hold on;
plot_tree(referencetree);
handles.referencetree = referencetree;

% mark original tree to be able to identify new grown parts
check1Dia = find(tree.D == 1);
tree.D(check1Dia) = 1.001;
% tree = tran_tree(tree);

%% rotate tree
for ctr = 1:length(tree.rnames)    
    if strcmp(tree.rnames{ctr},'Apical') || strcmp(tree.rnames{ctr},'apical')
    	APICALnr = ctr;
    end
end
if ~exist('APICALnr')
    APICALnr = 1;
end
ind_dend = find(tree.R == APICALnr);
FullDendpts = [];
FullDendpts(:,1) = tree.X(ind_dend);
FullDendpts(:,2) = tree.Y(ind_dend);
FullDendpts(:,3) = tree.Z(ind_dend);
valid_pts = [];
euclid_dist_soma = sqrt((FullDendpts(:,1)).^2+...
                        (FullDendpts(:,2)).^2+...
                        (FullDendpts(:,3)).^2);
valid_ind       = find(euclid_dist_soma > 2*max(euclid_dist_soma)/5);
valid_pts(:,1) = FullDendpts(valid_ind,1);
valid_pts(:,2) = FullDendpts(valid_ind,2);
valid_pts(:,3) = FullDendpts(valid_ind,3);

% get angles in sphereical coordinates
[azimuth,elevation,r] = cart2sph(valid_pts(:,1),valid_pts(:,2),valid_pts(:,3));
mean_azimuth    = mean(azimuth);
mean_elevation  = mean(elevation);
deg_azimuth = mean_azimuth*(180/pi);
deg_elevation = mean_elevation*(180/pi);

% tree = rot_tree(tree,[0 -deg_elevation deg_azimuth]);

TrPlot = plot_tree(tree,[1 0 0]); 

handles.xPlL = xlim; handles.yPlL = ylim; handles.zPlL = zlim;
xlabel('x')
ylabel('y')
zlabel('z')
shine;
% Choose default command line output for fix_tree_UI
%% save variables in handle
handles.output = hObject;
if ~isfield(handles,'tree')
    handles.tree   = tree;
end
handles.Imstack    = [];
handles.newrootCoord = [];
handles.stackMxz = [];
handles.stackMyz = [];
% 1 -> xy plane; 2 -> xz plane; 3 -> yz plane
handles.planeind    = 1;
handles.NVolumes    = 1;
handles.boundAlpha  = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fix_tree_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fix_tree_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Save_Vol_Coord.
function Save_Vol_Coord_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Vol_Coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% select points for Volume
% initialize plane index
if ~isfield(handles,'nPtsPerSelec')
    handles.nPtsPerSelec{1} = [];
    handles.PtsPlaneind{1} = [];
    handles.xChosen{1} = [];
    handles.yChosen{1} = [];
    handles.zChosen{1} = [];
end
if ~isfield(handles,'NVolumes')
    handles.NVolumes = 1;
end
volind = handles.NVolumes;

Volx = []; Voly = []; Volz = [];
[x,y,z] = ginput_plot;

z = zeros(length(z),1);
hold on;
scatter3(x,y,z,'filled','r'); 

disp(strcat(num2str(length(x))," Point/s were selected"));
handles.nPtsPerSelec{volind} = [handles.nPtsPerSelec{volind};length(x)];
handles.PtsPlaneind{volind} = [handles.PtsPlaneind{volind};handles.planeind];
handles.xChosen{volind} = [handles.xChosen{volind};x];
handles.yChosen{volind} = [handles.yChosen{volind};y];
handles.zChosen{volind} = [handles.zChosen{volind};z];
guidata(hObject, handles);



% --- Executes on button press in xy_axis.
function xy_axis_Callback(hObject, eventdata, handles)
% hObject    handle to xy_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla
plot_tree(handles.referencetree,[1 0 0]);
plot_tree(handles.tree); 
xlabel('x');
ylabel('y');
zlabel('z');
% view(0,90)
handles.planeind = 1;
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);
% zlim auto

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in xz_axis.
function xz_axis_Callback(hObject, eventdata, handles)
% hObject    handle to xz_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[outtree] = swaptreeaxis(handles.tree,'xz');
[outtree2] = swaptreeaxis(handles.referencetree,'xz');
cla
plot_tree(outtree2,[1 0 0]);
plot_tree(outtree); 
xlabel('x');
ylabel('z');
zlabel('y');
% view(0,0)
handles.planeind = 2;
if ~isempty(handles.Imstack)
    if isempty(handles.stackMxz)
        tempstack = handles.Imstack.M{1};
        newstack = handles.Imstack;
        newstack.M{1} = permute(tempstack,[3 2 1]);
        newstack.voxel(1) = handles.Imstack.voxel(1);
        newstack.voxel(2) = handles.Imstack.voxel(3);
        newstack.voxel(3) = handles.Imstack.voxel(2);
        HaStack = show_stack(newstack);
        handles.stackMxz = newstack.M{1};
    else
        newstack = handles.Imstack;
        newstack.M{1} = handles.stackMxz;
        newstack.voxel(1) = handles.Imstack.voxel(1);
        newstack.voxel(2) = handles.Imstack.voxel(3);
        newstack.voxel(3) = handles.Imstack.voxel(2);
        HaStack = show_stack(newstack);
    end
    StMaxX = size(newstack.M{1},2)*newstack.voxel(1);
    StMaxY = size(newstack.M{1},1)*newstack.voxel(2);
    XlimMax = max([StMaxX,max(outtree.X)]);
    XlimMin = min([0,min(outtree.X)]);
    YlimMax = max([StMaxY,max(outtree.Y)]);
    YlimMin = min([0,min(outtree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(outtree.X); XlimMin = min(outtree.X);
    YlimMax = max(outtree.Y); YlimMin = min(outtree.Y);
end

if XlimMin == 0 && XlimMax == 0
else
    xlim([XlimMin XlimMax]);
end
if YlimMin == 0 && YlimMax == 0
    ylim([-50 50]);
else
    ylim([YlimMin YlimMax]);
end
handles.output = hObject;
guidata(hObject, handles);



% --- Executes on button press in yz_axis.
function yz_axis_Callback(hObject, eventdata, handles)
% hObject    handle to yz_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[outtree] = swaptreeaxis(handles.tree,'yz');
[outtree2] = swaptreeaxis(handles.referencetree,'yz');
cla
plot_tree(outtree2,[1 0 0]);
plot_tree(outtree); 
limx = max([max(outtree.X),abs(min(outtree.X))])+20;
limy = max([max(outtree.Y),abs(min(outtree.Y))])+20;
% xlim([-limx limx]);
% ylim([-limy limy]);
xlabel('y');
ylabel('z');
zlabel('x');
% view(-90,0)
handles.planeind = 3;
if ~isempty(handles.Imstack)
    if isempty(handles.stackMyz)
        tempstack = handles.Imstack.M{1};
        newstack = handles.Imstack;
        newstack.M{1} = permute(tempstack,[3 1 2]);
        newstack.voxel(1) = handles.Imstack.voxel(2);
        newstack.voxel(2) = handles.Imstack.voxel(3);
        newstack.voxel(3) = handles.Imstack.voxel(1);
        HaStack = show_stack(newstack);
        handles.stackMyz = newstack.M{1};
    else
        newstack = handles.Imstack;
        newstack.M{1} = handles.stackMyz;
        newstack.voxel(1) = handles.Imstack.voxel(2);
        newstack.voxel(2) = handles.Imstack.voxel(3);
        newstack.voxel(3) = handles.Imstack.voxel(1);
        HaStack = show_stack(newstack);
    end
    StMaxX = size(newstack.M{1},2)*newstack.voxel(1);
    StMaxY = size(newstack.M{1},1)*newstack.voxel(2);
    XlimMax = max([StMaxX,max(outtree.X)]);
    XlimMin = min([0,min(outtree.X)]);
    YlimMax = max([StMaxY,max(outtree.Y)]);
    YlimMin = min([0,min(outtree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(outtree.X); XlimMin = min(outtree.X);
    YlimMax = max(outtree.Y); YlimMin = min(outtree.Y);
end

if XlimMin == 0 && XlimMax == 0
else
    xlim([XlimMin XlimMax]);
end
if YlimMin == 0 && YlimMax == 0
    ylim([-50 50]);
else
    ylim([YlimMin YlimMax]);
end
handles.output = hObject;
guidata(hObject, handles);



function [outtree] = swaptreeaxis(tree,option)
tempX = tree.X;
tempY = tree.Y;
tempZ = tree.Z;
outtree = tree;
if isempty(option)
elseif option == 'xz'
    outtree.Y = tempZ;
    outtree.Z = tempY;
elseif option == 'yz'
    outtree.X = tempY;
    outtree.Y = tempZ;
    outtree.Z = tempX;
end


% --- Executes on button press in Repair_Tree.
function Repair_Tree_Callback(hObject, eventdata, handles)
% hObject    handle to Repair_Tree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Repair tree
handles.NVolumes = length(handles.xChosen);
if ~isfield(handles,'xChosen')
    error('please select points for at least one dendrite volume');
end
if ~isfield(handles,'nPtsPerSelec')
    error('please select points for the dendrite volume');
elseif iscell(handles.nPtsPerSelec)
    if isempty(handles.nPtsPerSelec{1})
%         error('please select points for the dendrite volume');
    end            
end
for hhh = 1:handles.NVolumes
    if isempty(handles.PtsPlaneind{hhh}) || length(unique(handles.PtsPlaneind{hhh})) <= 1
%         handles.NVolumes = handles.NVolumes-1;
        disp(strcat("You have not selected enough points for Volume ",num2str(hhh)));
        if length(handles.xChosen) == 1
            disp("Warning: You have not selected sufficient points for any other Volume, this will likely produce an error!!!");
        end
    end
end
if isfield(handles,'RepTree')
    handles = rmfield(handles,'RepTree');
end
if logical(get(handles.cut_growth_enable,'Value')) & ~isfield(handles.tree,'IncompleteTerminals')
    disp('Cut growth is not possible since no IncompleteTerminals have been specified in the morphologie!');
    error('Error');
elseif logical(get(handles.cut_growth_enable,'Value')) & isempty(handles.tree.IncompleteTerminals)
    disp('Cut growth is not possible since no IncompleteTerminals have been specified in the morphologie!');
    error('Error');
end
disp("Calculation started");

if isfield(handles,'NPts_User')
    if length(handles.NPts_User) < handles.NVolumes
        for ttt = length(handles.NPts_User)+1:handles.NVolumes
            handles.NPts_User{ttt} = [];
        end
    end
end

% rest of params further down
resample_rate               = 1;
handles.treeParams.resample_rate = resample_rate;

FixTree = handles.tree;
startLen = sum(len_tree(FixTree))
startBpt = sum(B_tree(FixTree))
checkregions = '';
for ctr = 1:length(FixTree.rnames)
    checkregions = strcat(checkregions,FixTree.rnames{ctr});
end
if contains(checkregions,'Apical') && contains(checkregions,'Dendrite') && contains(checkregions,'CellBody')
    regionsOK = 1;
elseif contains(checkregions,'apical') && contains(checkregions,'dendritic') && contains(checkregions,'soma')
    regionsOK = 1;
elseif contains(checkregions,'apical') && contains(checkregions,'basal') && contains(checkregions,'soma')
    regionsOK = 1;
elseif contains(checkregions,'apical') && contains(checkregions,'basal') && contains(checkregions,'Soma')
    regionsOK = 1;
else
    regionsOK = 0;
end
if regionsOK == 1
    for ctr = 1:length(FixTree.rnames)    
        if strcmp(FixTree.rnames{ctr},'Apical') || strcmp(FixTree.rnames{ctr},'apical')
            Apind = ctr;
        elseif strcmp(FixTree.rnames{ctr},'Dendrite') || strcmp(FixTree.rnames{ctr},'dendritic') || strcmp(FixTree.rnames{ctr},'basal')
            Baind = ctr;
        elseif strcmp(FixTree.rnames{ctr},'CellBody') || strcmp(FixTree.rnames{ctr},'soma') || strcmp(FixTree.rnames{ctr},'Soma')
            Soind = ctr;
        end
    end
    
   
    
    allind = 1:1:length(FixTree.R);
    Ap_So = find(FixTree.R == Apind | FixTree.R == Soind);
    Ba_So = find(FixTree.R == Baind | FixTree.R == Soind);
    elim_BA = ~ismember(allind,Ap_So);
    elim_AP = ~ismember(allind,Ba_So);
    elim_BA = allind(elim_BA);
    elim_AP = allind(elim_AP);
    apical  = delete_tree(FixTree,elim_BA);                
    basal   = delete_tree(FixTree,elim_AP);
else
end

% check if regions in reference tree and Fixtree are identical
if isfield(handles,'referencetree') && ~isempty(handles.referencetree)
    if length(FixTree.rnames) == length(handles.referencetree.rnames)
        for ctr = 1:length(handles.referencetree.rnames)
            if ~strcmp(FixTree.rnames{ctr},handles.referencetree.rnames{ctr})
                error('Input tree and Reference tree do not have the same regions specified in the morphology file')
            end
        end
    else
        error('Input tree and Reference tree do not have the same regions specified in the morphology file')
    end
end

% get R value of tree corresponding to point clustering
% if tree is 2D r_mc_tree does not work
if sum(FixTree.Z) == 0
    R = 0.5;
else
    R = r_mc_tree (FixTree,[],10,[],'-bt');
end

% get taper params
[tapPars,~] = quadfit_tree(FixTree);

% rootangle = rootangle_tree (FixTree,'-s');
% AngV        = linspace   (0, pi, 25);
% pdf         = histcounts (rootangle, AngV);
% mAngV       = (AngV (2 : 25) + AngV (1 : 24)) / 2;
% angledens   = pdf / trapz (mAngV, pdf);
% Adensmaxind = find(angledens == max(angledens));
% bf_derived = 1-(Adensmaxind/length(angledens));
%% get volume
for volct = 1:length(handles.xChosen)
    % parameters
    if ~isfield(handles,'bf_par') || isempty(handles.bf_par{volct})
        bf_derived              = bf_tree (FixTree);
        bfapical                = bf_derived;
    else
        bfapical                = handles.bf_par{volct};
    end
    % bfbasal     = 0.65;
    if ~isfield(handles,'offset_taperpar') || isempty(handles.offset_taperpar{volct})
        colapictaper_offset     = tapPars(2);%0.30; 
    else
        colapictaper_offset     = handles.offset_taperpar{volct};
    end
    if ~isfield(handles,'scale_taperpar') || isempty(handles.scale_taperpar{volct})
        colapictaper_scale      = tapPars(1);%0.1;
    else
        colapictaper_scale      = handles.scale_taperpar{volct};
    end
    if ~isfield(handles,'thresh_taperpar') || isempty(handles.thresh_taperpar{volct})
        taperthreshold          = colapictaper_offset-colapictaper_offset*0.1;
    else
        taperthreshold          = handles.thresh_taperpar{volct};
    end
    stde                        = 0.15;

    if ~isfield(handles,'MST_prunelen') || isempty(handles.MST_prunelen{volct})
        prunlen                 = 0;
    else
        prunlen                 = handles.MST_prunelen{volct};
    end
    if ~isfield(handles,'main_thickratio') || isempty(handles.main_thickratio)
        main_thickratio         = 0.7;
    else
        main_thickratio         = handles.main_thickratio;
    end 
    if ~isfield(handles,'RmPts_Dist') || isempty(handles.RmPts_Dist{volct})
        RmPts_Dist         = 25;
    else
        RmPts_Dist         = handles.RmPts_Dist{volct};
    end 
   
    if isempty(handles.xChosen{volct})
        disp(strcat("Volume ",num2str(volct)," was not specified."));
        disp("Therefore it was discarded.");
    else
        % compile selected coordinates from the GUI to the growth volume
        % for the repair. Their can be multiple selected volumina hence the
        % for loop.
        disp(strcat("Repairing Volume ",num2str(volct)));
        VolPerim = [];
        startind = 1;
        stopind  = handles.nPtsPerSelec{volct}(1);
        for ctr = 1:length(handles.nPtsPerSelec{volct})
            planeInd = handles.PtsPlaneind{volct}(ctr); 
            tempxC = handles.xChosen{volct}(startind:stopind);
            tempyC = handles.yChosen{volct}(startind:stopind);
            switch planeInd
                case 1
                    fillC = zeros(handles.nPtsPerSelec{volct}(ctr),1);
                    VolPerim = [VolPerim;tempxC,tempyC,fillC];
                case 2
                    fillC = zeros(handles.nPtsPerSelec{volct}(ctr),1);
                    VolPerim = [VolPerim;tempxC,fillC,tempyC];
                case 3
                    fillC = zeros(handles.nPtsPerSelec{volct}(ctr),1);
                    VolPerim = [VolPerim;fillC,tempxC,tempyC];
            end        
            startind    = stopind+1;
            if ctr == length(handles.nPtsPerSelec{volct})
                break;
            else
                stopind = stopind+handles.nPtsPerSelec{volct}(ctr+1);
            end
        end
        meanx = mean(VolPerim(find(VolPerim(:,1) ~= 0),1));
        meany = mean(VolPerim(find(VolPerim(:,2) ~= 0),2));
        meanz = mean(VolPerim(find(VolPerim(:,3) ~= 0),3));
        VolPerim(find(VolPerim(:,1) == 0),1) = meanx;
        VolPerim(find(VolPerim(:,2) == 0),2) = meany;
        VolPerim(find(VolPerim(:,3) == 0),3) = meanz;
        handles.VolPerim{volct} = VolPerim;           

        if ~exist('PreviousTree')
            PreviousTree = FixTree;
        elseif exist('APReptree')
            PreviousTree = APReptree;
        end
        
        % promt to upload volume coordinates if available. can be canceled
        % if GUi selected coordinates should be used.
        [PtsfileName,Filpath] = uigetfile('*.mat','Upload set of 3D or 2D coordinates in .mat format. Otherwise press cancel.');
        if PtsfileName == 0
        else
            loadPtsstrct = load(strcat(Filpath,PtsfileName));
            loadfields = fieldnames(loadPtsstrct);
            CutVolPts = getfield(loadPtsstrct,loadfields{1});
            VolPerim = CutVolPts;%*1.1;
            handles.VolPerim{volct} = VolPerim;
        end
        %---------------------------------------------------------
        % initiate all parameters and run fix_tree function
        disp(strcat("Cut growth check value is ",num2str(logical(get(handles.cut_growth_enable,'Value')))));
        CutGrowth = logical(get(handles.cut_growth_enable,'Value'));
        % enalbe main branch growth (choice)
        disp(strcat("Main growth check value is ",num2str(logical(get(handles.mainBrGrowth,'Value')))));
        MainGrowth = logical(get(handles.mainBrGrowth,'Value'));
        if ~isfield(handles,'MST_growthThr') || isempty(handles.MST_growthThr{volct})
        else
            params.MST_growthThr    = handles.MST_growthThr{volct};
        end
        if ~isfield(handles,'NPts_User') || isempty(handles.NPts_User{volct})        
        else
            params.NPts_User        = handles.NPts_User{volct};
        end
        InputVol.Pts    = VolPerim;
        InputVol.alpha  = handles.boundAlpha;
        params.R                = R;
        params.taper_pars(1)    = colapictaper_scale;
        params.taper_pars(2)    = colapictaper_offset;
        params.taper_thresh     = taperthreshold;
        params.bf_par           = bfapical;
        params.jitter_stde      = stde;
        params.jitter_lambda    = 10;
        params.RmPts_Dist       = RmPts_Dist;
        params.MST_prunelen     = prunlen;
        params.res_rate         = resample_rate;
        params.cut_growth       = CutGrowth;
        params.main_thickratio  = main_thickratio;
        if volct ~= 1
           params.mainBr_growth = 0;
        else
           params.mainBr_growth = MainGrowth; 
        end
        
        % enable prune to length or not!
        if ~isfield(handles,'maxNrBranchPts_User')
            InputRefTree = []; 
        end
        if isfield(handles,'maxNrBranchPts_User') && ischar(handles.maxNrBranchPts_User)
            if contains(handles.maxNrBranchPts_User,'ref')  
                InputRefTree = handles.referencetree;   
            elseif isfield(handles,'maxNrBranchPts_User') && contains(handles.maxNrBranchPts_User,'reset')
                InputRefTree = [];
                params.maxNrBranchPts = [];
            end       
        end
        if isfield(handles,'maxNrBranchPts_User') && ~ischar(handles.maxNrBranchPts_User)
            InputRefTree = [];
            params.maxNrBranchPts = handles.maxNrBranchPts_User;
        end
            
%         % maxNrBranch = 0 -> maxDendLen = 0 -> enable prune to length
%         if ~isfield(handles,'maxNrBranchPts_User')
%             InputRefTree = [];   
%         elseif isfield(handles,'maxNrBranchPts_User') & handles.maxNrBranchPts_User < 0
%             InputRefTree = [];
%             if isfield(handles,'maxNrBranchPts_User') & handles.maxDendLen_User < 0
%                 InputRefTree = handles.referencetree;
%             end
%         elseif isfield(handles,'maxNrBranchPts_User') & handles.maxNrBranchPts_User > 0
%             InputRefTree = [];
%             params.maxNrBranchPts = handles.maxNrBranchPts_User;
%         else
%             InputRefTree = handles.referencetree;
%         end
        
        if CutGrowth
            [APReptree,OutData] = fix_tree(PreviousTree,...
                FixTree,...
                InputRefTree,...
                InputVol,...
                params,...
                '-B');
        else                          
            if ~CutGrowth && isfield(FixTree,'IncompleteTerminals') && size(FixTree.IncompleteTerminals,1) == 1
                [APReptree,OutData] = fix_tree(PreviousTree,...
                    FixTree,...
                    InputRefTree,...
                    InputVol,...
                    params,...
                    '-B -V');
            else
                [APReptree,OutData] = fix_tree(PreviousTree,...
                    FixTree,...
                    InputRefTree,...
                    InputVol,...
                    params,...
                    '-B');
            end
        end
        
        IndVolBou{volct}    = OutData.IndVolBou;
        ClustPCheck{volct}  = OutData.ClustPCheck;
        VolPtsCheck{volct}  = OutData.VolPtsCheck;
        RepTreeIter{volct}  = OutData.RepTreeIter;
        growThr             = OutData.growThr;
        selectNPts          = OutData.selectNPts;
        polyshape           = OutData.polyshape;
        meanVol             = OutData.meanVol;
        InComI              = OutData.InComI;
        VolPolyshape{volct} = polyshape;
        clear vars params
        %---------------------------------------------------------
        
    end
end
                                   
% find nodes of new tree after tree is resampled
% resampling changes the nodes and adds new ones
ReptreeNoEdit = APReptree;
% prune before resampling
% 0 = TP, 1 = CP, 2 = BP :
typeN = (ones (1, size (APReptree.dA, 1)) * APReptree.dA)';
termptsAPtree = find(typeN == 0); 
[prsect prvec] = dissect_tree(APReptree);
lenAPtree = len_tree(APReptree);
FixTfinalI = length(FixTree.X);
NewNodesInd = FixTfinalI+1:1:length(APReptree.X);
allsegnodes = [];
prunInd = [];
PrunedNodeMem = [];
for zz = 1:length(NewNodesInd)
    if ismember(NewNodesInd(zz),termptsAPtree)
        allsegnodes = find(prvec(:,1) == prvec(NewNodesInd(zz),1));
        FixTNodesCheck = find(allsegnodes < FixTfinalI);
        FixTNodesCheck = [FixTNodesCheck;find(ismember(allsegnodes,InComI) == 1)];
        DoubleFixTBrPt = find(prsect(:,1) == prsect(prvec(NewNodesInd(zz),1),1));        
        if isempty(FixTNodesCheck) & ~ismember(prsect(DoubleFixTBrPt(1),1),PrunedNodeMem)
            if sum(lenAPtree(allsegnodes)) <= prunlen
                prunInd = [prunInd;allsegnodes];
                if ~isempty(find(prsect(DoubleFixTBrPt,1) < FixTfinalI))
                    PrunedNodeMem = [PrunedNodeMem,prsect(DoubleFixTBrPt(1),1)];
                end
            end           
        end
    end
end
if ~isempty(prunInd)
    APReptree = delete_tree(APReptree,prunInd);
end
if isfield(APReptree,'IncompleteTerminals')
    APReptree.FormerIncTerms = APReptree.IncompleteTerminals;
    APReptree.IncompleteTerminals = [];
    APReptree.IncompleteTerminals(:,1) = APReptree.X(InComI);
    APReptree.IncompleteTerminals(:,2) = APReptree.Y(InComI);
    APReptree.IncompleteTerminals(:,3) = APReptree.Z(InComI);
end
% % APReptree = elimt_tree(APReptree);
% % APReptree = resample_tree(APReptree, resample_rate,'-r');
% get new part
TrueInd = find(APReptree.D == 1);
% resample new part of tree
LRtree = len_tree(APReptree);
PRtree = idpar_tree(APReptree);

for Resct = 1:length(TrueInd)
    CurLen = LRtree(TrueInd(Resct));
    if CurLen <= resample_rate
        continue;
    end
    CurPar = PRtree(TrueInd(Resct));
    CurPts = [APReptree.X(CurPar),APReptree.Y(CurPar),APReptree.Z(CurPar);...
        APReptree.X(TrueInd(Resct)),APReptree.Y(TrueInd(Resct)),APReptree.Z(TrueInd(Resct))];
    
    facRes = CurLen/resample_rate;
    vecRes = [-CurPts(1,1)+CurPts(2,1),...
        -CurPts(1,2)+CurPts(2,2),...
        -CurPts(1,3)+CurPts(2,3)];
    
    ReAddPt = [];
    for tta = 1:floor(facRes)-1
        ReAddPt = [CurPts(1,1)+((vecRes(:,1)/floor(facRes))*tta),...
            CurPts(1,2)+((vecRes(:,2)/floor(facRes))*tta),...
            CurPts(1,3)+((vecRes(:,3)/floor(facRes))*tta)];
        APReptree.X(end+1)    = ReAddPt(1);
        APReptree.Y(end+1)    = ReAddPt(2);
        APReptree.Z(end+1)    = ReAddPt(3);
        APReptree.D(end+1)    = 1;
        APReptree.R(end+1)    = APReptree.R(CurPar);
        % add row and column
        APReptree.dA(end+1,end+1)   = 0;
        % remove existing connection
        APReptree.dA(TrueInd(Resct),CurPar) = 0;
        % establish new connection
        APReptree.dA(end,CurPar)              = 1;
        APReptree.dA(TrueInd(Resct),end)      = 1;
        CurPar = length(APReptree.X);
        TrueInd = [TrueInd;length(APReptree.R)];
    end
end
%         figure;
%         hold on;
%         plot_tree(APReptree); shine
%         scatter3(APReptree.X(TrueInd),...
%                  APReptree.Y(TrueInd),...
%                  APReptree.Z(TrueInd),'filled','r');
% now jitter and smooth
HypoTree = jitter_tree(APReptree ,stde);
HypoTree = smooth_tree(HypoTree, 0.5, 0.9, 10);
APReptree.X(TrueInd) = HypoTree.X(TrueInd);
APReptree.Y(TrueInd) = HypoTree.Y(TrueInd);
APReptree.Z(TrueInd) = HypoTree.Z(TrueInd);
% smooth hard corners
changetree = APReptree;
[Corsect Corvec] = dissect_tree(changetree);
newNodeSegs = Corvec(TrueInd,1);
newNodeLper = Corvec(TrueInd,2);
SegNr = unique(newNodeSegs);
findpars = idpar_tree(changetree);
for ancheck = 1:length(SegNr)
    currsegNr = SegNr(ancheck);
    currInds = find(newNodeSegs == currsegNr);
    for ancheck2 = 1:length(currInds)
        parInd = findpars(TrueInd(currInds(ancheck2)));
        parparInd = findpars(parInd);
        childInd = find(findpars == TrueInd(currInds(ancheck2)));
        pardir(1) = changetree.X(parInd)-changetree.X(parparInd);
        pardir(2) = changetree.Y(parInd)-changetree.Y(parparInd);
        pardir(3) = changetree.Z(parInd)-changetree.Z(parparInd);
        if isempty(childInd) || length(childInd) > 1
            chidir = pardir;
        else
            chidir(1) = changetree.X(childInd)-changetree.X(TrueInd(currInds(ancheck2)));
            chidir(2) = changetree.Y(childInd)-changetree.Y(TrueInd(currInds(ancheck2)));
            chidir(3) = changetree.Z(childInd)-changetree.Z(TrueInd(currInds(ancheck2)));           
        end
        changetree.X(TrueInd(currInds(ancheck2))) = changetree.X(parInd)+pardir(1)/2+chidir(1)/2;
        changetree.Y(TrueInd(currInds(ancheck2))) = changetree.Y(parInd)+pardir(2)/2+chidir(2)/2;
        changetree.Z(TrueInd(currInds(ancheck2))) = changetree.Z(parInd)+pardir(3)/2+chidir(3)/2;
    end
end
APReptree.X(TrueInd) = changetree.X(TrueInd);
APReptree.Y(TrueInd) = changetree.Y(TrueInd);
APReptree.Z(TrueInd) = changetree.Z(TrueInd);

% prune to exact size if specified by user
if isfield(handles,'maxDendLen_User')            
    mDlen      = handles.maxDendLen_User;
else
    mDlen = [];
end
if isfield(handles,'maxNrBranchPts_User')
    mNBr      = handles.maxNrBranchPts_User;
else
    mNBr = [];
end
% if mNBr <= 0 & mDlen == 0
%     mDlen = sum(len_tree(handles.referencetree));
%     mNBr = sum(B_tree(handles.referencetree));
% elseif mNBr < 0 & mDlen < 0
%     mNBr = [];
%     mDlen = [];
% end

if ischar(mNBr) && ischar(mDlen)
    if contains(mNBr,'ref') && contains(mDlen,'ref')
        mDlen = sum(len_tree(handles.referencetree));
        mNBr = sum(B_tree(handles.referencetree));
    elseif contains(mNBr,'reset') && contains(mDlen,'reset')
        mNBr = [];
        mDlen = [];
    end
end
if ischar(mNBr)
    if contains(mNBr,'ref')
        mNBr = sum(B_tree(handles.referencetree));
    elseif contains(mNBr,'reset')
        mNBr = [];
    end
end
if ischar(mDlen)
    if contains(mDlen,'ref')
        mDlen = sum(len_tree(handles.referencetree));
    elseif contains(mDlen,'reset')
        mDlen = [];
    end
end

if isempty(mNBr) && isempty(mDlen)
elseif ~isempty(mNBr) && ischar(mNBr) && contains(mNBr,'nofit') && isempty(mDlen)
else
    [APReptree,TrueInd] = finetune_fix_tree(FixTree,APReptree,bfapical,TrueInd,VolPolyshape,mNBr,mDlen);
end

% taper tree here
getparent = idpar_tree(APReptree);
NewParents = getparent(TrueInd);
ConParents = NewParents(find(~ismember(NewParents,TrueInd) == 1));
ConParents = unique(ConParents);
HypoTree = quaddiameter_tree (APReptree,colapictaper_scale,... %colapictaper_scale
                              colapictaper_offset);   %,[],[],[],taperthreshold(1);
quadp_ind = find(HypoTree.D < taperthreshold);
HypoTree.D(quadp_ind) = taperthreshold;
APReptree.D(TrueInd) = HypoTree.D(TrueInd);
% smooth taper transition
DiaChInds = [];
NewDias = [];
for parct = 1:length(ConParents)    
    DiaChInds = [DiaChInds;find(getparent == ConParents(parct))];
    currTind = find(getparent == ConParents(parct));
    for chilind = 1:length(currTind)
        if APReptree.D(ConParents(parct)) > APReptree.D(currTind(chilind))       
            NewDias = [NewDias,...
                       APReptree.D(currTind(chilind))+...
                       abs(APReptree.D(ConParents(parct))-APReptree.D(currTind(chilind)))*0.6];
        elseif APReptree.D(ConParents(parct)) < APReptree.D(currTind(chilind))
            NewDias = [NewDias,...
                       APReptree.D(currTind(chilind))-...
                       abs(APReptree.D(ConParents(parct))-APReptree.D(currTind(chilind)))*0.6];
        else
            NewDias = [NewDias,APReptree.D(ConParents(parct))];
        end
    end
end
APReptree.D(DiaChInds) = NewDias;
APReptree.RepInds = TrueInd;

% make a tree just for plotting
FixInds = 1:length(APReptree.R);
FixInds(find(ismember(FixInds,TrueInd) == 1)) = [];
RepTreePLOT1 = APReptree;
RepTreePLOT2 = delete_tree(APReptree,TrueInd);
% -----------
%         figure;
%         hold on;
%         plot_tree(APReptree,APReptree.R); shine 

PlotAPReptree = resample_tree(APReptree, 2,'-r');
handles.RepTree{1} = APReptree; 

%% figures (create output figures in this section)
cla
% figure;
hold on;
% only if there is a reference tree that needs to be checked
referencetree = resample_tree(handles.referencetree,2);
% plot_tree(referencetree,[0 0 1]);
% --------
% FixTree = resample_tree(FixTree,2);
plot_tree(APReptree,[1 0 0],[],TrueInd); %RepairedTree
plot_tree(RepTreePLOT2); %FixTree
xlim auto
ylim auto
xlabel('x');
ylabel('y');
zlabel('z');
handles.planeind = 1;
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(PlotAPReptree.X)]);
    XlimMin = min([0,min(PlotAPReptree.X)]);
    YlimMax = max([StMaxY,max(PlotAPReptree.Y)]);
    YlimMin = min([0,min(PlotAPReptree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(PlotAPReptree.X); XlimMin = min(PlotAPReptree.X);
    YlimMax = max(PlotAPReptree.Y); YlimMin = min(PlotAPReptree.Y);
end

xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);

figure;
if length(FixTree.R) == length(handles.referencetree.R)
    plot_tree(handles.referencetree);
else
    TreeRefC = [];
    TreeRefC(:,1) = handles.referencetree.X;
    TreeRefC(:,2) = handles.referencetree.Y;
    TreeRefC(:,3) = handles.referencetree.Z;
    c = hull_tree(FixTree, 8, [], [], [], '-w');
    CheckCuts = inpolyhedron(c,TreeRefC);
    CutRefInds = find(CheckCuts == 0);
    CutTreeInds = find(CheckCuts == 1);
    hold on;
    plot_tree(handles.referencetree,[1 0 0],[],CutRefInds);
    plot_tree(handles.referencetree,[],[],CutTreeInds);
end  
xlabel('Ref Morphology');


figure;
disp(strcat("Growth Threshold ",num2str(growThr)));
disp(strcat("Balancing Factor ",num2str(bfapical)));
hold on;
plot_tree(RepTreePLOT2); %FixTree
for cttr = 1:length(VolPtsCheck)
    if ~isempty(handles.xChosen{cttr})
        colorvary = 1/cttr;
        disp(strcat(num2str(length(VolPtsCheck{cttr})),...
             " Pts for Volume ",num2str(cttr)));
        scatter3(ClustPCheck{cttr}(:,1),...
                 ClustPCheck{cttr}(:,2),...
                 ClustPCheck{cttr}(:,3),...
                 'MarkerFaceColor',[colorvary,0,0])
        if ~isempty(IndVolBou{cttr})
            trisurf(IndVolBou{cttr},...
                    handles.VolPerim{cttr}(:,1),...
                    handles.VolPerim{cttr}(:,2),...
                    handles.VolPerim{cttr}(:,3),'Facecolor','red','FaceAlpha',0.1);
        end
    end
end

figure;
plot_tree(PlotAPReptree,PlotAPReptree.R);

figure;
hold on;
plot_tree(APReptree,[1 0 0],[],TrueInd);
plot_tree(RepTreePLOT2);
if isfield(FixTree,'IncompleteTerminals')
    scatter3(FixTree.IncompleteTerminals(:,1),...
             FixTree.IncompleteTerminals(:,2),...
             FixTree.IncompleteTerminals(:,3),'filled','b');
end
for cttr = 1:length(handles.xChosen)  
    if isempty(handles.xChosen{cttr})
    else
        if ~isempty(IndVolBou{cttr})
            trisurf(IndVolBou{cttr},...
                    handles.VolPerim{cttr}(:,1),...
                    handles.VolPerim{cttr}(:,2),...
                    handles.VolPerim{cttr}(:,3),'Facecolor','blue','FaceAlpha',0.1,'LineStyle','none');
        end
    end
end
xlabel('RepVol Morphology');
% 
% IAP=find(APReptree.R == 1)
% IAX=find(APReptree.R == 2)
% ISO=find(APReptree.R == 3)
% IBA=find(APReptree.R == 4)
% dipind = ISO;
% colourr = 'r';
% hold on;
% scatter3(APReptree.X(dipind),APReptree.Y(dipind),APReptree.Z(dipind),'filled',colourr)


%% Analyse and compare old and new tree
% % branch order
% oldBO = BO_tree(FixTree);
% [oldsec oldvec] = dissect_tree(FixTree);
% PLoldBO = oldBO(oldsec(:,2));
% newBO = BO_tree(APReptree);
% [newsec newvec] = dissect_tree(APReptree);
% PLnewBO = newBO(newsec(:,2));
% limyC = max([max(histcounts(PLoldBO)),max(histcounts(PLnewBO))]);
% figure;
% subplot(2,1,1);
% histogram(PLoldBO);
% xlabel('Branch order');
% title('Cut Morphology')
% ylim([0 limyC]);
% xlim([0 max([max(PLoldBO),max(PLnewBO)])]);
% subplot(2,1,2);
% histogram(PLnewBO);
% xlabel('Branch order');
% title('Repaired Morphology')
% ylim([0 limyC]);
% xlim([0 max([max(PLoldBO),max(PLnewBO)])]);
% 
% % sholl analysis
% oldSholl = sholl_tree(FixTree);
% % oldSholl = oldSholl/max(oldSholl);
% oldx = 0:25:(length(oldSholl)-1)*25;
% newSholl = sholl_tree(APReptree);
% % newSholl = newSholl/max(newSholl);
% newx = 0:25:(length(newSholl)-1)*25;
% figure;
% subplot(2,1,1);
% plot(oldx,oldSholl);
% xlabel('Circle diameter [\mum]');
% ylabel('Sholl distribution');
% xlim([0 max([max(newx),max(oldx)])])
% ylim([0 max([max(oldSholl),max(newSholl)])])
% title('Cut Morphology')
% subplot(2,1,2);
% plot(newx,newSholl);
% xlabel('Circle diameter [\mum]');
% ylabel('Sholl distribution');
% xlim([0 max([max(newx),max(oldx)])])
% ylim([0 max([max(oldSholl),max(newSholl)])])
% title('Repaired Morphology')
% 
% 
% % number of branch points
% oldNBr = sum(B_tree(FixTree));
% newNBr = sum(B_tree(APReptree));
% Kats = categorical({'Cut','Repaired'});
% figure;
% bar(Kats,[oldNBr,newNBr],'r');
% ylabel('Nr. of Branch points');
% title('Total Nr. of Branch points');
% ylim([0 max([newNBr,oldNBr])+20]);
% 
% % tree volume
% [~,oldVol] = boundary(FixTree.X,FixTree.Y,FixTree.Z);
% [~,newVol] = boundary(APReptree.X,APReptree.Y,APReptree.Z);
% Kats = categorical({'Cut','Repaired'});
% figure;
% bar(Kats,[oldVol,newVol],'r');
% ylabel('Volume [\mum^3]');
% title('Total Volume of Neuron');
% ylim([0 max([oldVol,newVol])+100000]);
% 
% 
% % dend length
% newallind = 1:1:length(APReptree.R);
% newAp_So = find(APReptree.R == Apind || APReptree.R == Soind);
% newBa_So = find(APReptree.R == Baind || APReptree.R == Soind);
% newelim_BA = ~ismember(newallind,newAp_So);
% newelim_AP = ~ismember(newallind,newBa_So);
% newelim_BA = newallind(newelim_BA);
% newelim_AP = newallind(newelim_AP);
% newapical  = delete_tree(APReptree,newelim_BA);                
% newbasal   = delete_tree(APReptree,newelim_AP);
% 
% oldAPDlen = sum(len_tree(apical));
% oldBADlen = sum(len_tree(basal)); 
% newAPDlen = sum(len_tree(newapical));
% newBADlen = sum(len_tree(newbasal)); 
% Kats = categorical({'Apical','Basal'});
% figure;
% b = bar(Kats,[oldAPDlen,newAPDlen;oldBADlen,newBADlen]);
% ylabel('Dendritic length [\mum]');
% title('Total dendritic length');
% xtips1 = b(1).XEndPoints;
% ytips1 = b(1).YEndPoints;
% labels1 = 'Cut';
% text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
%     'VerticalAlignment','bottom')
% xtips2 = b(2).XEndPoints;
% ytips2 = b(2).YEndPoints;
% labels2 = 'Repaired';
% text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
%     'VerticalAlignment','bottom')
% ylim([0 max([oldAPDlen,oldBADlen,newAPDlen,newBADlen])+1000]);
% 
% % measures per section
% [sect1 vec1] = dissect_tree(FixTree);
% [sect2 vec2] = dissect_tree(APReptree);
% len1 = len_tree(FixTree);
% len2 = len_tree(APReptree);
% sect1RE = FixTree.R(sect1(:,2));
% sect2RE = APReptree.R(sect2(:,2));
% NRegions = length(FixTree.rnames);
% seglen1 = []; seglen2 = [];
% seg1meanDia = []; seg2meanDia = [];
% seglen1{NRegions} = []; seglen2{NRegions} = [];
% seg1meanDia{NRegions} = []; seg2meanDia{NRegions} = [];
% for nn = 1:length(sect1)
%     cursegnodes = find(vec1(:,1) == nn);
%     seglen1{sect1RE(nn)} = [seglen1{sect1RE(nn)},...
%                             sum(len1(cursegnodes))];
%     seg1meanDia{sect1RE(nn)} = [seg1meanDia{sect1RE(nn)},...
%                                 mean(FixTree.D(cursegnodes))];
% end
% for nn = 1:length(sect2)
%     cursegnodes = find(vec2(:,1) == nn);
%     seglen2{sect2RE(nn)} = [seglen2{sect2RE(nn)},...
%                             sum(len2(cursegnodes))];
%     seg2meanDia{sect2RE(nn)} = [seg2meanDia{sect2RE(nn)},...
%                                 mean(APReptree.D(cursegnodes))];
% end
% APmeanpersegLen1 = mean(seglen1{Apind});
% APmeanpersegLen2 = mean(seglen2{Apind});
% BAmeanpersegLen1 = mean(seglen1{Baind});
% BAmeanpersegLen2 = mean(seglen2{Baind});
% SOmeanpersegLen1 = mean(seglen1{Soind});
% SOmeanpersegLen2 = mean(seglen2{Soind});
% Kats = categorical({'Apical','Basal','Soma'});
% figure;
% b = bar(Kats,[APmeanpersegLen1,APmeanpersegLen2;...
%               BAmeanpersegLen1,BAmeanpersegLen2;...
%               SOmeanpersegLen1,SOmeanpersegLen2]);
% ylabel('Dendritic length [\mum]');
% title('Dendritic length per Segment');
% xtips1 = b(1).XEndPoints;
% ytips1 = b(1).YEndPoints;
% labels1 = 'Cut';
% text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
%     'VerticalAlignment','bottom')
% xtips2 = b(2).XEndPoints;
% ytips2 = b(2).YEndPoints;
% labels2 = 'Repaired';
% text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
%     'VerticalAlignment','bottom')
% ylim([0 max([APmeanpersegLen1,APmeanpersegLen2,...
%      BAmeanpersegLen1,BAmeanpersegLen2,SOmeanpersegLen1,SOmeanpersegLen2])+15]);
% APmeanpersegDia1 = mean(seg1meanDia{Apind});
% APmeanpersegDia2 = mean(seg2meanDia{Apind});
% BAmeanpersegDia1 = mean(seg1meanDia{Baind});
% BAmeanpersegDia2 = mean(seg2meanDia{Baind});
% SOmeanpersegDia1 = mean(seg1meanDia{Soind});
% SOmeanpersegDia2 = mean(seg2meanDia{Soind});
% Kats = categorical({'Apical','Basal','Soma'});
% figure;
% b = bar(Kats,[APmeanpersegDia1,APmeanpersegDia2;...
%               BAmeanpersegDia1,BAmeanpersegDia2;...
%               SOmeanpersegDia1,SOmeanpersegDia2]);
% ylabel('Diameter [\mum]');
% title('Diameter per Segment');
% xtips1 = b(1).XEndPoints;
% ytips1 = b(1).YEndPoints;
% labels1 = 'Cut';
% text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
%     'VerticalAlignment','bottom')
% xtips2 = b(2).XEndPoints;
% ytips2 = b(2).YEndPoints;
% labels2 = 'Repaired';
% text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
%     'VerticalAlignment','bottom')
% ylim([0 max([APmeanpersegDia1,APmeanpersegDia2,...
%      BAmeanpersegDia1,BAmeanpersegDia2,SOmeanpersegDia1,SOmeanpersegDia2])+1]);
% 
% % Diameter with respect to pathlength from root
% Lroot_perN1 = Pvec_tree(FixTree);
% Lroot_perN2 = Pvec_tree(APReptree);
% Lroot_perN3 = Pvec_tree(referencetree);
% figure;
% subplot(2,1,1);
% scatter(Lroot_perN1,FixTree.D,'filled','k');
% xlabel('Path length from Root [\mum]');
% ylabel('Diameter [\mum]');
% title('Cut Morphology');
% subplot(2,1,2);
% scatter(Lroot_perN2,APReptree.D,'filled','k');
% xlabel('Path length from Root [\mum]');
% ylabel('Diameter [\mum]');
% title('Repaired Morphology');
% 
% % measures per branchorder
% segBO1{NRegions} = []; segBO2{NRegions} = [];
% BOs1{NRegions} = []; BOs2{NRegions} = [];
% PerBOmeanlen1{NRegions} = []; PerBOmeanlen2{NRegions} = [];
% PerBOmeanDia1{NRegions} = []; PerBOmeanDia2{NRegions} = []; 
% 
% for nn = 1:length(sect1)
%     cursegnodes = find(vec1(:,1) == nn);
%     segBO1{sect1RE(nn)} = [segBO1{sect1RE(nn)},...
%                            oldBO(cursegnodes(1))];
% end
% for nn = 1:length(sect2)
%     cursegnodes = find(vec2(:,1) == nn);
%     segBO2{sect2RE(nn)} = [segBO2{sect2RE(nn)},...
%                            newBO(cursegnodes(1))];
% end
% 
% for nn = 1:length(segBO1)
%     BOs1{nn} = unique(segBO1{nn});
%     for tt = 1:length(BOs1{nn})
%         currBO = find(segBO1{nn} == BOs1{nn}(tt));
%         PerBOmeanlen1{nn} = [PerBOmeanlen1{nn},...
%                              mean(seglen1{nn}(currBO))];
%         PerBOmeanDia1{nn} = [PerBOmeanDia1{nn},...
%                              mean(seg1meanDia{nn}(currBO))];
%     end
%     BOs2{nn} = unique(segBO2{nn});
%     for tt = 1:length(BOs2{nn})
%         currBO = find(segBO2{nn} == BOs2{nn}(tt));
%         PerBOmeanlen2{nn} = [PerBOmeanlen2{nn},...
%                              mean(seglen2{nn}(currBO))];
%         PerBOmeanDia2{nn} = [PerBOmeanDia2{nn},...
%                              mean(seg2meanDia{nn}(currBO))];
%     end
% end
% 
% limYax = max([PerBOmeanlen1{1},PerBOmeanlen1{3},...
%               PerBOmeanlen2{1},PerBOmeanlen2{3}])+10;
% limXaxAP = max([length(PerBOmeanlen1{1}),length(PerBOmeanlen2{1})]);
% limXaxBA = max([length(PerBOmeanlen1{3}),length(PerBOmeanlen2{3})]);
% figure;
% subplot(2,2,1);
% b = bar(PerBOmeanlen1{1},'k');
% xlabel('Apical');
% ylabel('Length [\mum]');
% xlim([0 limXaxAP+1]);
% ylim([0 limYax]);
% title('Cut Tree')
% subplot(2,2,2);
% b = bar(PerBOmeanlen1{3},'r');
% xlabel('Basal');
% ylabel('Length [\mum]');
% xlim([0 limXaxBA+1]);
% ylim([0 limYax]);
% title('Cut Tree')
% subplot(2,2,3);
% b = bar(PerBOmeanlen2{1},'k');
% xlabel('Apical');
% ylabel('Length [\mum]');
% xlim([0 limXaxAP+1]);
% ylim([0 limYax]);
% title('Repaired Tree')
% subplot(2,2,4);
% b = bar(PerBOmeanlen2{3},'r');
% xlabel('Basal');
% ylabel('Length [\mum]');
% xlim([0 limXaxBA+1]);
% ylim([0 limYax]);
% title('Repaired Tree')
% 
% limYax = max([PerBOmeanDia1{1},PerBOmeanDia1{3},...
%               PerBOmeanDia2{1},PerBOmeanDia2{3}])+0.5;
% limXaxAP = max([length(PerBOmeanDia1{1}),length(PerBOmeanDia2{1})]);
% limXaxBA = max([length(PerBOmeanDia1{3}),length(PerBOmeanDia2{3})]);
% 
% figure;
% subplot(2,2,1);
% b = bar(PerBOmeanDia1{1},'k');
% xlabel('Apical');
% ylabel('Diameter [\mum]');
% xlim([0 limXaxAP+1]);
% ylim([0 limYax]);
% title('Cut Tree')
% subplot(2,2,2);
% b = bar(PerBOmeanDia1{3},'r');
% xlabel('Basal');
% ylabel('Diameter [\mum]');
% xlim([0 limXaxBA+1]);
% ylim([0 limYax]);
% title('Cut Tree')
% subplot(2,2,3);
% b = bar(PerBOmeanDia2{1},'k');
% xlabel('Apical');
% ylabel('Diameter [\mum]');
% xlim([0 limXaxAP+1]);
% ylim([0 limYax]);
% title('Repaired Tree')
% subplot(2,2,4);
% b = bar(PerBOmeanDia2{3},'r');
% xlabel('Basal');
% ylabel('Diameter [\mum]');
% xlim([0 limXaxBA+1]);
% ylim([0 limYax]);
% title('Repaired Tree')
% 
% % rootangle distribution
% oldRootA = rootangle_tree(FixTree);
% newRootA = rootangle_tree(APReptree);
% 
% AngV     = linspace   (0, pi, 25);
% oldpdf      = histcounts (oldRootA, AngV);
% newpdf      = histcounts (newRootA, AngV);
% mAngV    = (AngV (2 : 25) + AngV (1 : 24)) / 2; % Get midpoints
% oldRootA = oldpdf / trapz (mAngV, oldpdf);
% newRootA = newpdf / trapz (mAngV, newpdf);
% maxAngR = max([oldRootA,newRootA]);
% figure;
% subplot(2,1,1);
% plot     (mAngV, oldRootA, 'black')
% xlim     ([0 pi]);
% ylim     ([0 maxAngR]);
% xlabel   ('Angle');
% ylabel   ('Density');
% title('Cut Tree')
% subplot(2,1,2);
% plot     (mAngV, newRootA, 'black')
% xlim     ([0 pi]);
% ylim     ([0 maxAngR]);
% xlabel   ('Angle');
% ylabel   ('Density');
% title('Repaired Tree')
%% Plot tree statistics
if regionsOK == 1
    statisticsplot(FixTree,APReptree,handles.referencetree,Soind,Apind,Baind,apical,basal);
else
    statisticsplot(FixTree,APReptree,handles.referencetree,[],[],[],[],[]);
end
    
if ~isfield(handles.tree,'name')
    handles.tree.name = 'MorphoReconstructed';
else
    handles.tree.name = strrep(handles.tree.name,...
                               ' ',...
                               '_');
    handles.tree.name = strrep(handles.tree.name,...
                               ',',...
                               '__');
end
% save tree
if ~isfield(APReptree,'IncompleteTerminals')
else
    APReptree = rmfield(APReptree,'IncompleteTerminals');
end
APReptree.name = handles.tree.name;
tree = APReptree;
save(strcat("REP_",handles.tree.name,'.mtr'),'tree');
clear vars tree;
% save params
fileId = fopen('params.txt','w');
formatSpec1 = 'bf = %12.8f\noffset taper = %12.8f\nscale taper = %12.8f\n';
formatSpec2 = 'thresh taper = %12.8f\nprune length = %12.8f\ngrowth thresh = %12.8f\nNr. Pts = %12.8f';
formatSpec = strcat(formatSpec1,formatSpec2);
fprintf(fileId,formatSpec,bfapical,colapictaper_offset,colapictaper_scale,...
        taperthreshold,prunlen,growThr,selectNPts);
fclose(fileId);
% save volume
VolumeIndices = IndVolBou;
VolumePoints = handles.VolPerim;
save('VolPts.mat','VolumeIndices','VolumePoints');
  
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in Dips_Vol.
function Dips_Vol_Callback(hObject, eventdata, handles)
% hObject    handle to Dips_Vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'nPtsPerSelec') 
    error('please select points for the dendrite volume');
elseif iscell(handles.nPtsPerSelec)
    if isempty(handles.nPtsPerSelec{1})
%         error('please select points for the dendrite volume');
    end            
end
cla;

for volct = 1:length(handles.xChosen)
    if isempty(handles.nPtsPerSelec{volct}) || length(handles.nPtsPerSelec{volct}) == 1
        disp(strcat("Please select more points for Volume ",num2str(volct)));
    else
        VolPerim = [];
        startind = 1;
        stopind  = handles.nPtsPerSelec{volct}(1);
        for ctr = 1:length(handles.nPtsPerSelec{volct})
            planeInd = handles.PtsPlaneind{volct}(ctr); 
            tempxC = handles.xChosen{volct}(startind:stopind);
            tempyC = handles.yChosen{volct}(startind:stopind);
            switch planeInd
                case 1
                    fillC = zeros(handles.nPtsPerSelec{volct}(ctr),1);
                    VolPerim = [VolPerim;tempxC,tempyC,fillC];
                case 2
                    fillC = zeros(handles.nPtsPerSelec{volct}(ctr),1);
                    VolPerim = [VolPerim;tempxC,fillC,tempyC];
                case 3
                    fillC = zeros(handles.nPtsPerSelec{volct}(ctr),1);
                    VolPerim = [VolPerim;fillC,tempxC,tempyC];
            end        
            startind    = stopind+1;
            if ctr == length(handles.nPtsPerSelec{volct})
                break;
            else
                stopind = stopind+handles.nPtsPerSelec{volct}(ctr+1);
            end
        end
        meanx = mean(VolPerim(find(VolPerim(:,1) ~= 0),1));
        meany = mean(VolPerim(find(VolPerim(:,2) ~= 0),2));
        meanz = mean(VolPerim(find(VolPerim(:,3) ~= 0),3));
        VolPerim(find(VolPerim(:,1) == 0),1) = meanx;
        VolPerim(find(VolPerim(:,2) == 0),2) = meany;
        VolPerim(find(VolPerim(:,3) == 0),3) = meanz;

        VolBound = boundary(VolPerim,handles.boundAlpha);
        if volct == 1   
            cla
        end
        plot_tree(handles.tree);
        xlim auto
        ylim auto
        xlabel('x');
        ylabel('y');
        zlabel('z');
        hold on;
        trisurf(VolBound,...
                VolPerim(:,1),...
                VolPerim(:,2),...
                VolPerim(:,3),'Facecolor','red','FaceAlpha',0.1);
        handles.VolPerim{volct} = VolPerim;
    end
end
handles.planeind = 1;
if ~isempty(handles.Imstack)
    plot_tree(handles.tree);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla
plot_tree(handles.tree);
xlim(handles.xPlL)
ylim(handles.yPlL)
xlabel('x');
ylabel('y');
zlabel('z');
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);
if isfield(handles,'nPtsPerSelec')
    fields = {'nPtsPerSelec','PtsPlaneind','xChosen','yChosen',...
              'zChosen'};
    handles = rmfield(handles,fields);
end
if isfield(handles,'VolPerim')
    fields = {'VolPerim'};
    handles = rmfield(handles,fields);
end
if isfield(handles,'RepTree')
    fields = {'RepTree'};
    handles = rmfield(handles,fields);
end
if isfield(handles,'NPts_User')
    fields = {'NPts_User'};
    handles = rmfield(handles,fields);
end
handles.nPtsPerSelec{1} = [];
handles.PtsPlaneind{1} = [];
handles.xChosen{1} = [];
handles.yChosen{1} = [];
handles.zChosen{1} = [];
handles.VolPerim{1} = [];
% handles.RepTree{1} = [];
handles.NVolumes = 1;
handles.planeind = 1;
handles.boundAlpha = 0;
if isfield(handles,'maxDendLen_User')
    handles = rmfield(handles,'maxDendLen_User');
end
if isfield(handles,'maxNrBranchPts_User')
    handles = rmfield(handles,'maxNrBranchPts_User');
end
set(handles.maxDendLength,'String','Max. Dend. Length');
set(handles.maxNrBranchPts,'String','Max. Nr. Branch Pts.');
CurVolStr = strcat("Vol. ",num2str(handles.NVolumes));
set(handles.disp_curr_Vol_index, 'String', CurVolStr);
set(handles.Enter_Nr_Carrier_Points,'String','Nr. Points');
set(handles.boundary_alpha,'String','Boundary Alpha');
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in NewVolStart.
function NewVolStart_Callback(hObject, eventdata, handles)
% hObject    handle to NewVolStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'NVolumes')
    handles.NVolumes = 1;
end
if ~isfield(handles,'PtsPlaneind')
    handles.PtsPlaneind{1} = [];
end
if ~isfield(handles,'xChosen')
    error('You have not chosen any points for the first volume yet');
end
if handles.NVolumes < length(handles.xChosen)
    disp(strcat("Please use +1 Vol. button to go to Vol. ",num2str(length(handles.xChosen))));
    disp("Then press Start New Vol. again to start a new volume");
elseif length(unique(handles.PtsPlaneind{handles.NVolumes})) <= 1
    disp('Please select Points in at least two different planes');
else
    if isempty(handles.NVolumes)
        handles.NVolumes = 1;
    else
        handles.NVolumes = handles.NVolumes+1;
    end

    handles.nPtsPerSelec{handles.NVolumes} = [];
    handles.PtsPlaneind{handles.NVolumes} = [];
    handles.xChosen{handles.NVolumes} = [];
    handles.yChosen{handles.NVolumes} = [];
    handles.zChosen{handles.NVolumes} = [];
    handles.planeind = 1;
    cla
    plot_tree(handles.tree);
    xlim(handles.xPlL)
    ylim(handles.yPlL)
    xlabel('x');
    ylabel('y');
    zlabel('z');
    
    if ~isempty(handles.Imstack)
        HaStack = show_stack(handles.Imstack);
        StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
        StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
        XlimMax = max([StMaxX,max(handles.tree.X)]);
        XlimMin = min([0,min(handles.tree.X)]);
        YlimMax = max([StMaxY,max(handles.tree.Y)]);
        YlimMin = min([0,min(handles.tree.Y)]);
        if logical(get(handles.transperent_toggle,'Value'))
            set (HaStack, 'facealpha', 0.5);
        else
            set (HaStack, 'facealpha', 1);
        end
    else
        XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
        YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
    end
    
    xlim([XlimMin XlimMax]);
    ylim([YlimMin YlimMax]);

    CurVolStr = strcat("Vol. ",num2str(handles.NVolumes));
    set(handles.disp_curr_Vol_index, 'String', CurVolStr);
    set(handles.Enter_Nr_Carrier_Points,'String','Nr. Points');
end
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in Disp_Rep_tree.
function Disp_Rep_tree_Callback(hObject, eventdata, handles)
% hObject    handle to Disp_Rep_tree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'RepTree')
    cla
    plot_tree(handles.RepTree{end},[1 0 0]);
    plot_tree(resample_tree(handles.tree,handles.treeParams.resample_rate));
    xlim(handles.xPlL)
    ylim(handles.yPlL)
    xlabel('x');
    ylabel('y');
    zlabel('z');
    handles.planeind = 1;
    if ~isempty(handles.Imstack)
        HaStack = show_stack(handles.Imstack);
        StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
        StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
        XlimMax = max([StMaxX,max(handles.RepTree{1}.X)]);
        XlimMin = min([0,min(handles.RepTree{1}.X)]);
        YlimMax = max([StMaxY,max(handles.RepTree{1}.Y)]);
        YlimMin = min([0,min(handles.RepTree{1}.Y)]);
        if logical(get(handles.transperent_toggle,'Value'))
            set (HaStack, 'facealpha', 0.5);
        else
            set (HaStack, 'facealpha', 1);
        end
    else
        XlimMax = max(handles.RepTree{1}.X); XlimMin = min(handles.RepTree{1}.X);
        YlimMax = max(handles.RepTree{1}.Y); YlimMin = min(handles.RepTree{1}.Y);
    end
    
    xlim([XlimMin XlimMax]);
    ylim([YlimMin YlimMax]);
else
    disp('There is no Repaired Tree yet');
end
handles.output = hObject;
guidata(hObject, handles);



% next two functions handle entries for number of carrier points
function Enter_Nr_Carrier_Points_Callback(hObject, eventdata, handles)
% hObject    handle to Enter_Nr_Carrier_Points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.Enter_Nr_Carrier_Points,'String')))
    disp('Please enter a numerical number');
else
    handles.NPts_User{handles.NVolumes} = floor(str2double(get(handles.Enter_Nr_Carrier_Points,'String')));
    disp(strcat("Nr. of Points for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.NPts_User{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of Enter_Nr_Carrier_Points as text
%        str2double(get(hObject,'String')) returns contents of Enter_Nr_Carrier_Points as a double


% --- Executes during object creation, after setting all properties.
function Enter_Nr_Carrier_Points_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Enter_Nr_Carrier_Points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in previous_Vol.
function previous_Vol_Callback(hObject, eventdata, handles)
% hObject    handle to previous_Vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.NVolumes == 1
    disp("You are currently editing volume Nr. 1");
else
    handles.NVolumes = handles.NVolumes-1; 
end
CurVolStr = strcat("Vol. ",num2str(handles.NVolumes));
set(handles.disp_curr_Vol_index, 'String', CurVolStr);
set(handles.Enter_Nr_Carrier_Points,'String','Nr. Points');
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in next_Volume.
function next_Volume_Callback(hObject, eventdata, handles)
% hObject    handle to next_Volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.NVolumes == length(handles.xChosen)
    disp("You are currently editing the last volume specified.");
    disp("If you want to add more volumes click the Start New Vol. button");
else
    handles.NVolumes = handles.NVolumes+1;
end

CurVolStr = strcat("Vol. ",num2str(handles.NVolumes));
set(handles.disp_curr_Vol_index, 'String', CurVolStr);
set(handles.Enter_Nr_Carrier_Points,'String','Nr. Points');
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in reset_current_Vol.
function reset_current_Vol_Callback(hObject, eventdata, handles)
% hObject    handle to reset_current_Vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(strcat("Volume Nr. ",num2str(handles.NVolumes)," has been reset"));
handles.nPtsPerSelec{handles.NVolumes} = [];
handles.PtsPlaneind{handles.NVolumes} = [];
handles.xChosen{handles.NVolumes} = [];
handles.yChosen{handles.NVolumes} = [];
handles.zChosen{handles.NVolumes} = [];
handles.planeind = 1;
cla
plot_tree(handles.tree);
xlabel('x');
ylabel('y');
zlabel('z');
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);

set(handles.Enter_Nr_Carrier_Points,'String','Nr. Points');
handles.output = hObject;
guidata(hObject, handles);



function boundary_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to boundary_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.boundary_alpha,'String')))
    disp('Please enter a numerical number');
elseif str2double(get(handles.boundary_alpha,'String')) < 0 || str2double(get(handles.boundary_alpha,'String')) > 1
    disp('Please enter a numerical number between or equal to 0 and 1');
else
    handles.boundAlpha = str2double(get(handles.boundary_alpha,'String'));
    disp(strcat("Alpha for the boundary function was set to ",num2str(handles.boundAlpha)));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of boundary_alpha as text
%        str2double(get(hObject,'String')) returns contents of boundary_alpha as a double


% --- Executes during object creation, after setting all properties.
function boundary_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boundary_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function grwoth_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to grwoth_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.grwoth_thresh,'String')))
    disp('Please enter a numerical number');
else
    handles.MST_growthThr{handles.NVolumes} = str2double(get(handles.grwoth_thresh,'String'));
    disp(strcat("Growth threshold for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.MST_growthThr{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of grwoth_thresh as text
%        str2double(get(hObject,'String')) returns contents of grwoth_thresh as a double


% --- Executes during object creation, after setting all properties.
function grwoth_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grwoth_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function prune_len_Callback(hObject, eventdata, handles)
% hObject    handle to prune_len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.prune_len,'String')))
    disp('Please enter a numerical number');
else
    handles.MST_prunelen{handles.NVolumes} = str2double(get(handles.prune_len,'String'));
    disp(strcat("Prune length for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.MST_prunelen{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of prune_len as text
%        str2double(get(hObject,'String')) returns contents of prune_len as a double


% --- Executes during object creation, after setting all properties.
function prune_len_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prune_len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
movegui('northwest');


% --- Executes on button press in cut_growth_enable.
function cut_growth_enable_Callback(hObject, eventdata, handles)
% hObject    handle to cut_growth_enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cut_growth_enable



function scale_taper_Callback(hObject, eventdata, handles)
% hObject    handle to scale_taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.scale_taper,'String')))
    disp('Please enter a numerical number');
else
    handles.scale_taperpar{handles.NVolumes} = str2double(get(handles.scale_taper,'String'));
    disp(strcat("Taper scale for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.scale_taperpar{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of scale_taper as text
%        str2double(get(hObject,'String')) returns contents of scale_taper as a double


% --- Executes during object creation, after setting all properties.
function scale_taper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function offset_taper_Callback(hObject, eventdata, handles)
% hObject    handle to offset_taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.offset_taper,'String')))
    disp('Please enter a numerical number');
else
    handles.offset_taperpar{handles.NVolumes} = str2double(get(handles.offset_taper,'String'));
    disp(strcat("Taper offset for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.offset_taperpar{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of offset_taper as text
%        str2double(get(hObject,'String')) returns contents of offset_taper as a double


% --- Executes during object creation, after setting all properties.
function offset_taper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offset_taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function threshold_taper_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.threshold_taper,'String')))
    disp('Please enter a numerical number');
else
    handles.thresh_taperpar{handles.NVolumes} = str2double(get(handles.threshold_taper,'String'));
    disp(strcat("Taper threshold for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.thresh_taperpar{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of threshold_taper as text
%        str2double(get(hObject,'String')) returns contents of threshold_taper as a double


% --- Executes during object creation, after setting all properties.
function threshold_taper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_ImStack.
function load_ImStack_Callback(hObject, eventdata, handles)
% hObject    handle to load_ImStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% cla
% plot_tree(handles.referencetree,[1 0 0]);
% plot_tree(handles.tree);
% xlabel('x');
% ylabel('y');
% zlabel('z');
% % view(0,90)
% handles.planeind = 1;
if logical(get(handles.Im_2D_switch,'Value'))
    disp("2D Image is enabled");
else
    disp("3D Image is enabled");
end
Im2Denabled = logical(get(handles.Im_2D_switch,'Value'));
if Im2Denabled
    stack = imload_stack();
    % flip image the right way around
    tempStM = stack.M{1, 1};
    for cttr1 = 1:size(tempStM,3)
        for cttr2 = 1:size(tempStM,2)
            tempStM(:,cttr2,cttr1) = flip(tempStM(:,cttr2,cttr1));
        end
    end
    stack.M{1, 1} = tempStM;
else  
    stack = loadtifs_stack();
end
% stack.voxel = [0.33,0.33,0.33];
handles.Imstack = stack;
cla
plot_tree(handles.referencetree,[1 0 0]);
plot_tree(handles.tree);
xlabel('x');
ylabel('y');
zlabel('z');
% view(0,90)
handles.planeind = 1;
HaStack = show_stack(handles.Imstack);
xlim auto
ylim auto
handles.stackMxz = [];
handles.stackMyz = [];
StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
XlimMax = max([StMaxX,max(handles.tree.X)]);
XlimMin = min([0,min(handles.tree.X)]);
YlimMax = max([StMaxY,max(handles.tree.Y)]);
YlimMin = min([0,min(handles.tree.Y)]);
xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);
% handles.xPlL = xlim; handles.yPlL = ylim; handles.zPlL = zlim;
if logical(get(handles.transperent_toggle,'Value'))
    set (HaStack, 'facealpha', 0.5);
else
    set (HaStack, 'facealpha', 1);
end
greenmap = interp1([0;1],[0 0 0;0 1 0],linspace(0,1,256));
colormap(greenmap);
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in shift_neuron.
function shift_neuron_Callback(hObject, eventdata, handles)
% hObject    handle to shift_neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% % cla
% % plot_tree(handles.referencetree,[1 0 0]);
% % plot_tree(handles.tree);
% % xlabel('x');
% % ylabel('y');
% % zlabel('z');
view(0,90)
% xlim auto
% ylim auto
% xlim(handles.xPlL)
% ylim(handles.yPlL)
if isfield(handles.tree,'IncompleteTerminals')
    InComI = [];
    for ff = 1:length(handles.tree.IncompleteTerminals(:,1))
        tempINCOMP = find(handles.tree.X == handles.tree.IncompleteTerminals(ff,1) &...
                          handles.tree.Y == handles.tree.IncompleteTerminals(ff,2) &...
                          handles.tree.Z == handles.tree.IncompleteTerminals(ff,3));
        InComI = [InComI,tempINCOMP];
    end
end
% view(0,90)
handles.planeind = 1;
if ~isempty(handles.Imstack)
% %     HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end
% xlim([XlimMin XlimMax]);
% ylim([YlimMin YlimMax]);

disp('please select the point where the Soma of the neuron should move to');
[x,y,z] = ginput_plot(1);
z = 0;
if isempty(handles.newrootCoord)
    handles.newrootCoord = [x,y,z];
else
    handles.newrootCoord = [x,y,handles.newrootCoord(3)];
end
x = x-handles.tree.X(1);
y = y-handles.tree.Y(1);
handles.tree.X = x+handles.tree.X;
handles.tree.Y = y+handles.tree.Y;
handles.referencetree.X = x+handles.referencetree.X;
handles.referencetree.Y = y+handles.referencetree.Y;
cla
plot_tree(handles.referencetree,[1 0 0]);
plot_tree(handles.tree);
xlabel('x');
ylabel('y');
zlabel('z');
% view(0,90)
handles.planeind = 1;
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

% xlim([XlimMin XlimMax]);
% ylim([YlimMin YlimMax]);
% handles.xPlL = xlim; handles.yPlL = ylim; handles.zPlL = zlim;

if isfield(handles.tree,'IncompleteTerminals')
    handles.tree.IncompleteTerminals(:,1) = handles.tree.X(InComI);
    handles.tree.IncompleteTerminals(:,2) = handles.tree.Y(InComI);
    handles.tree.IncompleteTerminals(:,3) = handles.tree.Z(InComI);
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in rotate_neuron.
function rotate_neuron_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% % cla
% % plot_tree(handles.referencetree,[1 0 0]);
% % plot_tree(handles.tree);
% % xlabel('x');
% % ylabel('y');
% % zlabel('z');
view(0,90)
handles.planeind = 1;
if ~isempty(handles.Imstack)
% %     HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end
% xlim([XlimMin XlimMax]);
% ylim([YlimMin YlimMax]);

if isfield(handles.tree,'IncompleteTerminals')
    InComI = [];
    for ff = 1:length(handles.tree.IncompleteTerminals(:,1))
        tempINCOMP = find(handles.tree.X == handles.tree.IncompleteTerminals(ff,1) &...
                          handles.tree.Y == handles.tree.IncompleteTerminals(ff,2) &...
                          handles.tree.Z == handles.tree.IncompleteTerminals(ff,3));
        InComI = [InComI,tempINCOMP];
    end
end

disp('please select a point on the outer dendrites of the neuron');
[x1,y1,z1] = ginput_plot(1);
z1 = 0;
disp('please select a point to where you want the point on the dendrite to rotate');
[x2,y2,z2] = ginput_plot(1);
z2 = 0;
vec1 = [x1-handles.tree.X(1),y1-handles.tree.Y(1),0];
vec2 = [x2-handles.tree.X(1),y2-handles.tree.Y(1),0];
deg_azimuth = atan2d(vec1(1)*vec2(2)-vec1(2)*vec2(1),vec1(1)*vec2(1)+vec1(2)*vec2(2));
% deg_azimuth = acos((sum(vec1.*vec2))/(norm(vec1)*norm(vec2)));
% deg_azimuth = deg_azimuth*(180/pi);
xRo = handles.tree.X(1);
yRo = handles.tree.Y(1);
zRo = handles.tree.Z(1);
handles.tree = tran_tree(handles.tree);
handles.tree = rot_tree(handles.tree,[0 0 -deg_azimuth]);
handles.tree.X = xRo+handles.tree.X;
handles.tree.Y = yRo+handles.tree.Y;
handles.tree.Z = zRo+handles.tree.Z;
% handles.tree = tran_tree(handles.tree,[xRo yRo zRo]);
handles.referencetree = tran_tree(handles.referencetree);
handles.referencetree = rot_tree(handles.referencetree,[0 0 -deg_azimuth]);
handles.referencetree.X = xRo+handles.referencetree.X;
handles.referencetree.Y = yRo+handles.referencetree.Y;
handles.referencetree.Z = zRo+handles.referencetree.Z;
% handles.referencetree = tran_tree(handles.referencetree,[xRo yRo zRo]);
cla
plot_tree(handles.referencetree,[1 0 0]);
plot_tree(handles.tree);
xlabel('x');
ylabel('y');
zlabel('z');
% view(0,90)
handles.planeind = 1;
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

% xlim([XlimMin XlimMax]);
% ylim([YlimMin YlimMax]);
% handles.xPlL = xlim; handles.yPlL = ylim; handles.zPlL = zlim;

if isfield(handles.tree,'IncompleteTerminals')
    handles.tree.IncompleteTerminals(:,1) = handles.tree.X(InComI);
    handles.tree.IncompleteTerminals(:,2) = handles.tree.Y(InComI);
    handles.tree.IncompleteTerminals(:,3) = handles.tree.Z(InComI);
end

handles.xPlL = xlim; handles.yPlL = ylim; handles.zPlL = zlim;
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in shiftneuron_yz.
function shiftneuron_yz_Callback(hObject, eventdata, handles)
% hObject    handle to shiftneuron_yz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[outtree] = swaptreeaxis(handles.tree,'yz');
[outtree2] = swaptreeaxis(handles.referencetree,'yz');
cla
plot_tree(outtree2,[1 0 0]);
plot_tree(outtree); 
limx = max([max(outtree.X),abs(min(outtree.X))])+20;
limy = max([max(outtree.Y),abs(min(outtree.Y))])+20;
xlabel('y');
ylabel('z');
zlabel('x');
if isfield(handles.tree,'IncompleteTerminals')
    InComI = [];
    for ff = 1:length(handles.tree.IncompleteTerminals(:,1))
        tempINCOMP = find(handles.tree.X == handles.tree.IncompleteTerminals(ff,1) &...
                          handles.tree.Y == handles.tree.IncompleteTerminals(ff,2) &...
                          handles.tree.Z == handles.tree.IncompleteTerminals(ff,3));
        InComI = [InComI,tempINCOMP];
    end
end
% view(0,90)
handles.planeind = 3;
if ~isempty(handles.Imstack)
    if isempty(handles.stackMyz)
        tempstack = handles.Imstack.M{1};
        newstack = handles.Imstack;
        newstack.M{1} = permute(tempstack,[3 1 2]);
        newstack.voxel(1) = handles.Imstack.voxel(2);
        newstack.voxel(2) = handles.Imstack.voxel(3);
        newstack.voxel(3) = handles.Imstack.voxel(1);
        HaStack = show_stack(newstack);
        handles.stackMyz = newstack.M{1};
    else
        newstack = handles.Imstack;
        newstack.M{1} = handles.stackMyz;
        newstack.voxel(1) = handles.Imstack.voxel(2);
        newstack.voxel(2) = handles.Imstack.voxel(3);
        newstack.voxel(3) = handles.Imstack.voxel(1);
        HaStack = show_stack(newstack);
    end
    StMaxX = size(newstack.M{1},2)*newstack.voxel(1);
    StMaxY = size(newstack.M{1},1)*newstack.voxel(2);
    XlimMax = max([StMaxX,max(outtree.X)]);
    XlimMin = min([0,min(outtree.X)]);
    YlimMax = max([StMaxY,max(outtree.Y)]);
    YlimMin = min([0,min(outtree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(outtree.X); XlimMin = min(outtree.X);
    YlimMax = max(outtree.Y); YlimMin = min(outtree.Y);
end

ylim([-50+YlimMin YlimMax+50]);
xlim([XlimMin XlimMax]);
% ylim([YlimMin YlimMax]);

disp('please select the point where the Soma of the neuron should move to');
[x,y,z] = ginput_plot(1);
z = 0;
x = 0;
if isempty(handles.newrootCoord)
    handles.newrootCoord = [z,x,y];
else  
    handles.newrootCoord = [handles.newrootCoord(1),...
                            handles.newrootCoord(2),y];
end
% x = x-handles.tree.Y(1);
y = y-handles.tree.Z(1);
% handles.tree.Y = x+handles.tree.Y;
handles.tree.Z = y+handles.tree.Z;
% handles.referencetree.Y = x+handles.referencetree.Y;
handles.referencetree.Z = y+handles.referencetree.Z;
cla
[outtree] = swaptreeaxis(handles.tree,'yz');
[outtree2] = swaptreeaxis(handles.referencetree,'yz');
plot_tree(outtree2,[1 0 0]);
plot_tree(outtree);
xlabel('y');
ylabel('z');
zlabel('x');
% view(0,90)
handles.planeind = 3;
if ~isempty(handles.Imstack)
    HaStack = show_stack(newstack);
    StMaxX = size(newstack.M{1},2)*newstack.voxel(1);
    StMaxY = size(newstack.M{1},1)*newstack.voxel(2);
    XlimMax = max([StMaxX,max(outtree.X)]);
    XlimMin = min([0,min(outtree.X)]);
    YlimMax = max([StMaxY,max(outtree.Y)]);
    YlimMin = min([0,min(outtree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(outtree.X); XlimMin = min(outtree.X);
    YlimMax = max(outtree.Y); YlimMin = min(outtree.Y);
end

% xlim([XlimMin XlimMax]);
% ylim([YlimMin YlimMax]);

% handles.xPlL = xlim; handles.yPlL = ylim; handles.zPlL = zlim;

if isfield(handles.tree,'IncompleteTerminals')
    handles.tree.IncompleteTerminals(:,1) = handles.tree.X(InComI);
    handles.tree.IncompleteTerminals(:,2) = handles.tree.Y(InComI);
    handles.tree.IncompleteTerminals(:,3) = handles.tree.Z(InComI);
end

handles.output = hObject;
guidata(hObject, handles);



function x_voxel_size_Callback(hObject, eventdata, handles)
% hObject    handle to x_voxel_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.Imstack)
    disp('You have not loaded an image stack yet therefore voxel size cannot be adjusted!!');
else
    if isnan(str2double(get(handles.x_voxel_size,'String')))
        disp('Please enter a numerical number');
    else
        handles.Imstack.voxel(1) = str2double(get(handles.x_voxel_size,'String'));
        disp(strcat("X voxel size was set to ",num2str(handles.Imstack.voxel(1))));
        cla
        plot_tree(handles.referencetree,[1 0 0]);
        plot_tree(handles.tree);
        xlabel('x');
        ylabel('y');
        zlabel('z');
        % view(0,90)
        handles.planeind = 1;
        HaStack = show_stack(handles.Imstack);
        StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
        StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
        XlimMax = max([StMaxX,max(handles.tree.X)]);
        XlimMin = min([0,min(handles.tree.X)]);
        YlimMax = max([StMaxY,max(handles.tree.Y)]);
        YlimMin = min([0,min(handles.tree.Y)]);
        xlim([XlimMin XlimMax]);
        ylim([YlimMin YlimMax]);
        if logical(get(handles.transperent_toggle,'Value'))
            set (HaStack, 'facealpha', 0.5);
        else
            set (HaStack, 'facealpha', 1);
        end
    end
end

% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of x_voxel_size as text
%        str2double(get(hObject,'String')) returns contents of x_voxel_size as a double


% --- Executes during object creation, after setting all properties.
function x_voxel_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_voxel_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_voxel_size_Callback(hObject, eventdata, handles)
% hObject    handle to y_voxel_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.Imstack)
    disp('You have not loaded an image stack yet therefore voxel size cannot be adjusted!!');
else
    if isnan(str2double(get(handles.y_voxel_size,'String')))
        disp('Please enter a numerical number');
    else
        handles.Imstack.voxel(2) = str2double(get(handles.y_voxel_size,'String'));
        disp(strcat("Y voxel size was set to ",num2str(handles.Imstack.voxel(2))));
        cla
        plot_tree(handles.referencetree,[1 0 0]);
        plot_tree(handles.tree);
        xlabel('x');
        ylabel('y');
        zlabel('z');
        % view(0,90)
        handles.planeind = 1;
        HaStack = show_stack(handles.Imstack);
        StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
        StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
        XlimMax = max([StMaxX,max(handles.tree.X)]);
        XlimMin = min([0,min(handles.tree.X)]);
        YlimMax = max([StMaxY,max(handles.tree.Y)]);
        YlimMin = min([0,min(handles.tree.Y)]);
        xlim([XlimMin XlimMax]);
        ylim([YlimMin YlimMax]);
        if logical(get(handles.transperent_toggle,'Value'))
            set (HaStack, 'facealpha', 0.5);
        else
            set (HaStack, 'facealpha', 1);
        end
    end
end

% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of y_voxel_size as text
%        str2double(get(hObject,'String')) returns contents of y_voxel_size as a double


% --- Executes during object creation, after setting all properties.
function y_voxel_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_voxel_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_voxel_size_Callback(hObject, eventdata, handles)
% hObject    handle to z_voxel_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.Imstack)
    disp('You have not loaded an image stack yet therefore voxel size cannot be adjusted!!');
else
    if isnan(str2double(get(handles.z_voxel_size,'String')))
        disp('Please enter a numerical number');
    else
        handles.Imstack.voxel(3) = str2double(get(handles.z_voxel_size,'String'));
        disp(strcat("Z voxel size was set to ",num2str(handles.Imstack.voxel(3))));
        cla
        plot_tree(handles.referencetree,[1 0 0]);
        plot_tree(handles.tree);
        xlabel('x');
        ylabel('y');
        zlabel('z');
        % view(0,90)
        handles.planeind = 1;
        HaStack = show_stack(handles.Imstack);
        StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
        StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
        XlimMax = max([StMaxX,max(handles.tree.X)]);
        XlimMin = min([0,min(handles.tree.X)]);
        YlimMax = max([StMaxY,max(handles.tree.Y)]);
        YlimMin = min([0,min(handles.tree.Y)]);
        xlim([XlimMin XlimMax]);
        ylim([YlimMin YlimMax]);
        if logical(get(handles.transperent_toggle,'Value'))
            set (HaStack, 'facealpha', 0.5);
        else
            set (HaStack, 'facealpha', 1);
        end
    end
end

% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of z_voxel_size as text
%        str2double(get(hObject,'String')) returns contents of z_voxel_size as a double


% --- Executes during object creation, after setting all properties.
function z_voxel_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_voxel_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function balancing_factor_Callback(hObject, eventdata, handles)
% hObject    handle to balancing_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.balancing_factor,'String')))
    disp('Please enter a numerical number');
elseif str2double(get(handles.balancing_factor,'String')) < 0 || str2double(get(handles.balancing_factor,'String')) > 1
    disp('Please enter a numerical number between or equal to 0 and 1');
else
    handles.bf_par{handles.NVolumes} = str2double(get(handles.balancing_factor,'String'));
    disp(strcat("Balancing factor for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.bf_par{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of balancing_factor as text
%        str2double(get(hObject,'String')) returns contents of balancing_factor as a double


% --- Executes during object creation, after setting all properties.
function balancing_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to balancing_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in flip_neuron.
function flip_neuron_Callback(hObject, eventdata, handles)
% hObject    handle to flip_neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla
plot_tree(handles.referencetree,[1 0 0]);
plot_tree(handles.tree);
xlabel('x');
ylabel('y');
zlabel('z');
xlim auto
ylim auto
% xlim(handles.xPlL)
% ylim(handles.yPlL)
if isfield(handles.tree,'IncompleteTerminals')
    InComI = [];
    for ff = 1:length(handles.tree.IncompleteTerminals(:,1))
        tempINCOMP = find(handles.tree.X == handles.tree.IncompleteTerminals(ff,1) &...
                          handles.tree.Y == handles.tree.IncompleteTerminals(ff,2) &...
                          handles.tree.Z == handles.tree.IncompleteTerminals(ff,3));
        InComI = [InComI,tempINCOMP];
    end
end
% view(0,90)
handles.planeind = 1;
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);


if isfield(handles,'newrootCoord')
    rmfield(handles,'newrootCoord');
end
handles.tree = rot_tree(handles.tree,[0 -180 0]);
handles.referencetree = rot_tree(handles.referencetree,[0 -180 0]);

cla
plot_tree(handles.referencetree,[1 0 0]);
plot_tree(handles.tree);
xlabel('x');
ylabel('y');
zlabel('z');
% view(0,90)
handles.planeind = 1;
if ~isempty(handles.Imstack)
    HaStack = show_stack(handles.Imstack);
    StMaxX = size(handles.Imstack.M{1},2)*handles.Imstack.voxel(1);
    StMaxY = size(handles.Imstack.M{1},1)*handles.Imstack.voxel(2);
    XlimMax = max([StMaxX,max(handles.tree.X)]);
    XlimMin = min([0,min(handles.tree.X)]);
    YlimMax = max([StMaxY,max(handles.tree.Y)]);
    YlimMin = min([0,min(handles.tree.Y)]);
    if logical(get(handles.transperent_toggle,'Value'))
        set (HaStack, 'facealpha', 0.5);
    else
        set (HaStack, 'facealpha', 1);
    end
else
    XlimMax = max(handles.tree.X); XlimMin = min(handles.tree.X);
    YlimMax = max(handles.tree.Y); YlimMin = min(handles.tree.Y);
end

xlim([XlimMin XlimMax]);
ylim([YlimMin YlimMax]);
% handles.xPlL = xlim; handles.yPlL = ylim; handles.zPlL = zlim;

if isfield(handles.tree,'IncompleteTerminals')
    handles.tree.IncompleteTerminals(:,1) = handles.tree.X(InComI);
    handles.tree.IncompleteTerminals(:,2) = handles.tree.Y(InComI);
    handles.tree.IncompleteTerminals(:,3) = handles.tree.Z(InComI);
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in Im_2D_switch.
function Im_2D_switch_Callback(hObject, eventdata, handles)
% hObject    handle to Im_2D_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Im_2D_switch



function maxDendLength_Callback(hObject, eventdata, handles)
% hObject    handle to maxDendLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.maxDendLength,'String')))
    if ~contains(get(handles.maxDendLength,'String'),'ref') && ~contains(get(handles.maxDendLength,'String'),'reset')
        disp('Please enter a positive numerical number or "ref" to match the statistics of the reference morphology');
        disp('Enter "reset" to stop matching of statistics');
    elseif contains(get(handles.maxDendLength,'String'),'ref')
        handles.maxDendLen_User = 'ref';
        disp('Max. Dendritic length was set to "ref"');
    elseif contains(get(handles.maxDendLength,'String'),'reset')
        handles.maxDendLen_User = 'reset';
        disp('Max. Dendritic length was set to "reset"');
    end
elseif str2double(get(handles.maxDendLength,'String')) <= 0
    disp('Please enter a positive numerical number or "ref" to match the statistics of the reference morphology');
    disp('Enter "reset" to stop matching of statistics');
else
    handles.maxDendLen_User = str2double(get(handles.maxDendLength,'String'));
    disp(strcat("Max. Dendritic length was set to ",num2str(handles.maxDendLen_User)));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of maxDendLength as text
%        str2double(get(hObject,'String')) returns contents of maxDendLength as a double


% --- Executes during object creation, after setting all properties.
function maxDendLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxDendLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxNrBranchPts_Callback(hObject, eventdata, handles)
% hObject    handle to maxNrBranchPts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.maxNrBranchPts,'String')))
    if ~contains(get(handles.maxNrBranchPts,'String'),'ref') && ~contains(get(handles.maxNrBranchPts,'String'),'reset')
        disp('Please enter a positive numerical number or "ref" to match the statistics of the reference morphology');
        disp('Enter "reset" to stop matching of statistics');
    elseif contains(get(handles.maxNrBranchPts,'String'),'ref')
        handles.maxNrBranchPts_User = 'ref';
        disp('Max. Nr. of Branches was set to "ref"');
    elseif contains(get(handles.maxNrBranchPts,'String'),'reset')
        handles.maxNrBranchPts_User = 'reset';
        disp('Max. Nr. of Branches was set to "reset"');
    end
elseif str2double(get(handles.maxNrBranchPts,'String')) <= 0
    disp('Please enter a positive numerical number or "ref" to match the statistics of the reference morphology');
    disp('Enter "reset" to stop matching of statistics');
else
    handles.maxNrBranchPts_User = floor(str2double(get(handles.maxNrBranchPts,'String')));
    disp(strcat("Max. Nr. of Branches ",num2str(handles.maxNrBranchPts_User)));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of maxNrBranchPts as text
%        str2double(get(hObject,'String')) returns contents of maxNrBranchPts as a double


% --- Executes during object creation, after setting all properties.
function maxNrBranchPts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxNrBranchPts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mainBrGrowth.
function mainBrGrowth_Callback(hObject, eventdata, handles)
% hObject    handle to mainBrGrowth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mainBrGrowth


% --- Executes on button press in transperent_toggle.
function transperent_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to transperent_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of transperent_toggle



function mainBrThickRatio_Callback(hObject, eventdata, handles)
% hObject    handle to mainBrThickRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.mainBrThickRatio,'String')))
    disp('Please enter a numerical number');
elseif str2double(get(handles.mainBrThickRatio,'String')) < 0 || str2double(get(handles.mainBrThickRatio,'String')) > 1
    disp('Please enter a numerical number between or equal to 0 and 1');
else
    handles.main_thickratio = str2double(get(handles.mainBrThickRatio,'String'));
    disp(strcat("Thickness ratio for main branches was set to ",num2str(handles.main_thickratio)));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of mainBrThickRatio as text
%        str2double(get(hObject,'String')) returns contents of mainBrThickRatio as a double


% --- Executes during object creation, after setting all properties.
function mainBrThickRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainBrThickRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [] = statisticsplot(FixTree,APReptree,Referencetree,Soind,Apind,Baind,apical,basal)

oldBO = BO_tree(FixTree);
[oldsec oldvec] = dissect_tree(FixTree);
PLoldBO = oldBO(oldsec(:,2));
newBO = BO_tree(APReptree);
[newsec newvec] = dissect_tree(APReptree);
PLnewBO = newBO(newsec(:,2));
refBO = BO_tree(Referencetree);
[refsec refvec] = dissect_tree(Referencetree);
PLrefBO = refBO(refsec(:,2));
limyC = max([max(histcounts(PLoldBO)),max(histcounts(PLnewBO)),max(histcounts(PLrefBO))]);
figure;
subplot(3,1,1);
histogram(PLoldBO);
xlabel('Branch order');
title('Cut Morphology')
ylim([0 limyC]);
xlim([0 max([max(PLoldBO),max(PLnewBO),max(PLrefBO)])]);
subplot(3,1,2);
histogram(PLnewBO);
xlabel('Branch order');
title('Repaired Morphology')
ylim([0 limyC]);
xlim([0 max([max(PLoldBO),max(PLnewBO),max(PLrefBO)])]);
subplot(3,1,3);
histogram(PLrefBO);
xlabel('Branch order');
title('PLreference Morphology')
ylim([0 limyC]);
xlim([0 max([max(PLoldBO),max(PLnewBO),max(PLrefBO)])]);

% sholl analysis
oldSholl = sholl_tree(FixTree);
% oldSholl = oldSholl/max(oldSholl);
oldx = 0:25:(length(oldSholl)-1)*25;
newSholl = sholl_tree(APReptree);
% newSholl = newSholl/max(newSholl);
newx = 0:25:(length(newSholl)-1)*25;
refSholl = sholl_tree(Referencetree);
% newSholl = newSholl/max(newSholl);
refx = 0:25:(length(refSholl)-1)*25;
figure;
subplot(3,1,1);
plot(oldx,oldSholl);
xlabel('Circle diameter [\mum]');
ylabel('Sholl distribution');
xlim([0 max([max(newx),max(oldx),max(refx)])])
ylim([0 max([max(oldSholl),max(newSholl),max(refSholl)])])
title('Cut Morphology')
subplot(3,1,2);
plot(newx,newSholl);
xlabel('Circle diameter [\mum]');
ylabel('Sholl distribution');
xlim([0 max([max(newx),max(oldx),max(refx)])])
ylim([0 max([max(oldSholl),max(newSholl),max(refSholl)])])
title('Repaired Morphology')
subplot(3,1,3);
plot(refx,refSholl);
xlabel('Circle diameter [\mum]');
ylabel('Sholl distribution');
xlim([0 max([max(newx),max(oldx),max(refx)])])
ylim([0 max([max(oldSholl),max(newSholl),max(refSholl)])])
title('Reference Morphology')

% tree volume
[~,oldVol] = boundary(FixTree.X,FixTree.Y,FixTree.Z);
[~,newVol] = boundary(APReptree.X,APReptree.Y,APReptree.Z);
[~,refVol] = boundary(Referencetree.X,Referencetree.Y,Referencetree.Z);
Kats = categorical({'Cut','Repaired','Reference'});
figure;
bar(Kats,[oldVol,newVol,refVol],'r');
ylabel('Volume [\mum^3]');
title('Total Volume of Neuron');
ylim([0 max([oldVol,newVol,refVol])+100000]);

% number of branch points
oldNBr = sum(B_tree(FixTree));
newNBr = sum(B_tree(APReptree));
refNBr = sum(B_tree(Referencetree));
Kats = categorical({'Cut','Repaired','Reference'});
figure;
subplot(1,3,1);
bar(Kats,[oldNBr,newNBr,refNBr],'r');
ylabel('Nr. of Branch points');
title('Total Nr. of Branch points');
ylim([0 max([newNBr,oldNBr,refNBr])+20]);

if isempty(Soind) && isempty(Apind) && isempty(Baind)
    oldDlen = sum(len_tree(FixTree));
    newDlen = sum(len_tree(APReptree)); 
    refDlen = sum(len_tree(Referencetree));
    Kats = categorical({'Cut','Repaired','Reference'});
    % figure;
    subplot(1,3,2);
    b = bar(Kats,[oldDlen,newDlen,refDlen]);
    ylabel('Dendritic length [\mum]');
    title('Total dendritic length');
    ylim([0 max([oldDlen,newDlen,refDlen])+1000]);
else
    % dend length
    newallind = 1:1:length(APReptree.R);
    newAp_So = find(APReptree.R == Apind | APReptree.R == Soind);
    newBa_So = find(APReptree.R == Baind | APReptree.R == Soind);
    newelim_BA = ~ismember(newallind,newAp_So);
    newelim_AP = ~ismember(newallind,newBa_So);
    newelim_BA = newallind(newelim_BA);
    newelim_AP = newallind(newelim_AP);
    newapical  = delete_tree(APReptree,newelim_BA);                
    newbasal   = delete_tree(APReptree,newelim_AP);

    refallind = 1:1:length(Referencetree.R);
    refAp_So = find(Referencetree.R == Apind | Referencetree.R == Soind);
    refBa_So = find(Referencetree.R == Baind | Referencetree.R == Soind);
    refelim_BA = ~ismember(refallind,refAp_So);
    refelim_AP = ~ismember(refallind,refBa_So);
    refelim_BA = refallind(refelim_BA);
    refelim_AP = refallind(refelim_AP);
    refapical  = delete_tree(Referencetree,refelim_BA);                
    refbasal   = delete_tree(Referencetree,refelim_AP);

    oldAPDlen = sum(len_tree(apical));
    oldBADlen = sum(len_tree(basal)); 
    newAPDlen = sum(len_tree(newapical));
    newBADlen = sum(len_tree(newbasal)); 
    refAPDlen = sum(len_tree(refapical));
    refBADlen = sum(len_tree(refbasal)); 
    Kats = categorical({'Apical','Basal'});
    % figure;
    subplot(1,3,2);
    b = bar(Kats,[oldAPDlen,newAPDlen,refAPDlen;oldBADlen,newBADlen,refBADlen]);
    ylabel('Dendritic length [\mum]');
    title('Total dendritic length');
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = 'Cut';
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xtips2 = b(2).XEndPoints;
    ytips2 = b(2).YEndPoints;
    labels2 = 'Repaired';
    text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xtips3 = b(3).XEndPoints;
    ytips3 = b(3).YEndPoints;
    labels3 = 'Reference';
    text(xtips3,ytips3,labels3,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    ylim([0 max([oldAPDlen,oldBADlen,newAPDlen,newBADlen,refAPDlen,refBADlen])+1000]);

    % measures per section
    [sect1 vec1] = dissect_tree(FixTree);
    [sect2 vec2] = dissect_tree(APReptree);
    [sect3 vec3] = dissect_tree(Referencetree);
    len1 = len_tree(FixTree);
    len2 = len_tree(APReptree);
    len3 = len_tree(Referencetree);
    sect1RE = FixTree.R(sect1(:,2));
    sect2RE = APReptree.R(sect2(:,2));
    sect3RE = Referencetree.R(sect3(:,2));
    NRegions = length(FixTree.rnames);
    seglen1 = []; seglen2 = []; seglen3 = [];
    seg1meanDia = []; seg2meanDia = []; seg3meanDia = [];
    seglen1{NRegions} = []; seglen2{NRegions} = []; seglen3{NRegions} = [];
    seg1meanDia{NRegions} = []; seg2meanDia{NRegions} = []; seg3meanDia{NRegions} = [];
    for nn = 1:length(sect1)
        cursegnodes = find(vec1(:,1) == nn);
        seglen1{sect1RE(nn)} = [seglen1{sect1RE(nn)},...
                                sum(len1(cursegnodes))];
        seg1meanDia{sect1RE(nn)} = [seg1meanDia{sect1RE(nn)},...
                                    mean(FixTree.D(cursegnodes))];
    end
    for nn = 1:length(sect2)
        cursegnodes = find(vec2(:,1) == nn);
        seglen2{sect2RE(nn)} = [seglen2{sect2RE(nn)},...
                                sum(len2(cursegnodes))];
        seg2meanDia{sect2RE(nn)} = [seg2meanDia{sect2RE(nn)},...
                                    mean(APReptree.D(cursegnodes))];
    end
    for nn = 1:length(sect3)
        cursegnodes = find(vec3(:,1) == nn);
        seglen3{sect3RE(nn)} = [seglen3{sect3RE(nn)},...
                                sum(len3(cursegnodes))];
        seg3meanDia{sect3RE(nn)} = [seg3meanDia{sect3RE(nn)},...
                                    mean(Referencetree.D(cursegnodes))];
    end
    APmeanpersegLen1 = mean(seglen1{Apind});
    APmeanpersegLen2 = mean(seglen2{Apind});
    APmeanpersegLen3 = mean(seglen3{Apind});
    BAmeanpersegLen1 = mean(seglen1{Baind});
    BAmeanpersegLen2 = mean(seglen2{Baind});
    BAmeanpersegLen3 = mean(seglen3{Baind});
    SOmeanpersegLen1 = mean(seglen1{Soind});
    SOmeanpersegLen2 = mean(seglen2{Soind});
    SOmeanpersegLen3 = mean(seglen3{Soind});
    Kats = categorical({'Apical','Basal','Soma'});
    % figure;
    subplot(1,3,3);
    b = bar(Kats,[APmeanpersegLen1,APmeanpersegLen2,APmeanpersegLen3;...
                  BAmeanpersegLen1,BAmeanpersegLen2,BAmeanpersegLen3;...
                  SOmeanpersegLen1,SOmeanpersegLen2,SOmeanpersegLen3]);
    ylabel('Dendritic length [\mum]');
    title('Dendritic length per Segment');
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = 'Cut';
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xtips2 = b(2).XEndPoints;
    ytips2 = b(2).YEndPoints;
    labels2 = 'Repaired';
    text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xtips2 = b(3).XEndPoints;
    ytips2 = b(3).YEndPoints;
    labels2 = 'Reference';
    text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    ylim([0 max([APmeanpersegLen1,APmeanpersegLen2,APmeanpersegLen3,...
         BAmeanpersegLen1,BAmeanpersegLen2,BAmeanpersegLen3,...
         SOmeanpersegLen1,SOmeanpersegLen2,SOmeanpersegLen3])+15]);
    APmeanpersegDia1 = mean(seg1meanDia{Apind});
    APmeanpersegDia2 = mean(seg2meanDia{Apind});
    APmeanpersegDia3 = mean(seg3meanDia{Apind});
    BAmeanpersegDia1 = mean(seg1meanDia{Baind});
    BAmeanpersegDia2 = mean(seg2meanDia{Baind});
    BAmeanpersegDia3 = mean(seg3meanDia{Baind});
    SOmeanpersegDia1 = mean(seg1meanDia{Soind});
    SOmeanpersegDia2 = mean(seg2meanDia{Soind});
    SOmeanpersegDia3 = mean(seg3meanDia{Soind});
    Kats = categorical({'Apical','Basal'});
    figure;
    b = bar(Kats,[APmeanpersegDia1,APmeanpersegDia2,APmeanpersegDia3;...
                  BAmeanpersegDia1,BAmeanpersegDia2,BAmeanpersegDia3]);
    ylabel('Diameter [\mum]');
    title('Diameter per Segment');
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = 'Cut';
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xtips2 = b(2).XEndPoints;
    ytips2 = b(2).YEndPoints;
    labels2 = 'Repaired';
    text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xtips2 = b(3).XEndPoints;
    ytips2 = b(3).YEndPoints;
    labels2 = 'Reference';
    text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    ylim([0 max([APmeanpersegDia1,APmeanpersegDia2,APmeanpersegDia3,...
         BAmeanpersegDia1,BAmeanpersegDia2,BAmeanpersegDia3])+1]);

    % Diameter with respect to pathlength from root
    Lroot_perN1 = Pvec_tree(FixTree);
    Lroot_perN2 = Pvec_tree(APReptree);
    Lroot_perN3 = Pvec_tree(Referencetree);
    figure;
    subplot(3,1,1);
    scatter(Lroot_perN1,FixTree.D,'filled','k');
    xlabel('Path length from Root [\mum]');
    ylabel('Diameter [\mum]');
    title('Cut Morphology');
    subplot(3,1,2);
    scatter(Lroot_perN2,APReptree.D,'filled','k');
    xlabel('Path length from Root [\mum]');
    ylabel('Diameter [\mum]');
    title('Repaired Morphology');
    subplot(3,1,3);
    scatter(Lroot_perN3,Referencetree.D,'filled','k');
    xlabel('Path length from Root [\mum]');
    ylabel('Diameter [\mum]');
    title('Reference Morphology');

    % measures per branchorder
    segBO1{NRegions} = []; segBO2{NRegions} = []; segBO3{NRegions} = [];
    BOs1{NRegions} = []; BOs2{NRegions} = []; BOs3{NRegions} = [];
    PerBOmeanlen1{NRegions} = []; PerBOmeanlen2{NRegions} = []; PerBOmeanlen3{NRegions} = [];
    PerBOmeanDia1{NRegions} = []; PerBOmeanDia2{NRegions} = []; PerBOmeanDia3{NRegions} = [];

    for nn = 1:length(sect1)
        cursegnodes = find(vec1(:,1) == nn);
        segBO1{sect1RE(nn)} = [segBO1{sect1RE(nn)},...
                               oldBO(cursegnodes(1))];
    end
    for nn = 1:length(sect2)
        cursegnodes = find(vec2(:,1) == nn);
        segBO2{sect2RE(nn)} = [segBO2{sect2RE(nn)},...
                               newBO(cursegnodes(1))];
    end
    for nn = 1:length(sect3)
        cursegnodes = find(vec3(:,1) == nn);
        segBO3{sect3RE(nn)} = [segBO3{sect3RE(nn)},...
                               refBO(cursegnodes(1))];
    end

    for nn = 1:length(segBO1)
        BOs1{nn} = unique(segBO1{nn});
        for tt = 1:length(BOs1{nn})
            currBO = find(segBO1{nn} == BOs1{nn}(tt));
            PerBOmeanlen1{nn} = [PerBOmeanlen1{nn},...
                                 mean(seglen1{nn}(currBO))];
            PerBOmeanDia1{nn} = [PerBOmeanDia1{nn},...
                                 mean(seg1meanDia{nn}(currBO))];
        end
        BOs2{nn} = unique(segBO2{nn});
        for tt = 1:length(BOs2{nn})
            currBO = find(segBO2{nn} == BOs2{nn}(tt));
            PerBOmeanlen2{nn} = [PerBOmeanlen2{nn},...
                                 mean(seglen2{nn}(currBO))];
            PerBOmeanDia2{nn} = [PerBOmeanDia2{nn},...
                                 mean(seg2meanDia{nn}(currBO))];
        end
        BOs3{nn} = unique(segBO3{nn});
        for tt = 1:length(BOs3{nn})
            currBO = find(segBO3{nn} == BOs3{nn}(tt));
            PerBOmeanlen3{nn} = [PerBOmeanlen3{nn},...
                                 mean(seglen3{nn}(currBO))];
            PerBOmeanDia3{nn} = [PerBOmeanDia3{nn},...
                                 mean(seg3meanDia{nn}(currBO))];
        end
    end

    limYax = max([PerBOmeanlen1{1},PerBOmeanlen1{3},PerBOmeanlen2{1},PerBOmeanlen2{3},...
                  PerBOmeanlen3{1},PerBOmeanlen3{3}])+10;
    limXaxAP = max([length(PerBOmeanlen1{1}),length(PerBOmeanlen2{1}),...
                    length(PerBOmeanlen3{1})]);
    limXaxBA = max([length(PerBOmeanlen1{3}),length(PerBOmeanlen2{3}),...
                    length(PerBOmeanlen3{3})]);

    figure;
    subplot(3,2,1);
    b = bar(PerBOmeanlen1{1},'k');
    xlabel('Apical');
    ylabel('Length [\mum]');
    xlim([0 limXaxAP+1]);
    ylim([0 limYax]);
    title('Cut Tree')
    subplot(3,2,2);
    b = bar(PerBOmeanlen1{3},'r');
    xlabel('Basal');
    ylabel('Length [\mum]');
    xlim([0 limXaxBA+1]);
    ylim([0 limYax]);
    title('Cut Tree')
    subplot(3,2,3);
    b = bar(PerBOmeanlen2{1},'k');
    xlabel('Apical');
    ylabel('Length [\mum]');
    xlim([0 limXaxAP+1]);
    ylim([0 limYax]);
    title('Repaired Tree')
    subplot(3,2,4);
    b = bar(PerBOmeanlen2{3},'r');
    xlabel('Basal');
    ylabel('Length [\mum]');
    xlim([0 limXaxBA+1]);
    ylim([0 limYax]);
    title('Repaired Tree')
    subplot(3,2,5);
    b = bar(PerBOmeanlen3{1},'k');
    xlabel('Apical');
    ylabel('Length [\mum]');
    xlim([0 limXaxAP+1]);
    ylim([0 limYax]);
    title('Reference Tree')
    subplot(3,2,6);
    b = bar(PerBOmeanlen3{3},'r');
    xlabel('Basal');
    ylabel('Length [\mum]');
    xlim([0 limXaxBA+1]);
    ylim([0 limYax]);
    title('Reference Tree')

    limYax = max([PerBOmeanDia1{1},PerBOmeanDia1{3},PerBOmeanDia2{1},PerBOmeanDia2{3},...
                  PerBOmeanDia3{1},PerBOmeanDia3{3}])+0.5;
    limXaxAP = max([length(PerBOmeanDia1{1}),length(PerBOmeanDia2{1}),...
                    length(PerBOmeanDia3{1})]);
    limXaxBA = max([length(PerBOmeanDia1{3}),length(PerBOmeanDia2{3}),...
                    length(PerBOmeanDia3{3})]);

    figure;
    subplot(3,2,1);
    b = bar(PerBOmeanDia1{1},'k');
    xlabel('Apical');
    ylabel('Diameter [\mum]');
    xlim([0 limXaxAP+1]);
    ylim([0 limYax]);
    title('Cut Tree')
    subplot(3,2,2);
    b = bar(PerBOmeanDia1{3},'r');
    xlabel('Basal');
    ylabel('Diameter [\mum]');
    xlim([0 limXaxBA+1]);
    ylim([0 limYax]);
    title('Cut Tree')
    subplot(3,2,3);
    b = bar(PerBOmeanDia2{1},'k');
    xlabel('Apical');
    ylabel('Diameter [\mum]');
    xlim([0 limXaxAP+1]);
    ylim([0 limYax]);
    title('Repaired Tree')
    subplot(3,2,4);
    b = bar(PerBOmeanDia2{3},'r');
    xlabel('Basal');
    ylabel('Diameter [\mum]');
    xlim([0 limXaxBA+1]);
    ylim([0 limYax]);
    title('Repaired Tree')
    subplot(3,2,5);
    b = bar(PerBOmeanDia3{1},'k');
    xlabel('Apical');
    ylabel('Diameter [\mum]');
    xlim([0 limXaxAP+1]);
    ylim([0 limYax]);
    title('Reference Tree')
    subplot(3,2,6);
    b = bar(PerBOmeanDia3{3},'r');
    xlabel('Basal');
    ylabel('Diameter [\mum]');
    xlim([0 limXaxBA+1]);
    ylim([0 limYax]);
    title('Reference Tree')

    % rootangle distribution
    oldRootA = rootangle_tree(FixTree);
    newRootA = rootangle_tree(APReptree);
    refRootA = rootangle_tree(Referencetree);

    AngV     = linspace   (0, pi, 25);
    oldpdf      = histcounts (oldRootA, AngV);
    newpdf      = histcounts (newRootA, AngV);
    refpdf      = histcounts (refRootA, AngV);
    mAngV    = (AngV (2 : 25) + AngV (1 : 24)) / 2; % Get midpoints
    oldRootA = oldpdf / trapz (mAngV, oldpdf);
    newRootA = newpdf / trapz (mAngV, newpdf);
    refRootA = refpdf / trapz (mAngV, refpdf);
    maxAngR = max([oldRootA,newRootA,refRootA]);
    figure;
    subplot(3,1,1);
    plot     (mAngV, oldRootA, 'black')
    xlim     ([0 pi]);
    ylim     ([0 maxAngR]);
    xlabel   ('Angle');
    ylabel   ('Density');
    title('Cut Tree')
    subplot(3,1,2);
    plot     (mAngV, newRootA, 'black')
    xlim     ([0 pi]);
    ylim     ([0 maxAngR]);
    xlabel   ('Angle');
    ylabel   ('Density');
    title('Repaired Tree')
    subplot(3,1,3);
    plot     (mAngV, refRootA, 'black')
    xlim     ([0 pi]);
    ylim     ([0 maxAngR]);
    xlabel   ('Angle');
    ylabel   ('Density');
    title('Reference Tree')
end

function [out1,out2,out3] = ginput_plot(arg1)
%GINPUT Graphical input from mouse.
%   [X,Y] = GINPUT(N) gets N points from the current axes and returns
%   the X- and Y-coordinates in length N vectors X and Y.  The cursor
%   can be positioned using a mouse.  Data points are entered by pressing
%   a mouse button or any key on the keyboard except carriage return,
%   which terminates the input before N points are entered. If the current
%   axes is a geographic axes, the coordinates returned are latitude and
%   longitude instead of X and Y.
%
%   [X,Y] = GINPUT gathers an unlimited number of points until the
%   return key is pressed.
%
%   [X,Y,BUTTON] = GINPUT(N) returns a third result, BUTTON, that
%   contains a vector of integers specifying which mouse button was
%   used (1,2,3 from left) or ASCII numbers if a key on the keyboard
%   was used.
%
%   Examples:
%       [x,y] = ginput;
%
%       [x,y] = ginput(5);
%
%       [x, y, button] = ginput(1);
%
%   See also GTEXT, WAITFORBUTTONPRESS.

%   Copyright 1984-2018 The MathWorks, Inc.

out1 = []; out2 = []; out3 = []; y = [];

if ~matlab.ui.internal.isFigureShowEnabled
    error(message('MATLAB:hg:NoDisplayNoFigureSupport', 'ginput'))
end
    
    % Check Inputs
    if nargin == 0
        how_many = -1;
        b = [];
    else
        how_many = arg1;
        b = [];
        if  ~isPositiveScalarIntegerNumber(how_many) 
            error(message('MATLAB:ginput:NeedPositiveInt'))
        end
        if how_many == 0
            % If input argument is equal to zero points,
            % give a warning and return empty for the outputs.            
            warning (message('MATLAB:ginput:InputArgumentZero'));
        end
    end
    
    % Get figure
    fig = gcf;
    drawnow;
    figure(gcf);
    
    % Make sure the figure has an axes
    gca(fig);    
    
    % Setup the figure to disable interactive modes and activate pointers. 
    initialState = setupFcn(fig);
    
    % onCleanup object to restore everything to original state in event of
    % completion, closing of figure errors or ctrl+c. 
    c = onCleanup(@() restoreFcn(initialState));
    
    drawnow
    char = 0;
    
    while how_many ~= 0
        waserr = 0;
        try
            keydown = wfbp;
        catch %#ok<CTCH>
            waserr = 1;
        end
        if(waserr == 1)
            if(ishghandle(fig))
                cleanup(c);
                error(message('MATLAB:ginput:Interrupted'));
            else
                cleanup(c);
                error(message('MATLAB:ginput:FigureDeletionPause'));
            end
        end
        % g467403 - ginput failed to discern clicks/keypresses on the figure it was
        % registered to operate on and any other open figures whose handle
        % visibility were set to off
        figchildren = allchild(0);
        if ~isempty(figchildren)
            ptr_fig = figchildren(1);
        else
            error(message('MATLAB:ginput:FigureUnavailable'));
        end
        %         old code -> ptr_fig = get(0,'CurrentFigure'); Fails when the
        %         clicked figure has handlevisibility set to callback
        if(ptr_fig == fig)
            if keydown
                char = get(fig, 'CurrentCharacter');
                button = abs(get(fig, 'CurrentCharacter'));
            else
                button = get(fig, 'SelectionType');
                if strcmp(button,'open')
                    button = 1;
                elseif strcmp(button,'normal')
                    button = 1;
                elseif strcmp(button,'extend')
                    button = 2;
                elseif strcmp(button,'alt')
                    button = 3;
                else
                    error(message('MATLAB:ginput:InvalidSelection'))
                end
            end
            
            if(char == 13) % & how_many ~= 0)
                % if the return key was pressed, char will == 13,
                % and that's our signal to break out of here whether
                % or not we have collected all the requested data
                % points.
                % If this was an early breakout, don't include
                % the <Return> key info in the return arrays.
                % We will no longer count it if it's the last input.
                break;
            end
            
            axes_handle = gca;            
            if ~(isa(axes_handle,'matlab.graphics.axis.Axes') ...
                    || isa(axes_handle,'matlab.graphics.axis.GeographicAxes'))
                % If gca is not an axes, warn but keep listening for clicks. 
                % (There may still be other subplots with valid axes)
                warning(message('MATLAB:Chart:UnsupportedConvenienceFunction', 'ginput', axes_handle.Type));
                continue            
            end
            
            drawnow;
            pt = get(axes_handle, 'CurrentPoint');            
            how_many = how_many - 1;
            

            
            out1 = [out1;pt(1,1)]; %#ok<AGROW>
            y = [y;pt(1,2)]; %#ok<AGROW>
            b = [b;button]; %#ok<AGROW>
            hold on;
            scatter3(out1,y,zeros(length(y),1),'filled','r');
        end
    end
    
    % Cleanup and Restore 
    cleanup(c);
    
    if nargout > 1
        out2 = y;
        if nargout > 2
            out3 = b;
        end
    else
        out1 = [out1 y];
    end

function valid = isPositiveScalarIntegerNumber(how_many)
valid = ~isa(how_many, 'matlab.graphics.Graphics') && ... % not a graphics handle
        ~ischar(how_many) && ...            % is numeric
        isscalar(how_many) && ...           % is scalar
        (fix(how_many) == how_many) && ...  % is integer in value
        how_many >= 0;                      % is positive


function key = wfbp
%WFBP   Replacement for WAITFORBUTTONPRESS that has no side effects.

fig = gcf;
current_char = []; %#ok<NASGU>

% Now wait for that buttonpress, and check for error conditions
waserr = 0;
try
    h=findall(fig,'Type','uimenu','Accelerator','C');   % Disabling ^C for edit menu so the only ^C is for
    set(h,'Accelerator','');                            % interrupting the function.
    keydown = waitforbuttonpress;
    current_char = double(get(fig,'CurrentCharacter')); % Capturing the character.
    if~isempty(current_char) && (keydown == 1)          % If the character was generated by the
        if(current_char == 3)                           % current keypress AND is ^C, set 'waserr'to 1
            waserr = 1;                                 % so that it errors out.
        end
    end
    
    set(h,'Accelerator','C');                           % Set back the accelerator for edit menu.
catch %#ok<CTCH>
    waserr = 1;
end
drawnow;
if(waserr == 1)
    set(h,'Accelerator','C');                          % Set back the accelerator if it errored out.
    error(message('MATLAB:ginput:Interrupted'));
end

if nargout>0, key = keydown; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function initialState = setupFcn(fig)

% Store Figure Handle. 
initialState.figureHandle = fig; 

% Suspend figure functions
initialState.uisuspendState = uisuspend(fig);

% Disable Plottools Buttons
initialState.toolbar = findobj(allchild(fig),'flat','Type','uitoolbar');
if ~isempty(initialState.toolbar)
    initialState.ptButtons = [uigettool(initialState.toolbar,'Plottools.PlottoolsOff'), ...
        uigettool(initialState.toolbar,'Plottools.PlottoolsOn')];
    initialState.ptState = get (initialState.ptButtons,'Enable');
    set (initialState.ptButtons,'Enable','off');
end

% Disable AxesToolbar
initialState.axes = findobj(allchild(fig),'-isa','matlab.graphics.axis.AbstractAxes');
tb = get(initialState.axes, 'Toolbar');
if ~isempty(tb) && ~iscell(tb)
    initialState.toolbarVisible{1} = tb.Visible;
    tb.Visible = 'off';
else
    for i=1:numel(tb)
        if ~isempty(tb{i})
            initialState.toolbarVisible{i} = tb{i}.Visible;
            tb{i}.Visible = 'off';
        end
    end
end

%Setup empty pointer
cdata = NaN(16,16);
hotspot = [8,8];
set(gcf,'Pointer','custom','PointerShapeCData',cdata,'PointerShapeHotSpot',hotspot)

% Create uicontrols to simulate fullcrosshair pointer.
initialState.CrossHair = createCrossHair(fig);

% Adding this to enable automatic updating of currentpoint on the figure 
% This function is also used to update the display of the fullcrosshair
% pointer and make them track the currentpoint.
set(fig,'WindowButtonMotionFcn',@(o,e) dummy()); % Add dummy so that the CurrentPoint is constantly updated
initialState.MouseListener = addlistener(fig,'WindowMouseMotion', @(o,e) updateCrossHair(o,initialState.CrossHair));

% Get the initial Figure Units
initialState.fig_units = get(fig,'Units');


function restoreFcn(initialState)
if ishghandle(initialState.figureHandle)
    delete(initialState.CrossHair);
    
    % Figure Units
    set(initialState.figureHandle,'Units',initialState.fig_units);
    
    set(initialState.figureHandle,'WindowButtonMotionFcn','');
    delete(initialState.MouseListener);
    
    % Plottools Icons
    if ~isempty(initialState.toolbar) && ~isempty(initialState.ptButtons)
        set (initialState.ptButtons(1),'Enable',initialState.ptState{1});
        set (initialState.ptButtons(2),'Enable',initialState.ptState{2});
    end
    
    % Restore axestoolbar
    for i=1:numel(initialState.axes)
        if ~isempty(initialState.axes(i).Toolbar)
            initialState.axes(i).Toolbar.Visible_I = initialState.toolbarVisible{i};
        end
    end    
    
    % UISUSPEND
    uirestore(initialState.uisuspendState);    
end


function updateCrossHair(fig, crossHair)
% update cross hair for figure.
gap = 3; % 3 pixel view port between the crosshairs
cp = hgconvertunits(fig, [fig.CurrentPoint 0 0], fig.Units, 'pixels', fig);
cp = cp(1:2);
figPos = hgconvertunits(fig, fig.Position, fig.Units, 'pixels', fig.Parent);
figWidth = figPos(3);
figHeight = figPos(4);

% Early return if point is outside the figure
if cp(1) < gap || cp(2) < gap || cp(1)>figWidth-gap || cp(2)>figHeight-gap
    return
end

set(crossHair, 'Visible', 'on');
thickness = 1; % 1 Pixel thin lines. 
set(crossHair(1), 'Position', [0 cp(2) cp(1)-gap thickness]);
set(crossHair(2), 'Position', [cp(1)+gap cp(2) figWidth-cp(1)-gap thickness]);
set(crossHair(3), 'Position', [cp(1) 0 thickness cp(2)-gap]);
set(crossHair(4), 'Position', [cp(1) cp(2)+gap thickness figHeight-cp(2)-gap]);


function crossHair = createCrossHair(fig)
% Create thin uicontrols with black backgrounds to simulate fullcrosshair pointer.
% 1: horizontal left, 2: horizontal right, 3: vertical bottom, 4: vertical top
for k = 1:4
    crossHair(k) = uicontrol(fig, 'Style', 'text', 'Visible', 'off', 'Units', 'pixels', 'BackgroundColor', [0 0 0], 'HandleVisibility', 'off', 'HitTest', 'off'); %#ok<AGROW>
end


function cleanup(c)
if isvalid(c)
    delete(c);
end


function dummy(~,~)
dumdum = 1;

function RmVolPts_Dist_Callback(hObject, eventdata, handles)
% hObject    handle to RmVolPts_Dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isnan(str2double(get(handles.RmVolPts_Dist,'String')))
    disp('Please enter a numerical number');
else
    handles.RmPts_Dist{handles.NVolumes} = str2double(get(handles.RmVolPts_Dist,'String'));
    disp(strcat("RmVolPts_Dist for Volume ",num2str(handles.NVolumes)," was set to ",num2str(handles.RmPts_Dist{handles.NVolumes})));
end
% assignin('base','NPts_User',NPts_User)
handles.output = hObject;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of RmVolPts_Dist as text
%        str2double(get(hObject,'String')) returns contents of RmVolPts_Dist as a double


% --- Executes during object creation, after setting all properties.
function RmVolPts_Dist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RmVolPts_Dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
