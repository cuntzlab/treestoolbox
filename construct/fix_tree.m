% fix_tree   Minimum spanning tree based tree repair tool.
% (trees package)
%
% 
% [RepTree,OutData] = fix_tree(InTree,BaseTree,RefTree,Vol,params,options)
% 
% Tree repair tool that adds artificial dendrites in a specified volume to 
% an existing morpholgy reconstruction. Dendrites can be grown form
% incomplete ends exclusively or from any random point on the tree. For
% pyramidal cells a number of main dendrites can be grown first (only
% available if incomplete growth is enabled). Incomplete ends of the Input
% morphology have to be specified in the Input tree as field
% 'IncompleteTerminals'.
% 
% 
% Input
% -----
% InTree:   Tree that is going to be repaired (this can be a tree that
%           already has a repair done in which case the original tree
%           with no repairs should be passed to 'BaseTree').
% BaseTree: Original tree with no repairs done (if left empty it is the
%           same tree as 'InTree' which will be repaired). 'BaseTree'
%           is used to derive the balancing factor and other parameters
%           for the repair.
% RefTree:  optional reference morphologie used to calculate total
%           number of branch points and total dendritic length the
%           repair is supposed to match (turn on options '-Re' for
%           repair to be edited).
% Vol:      Volume coordinate struct. 3D coordinates as Vol.Pts 
%           {DEFAULT: rand(100,3)} and boundary alpha as Vol.aplpha 
%           {DEFAULT: 0}.
% params:   parameter struct. Use to manually change all parameters.
%           Example -> params.NPts_User = 100
%           params list:
%           cut_growth{DEFAULT: 0};mainBr_growth{DEFAULT: 0};
%           main_thickratio{DEFAULT: 0.7};R{DEFAULT: 0.5};taper_pars;
%           bf_par;taper_thresh;jitter_stde{DEFAULT: 0.15};
%           jitter_lambda{DEFAULT: 10};MST_prunelen{DEFAULT: 0};
%           MST_growthThr;NPts_User;res_rate{DEFAULT: 1};
%           maxDendLen;maxNrBranchPts;RmPts_Dist{DEFAULT: 25}
% options:  '-V'    enables volume control for biological regrowth.
%                   Cutgrwoth needs to be disabled and the coordinates of 
%                   the incomplete terminal of the severed branch specified
%                   in the morphology as a field 'IncompleteTerminals'.
%           '-e'    echo
%           '-Re'   edit or rework the final repaired part of the tree by
%                   jittering, tapering, smoothing etc.
%           '-B'    matching growth to Nr. of branch points
%           '-L'    pruning to match Nr. of branch points ('-Re' must be 
%                   engaged) This option leads to NON optimal trees!!!! Use
%                   for testing!
%           '-J'    no jitter_tree ('-Re' must be engaged)
%           '-S'    no smooth_tree ('-Re' must be engaged)
%           '->'    no tapering ('-Re' must be engaged)
%           '-Str'  no smoothing taper transition between old and new
%                   dendrites (only applies if tapering is enabled)
%                   ('-Re' must be engaged)
%           '-M'    plot final repair and mark artificially added carrier
%                   points ('-Re' must be engaged)

function [RepTree,OutData] = fix_tree(InTree,BaseTree,RefTree,Vol,...
    params,options)

FinalInfoStr = '';

if nargin < 6
    options = '';
elseif nargin < 5
    options = '';
    params  = [];
elseif nargin < 4
    error('Please specifiy input trees as well as Vol variables as input arguments');  
end

if isempty(BaseTree)
    BaseTree = InTree;
end
if isempty(Vol)
    disp('please specify volume coordinates and boundary alpha');
    Vol.Pts     = rand(100,3)*100;
    Vol.alpha   = 0;
elseif ~isstruct(Vol)
    error('Vol must be a struct with fields Pts and alpha');
elseif ~isfield(Vol,'Pts')
    disp('please specify volume coordinates and boundary alpha');
    Vol.Pts     = rand(100,3)*100;
elseif ~isfield(Vol,'alpha')
    disp('please specify volume coordinates and boundary alpha');
    Vol.alpha   = 0;
end
% mark original tree to be able to identify new grown parts
% artifiacially grown parts have diameter 1 therefore original tree parts
% are marked by having diameter different from 1
check1Dia = find(InTree.D == 1);
InTree.D(check1Dia) = 1.001;
% check if volume is 2 dimensional
if size(Vol.Pts,2) == 2
    Vol.Pts(:,3) = zeros(size(Vol.Pts,1),1);
end
%% Set parameters for the repair
% params list:
%%% cut_growth;mainBr_growth;main_thickratio;R;taper_pars;bf_par;
%%% taper_thresh;jitter_stde;jitter_lambda;MST_prunelen;MST_growthThr;
%%% NPts_User;res_rate;maxDendLen;maxNrBranchPts
% Vol list:
%%% Pts;alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initializing parameters
if ~isfield(params,'cut_growth') || isempty(params.cut_growth) || isempty(params)
    cut_growth = 0;
else
    cut_growth = params.cut_growth;
end
if ~isfield(params,'mainBr_growth') || isempty(params.mainBr_growth) || isempty(params)
    mainBr_growth = 0;
else
    mainBr_growth = params.mainBr_growth;
end
if ~isfield(params,'main_thickratio') || isempty(params.main_thickratio) || isempty(params)
    main_thickratio = 0.7;
else
    main_thickratio = params.main_thickratio;
end
% get R value of tree corresponding to point clustering
if ~isfield(params,'R') || isempty(params.R) || isempty(params)
    if sum(BaseTree.Z) == 0
        R = 0.5;
    else
        R = r_mc_tree (BaseTree,[],10,[],'-bt');
    end
else
    R                = params.R;
end
% get taper params
if contains(options,'->')
else
    if ~isfield(params,'taper_pars') || isempty(params.taper_pars) || isempty(params)
        [taper_pars,~] = quadfit_tree(BaseTree);
    else
        if length(params.taper_pars) ~= 2
            disp('taper parameters must be a 2-tupel (first number -> scale)');
            disp('(second number -> offset)');
            error('taper parameters must be a 2-tupel');
        else
            taper_pars                = params.taper_pars;
        end
    end
end
% get parameters from params struct
if ~isfield(params,'bf_par') || isempty(params.bf_par) || isempty(params)
    bf_derived              = bf_tree (BaseTree);
    bfapical                = bf_derived;
else
    bfapical                = params.bf_par;
end
if contains(options,'->')
else
    if ~isfield(params,'taper_pars') || isempty(params.taper_pars) || isempty(params)
        colapictaper_offset     = taper_pars(2);%0.30;
    else
        colapictaper_offset     = params.taper_pars(2);
    end
    if ~isfield(params,'taper_pars') || isempty(params.taper_pars) || isempty(params)
        colapictaper_scale      = taper_pars(1);%0.1;
    else
        colapictaper_scale      = params.taper_pars(1);
    end
    if ~isfield(params,'taper_thresh') || isempty(params.taper_thresh) || isempty(params)
        taperthreshold          = colapictaper_offset-colapictaper_offset*0.1;
    else
        taperthreshold          = params.taper_thresh;
    end
end
if ~isfield(params,'jitter_stde') || isempty(params.jitter_stde) || isempty(params)
    jitter_stde                     = 0.15;
else
    jitter_stde                     = params.jitter_stde;
end
if ~isfield(params,'jitter_lambda') || isempty(params.jitter_lambda) || isempty(params)
    jitter_lambda                   = 10;
else
    jitter_lambda                   = params.jitter_lambda;
end
jitter_lambda = 10;
if ~isfield(params,'MST_prunelen') || isempty(params.MST_prunelen) || isempty(params)
    prunlen                 = 0;
else
    prunlen                 = params.MST_prunelen;
end
if ~isfield(params,'res_rate') || isempty(params.res_rate) || isempty(params)
    resample_rate           = 1;
else
    resample_rate           = params.res_rate;
end
if ~isfield(params,'RmPts_Dist') || isempty(params.RmPts_Dist) || isempty(params)
    RmPts_Dist = 25;
else
    RmPts_Dist = params.RmPts_Dist;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get boundary of input volume coordinates
[VolBound,Volsize] = boundary(Vol.Pts,Vol.alpha);
if sum(Vol.Pts(:,3)) == 0
    Volsize = polyarea(Vol.Pts(:,1),Vol.Pts(:,2));
end
OutData.IndVolBou = VolBound;
% calculate min and max of Vloume to shift points into place
meanVol = [];
extX(1) = max(Vol.Pts(:,1)); extX(2) = min(Vol.Pts(:,1));
extY(1) = max(Vol.Pts(:,2)); extY(2) = min(Vol.Pts(:,2));
extZ(1) = max(Vol.Pts(:,3)); extZ(2) = min(Vol.Pts(:,3));
VolCube = abs(extX(1)-extX(2))*abs(extY(1)-extY(2))*abs(extZ(1)-extZ(2));
xsidelen = ceil(abs(extX(1)-extX(2))/200);
ysidelen = ceil(abs(extY(1)-extY(2))/200);
zsidelen = ceil(abs(extZ(1)-extZ(2))/200);
meanVol(:,1) = mean(Vol.Pts(:,1));
meanVol(:,2) = mean(Vol.Pts(:,2));
meanVol(:,3) = mean(Vol.Pts(:,3));
OutData.meanVol = meanVol;

% get direction in which most branches grow to determine
% 'growThr' by calculating straigth line from root through mean of Volume
rootcord = [BaseTree.X(1),BaseTree.Y(1),BaseTree.Z(1)];
Volmeancord = mean(Vol.Pts);

checkdist = squareform(pdist([rootcord;Vol.Pts]));
[~,farind]= max(checkdist(1,:));
farpt = Vol.Pts(farind-1,:);
Volmeancord = mean([farpt;Volmeancord]);

spanvec = Volmeancord-rootcord;
linPtN = 0:0.01:5;
linePts =[];
for qind = 1:length(linPtN)
    linePts = [linePts;rootcord+linPtN(qind)*spanvec];
end
polyshape.faces     = VolBound;
polyshape.vertices  = Vol.Pts;
OutData.polyshape = polyshape;
if sum(Vol.Pts(:,3)) == 0
    inside = inpolygon(linePts(:,1),linePts(:,2),Vol.Pts(:,1),Vol.Pts(:,2));
else
    inside = inpolyhedron(polyshape,linePts);
end
INlinePts = linePts(inside,:);
if ~isfield(params,'MST_growthThr') || isempty(params.MST_growthThr) || isempty(params)
    %             growThr                 = max(pdist([BaseTree.X,BaseTree.Y,BaseTree.Z]))/3;
    growThr = norm(INlinePts(1,:)-INlinePts(end,:))*1.3;
else
    growThr                 = params.MST_growthThr;
end
OutData.growThr = growThr;

% get branch and terminal point density to determine 'Npts' if not
% specified in params
iBT = B_tree(InTree) | T_tree(InTree);
[tree_M,tree_dX,tree_dY,tree_dZ,tree_HP] = gdens_tree(InTree, 20, iBT, 'none');
densBaseTree = mean(mean(mean(tree_M)));

if ~isfield(params,'NPts_User') || isempty(params.NPts_User) || isempty(params)
    Npts = ceil(3+densBaseTree*2353+Volsize*0.00002);
else
    Npts = params.NPts_User;
end

% check nr of branch points in RefTree or any number that has been
% specified by the user
if ~isempty(RefTree)
    mDlen = sum(len_tree(RefTree));
    mNBr = sum(B_tree(RefTree));
else
    if ~isfield(params,'maxDendLen') || isempty(params.maxDendLen) || isempty(params)
        mDlen = [];
    else
        mDlen      = params.maxDendLen;
    end
    if ~isfield(params,'maxNrBranchPts') || isempty(params.maxNrBranchPts) || isempty(params)
        mNBr = [];
    else
        mNBr      = params.maxNrBranchPts;
    end
end
% if Npts is smaller than the required number of branch points increase
% Npts to a sufficient number
if ~isempty(mNBr) && Npts <= ceil(mNBr*1.5)
    Npts = ceil(mNBr*1.8);
end

%% Begin repair
%% distribute carrier points using monte carlo in pp_generator_tree
ClustP = [];
selectNPts = Npts;
OutData.selectNPts = selectNPts;

% get first set of points with monte carlo (2D or 3D) in 200x200x200 cube
if sum(Vol.Pts(:,3)) == 0
    Npts = ceil(Npts/(xsidelen*ysidelen));
    if Npts < 4
       Npts = 4; 
    end
    ClustP = PP_generator_tree (Npts, R, [], [], 10, [], [], '-2d');
    ClustP(:,3) = zeros(size(ClustP,1),1);
else
    Npts = ceil(Npts/(xsidelen*ysidelen*zsidelen));
    if Npts < 4
       Npts = 4; 
    end
    ClustP = PP_generator_tree (Npts, R, [], [], 10, [], [], '-3d');
end
saveClustP = ClustP;

% cube of points needs to be expanded for larger volumes
% first create a set of point cubes that are all different
mixedupCu{1} = saveClustP;
mixedupCu{2} = [-saveClustP(:,1),saveClustP(:,2),saveClustP(:,3)];
mixedupCu{3} = [saveClustP(:,1),-saveClustP(:,2),saveClustP(:,3)];
mixedupCu{4} = [-saveClustP(:,1),-saveClustP(:,2),saveClustP(:,3)];
mixedupCu{5} = [-saveClustP(:,1),saveClustP(:,2),-saveClustP(:,3)];
mixedupCu{6} = [-saveClustP(:,1),-saveClustP(:,2),-saveClustP(:,3)];

% put cubes side by side until volume size and desired number of points is
% reached (shrink cubes to fit more next to each other until desired
% number of points is reached)
NInVolP = 0; shrinkfac = 1;
while NInVolP < selectNPts
    disp(strcat("Loop shrink ",num2str(shrinkfac)));
    xsidelen = ceil(abs(extX(1)-extX(2))/(200/shrinkfac));
    ysidelen = ceil(abs(extY(1)-extY(2))/(200/shrinkfac));
    zsidelen = ceil(abs(extZ(1)-extZ(2))/(200/shrinkfac));
    FirstCube = saveClustP/shrinkfac;
    FirstCube(:,1) = FirstCube(:,1)+(100/shrinkfac);
    FirstCube(:,2) = FirstCube(:,2)+(100/shrinkfac);
    FirstCube(:,3) = FirstCube(:,3)+(100/shrinkfac);
    CatPTS = [];
    for kk = 1:xsidelen
        %                 tempCube = FirstCube;
        tempCube = mixedupCu{randi([1 6])}/shrinkfac;
        tempCube(:,1) = tempCube(:,1)+(100/shrinkfac);
        tempCube(:,2) = tempCube(:,2)+(100/shrinkfac);
        tempCube(:,3) = tempCube(:,3)+(100/shrinkfac);
        tempCube(:,1) = tempCube(:,1)+((200/shrinkfac)*(kk-1));
        CatPTS = [CatPTS;tempCube];
    end
    InterPTS = CatPTS;

    for kk = 1:ysidelen
        tempCube = InterPTS;
        %                 tempCube = InterPTS{randi([1 4])};
        tempCube(:,2) = tempCube(:,2)+((200/shrinkfac)*(kk-1));
        if kk > 1
            CatPTS = [CatPTS;tempCube];
        end
    end
    InterPTS = CatPTS;
    for kk = 1:zsidelen
        tempCube = InterPTS;
        tempCube(:,3) = tempCube(:,3)+((200/shrinkfac)*(kk-1));
        if kk > 1
            CatPTS = [CatPTS;tempCube];
        end
    end
    clear vars InterPTS;
    CatPTS(:,1) = CatPTS(:,1)-mean(CatPTS(:,1));
    CatPTS(:,2) = CatPTS(:,2)-mean(CatPTS(:,2));
    CatPTS(:,3) = CatPTS(:,3)-mean(CatPTS(:,3));
    % shift distributed points into place (into selected volume)
    difftomax(1) = extX(1)-max(CatPTS(:,1));
    difftomax(2) = extY(1)-max(CatPTS(:,2));
    difftomax(3) = extZ(1)-max(CatPTS(:,3));
    CatPTS(:,1) = CatPTS(:,1)+difftomax(1);
    CatPTS(:,2) = CatPTS(:,2)+difftomax(2);
    CatPTS(:,3) = CatPTS(:,3)+difftomax(3);
    ClustP = CatPTS;
    
    % this distributes just random points
    %             XrandC = (max(Vol.Pts(:,1))-min(Vol.Pts(:,1))).*rand(Npts,1) + min(Vol.Pts(:,1));
    %             YrandC = (max(Vol.Pts(:,2))-min(Vol.Pts(:,2))).*rand(Npts,1) + min(Vol.Pts(:,2));
    %             ZrandC = (max(Vol.Pts(:,3))-min(Vol.Pts(:,3))).*rand(Npts,1) + min(Vol.Pts(:,3));
    %             ClustP(:,1) = XrandC; ClustP(:,2) = YrandC; ClustP(:,3) = ZrandC;
    % jitter points
    % slightly randomize points to break any patterns
    movedperc = 0.7;
    wiggleroom = 0.6;%0.3;
%     randupPts = 1-wiggleroom+(2*wiggleroom)*rand(size(ClustP,1),3);
%     temprand = [randupPts(:,1);randupPts(:,2);randupPts(:,3)];
%     quickranI = randperm(size(ClustP,1)*size(ClustP,2));
%     quickranI(ceil((size(ClustP,1)*size(ClustP,2))*(1-movedperc)):end) = [];
%     temprand(quickranI) = 1;
%     randupPts(:,1) = temprand(1:size(ClustP,1));
%     randupPts(:,2) = temprand(size(ClustP,1)+1:2*size(ClustP,1));
%     randupPts(:,3) = temprand(2*size(ClustP,1)+1:3*size(ClustP,1));
    % shuffles points
    ClustP = ClustP(randperm(size(ClustP,1)),:);
    notmove = 0;
    GetExt = ceil(abs(extX(1)-extX(2)));
    GetExt2 = ceil(abs(extY(1)-extY(2)));
    GetExt3 = ceil(abs(extZ(1)-extZ(2)));
    movedistt = max([GetExt,GetExt2,GetExt3]);
    Rwiggle = rand(size(ClustP,1),3);
    Rwiggle(randperm(ceil(size(ClustP,1)*notmove)),:) = 0;
%     Rwiggle(randi(size(ClustP,1),[ceil(size(ClustP,1)*notmove),1]),:) = 0;
    ClustP = ClustP+Rwiggle*(movedistt*wiggleroom);
    
    % find valid points that lie within the specified volume
    OutData.ClustPCheck = ClustP;
    polyshape.faces     = VolBound;
    polyshape.vertices  = Vol.Pts;
    if sum(Vol.Pts(:,3)) == 0
        yes = inpolygon(ClustP(:,1),ClustP(:,2),Vol.Pts(:,1),Vol.Pts(:,2));
    else
        yes = inpolyhedron(polyshape,ClustP);
    end
    validVolPts = [];
    validVolPts(:,1) = ClustP(yes,1);
    validVolPts(:,2) = ClustP(yes,2);
    validVolPts(:,3) = ClustP(yes,3);
    
    NInVolP = length(validVolPts);
    shrinkfac = shrinkfac+1;
end
% get rid of any excess points to match desired number of points
if NInVolP > selectNPts
    elimInd = randperm(NInVolP,NInVolP-selectNPts);
    validVolPts(elimInd,:) = [];
end

%% Incomplete growth only or not! (Choice)
disp(strcat("Cut growth check value is ",num2str(logical(cut_growth))));
CutGrowth = logical(cut_growth);
% enalbe main branch growth (choice) for pyramidal apical growth (can only
% be enabled while incomplete growth is active as well!!!)
disp(strcat("Main growth check value is ",num2str(logical(mainBr_growth))));
MainGrowth = logical(mainBr_growth);

% add code for deleting carrier points that are to close to the severed
% stem in case of biological regrowth. The incomplete terminal of the 
% severed end must be specified in the morphology for this to work. Add
% option in function for this feature.
if ~CutGrowth && isfield(BaseTree,'IncompleteTerminals') && contains(options,'-V')
% % if ~CutGrowth && contains(options,'-V')    
    if size(BaseTree.IncompleteTerminals,1) > 1
       error('more than one severed stem was defined in IncompleteTerminals'); 
    end
    DistVoltoTree = squareform(pdist([validVolPts;BaseTree.X,BaseTree.Y,BaseTree.Z]));
    DistVoltoTree = DistVoltoTree(size(validVolPts,1)+1:end,1:size(validVolPts,1));
    MeanDisttoTree = mean(mean(DistVoltoTree));
    BaseTree.FormerIncTerms = BaseTree.IncompleteTerminals;
    
    CptsRmInd = [];
    for NtreePts = 1:length(BaseTree.R)
        DistToStem = squareform(pdist([BaseTree.X(NtreePts),BaseTree.Y(NtreePts),...
            BaseTree.Z(NtreePts);validVolPts]));
        FirstRow = DistToStem(1,:);
        FirstRow(1) = [];
        CptsRmInd = [CptsRmInd,find(FirstRow < RmPts_Dist)];
    end
    validVolPts(CptsRmInd,:) = [];
    
%     DistToStem = squareform(pdist([BaseTree.IncompleteTerminals;validVolPts]));
%     FirstRow = DistToStem(1,:);
%     FirstRow(1) = [];
%     getfac = MeanDisttoTree/30;
%     validVolPts(find(FirstRow < RmPts_Dist),:) = []; 
    BaseTree = rmfield(BaseTree,'IncompleteTerminals');  
    FinalInfoStr = strcat(FinalInfoStr,'\n','(-V active) Points in the growth volume that are to close to the tree are being removed');
end

% determine incomplete terminals (must be specified in morphology struct as
% field 'IncompleteTerminals')!!!!!
InComI = [];
if ~isfield(BaseTree,'IncompleteTerminals')
    InComI = find(T_tree(BaseTree) == 1);
else
    % distance of Incomplete Terminals to the volume to discard the
    % Terminals that are too far away
    sizeT = max(pdist([BaseTree.X,BaseTree.Y,BaseTree.Z]));
    randfillPt = [];
    randfillPt(:,1) = extX(2) + (extX(1)-extX(2)) .* rand(10000,1);
    randfillPt(:,2) = extY(2) + (extY(1)-extY(2)) .* rand(10000,1);
    randfillPt(:,3) = extZ(2) + (extZ(1)-extZ(2)) .* rand(10000,1);
    if sum(Vol.Pts(:,3)) == 0
        InnPt = inpolygon(randfillPt(:,1),randfillPt(:,2),Vol.Pts(:,1),Vol.Pts(:,2));
        randfillPt(:,3) = zeros(size(randfillPt,1),1);
    else
        InnPt = inpolyhedron(polyshape,randfillPt);
    end
    randfillPt = randfillPt(InnPt,:);
    ToAlldist = squareform(pdist([BaseTree.IncompleteTerminals;randfillPt]));
    DistToVol = min(ToAlldist(size(BaseTree.IncompleteTerminals,1)+1:end,...
        1:size(BaseTree.IncompleteTerminals,1)));
    closeTerms = find(DistToVol <= min(DistToVol)+(sizeT/9));
    
    for ff = 1:length(BaseTree.IncompleteTerminals(:,1))
        tempINCOMP = find(BaseTree.X == BaseTree.IncompleteTerminals(ff,1) &...
            BaseTree.Y == BaseTree.IncompleteTerminals(ff,2) &...
            BaseTree.Z == BaseTree.IncompleteTerminals(ff,3));
        if ismember(ff,closeTerms)
            InComI = [InComI,tempINCOMP];
        end
    end
end
if isempty(InComI)
    disp('The coordinates for incomplete terminals specified in your ');
    disp('morphology do not match any coordinates on the morphology or ');
    disp('are not in close vicinity of the selected volume');
    error('No incomplete terminals found');
end

if isfield(InTree,'AddedMain')
    InTree = rmfield(InTree,'AddedMain');
end

% if enabled this grows a main dendrite first from the thickest cut branch
% (watch out when passing params only equal to 1 for first
% volume when using the GUI)!!!!
if MainGrowth && CutGrowth && isfield(BaseTree,'IncompleteTerminals')
    % get points for main dend and creat DIST for right connection
    % determine how many thick branches there are with 'main_thickratio'
    % parameter to decide how many main dendrites to grow
    [MaxDia,thickbrI] = max(BaseTree.D(InComI));
    allMaininds = find(BaseTree.D(InComI) > MaxDia*main_thickratio);
    newBaseTree = BaseTree;
    newBaseTree.AddedMain = [];
    
    % add main apical dendrites using straigth lines
    for addMct = 1:length(allMaininds)
        connPt(1) = BaseTree.X(InComI(allMaininds(addMct)));
        connPt(2) = BaseTree.Y(InComI(allMaininds(addMct)));
        connPt(3) = BaseTree.Z(InComI(allMaininds(addMct)));
        distvec = INlinePts(1,:)-connPt;
        tempLinePts = INlinePts;
        tempLinePts = tempLinePts-distvec;
        if sum(Vol.Pts(:,3)) == 0
            gdLpt = inpolygon(tempLinePts(:,1),tempLinePts(:,2),Vol.Pts(:,1),Vol.Pts(:,2));
        else
            gdLpt = inpolyhedron(polyshape,tempLinePts);
        end
        tempLinePts = tempLinePts(gdLpt,:);
        mainendpt = ceil(length(tempLinePts)*0.98);
        MainDIST = zeros(length(BaseTree.R)+1);
        MainDIST(InComI(allMaininds(addMct)),length(BaseTree.R)+1) = 1000;
        MainDIST = sparse(MainDIST);
        % add section using MST_tree
        temptree{addMct} = MST_tree ({InTree},tempLinePts(mainendpt,1), ...
            tempLinePts(mainendpt,2),...
            tempLinePts(mainendpt,3),...
            bfapical, Inf,[],MainDIST,...
            '-b -c');
        
        % resample added section and reconnect to tree
        getrid = 1:1:length(BaseTree.R);
        keepTerm = InComI(allMaininds(addMct));
        getrid(InComI(allMaininds(addMct))) = [];
        addedsect{addMct} = delete_tree(temptree{addMct},getrid);
        % smooth transition between original tree and added main apical
        % dendrite curving the straight line
        addedsect{addMct} = resample_tree(addedsect{addMct},20);
        addedsect{addMct} = delete_tree(addedsect{addMct},1);
        getpar = idpar_tree(BaseTree);
        firstpar = keepTerm;
        parnodes = firstpar;
        for parct = 1:20
            parnodes = [parnodes,getpar(firstpar)];
            firstpar = getpar(firstpar);
        end
        FitPts = [];
        FitPts(:,1) = [BaseTree.X(parnodes(end));BaseTree.X(parnodes(1));addedsect{addMct}.X];
        FitPts(:,2) = [BaseTree.Y(parnodes(end));BaseTree.Y(parnodes(1));addedsect{addMct}.Y];
        FitPts(:,3) = [BaseTree.Z(parnodes(end));BaseTree.Z(parnodes(1));addedsect{addMct}.Z];
        for ptct = 1:size(FitPts,1)-2
            convector(1) = FitPts(ptct+1,1)-FitPts(ptct,1);
            convector(2) = FitPts(ptct+1,2)-FitPts(ptct,2);
            convector(3) = FitPts(ptct+1,3)-FitPts(ptct,3);
            convector2(1) = FitPts(ptct+2,1)-FitPts(ptct+1,1);
            convector2(2) = FitPts(ptct+2,2)-FitPts(ptct+1,2);
            convector2(3) = FitPts(ptct+2,3)-FitPts(ptct+1,3);
            convector = convector/norm(convector);
            norm2 = norm(convector2);
            if norm2 > 40
                norm2 = 20;
            end
            checkpt(1) = FitPts(ptct+1,1)+(convector(1)*(norm2));
            checkpt(2) = FitPts(ptct+1,2)+(convector(2)*(norm2));
            checkpt(3) = FitPts(ptct+1,3)+(convector(3)*(norm2));
            countervec(1) = FitPts(end,1)-checkpt(1);
            countervec(2) = FitPts(end,2)-checkpt(2);
            countervec(3) = FitPts(end,3)-checkpt(3);
            countervec = countervec/norm(countervec);
            FitPts(ptct+2,1) = FitPts(ptct+1,1)+((convector(1)+(countervec(1)*0.3))*(norm2));
            FitPts(ptct+2,2) = FitPts(ptct+1,2)+((convector(2)+(countervec(2)*0.3))*(norm2));
            FitPts(ptct+2,3) = FitPts(ptct+1,3)+((convector(3)+(countervec(3)*0.3))*(norm2));
        end
        % kick all points that are outside the volume
        CheckFitPts = [];
        CheckFitPts(:,1) = FitPts(3:end,1);
        CheckFitPts(:,2) = FitPts(3:end,2);
        CheckFitPts(:,3) = FitPts(3:end,3);
        polyshape.faces     = VolBound;
        polyshape.vertices  = Vol.Pts;
        if sum(Vol.Pts(:,3)) == 0
            goodInds = ~inpolygon(CheckFitPts(:,1),CheckFitPts(:,2),Vol.Pts(:,1),Vol.Pts(:,2));
        else
            goodInds = ~inpolyhedron(polyshape,CheckFitPts);
        end
        addedsect{addMct}.X = CheckFitPts(:,1);
        addedsect{addMct}.Y = CheckFitPts(:,2);
        addedsect{addMct}.Z = CheckFitPts(:,3);
        addedsect{addMct}   = delete_tree(addedsect{addMct},find(goodInds == 1));
        addedsect{addMct} = resample_tree(addedsect{addMct},2);
        
        % connect new dendrite to original tree
        eudistCH = [];
        for gg = 1:length(addedsect{addMct}.R)
            eudistCH(gg) = norm([BaseTree.X(InComI(allMaininds(addMct)))-addedsect{addMct}.X(gg),...
                BaseTree.Y(InComI(allMaininds(addMct)))-addedsect{addMct}.Y(gg),...
                BaseTree.Z(InComI(allMaininds(addMct)))-addedsect{addMct}.Z(gg)]);
        end
        [~,connInd(addMct)] = min(eudistCH);
        topmat = [newBaseTree.dA,zeros(length(newBaseTree.R),length(addedsect{addMct}.R))];
        botmat = [zeros(length(addedsect{addMct}.R),length(newBaseTree.R)),addedsect{addMct}.dA];
        newBaseTree.dA = [topmat;botmat];
        
%         newBaseTree.dA(length(BaseTree.R)+connInd(addMct),InComI(thickbrI)) = 1;%!!!
        newBaseTree.X = [newBaseTree.X;addedsect{addMct}.X];
        newBaseTree.Y = [newBaseTree.Y;addedsect{addMct}.Y];
        newBaseTree.Z = [newBaseTree.Z;addedsect{addMct}.Z];
        newBaseTree.D = [newBaseTree.D;addedsect{addMct}.D];
        newBaseTree.R = [newBaseTree.R;addedsect{addMct}.R];
        % eliminate cut terminal point
        termUsed = find(newBaseTree.IncompleteTerminals(:,1) == newBaseTree.X(InComI(allMaininds(addMct))) &...
            newBaseTree.IncompleteTerminals(:,2) == newBaseTree.Y(InComI(allMaininds(addMct))) &...
            newBaseTree.IncompleteTerminals(:,3) == newBaseTree.Z(InComI(allMaininds(addMct))));
        newBaseTree.IncompleteTerminals(termUsed,:) = [];
        
    end
    % add main dendrite to incomplete terminals so new dendrites can grow
    % from it
    newBaseTree.AddedMain = length(BaseTree.R)+1:1:length(newBaseTree.R);
    InComI = [InComI,newBaseTree.AddedMain];
    % use saveMConn to later reconnect
    saveMConn = InComI(allMaininds);
    InComI(allMaininds) = [];
    InTree = newBaseTree;
else
    disp('Please enable "Cutgrowth" and add IncompleteTerminals to your morphology');
    disp('MainGrowth was NOT carried out');
end
OutData.InComI = InComI;

% continue with cutgrowth by creating DIST matrix
if CutGrowth && isfield(BaseTree,'IncompleteTerminals')
    EndNnode = length(InTree.X);
    NewNrnodes = length(validVolPts);
    NDIST = EndNnode+NewNrnodes;
    NewNodes = [];
    parentNodes = [];
    conprobs = [];
    for ff = 1:NewNrnodes
        tempSameI = ones(1,NewNrnodes-1)*(EndNnode+ff);
        tempDiffI = EndNnode+1:1:NDIST;
        tempDiffI(find(tempDiffI == (EndNnode+ff))) = [];
        parentNodes = [parentNodes,tempSameI];
        NewNodes = [NewNodes,tempDiffI];
    end
    conprobs = ones(1,length(parentNodes))*1000;
    for ff = 1:length(InComI)
        tempSameI = ones(1,NewNrnodes)*InComI(ff);
        tempDiffI = EndNnode+1:1:NDIST;
        parentNodes = [parentNodes,tempSameI];
        NewNodes = [NewNodes,tempDiffI];
    end
    conprobs = [conprobs,ones(1,length(InComI)*NewNrnodes)*1000];
    DIST = sparse(parentNodes,NewNodes,conprobs,NDIST,NDIST);
    DIST(DIST > 1000) = 1000;
else
    disp('You have not specified any incomplete terminal in your tree structure');
    disp('or checked the cut growth box therefore grwoth from all branches is enabled');
    DIST = [];
end

%         figure;
%         imagesc(DIST);

% grow repair sections using MST_tree

% run MST_tree with subsequently increasing number of carrier points until
% desired number of branch points is reached
if ~isempty(mNBr) && contains(options,'-B')
    FinalInfoStr = strcat(FinalInfoStr,'\n','(-B active) Nr. of branch points are being matched to RefTree or input');
    MaxNBr = mNBr;
    neededNBr = mNBr-sum(B_tree(InTree));
    validVolPts_save = validVolPts;
    DIST_save = DIST;
    curRepmNBr = 0;
    carrieradd = 0;
    breakctr = 0;
    breakctr2 = 0;
    while curRepmNBr ~= MaxNBr
        breakctr2 = breakctr2+1;
        validVolPts = validVolPts_save;
        DIST = DIST_save;
        delnumber = size(validVolPts,1)-(2*neededNBr)-carrieradd;
        if delnumber <= 0
            disp('insuficient number of carrier points to match Nr. of branch points!');
            disp('please increase params.NPts_User');
            error('not enough carrier points to match Nr. of branch points!');
            break;
        end
        if ~isempty(DIST)
            DIST(size(DIST,1)-delnumber+1:end,:) = [];
            DIST(:,size(DIST,2)-delnumber+1:end) = [];
        end
        for ptdelctr = 1:delnumber
            validVolPts(randi(size(validVolPts,1)),:) = [];
        end
        if CutGrowth
            RepTree = MST_tree ({InTree},...
                validVolPts(:,1),...
                validVolPts(:,2),...
                validVolPts(:,3),...
                bfapical, growThr,[],DIST, ...
                '-b -c');%mNBr,mDlen,'-b');
        else
            RepTree = MST_tree ({InTree},...
                validVolPts(:,1),...
                validVolPts(:,2),...
                validVolPts(:,3),...
                bfapical, growThr,[],DIST, ...
                '-b');%mNBr,mDlen,'-b');
        end
        curRepmNBr = sum(B_tree(RepTree));
        carrieradd = carrieradd+ceil((mNBr-curRepmNBr)*0.4);
        if curRepmNBr >= MaxNBr-3 && curRepmNBr <= MaxNBr+3
            breakctr = breakctr+1;
        end
        if breakctr > 3
            break;
        end
        if breakctr2 > 10000
            break;
        end
    end
else
    FinalInfoStr = strcat(FinalInfoStr,'\n','(-B not active) Nr. of branch points depends on Nr. of carrier points');
    % just grow with the number of points specified
    if CutGrowth
        RepTree = MST_tree ({InTree},...
            validVolPts(:,1),...
            validVolPts(:,2),...
            validVolPts(:,3),...
            bfapical, growThr,[],DIST,...
            '-b -c');%mNBr,mDlen,'-b');
    else
        RepTree = MST_tree ({InTree},...
            validVolPts(:,1),...
            validVolPts(:,2),...
            validVolPts(:,3),...
            bfapical, growThr,[],DIST,...
            '-b');%mNBr,mDlen,'-b');
    end
end
OutData.VolPtsCheck = validVolPts;
%         % growth tree variation
%         voltreestruct.X = Vol.Pts(:,1); voltreestruct.Y = Vol.Pts(:,2); voltreestruct.Z = Vol.Pts(:,3);
%         growth_out      = growth_treeGen2(voltreestruct,...
%                                           InTree, mDlen, bfapical,...
%                                           growThr, 0.9, Vol.alpha,...
%                                           [], [], '-L',0);
%         RepTree = growth_out{end};

% connect main dendrite if existing to original tree
if MainGrowth && CutGrowth && isfield(BaseTree,'IncompleteTerminals')
    addindices = 0;
    for addMct = 1:length(allMaininds)
        if addMct == 1
        else
            addindices = addindices+length(addedsect{addMct-1}.R);
        end
        RepTree.dA(length(BaseTree.R)+addindices+connInd(addMct),saveMConn(addMct)) = 1;
    end
    %         RepTree.dA(length(BaseTree.R)+connInd,saveMConn) = 1;
end

% assign correct regional indices to new dendrites
[NEsect,NEvec] = dissect_tree(RepTree);
NPartNodesI = length(InTree.R)+1:1:length(RepTree.R);
somaInd = InTree.R(find(InTree.D == max(InTree.D)));
for ctz = 1:length(NPartNodesI)
    segInd = NEvec(NPartNodesI(ctz),1);
    Indupdate = RepTree.R(NEsect(segInd,1));
    if Indupdate == somaInd
    else
        RepTree.R(NPartNodesI(ctz)) = Indupdate;
    end
end
OutData.RepTreeIter = RepTree;

%% Edit final repaired tree
if contains(options,'-Re')
    % find nodes of new tree after tree is resampled
    % resampling changes the nodes and adds new ones
    FinalInfoStr = strcat(FinalInfoStr,'\n','(-Re active) Final tree editing is engaged');
    ReptreeNoEdit = RepTree;
    % prune before resampling
    % 0 = TP, 1 = CP, 2 = BP :
    typeN = (ones (1, size (RepTree.dA, 1)) * RepTree.dA)';
    termptsAPtree = find(typeN == 0);
    [prsect prvec] = dissect_tree(RepTree);
    lenAPtree = len_tree(RepTree);
    FixTfinalI = length(BaseTree.X);
    NewNodesInd = FixTfinalI+1:1:length(RepTree.X);
    allsegnodes = [];
    prunInd = [];
    PrunedNodeMem = [];
    % prune repaired section of tree if prunelength is specified
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
        RepTree = delete_tree(RepTree,prunInd);
    end
    % save former incomplete terminals to morphology
    if isfield(RepTree,'IncompleteTerminals')
        RepTree.FormerIncTerms = RepTree.IncompleteTerminals;
        RepTree.IncompleteTerminals = [];
        RepTree.IncompleteTerminals(:,1) = RepTree.X(InComI);
        RepTree.IncompleteTerminals(:,2) = RepTree.Y(InComI);
        RepTree.IncompleteTerminals(:,3) = RepTree.Z(InComI);
    end
%     RepTree = elimt_tree(RepTree);
%     RepTree = resample_tree(RepTree, resample_rate,'-r');
    % get new part
    TrueInd = find(RepTree.D == 1);
    % resample new part of tree
    LRtree = len_tree(RepTree);
    PRtree = idpar_tree(RepTree);
    
    for Resct = 1:length(TrueInd)
        CurLen = LRtree(TrueInd(Resct));
        if CurLen <= resample_rate
            continue;
        end
        CurPar = PRtree(TrueInd(Resct));
        CurPts = [RepTree.X(CurPar),RepTree.Y(CurPar),RepTree.Z(CurPar);...
            RepTree.X(TrueInd(Resct)),RepTree.Y(TrueInd(Resct)),RepTree.Z(TrueInd(Resct))];
        
        facRes = CurLen/resample_rate;
        vecRes = [-CurPts(1,1)+CurPts(2,1),...
            -CurPts(1,2)+CurPts(2,2),...
            -CurPts(1,3)+CurPts(2,3)];
        
        ReAddPt = [];
        for tt = 1:floor(facRes)-1
            ReAddPt = [CurPts(1,1)+((vecRes(:,1)/floor(facRes))*tt),...
                CurPts(1,2)+((vecRes(:,2)/floor(facRes))*tt),...
                CurPts(1,3)+((vecRes(:,3)/floor(facRes))*tt)];
            RepTree.X(end+1)    = ReAddPt(1);
            RepTree.Y(end+1)    = ReAddPt(2);
            RepTree.Z(end+1)    = ReAddPt(3);
            RepTree.D(end+1)    = 1;
            RepTree.R(end+1)    = RepTree.R(CurPar);
            % add row and column
            RepTree.dA(end+1,end+1)   = 0;
            % remove existing connection
            RepTree.dA(TrueInd(Resct),CurPar) = 0;
            % establish new connection
            RepTree.dA(end,CurPar)              = 1;
            RepTree.dA(TrueInd(Resct),end)      = 1;
            CurPar = length(RepTree.X);
            TrueInd = [TrueInd;length(RepTree.R)];
        end
    end
    %         figure;
    %         hold on;
    %         plot_tree(RepTree); shine
    %         scatter3(RepTree.X(TrueInd),...
    %                  RepTree.Y(TrueInd),...
    %                  RepTree.Z(TrueInd),'filled','r');
    % now jitter and smooth
    HypoTree = RepTree;
    if ~contains(options,'-J')
        FinalInfoStr = strcat(FinalInfoStr,'\n','(-J not active) Tree is being jittered');
        HypoTree = jitter_tree(HypoTree,jitter_stde,jitter_lambda,'none');
    end
    if ~contains(options,'-S')
        FinalInfoStr = strcat(FinalInfoStr,'\n','(-S not active) Tree is being smoothed');
        HypoTree = smooth_tree(HypoTree, 0.5, 0.9, 10,'none');
    end
    RepTree.X(TrueInd) = HypoTree.X(TrueInd);
    RepTree.Y(TrueInd) = HypoTree.Y(TrueInd);
    RepTree.Z(TrueInd) = HypoTree.Z(TrueInd);
    % smooth hard corners by rounding them over
    changetree = RepTree;
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
    RepTree.X(TrueInd) = changetree.X(TrueInd);
    RepTree.Y(TrueInd) = changetree.Y(TrueInd);
    RepTree.Z(TrueInd) = changetree.Z(TrueInd);
    
    % prune to exact size if specified by user
    VolPolyshape{1} = polyshape;
    if isempty(mNBr) && isempty(mDlen)
    elseif contains(options,'-L')
        FinalInfoStr = strcat(FinalInfoStr,'\n','(-L active) Tree is being pruned');
        [RepTree,TrueInd] = finetune_fix_tree (BaseTree,RepTree,bfapical,TrueInd,VolPolyshape,mNBr,mDlen);
    end
    
    % taper tree here using quaddiameter_tree
    if ~contains(options,'->')
        FinalInfoStr = strcat(FinalInfoStr,'\n','(-T not active) Tree is being tapered');
        getparent = idpar_tree(RepTree);
        NewParents = getparent(TrueInd);
        ConParents = NewParents(find(~ismember(NewParents,TrueInd) == 1));
        ConParents = unique(ConParents);
        HypoTree = quaddiameter_tree (RepTree,colapictaper_scale,... %colapictaper_scale
            colapictaper_offset);   %,[],[],[],taperthreshold(1);
        quadp_ind = find(HypoTree.D < taperthreshold);
        HypoTree.D(quadp_ind) = taperthreshold;
        RepTree.D(TrueInd) = HypoTree.D(TrueInd);
        % smooth taper transition between original tree and new dendrites
        if ~contains(options,'-Str')
            FinalInfoStr = strcat(FinalInfoStr,'\n','(-Str & -T not active) Tree taper transition between old and new branches is being smoothed');
            DiaChInds = [];
            NewDias = [];
            for parct = 1:length(ConParents)
                DiaChInds = [DiaChInds;find(getparent == ConParents(parct))];
                currTind = find(getparent == ConParents(parct));
                for chilind = 1:length(currTind)
                    if RepTree.D(ConParents(parct)) > RepTree.D(currTind(chilind))
                        NewDias = [NewDias,...
                            RepTree.D(currTind(chilind))+...
                            abs(RepTree.D(ConParents(parct))-RepTree.D(currTind(chilind)))*0.6];
                    elseif RepTree.D(ConParents(parct)) < RepTree.D(currTind(chilind))
                        NewDias = [NewDias,...
                            RepTree.D(currTind(chilind))-...
                            abs(RepTree.D(ConParents(parct))-RepTree.D(currTind(chilind)))*0.6];
                    else
                        NewDias = [NewDias,RepTree.D(ConParents(parct))];
                    end
                end
            end
            RepTree.D(DiaChInds) = NewDias;
        end
    end
    RepTree.RepInds = TrueInd;
    if contains(options,'-M')
        FinalInfoStr = strcat(FinalInfoStr,'\n','(-M active) Repair is being plotted');
        figure; hold on;
        plot_tree(RepTree);
        scatter3(RepTree.X(RepTree.RepInds),...
            RepTree.Y(RepTree.RepInds),...
            RepTree.Z(RepTree.RepInds),'filled','b');
    end
end

if contains(options,'-e')
    disp(sprintf(FinalInfoStr));
end

end

