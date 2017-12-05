% CGUI_TREE   User interface to try out TREES package functions.
% (trees package)
%
% cgui_tree (action)
% ------------------
%
% launches a GUI to handle trees. The GUI is segregated in multiple panel
% areas which are handled pretty much separately. These are:
% from top to bottom on the left, editor panels:
% stk_:     everything related to image stacks containing dendrite trees
% thr_:     binary (thresholded) image stacks
% skl_:     carrier points from the images for the trees (skeletonization)
% mtr_:     constructing trees in various ways (also fully automatic reconstr.)
%           and - manual editing of the trees
% ged_:     orientation and positioning of a tree in a group
% from top to bottom on the right, visual panels:
% vis_:     figure and overall graphics
% cat_:     tree sorter
% plt_:     separate graphical elements and their handles
% slt_:     selection and statistics panel
% ele_:     electrotonic properties
% extras are (only available through the menu):
% ui_:      user interface related
% plx_:     outside plots
%
% to better read the code we recommend to fold the code on "switch" and
% "if" clauses. Really! It's worth it!
%
% typical action nomenclature is:
% no action: initialization
% _show:     activate or inactivate user interface elements for data structure
% _inform:   outputs information about data (e.g. stack size)
% _setxx:    actions repair links between edit fields and actual objects
% (for example cgui_tree ('ged_settran') updates the edits for tree root
% coordinates
% _rxx:      radio button toggling
% _image:    actions reconstruct the graph according to changes made
% (for example cgui_tree ('mtr_image') reconstructs the image of the active
% tree)
%
% initial user interface controls and figure setup is done in a separate
% function: "cgui_tree_initialize"
%
% at the end, keyboard and mouse actions are dealt with. keyboard shortcuts
% can be set in the separate function: "cgui_tree_keys"
%
% references in the code  comment to the corresponding TREES toolbox
% functions used are made in "double quotes" (for example : see "plot_tree")
%
% manual intervention is simple at the command window, just make cgui a
% global variable and access all the elements:
% global cgui                <= make cgui global
% plot_tree (cgui.mtr.tree)  <= plot the currently activated tree outside of
%                               the GUI
%
% USAGE:
% ------
% cgui_tree
%
% See also start_trees
%
% Uses pretty much everything
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function cgui_tree (action)

% special gui related global structure containing all handles and variables
global cgui

% if no action is defined initialize GUI (call "cgui_tree_initialize")
if (nargin<1) || isempty (action), % initialization
    action = 'initialize';
    % initializing the global variables of all panels
    
    % ui_         user interface related
    % matlab does not allow me to turn of "tab order" and "space
    % activation" of uicontrol elements, therefore "tab" and "space" have
    % unwanted effects.Same goes with the mouse: after usage of uicontrol
    % elements, click once on the axis to reactivate the mouse.
    cgui.ui.lHP =         {};   % edit and edit-select mode line handle
    cgui.ui.sHP =         {};   % edit and edit-select mode point handle
    cgui.ui.pHP =         {};   % edit and edit-select mode patch handle
    
    % vis_        visual control panel
    cgui.vis.cbar       = [];   % colorbar handle
    cgui.vis.res        =  8;   % cylinder plot resolution
    % z-index into matrix cgui.stk.M for displayed slice. It is also the z
    % value for the _vis grid and mtr_ manually added points:
    cgui.vis.iM         =  0;
    
    % cat_        tree sorter panel, cell arrays of trees etc...
    cgui.cat.trees      = {};   % cell array of trees - can have two layers of depth
    cgui.cat.itree      =  0;   % index to deep layer
    cgui.cat.i2tree     =  0;   % index to top layer
    cgui.cat.untrees    = {};   % undo trees, remembers all actions on an active tree
    cgui.cat.tautosave = timer('ExecutionMode','fixedRate','Period',60,'StartDelay',60,'StartFcn',@startasv,'TimerFcn',@autosave,'StopFcn',@deleteasv,'UserData',{userpath,'autosave.mtr',0});
    
    % plt_        plot panel, separate graphical elements and their handles
    cgui.plt.HPs        = {};   % cell array of handles for hulls and plots, etc...
    cgui.plt.sHPs       = {};   % names of created handles for example 'plot hsn'
    
    % slt_        select and branching parameter panel
    % vector containing names of possible parameter attributes
    cgui.slt.svec = {'none', 'BO - branch order', 'PL - path length', ...
        'LO - level order', 'EUCL - euclidean distances to root', ...
        'LEN - segment lengths', 'SURF - segment surfaces', ...
        'VOL - segment volumes', 'BANGL - branching angles at branch points',...
        'TYPEN - node type', 'Rindex - region index', 'R - region #', ...
        'B - branch points', 'T - termination points',...
        'BT - branch and termination points', 'C - continuation points', ...
        'D - diameters', 'RIN - local input resistances', ...
        'INJ - current injection','COMPUTED'};
    % vector containing names of possible index annotation attributes
    cgui.slt.sind = {'none','all', 'iB - branch points', ...
        'iT - termination points', 'iBT - branch and termination points', ...
        'iC - continuation points', 'iR - actual region', 'COMPUTED'};
    cgui.slt.cind = [];
    cgui.slt.cvec = [];
    
    % stk_       image stacks control panel
    cgui.stk.M =          {};   % image stacks in matrix form
    cgui.stk.sM =         {};   % names of stacks from file-name
    cgui.stk.mM1 =        {};   % maximum intensity projections xy for snap edit
    cgui.stk.mM2 =        {};   % maximum intensity projections xz for snap edit
    cgui.stk.mM3 =        {};   % maximum intensity projections yz for snap edit
    cgui.stk.imM1 =       {};   % indices of maximum in third dimension z
    cgui.stk.imM2 =       {};   % indices of maximum in third dimension y
    cgui.stk.imM3 =       {};   % indices of maximum in third dimension x
    cgui.stk.HP =         {};   % handles of tiled image stacks, one cell per stack
    cgui.stk.coord =      [];   % XYZ-coordinates of each stack
    cgui.stk.voxel = [1 1 1];   % voxel size (must be same for all stacks)
    cgui.stk.alpha =     0.5;   % stack presentation transparency (affects colorbar)
    % stk_       user-edit
    cgui.stk.active =     [];   % stack which is closest to the mouse cursor
    cgui.stk.distance =   [];   % distance between closest stack and cursor
    cgui.stk.selected =   [];   % Region Of Interest (ROI) polygon
    
    % thr_       thresholding control panel
    cgui.thr.BW =         {};   % thresholded image stacks in binary matrix form
    cgui.thr.HP =         {};   % handles of thresholded image representations
    % thr_       user-edit
    cgui.thr.active =     [];   % stack which is closest to the mouse cursor
    cgui.thr.distance =   [];   % distance between closest stack and cursor
    cgui.thr.radius =     10;   % box diameter for local threshold
    
    % skl_       skeletonization panel
    cgui.skl.I =          [];   % point coordinates of skeletonized points
    cgui.skl.BI =         [];   % brightness levels at those point coordinates
    cgui.skl.DI =         [];   % extracted diameter values from thresholded image there
    cgui.skl.CI =         [];   % coordinates within stack and stack number
    cgui.skl.LI =         [];   % floodfill labeling information
    cgui.skl.HPI =        [];   % handle to the plot representing the points (green points)
    cgui.skl.CN =         [];   % sparse connectivity matrix
    cgui.skl.dCN =        [];   % orientation similarity component of CN
    cgui.skl.tCN =        [];   % threshold floodfill connection component of CN
    cgui.skl.S =          [];   % starting points for growth algorithm
    cgui.skl.HPS =        [];   % handle to the starting points (red crosses)
    cgui.skl.HPCN =       [];   % handle to the patch plot representing the connectivity CN
    % skl_       user-edit
    cgui.skl.active =     [];   % soma which is closest to cursor
    cgui.skl.distance =   [];   % distance between closest soma and cursor
    
    % mtr_       tree creation panel
    cgui.mtr.tHP =        {};   % handle to plotted tree
    cgui.mtr.pHP =        {};   % handle to plotted nodes
    cgui.mtr.tree =       {};   % tree structure containing currently active tree
    % mtr_       user-edit
    cgui.mtr.plen =       [];   % vector to store the path length info
    cgui.mtr.active =     [];   % node which is closest to the cursor
    cgui.mtr.distance =   [];   % distance to closest node and cursor
    cgui.mtr.selected =   [];   % index to selected nodes
    cgui.mtr.selectstart = [];  % starting node for branch selection
    cgui.mtr.lastnode =   [];   % last activated node
    
    % ged_      global-edit panel
    cgui.ged.tHP =        {};   % handle to plots of other trees in group
    % ged_       user-edit
    cgui.ged.active =     [];   % tree which is closest to the cursor
    cgui.ged.distance =   [];   % distance from cursor to closest tree
    % Useful to set back the coordinates after spreading:
    cgui.ged.dd =         {};   % coordinates of spreading.
    
    % modes_     different modes of editing
    cgui.modes.view =      4;   % 1: xy,   2: xz,   3: yz,   4:xyz  views
    % this decides for which panel editing is active, starts with stacks:
    cgui.modes.panel =     1;   % 1: stk_, 2: thr_, 3: skl_, 4: mtr_, 5: ged_
    cgui.modes.select =    0;   % 0: off,  1: on
    cgui.modes.edit =      0;   % 0: off,  1: on
    cgui.modes.hold =      0;   % 0: off,  1: on
    
    % this can be changed by a different layout as long as the same
    % components exist:
    cgui_tree_initialize; % define full control panel/figure/menu etc.. layout
    
    cgui_tree ('ui_editorframe'); % set active editor frame
    cgui_tree ('vis_cla');        % start with initializing graphical elements
    set (cgui.vis.ui.txt1, 'string', {'load image stack', 'or tree to start'});
end

% ui_:      user interface related
% vis_:     figure and overall graphics
% plt_:     separate graphical elements and their handles
% slt_:     selection and statistics panel
% ele_:     electrotonics panel
% cat_:     tree sorter
% stk_:     relating to tiled image stacks containing neuronal tree images
% thr_:     binary (thresholded) image stacks
% skl_:     carrier points to build the trees (skeletonization)
% mtr_:     constructing trees in various ways (also fully automatic reconstr.)
%           and - manual editing of the trees
% plx_:     outside figure plots
switch action,      % respond to actions arranged by ui panels:
    case 'ui_close'             % quit the TREES toolbox GUI (only in menu)
        selection = questdlg ('Close TREES toolbox control center?',...
            'Close Request Function',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                delete (cgui.ui.F);
                if strcmp(get(cgui.cat.tautosave,'Running'),'on')
                    stop(cgui.cat.tautosave)
                end
        end
    case 'ui_save'              % save the entire TREES workspace (.tw1)
        % (.tw1 is the currently used format for cgui_tree)
        % save all about stacks:
        stk = []; stk.M = cgui.stk.M; stk.coord = cgui.stk.coord;
        stk.voxel = cgui.stk.voxel;   stk.sM = cgui.stk.sM;
        % save all about thresholds;
        thr = []; thr.BW = cgui.thr.BW;
        % save all about skeleton points:
        skl = []; skl.I = cgui.skl.I; skl.BI = cgui.skl.BI;
        skl.CI = cgui.skl.CI; skl.DI = cgui.skl.DI; skl.LI = cgui.skl.LI;
        skl.dCN = cgui.skl.dCN; skl.tCN = cgui.skl.tCN;
        skl.S = cgui.skl.S;
        % save all about trees:
        cgui_tree ('cat_update'); supercat.trees = cgui.cat.trees;
        [name path] = uiputfile ('.tw1', 'save workspace', 'workspace.tw1');
        if name ~= 0, % if a filename has been chosen
            % save the variables in a matlab workspace file, extension:
            % ".tw1"
            save ([path name], 'stk', 'thr', 'skl', 'supercat');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'saved workspace', name});
        end
        clear supercat;
    case 'ui_clear_all'         % clear the entire TREES workspace
        cgui_tree ('cat_clear_all'); % clear all trees
        % set back all edit fields in stk_:
        set (cgui.stk.ui.ed_tran1, 'string', '0'); % stack coordinates x
        set (cgui.stk.ui.ed_tran2, 'string', '0'); % stack coordinates y
        set (cgui.stk.ui.ed_tran3, 'string', '0'); % stack coordinates z
        set (cgui.stk.ui.ed_vox1,  'string', '1'); % voxel resolution  x
        set (cgui.stk.ui.ed_vox2,  'string', '1'); % voxel resolution  y
        set (cgui.stk.ui.ed_vox3,  'string', '1'); % voxel resolution  z
        cgui_tree ('stk_clear_all'); % clear all stacks
        % clear skeletonization variables:
        cgui.skl.I  = []; cgui.skl.BI  = []; cgui.skl.DI  = [];
        cgui.skl.LI = []; cgui.skl.CI  = [];
        cgui.skl.CN = []; cgui.skl.tCN = []; cgui.skl.dCN = [];
        cgui_tree ('skl_clear');     % clear soma locations
        cgui_tree ('vis_cla');       % redraw everything
        % inactivate all editor panels:
        cgui_tree ('stk_showpanels'); cgui_tree ('skl_showpanels');
        cgui_tree ('mtr_showpanels');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'cleared workspace'});
    case 'ui_load'              % load a previously saved TREES workspace (.tw1)
        % (.tw1 is the currently used format for cgui_tree)
        [name path] = uigetfile ('.tw1', 'load workspace', 'workspace.tw1');
        if (name ~= 0), % if a filename has been chosen
            data = load ([path name], '-mat');
            cgui_tree ('ui_clear_all'); % first clear the full workspace
            % read out data (see 'ui_save' action):
            stk = data.stk; thr = data.thr; skl = data.skl; supercat = data.supercat;
            % update stk_ panel:
            cgui.stk.M     = stk.M;     cgui.stk.sM    = stk.sM;
            cgui.stk.coord = stk.coord; cgui.stk.voxel = stk.voxel;
            % update popup field and edits with last stack which becomes
            % active:
            if ~isempty (cgui.stk.M),
                set (cgui.stk.ui.pop, 'string', cgui.stk.sM, 'value', length (cgui.stk.sM));
                % coordinates of active image stack:
                set (cgui.stk.ui.ed_tran1, 'string', num2str (cgui.stk.coord (end, 1)));
                set (cgui.stk.ui.ed_tran2, 'string', num2str (cgui.stk.coord (end, 2)));
                set (cgui.stk.ui.ed_tran3, 'string', num2str (cgui.stk.coord (end, 3)));
                % set a threshold corresponding to brightness values of stack:
                cgui_tree ('thr_setstd');
            end
            % voxel resolution of loaded stack:
            set (cgui.stk.ui.ed_vox1, 'string', num2str (cgui.stk.voxel (1)));
            set (cgui.stk.ui.ed_vox2, 'string', num2str (cgui.stk.voxel (2)));
            set (cgui.stk.ui.ed_vox3, 'string', num2str (cgui.stk.voxel (3)));
            cgui_tree ('stk_showpanels'); cgui_tree ('stk_inform');
            % same with thr_ and skl_
            cgui.thr.BW = thr.BW;
            % if there is a thresholded stack activate skl_ ui:
            cgui_tree ('skl_showpanels'); cgui_tree ('thr_inform');
            cgui.skl.I  = skl.I;  cgui.skl.BI = skl.BI; cgui.skl.S  = skl.S;
            cgui.skl.CI = skl.CI; cgui.skl.DI = skl.DI; cgui.skl.LI = skl.LI;
            skl.dCN = cgui.skl.dCN;
            skl.tCN = cgui.skl.tCN;
            cgui_tree ('skl_updateCN'); % calculate connectivity matrix
            % if there are skeletonized points activate mtr_ ui
            cgui_tree ('mtr_showpanels'); cgui_tree ('skl_inform');
            % update cat_ panel with new trees:
            incorporateloaded_tree (supercat.trees, 'tree'); clear supercat;
            cgui_tree ('stk_update'); % update stk_ maximum intensity projections
            cgui_tree ('stk_image');  % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image');  % redraw thr_ graphical output: thresholded stacks
            cgui_tree ('skl_image');  % redraw skl_ graphical output: skeletonized points
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'loaded workspace', name});
        end
        
    case 'ui_allvisible'        % set all panels to visible
        for te = 1 : length (cgui.ui.panels),
            str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
            for ward = 3 : length (str),
                set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'visible', 'on');
            end
        end
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'all UI elements visible'});
    case 'ui_allinvisible'      % set all panels to invisible
        for te = 1 : length (cgui.ui.panels),
            str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
            for ward = 3 : length (str),
                set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'visible', 'off');
            end
        end
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'all UI elements invisible'});
    case 'ui_editorsvisible'    % set editor panels to visible
        for te = 6 : length (cgui.ui.panels),
            str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
            for ward = 3 : length (str),
                set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'visible', 'on');
            end
        end
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'editor UI visible'});
    case 'ui_editorsinvisible'  % set editor panels to invisible
        for te = 6 : length (cgui.ui.panels),
            str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
            for ward = 3 : length (str),
                set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'visible', 'off');
            end
        end
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'editor UI invisible'});
    case 'ui_undock'            % undock control panels (not redockable)
        F = figure ('Name', 'TREES CONTROLS', 'NumberTitle', 'off', ...
            'DefaultLineLineWidth', 2, 'Visible', 'on', 'menubar', 'none', ...
            'units', 'normalized', 'paperorientation', 'landscape', ...
            'Position', [1-(.03+cgui.ui.xrel*2*3) 0 ...
            (.08+cgui.ui.xrel*2*3) 1-(.975-31.55*cgui.ui.yrel-.0225-0.01)], ...
            'color', cgui.NColor.background);
        set (cgui.stk.ui.r1, 'units','pixels'); set (cgui.ged.ui.b29, 'units', 'pixels');
        pos1 = get (cgui.stk.ui.r1,  'position'); pos1 = pos1 - 50; pos1 (2 : 4)   = 0;
        pos2 = get (cgui.ged.ui.b29, 'position'); pos2 = pos2 - 50; pos2 ([1 3 4]) = 0;
        for te = 1 : length (cgui.ui.panels),
            str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
            for ward = 3 : length (str),
                set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'units', 'pixels');
                set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'parent', F);
                set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'position', ...
                    get (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]),...
                    'position') - pos1 - pos2);
            end
        end
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'undocked all UI elements'});
        
    case 'ui_editoron'          % turn edit mode on (user interaction)
        cgui.modes.edit  =  1;                % edit mode on
        cgui.ui.selected = [];                % start with an empty selection
        set (cgui.ui.F, 'pointer', 'circle'); % change mouse cursor to "o"
        set (cgui.vis.ui.t1, 'value', 1);     % press down "edit" button in vis_panel
        if cgui.modes.select % the behaviour is different for selector mode
            switch cgui.modes.panel % ... and different for different panels
                case 1  % stk_panel edit select active
                    cgui_mouse_tree ([], [], 'mouse_stk_selector');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_stk_selector'});
                case 2  % thr_panel edit select active
                    cgui_mouse_tree ([], [], 'mouse_thr_selector');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_thr_selector'});
                case 3  % skl_panel edit select active
                    cgui_mouse_tree ([], [], 'mouse_skl_selector');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_skl_selector'});
                case 4  % mtr_panel edit select active
                    cgui_mouse_tree ([], [], 'mouse_mtr_selector');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_mtr_selector'});
                    cgui_tree ('mtr_image');
                case 5  % ged_panel edit select active
                    cgui_mouse_tree ([], [], 'mouse_ged_selector');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_ged_selector'});
            end
        else
            switch cgui.modes.panel % ... and again different for different panels
                case 1  % stk_panel edit active
                    cgui_mouse_tree ([], [], 'mouse_stk_editor');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_stk_editor'});
                case 2  % thr_panel edit active
                    cgui_mouse_tree ([], [], 'mouse_thr_editor');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_thr_editor'});
                case 3  % skl_panel edit active
                    cgui_mouse_tree ([], [], 'mouse_skl_editor');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_skl_editor'});
                case 4  % mtr_panel edit active
                    cgui_mouse_tree ([], [], 'mouse_mtr_editor');
                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_mtr_editor'});
                    cgui_tree ('mtr_image');
                case 5  % ged_panel edit active
                    cgui_mouse_tree ([], [], 'mouse_ged_editor');
                    set (cgui.ui.F,'WindowButtonMotionFcn', ...
                        {@cgui_mouse_tree, 'mouse_ged_editor'});
            end
        end
    case 'ui_editoroff'         % turn edit mode off (user interaction)
        cgui.modes.edit = 0;                  % edit mode off
        set (cgui.ui.F, 'pointer', 'arrow');  % change mouse cursor to arrow
        set (cgui.vis.ui.t1, 'value', 0);     % press up "edit" button in vis_panel
        cgui_tree ('ui_clean');               % rid editor and selector graphic handles
        if cgui.modes.select, % specific editor panel redraw
            switch cgui.modes.panel
                case 2
                    cgui_tree ('thr_image');  % redraw thr_ graphical output
                case 4
                    cgui_tree ('mtr_image');  % redraw mtr_ graphical output: active tree
            end
        else
            switch cgui.modes.panel
                case 2
                    cgui_tree ('thr_image');  % redraw thr_ graphical output
                case 4
                    cgui_tree ('mtr_image');  % redraw mtr_ graphical output: active tree
            end
        end
        set (cgui.ui.F, 'WindowButtonMotionFcn', ''); % inactive mouse motion callback
    case 'ui_clean'             % rid editor and selector graphic handles
        if ~isempty (cgui.ui.lHP), % delete handle to dotted line in editor mode
            delete (cgui.ui.lHP); cgui.ui.lHP = {};
        end
        if ~isempty (cgui.ui.sHP), % delete handle to selector points
            delete (cgui.ui.sHP); cgui.ui.sHP = {};
        end
        if ~isempty (cgui.ui.pHP), % delete handle to selector patches
            delete (cgui.ui.pHP); cgui.ui.pHP = {};
        end
    case 'ui_editor'            % toggle editor mode, adds user interactions dependent
        % on the panel which is active. Mouse and keyboard and graphics are
        % set for best manual editing.
        if cgui.modes.edit,
            cgui_tree ('ui_editoroff');
        else
            cgui_tree ('ui_editoron');
        end
    case 'ui_selector'          % toggle selection mode, second mode of user interactions
        if cgui.modes.select,
            cgui.modes.select = 0; % inactivate selection mode
            set (cgui.vis.ui.t2, 'value', 0);
        else
            cgui.modes.select = 1; % activate selection mode
            set (cgui.vis.ui.t2, 'value', 1);
        end
        if cgui.modes.edit, % if editor is on reset editor mode to select
            cgui_tree ('ui_editoroff');
            cgui_tree ('ui_editoron');
        end
    case 'ui_editorframe'       % enlarge panel of active editor
        panel       = cgui.ui.panels {cgui.modes.panel+5};
        pos         = get (eval (['cgui.' panel '.ui.c']), 'Position');
        pos (1 : 2) = pos (1 : 2) - 0.1 * cgui.ui.xrel;
        pos (3 : 4) = pos (3 : 4) + 0.2 * cgui.ui.xrel;
        set (eval (['cgui.' panel '.ui.c']), 'position', pos);
    case 'ui_editorunframe'     % set back panel of inactived editor
        panel       = cgui.ui.panels {cgui.modes.panel+5};
        pos         = get (eval (['cgui.' panel '.ui.c']),'Position');
        pos (1 : 2) = pos (1 : 2) + 0.1 * cgui.ui.xrel;
        pos (3 : 4) = pos (3 : 4) - 0.2 * cgui.ui.xrel;
        set (eval (['cgui.' panel '.ui.c']),'position',pos);
    case 'ui_editorpanelup'     % change active editor one up
        if cgui.modes.panel > 1,
            cgui_tree ('ui_editorunframe');
            if cgui.modes.edit,
                cgui_tree ('ui_editoroff');
                cgui.modes.panel = cgui.modes.panel - 1;
                cgui_tree ('ui_editoron');
            else
                cgui.modes.panel = cgui.modes.panel - 1;
            end
            cgui_tree ('ui_editorframe');
        end
    case 'ui_editorpaneldown'   % change active editor one down
        if cgui.modes.panel < 5,
            cgui_tree ('ui_editorunframe');
            if cgui.modes.edit,
                cgui_tree ('ui_editoroff');
                cgui.modes.panel = cgui.modes.panel + 1;
                cgui_tree ('ui_editoron');
            else
                cgui.modes.panel = cgui.modes.panel + 1;
            end
            cgui_tree ('ui_editorframe');
        end
        
    case 'vis_cla'              % redraw everything and reattribute mouse and keyboard
        figure    (cgui.ui.F);
        cgui_tree ('ui_clean'); % rid editor and selector graphic handles
        if cgui.modes.edit, % inactivate editor if editor is on
            cgui_tree ('ui_editoroff'); eflag = 1;
        else
            eflag = 0;
        end
        if ~isempty (cgui.vis.cbar), % delete colorbar if exists
            ch = get (cgui.vis.cbar, 'children'); delete (ch);
            delete (cgui.vis.cbar); cgui.vis.cbar = [];
        end
        delete (cgui.ui.g1); % delete complete axis
        % and create a new one:
        cgui.ui.g1 = axes ('position', cgui.ui.gpos, 'color', cgui.NColor.graph);
        % start out with visible axis/grid
        set (cgui.ui.g1, 'view', [0 90]); grid on; axis image; hold on;
        xlabel('x [\mum]'); ylabel('y [\mum]'); zlabel('z [\mum]'); % labels
        cgui.vis.scHP = [];  % empty scalebar handle
        cgui.vis.grHP = {};  % empty grid handle
        % for some reason I need to draw a surface before surfacing the
        % stack; surface handle:
        cgui.vis.sHP = surface([-.5 .5;  -.5 .5], [.5 .5;  -.5 -.5], [0 0; 0 0]);
        set (cgui.vis.sHP, 'CData', ones (2, 2), 'FaceColor', 'texturemap', ...
            'Edgecolor', 'none','facealpha', 0.5);
        cgui.stk.HP   = {};  % handles of tiled image stacks, one cell per stack
        cgui.thr.HP   = {};  % handles of thresholded image representations
        cgui.skl.HPI  = [];  % handle to the plot representing skeletonized points
        cgui.skl.HPS  = [];  % handle to the plot representing the starting points
        cgui.skl.HPCN = [];  % handle to the plot representing the connectivity graph
        cgui.mtr.tHP  = {};  % handle to plotted tree
        cgui.mtr.pHP  = {};  % handle to plotted nodes
        cgui.ged.tHP  = {};  % handles to plots of other trees in group
        cgui.plt.sHPs = {}; cgui.plt.HPs = {}; % delete all graphic objects
        set (cgui.plt.ui.pop, 'value', 1, 'string', 'none'); % reinitialize popup
        % redraw everything anew (from all panels):
        cgui_tree ('stk_image'); cgui_tree ('thr_image'); cgui_tree ('skl_image');
        cgui_tree ('mtr_image'); cgui_tree ('ged_image');
        % re-activate keyboard-shortcuts
        set (cgui.ui.F, 'KeyPressFcn', 'cgui_tree (''keymap'')');
        % activate mouse buttons
        set (cgui.ui.F, 'WindowButtonDownFcn', {@cgui_mouse_tree, 'mouse_bdown'});
        set (cgui.ui.F, 'WindowButtonUpFcn',   {@cgui_mouse_tree, 'mouse_udown'});
        if  eflag, % reactivate editor if editor was on
            cgui_tree ('ui_editoron');
        end
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'redrew everything'});
        % inform about all data:
        cgui_tree ('stk_inform'); cgui_tree ('thr_inform'); cgui_tree ('skl_inform');
        cgui_tree ('mtr_inform');
        % activate ui panels:
        cgui_tree ('stk_showpanels'); cgui_tree ('skl_showpanels');
        cgui_tree ('mtr_showpanels');
    case 'vis_tight'            % set axis limits to tight
        set (cgui.vis.ui.txt1, 'string', {'axis tight'});
        axis (cgui.ui.g1, 'tight'); % this doesn't seem to always work!
    case 'vis_xy'               % toggle axis view to 2D: only x and y axis
        if sum (get (cgui.ui.g1 ,'view') == [0 90]) == 2,
            % if it is already set to xy view toggle back to 3D:
            set (cgui.ui.g1,       'view', [-37.5 30]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:','3D'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 4; % 3D mode is view 4
        else
            set (cgui.ui.g1,       'view', [0 90]);   % xy view
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', 'x vs. y'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 1); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 1; % xy mode is view 1
        end
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
    case 'vis_xz'               % toggle axis view to 2D: only x and z axis
        if sum (get (cgui.ui.g1, 'view') == [0 0]) == 2,
            % if it is already set to xz view toggle back to 3D:
            set (cgui.ui.g1,       'view', [-37.5 30]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', '3D'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 4; % 3D mode is view 4
        else
            set (cgui.ui.g1,       'view', [0 0]);   % xz view
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', 'x vs. z'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 1);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 2; % xz mode is view 2
        end
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
    case 'vis_yz'               % toggle axis view to 2D: only y and z axis
        if sum (get (cgui.ui.g1, 'view') == [90 0]) == 2,
            % if it is already set to yz view toggle back to 3D:
            set (cgui.ui.g1,       'view', [-37.5 30]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', '3D'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 4; % 3D mode is view 4
        else
            set (cgui.ui.g1,       'view', [90 0]);   % yz view
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', 'y vs. z'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 1);
            cgui.modes.view = 3; % yz mode is view 3
        end
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
    case 'vis_2d3d'             % toggle between different axis views
        % toggle order is xy then xz then yz then 3D
        if    sum (get (cgui.ui.g1, 'view') == [0 90]) == 2,
            set (cgui.ui.g1,       'view', [0 0]);    % xz view
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', 'x vs. z'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 1);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 2; % xz mode is view 2
        elseif sum (get (cgui.ui.g1, 'view') == [0 0]) == 2,
            set (cgui.ui.g1,       'view', [90 0]);   % yz view
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', 'y vs. z'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 1);
            cgui.modes.view = 3; % yz mode is view 3
        elseif sum (get (cgui.ui.g1, 'view') == [90 0]) == 2,
            set (cgui.ui.g1,       'view',[-37.5 30]); % 3D view
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', '3D'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 0); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 4; % 3D mode is view 4
        else
            set (cgui.ui.g1,       'view', [0 90]);   % xy view
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'view:', 'x vs. y'});
            % update radio buttons:
            set (cgui.vis.ui.r1,   'value', 1); set (cgui.vis.ui.r2, 'value', 0);
            set (cgui.vis.ui.r3,   'value', 0);
            cgui.modes.view = 1; % xy mode is view 1
        end
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
    case 'vis_projection'       % toggle between orthographic and perspective projection
        if strcmp (get (cgui.ui.g1, 'projection'), 'orthographic'),
            set (cgui.ui.g1, 'projection', 'perspective');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'set projection:', 'perspective'});
        else
            set(cgui.ui.g1,'projection','orthographic');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'set projection:', 'orthographic'});
        end
    case 'vis_rshow'            % roundshow movie
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'roundshow'});
        figure (cgui.ui.F); % recover figure control
        roundshow;  % try out or see "roundshow"
        
    case 'vis_scale'            % toggle a scalebar on/off (see "scalebar")
        figure (cgui.ui.F); % recover figure control
        if strcmp (get(cgui.vis.scHP, 'visible'), 'on'),
            delete (cgui.vis.scHP); cgui.vis.scHP = []; % turn off scalebar
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'scalebar:', 'off'});
        else
            cgui.vis.scHP = scalebar ('\mum'); % create a scalebar
            set (cgui.vis.scHP, 'visible','on');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'scalebar:', 'on'});
        end
    case 'vis_cbar'             % toggle a colorbar on/off
        figure (cgui.ui.F);
        if strcmp (get(cgui.vis.cbar, 'visible'), 'on'),
            ch = get (cgui.vis.cbar, 'children'); delete (ch);
            delete (cgui.vis.cbar); cgui.vis.cbar = []; % turn off colorbar
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'colorbar:', 'off'});
        else
            cgui.vis.cbar = colorbar ('eastoutside'); % create a colorbar
            % adjust transparency to stack representation:
            h = get (cgui.vis.cbar, 'children'); set (h, 'alphadata', [cgui.stk.alpha]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'colorbar:', 'on'});
            cgui_tree ('vis_xclim'); % update colormap limits in edit fields
        end
    case 'vis_clim'             % set colormap limits according to edit fields
        set (cgui.ui.g1, 'clim', ...
            [str2double(get (cgui.vis.ui.ed_cbar1, 'string')) ...
            str2double( get (cgui.vis.ui.ed_cbar2, 'string'))]);
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'color limits', num2str(get (cgui.ui.g1, 'clim'))});
    case 'vis_xclim'            % if auto color limits then update edit fields
        if strcmp (get (cgui.ui.g1, 'climmode'), 'auto'),
            cgui_tree ('vis_climupdate'); % update edit fields with new colormap limits
        end
    case 'vis_climauto'         % set colormap back to automatic limits
        set (cgui.ui.g1, 'climmode', 'auto');
        cgui_tree ('vis_climupdate'); % update edit fields with new colormap limits
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'color limits', 'auto'});
    case 'vis_climupdate'       % update edit fields with new colormap limits
        if strcmp (get (cgui.ui.g1, 'climmode'), 'auto'),
            % update edit-fields with new clim values
            climmer = get (cgui.ui.g1, 'clim');
            set (cgui.vis.ui.ed_cbar1, 'string', num2str (climmer (1)));
            set (cgui.vis.ui.ed_cbar2, 'string', num2str (climmer (2)));
        end
    case 'vis_axoff'            % toggle visibility of axis
        if strcmp (get (cgui.ui.g1, 'visible'), 'on'),
            set (cgui.ui.g1, 'visible', 'off'); % turn off axis
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'axis:', 'off'});
        else
            set (cgui.ui.g1, 'visible', 'on'); % turn axis back on
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'axis:', 'on'});
        end
    case 'vis_shine'            % add sun-shine, this typically switches to opengl
        figure (cgui.ui.F); % recover figure control
        camlight; lighting gouraud;
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'added', 'sun shine'});
    case 'vis_grid'             % toggle grid on/off
        if ~isempty (cgui.vis.grHP),
            cgui_tree ('vis_cleargrid'); % clear grid, well yeah
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'grid:', 'off'});
        else
            cgui_tree ('vis_buildgrid'); % build grid, ...
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'grid:', 'on'});
        end
    case 'vis_rebuildgrid'      % change properties of grid
        if ~isempty (cgui.vis.grHP),
            cgui_tree ('vis_cleargrid'); cgui_tree ('vis_buildgrid');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'grid:', 'rebuilt'});
        end
    case 'vis_buildgrid'        % build grid according to edit fields
        figure (cgui.ui.F); % recover figure control
        start1 = str2double (get(cgui.vis.ui.ed_grid1, 'string')); % dimension 1
        start2 = str2double (get(cgui.vis.ui.ed_grid2, 'string')); % dimension 2
        num1   = str2double (get(cgui.vis.ui.ed_grid3, 'string')); % # of cells (dim 1)
        num2   = str2double (get(cgui.vis.ui.ed_grid4, 'string')); % # of cells (dim 2)
        dd     = str2double (get(cgui.vis.ui.ed_grid5, 'string')); % spacing
        switch cgui.modes.view, % the grid display depends on the view at the
            % moment at which the grid is buildt. To change orientation of
            % grid just press grid button twice.
            case 2 % xz view -> xz grid
                cgui.vis.grHP {1} = patch ([start1:dd:start1+(num1-1)*dd; ...
                    start1:dd:start1+(num1-1)*dd], ...
                    cgui.vis.iM*ones(2,num1), ...
                    [start2*ones(1,num1); (start2+(num2-1)*dd)*ones(1,num1)], [0 0 0]);
                cgui.vis.grHP {2} = patch ([start1*ones(1,num2); ...
                    (start1+(num1-1)*dd)*ones(1,num2)], ...
                    cgui.vis.iM*ones(2,num2), ...
                    [start2:dd:start2+(num2-1)*dd; start2:dd:start2+(num2-1)*dd], [0 0 0]);
            case 3 % yz view -> yz grid
                cgui.vis.grHP {1} = patch (cgui.vis.iM*ones(2,num1), ...
                    [start1:dd:start1+(num1-1)*dd; start1:dd:start1+(num1-1)*dd], ...
                    [start2*ones(1,num1); (start2+(num2-1)*dd)*ones(1,num1)], [0 0 0]);
                cgui.vis.grHP {2} = patch (cgui.vis.iM*ones(2,num2), ...
                    [start1*ones(1,num2); (start1+(num1-1)*dd)*ones(1,num2)], ...
                    [start2:dd:start2+(num2-1)*dd; start2:dd:start2+(num2-1)*dd], [0 0 0]);
            otherwise % xy or 3D view -> xy grid
                cgui.vis.grHP {1} = patch ([start1:dd:start1+(num1-1)*dd; ...
                    start1:dd:start1+(num1-1)*dd], ...
                    [start2*ones(1,num1); (start2+(num2-1)*dd)*ones(1,num1)], ...
                    cgui.vis.iM*ones(2,num1), [0 0 0]);
                cgui.vis.grHP {2} = patch ([start1*ones(1,num2); ...
                    (start1+(num1-1)*dd)*ones(1,num2)], ...
                    [start2:dd:start2+(num2-1)*dd; start2:dd:start2+(num2-1)*dd], ...
                    cgui.vis.iM*ones(2,num2), [0 0 0]);
        end
    case 'vis_cleargrid'        % clear grid (only internal use)
        for ward = 1 : length (cgui.vis.grHP),
            delete (cgui.vis.grHP {ward});
        end
        cgui.vis.grHP = {};
    case 'vis_iMm1'             % change slicer value -1 in slicing dimension
        set (cgui.vis.ui.ed_setz, 'string', str2double (get (cgui.vis.ui.ed_setz, 'string')) - 1);
        cgui_tree ('vis_setz');
    case 'vis_iMm5'             % change slicer value -5 in slicing dimension
        set (cgui.vis.ui.ed_setz, 'string', str2double (get (cgui.vis.ui.ed_setz, 'string')) - 5);
        cgui_tree ('vis_setz');
    case 'vis_iMp1'             % change slicer value +1 in slicing dimension
        set (cgui.vis.ui.ed_setz, 'string', str2double (get (cgui.vis.ui.ed_setz, 'string')) + 1);
        cgui_tree ('vis_setz');
    case 'vis_iMp5'             % change slicer value +5 in slicing dimension
        set (cgui.vis.ui.ed_setz, 'string', str2double (get (cgui.vis.ui.ed_setz, 'string')) + 5);
        cgui_tree ('vis_setz');
    case 'vis_setz'             % after changing the slicer value this does the changes:
        cgui.vis.iM = str2double (get (cgui.vis.ui.ed_setz, 'string'));
        cgui_tree ('vis_rebuildgrid'); % change properties of grid
        if ~isempty(cgui.stk.M) && get(cgui.stk.ui.r2, 'value'),
            cgui_tree ('stk_image'); % slicer also affects the slice viewed in image stack
        end
        
    case 'vis_print'            % print a snapshot of the screen incl. GUI
        printpreview (cgui.ui.F);
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'printed', 'snapshot'});
    case 'vis_jpg'              % print low resolution jpeg
        cgui_tree ('ui_allinvisible'); set (cgui.ui.g1, 'position', cgui.ui.ppos);
        tprint    ('', '-jpg');
        cgui_tree ('ui_allvisible');   set (cgui.ui.g1, 'position', cgui.ui.gpos);
        set (cgui.ui.F, 'color', cgui.NColor.background); % tprint makes background white
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'printed', 'low res jpeg'});
    case 'vis_tif'              % print high resolution tiff
        cgui_tree ('ui_allinvisible');
        tprint    ('', '-tif -HR', [10 10]);
        cgui_tree ('ui_allvisible');
        set (cgui.ui.F, 'color', cgui.NColor.background); % tprint makes background white
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'printed', 'high res tiff'});
    case 'vis_eps'              % print vectorized image
        cgui_tree ('ui_allinvisible'); set (cgui.ui.g1, 'position', cgui.ui.ppos);
        % this mode cannot deal with transparency or spotlight therefore
        % painter:
        set (cgui.ui.F, 'renderer', 'painter'); tprint('', '-eps -HR');
        % most of the time this will not be enough. Make sure that you get
        % rid of any opengl elements like real tree plots (blatt
        % representation is ok).
        set (cgui.ui.F, 'renderer', 'opengl');
        cgui_tree ('ui_allvisible'); set (cgui.ui.g1, 'position', cgui.ui.gpos);
        set (cgui.ui.F, 'color', cgui.NColor.background); % tprint makes background white
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'printed', 'vectorized eps'});
        
    case 'vis_cmap1'            % switch to hot-colorscale
        colormap hot; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5,'children'); % update menu
        set (childs(4 : 14), 'checked', 'off'); set (childs (14), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'hot-colormap'});
    case 'vis_cmapi1'           % switch to inverse hot-colorscale
        colormap (flipud (hot));
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (4 : 14), 'checked', 'off'); set (childs (13), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'hot-colormap'});
    case 'vis_cmap2'            % switch to grayscale
        colormap gray; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (4 : 14), 'checked', 'off'); set (childs (12), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'grayscale'});
    case 'vis_cmapi2'           % switch to inverse grayscale
        colormap (flipud (gray)); cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (4 : 14), 'checked', 'off'); set (childs (11), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'grayscale'});
    case 'vis_cmap3'            % switch to jet false-colorscale
        colormap jet; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (4 : 14), 'checked', 'off'); set (childs (10), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'pseudo-colormap'});
    case 'vis_cmap4'            % switch to bone false-colorscale
        colormap bone; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs, 'checked', 'off'); set (childs (9), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'bone-colormap'});
    case 'vis_cmap5'            % switch to copper false-colorscale
        colormap copper; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (4 : 14), 'checked', 'off'); set (childs (8), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'copper-colormap'});
    case 'vis_cmap6'            % switch to autumn false-colorscale
        colormap autumn; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs, 'checked', 'off'); set (childs (7), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'autumn-colormap'});
    case 'vis_cmap7'            % switch to spring false-colorscale
        colormap spring; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (4 : 14), 'checked', 'off'); set (childs (6), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'spring-colormap'});
    case 'vis_cmap8'            % switch to winter false-colorscale
        colormap winter; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs, 'checked', 'off'); set (childs (5), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'winter-colormap'});
    case 'vis_cmap9'            % switch to summer false-colorscale
        colormap summer; cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (4 : 14), 'checked', 'off'); set (childs (4), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'summer-colormap'});
    case 'vis_cmap_t5'          % switch to transparent colormap
        cgui.stk.alpha = 0.5;
%         set(cgui.ui.F,'renderer','opengl')
        cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar'); cgui_tree ('stk_image');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (1), 'checked', 'off'); set (childs (2), 'checked', 'on');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'transparent colormap'});
    case 'vis_cmap_t0'          % switch to opaque colormap
        cgui.stk.alpha = 1;
%         set(cgui.ui.F,'renderer','painters')
        cgui_tree ('vis_cbar'); cgui_tree ('vis_cbar'); cgui_tree ('stk_image');
        childs = get (cgui.ui.mu5, 'children'); % update menu
        set (childs (1), 'checked', 'on'); set (childs (2), 'checked', 'off');
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'switched to', 'opaque colormap'});
    case 'vis_resx4'            % change resolution of cylinders in tree to 4 points
        cgui.vis.res = 4; cgui_tree ('mtr_image');
        childs = get (cgui.ui.mu43, 'children'); % update menu
        set (childs, 'checked', 'off'); set (childs (3), 'checked', 'on');
    case 'vis_resx8'            % change resolution of cylinders in tree to 8 points
        cgui.vis.res = 8; cgui_tree ('mtr_image');
        childs = get (cgui.ui.mu43, 'children'); % update menu
        set (childs, 'checked', 'off'); set (childs (2), 'checked', 'on');
    case 'vis_resx32'           % change resolution of cylinders in tree to 32 points
        cgui.vis.res = 32; cgui_tree ('mtr_image');
        childs = get (cgui.ui.mu43, 'children'); % update menu
        set (childs, 'checked', 'off'); set (childs (1), 'checked', 'on');
        
    case 'plt_pop'              % popup dealer to manage handles to all graphical objects
        % this entire section concerns the plotting panel, in which permanent
        % graphical objects are created from the active tree. The object
        % handles can be separately edited. But  remember that vis_cla
        % removes all these handles.
        if ~isempty (cgui.plt.HPs),
            % activate a handle object by putting it on top of the stack:
            value = get (cgui.plt.ui.pop, 'value');
            vec   = cgui.plt.HPs {value};
            cgui.plt.HPs  (value)   = [];   % take out selected handle
            cgui.plt.HPs  {end+1}   = vec;  % and put it on top of the stack
            vec   = cgui.plt.sHPs {value};  % same for strings describing the handles
            cgui.plt.sHPs (value)   = [];
            cgui.plt.sHPs {end+1}   = vec;
            set (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'selected a graphics handle:', vec});
        end
    case 'plt_plot'             % create a nice cylinder tree plot handle
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            cgui_tree ('slt_vcomp'); % read out vector to map on color
            % see "plot_tree":
            cgui.plt.HPs  {end+1} = plot_tree (cgui.mtr.tree, cgui.slt.vec, [], [], ...
                cgui.vis.res, '-p');
            % update popup:
            cgui.plt.sHPs {end+1} = ['plot ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'full plot of tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1,'tight');
        end
    case 'plt_pplot'            % create a blatt tree
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out vector to map on color and read out index:
            cgui_tree ('slt_vcomp'); cgui_tree ('slt_icomp');
            % see "plot_tree":
            cgui.plt.HPs  {end+1} = plot_tree (cgui.mtr.tree, cgui.slt.vec, [], ...
                cgui.slt.ind, 2, '-b');
            % update popup:
            cgui.plt.sHPs {end+1} = ['bplot ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'blatt plot of tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_qplot'            % create a quiver tree (arrows of the graph)
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out index:
            cgui_tree ('slt_icomp');
            % see "plot_tree":
            cgui.plt.HPs {end+1}  = plot_tree (cgui.mtr.tree, [], [], ...
                cgui.slt.ind, 2, '-3q');
            % update popup:
            cgui.plt.sHPs {end+1} = ['qplot ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'quiver plot of tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_vtext'            % create a text handle with current vector of values
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out vector to map on text and color and read out index:
            cgui_tree ('slt_vcomp'); cgui_tree ('slt_icomp');
            % see "vtext_tree":
            cgui.plt.HPs {end+1}  = vtext_tree (cgui.mtr.tree, cgui.slt.vec, ...
                cgui.slt.vec, [], [], cgui.slt.ind);
            % update popup:
            cgui.plt.sHPs {end+1} = ['vtext ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'text on tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_vtext2'           % create a 2D text handle with current vector of values
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out vector to map on text and color and read out index:
            cgui_tree ('slt_vcomp'); cgui_tree ('slt_icomp');
            % see "vtext_tree":
            cgui.plt.HPs {end+1}  = vtext_tree (cgui.mtr.tree, cgui.slt.vec (cgui.slt.ind), ...
                cgui.slt.vec (cgui.slt.ind), [], [], cgui.slt.ind, '-2d');
            % update popup:
            cgui.plt.sHPs {end+1} = ['vtext ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'2D text on tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_pointer'          % create handle of spheres sitting on selected points
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out index for points to point at:
            cgui_tree ('slt_icomp');
            % see "pointer_tree":
            if ~isempty (cgui.slt.ind)
                cgui.plt.HPs {end+1} = pointer_tree (cgui.mtr.tree, cgui.slt.ind);
            else
                cgui.plt.HPs {end+1} = pointer_tree (cgui.mtr.tree, cgui.mtr.lastnode);
            end
            % update popup:
            cgui.plt.sHPs {end+1} = ['point ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'pointer on tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_electrode'        % create handle of cones pointing to selected points
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out index for points to point at:
            cgui_tree ('slt_icomp');
            % see "pointer_tree":
            if ~isempty (cgui.slt.ind)
                cgui.plt.HPs {end+1} = pointer_tree (cgui.mtr.tree, cgui.slt.ind, ...
                    [], [], [], '-l');
            else
                cgui.plt.HPs {end+1} = pointer_tree (cgui.mtr.tree, cgui.mtr.lastnode, ...
                    [], [], [], '-l');
            end
            % update popup:
            cgui.plt.sHPs {end+1} = ['lpoint ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'electrode on tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_electrode2'       % create an electrode handle pointing to selected points
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out index for points to point at:
            cgui_tree ('slt_icomp');
            % see "pointer_tree":
            if ~isempty (cgui.slt.ind)
                cgui.plt.HPs {end+1} = pointer_tree (cgui.mtr.tree, cgui.slt.ind, ...
                    [], [], [], '-v');
            else
                cgui.plt.HPs {end+1} = pointer_tree (cgui.mtr.tree, cgui.mtr.lastnode, ...
                    [], [], [], '-v');
            end
            % update popup:
            cgui.plt.sHPs {end+1} = ['vpoint ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'patch electrode on tree', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_dhull'            % create a distance hull handle around tree
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % see "hull_tree":
            [hull M cgui.plt.HPs{end+1}] = hull_tree (cgui.mtr.tree, ...
                str2double (get (cgui.plt.ui.ed_hull1, 'string')), 30, 30, 30, '-w -s');
            clear hull M
            % update popup:
            cgui.plt.sHPs {end+1} = ['hull ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'distance hull', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_dhull2'           % create a 2D distance hull handle around tree
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % see "hull_tree":
            [hull M cgui.plt.HPs{end+1}] = hull_tree (cgui.mtr.tree, ...
                str2double (get (cgui.plt.ui.ed_hull1, 'string')), 30, 30, 30, '-w -s -2d');
            clear hull M
            % update popup:
            cgui.plt.sHPs {end+1} = ['2d-hull ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'2D distance hull', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_vhull'            % create a voronoi hull handle
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out vector to map on voronoi field color and read out
            % index:
            cgui_tree ('slt_vcomp'); cgui_tree ('slt_icomp');
            % first find the distance hull:
            c = hull_tree (cgui.mtr.tree, ...
                str2double (get(cgui.plt.ui.ed_hull1, 'string')), 20, 20, 20, '-w');
            points = c.vertices;
            % see "vhull_tree":
            cgui.plt.HPs  {end+1}  = vhull_tree (cgui.mtr.tree, cgui.slt.vec,...
                points, cgui.slt.ind, [],'-w -s');
            % update popup:
            cgui.plt.sHPs {end+1} = ['vhull ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'voronoi hull', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_vhull2'           % create a 2D voronoi hull handle
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out vector to map on voronoi field color and read out
            % index:
            cgui_tree ('slt_vcomp'); cgui_tree ('slt_icomp');
            % first find the 2D distance hull:
            [Xt Yt] = cpoints (hull_tree (cgui.mtr.tree, ...
                str2double (get (cgui.plt.ui.ed_hull1, 'string')), 30, 30, 30, '-w -2d'));
            points = [Xt Yt];
            % see "vhull_tree":
            cgui.plt.HPs {end+1}  = vhull_tree (cgui.mtr.tree, cgui.slt.vec, ...
                points, cgui.slt.ind, [], '-w -s -2d');
            % update popup:
            cgui.plt.sHPs {end+1} = ['2d-vhull ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'2D voronoi hull', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_lego'             % create a lego density distribution handle
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % see "lego_tree", use distance hull edit for resolution:
            cgui.plt.HPs  {end+1} = lego_tree (cgui.mtr.tree, ...
                str2double (get (cgui.plt.ui.ed_hull1, 'string')), 0, '-f -e');
            % update popup:
            cgui.plt.sHPs {end+1} = ['lego ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'lego toy plot', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_gdens'            % create a density distribution handle
        if ~isempty (cgui.mtr.tree),
            figure (cgui.ui.F); % recover figure control
            % read out index of nodes to use for density plot:
            cgui_tree ('slt_icomp');
            % see "gdens_tree", use distance hull edit for resolution:
            [m dx dy dz cgui.plt.HPs{end+1}] = gdens_tree (cgui.mtr.tree, ...
                str2double (get (cgui.plt.ui.ed_hull1, 'string')), cgui.slt.ind, '-s');
            clear m dx dy dz
            % update popup:
            cgui.plt.sHPs {end+1} = ['dens ' cgui.mtr.tree.name]; % create name of handle
            set  (cgui.plt.ui.pop,  'string', cgui.plt.sHPs, 'value', length (cgui.plt.sHPs));
            % echo on text frame of vis_ panel:
            set  (cgui.vis.ui.txt1, 'string', {'density plot', cgui.plt.sHPs{end}});
            axis (cgui.ui.g1, 'tight');
        end
    case 'plt_color'            % color selector for active handle (opens GUI)
        if ~isempty (cgui.plt.HPs),
            sui = uisetcolor ([0 0 0]); % open GUI, {DEFAULT: black}
            for ward = 1 : length (cgui.plt.HPs {end}),
                HP = cgui.plt.HPs {end} (ward);
                if isprop (HP, 'color'),
                    set (HP, 'color', sui);
                elseif isprop (HP, 'facecolor')
                    set (HP, 'facecolor', sui);
                end
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'changed face color of', cgui.plt.sHPs{end}});
        end
    case 'plt_color2'           % line color selector for active handle (opens GUI)
        if ~isempty (cgui.plt.HPs),
            sui = uisetcolor ([0 0 0]); % open GUI, {DEFAULT: black}
            for ward = 1 : length (cgui.plt.HPs {end}),
                HP = cgui.plt.HPs {end} (ward);
                if isprop (HP, 'edgecolor')
                    set (HP, 'linestyle', '-', 'edgecolor', sui);
                    if isprop (HP, 'edgealpha')
                        set (HP, 'edgealpha', 1);
                    end
                end
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'changed edge color of', cgui.plt.sHPs{end}});
        end
    case 'plt_trans1'           % decrease transparency of active handle
        if ~isempty (cgui.plt.HPs)
            for ward = 1 : length (cgui.plt.HPs {end}), % walk through sub-handles
                HP = cgui.plt.HPs {end} (ward);
                if isprop   (HP, 'facealpha'),
                    if get  (HP, 'facealpha') <= 0.9,
                        set (HP, 'facealpha', get (HP, 'facealpha') + 0.1);
                    end
                end
                if isprop   (HP, 'edgealpha'),
                    if get  (HP, 'edgealpha') <= 0.9,
                        set (HP, 'edgealpha', get (HP, 'edgealpha') + 0.1);
                    end
                end
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'decreased transparency of', cgui.plt.sHPs{end}});
        end
    case 'plt_trans2'           % increase transparency of active handle
        if ~isempty (cgui.plt.HPs)
            for ward = 1 : length (cgui.plt.HPs {end}),
                HP = cgui.plt.HPs {end} (ward);
                if isprop   (HP, 'facealpha'),
                    if get  (HP, 'facealpha') >= 0.1,
                        set (HP, 'facealpha', get (HP, 'facealpha') - 0.1);
                    end
                end
                if isprop   (HP, 'edgealpha'),
                    if get  (HP, 'edgealpha') >= 0.1,
                        set (HP, 'edgealpha', get (HP, 'edgealpha') - 0.1);
                    end
                end
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'increased transparency of', cgui.plt.sHPs{end}});
        end
    case 'plt_linem'            % thin line of active handle
        if ~isempty (cgui.plt.HPs)
            for ward = 1 : length (cgui.plt.HPs {end}),
                HP = cgui.plt.HPs {end} (ward);
                if isprop (HP, 'linewidth'),
                    set (HP, 'linewidth', get (HP, 'linewidth') * .9);
                end
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'thin line of', cgui.plt.sHPs{end}});
        end
    case 'plt_linep'            % thicken line of active handle
        if ~isempty (cgui.plt.HPs)
            for ward = 1 : length (cgui.plt.HPs {end}),
                HP = cgui.plt.HPs {end} (ward);
                if isprop (HP, 'linewidth'),
                    set (HP, 'linewidth', get (HP, 'linewidth') * 1.1);
                end
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'thicken line of', cgui.plt.sHPs{end}});
        end
    case 'plt_font'             % change font of active handle (opens GUI)
        if ~isempty (cgui.plt.HPs)
            strHP.FontName  = 'Arial'; strHP.FontUnits  = 'points';
            strHP.FontSize  = 12;      strHP.FontWeight = 'regular';
            strHP.FontAngle = 'regular'; sui = uisetfont (strHP); % open GUI
            for ward = 1 : length (cgui.plt.HPs {end}),
                HP = cgui.plt.HPs {end} (ward);
                if isprop (HP, 'fontname'),
                    set (cgui.plt.HPs {end}, sui);
                end
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'changed font of', cgui.plt.sHPs{end}});
        end
    case 'plt_clear'            % clear active handle
        if ~isempty (cgui.plt.HPs)
            delete (cgui.plt.HPs {end}); % selected or most recent handle is at the end
            cgui.plt.HPs  (end) = [];
            cgui.plt.sHPs (end) = [];
            % update popup:
            if isempty (cgui.plt.sHPs),
                cgui.plt.sHPs = {};
                set (cgui.plt.ui.pop, 'value', 1, 'string', 'none');
            else
                set (cgui.plt.ui.pop, 'value', length (cgui.plt.sHPs), 'string', cgui.plt.sHPs);
            end
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'cleared actual handle');
        end
        
    case 'slt_relsel'           % release selection after tree was altered
        cgui.slt.ind = []; % release slt_ panel indexed nodes
        if ~isempty (cgui.slt.cind),
            % release slt_ panel computed indexed nodes and reset popup
            cgui.slt.cind = []; cgui.slt.sind {end} = 'computed';
            set (cgui.slt.ui.pop2, 'string', cgui.slt.sind);
        end
        cgui.mtr.selected = []; % release mtr_panel edit selected nodes
        if ~isfield(cgui.modes,'hold') || cgui.modes.hold == 0
            cgui.mtr.lastnode =  1; % reset last active node to tree root
        elseif cgui.mtr.lastnode > numel(cgui.mtr.tree.X)   % change lastnode
            cgui.mtr.lastnode = numel(cgui.mtr.tree.X);
        end
        cgui.slt.vec      = []; % release Nx1 vectors from slt_ panel
        if ~isempty (cgui.slt.cvec),
            % release slt_ panel computed Nx1 vectors and reset popup
            cgui.slt.cvec = []; cgui.slt.svec{end} = 'computed';
            set (cgui.slt.ui.pop1, 'string', cgui.slt.svec);
        end
    case 'slt_indpop'           % select an index to nodes in tree
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_icomp'); % read out index to send to selected
            % update selected nodes in mtr_ edit-select mode
            if get (cgui.mtr.ui.t_selp, 'value'),
                cgui.mtr.selected = unique ([cgui.mtr.selected; cgui.slt.ind]);
            else
                cgui.mtr.selected = cgui.slt.ind;
            end
            if ~isempty (cgui.slt.ind)
                cgui.mtr.lastnode = cgui.slt.ind (end);
            end
            cgui_tree ('mtr_image'); % update mtr_ to show selected nodes
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'new selection of nodes'});
        end
    case 'slt_vecpop'           % select a vector of values to map on nodes
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('mtr_image'); % update values color-mapping in mtr_
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'selected new value mapping'});
        end
    case 'slt_vcomp'            % calculate values-to-node mapping
        if ~isempty (cgui.mtr.tree)
            switch get (cgui.slt.ui.pop1, 'value'),
                case 1  % no values mapping
                    cgui.slt.vec = [];
                case 2  % map branch order
                    cgui.slt.vec = BO_tree     (cgui.mtr.tree);
                case 3  % map topological path length
                    cgui.slt.vec = PL_tree     (cgui.mtr.tree);
                case 4  % map level order
                    cgui.slt.vec = LO_tree     (cgui.mtr.tree);
                case 5  % map euclidean distance to root
                    cgui.slt.vec = eucl_tree   (cgui.mtr.tree);
                case 6  % map segment lengths
                    cgui.slt.vec = len_tree    (cgui.mtr.tree);
                case 7  % map segment surfaces
                    cgui.slt.vec = surf_tree   (cgui.mtr.tree);
                case 8  % map segment volumes
                    cgui.slt.vec = vol_tree    (cgui.mtr.tree);
                case 9  % map branch angles
                    cgui.slt.vec = angleB_tree (cgui.mtr.tree);
                case 10 % map node type (0:termination, 1: continuation, 2: branch)
                    cgui.slt.vec = typeN_tree  (cgui.mtr.tree);
                case 11 % map individual index for regions
                    cgui.slt.vec = rindex_tree (cgui.mtr.tree);
                case 12 % map region values
                    cgui.slt.vec = cgui.mtr.tree.R;
                case 13 % map 1 for branch point 0 for not
                    cgui.slt.vec = double (B_tree (cgui.mtr.tree));
                case 14 % map 1 for termination point 0 for not
                    cgui.slt.vec = double (T_tree (cgui.mtr.tree));
                case 15 % map 1 for topological point 0 for not
                    cgui.slt.vec = double (B_tree (cgui.mtr.tree) | T_tree (cgui.mtr.tree));
                case 16 % map 1 for continuation point 0 for not
                    cgui.slt.vec = double (C_tree (cgui.mtr.tree));
                case 17 % map diameter values
                    cgui.slt.vec = cgui.mtr.tree.D;
                case 18 % map local input resistances
                    sse = sse_tree             (cgui.mtr.tree); % see "sse_tree"
                    cgui.slt.vec = diag(sse);
                case 19 % map current injection in selected nodes or root
                    cgui_tree ('slt_icomp'); % read out index to inject current
                    I = zeros (size (cgui.mtr.tree.dA, 1), 1); % Iinj vector
                    if ~isempty (cgui.slt.ind),
                        I (cgui.slt.ind) = 1; % inject 1 nA steady state in selected nodes
                        cgui.slt.vec = sse_tree (cgui.mtr.tree, I);
                    else
                        I (cgui.mtr.lastnode) = 1; % inject 1 nA steady state in last selected
                        cgui.slt.vec = sse_tree (cgui.mtr.tree, I);
                    end
                case 20 % map computed values using METAFUNCTIONs
                    if ~isempty (cgui.slt.cvec),
                        cgui.slt.vec = cgui.slt.cvec;
                    else
                        cgui.slt.vec = [];
                    end
            end
        end
    case 'slt_pvec'             % metafunction: recursive on the path summation
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp'); % read out selected value mapping
            % apply "Pvec_tree" on that mapping (cumulative summation of
            % vector values along the paths away from the the root):
            cgui.slt.cvec = Pvec_tree (cgui.mtr.tree, cgui.slt.vec);
            % update popup:
            cgui.slt.svec {end} = ['pvec ' cgui.slt.svec{get(cgui.slt.ui.pop1, 'value')}];
            set (cgui.slt.ui.pop1, 'string', cgui.slt.svec, 'value', length (cgui.slt.svec));
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'computed on the path summation', ...
                cgui.slt.svec{end}});
        end
    case 'slt_ratio'            % metafunction: daugher parent value ratio
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp'); % read out selected value mapping
            % apply "ratio_tree" on that mapping (Ratio between parent and
            % daughter segments in a tree of the values in the vector):
            cgui.slt.cvec = ratio_tree (cgui.mtr.tree, cgui.slt.vec);
            % update popup:
            cgui.slt.svec {end} = ['ratio ' cgui.slt.svec{get(cgui.slt.ui.pop1, 'value')}];
            set (cgui.slt.ui.pop1, 'string', cgui.slt.svec, 'value', length (cgui.slt.svec));
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'computed parent daughter ratio', ...
                cgui.slt.svec{end}});
        end
    case 'slt_child'            % metafunction: sum up values over children
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp'); % read out selected value mapping
            % apply "child_tree" on that mapping (Attribute add-up child
            % node values to parent nodes in a tree for values in the
            % vector):
            cgui.slt.cvec = child_tree (cgui.mtr.tree, cgui.slt.vec);
            % update popup:
            cgui.slt.svec {end} = ['child ' cgui.slt.svec{get(cgui.slt.ui.pop1, 'value')}];
            set (cgui.slt.ui.pop1, 'string', cgui.slt.svec, 'value', length (cgui.slt.svec));
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'computed summation over children',...
                cgui.slt.svec{end}});
        end
    case 'slt_asym'             % metafunction: value-sum-up asymmetry over subtrees
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp'); % read out selected value mapping
            % apply "asym_tree" on that mapping (branch point asymmetry of
            cgui.slt.cvec = asym_tree (cgui.mtr.tree, cgui.slt.vec);
            % update popup:
            cgui.slt.svec {end} = ['asym ' cgui.slt.svec{get(cgui.slt.ui.pop1, 'value')}];
            set (cgui.slt.ui.pop1, 'string', cgui.slt.svec, 'value', length (cgui.slt.svec));
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'computed subtree asymmetry', cgui.slt.svec{end}});
        end
    case 'slt_icomp'            % calculate node selection indexing
        if ~isempty (cgui.mtr.tree)
            switch get (cgui.slt.ui.pop2, 'value'),
                case 1 % no selection
                    cgui.slt.ind = [];
                case 2 % select all
                    cgui.slt.ind = (1 : size (cgui.mtr.tree.dA, 1))';
                case 3 % select branch points
                    cgui.slt.ind = find (B_tree (cgui.mtr.tree));
                case 4 % select termination points
                    cgui.slt.ind = find (T_tree (cgui.mtr.tree));
                case 5 % select topological points
                    cgui.slt.ind = find (B_tree (cgui.mtr.tree) | T_tree (cgui.mtr.tree));
                case 6 % select continuation points
                    cgui.slt.ind = find (C_tree (cgui.mtr.tree));
                case 7 % select nodes from selected region
                    cgui.slt.ind = find (cgui.mtr.tree.R == get (cgui.slt.ui.pop3, 'value'));
                case 8 % computed selection
                    if ~isempty (cgui.slt.cind),
                        cgui.slt.ind = cgui.slt.cind;
                    else
                        cgui.slt.ind = [];
                    end
            end
        end
    case 'slt_thr1'             % compute selection of thresholding value vector <
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp'); % read out selected value mapping
            % set threshold v<thr
            cgui.slt.cind = find (cgui.slt.vec < ...
                str2double (get (cgui.slt.ui.ed_thred1, 'string')));
            % update selected nodes in mtr_ edit-select mode
            if get (cgui.mtr.ui.t_selp, 'value'),
                cgui.mtr.selected = unique ([cgui.mtr.selected; cgui.slt.cind]);
            else
                cgui.mtr.selected = cgui.slt.cind;
            end
            if ~isempty (cgui.slt.cind)
                cgui.mtr.lastnode = cgui.slt.cind (end);
            end
            % update popup
            cgui.slt.sind {end} = [cgui.slt.svec{get(cgui.slt.ui.pop1, 'value')} ...
                '<' get(cgui.slt.ui.ed_thred1, 'string')];
            set (cgui.slt.ui.pop2, 'string', cgui.slt.sind, 'value', length (cgui.slt.sind));
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'computed thresholding', cgui.slt.svec{end}});
        end
    case 'slt_thr2'             % compute selection of thresholding value vector >
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp'); % read out selected value mapping
            % set threshold v>thr
            cgui.slt.cind = find (cgui.slt.vec > ...
                str2double (get (cgui.slt.ui.ed_thred1, 'string')));
            % update selected nodes in mtr_ edit-select mode
            if get (cgui.mtr.ui.t_selp, 'value'),
                cgui.mtr.selected = unique ([cgui.mtr.selected; cgui.slt.cind]);
            else
                cgui.mtr.selected = cgui.slt.cind;
            end
            if ~isempty (cgui.slt.cind)
                cgui.mtr.lastnode = cgui.slt.cind (end);
            end
            % update popup
            cgui.slt.sind {end} = [cgui.slt.svec{get(cgui.slt.ui.pop1, 'value')} ...
                '>' get(cgui.slt.ui.ed_thred1, 'string')];
            set (cgui.slt.ui.pop2, 'string', cgui.slt.sind, 'value', length (cgui.slt.sind));
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'computed thresholding', cgui.slt.svec{end}});
        end
    case 'slt_delete'           % delete selected nodes
        if ~isempty (cgui.mtr.tree),
            if cgui.modes.select && cgui.modes.edit && (cgui.modes.panel == 4)
                % delete selected nodes in mtr_ edit-select mode
                indy = cgui.mtr.selected;
            else
                cgui_tree ('slt_icomp'); % read out index of selected nodes
                indy = cgui.slt.ind;
            end
            if ~isempty (indy),
                cgui.cat.untrees {end+1} = cgui.mtr.tree; % keep track of old tree for undo
                % this is it (see "delete_tree"):
                cgui.mtr.tree = delete_tree (cgui.mtr.tree, indy,'-r');
                cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
                cgui_tree ('slt_regupdate'); % check if tree alteration affected region index
                if isempty (cgui.mtr.tree), % clear tree if tree became empty...
                    cgui_tree ('cat_cleartree');
                    % echo on text frame of vis_ panel:
                    set (cgui.vis.ui.txt1, 'string', 'this deleted entire tree');
                else
                    cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                    cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
                    % echo on text frame of vis_ panel:
                    set (cgui.vis.ui.txt1, 'string', 'deleted selected nodes');
                end
            end
        end
    case 'slt_setreg'           % reset region popup and edit
        if ~isempty (cgui.mtr.tree),
            set (cgui.slt.ui.pop3, 'string', num2str ((1 : length (cgui.mtr.tree.rnames))'), ...
                'value', 1);
            set (cgui.slt.ui.ed_name1, 'string', cgui.mtr.tree.rnames {1});
        end
    case 'slt_regupdate'        % update region popup and edit when tree was altered
        if ~isempty (cgui.mtr.tree)
            if length (cgui.mtr.tree.rnames) ~= length (get (cgui.slt.ui.pop3, 'string')),
                cgui_tree ('slt_setreg');
            end
        end
    case 'slt_regpop'           % popup region select
        if ~isempty (cgui.mtr.tree),
            set (cgui.slt.ui.ed_name1, 'string', ...
                cgui.mtr.tree.rnames {get(cgui.slt.ui.pop3, 'value')});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'selected different region');
        end
    case 'slt_name'             % change name of selected region
        if ~isempty (cgui.mtr.tree),
            cgui.mtr.tree.rnames {get(cgui.slt.ui.pop3, 'value')} = ...
                get (cgui.slt.ui.ed_name1, 'string');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'changed region name');
        end
    case 'slt_assign'           % assign active region to selected nodes
        if ~isempty (cgui.mtr.tree),
            if cgui.modes.edit && (cgui.modes.panel == 4)
                % set edit-select selected nodes to active region:
                cgui.mtr.tree.R (cgui.mtr.selected) = get (cgui.slt.ui.pop3, 'value');
            else
                cgui_tree ('slt_icomp'); % update node selection indexing
                % set selected nodes to active region:
                cgui.mtr.tree.R (cgui.slt.ind) = get (cgui.slt.ui.pop3, 'value');
            end
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', ...
                {'assigned to selected nodes', ['region # ' num2str(get (cgui.slt.ui.pop3, 'value'))]});
        end
    case 'slt_assignN'          % assign NEW active region to selected nodes
        if ~isempty (cgui.mtr.tree),
            len = length (cgui.mtr.tree.rnames);
            cgui.mtr.tree.rnames {len+1} = 'new_region';
            if cgui.modes.edit && (cgui.modes.panel == 4)
                % set edit-select selected nodes to new active region:
                cgui.mtr.tree.R (cgui.mtr.selected) = len + 1;
            else
                cgui_tree ('slt_icomp'); % update node selection indexing
                % set selected nodes to new active region:
                cgui.mtr.tree.R (cgui.slt.ind) = len + 1;
            end
            set (cgui.slt.ui.pop3, 'string', num2str ((1 : length (cgui.mtr.tree.rnames))'), ...
                'value', len + 1);
            set (cgui.slt.ui.ed_name1, 'string', ...
                cgui.mtr.tree.rnames {get(cgui.slt.ui.pop3, 'value')});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', ...
                {'created new region', 'and assigned to selected nodes'});
        end
    case 'slt_delreg'           % delete a region if it is void of nodes (only on command)
        if ~isempty (cgui.mtr.tree),
            ireg = get (cgui.slt.ui.pop3, 'value');
            if sum (cgui.mtr.tree.R == ireg) == 0,
                cgui.mtr.tree.rnames (ireg) = [];
                cgui.mtr.tree. R(cgui.mtr.tree.R > ireg) = ...
                    cgui.mtr.tree.R (cgui.mtr.tree.R > ireg) - 1;
                cgui_tree ('slt_regupdate'); % update region popup and edit
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            end
        end
    case 'slt_cyl'              % toggle between cylinder and frustum representation
        if get  (cgui.slt.ui.t1, 'value'),
            set (cgui.slt.ui.t2, 'value', 0);
            if isfield (cgui.mtr.tree, 'frustum'),
                % remove "frustum" field to revert to cylinders:
                cgui.mtr.tree = rmfield (cgui.mtr.tree, 'frustum');
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'switched to', 'cylinder representation'});
            end
        else
            set (cgui.slt.ui.t2, 'value', 1);
            if ~isfield (cgui.mtr.tree, 'frustum'),
                % add "frustum" field to revert to frustums:
                cgui.mtr.tree.frustum = 1;
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'switched to', 'frustum representation'});
            end
        end
    case 'slt_frustum'          % toggle between cylinder and frustum representation
        if get  (cgui.slt.ui.t2, 'value'),
            set (cgui.slt.ui.t1, 'value', 0);
            if ~isfield (cgui.mtr.tree, 'frustum'),
                % add "frustum" field to revert to frustums:
                cgui.mtr.tree.frustum = 1;
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'switched to', 'frustum representation'});
            end
        else
            set (cgui.slt.ui.t1, 'value', 1);
            if isfield (cgui.mtr.tree, 'frustum'),
                % remove "frustum" field to revert to cylinders:
                cgui.mtr.tree = rmfield (cgui.mtr.tree, 'frustum');
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'switched to', 'cylinder representation'});
            end
        end
    case 'slt_subtree'          % select all nodes belonging to a sub-tree
        if ~isempty (cgui.mtr.tree),
            % find nodes belonging to sub-tree of last-active-node:
            cgui.slt.cind = find (sub_tree (cgui.mtr.tree, cgui.mtr.lastnode));
            % update selected nodes in mtr_ edit-select mode
            if get(cgui.mtr.ui.t_selp, 'value'),
                cgui.mtr.selected = unique ([cgui.mtr.selected; cgui.slt.cind]);
            else
                cgui.mtr.selected = cgui.slt.cind;
            end
            if ~isempty (cgui.slt.cind)
                cgui.mtr.lastnode = cgui.slt.cind (end);
            end
            % update popup
            cgui.slt.sind {end} = ['nodes of subtree of ' num2str(cgui.mtr.lastnode)];
            set (cgui.slt.ui.pop2, 'string', cgui.slt.sind, 'value', length (cgui.slt.sind));
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', ...
                {'selected subtree', ['of node ' num2str(cgui.mtr.lastnode)]});
        end
        
    case 'ele_Ri'               % change axial resistance
        if ~isempty (cgui.mtr.tree),
            cgui.mtr.tree.Ri = str2double (get (cgui.ele.ui.ed_elec1, 'string'));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'updated axial resistance');
        end
    case 'ele_Gm'               % change membrane conductance
        if ~isempty (cgui.mtr.tree),
            cgui.mtr.tree.Gm = str2double (get (cgui.ele.ui.ed_elec2, 'string'));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'updated membrane conductance');
        end
    case 'ele_Cm'               % change membrane capacitance
        if ~isempty (cgui.mtr.tree),
            cgui.mtr.tree.Cm = str2double (get (cgui.ele.ui.ed_elec3, 'string'));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'updated membrane capacitance');
        end
    case 'ele_setelec'          % update edit fields with electrotonic values from tree
        if ~isempty (cgui.mtr.tree),
            set (cgui.ele.ui.ed_elec1, 'string', num2str (cgui.mtr.tree.Ri));
            set (cgui.ele.ui.ed_elec2, 'string', num2str (cgui.mtr.tree.Gm));
            set (cgui.ele.ui.ed_elec3, 'string', num2str (cgui.mtr.tree.Cm));
        end
        
    case 'cat_clear_all'        % clear all trees including currently active tree
        if ~isempty (cgui.mtr.tree)
            answer = questdlg('Do you really want to clear all trees? This cannot be undone!','Warning');
            if ~strcmp(answer,'Yes')
                return
            end
            setasvtimer('ask',1)
            stop(cgui.cat.tautosave)
            cgui.mtr.tree  = {}; cgui.cat.trees  = {}; % delete all trees
            cgui.cat.itree =  0; cgui.cat.i2tree =  0; % set pointer to groups to 0
            % update cat_ panel UI elements:
            set (cgui.cat.ui.f2, 'value',    1); set (cgui.cat.ui.f1, 'value',       1);
            set (cgui.cat.ui.f2, 'string', 'x'); set (cgui.cat.ui.f1, 'string', 'none');
            set (cgui.cat.ui.ed_name1, 'string', '');
            % redraw tree graphics:
            cgui_tree ('mtr_image');   cgui_tree ('ged_image');
            % update root location, electrotonics and regions edit fields
            cgui_tree ('ged_settran'); cgui_tree ('ele_setelec'); cgui_tree ('slt_setreg');
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            cgui.cat.untrees = {}; % get rid of undo (or should I not?)
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'cleared all trees'});
            cgui_tree ('mtr_showpanels'); % check if mtr_ ui panels should be active
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_cleartree'        % clear just active tree
        if ~isempty (cgui.cat.trees)
            % deal with the fact that cgui.cat.trees can be an array of arrays
            % of trees, and delete the right tree:
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
%                 if length (cgui.cat.trees {cgui.cat.i2tree}) == 2,
%                 %???? CRAP?
%                     cgui.cat.trees {cgui.cat.i2tree} = cgui.cat.trees{cgui.cat.i2tree}{1};
%                     cgui.cat.itree = 1;
%                 else
                    cgui.cat.trees {cgui.cat.i2tree} (cgui.cat.itree) = [];
                    cgui.cat.itree = 1;
%                 end
            else
                cgui.cat.trees (cgui.cat.i2tree) = [];
                cgui.cat.i2tree = 1; cgui.cat.itree = 1;
            end
            % then check if at all a tree is remaining:
            if isempty (cgui.cat.trees), % if not reset ui elements:
                cgui.cat.i2tree = 0; cgui.cat.itree = 0;
                cgui.mtr.tree = {};
                set (cgui.cat.ui.f1, 'value', 1, 'string', 'none');
                set (cgui.cat.ui.f2, 'value', 1, 'string', 'x');
                set (cgui.cat.ui.ed_name1, 'string', '');
                cgui_tree ('mtr_showpanels');
            else % if yes choose a new active tree:
                if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                    str = cell (1, length (cgui.cat.trees {cgui.cat.i2tree}));
                    for ward = 1 : length (cgui.cat.trees {cgui.cat.i2tree})
                        str {ward} = cgui.cat.trees{cgui.cat.i2tree}{ward}.name;
                    end
                    cgui.mtr.tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree};
                else
                    if iscell(cgui.cat.trees {cgui.cat.i2tree})
                        str = cgui.cat.trees {cgui.cat.i2tree}{1}.name;  %
                        cgui.mtr.tree = cgui.cat.trees {cgui.cat.i2tree}{1};  %
                    else
                        str = cgui.cat.trees {cgui.cat.i2tree}.name;  %{1}
                        cgui.mtr.tree = cgui.cat.trees {cgui.cat.i2tree};  %{1}
                    end
                end
                % and update the ui panels:
                set (cgui.cat.ui.f1, 'value', cgui.cat.itree,  'string', str);
                set (cgui.cat.ui.f2, 'value', cgui.cat.i2tree, 'string', ...
                    num2str ((1 : length (cgui.cat.trees))'));
                set (cgui.cat.ui.ed_name1, 'string', cgui.mtr.tree.name); % update edit field for tree name
            end
            if ~isempty (cgui.vis.cbar), % delete colorbar if exists, for some reason it makes trouble otherwise
                ch = get (cgui.vis.cbar, 'children'); delete (ch);
                delete (cgui.vis.cbar); cgui.vis.cbar = [];
            end
            % redraw tree graphics:
            cgui_tree ('mtr_image');   cgui_tree ('ged_image');
            % update root location, electrotonics and regions edit fields
            cgui_tree ('ged_settran'); cgui_tree ('ele_setelec'); cgui_tree ('slt_setreg');
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            cgui.cat.untrees = {}; % no undo!!
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'cleared last active tree'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_load'             % load TREES toolbox trees
        stop(cgui.cat.tautosave)
        [tree,name,path] = load_tree;   % see "load_tree", well yes...
        setasvtimer({'path','name'},{path,name})
        if ~isempty (tree),
            incorporateloaded_tree (tree, 'tree'); % this deals with new trees
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'loaded TREES trees'});
%             if isstruct(tree{1}) && numel(unique(cellfun(@(x) x.x_scale,tree))) == 1
%                 % edit field entries call this function
%                 set(cgui.stk.ui.ed_vox1, 'string', tree{1}.x_scale)
%                 set(cgui.stk.ui.ed_vox2, 'string', tree{1}.y_scale)
%                 set(cgui.stk.ui.ed_vox3, 'string', tree{1}.z_scale);
%                 cgui_tree ('stk_setvoxel' )
%             end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
        start(cgui.cat.tautosave)
    case 'cat_nlucida'          % load neurolucida tree (see "neurolucida_tree")
        [tree mcoords] = neurolucida_tree ('', '-r -c -w');
        incorporateloaded_tree (tree, 'nlucida'); % this deals with new trees
        if ~isempty (mcoords)
            % markers are loaded into skeletonization panel
            cgui.skl.I = mcoords(:, [2 1 3]); cgui_tree ('skl_image');
            cgui_tree ('skl_showpanels'); % enable/disable skl_ ui elements
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'neurolucida tree', 'including markers'});
        else
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'neurolucida tree'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_nlucida_onesoma'  % load neurolucida tree (see "neurolucida_tree")
        % this version incorporates all trees in one
        [tree mcoords] = neurolucida_tree ('', '-r -c -o -w');   % -o option
        incorporateloaded_tree (tree, 'nlucida'); % this deals with new trees
        if ~isempty (mcoords)
            % markers are loaded into skeletonization panel
            cgui.skl.I = mcoords (:, [2 1 3]); cgui_tree ('skl_image');
            cgui_tree ('skl_showpanels'); % enable/disable skl_ ui elements
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'neurolucida tree', 'forced one tree load', ...
                'including markers'});
        else
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'neurolucida tree', 'forced one tree load'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_save'             % save active tree
        if ~isempty (cgui.mtr.tree)
            [tname, path] = uiputfile ('.mtr', 'save trees',fullfile(getasvtimer('path'),getasvtimer('name')));
            name = save_tree (cgui.mtr.tree,fullfile(path,tname));   % see "save_tree", well yes...
            % echo on text frame of vis_ panel:
            if ~isempty (name),
                set (cgui.vis.ui.txt1, 'string', {'active tree saved:', name});
            end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_gsave'            % save active group of trees
        if ~isempty (cgui.cat.trees)
            %before saving, be sure to store changes of active tree
            cgui_tree ('cat_update');
            [tname, path] = uiputfile ('.mtr', 'save trees',fullfile(getasvtimer('path'),getasvtimer('name')));
            [name, path] = save_tree ({cgui.cat.trees{cgui.cat.i2tree}},fullfile(path,tname));
            % echo on text frame of vis_ panel:
            if ~isempty (name),
                set (cgui.vis.ui.txt1, 'string', {'active tree group saved', name});
                if strcmp(get(cgui.cat.tautosave,'Running'),'off')
                   start(cgui.cat.tautosave); 
                end
                setasvtimer({'path','name'},{path,name})
            end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_allsave'          % save all trees
        if ~isempty (cgui.cat.trees)
%             before saving, be sure to store changes of active tree
            cgui_tree ('cat_update');
            [tname, path] = uiputfile ('.mtr', 'save trees',fullfile(getasvtimer('path'),getasvtimer('name')));
            [name, path] = save_tree (cgui.cat.trees,fullfile(path,tname));
            % echo on text frame of vis_ panel:
            if ~isempty (name),
                set (cgui.vis.ui.txt1, 'string', {'all trees saved', name});
                if strcmp(get(cgui.cat.tautosave,'Running'),'off')
                    start(cgui.cat.tautosave);
                end
                setasvtimer({'path','name'},{path,name})
            end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_duplicate'        % duplicate the currently active tree
        if ~isempty (cgui.mtr.tree)
            % this deals with multiple trees etc..
            incorporateloaded_tree (cgui.mtr.tree, ['copy_' cgui.mtr.tree.name]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'loaded TREES trees'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_swc'              % export active tree to .swc format
        if ~isempty (cgui.cat.trees)
            name = swc_tree (cgui.mtr.tree);
            % echo on text frame of vis_ panel:
            if ~isempty (name),
                set (cgui.vis.ui.txt1, 'string', {'exported to .swc', name});
            end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_neuron'           % export active tree to NEURON format
        if ~isempty (cgui.cat.trees)
            name = neuron_tree (cgui.mtr.tree);
            % echo on text frame of vis_ panel:
            if ~isempty (name),
                set (cgui.vis.ui.txt1, 'string', {'exported to .hoc/.nrn', name});
            end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_nml_v1_l1'        % export active tree to nml_v1_l1 format
        if ~isempty (cgui.cat.trees)
            name = neuroml_tree (cgui.mtr.tree, [], '-v1l1 -w');
            % echo on text frame of vis_ panel:
            if ~isempty (name),
                set (cgui.vis.ui.txt1, 'string', {'exported to NeuroML Level 1', name});
            end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_nml_v2a'          % export active tree to nml_v2a format
        if ~isempty (cgui.cat.trees)
            name = neuroml_tree (cgui.mtr.tree, [], '-v2a -w');
            % echo on text frame of vis_ panel:
            if ~isempty (name),
                set (cgui.vis.ui.txt1, 'string', {'exported to NeuroML v2alpha', name});
            end
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_update'           % before switching tree update changes made to active tree
        if ~isempty (cgui.cat.trees)
            cgui.cat.untrees = {};  % undo is deactivated!!
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree} = cgui.mtr.tree;
            else
                cgui.cat.trees{cgui.cat.i2tree} = cgui.mtr.tree;
            end
            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
        end
    case 'cat_name'             % change name of active tree
        if ~isempty (cgui.cat.trees)
            name = get (cgui.cat.ui.ed_name1, 'string');
            % update active tree and cat_ cell array name fields
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree}.name = name;
            else
                cgui.cat.trees{cgui.cat.i2tree}.name = name;
            end
            cgui.mtr.tree.name = name;
            % update frame window containing tree names in active group:
            str = get (cgui.cat.ui.f1, 'string');
            if ~iscell(str)
                str = {str};
            end
            str {cgui.cat.itree} = name;
            set (cgui.cat.ui.f1, 'string', str);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'changed tree name:', name});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_selecttree'       % select a tree in a group
        if ~isempty (cgui.cat.trees)
            cgui_tree ('cat_update'); % update changes made to active tree
            cgui.cat.itree = get (cgui.cat.ui.f1, 'value'); % read out index
            % update active tree:
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                cgui.mtr.tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree};
            else
                cgui.mtr.tree = cgui.cat.trees{cgui.cat.i2tree};
            end
            if isfield(cgui.modes,'hold') && cgui.modes.hold == 1
                cgui.mtr.lastnode = 1;
            end
            % update edit field for tree name:
            set (cgui.cat.ui.ed_name1, 'string', cgui.mtr.tree.name);
            cgui_tree ('mtr_image');   cgui_tree ('ged_image'); % redraw tree graphics
            % update root location, electrotonics and regions edit fields
            cgui_tree ('ged_settran'); cgui_tree ('ele_setelec'); cgui_tree ('slt_setreg');
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            cgui.cat.untrees = {}; % get rid of undos...
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'selected different tree'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_selectgroup'      % select a group of trees
        if ~isempty (cgui.cat.trees)
            cgui_tree ('cat_update'); % update changes made to active tree
            cgui.cat.i2tree = get (cgui.cat.ui.f2, 'value'); % read out index
            cgui.cat.itree = 1; % select first tree in new group
            % update active tree:
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                str = cell (1 , length (cgui.cat.trees {cgui.cat.i2tree}));
                for ward = 1 : length (cgui.cat.trees {cgui.cat.i2tree}),
                    str {ward} = cgui.cat.trees{cgui.cat.i2tree}{ward}.name;
                end
                cgui.mtr.tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree};
            else
                str = cgui.cat.trees {cgui.cat.i2tree}.name;
                cgui.mtr.tree = cgui.cat.trees {cgui.cat.i2tree};
            end
            set (cgui.cat.ui.f1, 'value', 1, 'string', str);
            % update edit field for tree name
            set (cgui.cat.ui.ed_name1, 'string', cgui.mtr.tree.name);
            cgui_tree ('mtr_image');   cgui_tree ('ged_image'); % redraw tree graphics
            % update root location, electrotonics and regions edit fields
            cgui_tree ('ged_settran'); cgui_tree ('ele_setelec'); cgui_tree ('slt_setreg');
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            cgui.cat.untrees = {}; % get rid of undos...
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'selected different tree group'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_uptree'           % move tree up (very complicated)
        if ~isempty (cgui.cat.trees)
            % deal with the fact that cat_ trees can be cell array of cell
            % array of trees. Has to deal with all different possibilities:
            % a tree is moved up within a group, or if it is first element
            % then it becomes a group of its own; if it is a group of its
            % own, move it to the end of the next group. And of course
            % don't do anything if it is the top element.
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree};
            else
                tree = cgui.cat.trees{cgui.cat.i2tree};
            end
            if (cgui.cat.itree == 1)
                if length (cgui.cat.trees {cgui.cat.i2tree}) > 1
                    if length (cgui.cat.trees {cgui.cat.i2tree}) == 2,
                        cgui.cat.trees{cgui.cat.i2tree} = cgui.cat.trees{cgui.cat.i2tree}{2};
                    else
                        cgui.cat.trees{cgui.cat.i2tree}(cgui.cat.itree) = [];
                    end
                    cgui.cat.trees = {cgui.cat.trees{1:cgui.cat.i2tree-1}, tree, ...
                        cgui.cat.trees{cgui.cat.i2tree:end}};
                else
                    if cgui.cat.i2tree > 1
                        cgui.cat.trees (cgui.cat.i2tree) = [];
                        cgui.cat.i2tree = cgui.cat.i2tree - 1;
                        if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                            cgui.cat.trees{cgui.cat.i2tree} = ...
                                [cgui.cat.trees{cgui.cat.i2tree}, tree];
                        else
                            cgui.cat.trees{cgui.cat.i2tree} = ...
                                {cgui.cat.trees{cgui.cat.i2tree}, tree};
                        end
                        cgui.cat.itree = length (cgui.cat.trees {cgui.cat.i2tree});
                    end
                end
            else
                cgui.cat.trees{cgui.cat.i2tree}(cgui.cat.itree) = [];
                cgui.cat.itree = cgui.cat.itree - 1;
                cgui.cat.trees{cgui.cat.i2tree} = ...
                    {cgui.cat.trees{cgui.cat.i2tree}{1:cgui.cat.itree - 1}, ...
                    tree, cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree:end}};
            end
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                str = cell (1 , length (cgui.cat.trees{cgui.cat.i2tree}));
                for ward = 1 : length (cgui.cat.trees {cgui.cat.i2tree})
                    str {ward} = cgui.cat.trees{cgui.cat.i2tree}{ward}.name;
                end
            else
                str = cgui.cat.trees{cgui.cat.i2tree}.name;
            end
            set (cgui.cat.ui.f1, 'value', cgui.cat.itree,  'string', str);
            set (cgui.cat.ui.f2, 'value', cgui.cat.i2tree, 'string', ...
                num2str ((1 : length (cgui.cat.trees))'));
            cgui_tree ('ged_image'); % active tree doesn't change but neighborhood
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree in selector'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_downtree'         % move tree down (complicated as well)
        if ~isempty (cgui.cat.trees)
            % deal with the fact that cat_ trees can be cell array of cell
            % array of trees. See above: Has to deal with all different
            % possibilities: a tree is moved down within a group, or if it
            % is last element then it becomes a group of its own; if it is
            % a group of its own, move it to the first position of the next
            % group. And of course don't do anything if it is the very last
            % element.
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree};
            else
                tree = cgui.cat.trees{cgui.cat.i2tree};
            end
            if (cgui.cat.itree == length (cgui.cat.trees{cgui.cat.i2tree}))
                if length (cgui.cat.trees {cgui.cat.i2tree}) > 1
                    if length (cgui.cat.trees {cgui.cat.i2tree}) == 2,
                        cgui.cat.trees{cgui.cat.i2tree} = cgui.cat.trees{cgui.cat.i2tree}{1};
                    else
                        cgui.cat.trees{cgui.cat.i2tree}(cgui.cat.itree) = [];
                    end
                    cgui.cat.i2tree = cgui.cat.i2tree + 1; cgui.cat.itree = 1;
                    cgui.cat.trees  = {cgui.cat.trees{1:cgui.cat.i2tree-1}, tree, ...
                        cgui.cat.trees{cgui.cat.i2tree:end}};
                else
                    if (length (cgui.cat.trees) > cgui.cat.i2tree)
                        cgui.cat.trees (cgui.cat.i2tree) = [];
                        if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                            cgui.cat.trees{cgui.cat.i2tree} = [{tree}, ...
                                cgui.cat.trees{cgui.cat.i2tree}];
                        else
                            cgui.cat.trees{cgui.cat.i2tree} = {tree, ...
                                cgui.cat.trees{cgui.cat.i2tree}};
                        end
                        cgui.cat.itree = 1;
                    end
                end
            else
                cgui.cat.trees{cgui.cat.i2tree}(cgui.cat.itree) = [];
                cgui.cat.itree = cgui.cat.itree + 1;
                cgui.cat.trees{cgui.cat.i2tree} = ...
                    {cgui.cat.trees{cgui.cat.i2tree}{1:cgui.cat.itree-1}, ...
                    tree, cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree:end}};
            end
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                str = cell (1, length (cgui.cat.trees {cgui.cat.i2tree}));
                for ward = 1 : length (cgui.cat.trees {cgui.cat.i2tree})
                    str {ward} = cgui.cat.trees{cgui.cat.i2tree}{ward}.name;
                end
            else
                str = cgui.cat.trees{cgui.cat.i2tree}.name;
            end
            set (cgui.cat.ui.f1, 'value', cgui.cat.itree,  'string', str);
            set (cgui.cat.ui.f2, 'value', cgui.cat.i2tree, 'string', ...
                num2str ((1 : length (cgui.cat.trees))'));
            cgui_tree ('ged_image'); % active tree doesn't change but neighborhood
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree in selector'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'cat_undo'             % undo tree action
        if ~isempty (cgui.cat.untrees)
            cgui.mtr.tree = cgui.cat.untrees {end}; % active tree becomes last undo
            cgui.cat.untrees (end) = []; % eliminate undo
            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
            cgui_tree ('mtr_image');   cgui_tree ('ged_image'); % redraw tree graphics
            % update root location, electrotonics and regions edit fields
            cgui_tree ('ged_settran'); cgui_tree ('ele_setelec'); cgui_tree ('slt_setreg');
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'UNDO','reverted tree to previous status'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'stk_showpanels'       % enable/disable stk_ and thr_ ui elements
        if ~isempty (cgui.stk.M), % enable ui elements if there are some stacks
            % enable ui elements of stk_ and thr_ panels:
            for te = 6 : 7,
                str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
                for ward = 3 : length (str),
                    HP = eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]);
                    set (HP, 'enable', 'on');
                    if strcmp (get (HP, 'style'), 'edit'),
                        set (HP, 'backgroundcolor', [0 0 0]); % weird stuff
                        set (HP, 'backgroundcolor', cgui.NColor.edit);
                    end
                end
            end
            set (cgui.vis.ui.b3, 'enable', 'on');
            % change background color of panels and radio buttons:
            set (cgui.stk.ui.c,  'backgroundcolor', [0 0 0]);
            set (cgui.stk.ui.r1, 'backgroundcolor', [0 0 0]);
            set (cgui.stk.ui.r2, 'backgroundcolor', [0 0 0]);
            set (cgui.thr.ui.c,  'backgroundcolor', [0 0 1]);
            set (cgui.thr.ui.r1, 'backgroundcolor', [0 0 1]);
            set (cgui.thr.ui.r2, 'backgroundcolor', [0 0 1]);
            set (cgui.thr.ui.r3, 'backgroundcolor', [0 0 1]);
            mu11 = get (cgui.ui.mu1, 'children'); set (mu11 (1 : 2), 'enable', 'on');
        else
            % disable ui elements of stk_ and thr_ panels:
            for te = 6 : 7,
                str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
                for ward = 3 : length (str),
                    set (eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]), 'enable', 'off');
                end
            end
            set (cgui.vis.ui.b3, 'enable','off');
            % change background color of panels and radio buttons:
            set (cgui.stk.ui.c,  'backgroundcolor', [.7 .7 .7]);
            set (cgui.stk.ui.r1, 'backgroundcolor', [.7 .7 .7]);
            set (cgui.stk.ui.r2, 'backgroundcolor', [.7 .7 .7]);
            set (cgui.thr.ui.c,  'backgroundcolor', [.7 .7 1]);
            set (cgui.thr.ui.r1, 'backgroundcolor', [.7 .7 1]);
            set (cgui.thr.ui.r2, 'backgroundcolor', [.7 .7 1]);
            set (cgui.thr.ui.r3, 'backgroundcolor', [.7 .7 1]);
            mu11 = get (cgui.ui.mu1, 'children'); set (mu11 (1 : 2), 'enable', 'off');
        end
    case 'stk_inform'           % text output on stack size
        str = get (cgui.vis.ui.txt2, 'string'); % replace adequate str-cell
        if ~isempty (cgui.stk.M)
            str {1} = ['stk: ' num2str(size (cgui.stk.M {end}, 1)), ' x ',...
                num2str(size (cgui.stk.M {end}, 2)),' x ' num2str(size (cgui.stk.M {end}, 3))];
        else
            str {1} = '';
        end
        set (cgui.vis.ui.txt2, 'string', str); % and put back on text screen
    case 'stk_clear'            % clear active stack (and all thresholded)
        if ~isempty (cgui.stk.M),
            % clear stack and complete binary thresholds
            cgui.stk.M (end) = []; cgui.thr.BW = {};
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {[cgui.stk.sM{end} ' deleted'], ...
                'and all thresholded images'});
            cgui.stk.sM (end) = []; cgui.stk.coord (end, :) = [];
            if isempty (cgui.stk.M),
                % completely reset stacks if all stacks are gone
                cgui.stk.M = {}; cgui.stk.sM = {};
                % reset popup and edits:
                set (cgui.stk.ui.pop, 'string', 'none', 'value', 1);
                set (cgui.stk.ui.ed_tran1, 'string', '0');
                set (cgui.stk.ui.ed_tran2, 'string', '0');
                set (cgui.stk.ui.ed_tran3, 'string', '0');
            else
                % update popup and edits with newly active stack:
                set (cgui.stk.ui.pop, 'string', cgui.stk.sM, 'value', length (cgui.stk.sM));
                set (cgui.stk.ui.ed_tran1, 'string', num2str (cgui.stk.coord(end, 1)));
                set (cgui.stk.ui.ed_tran2, 'string', num2str (cgui.stk.coord(end, 2)));
                set (cgui.stk.ui.ed_tran3, 'string', num2str (cgui.stk.coord(end, 3)));
            end
            cgui_tree ('stk_update'); % update stk_ maximum intensity projections
            cgui_tree ('stk_image');  % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image');  % redraw thr_ graphical output: thresholded stacks
            cgui_tree ('stk_inform'); % text output on stack size
            cgui_tree ('thr_inform'); % text output on percentage thresholded
            if isempty(cgui.stk.M),
                % weird surface handle which needs to always be there:
                cgui.vis.sHP = surface ([-.5 .5;  -.5 .5], [.5 .5;  -.5 -.5], [0 0; 0 0]);
                set (cgui.vis.sHP, 'CData', ones(2, 2), 'FaceColor', 'texturemap', ...
                    'Edgecolor', 'none', 'facealpha', 0.5);
                % deactivate stk_ ui elements (and check skl_ ...):
                cgui_tree ('stk_showpanels'); cgui_tree ('skl_showpanels');
            end
        end
    case 'stk_clear_all'        % clear all stacks (and all thresholded)
        % reset stacks
        cgui.stk.coord = []; cgui.stk.voxel = [1 1 1];
        cgui.stk.M = {}; cgui.thr.BW = {}; cgui.stk.sM = {};
        % reset popup and edit fields
        set (cgui.stk.ui.pop, 'string', 'none', 'value', 1);
        set (cgui.stk.ui.ed_tran1, 'string', '0');
        set (cgui.stk.ui.ed_tran2, 'string', '0');
        set (cgui.stk.ui.ed_tran3, 'string', '0');
        cgui_tree ('stk_update'); % update stk_ maximum intensity projections
        cgui_tree ('stk_image');  % redraw stk_ graphical output: image stacks
        cgui_tree ('thr_image');  % redraw thr_ graphical output: thresholded stacks
        % weird surface handle which needs to always be there:
        cgui.vis.sHP = surface ([-.5 .5;  -.5 .5], [.5 .5;  -.5 -.5], [0 0; 0 0]);
        set (cgui.vis.sHP, 'CData', ones(2, 2), 'FaceColor', 'texturemap', ...
            'Edgecolor', 'none', 'facealpha', 0.5);
        % deactivate stk_ ui elements (and check skl_ ...):
        cgui_tree ('stk_showpanels'); cgui_tree ('skl_showpanels');
        cgui_tree ('stk_inform'); % text output on stack size
        cgui_tree ('thr_inform'); % text output on percentage thresholded
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', {'all stacks deleted', 'and all thresholded images'});
    case 'stk_dirload'          % load image sequence from directory
        stack = loaddir_stack;
        if ~isempty (stack),
            incorporateloaded_stack (stack); % does what it says
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'load stack from dir:', stack.sM{1}});
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_imload'           % load single image from file
        stack = imload_stack;
        if ~isempty (stack),
            incorporateloaded_stack (stack); % does what it says
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'load image:', stack.sM{1}});
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_load'             % load TREES stack (clears all old stacks)
        cgui_tree ('stk_clear_all'); % clear all old stacks
        stack = load_stack;
        if ~isempty (stack),
            % integrate stacks:
            cgui.stk.M = stack.M; cgui.stk.sM = stack.sM;
            % set a threshold corresponding to brightness values of stack:
            cgui_tree ('thr_setstd');
            cgui.stk.coord = stack.coord; cgui.stk.voxel = stack.voxel;
            % update popup (last stack becomes active stack):
            set (cgui.stk.ui.pop,      'string', cgui.stk.sM, 'value', length (cgui.stk.sM));
            set (cgui.stk.ui.ed_tran1, 'string', num2str (cgui.stk.coord (end, 1)));
            set (cgui.stk.ui.ed_tran2, 'string', num2str (cgui.stk.coord (end, 2)));
            set (cgui.stk.ui.ed_tran3, 'string', num2str (cgui.stk.coord (end, 3)));
            set (cgui.stk.ui.ed_vox1,  'string', num2str (cgui.stk.voxel (1)));
            set (cgui.stk.ui.ed_vox2,  'string', num2str (cgui.stk.voxel (2)));
            set (cgui.stk.ui.ed_vox3,  'string', num2str (cgui.stk.voxel (3)));
            cgui_tree ('stk_update'); % update stk_ maximum intensity projections
            cgui_tree ('stk_image');  % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image');  % redraw thr_ graphical output: thresholded stacks
            % activate ui elements and text output stack size:
            cgui_tree ('stk_showpanels'); cgui_tree ('stk_inform');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'loaded TREES stack'});
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_tifsload'         % load image stack from multiple tif
        stack = loadtifs_stack;
        if ~isempty (stack),
            incorporateloaded_stack (stack); % does what it says
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'load stack from tif:', stack.sM{1}});
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_save'             % save TREES stack
        if ~isempty (cgui.stk.M),
            % extract stack:
            stack = []; stack.M = cgui.stk.M; stack.sM = cgui.stk.sM;
            stack.coord = cgui.stk.coord; stack.voxel = cgui.stk.voxel;
            save_stack (stack); % see "save_stack"
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
        
    case 'stk_pop'              % update stack sorter
        if ~isempty (cgui.stk.M),
            value = get (cgui.stk.ui.pop, 'value'); % find popup selected
            % put selected stack, its descriptive string, its coordinates
            % and maximum intensity projections to the end of the arrays:
            % (becomes currently activated stack).
            vec = cgui.stk.M    {value}; cgui.stk.M    (value) = []; cgui.stk.M    {end+1} = vec;
            vec = cgui.stk.sM   {value}; cgui.stk.sM   (value) = []; cgui.stk.sM   {end+1} = vec;
            vec = cgui.stk.imM1 {value}; cgui.stk.imM1 (value) = []; cgui.stk.imM1 {end+1} = vec;
            vec = cgui.stk.imM2 {value}; cgui.stk.imM2 (value) = []; cgui.stk.imM2 {end+1} = vec;
            vec = cgui.stk.imM3 {value}; cgui.stk.imM3 (value) = []; cgui.stk.imM3 {end+1} = vec;
            vec = cgui.stk.mM1  {value}; cgui.stk.mM1  (value) = []; cgui.stk.mM1  {end+1} = vec;
            vec = cgui.stk.mM2  {value}; cgui.stk.mM2  (value) = []; cgui.stk.mM2  {end+1} = vec;
            vec = cgui.stk.mM3  {value}; cgui.stk.mM3  (value) = []; cgui.stk.mM3  {end+1} = vec;
            if ~isempty (cgui.thr.BW),
                vec = cgui.thr.BW {value}; cgui.thr.BW (value) = []; cgui.thr.BW   {end+1} = vec;
            end
            vec = cgui.stk.coord (value, :); cgui.stk.coord (value, :) = [];
            cgui.stk.coord (end + 1, :) = vec;
            % update popup and coordinate edit fields
            set (cgui.stk.ui.pop,      'string', cgui.stk.sM, 'value', length (cgui.stk.sM));
            set (cgui.stk.ui.ed_tran1, 'string', num2str (cgui.stk.coord (end, 1)));
            set (cgui.stk.ui.ed_tran2, 'string', num2str (cgui.stk.coord (end, 2)));
            set (cgui.stk.ui.ed_tran3, 'string', num2str (cgui.stk.coord (end, 3)));
            setactivepanel_tree (1);  % activate stk_ panel for edit
            cgui_tree ('stk_image');  % redraw stk_ graphical output: image stacks
            cgui_tree ('stk_inform'); % text output on stack size
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'changed active stack');
        end
    case 'stk_filter'           % this is left free for image processing filters
        % please please somebody implement some magic here!!!
    case 'stk_downsize'         % downsample X and Y to 50% in all stacks
        if ~isempty (cgui.stk.M),
            HW = waitbar (0, 'downsampling to 50% in X and Y...');
            set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
            warning ('off', 'MATLAB:divideByZero');
            for ward = 1 : length (cgui.stk.M),
                waitbar (ward / length (cgui.stk.M), HW);
                cgui.stk.M {ward} = imresize (cgui.stk.M {ward}, 0.5);
            end
            cgui.thr.BW = {}; % reset thresholded images
            close (HW);
            warning ('on',  'MATLAB:divideByZero');
            % update edit fields with new voxel size (x2)
            set (cgui.stk.ui.ed_vox1, 'string', ...
                str2double (get (cgui.stk.ui.ed_vox1, 'string')) * 2);
            set (cgui.stk.ui.ed_vox2, 'string', ...
                str2double (get (cgui.stk.ui.ed_vox2, 'string')) * 2);
            cgui_tree ('stk_setvoxel'); % set the voxel size according to edit fields
            cgui_tree ('stk_update'); % update stk_ maximum intensity projections
            cgui_tree ('stk_image'); % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image'); % redraw thr_ graphical output: thresholded stacks
            setactivepanel_tree (1); % activate stk_ panel for edit
            cgui_tree ('stk_inform'); % text output on stack size
            cgui_tree ('thr_inform'); % text output on percentage thresholded
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'downsampled stacks','50% in X and Y'});
        end
    case 'stk_bmx'              % move currently activated image stack in X
        if ~isempty (cgui.stk.M),
            % update edit field
            set (cgui.stk.ui.ed_tran1, 'string', ...
                str2double (get (cgui.stk.ui.ed_tran1, 'string')) - 1);
            % then change coordinates according to edit field:
            cgui_tree ('stk_setcoord');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'set X coords for stack');
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_bpx'              % move currently activated image stack in X
        if ~isempty (cgui.stk.M),
            % update edit field
            set (cgui.stk.ui.ed_tran1, 'string', ...
                str2double (get (cgui.stk.ui.ed_tran1, 'string')) + 1);
            % then change coordinates according to edit field:
            cgui_tree ('stk_setcoord');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'set X coords for stack');
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_bmy'              % move currently activated image stack in Y
        if ~isempty (cgui.stk.M),
            % update edit field
            set (cgui.stk.ui.ed_tran2, 'string', ...
                str2double (get (cgui.stk.ui.ed_tran2, 'string')) - 1);
            % then change coordinates according to edit field:
            cgui_tree ('stk_setcoord');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'set Ycoords for stack');
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_bpy'              % move currently activated image stack in Y
        if ~isempty (cgui.stk.M),
            % update edit field
            set (cgui.stk.ui.ed_tran2, 'string', ...
                str2double (get (cgui.stk.ui.ed_tran2, 'string')) + 1);
            % then change coordinates according to edit field:
            cgui_tree ('stk_setcoord');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'set Y coords for stack');
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_bmz'              % move currently activated image stack in Z
        if ~isempty (cgui.stk.M),
            % update edit field
            set (cgui.stk.ui.ed_tran3, 'string', ...
                str2double (get (cgui.stk.ui.ed_tran3, 'string')) - 1);
            % then change coordinates according to edit field:
            cgui_tree ('stk_setcoord');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'set Z coords for stack');
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_bpz'              % move currently activated image stack in Z
        if ~isempty (cgui.stk.M),
            % update edit field
            set (cgui.stk.ui.ed_tran3, 'string', ...
                str2double (get (cgui.stk.ui.ed_tran3, 'string')) + 1);
            % then change coordinates according to edit field:
            cgui_tree ('stk_setcoord');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'set Z coords for stack');
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_align'            % align current stack to previous stack
        if length (cgui.stk.M) > 1,
            % WOW matlab you are so cool! Use normxcorr2 to align
            % (register) the maximum intensity projections and adjust for
            % stack coordinates and voxel sizes:
            NC = normxcorr2 (cgui.stk.mM1 {end}, cgui.stk.mM1 {end-1});
            [i1 i2] = max (NC); [i1 i3] = max (i1);
            x = cgui.stk.voxel (1) * (i3      - size (cgui.stk.mM1 {end}, 2)) + ...
                cgui.stk.coord (end - 1, 1);
            y = cgui.stk.voxel (2) * (i2 (i3) - size (cgui.stk.mM1 {end}, 1)) + ...
                cgui.stk.coord (end - 1, 2);
            if size (cgui.stk.mM2 {end}, 1) > size (cgui.stk.mM2 {end-1}, 1),
                NC = normxcorr2 (cgui.stk.mM2 {end-1}, cgui.stk.mM2 {end});
            else
                NC = normxcorr2 (cgui.stk.mM2 {end},   cgui.stk.mM2 {end-1});
            end
            [i1 i2] = max (NC); [i1 i3] = max (i1);
            z = cgui.stk.voxel (3) * (i2 (i3) - size (cgui.stk.mM2 {end}, 1)) + ...
                cgui.stk.coord (end - 1, 3);
            % set stack coordinates:
            set (cgui.stk.ui.ed_tran1, 'string', num2str (x));
            set (cgui.stk.ui.ed_tran2, 'string', num2str (y));
            set (cgui.stk.ui.ed_tran3, 'string', num2str (z));
            cgui_tree ('stk_setcoord');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'tried aligning stacks');
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_zero'             % set the coordinates of stack to zero
        if ~isempty (cgui.stk.M),
            set (cgui.stk.ui.ed_tran1, 'string', num2str (0));
            set (cgui.stk.ui.ed_tran2, 'string', num2str (0));
            set (cgui.stk.ui.ed_tran3, 'string', num2str (0));
            cgui_tree ('stk_setcoord'); % activate stk_ panel for edit
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_setcoord'         % set the coordinates according to edit fields
        % both entries in edit fields and button actions lead to here
        if ~isempty (cgui.stk.M),
            cgui.stk.coord (end, :) = [str2double(get (cgui.stk.ui.ed_tran1, 'string')), ...
                str2double(get (cgui.stk.ui.ed_tran2, 'string')),...
                str2double(get (cgui.stk.ui.ed_tran3, 'string'))];
            % do not redraw everything, just move coordinates of handles.
            % That's much much quicker of course:
            if get (cgui.stk.ui.r1, 'value'),
                for ward = 0 : 2,
                    xdata = get (cgui.stk.HP {end-ward}, 'xdata');
                    xdata = xdata - min (min (xdata));
                    set (cgui.stk.HP {end-ward}, 'xdata', xdata + cgui.stk.coord (end, 1) - .5);
                    ydata = get (cgui.stk.HP {end-ward}, 'ydata');
                    ydata = ydata - min (min (ydata));
                    set (cgui.stk.HP {end-ward}, 'ydata', ydata + cgui.stk.coord (end, 2) - .5);
                    zdata = get (cgui.stk.HP {end-ward}, 'zdata');
                    zdata = zdata - min (min (zdata));
                    set (cgui.stk.HP {end-ward}, 'zdata', zdata + cgui.stk.coord (end, 3) - .5);
                end
            end
            if get (cgui.stk.ui.r2, 'value'),
                xdata = get (cgui.stk.HP {end}, 'xdata');
                xdata = xdata - min (min (xdata));
                set (cgui.stk.HP {end}, 'xdata', xdata + cgui.stk.coord (end, 1) - .5);
                ydata = get (cgui.stk.HP {end}, 'ydata');
                ydata = ydata - min (min (ydata));
                set (cgui.stk.HP {end}, 'ydata', ydata + cgui.stk.coord (end, 2) - .5);
                zdata = get (cgui.stk.HP {end} ,'zdata');
                zdata = zdata - min (min (zdata));
                set (cgui.stk.HP {end}, 'zdata', zdata + cgui.stk.coord (end, 3) - .5);
            end
            %  thr_ is also affected but not updated, would take too long!
        end
        setactivepanel_tree (1); % activate stk_ panel for edit
    case 'stk_setvoxel'         % set the voxel size according to edit fields
        % edit field entries call this function
        cgui.stk.voxel = [str2double(get (cgui.stk.ui.ed_vox1, 'string')), ...
            str2double(get (cgui.stk.ui.ed_vox2, 'string')), ...
            str2double(get (cgui.stk.ui.ed_vox3, 'string'))];
        % redraw stack and thresholded images:
        cgui_tree ('stk_image'); cgui_tree ('thr_image'); % again thr_ is also affected!
        setactivepanel_tree (1); % activate stk_ panel for edit
        
    case 'stk_auto'             % fully automated attempt to tree from stack reconstruction
        if ~isempty(cgui.stk.M),
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'thresholding'});
            cgui_tree ('thr_thr');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'cleaning binary'});
            cgui_tree ('thr_clean');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'skeletonizing'});
            cgui_tree ('skl_skel');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'cleaning skeleton'});
            cgui_tree ('skl_clean');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'finding soma'});
            cgui_tree ('skl_soma');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'floodfilling connections'});
            cgui_tree ('skl_tCN');
            %             set(cgui.vis.ui.txt1,'string',{'AUTO:','calculating orientation similariy'});
            %             cgui_tree ('skl_dCN');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'drawing trees'});
            cgui_tree ('mtr_MST');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'cleaning trees'});
            for ward = 1 : 5, cgui_tree ('mtr_clean'); end
            while get (cgui.cat.ui.f1, 'value') < ...
                    length (cgui.cat.trees {cgui.cat.i2tree}),
                set (cgui.cat.ui.f1, 'value', get (cgui.cat.ui.f1, 'value') + 1);
                cgui_tree ('cat_selecttree');
                for ward = 1 : 5, cgui_tree ('mtr_clean'); end
            end
            set (cgui.cat.ui.f1,   'value', 1); cgui_tree ('cat_selecttree');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'resampling trees'});
            cgui_tree ('mtr_resample');
            while get (cgui.cat.ui.f1, 'value') < ...
                    length (cgui.cat.trees {cgui.cat.i2tree}),
                set (cgui.cat.ui.f1, 'value', get (cgui.cat.ui.f1, 'value') + 1);
                cgui_tree ('cat_selecttree');
                cgui_tree ('mtr_resample');
            end            
            set (cgui.cat.ui.f1,   'value', 1); cgui_tree ('cat_selecttree');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'smoothing trees'});
            cgui_tree ('mtr_smooth');
            while get (cgui.cat.ui.f1, 'value') < ... 
                    length (cgui.cat.trees {cgui.cat.i2tree}),
                set (cgui.cat.ui.f1, 'value', get (cgui.cat.ui.f1, 'value') + 1);
                cgui_tree ('cat_selecttree');
                cgui_tree ('mtr_smooth');
            end          
            set (cgui.cat.ui.f1,   'value', 1); cgui_tree ('cat_selecttree');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'quadratic diameter fitting'});
            cgui_tree ('mtr_quadfit');
            while get (cgui.cat.ui.f1, 'value') < ...
                    length (cgui.cat.trees {cgui.cat.i2tree}),
                set (cgui.cat.ui.f1, 'value', get (cgui.cat.ui.f1, 'value') + 1);
                cgui_tree ('cat_selecttree');
                cgui_tree ('mtr_quadfit');
            end    
            set (cgui.cat.ui.f1,   'value', 1); cgui_tree ('cat_selecttree');
            set (cgui.vis.ui.txt1, 'string', {'AUTO:', 'automated model-based reconstruction'});
        end
    case 'stk_r1'               % radio button toggle (maximum projections)
        set (cgui.stk.ui.r2, 'value', 0); % its either or (so no slicer)
        cgui_tree ('stk_image'); % redraw stk_ graphical output: image stacks
    case 'stk_r2'               % radio button toggle (slice view)
        set (cgui.stk.ui.r1, 'value', 0); % its either or (so no max proj.)
        cgui_tree ('stk_image'); % redraw stk_ graphical output: image stacks
    case 'stk_update'           % update maximum intensity projections of image stacks
        cgui.stk.imM1 = cell (1, length (cgui.stk.M));
        cgui.stk.imM2 = cell (1, length (cgui.stk.M));
        cgui.stk.imM3 = cell (1, length (cgui.stk.M));
        cgui.stk.mM1  = cell (1, length (cgui.stk.M));
        cgui.stk.mM2  = cell (1, length (cgui.stk.M));
        cgui.stk.mM3  = cell (1, length (cgui.stk.M));
        for ward = 1 : length (cgui.stk.M),
% %             [cgui.stk.mM1{ward} cgui.stk.imM1{ward}] = max (cgui.stk.M{ward}, [], 3);
%             [cgui.stk.mM1{ward} ] = max(cgui.stk.M{ward}, [], 3);
%             [cgui.stk.mM2{ward} ] = max (cgui.stk.M{ward}, [], 2); %cgui.stk.imM2{ward}
%             cgui.stk.mM2  {ward} = squeeze (cgui.stk.mM2  {ward})';
% %             cgui.stk.imM2 {ward} = squeeze (cgui.stk.imM2 {ward})';
%             [cgui.stk.mM3{ward} ] = max (cgui.stk.M{ward}, [], 1); %cgui.stk.imM3{ward}
%             cgui.stk.mM3  {ward} = squeeze (cgui.stk.mM3  {ward})';
% %             cgui.stk.imM3 {ward} = squeeze (cgui.stk.imM3 {ward})';




            [cgui.stk.mM1{ward} cgui.stk.imM1{ward}] = max (cgui.stk.M{ward}, [], 3);
            [cgui.stk.mM2{ward} cgui.stk.imM2{ward}] = max (cgui.stk.M{ward}, [], 2);
            cgui.stk.mM2  {ward} = squeeze (cgui.stk.mM2  {ward})';
            cgui.stk.imM2 {ward} = squeeze (cgui.stk.imM2 {ward})';
            [cgui.stk.mM3{ward} cgui.stk.imM3{ward}] = max (cgui.stk.M{ward}, [], 1);
            cgui.stk.mM3  {ward} = squeeze (cgui.stk.mM3  {ward})';
            cgui.stk.imM3 {ward} = squeeze (cgui.stk.imM3 {ward})';



















        end
    case 'stk_trim'             % trim stacks after part deletion
        if ~isempty (cgui.stk.M),
            for ward = 1 : length (cgui.stk.M),
                % check out the limits of non-zero image values:
                [i1 i2 i3] = ind2sub (size (cgui.stk.M {ward}), find (cgui.stk.M {ward} > 0));
                % tighten the matrix:
                cgui.stk.M {ward} = cgui.stk.M {ward} (min (i1) : max (i1), ...
                    min (i2) : max (i2), min (i3) : max (i3));
                % adjust the coordinates:
                cgui.stk.coord (ward, :) = cgui.stk.coord (ward, :) + ...
                    round ([(min (i2) - 1)*cgui.stk.voxel(1), ...
                    (min (i1) - 1)*cgui.stk.voxel(2), ...
                    (min (i3) - 1)*cgui.stk.voxel(3)]);
            end
            cgui_tree ('stk_update'); % update stk_ maximum intensity projections
            cgui_tree ('stk_image');  % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image');  % redraw thr_ graphical output: thresholded stacks
        end
    case 'stk_image'            % update graphical output for image stacks
        
        figure (cgui.ui.F); % recover figure control
        if ~isempty (cgui.stk.HP), % redraw all handles, so first delete them
            for ward =  1: length (cgui.stk.HP),
                delete (cgui.stk.HP {ward});
            end
            cgui.stk.HP = {};
        end
        if isempty(cgui.stk.HP)
            for ward = 1 : length (cgui.stk.M)
                cgui.stk.HP{ward} = surface;
            end
        end
        % if 3 stacks on same coordinates stack is considered RGB (but many
        % restrictions there!!
        RGBflag = (size (cgui.stk.coord, 1) == 3) && ...
            (sum (cgui.stk.coord (2, :) - cgui.stk.coord (1, :)) == 0) && ...
            (sum (cgui.stk.coord (3, :) - cgui.stk.coord (1, :)) == 0);
        if RGBflag
            if get (cgui.stk.ui.r1, 'value') % display the three maximum intensity projections
                B1 = cat (3, flipud (cgui.stk.mM1 {1}), flipud (cgui.stk.mM1 {2}), flipud (cgui.stk.mM1 {3}));
                B2 = cat (3, flipud (cgui.stk.mM2 {1}), flipud (cgui.stk.mM2 {2}), flipud (cgui.stk.mM2 {3}));
                B3 = cat (3, flipud (cgui.stk.mM3 {1}), flipud (cgui.stk.mM3 {2}), flipud (cgui.stk.mM3 {3}));
                B1 = double (B1) / double (max (max (max (cgui.stk.M {1}))));
                B2 = double (B2) / double (max (max (max (cgui.stk.M {1}))));
                B3 = double (B3) / double (max (max (max (cgui.stk.M {1}))));
                % map all three maximum projections on rectangular
                % surfaces:
                cgui.stk.HP {end+1} = surface ( ...
                    - .5 * cgui.stk.voxel (1) + (cgui.stk.coord (1, 1) + ...
                    cgui.stk.voxel (1) * ...
                    [0 size(cgui.stk.M{1}, 2)-1; 0 size(cgui.stk.M{1}, 2)-1]), ...
                    - .5 * cgui.stk.voxel (2) + (cgui.stk.coord (1, 2) + ...
                    cgui.stk.voxel (2) * ...
                    [size(cgui.stk.M{1}, 1)-1 size(cgui.stk.M{1}, 1)-1; 0 0]), ...
                    (cgui.stk.coord (1, 3) + zeros (2, 2)));
                set (cgui.stk.HP {end}, 'CData', B1, ...
                    'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                    'facealpha', cgui.stk.alpha);
                cgui.stk.HP {end+1} = surface ( ...
                    - .5 * cgui.stk.voxel (1) + (cgui.stk.coord (1, 1) + ...
                    cgui.stk.voxel (1) * ...
                    [0 size(cgui.stk.M{1}, 2)-1; 0  size(cgui.stk.M{1},2)-1]), ...
                    (cgui.stk.coord (1, 2) + zeros (2, 2)), ...
                    - .5 * cgui.stk.voxel (3) + (cgui.stk.coord (1, 3) + ...
                    cgui.stk.voxel (3) * ...
                    [size(cgui.stk.M{1}, 3)-1 size(cgui.stk.M{1}, 3)-1; 0 0]));
                set (cgui.stk.HP {end}, 'CData', B3, ...
                    'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                    'facealpha', cgui.stk.alpha);
                cgui.stk.HP {end+1} = surface ( ...
                    (cgui.stk.coord (1, 1) + zeros (2, 2)), ...
                    - .5 * cgui.stk.voxel (2) + (cgui.stk.coord (1, 2)+ ...
                    cgui.stk.voxel (2) * ...
                    [0 size(cgui.stk.M{1},1)-1; 0 size(cgui.stk.M{1},1)-1]), ...
                    - .5 * cgui.stk.voxel (3) + (cgui.stk.coord (1, 3) + ...
                    cgui.stk.voxel (3) * ...
                    [size(cgui.stk.M{1}, 3)-1 size(cgui.stk.M{1}, 3)-1; 0 0]));
                set (cgui.stk.HP {end}, 'CData', B2, ...
                    'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                    'facealpha', cgui.stk.alpha);
            end
            if get (cgui.stk.ui.r2, 'value'), % draw slices through the stack
                % the orientation of the slices depends on the view but most
                % often will be xy-slice (same as grid):
                switch cgui.modes.view,
                    case 2
                        cM = ceil ((cgui.vis.iM - cgui.stk.coord (1, 2)) / cgui.stk.voxel (2)) + 1;
                        if (cM >= 1) && (cM <= size (cgui.stk.M {1}, 2)),
                            cgui.stk.HP {end+1} = surface ((cgui.stk.coord (1, 1) + ...
                                cgui.stk.voxel (1) * ...
                                [0 size(cgui.stk.M{1}, 2)-1; 0 size(cgui.stk.M{1}, 2)-1]), ...
                                cgui.vis.iM + zeros (2, 2), ...
                                (cgui.stk.coord (1, 3) + ...
                                cgui.stk.voxel (3) * ...
                                [size(cgui.stk.M{1}, 3)-1 size(cgui.stk.M{1}, 3)-1; 0 0]));
                            B = cat (3, ...
                                flipud (squeeze (cgui.stk.M {1} (:, cM, :))), ...
                                flipud (squeeze (cgui.stk.M {2} (:, cM, :))), ...
                                flipud (squeeze (cgui.stk.M {3} (:, cM, :))));
                            B = double (B) / double (max (max (max (cgui.stk.M {1}))));
                            set (cgui.stk.HP {end}, 'CData', B, ...
                                'FaceColor', 'texturemap', 'Edgecolor', 'none',...
                                'facealpha', cgui.stk.alpha);
                        end
                    case 3
                        cM = ceil ((cgui.vis.iM - cgui.stk.coord (1, 1)) / cgui.stk.voxel (1)) + 1;
                        if (cM >= 1) && (cM <= size (cgui.stk.M {1}, 1)),
                            cgui.stk.HP {end+1} = surface (cgui.vis.iM + zeros (2, 2), ...
                                (cgui.stk.coord (1, 2) + ...
                                cgui.stk.voxel(2) * ...
                                [0 size(cgui.stk.M{1}, 1)-1; 0 size(cgui.stk.M{1}, 1)-1]), ...
                                (cgui.stk.coord (1, 3) + ...
                                cgui.stk.voxel (3) * ...
                                [size(cgui.stk.M{1}, 3)-1 size(cgui.stk.M{1}, 3)-1; 0 0]));
                            B = cat (3, ...
                                flipud (squeeze (cgui.stk.M {1} (cM, :, :))), ...
                                flipud (squeeze (cgui.stk.M {2} (cM, :, :))), ...
                                flipud (squeeze (cgui.stk.M {3} (cM, :, :))));    
                            B = double (B) / double (max (max (max (cgui.stk.M {1}))));
                            set (cgui.stk.HP {end}, 'CData', B, ...
                                'FaceColor', 'texturemap', 'Edgecolor', 'none',...
                                'facealpha', cgui.stk.alpha);
                        end
                    otherwise
                        cM = ceil ((cgui.vis.iM - cgui.stk.coord (1, 3)) / cgui.stk.voxel (3)) + 1;
                        if (cM >= 1) && (cM <= size (cgui.stk.M{1}, 3)),
                            cgui.stk.HP {end+1} = surface ((cgui.stk.coord (1, 1) + ...
                                cgui.stk.voxel (1) * ...
                                [0 size(cgui.stk.M{1}, 2)-1; 0 size(cgui.stk.M{1}, 2)-1]), ...
                                (cgui.stk.coord (1, 2) + ...
                                cgui.stk.voxel (2) * ...
                                [size(cgui.stk.M{1}, 1)-1 size(cgui.stk.M{1}, 1)-1; 0 0]), ...
                                cgui.vis.iM + zeros (2, 2));
                            B = cat (3, ...
                                flipud (cgui.stk.M {1} (:, :, cM)), ...
                                flipud (cgui.stk.M {2} (:, :, cM)), ...
                                flipud (cgui.stk.M {3} (:, :, cM)));
                            B = double (B) / double (max (max (max (cgui.stk.M {1}))));
                            set (cgui.stk.HP {end}, 'CData', B, ...
                                'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                                'facealpha', cgui.stk.alpha);
                        end
                end
            end
        else
            if get (cgui.stk.ui.r1, 'value') % display the three maximum intensity projections
                for ward = 1 : length (cgui.stk.M),
                    if get (cgui.thr.ui.r3, 'value') && (~isempty (cgui.thr.BW)),
                        % apply image threshold from thr_ panel and display
                        % the index of the third dimension in the maximum
                        % intensity projections instead of the brightness.
                        B1 = cgui.stk.imM1 {ward} / size (cgui.stk.M {ward}, 3);
                        B2 = cgui.stk.imM2 {ward} / size (cgui.stk.M {ward}, 2);
                        B3 = cgui.stk.imM3 {ward} / size (cgui.stk.M {ward}, 1);
                        B1 (~max (cgui.thr.BW {ward}, [], 3)) = 0;
                        B2 (~squeeze (max (cgui.thr.BW {ward}, [], 2))') = 0;
                        B3 (~squeeze (max (cgui.thr.BW {ward}, [], 1))') = 0;
                    else
                        B1 = cgui.stk.mM1 {ward}; B2 = cgui.stk.mM2 {ward};
                        B3 = cgui.stk.mM3 {ward};
                    end
                    % map all three maximum projections on rectangular
                    % surfaces:
                    cgui.stk.HP {end+1} = surface ( ...
                        - .5 * cgui.stk.voxel (1) + (cgui.stk.coord (ward, 1) + ...
                        cgui.stk.voxel (1) * ...
                        [0 size(cgui.stk.M{ward}, 2)-1; 0 size(cgui.stk.M{ward}, 2)-1]),...
                        - .5 * cgui.stk.voxel (2) + (cgui.stk.coord (ward, 2) + ...
                        cgui.stk.voxel (2) * ...
                        [size(cgui.stk.M{ward}, 1)-1 size(cgui.stk.M{ward}, 1)-1; 0 0]),...
                        (cgui.stk.coord (ward, 3) + repmat (0, 2, 2)));
                    set (cgui.stk.HP {end}, 'CData', flipud (double (B1)), ...
                        'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                        'facealpha', cgui.stk.alpha);
                    cgui.stk.HP {end+1} = surface ( ...
                        - .5 * cgui.stk.voxel (1) + (cgui.stk.coord (ward, 1)+ ...
                        cgui.stk.voxel (1) * ...
                        [0 size(cgui.stk.M{ward}, 2)-1; 0 size(cgui.stk.M{ward}, 2)-1]),...
                        (cgui.stk.coord (ward, 2) + repmat (0, 2, 2)), ...
                        - .5 * cgui.stk.voxel (3) + (cgui.stk.coord (ward, 3) + ...
                        cgui.stk.voxel (3) * ...
                        [size(cgui.stk.M{ward}, 3)-1 size(cgui.stk.M{ward}, 3)-1; 0 0]));
                    set (cgui.stk.HP {end}, 'CData', flipud (double (B3)),...
                        'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                        'facealpha', cgui.stk.alpha);
                    cgui.stk.HP {end+1} = surface ( ...
                        (cgui.stk.coord (ward, 1) + repmat (0, 2, 2)), ...
                        - .5 * cgui.stk.voxel (2) + (cgui.stk.coord (ward, 2) + ...
                        cgui.stk.voxel (2) * ...
                        [0 size(cgui.stk.M{ward}, 1)-1; 0 size(cgui.stk.M{ward}, 1)-1]),...
                        - .5 * cgui.stk.voxel (3) + (cgui.stk.coord (ward, 3) + ...
                        cgui.stk.voxel (3) * ...
                        [size(cgui.stk.M{ward}, 3)-1 size(cgui.stk.M{ward}, 3)-1; 0 0]));
                    set (cgui.stk.HP {end}, 'CData', flipud (double (B2)),...
                        'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                        'facealpha', cgui.stk.alpha);
                end
            end
            if get (cgui.stk.ui.r2, 'value'), % draw slices through the stack
                % the orientation of the slices depends on the view but most
                % often will be xy-slice (same as grid):
                switch cgui.modes.view,
                    case 2
                        for ward = 1 : length (cgui.stk.M),
                            cM = ceil ((cgui.vis.iM - cgui.stk.coord (ward, 1)) / ...
                                cgui.stk.voxel(1)) + 1;
                            if (cM >= 1) && (cM <= size (cgui.stk.M {ward}, 1)),
                                cgui.stk.HP {end+1} = surface ( ...
                                    cgui.stk.coord (ward, 1) + cgui.stk.voxel (1) * ...
                                    [0 size(cgui.stk.M{ward}, 2)-1; ...
                                    0 size(cgui.stk.M{ward}, 2)-1], ...
                                    cgui.vis.iM + zeros (2, 2), ...
                                    cgui.stk.coord (ward, 3) + cgui.stk.voxel (3) * ...
                                    [0 0; size(cgui.stk.M{ward}, 3)-1 ...
                                    size(cgui.stk.M{ward}, 3)-1]);
                                set (cgui.stk.HP {end}, 'CData', ...
                                    double (squeeze (cgui.stk.M {ward} (cM, :, :)))', ...
                                    'FaceColor', 'texturemap', 'Edgecolor', 'none', ...
                                    'facealpha', cgui.stk.alpha);
                            end
                        end
                    case 3
                        for ward = 1 : length (cgui.stk.M),
                            cM = ceil ((cgui.vis.iM - cgui.stk.coord (ward, 2)) / ...
                                cgui.stk.voxel (2)) + 1;
                            if (cM >= 1) && (cM <= size (cgui.stk.M {ward}, 2)),
                                cgui.stk.HP{end+1} = surface ( ...
                                    cgui.vis.iM + zeros (2, 2), ...
                                    cgui.stk.coord (ward, 2) + cgui.stk.voxel (2) * ...
                                    [0 size(cgui.stk.M{ward}, 1)-1; ...
                                    0 size(cgui.stk.M{ward}, 1)-1], ...
                                    cgui.stk.coord (ward, 3) + cgui.stk.voxel (3) * ...
                                    [0 0; size(cgui.stk.M{ward}, 3)-1 ...
                                    size(cgui.stk.M{ward}, 3)-1]);
                                set (cgui.stk.HP {end}, 'CData', ...
                                    double (squeeze (cgui.stk.M {ward} (:, cM, :)))', ...
                                    'FaceColor', 'texturemap', 'Edgecolor', 'none',...
                                    'facealpha', cgui.stk.alpha);
                            end
                        end
                    otherwise
                        for ward = 1 : length (cgui.stk.M),
                            cM = ceil ((cgui.vis.iM - cgui.stk.coord (ward, 3)) / ...
                                cgui.stk.voxel (3)) + 1;
                            if (cM >= 1) && (cM <= size (cgui.stk.M {ward}, 3)),
%                                 cgui.stk.HP{end+1} = surface ( ...
%                                     cgui.stk.coord (ward, 1) + cgui.stk.voxel (1) * ...
%                                     [0 size(cgui.stk.M{ward}, 2)-1; ...
%                                     0 size(cgui.stk.M{ward}, 2)-1], ...
%                                     cgui.stk.coord (ward, 2) + cgui.stk.voxel (2) * ...
%                                     [0 0; size(cgui.stk.M{ward}, 1)-1 ...
%                                     size(cgui.stk.M{ward}, 1)-1], ...
%                                     cgui.vis.iM + zeros (2, 2));
                                set (cgui.stk.HP{ward}, 'XData',cgui.stk.coord (ward, 1) + cgui.stk.voxel (1) * [0 size(cgui.stk.M{ward}, 2)-1; 0 size(cgui.stk.M{ward}, 2)-1] , 'YData',cgui.stk.coord (ward, 2) + cgui.stk.voxel (2) * [0 0; size(cgui.stk.M{ward}, 1)-1 size(cgui.stk.M{ward}, 1)-1] ,'ZData', cgui.vis.iM + zeros (2, 2))
%                                 [m sys] =memory;
%                                 if m.MaxPossibleArrayBytes < sys.SystemMemory /4  % if memory gets low, flush opengl cache
%                                     set(gcf,'Renderer','zbuffer')
%                                     set(gcf,'Renderer','opengl')
%                                 end
                                set (cgui.stk.HP {ward}, 'CData', ...
                                    double (cgui.stk.M {ward} (:, :, cM)), ...
                                    'FaceColor', 'texturemap', 'Edgecolor', 'none',...
                                    'facealpha', cgui.stk.alpha);
                            end
                        end
                end
            end
        end
        axis (cgui.ui.g1, 'tight', 'equal');
        cgui_tree ('vis_xclim'); % update colormap limits in edit fields
        
    case 'thr_inform'           % text output on percentage thresholded
        str = get (cgui.vis.ui.txt2, 'string'); % replace adequate str-cell
        if ~isempty (cgui.thr.BW)
            pon = zeros (length (cgui.thr.BW), 1); pall = zeros (length (cgui.thr.BW), 1);
            for ward = 1 : length (cgui.thr.BW)
                pall (ward) = numel         (cgui.thr.BW {ward});
                pon  (ward) = sum (sum (sum (cgui.thr.BW {ward})));
            end
            str{2} = ['thr: ' num2str(round (1000 * sum (pon) / sum (pall)) / 10) ' % in'];
        else
            str{2} = '';
        end
        set (cgui.vis.ui.txt2, 'string', str); % and put back on text screen
    case 'thr_setstd'           % typical dynamic threshold is close to std/2 (brightness)
        if ~isempty (cgui.stk.M),
            stdthr = 0;
            for ward = 1 : length (cgui.stk.M),
                stdthre = ceil (std (double (reshape (cgui.stk.M {ward}, ...
                    numel (cgui.stk.M {ward}), 1))));
                if stdthre > stdthr / 2, stdthr = stdthre / 2; end;
            end
            set (cgui.thr.ui.ed_thr1, 'string', num2str (stdthr));
        end
    case 'thr_thr'              % threshold brightness levels> value in edit field
        % thresholds are only updated when buttons are pressed not when
        % threshold edit field is changed! Threshold image is discarded
        % when stack images are altered!
        if ~isempty (cgui.stk.M),
            cgui.thr.BW = {};
            if get (cgui.thr.ui.t_dyn, 'value'), % dynamic thresholding
                % dynamic thresholding compares brightness with neighboring
                % brightness levels by performing a quick 2D (xy) convolution
                HW = waitbar (0, 'dynamic thresholding...');
                set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
                for ward = 1 : length (cgui.stk.M),
                    waitbar (ward / length (cgui.stk.M), HW);
                    % BW matrices contain binary data obtained from the tiled image
                    % stacks M from the stk_ panel.
                    M = max (cgui.stk.M {ward}, [], 3);
                    maxmaxM = max (max (max (cgui.stk.M {ward})));
                    M = [zeros(size (M, 1), 32)  M  zeros(size (M, 1), 32)];
                    M = [zeros(32, size (M, 2)); M ;zeros(32, size (M, 2))];
                    M (M == 0) = 2 * mean (mean (mean (M)));
                    M2 = convn (M, ones (32, 32) /32 /32, 'same'); % local threshold
                    M2 = M2 (33 : end - 32, 33 : end - 32);
                    % + threshold offset which is typically std
                    % (brightness, see "thr_setstd")
                    thr = str2double (get (cgui.thr.ui.ed_thr1, 'string'));
                    for te = 1 : size (cgui.stk.M {ward}, 3),
                        % but also all that is 80 % of max is also
                        % automatically inside:
                        cgui.thr.BW {ward} (:, :, te)  = ...
                            (cgui.stk.M {ward} (:, :, te) > M2 + thr) | ...
                            (cgui.stk.M {ward} (:, :, te) > .8 * maxmaxM);
                    end
                end
                close (HW);
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'dynamic threshold at', ...
                    get(cgui.thr.ui.ed_thr1, 'string')});
            else
                for ward = 1:length(cgui.stk.M),
                    % BW matrices contain binary data obtained from the tiled image
                    % stacks M from the stk_ panel.
                    cgui.thr.BW {ward} = cgui.stk.M {ward} > ...
                        str2double (get (cgui.thr.ui.ed_thr1, 'string'));
                end
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'threshold at', ...
                    get(cgui.thr.ui.ed_thr1, 'string')});
            end
            cgui_tree ('stk_image'); % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image'); % redraw thr_ graphical output: thresholded stacks
            cgui_tree ('skl_showpanels'); % enable/disable skl_ ui elements
            cgui_tree ('thr_inform'); % text output on percentage thresholded
        end
        setactivepanel_tree (2); % activate thr_ panel for edit
    case 'thr_thr2'             % threshold brightness levels< value in edit field
        % thresholds are only updated when buttons are pressed not when
        % threshold edit field is changed! Threshold image is discarded
        % when stack images are altered! (This way threshold was not much
        % tested and probably doesn't work)
        if ~isempty (cgui.stk.M),
            cgui.thr.BW = {};
            if get (cgui.thr.ui.t_dyn, 'value'), % dynamic thresholding
                % dynamic thresholding compares brightness with neighboring
                % brightness levels by performing a quick 2D (xy) convolution
                HW = waitbar (0, 'dynamic thresholding...');
                set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
                for ward = 1 : length (cgui.stk.M),
                    waitbar (ward / length (cgui.stk.M), HW);
                    % BW matrices contain binary data obtained from the tiled image
                    % stacks M from the stk_ panel.
                    M = min (cgui.stk.M {ward}, [], 3);
                    maxmaxM = max (max (max (cgui.stk.M {ward})));
                    M = [zeros(size (M, 1), 32)  M  zeros(size (M, 1), 32)];
                    M = [zeros(32, size (M, 2)); M ;zeros(32, size (M, 2))];
                    M (M == 0) = 2 * mean (mean (mean (M)));
                    M2 = convn (M, ones (32, 32) /32 /32, 'same'); % local threshold
                    M2 = M2 (33 : end - 32, 33 : end - 32);
                    % - threshold offset which is typically std
                    % (brightness, see "thr_setstd")
                    thr = str2double (get (cgui.thr.ui.ed_thr1, 'string'));
                    for te = 1 : size (cgui.stk.M {ward}, 3),
                        % but also all that is 80 % of max is also
                        % automatically inside:
                        cgui.thr.BW {ward} (:, :, te)  = ...
                            (cgui.stk.M {ward} (:, :, te) < M2 - thr) | ...
                            (cgui.stk.M {ward} (:, :, te) < .2 * maxmaxM);
                    end
                end
                close (HW);
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'dynamic threshold at', ...
                    get(cgui.thr.ui.ed_thr1, 'string')});
            else
                for ward = 1 : length (cgui.stk.M),
                    % BW matrices contain binary data obtained from the tiled image
                    % stacks M from the stk_ panel.
                    cgui.thr.BW {ward} = cgui.stk.M {ward} < ...
                    str2double (get (cgui.thr.ui.ed_thr1, 'string'));
                end
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'threshold at <', ...
                    get(cgui.thr.ui.ed_thr1, 'string')});
            end
            cgui_tree ('stk_image'); % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image'); % redraw thr_ graphical output: thresholded stacks
            cgui_tree ('skl_showpanels'); % enable/disable skl_ ui elements
            cgui_tree ('thr_inform'); % text output on percentage thresholded
        end
        setactivepanel_tree (2); % activate thr_ panel for edit
    case 'thr_clean'            % clean the thresholded image stack of very small pieces
        if ~isempty (cgui.thr.BW),
            % this is a matlab image processing toolbox function, see
            % "bwareaopen"
            HW = waitbar (0, 'filling in...');
            set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
            for ward = 1 : length (cgui.thr.BW),
                waitbar (ward / length (cgui.thr.BW), HW);
                cgui.thr.BW {ward} = bwareaopen (cgui.thr.BW {ward}, ...
                    str2double (get (cgui.thr.ui.ed_clean1, 'string')), 26);
            end
            close (HW);
            cgui_tree ('stk_image'); % redraw stk_ graphical output: image stacks
            cgui_tree ('thr_image'); % redraw thr_ graphical output: thresholded stacks
            cgui_tree ('thr_inform'); % text output on percentage thresholded
        end
        setactivepanel_tree (2); % activate thr_ panel for edit
    case 'thr_r1'               % toggle radio buttons: 2D tiles max image projection
        % little tiles on the projection images
        set (cgui.thr.ui.r2, 'value', 0); % it's either the tiles or full 3D cubes
        cgui_tree ('thr_image'); % redraw thr_ graphical output: thresholded stacks
    case 'thr_r2'               % toggle radio buttons: 3D cubes
        % 3D cubes at threshold brightness value
        set (cgui.thr.ui.r1, 'value', 0); % it's either this or 2D tiles on projection images
        cgui_tree ('thr_image'); % redraw thr_ graphical output: thresholded stacks
    case 'thr_image'            % main graphical updating function for thresholded images
        figure (cgui.ui.F); % recover figure control
        if ~isempty (cgui.thr.HP), % eliminate graphical objects
            for ward = 1 : length (cgui.thr.HP),
                delete (cgui.thr.HP {ward});
            end
            cgui.thr.HP = {};
        end
        if get (cgui.thr.ui.r1, 'value'), % thresholded image as transparent overlay
            for ward = 1 : length (cgui.thr.BW),
                % small 2D tiles which are spread all over the max
                % projection (on all projections one at a time):
                cX = [0 1 1 0] - 0.5; cY = [0 0 1 1] - 0.5; % (X, Y) tiles
                maxBW = max (cgui.thr.BW{ward}, [], 3);
                [y x] = ind2sub (size (maxBW), find (maxBW));
                len = length (x);
                xc = repmat (reshape (x', numel (x), 1), 1, 4) - 1;
                yc = repmat (reshape (y', numel (y), 1), 1, 4) - 1;
                SX = cgui.stk.coord (ward, 1) + ...
                    cgui.stk.voxel (1) * repmat (cX, len, 1) + ...
                    cgui.stk.voxel (1) * xc - cgui.stk.voxel (1) / 2;
                SY = cgui.stk.coord (ward, 2) + ...
                    cgui.stk.voxel (2) *repmat(cY,len,1) + ...
                    cgui.stk.voxel (2) * yc - cgui.stk.voxel (2) / 2;
                SZ = cgui.stk.coord (ward ,3) + ...
                    zeros (size (SX)) - cgui.stk.voxel (3) / 2;
                cgui.thr.HP {end+1} = patch (SX', SY', SZ', [0 0 1]); % graphical object
                % transparency could be added here but is too slow for now:
                set (cgui.thr.HP {end}, 'facealpha', 1, 'edgecolor', 'none');
                cX = [0 1 1 0] - 0.5; cZ = [0 0 1 1] - 0.5; % (X, Z) tiles
                maxBW = squeeze (max (cgui.thr.BW {ward}, [], 1));
                [x z] = ind2sub (size (maxBW), find (maxBW));
                len = length (x);
                xc = repmat (reshape (x', numel (x), 1), 1, 4) - 1;
                zc = repmat (reshape (z', numel (z), 1), 1, 4) - 1;
                SX = cgui.stk.coord (ward, 1) + ...
                    cgui.stk.voxel (1) * repmat (cX, len, 1) + ...
                    cgui.stk.voxel (1) * xc - cgui.stk.voxel (1) / 2;
                SZ = cgui.stk.coord (ward, 3) + ...
                    cgui.stk.voxel (3) * repmat (cZ, len, 1) + ...
                    cgui.stk.voxel (3) * zc - cgui.stk.voxel (3) / 2;
                SY = cgui.stk.coord (ward, 2) + ...
                    zeros (size (SX)) - cgui.stk.voxel (2) / 2;
                cgui.thr.HP {end+1} = patch (SX', SY', SZ', [0 0 1]); % graphical object
                % transparency could be added here but is too slow for now:
                set (cgui.thr.HP {end}, 'facealpha', 1, 'edgecolor', 'none');
                cY = [0 1 1 0] - 0.5; cZ = [0 0 1 1] - 0.5; % (Y, Z) tiles
                maxBW = squeeze (max (cgui.thr.BW {ward}, [], 2));
                [y z] = ind2sub (size (maxBW), find (maxBW));
                len = length (y);
                yc = repmat (reshape (y', numel (y), 1), 1, 4) - 1;
                zc = repmat (reshape (z', numel (z), 1), 1, 4) - 1;
                SY = cgui.stk.coord (ward, 2) + ...
                    cgui.stk.voxel (2) * repmat (cY, len, 1) + ...
                    cgui.stk.voxel (2) * yc - cgui.stk.voxel (2) / 2;
                SZ = cgui.stk.coord (ward, 3) + ...
                    cgui.stk.voxel (3) * repmat (cZ, len, 1) + ...
                    cgui.stk.voxel (3) * zc - cgui.stk.voxel (3) / 2;
                SX = cgui.stk.coord (ward, 1) + ...
                    zeros (size (SY)) - cgui.stk.voxel (1) / 2;
                cgui.thr.HP {end+1} = patch (SX', SY', SZ', [0 0 1]); % graphical object
                % transparency could be added here but is too slow for now:
                set (cgui.thr.HP {end}, 'facealpha', 1, 'edgecolor', 'none');
            end
            axis (cgui.ui.g1, 'tight');
        end
        if get (cgui.thr.ui.r2, 'value'), % 3D cubes at threshold brightness value (SLOW!)
            for ward = 1 : length (cgui.thr.BW),
                % first resize (only XY), if computer is good enough maybe not
                % necessary
                warning ('off', 'MATLAB:divideByZero');
                nfac = 2; % resize factor
                BW = imresize (cgui.thr.BW {ward}, 1 / nfac);
                warning ('on',  'MATLAB:divideByZero');
                % identity cube:
                cX = [0 0 0 0; 0 1 1 0; 0 1 1 0; 1 1 0 0; 1 1 0 0; 1 1 1 1] - 0.5;
                cY = [0 0 1 1; 0 0 1 1; 1 1 1 1; 0 1 1 0; 0 0 0 0; 0 0 1 1] - 0.5;
                cZ = [0 1 1 0; 0 0 0 0; 1 1 0 0; 1 1 1 1; 1 0 0 1; 0 1 1 0] - 0.5;
                [y x z] = ind2sub (size (BW), find (BW)); len = length (x);
                xc = repmat (x, 1, 6);
                xc = repmat (reshape (xc', numel (xc), 1), 1, 4) - 1;
                yc = repmat (y, 1, 6);
                yc = repmat (reshape (yc', numel (yc), 1), 1, 4) - 1;
                zc = repmat (z, 1, 6);
                zc = repmat (reshape (zc', numel (zc), 1), 1, 4) - 1;
                SX = cgui.stk.coord (ward, 1) + ...
                    nfac * cgui.stk.voxel (1) * repmat (cX, len, 1) + ...
                    nfac * cgui.stk.voxel (1) * xc - cgui.stk.voxel (1) / 2;
                SY = cgui.stk.coord (ward, 2) + ...
                    nfac * cgui.stk.voxel (2) * repmat (cY, len, 1) + ...
                    nfac * cgui.stk.voxel (2) * yc - cgui.stk.voxel (2) / 2;
                SZ = cgui.stk.coord (ward, 3) + ...
                    cgui.stk.voxel (3) * repmat (cZ, len, 1) + ...
                    cgui.stk.voxel (3) * zc - cgui.stk.voxel (3) / 2;
                cgui.thr.HP {end+1} = patch (SX', SY', SZ', [0 0 1]); % graphical object
                % no transparency !
                set (cgui.thr.HP {end}, 'edgecolor', 'none', 'facealpha', 1);
            end
            axis (cgui.ui.g1, 'tight');
        end
        % third radio-button thr_ representation is an alteration of the
        % stk_image plot and is implemented there.
        
    case 'skl_showpanels'       % enable/disable skl_ ui elements
        % enable ui elements if there are some thresholded binary stacks
        % or some already skeletonized points:
        if (~isempty (cgui.thr.BW)) || (~isempty (cgui.skl.I)),
            % enable ui elements of skl_ panels:
            for te = 8,
                str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
                for ward = 3 : length (str),
                    HP = eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]);
                    set (HP, 'enable', 'on');
                    if strcmp (get (HP, 'style'), 'edit'),
                        set (HP, 'backgroundcolor', [0 0 0]); % weird stuff
                        set (HP, 'backgroundcolor', cgui.NColor.edit);
                    end
                end
            end
            % change background color of panel and radio button:
            set (cgui.skl.ui.c,  'backgroundcolor', [0 1 0]);
            set (cgui.skl.ui.r1, 'backgroundcolor', [0 1 0]);
            set (cgui.skl.ui.r2, 'backgroundcolor', [0 1 0]);
            set (cgui.skl.ui.r3, 'backgroundcolor', [0 1 0]);
        else
            % disable ui elements of skl_ panel:
            for te = 8,
                str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
                for ward = 3 : length (str),
                    HP = eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]);
                    set (HP, 'enable', 'off');
                end
            end
            % change background color of panel and radio button:
            set (cgui.skl.ui.c,  'backgroundcolor', [.7 1 .7]);
            set (cgui.skl.ui.r1, 'backgroundcolor', [.7 1 .7]);
            set (cgui.skl.ui.r2, 'backgroundcolor', [.7 1 .7]);
            set (cgui.skl.ui.r3, 'backgroundcolor', [.7 1 .7]);
        end
    case 'skl_inform'           % text output on number of skel points
        str = get (cgui.vis.ui.txt2, 'string'); % replace adequate str-cell
        if ~isempty (cgui.skl.S) || ~isempty (cgui.skl.I)
            str{3} = [num2str(size(cgui.skl.S, 1)) ' soma(ta) ' ...
                num2str(size(cgui.skl.I, 1)) ' points'];
        else
            str{3} = '';
        end
        set (cgui.vis.ui.txt2,'string', str); % and put back on text screen
    case 'skl_clear'            % clear starting points
        cgui.skl.S = []; % starting locations are in this matrix
        cgui_tree ('skl_image'); % update the graphical elements accordingly
        cgui_tree ('skl_inform'); % text output on number of skel points
        setactivepanel_tree (3); % activate skl_ panel for edit
    case 'skl_clearpoints'      % clear skeletonized points (is called by the D-button)
        cgui.skl.I   = []; % point coordinates of sekeletonized points
        cgui.skl.BI  = []; % brightness levels at those point coordinates
        cgui.skl.DI  = []; % extracted diameter values from thresholded image
        cgui.skl.LI  = []; % floodfill label information
        cgui.skl.CI  = []; % coordinates in stack and stack number for skel points
        cgui.skl.CN  = []; % combined connectivity matrix
        cgui.skl.dCN = []; % local orientation similarity connectivity matrix
        cgui.skl.tCN = []; % local threshold floodfill connectivity matrix
        cgui_tree ('skl_image'); % update the graphical elements accordingly
        cgui_tree ('skl_inform'); % text output on number of skel points
        setactivepanel_tree (3); % activate skl_ panel for edit
    case 'skl_soma'             % find somata in the 3D image stack
        % when diameter values were captured by binary distance during the
        % skeletonization (D button toggle) then the points with largest
        % diameter values could be somata. Find those that are sufficiently
        % far apart (see skl_clean).
        if ~isempty (cgui.skl.DI),
            [m iM1] = sort (cgui.skl.DI, 1, 'descend'); % sort descending D
            thrD = str2double (get (cgui.skl.ui.ed_soma1, 'string'));
            % index to all points above threshold diameter
            iM1 = iM1 (1 : find (m > thrD, 1, 'last')); % take those as starting points
            if isempty (iM1), % if none is large enough take biggest
                [m1 iM1] = max (cgui.skl.DI);
            end
            % clean points just like in skl_clean:
            EX = ones (length (iM1), 1);
            for counter = 1 : length (iM1)
                if EX (counter),
                    dis = sqrt (((cgui.skl.I (iM1 (counter), 1) - cgui.skl.I (iM1, 1)).^2) + ...
                        ((cgui.skl.I (iM1 (counter), 2) - cgui.skl.I (iM1, 2)).^2) + ...
                        ((cgui.skl.I (iM1 (counter), 3) - cgui.skl.I (iM1, 3)).^2));
                    % threshold distance from edit field:
                    idis = dis < 2 * thrD;
                    iL = cgui.skl.LI (iM1) == cgui.skl.LI (iM1 (counter));
                    idis (counter) = 0;
                    iL (counter) = 0;
                    EX (idis | iL) = 0; % eliminate points which are in the vicinity of this one
                end
            end
            S = cgui.skl.I (iM1 (logical (EX)), :); % the remaining ones are starting points
            % echo on text frame of vis_ panel and update all:
            if ~isempty (S),
                % add the new starting points to the matrix:
                cgui.skl.S = [cgui.skl.S; S];
                set (cgui.vis.ui.txt1, 'string', {'found', [num2str(size (S, 1)) ' somata']});
                cgui_tree ('skl_image'); % redraw skl_ graphical output: skeletonized points
                cgui_tree ('skl_inform'); % text output on number of skel points
            else
                set (cgui.vis.ui.txt1, 'string', {'found', 'no soma'});
            end
        end
        setactivepanel_tree (3); % activate skl_ panel for edit
    case 'skl_skel'             % skeletonizes the thresholded 3D image stack
        if ~isempty (cgui.thr.BW)
            cgui.skl.I   = []; % contains the coordinates of carrier points
            cgui.skl.BI  = []; % brightness levels corresponding to the coordinates
            cgui.skl.DI  = []; % extracted diameters from thresholded image
            cgui.skl.CI  = []; % coordinates in stack and stack number
            cgui.skl.LI  = []; % floodfill label information
            cgui.skl.tCN = []; % local threshold floodfill connectivity matrix
            cgui.skl.dCN = []; % orientation similarity connectivity matrix
            cgui.skl.CN  = []; % combined connectivity matrix
            for ward = 1 : length (cgui.thr.BW),
                % skeletonization according to papers by Palagyi and Kuba
                % see "skel_stack" although that won't help much!
                if cgui.skl.ui.t_close.Value
                    [i1 i2 i3] = skel_stack (cgui.thr.BW {ward}, 0.5, '-c -w');
                else
                    % skeletonizes the thresholded 3D image stack
                    % without closing image stack. Does not require image processing
                    % toolbox
                    [i1 i2 i3] = skel_stack (cgui.thr.BW {ward}, 0.5, '-w');
                end
                cgui.skl.I = [cgui.skl.I; ...
                    cgui.stk.coord(ward, 2)+cgui.stk.voxel(2)*(i1 - 2) ...
                    cgui.stk.coord(ward, 1)+cgui.stk.voxel(1)*(i2 - 2) ...
                    cgui.stk.coord(ward, 3)+cgui.stk.voxel(3)*(i3 - 2)];
                cgui.skl.CI = [cgui.skl.CI; [ones(size (i1, 1), 1)*ward i1 i2 i3]];
                cgui.skl.BI = [cgui.skl.BI; ...
                    cgui.stk.M{ward}(sub2ind (size (cgui.stk.M {ward}), i1 - 1, i2 - 1, i3 - 1))];
                if get (cgui.skl.ui.t_D, 'value')
                    % extract diameter values from binary distance to
                    % non-zero values:
                    D = diameterestimate (i2, i1, i3, ward);
                    cgui.skl.DI = [cgui.skl.DI; D];
                end
                if get (cgui.skl.ui.t_L, 'value')
                    % label binary image stacks (see "bwlabeln" from the
                    % image processing toolbox). Check if nodes are
                    % connected by floodfill in the threshold image stacks.
                    L = bwlabeln (cgui.thr.BW {ward}, 26);
                    cgui.skl.LI = [cgui.skl.LI; L(sub2ind (size (L), i1 - 1, i2 - 1, i3 - 1))];
                end
            end
            % echo on text frame of vis_ panel
            set (cgui.vis.ui.txt1, 'string', 'skeletonization');
            cgui_tree ('skl_image'); % redraw skl_ graphical output: skeletonized points
            cgui_tree ('mtr_showpanels'); % enable/disable mtr_ ui elements
            cgui_tree ('skl_inform'); % text output on number of skel points
        end
        setactivepanel_tree (3); % activate skl_ panel for edit
    case 'skl_clean'            % sparsening of skeletonized points
        % find skeletonized points which are sufficiently far apart.
        if (~isempty (cgui.skl.I)) && (~isempty (cgui.skl.BI))
            [m iM1] = sort (cgui.skl.BI, 1, 'descend'); % sort descending brightness
            EX = ones (length (iM1), 1);
            HW = waitbar (0, 'sparsening points...');
            set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
            for counter = 1 : length (iM1)
                if mod (counter, 500) == 0,
                    waitbar (counter / length (iM1), HW);
                end
                if EX (counter),
                    % calculate euclidean distance to other points
                    dis = sqrt (((cgui.skl.I (iM1 (counter), 1) - cgui.skl.I (iM1, 1)).^2) + ...
                        ((cgui.skl.I (iM1 (counter), 2) - cgui.skl.I (iM1, 2)).^2) + ...
                        ((cgui.skl.I (iM1 (counter), 3) - cgui.skl.I (iM1, 3)).^2));
                    % threshold distance from edit field:
                    idis = dis < str2double (get (cgui.skl.ui.ed_clean1, 'string'));
                    idis (counter) = 0; % but disregard actual point
                    EX (idis) = 0; % eliminate points which are in the vicinity of this one
                end
            end
            close (HW);
            cgui.skl.I  (iM1 (logical (~EX)), :) = []; % actually eliminate points
            cgui.skl.BI (iM1 (logical (~EX)), :) = []; % and in related vectors
            cgui.skl.CI (iM1 (logical (~EX)), :) = [];
            if ~isempty (cgui.skl.DI),
                cgui.skl.DI  (iM1 (logical (~EX)), :) = [];
            end
            if ~isempty (cgui.skl.LI),
                cgui.skl.LI  (iM1 (logical (~EX)), :) = [];
            end
            if ~isempty (cgui.skl.tCN),
                cgui.skl.tCN (iM1 (logical (~EX)), :) = [];
                cgui.skl.tCN (:, iM1 (logical (~EX))) = [];
            end
            if ~isempty(cgui.skl.dCN),
                cgui.skl.dCN (iM1 (logical (~EX)), :) = [];
                cgui.skl.dCN (:, iM1 (logical (~EX))) = [];
            end
            cgui_tree ('skl_updateCN');
            % echo on text frame of vis_ panel
            set (cgui.vis.ui.txt1, 'string', {'sparsened skel. points'});
            cgui_tree ('skl_image'); % redraw skl_ graphical output: skeletonized points
            cgui_tree ('skl_inform'); % text output on number of skel points
        end
        setactivepanel_tree (3); % activate skl_ panel for edit
    case 'skl_updateCN'         % combine probabilities for connectivity matrix
        % this matrix increases the probability that two nodes get
        % connected by the MST tree constructor (see "RST_tree"). This
        % matrix is sparse and zero anywhere where connections are
        % unlikely. The graph is plotted in skl_image with third radio
        % button on.
        if (~isempty (cgui.skl.I)),
            cgui.skl.CN = sparse (size (cgui.skl.I, 1), size (cgui.skl.I, 1));
            % add local threshold floodfill connectivity matrix:
            if ~isempty (cgui.skl.tCN)
                cgui.skl.CN = cgui.skl.CN + ...
                    str2double (get (cgui.skl.ui.ed_tCN, 'string')) * cgui.skl.tCN;
            end
            % add local orientation similarity connectivity matrix:
            if ~isempty (cgui.skl.dCN)
                cgui.skl.CN = cgui.skl.CN + cgui.skl.dCN;
            end
            if full (sum (sum (cgui.skl.CN))) == 0,
                cgui.skl.CN = [];
            end
            cgui_tree ('skl_image');
        end
    case 'skl_dCN'              % local orientation similarity connectivity matrix
        if (~isempty (cgui.skl.I)) && (~isempty (cgui.stk.M)) && (~isempty (cgui.thr.BW)),
            dCN = zeros (size (cgui.skl.I, 1), 3);
            HW = waitbar (0, 'calculating gradients...');
            set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
            for te = 1 : length (cgui.stk.M),
                indy = find (cgui.thr.BW {te});
                [i1 i2 i3] = ind2sub (size (cgui.thr.BW {te}), indy);
                pV    = [i1 i2 i3];
                inCI  = find    (cgui.skl.CI (:, 1) == te);
                dskin = zeros   (size (inCI, 1), 3);
                thr   = 2 * max (cgui.skl.DI);
                for ward = 1 : size (inCI, 1),
                    waitbar ((te - 1 + (ward / size (inCI, 1))) / length (cgui.stk.M), HW);
                    dist = sqrt (((i1 - cgui.skl.CI (inCI (ward), 2)).^2) + ...
                        ((i2 - cgui.skl.CI (inCI (ward), 3)).^2) + ...
                        ((i3 - cgui.skl.CI (inCI (ward), 4)).^2));
                    ipV = pV (dist < thr, :);
                    mpV = ipV - repmat (mean (ipV, 1), size (ipV, 1), 1);
                    dV = princomp (mpV);
                    dskin (ward, :) = dV (:, 1)';
                end
                dCN (inCI, :) = dskin;
            end
            dCN (dCN (:, 1) < 0, :) = -dCN (dCN (:, 1) < 0, :);
            % % try this if you want to check out what this does!
            % figure (cgui.ui.F); % recover figure control
            % HP = quiver3(cgui.skl.I(:,2),cgui.skl.I(:,1),cgui.skl.I(:,3),...
            % cgui.skl.dCN(:,2), cgui.skl.dCN(:,1), cgui.skl.dCN(:,3));
            % figure (cgui.ui.F); % recover figure control
            % delete (HP);
            cgui.skl.dCN = sparse (size (cgui.skl.I, 1), size (cgui.skl.I, 1));
            waitbar (0, HW, 'building connectivity matrix...');
            for ward = 1 : size (cgui.skl.I, 1),
                waitbar (ward / size (cgui.skl.I, 1));
                dist = sqrt ((cgui.skl.I (ward, 1) - cgui.skl.I (:, 1)).^2 + ...
                    (cgui.skl.I (ward, 2) - cgui.skl.I (:, 2)).^2 + ...
                    (cgui.skl.I (ward, 3) - cgui.skl.I (:, 3)).^2);
                thr      = str2double (get (cgui.mtr.ui.ed_mst2, 'string'));
                idist    = dist < thr;
                dist_dCN = repmat (dCN (ward, :), sum (idist), 1) - ...
                    dCN (idist, :);
                dist_dCN = (.5 - sqrt (sum (dist_dCN.^2, 2))) / 2;
                if dist_dCN < 0, dist_dCN = 0; end;
                cgui.skl.dCN (ward,  idist) = dist_dCN;
                cgui.skl.dCN (idist,  ward) = dist_dCN;
            end
            close (HW);
            cgui_tree ('skl_updateCN'); % combine probabilities for connectivity matrix
        end
    case 'skl_tCN'              % threshold floodfill connectivity matrix
        if (~isempty (cgui.skl.I)) && (~isempty (cgui.stk.M)) && (~isempty (cgui.thr.BW)),
            if isempty (cgui.skl.LI),
                cgui.skl.LI = zeros (size (cgui.skl.I, 1), 1);
                for ward = 1 : length (cgui.thr.BW),
                    % label binary image stacks (see "bwlabeln" from the
                    % image processing toolbox). Check if nodes are
                    % connected by floodfill in the threshold image stacks.
                    indy = find (cgui.skl.CI (:, 1) == ward);
                    L = bwlabeln (cgui.thr.BW {ward}, 26);
                    cgui.skl.LI (indy) = L (sub2ind (size (L), ...
                        cgui.skl.CI (indy, 2) - 1, ...
                        cgui.skl.CI (indy, 3) - 1, ...
                        cgui.skl.CI (indy, 4) - 1));
                end
            end
            cgui.skl.tCN = sparse (size (cgui.skl.I, 1), size (cgui.skl.I, 1));
            HW = waitbar (0, 'completing global floodfill connectivity...');
            set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
            thr = str2double (get (cgui.mtr.ui.ed_mst2, 'string'));
            for ward = 1 : size (cgui.skl.I, 1),
                if mod (ward, 500) == 0,
                    waitbar (ward / size (cgui.skl.I, 1), HW);
                end
                dist = sqrt (sum ((repmat (cgui.skl.I (ward, :), size (cgui.skl.I, 1), 1) - ...
                    cgui.skl.I).^2, 2));
                indy = find ((cgui.skl.CI (:, 1) == cgui.skl.CI (ward, 1)) & ...
                    (cgui.skl.LI (:, 1) == cgui.skl.LI (ward, 1)) & (dist < thr));
                cgui.skl.tCN (ward, indy) = 1;
                cgui.skl.tCN (indy, ward) = 1;
            end
            close(HW);
            %
            % alternative: local threshold floodfill
            %
            cgui_tree ('skl_updateCN'); % combine probabilities for connectivity matrix
        end
    case 'skl_image'            % main graphical updating function for changes
        % in selected carrier points
        figure (cgui.ui.F);
        if ~isempty (cgui.skl.HPI),  % delete graphical objects for carrier points
            delete  (cgui.skl.HPI);  cgui.skl.HPI= [];
        end
        if ~isempty (cgui.skl.HPS),  % delete graphical objects for starting points
            delete  (cgui.skl.HPS);  cgui.skl.HPS= [];
        end
        if ~isempty (cgui.skl.HPCN), % delete graphical objects for connectivity graph
            delete  (cgui.skl.HPCN); cgui.skl.HPCN= [];
        end
        if get (cgui.skl.ui.r1, 'value'), % plot carrier points as green dots in 3D
            if ~isempty (cgui.skl.I),
                cgui.skl.HPI = plot3 (cgui.skl.I (:, 2), cgui.skl.I (:, 1), ...
                    cgui.skl.I (:, 3), 'ko');
                set (cgui.skl.HPI, 'markerfacecolor', [0 1 0]);
            end
        end
        if get (cgui.skl.ui.r2, 'value'), % plot starting points as large red crosses in 3D
            if ~isempty (cgui.skl.S),
                cgui.skl.HPS = plot3 (cgui.skl.S (:, 2), cgui.skl.S (:, 1), ...
                    cgui.skl.S (:, 3), 'ko');
                set (cgui.skl.HPS, 'markersize', 12, 'markerfacecolor', [1 0 0]);
            end
        end
        if get (cgui.skl.ui.r3, 'value'), % plot connectivity matrix
            if ~isempty (cgui.skl.CN),
                indy = find (tril (cgui.skl.CN, -1));
                D = .02 * cgui.skl.CN (indy); % diameter indicates strength of connection
                [i1 i2] = ind2sub (size (cgui.skl.CN), indy);
                X1 = cgui.skl.I (i1, 2); X2 = cgui.skl.I (i2, 2);
                Y1 = cgui.skl.I (i1, 1); Y2 = cgui.skl.I (i2, 1);
                Z1 = cgui.skl.I (i1, 3); Z2 = cgui.skl.I (i2, 3);
                warning ('off', 'MATLAB:divideByZero');
                dP = [X2-X1 Y2-Y1] ./ repmat (sqrt ((X2 - X1).^2+(Y2 - Y1).^2), 1, 2);
                warning ('on',  'MATLAB:divideByZero');
                dP = dP (:, 1 : 2);
                % use rotation matrix to rotate the data
                V1 = (dP * [0, -1;  1, 0]).* (repmat (D, 1, 2) ./ 2);
                V2 = (dP * [0,  1; -1, 0]).* (repmat (D, 1, 2) ./ 2);
                MX = [X1+V2(:, 1) X1+V1(:, 1) X2+V1(:, 1) X2+V2(:, 1)]';
                MY = [Y1+V2(:, 2) Y1+V1(:, 2) Y2+V1(:, 2) Y2+V2(:, 2)]';
                MZ = [Z1 Z1 Z2 Z2]';
                cgui.skl.HPCN = patch (MX, MY, MZ, [0 1 0]);
                set (cgui.skl.HPCN, 'linestyle', 'none');
            end
        end
        
    case 'mtr_showpanels'       % enable/disable mtr_ ui elements
        % menu switches: each panel could theoretically be switched on and off
        % separately:
        if ~isempty (cgui.mtr.tree),
            % enable ui elements of mtr_ slt_ plt_ cat_ ged_ panels:
            for te = [2:5 9 10],
                str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
                for ward = 3 : length (str),
                    HP = eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]);
                    set (HP, 'enable', 'on');
                    if strcmp (get (HP, 'style'), 'edit'),
                        set (HP, 'backgroundcolor', [0 0 0]);
                        set (HP, 'backgroundcolor', cgui.NColor.edit);
                    end
                end
            end
            % change background color of panels and radio buttons:
            set (cgui.mtr.ui.c,  'backgroundcolor', [1 0 0]);
            set (cgui.mtr.ui.r1, 'backgroundcolor', [1 0 0]);
            set (cgui.mtr.ui.r2, 'backgroundcolor', [1 0 0]);
            set (cgui.mtr.ui.r3, 'backgroundcolor', [1 0 0]);
            set (cgui.mtr.ui.r4, 'backgroundcolor', [1 0 0]);
            set (cgui.mtr.ui.r5, 'backgroundcolor', [1 0 0]);
            set (cgui.ged.ui.c,  'backgroundcolor', [1 1 0]);
            set (cgui.ged.ui.r1, 'backgroundcolor', [1 1 0]);
            set (cgui.ged.ui.r2, 'backgroundcolor', [1 1 0]);
            set (cgui.ui.mu4,    'enable'         , 'on');
            % activate menu elements:
            mu22 = get (cgui.ui.mu2, 'children'); set (mu22 (1 : 11), 'enable', 'on');
        else
            % disable ui elements of mtr_ slt_ plt_ cat_ ged_ panels:
            for te = [2:5 9 10],
                str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
                for ward = 3 : length (str),
                    HP = eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]);
                    set (HP, 'enable', 'off');
                end
            end
            % change background color of panels and radio buttons:
            set (cgui.mtr.ui.c,  'backgroundcolor', [1 .7 .7]);
            set (cgui.mtr.ui.r1, 'backgroundcolor', [1 .7 .7]);
            set (cgui.mtr.ui.r2, 'backgroundcolor', [1 .7 .7]);
            set (cgui.mtr.ui.r3, 'backgroundcolor', [1 .7 .7]);
            set (cgui.mtr.ui.r4, 'backgroundcolor', [1 .7 .7]);
            set (cgui.mtr.ui.r5, 'backgroundcolor', [1 .7 .7]);
            set (cgui.ged.ui.c,  'backgroundcolor', [1 1 .7]);
            set (cgui.ged.ui.r1, 'backgroundcolor', [1 1 .7]);
            set (cgui.ged.ui.r2, 'backgroundcolor', [1 1 .7]);
            set (cgui.ui.mu4,    'enable'         , 'off');
            % inactivate menu elements:
            mu22 = get (cgui.ui.mu2, 'children'); set (mu22 (1 : 11), 'enable', 'off');
        end
        if ~isempty (cgui.skl.I),
            % check if MST should be activated:
            for te = 9,
                str = fieldnames (eval (['cgui.' cgui.ui.panels{te} '.ui']));
                for ward = 8 : 13,
                    HP = eval (['cgui.' cgui.ui.panels{te} '.ui.' str{ward}]);
                    set (HP, 'enable', 'on');
                    if strcmp (get (HP, 'style'), 'edit'),
                        set (HP, 'backgroundcolor', [0 0 0]);
                        set (HP, 'backgroundcolor', cgui.NColor.edit);
                    end
                end
            end
        end
        set (cgui.mtr.ui.b23, 'enable', 'on'); % always possible
    case 'mtr_inform'           % text output on tree length and number of nodes
        str = get (cgui.vis.ui.txt2, 'string'); % replace adequate str-cell
        if ~isempty (cgui.mtr.tree)
            str{4} = ['tree length ' num2str(round (sum (len_tree (cgui.mtr.tree)))) ' um'];
            str{5} = [num2str(size (cgui.mtr.tree.dA, 1)) ' nodes'];
        else
            str{4} = ''; str{5} = '';
        end
        set (cgui.vis.ui.txt2, 'string', str); % and put back on text screen
    case 'mtr_MST'              % use minimum spanning tree algorithm to connect points
        if ~isempty (cgui.skl.I)
            cgui_tree ('cat_update'); % update tree sorter according to actual tree
            % see "MST_tree" for more details!!
            % using points defined by skl_ panel, connect them to minimize
            % total wiring and path length from any open point to the
            % starting points, the roots of the neuronal trees
            if get (cgui.mtr.ui.t_rst, 'value'),
                DIST = cgui.skl.CN;
            else
                DIST = [];
            end
            sDIST = size (DIST, 1);
            if ~isempty (cgui.skl.S)
                if ~isempty (DIST),
                    DIST = [sparse(size (cgui.skl.S, 1), sDIST + size (cgui.skl.S, 1)); ...
                        [sparse(sDIST, size (cgui.skl.S, 1)) DIST]];
                end
                [tree indx] = MST_tree ((1 : size (cgui.skl.S, 1)), ...
                    [cgui.skl.S(:, 2); cgui.skl.I(:, 2)], ...
                    [cgui.skl.S(:, 1); cgui.skl.I(:, 1)], ...
                    [cgui.skl.S(:, 3); cgui.skl.I(:, 3)], ...
                    str2double (get (cgui.mtr.ui.ed_mst1, 'string')), ...
                    str2double (get (cgui.mtr.ui.ed_mst2, 'string')), ...
                    str2double (get (cgui.mtr.ui.ed_mst3, 'string')), ...
                    DIST);
            else
                [tree indx] = MST_tree (1, ...
                    cgui.skl.I (:, 2), cgui.skl.I (:, 1), cgui.skl.I (:, 3), ...
                    str2double (get (cgui.mtr.ui.ed_mst1, 'string')), ...
                    str2double (get (cgui.mtr.ui.ed_mst2, 'string')), ...
                    str2double (get (cgui.mtr.ui.ed_mst3, 'string')), ...
                    DIST);
            end
            if (~isempty (cgui.skl.DI)) && (get (cgui.skl.ui.t_D, 'value')),
                if iscell (tree),
                    for te = 1 : length (tree),
                        indy = find (indx (:, 1) == te);
                        tree {te}.D (indx (indy, 2)) = cgui.skl.DI (indy);
                    end
                else
                    indy = find (indx (:, 1) == 1);
                    tree.D (indx (indy, 2)) = cgui.skl.DI (indy);
                end
            end
            incorporateloaded_tree ({tree}, 'mst'); % incorporate new trees in tree sorter
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'connected new trees', 'MST method'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_BCT'              % equivalent standard tree
        if ~isempty (cgui.mtr.tree)
            cgui_tree ('cat_update'); % update tree sorter according to actual tree
            % see "xdend_tree", this function transforms the tree into an
            % electrotonic equivalent tree which is sorted. Two trees with
            % the same exact electrotonic properties will therefore fall on
            % the same exact equivalent standard tree. If the tree is
            % resample then the BCT - string corresponds to the gene which
            % encodes this equivalent standard tree.
            tree = sort_tree (cgui.mtr.tree, '-LO');
            [xdend tree] = xdend_tree (tree, '-w');
            incorporateloaded_tree (tree, 'BCT'); % incorporate new tree in tree sorter
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', ...
                {'created equivalent BCT tree', 'xdend method'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_clone'            % use MST algorithm to clone a tree
        if ~isempty (cgui.mtr.tree)
            cgui_tree ('cat_update'); % update tree sorter according to actual tree
            % see "clone_tree", this function is based on the idea that a
            % dendrite is described well by its MST growth rule, and the
            % density function of the field that it spans. Points are
            % randomly distributed according to the density function of the
            % real tree (region by region) and connected by MST_tree.
            if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                tree = clone_tree (cgui.cat.trees {cgui.cat.i2tree}, ...
                    str2double (get (cgui.mtr.ui.ed_clone1, 'string')), ...
                    str2double (get (cgui.mtr.ui.ed_mst1,   'string')), '-w');
            else
                tree = clone_tree ({cgui.cat.trees{cgui.cat.i2tree}}, ...
                    str2double (get (cgui.mtr.ui.ed_clone1, 'string')), ...
                    str2double (get (cgui.mtr.ui.ed_mst1,   'string')), '-w');
            end
            if length (tree) > 1,
                tree = {tree};
            end
            incorporateloaded_tree (tree, 'clone'); % incorporate new trees in tree sorter
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'created new tree', 'clone method'});
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_soma'             % add a soma by increasing the diameter at root
        if ~isempty (cgui.mtr.tree ),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "soma_tree", maps a cosine diameter around the root
            % location with a diameter and a length parameter (only
            % increases diameter, never decreases a diameter)
            cgui.mtr.tree  = soma_tree (cgui.mtr.tree, ...
                str2double (get (cgui.mtr.ui.ed_soma1, 'string')), ...
                str2double (get (cgui.mtr.ui.ed_soma2, 'string')));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'added a soma', ...
                ['diam. ' get(cgui.mtr.ui.ed_soma1, 'string') ' x ' ...
                get(cgui.mtr.ui.ed_soma2, 'string')]});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_spines'           % add a number of spines
        if ~isempty (cgui.mtr.tree ),
            cgui_tree ('slt_icomp'); % read out index for points to point at:
            cgui.cat.untrees {end+1} = cgui.mtr.tree; % keep track of old tree for undo
            % see "spines_tree". Attaches randomly distributed spines to
            % selected nodes. If region with name "spines" exists then the
            % new spines are appended to it, otherwise it is created anew.
            % For a homogeneous distribution first resample a tree to
            % equidistant nodes:
            cgui.mtr.tree  = spines_tree (cgui.mtr.tree, ...
                str2double (get (cgui.mtr.ui.ed_spines1, 'string')), ...
                str2double (get (cgui.mtr.ui.ed_spines2, 'string')), ...
                str2double (get (cgui.mtr.ui.ed_spines3, 'string')), ...
                str2double (get (cgui.mtr.ui.ed_spines4, 'string')), ...
                str2double (get (cgui.mtr.ui.ed_spines4, 'string')), cgui.slt.ind);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string','add a few spines');
            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
            cgui_tree ('slt_regupdate'); % check if tree alteration affected region index
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_spines2'          % add spines from skeletonized points
        if ~isempty (cgui.mtr.tree ) && ~isempty (cgui.skl.I),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "spines_tree". Attaches spines as mtr_spines but at
            % locations of skeletonized points (see mtr_spines):
            cgui.mtr.tree  = spines_tree (cgui.mtr.tree, ...
                [cgui.skl.I(:, 2) cgui.skl.I(:, 1) cgui.skl.I(:, 3)]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', 'add a few spines');
            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
            cgui_tree ('slt_regupdate'); % check if tree alteration affected region index
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_quaddiameter'     % map quadratic diameter decay starting at the root
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "quaddiameter_tree" and (cuntz, borst and segev 2007). A
            % quadratic tapering optimizes current transfer from a terminal
            % to the dendrite root, therefore this is a good way to map a
            % dendrite tapering to an existing branching structure. This is
            % scaled by RIN and offset by a minimum tip diameter (not 0 in
            % real cells although that or even negative would be optimal
            % ;-) ):
            cgui.mtr.tree  = quaddiameter_tree (cgui.mtr.tree, ...
                str2double (get (cgui.mtr.ui.ed_qdiam1, 'string')),...
                str2double (get (cgui.mtr.ui.ed_qdiam2, 'string')), '-w');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'quad diameter', 'decay'});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_quadfit'          % fit quadratic diameter automatically
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "quadfit_tree" and "quaddiameter_tree" and "qfit" further below
            % in this file. Fits scaling and offset parameter of quadratic
            % diameter tapering:
            P0 = fminsearch (@(P) qfit (P, cgui.mtr.tree), rand (1, 2));
            tree = quaddiameter_tree (cgui.mtr.tree, P0 (1), P0 (2), 'none');
            tree.D (cgui.mtr.tree.D > max (tree.D)) = ...
                cgui.mtr.tree.D (cgui.mtr.tree.D > max (tree.D));
            cgui.mtr.tree.D = tree.D;
            set (cgui.mtr.ui.ed_qdiam1, 'string', num2str (P0 (1)));
            set (cgui.mtr.ui.ed_qdiam2, 'string', num2str (P0 (2)));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'fitted quadratic diameter taper'});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_constD'           % set constant diameter throughout the tree.
        if ~isempty (cgui.mtr.tree ),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            diam            = str2double (get (cgui.mtr.ui.ed_qdiam2, 'string'));
            cgui.mtr.tree.D = cgui.mtr.tree.D * 0 + diam;
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'constant diameter', [num2str(diam) ' um']});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_friedrichD'       % set "friedrich" diameter according to image stack.
        if ~isempty (cgui.mtr.tree) && ~isempty (cgui.stk.M),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "fitD_stack", interpolates brightness levels a few points
            % along the cylinders and finds edges using the 2nd order
            % derivative:
            cgui.mtr.tree.D = fitD_stack (cgui.mtr.tree, cgui.stk, 50, '-w') / 2;
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'friedrich diameter'});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_resample'         % resample tree, approx. all segments become same length
        if ~isempty (cgui.mtr.tree),
            if size (cgui.mtr.tree.X, 1) > 1,
                cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
                % see "resample_tree" which redistributes the nodes on the
                % graph to keep the topology as intact as possible but in
                % approximately the same distance pieces, given is the
                % resolution in um
                cgui.mtr.tree  = resample_tree (cgui.mtr.tree, ...
                    str2double (get (cgui.mtr.ui.ed_resample1, 'string')),'-r');
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'resampled tree:',...
                    [get(cgui.mtr.ui.ed_resample1, 'string') ' um']});
                cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            end;
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_resamplelong'     % resample tree, length conservation
        if ~isempty(cgui.mtr.tree ),
            if size (cgui.mtr.tree.X, 1) > 1,
                cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
                % see "resample_tree" which redistributes the nodes on the
                % graph to keep the topology as intact as possible but in
                % approximately the same distance pieces, given is the
                % resolution in um
                cgui.mtr.tree  = resample_tree (cgui.mtr.tree, ...
                    str2double (get(cgui.mtr.ui.ed_resample1, 'string')), '-l -w -r');
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'resampled stretched tree:', ...
                    [get(cgui.mtr.ui.ed_resample1, 'string') ' um']});
                cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            end;
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_repair'           % repair a tree to fit all TREES functions
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "repair_tree" eliminates 0-length elements, trifurcations
            % and sorts the branches according to level order
            cgui.mtr.tree = repair_tree (cgui.mtr.tree);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'repaired tree'});
            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
            cgui_tree ('slt_regupdate'); % check if tree alteration affected region index
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_redirect'         % attributes the root to another node
        if ~isempty(cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "redirect_tree", the tree structure has to be reordered,
            % the adjacency matrix is recalculated since all edges lead
            % away from the new root. Making a branching point the new root
            % results automatically in a trifurcation. If the root was
            % previously deleted, redirection can have terrible effects!
            cgui.mtr.tree = redirect_tree (cgui.mtr.tree, cgui.mtr.lastnode);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'redirected tree', ...
                ['node:' num2str(cgui.mtr.lastnode)]});
            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_morph'            % morphometric transform
        cgui_tree ('slt_vcomp'); % calculate value vector from slt_ panel
        if ~isempty (cgui.slt.vec) && ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % and apply the value vector on the tree as new length values
            % for the individual edges of the tree.
            % see "morph_tree". Some typical morphometric transform concern
            % the electrotonic properties (morphoelectrotonic transform)
            % and can be applied also here by adjusting the slt_ panel
            % accordingly.
            cgui.mtr.tree = morph_tree (cgui.mtr.tree, cgui.slt.vec);
            str = cgui.slt.svec (get (cgui.slt.ui.pop1, 'value'));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'morphed tree', str{1}});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_flat'             % flatten tree, this is also a kind of morphometric transform
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % segment length values are preserved and two-dimensional angles
            % but the tree is mapped to 2D, see "flatten_tree".
            cgui.mtr.tree = flatten_tree (cgui.mtr.tree);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'flattened tree'});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_zcorr'            % z-correction (for neurolucida imports usually)
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % because of the digitization method in neurolucida, large
            % abrupt jumps in z can occur and are ironed out by this
            % function. Careful though that the function reduces the jump
            % to zero and will possibly result in actual shape information
            % loss if misused, see "zcorr_tree". The parameter is the
            % minimum jump (threshold) in z that is ironed out.
            cgui.mtr.tree = zcorr_tree (cgui.mtr.tree, ...
                str2double (get (cgui.mtr.ui.ed_zcorr1, 'string')), '-w');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'z-correction'});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree(4); % activate mtr_ panel for edit
    case 'mtr_discon'           % disconnect sub-tree, reappears as new tree
        if ~isempty (cgui.mtr.tree) && ~isempty (cgui.mtr.lastnode)
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % find subtree to last clicked node:
            [isub subtree] = sub_tree (cgui.mtr.tree, cgui.mtr.lastnode);
            % delete that subtree on current tree:
            cgui.mtr.tree = delete_tree (cgui.mtr.tree, find (isub),'-r');
            % and incorporate that tree in tree sorter and make it active:
            incorporateloaded_tree (subtree, 'sub'); % incorporate subtrees in tree sorter
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'disconnected', 'subtree'});
        end
    case 'mtr_smooth'           % smoothen tree along heavier branches
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "smooth_tree" (really??.. surprise!) and "smoothbranch".
            % Smoothens heavy branches making longer paths shorter
            % (straighter):
            cgui.mtr.tree = smooth_tree (cgui.mtr.tree, [], ...
                str2double (get (cgui.mtr.ui.ed_smooth1, 'string')), ...
                str2double (get (cgui.mtr.ui.ed_smooth2, 'string')));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'smoothened', 'tree'});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_jitter'           % apply jitter on XYZ coordinates
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "jitter_tree", applies spatially low-pass filtered noise
            % (along the branch axis) from a normal distribution.
            cgui.mtr.tree = jitter_tree (cgui.mtr.tree, ...
                str2double (get (cgui.mtr.ui.ed_jitter1, 'string')), ...
                str2double (get (cgui.mtr.ui.ed_jitter2, 'string')));
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'tree was jittered'});
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_clean'            % clean tree of short terminals
        if ~isempty (cgui.mtr.tree)
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % see "clean_tree", here a lot of improvement still can be
            % made. For now nodes that appear within the diameter of larger
            % branches are deleted.
            cgui.mtr.tree = clean_tree (cgui.mtr.tree, ...
                str2double (get (cgui.mtr.ui.ed_clean1, 'string')), '-w');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'cleaned tree'});
            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
            cgui_tree ('slt_regupdate'); % check if tree alteration affected region index
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
        setactivepanel_tree (4); % activate mtr_ panel for edit
    case 'mtr_empty'            % starts an empty tree of length 10um and diameter 5um
        % If soma locations were selected in the skeletonization panel then
        % new trees are created for every soma location.
        if ~isempty (cgui.skl.S),
            tree = cell (1, size (cgui.skl.S, 1));
            for ward = 1 : size (cgui.skl.S, 1)
                tree {ward}.dA = sparse ([0 0 0; 1 0 0; 0 1 0]);
                tree {ward}.X  = cgui.skl.S (ward, 2) + [0; 0; 10];
                tree {ward}.Y  = cgui.skl.S (ward, 1) + [0; 0; 0];
                tree {ward}.Z  = cgui.skl.S (ward, 3) + [0; 0; 0];
                tree {ward}.D  = [5; 5; 5]; tree {ward}.R = [1; 1; 1];
                tree {ward}.rnames = {'noregions'};
            end
        else
            tree.dA = sparse ([0 0 0; 1 0 0; 0 1 0]);
            tree.X = [0; 0; 10]; tree.Y = [0; 0; 0];
            tree.Z = [0; 0; 0];  tree.D = [5; 5; 5]; tree.R = [1; 1; 1];
            tree.rnames = {'noregions'};
        end
        incorporateloaded_tree (tree, 'newtree'); % incorporate new trees in tree sorter
        % echo on text frame of vis_ panel:
        set (cgui.vis.ui.txt1, 'string', 'created new empty tree(s)');
        setactivepanel_tree (4); % activate mtr_ panel for edit
        cgui_tree ('mtr_showpanels'); % check if tree control panels need to be active
    case 'mtr_t_snap1'          % handle toggle elements for snap editing: threshold stack
        if get  (cgui.mtr.ui.t_snap1, 'value')
            set (cgui.mtr.ui.t_snap2, 'value', 0);
        end
    case 'mtr_t_snap2'          % snap editing: skeletonized points
        if get  (cgui.mtr.ui.t_snap2, 'value')
            set (cgui.mtr.ui.t_snap1, 'value', 0);
        end
    case 'mtr_t_snap3'          % snap editing: maximum intensity third dimension
        % if neither snap3 nor snap4 is active the third dimension is taken
        % from the slicer
        if get  (cgui.mtr.ui.t_snap3, 'value')
            set (cgui.mtr.ui.t_snap4, 'value', 0);
        end
    case 'mtr_t_snap4'          % snap editing: closest tree point third dimension
        if get  (cgui.mtr.ui.t_snap4, 'value')
            set (cgui.mtr.ui.t_snap3, 'value', 0);
        end
    case 'mtr_t_move1'          % edit: toggle on moving single node {DEFAULT}
        if get  (cgui.mtr.ui.t_move1, 'value')
            set (cgui.mtr.ui.t_move2, 'value', 0); set (cgui.mtr.ui.t_move3, 'value', 0);
            set (cgui.mtr.ui.t_move4, 'value', 0);
        else
            set (cgui.mtr.ui.t_move2, 'value', 1); set (cgui.mtr.ui.t_move3, 'value', 0);
            set (cgui.mtr.ui.t_move4, 'value', 0);
        end
    case 'mtr_t_move2'          % edit: toggle on moving selected nodes
        if get  (cgui.mtr.ui.t_move2, 'value')
            set (cgui.mtr.ui.t_move1, 'value', 0); set (cgui.mtr.ui.t_move3, 'value', 0);
            set (cgui.mtr.ui.t_move4, 'value', 0);
        else
            set (cgui.mtr.ui.t_move1, 'value', 1); set (cgui.mtr.ui.t_move3, 'value', 0);
            set (cgui.mtr.ui.t_move4, 'value', 0);
        end
    case 'mtr_t_move3'          % edit: toggle on moving subtree
        if get  (cgui.mtr.ui.t_move3, 'value')
            set (cgui.mtr.ui.t_move1, 'value', 0); set (cgui.mtr.ui.t_move2, 'value', 0);
            set (cgui.mtr.ui.t_move4, 'value', 0);
        else
            set (cgui.mtr.ui.t_move1, 'value', 1); set (cgui.mtr.ui.t_move2, 'value', 0);
            set (cgui.mtr.ui.t_move4, 'value', 0);
        end
    case 'mtr_t_move4'          % edit: toggle on moving gooey all nodes weighted by distance
        if get  (cgui.mtr.ui.t_move4, 'value')
            set (cgui.mtr.ui.t_move1, 'value', 0); set (cgui.mtr.ui.t_move2, 'value', 0);
            set (cgui.mtr.ui.t_move3, 'value', 0);
        else
            set (cgui.mtr.ui.t_move1, 'value', 1); set (cgui.mtr.ui.t_move2, 'value', 0);
            set (cgui.mtr.ui.t_move3, 'value', 0);
        end
    case 'mtr_r1'               % segmented view on the actual tree
        % includes nodes as red points
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        cgui_tree ('vis_climupdate'); % update edit fields with new colormap limits
    case 'mtr_r2'               % fuller fake cylinder view on the actual tree
        set (cgui.mtr.ui.r3, 'value', 0); set (cgui.mtr.ui.r4, 'value', 0);
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        cgui_tree ('vis_climupdate'); % update edit fields with new colormap limits
    case 'mtr_r3'               % graph view of the currently activated tree (arrows)
        set (cgui.mtr.ui.r2, 'value', 0); set (cgui.mtr.ui.r4, 'value', 0);
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        cgui_tree ('vis_climupdate'); % update edit fields with new colormap limits
    case 'mtr_r4'               % full fake view with mapped slt_ vectors
        set (cgui.mtr.ui.r2, 'value', 0); set (cgui.mtr.ui.r3, 'value', 0);
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        cgui_tree ('vis_climupdate'); % update edit fields with new colormap limits
    case 'mtr_r5'               % transparency on mtr_image plots
        cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
    case 'mtr_image'            % main graphical updating function for changes
        % to the currently active tree
        figure (cgui.ui.F); % recover figure control
        if~isempty (cgui.mtr.tHP), % delete handles to tree plots
            for ward = 1 : length (cgui.mtr.tHP),
                delete (cgui.mtr.tHP {ward});
            end
            cgui.mtr.tHP = {};
        end
        if~isempty (cgui.mtr.pHP), % delete handles to tree node plots
            for ward = 1 : length (cgui.mtr.pHP),
                delete (cgui.mtr.pHP {ward});
            end
            cgui.mtr.pHP = {};
        end
        if ~isempty (cgui.mtr.tree)
            if get (cgui.mtr.ui.r2, 'value'), % full cylinder view on the actual tree
                cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                    [1 0 0], [], [], cgui.vis.res, '-p');
                if get  (cgui.mtr.ui.r5, 'value'), % transparent trees
                    set (cgui.mtr.tHP {end}, 'facealpha', .2);
                end
            end
            if get  (cgui.mtr.ui.r3, 'value'), % graph view of the currently activated tree (arrows)
                cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                    [1 0 0], [], [], [], '-3q');
                set (cgui.mtr.tHP {end}, 'linewidth', 0.5);
            end
            if get (cgui.mtr.ui.r4, 'value'), % full view with mapped slt_ vectors
                cgui_tree ('slt_vcomp'); % obtain node values from slt_ controler
                % and map them onto the tree directly:
                cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                    cgui.slt.vec, [], [], cgui.vis.res, '-p');
                if get  (cgui.mtr.ui.r5, 'value'), % transparent trees
                    set (cgui.mtr.tHP {end}, 'facealpha', .2);
                end
                cgui_tree ('vis_xclim'); % update colormap limits in edit fields
            end
            if ~(cgui.modes.edit && (cgui.modes.panel == 4))
                if get (cgui.mtr.ui.r1, 'value'), % segmented view on the actual tree
                    % cylinders are not correctly drawn for speed (see
                    % "plot_tree", "blatt" representation)
                    switch cgui.modes.view % representation depends on the view:
                        case 2 % xz-view
                            cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                                [], [], [], 2, '-b2');
                        case 3 % yz-view
                            cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                                [], [], [], 2, '-b3');
                        otherwise % xy or 3D-view
                            cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                                [], [], [], 2, '-b1');
                    end
                    set (cgui.mtr.tHP {end}, 'facecolor', 'none');
                    set (cgui.mtr.tHP {end}, 'edgecolor', [1 0 0]);
                    % nodes as red points and the root as a bigger red point
                    cgui_tree ('slt_icomp');
                    cgui.mtr.pHP {1} = plot3 (cgui.mtr.tree.X (1), cgui.mtr.tree.Y (1), ...
                        cgui.mtr.tree.Z (1), 'ro'); % root
                    set (cgui.mtr.pHP {1}, 'markersize', 12);
                    if ~isempty (cgui.slt.ind),
                        cgui.mtr.pHP {2} = plot3 (cgui.mtr.tree.X, cgui.mtr.tree.Y, ...
                            cgui.mtr.tree.Z,'r.');  % nodes in red according to the..
                        % index selected in the slt_ panel
                        cgui.mtr.pHP {3} = plot3 (cgui.mtr.tree.X (cgui.slt.ind), ...
                            cgui.mtr.tree.Y (cgui.slt.ind), ...
                            cgui.mtr.tree.Z (cgui.slt.ind), 'k.'); % all other nodes
                        set (cgui.mtr.pHP {3}, 'markersize', 24);
                    else
                        cgui.mtr.pHP {2} = plot3 (cgui.mtr.tree.X, cgui.mtr.tree.Y, ...
                            cgui.mtr.tree.Z, 'r.'); % if none selected then all nodes red
                        if (get (cgui.slt.ui.pop2, 'value') == 1) && ~isempty (cgui.mtr.selected)
                            cgui.mtr.pHP {3} = plot3 (cgui.mtr.tree.X (cgui.mtr.selected), ...
                                cgui.mtr.tree.Y (cgui.mtr.selected), ...
                                cgui.mtr.tree.Z (cgui.mtr.selected), 'k.'); % selected nodes
                            set (cgui.mtr.pHP {3}, 'markersize', 24);
                        end
                        if ~isempty (cgui.mtr.lastnode)
                            cgui.mtr.pHP {4} = plot3 (cgui.mtr.tree.X (cgui.mtr.lastnode), ...
                                cgui.mtr.tree.Y (cgui.mtr.lastnode), ...
                                cgui.mtr.tree.Z (cgui.mtr.lastnode), 'go'); % selected nodes
                            set (cgui.mtr.pHP {4}, 'markersize', 24);
                        end
                    end
                end
            else % if the editor is on, the representation is different:
                ipart = [];
                % cylinders are not correctly drawn for speed (see
                % "plot_tree", "blatt" representation)
                switch cgui.modes.view % representation depends on the view:
                    case 2 % xz-view
                        cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                            [], [], ipart, 2, '-b2');
                    case 3 % yz-view
                        cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                            [], [], ipart, 2, '-b3');
                    otherwise % xy or 3D-view
                        cgui.mtr.tHP {end+1} = plot_tree (cgui.mtr.tree, ...
                            [], [], ipart, 2, '-b1');
                end
                set (cgui.mtr.tHP {end}, 'linewidth', 2, 'faceColor', 'none');
                set (cgui.mtr.tHP {end}, 'edgecolor', [1 0 0]);
                cgui.mtr.pHP {1} = plot3 (cgui.mtr.tree.X (1), cgui.mtr.tree.Y (1), ...
                    cgui.mtr.tree.Z (1), 'ro'); % root
                set(cgui.mtr.pHP {1}, 'markersize', 18);
                 if isfield (cgui.mtr.tree,'jpoints') %?%?%?
                     cgui.mtr.pHP {2} = plot3 (cgui.mtr.tree.X(cgui.mtr.tree.jpoints==0), cgui.mtr.tree.Y(cgui.mtr.tree.jpoints==0), ...
                    cgui.mtr.tree.Z(cgui.mtr.tree.jpoints==0), 'r.');  % nodes in empty according to the..
                 else
                cgui.mtr.pHP {2} = plot3 (cgui.mtr.tree.X, cgui.mtr.tree.Y, ...
                    cgui.mtr.tree.Z, 'r.');  % nodes in empty according to the..
                 end
                set(cgui.mtr.pHP {2}, 'markersize', 24);
                if ~isempty (cgui.mtr.selected),
                    cgui.mtr.pHP {3} = plot3 (cgui.mtr.tree.X (cgui.mtr.selected), ...
                        cgui.mtr.tree.Y (cgui.mtr.selected), ...
                        cgui.mtr.tree.Z (cgui.mtr.selected), 'k.'); % all other nodes
                    set(cgui.mtr.pHP {3}, 'markersize', 48);
                end
                if ~isempty (cgui.mtr.lastnode)
                    cgui.mtr.pHP {4} = plot3 (cgui.mtr.tree.X (cgui.mtr.lastnode), ...
                        cgui.mtr.tree.Y (cgui.mtr.lastnode), ...
                        cgui.mtr.tree.Z (cgui.mtr.lastnode), 'go'); % selected nodes
                    set(cgui.mtr.pHP {4}, 'markersize', 24);
                end
                if isfield (cgui.mtr.tree,'jpoints') %!%!%!
                    cgui.mtr.pHP {5} = plot3 (cgui.mtr.tree.X (cgui.mtr.tree.jpoints>0), ...
                        cgui.mtr.tree.Y (cgui.mtr.tree.jpoints>0), ...
                        cgui.mtr.tree.Z (cgui.mtr.tree.jpoints>0), 'b.'); % jump nodes
                    set (cgui.mtr.pHP {5}, 'markersize', 25);
                end
            end
        end
        axis (cgui.ui.g1, 'tight');
        
    case 'ged_scaleedit'        % toggle to edit-scaling mode
        % in edit-mode mouse movements scale a tree or a group of trees.
        if  get (cgui.ged.ui.t1, 'value'),
            set (cgui.ged.ui.t2, 'value', 0); set (cgui.ged.ui.t3, 'value', 0);
        else
            set (cgui.ged.ui.t2, 'value', 0); set (cgui.ged.ui.t3, 'value', 1);
        end
        setactivepanel_tree (5); % activate ged_ panel for edit
    case 'ged_rotedit'          % toggle to edit-rotating mode
        % in edit-mode mouse movements rotate a tree or a group of trees.
        if  get (cgui.ged.ui.t2, 'value'),
            set (cgui.ged.ui.t1, 'value', 0); set (cgui.ged.ui.t3, 'value', 0);
        else
            set (cgui.ged.ui.t1, 'value', 0); set (cgui.ged.ui.t3, 'value', 1);
        end
        setactivepanel_tree (5); % activate ged_ panel for edit
    case 'ged_moveedit'         % toggle to edit-moving mode {DEFAULT}
        % in edit-mode mouse movements move a tree or a group of trees.
        if  get (cgui.ged.ui.t3, 'value'),
            set (cgui.ged.ui.t1, 'value', 0); set (cgui.ged.ui.t2, 'value', 0);
        else
            set (cgui.ged.ui.t1, 'value', 1); set (cgui.ged.ui.t2, 'value', 0);
        end
        setactivepanel_tree (5); % activate ged_ panel for edit
    case 'ged_scale'            % scale tree according to edit field
        if ~isempty (cgui.mtr.tree), % see "scale_tree", scales the diameter as well
            gedapply2 ('scale_tree', ...
                str2double (get (cgui.ged.ui.ed_scale1, 'string')), 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'scaled tree by', ...
                get(cgui.ged.ui.ed_scale1, 'string')});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_scale1'           % scale tree smaller by 10%
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('scale_tree', .9, 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'scaled tree 90%'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_scale2'           % scale tree larger by 10%
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('scale_tree', 1.1, 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'scaled tree 110%'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_tran1'            % move tree by -1 um in X
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree), % see "tran_tree"
            gedapply2 ('tran_tree', [-1 0 0]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree:', 'X - 1um'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_tran2'            % move tree by +1 um in X
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('tran_tree', [1 0 0]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree:', 'X + 1um'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_tran3'            % move tree by -1 um in Y
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('tran_tree', [0 -1 0]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree:', 'Y - 1um'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_tran4'            % move tree by +1 um in Y
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('tran_tree', [0 1 0]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree:', 'Y + 1um'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_tran5'            % move tree by -1 um in Z
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('tran_tree', [0 0 -1]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree:', 'Z - 1um'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_tran6'            % move tree by +1 um in Z
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('tran_tree', [0 0 1]);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree:', 'Z + 1um'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_traned1'          % update root x-location according to edit
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            Xx = str2double (get (cgui.ged.ui.ed_tran1, 'string'));
            cgui.mtr.tree = tran_tree (cgui.mtr.tree, [Xx-cgui.mtr.tree.X(1) 0 0]);
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree', ...
                [get(cgui.ged.ui.ed_tran1, 'string') 'in X']});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_traned2'          % update root y-location according to edit
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees{end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            Yy = str2double (get (cgui.ged.ui.ed_tran2, 'string'));
            cgui.mtr.tree = tran_tree (cgui.mtr.tree, [0 Yy-cgui.mtr.tree.Y(1) 0]);
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree', ...
                [get(cgui.ged.ui.ed_tran2, 'string') 'in Y']});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_traned3'          % update root z-location according to edit
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            Zz = str2double (get (cgui.ged.ui.ed_tran3, 'string'));
            cgui.mtr.tree = tran_tree (cgui.mtr.tree, [0 0 Zz-cgui.mtr.tree.Z(1)]);
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'moved tree', ...
                [get(cgui.ged.ui.ed_tran3, 'string') 'in Z']});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_settran'          % update edit fields according to new root location
        if ~isempty (cgui.mtr.tree),
            set (cgui.ged.ui.ed_tran1, 'string', num2str (cgui.mtr.tree.X (1)));
            set (cgui.ged.ui.ed_tran2, 'string', num2str (cgui.mtr.tree.Y (1)));
            set (cgui.ged.ui.ed_tran3, 'string', num2str (cgui.mtr.tree.Z (1)));
        end
    case 'ged_zero'             % set root location to (0, 0, 0)
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('tran_tree', []);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'centered the tree'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rotpc'            % rotate active tree according to its principal components
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty(cgui.mtr.tree),     % see "rot_tree"
            gedapply ('tree = rot_tree (tree, [], ''-pc3d'');');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree','principal components'});
            setactivepanel_tree(5); % activate ged_ panel for edit
        end
    case 'ged_rotpc2d'          % rotate active tree according to its principal components
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply ('tree = rot_tree (tree, [], ''-pc2d'');');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', '2D principal components'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rotmean'          % rotate active tree according to its mean axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply ('tree = rot_tree (tree, [], ''-m3dY'');');            
%             gedapply (['tree = rot_tree (tree, [rad2deg(atan(mean(tree.Z)./mean(tree.Y))), ' ...
%                 'rad2deg(atan(mean(tree.Z)./mean(tree.X))), ' ...
%                 'rad2deg(atan(mean(tree.Y)./mean(tree.X)))]);']);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'mean axis Marcel'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot1'             % rotate active tree by -1deg around X-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [-1 0 0],1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around X -1deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot2'             % rotate active tree by +1deg around X-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [1 0 0], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around X +1deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot3'             % rotate active tree by -1deg around Y-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 -1 0], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Y -1deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot4'             % rotate active tree by +1deg around Y-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 1 0], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Y +1deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot5'             % rotate active tree by -1deg around Z-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 0 -1], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Z -1deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot6'             % rotate active tree by +1deg around Z-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 0 1], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Z +1deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot10'            % rotate active tree by -10deg around X-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [-10 0 0], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around X -10deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot20'            % rotate active tree by +10deg around X-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [10 0 0], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around X +10deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot30'            % rotate active tree by -10deg around Y-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 -10 0], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Y -10deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot40'            % rotate active tree by +10deg around Y-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 10 0], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Y +10deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot50'            % rotate active tree by -10deg around Z-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 0 -10], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Z -10deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_rot60'            % rotate active tree by +10deg around Z-axis
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('rot_tree', [0 0 10], 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'rotated tree', 'around Z +10deg'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_flipx'            % flip tree over X-dimension
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree), % see "flip_tree" , obviously...
            gedapply2 ('flip_tree', 1);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'flipped tree', 'over X'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_flipy'            % flip tree over Y-dimension
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('flip_tree', 2);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'flipped tree', 'over Y'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_flipz'            % flip tree over Z-dimension
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply2 ('flip_tree', 3);
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'flipped tree', 'over Z'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_concat'           % concatenate tree at its root to closest node of previous tree
        if (length (cgui.cat.trees {cgui.cat.i2tree}) > 1) && (cgui.cat.itree > 1),
            tree = cat_tree (cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree-1}, ...
                cgui.mtr.tree, [], [], 'none');
            incorporateloaded_tree (tree, 'concat'); % incorporate concated trees in tree sorter
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_spread'           % spread trees in a group
        if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % only active tree is kept in memory though
            cgui.ged.dd = spread_tree (cgui.cat.trees {cgui.cat.i2tree}); % see "spread_tree"
            for ward = 1 : length (cgui.ged.dd)
                cgui.cat.trees{cgui.cat.i2tree}{ward} = ...
                    tran_tree (cgui.cat.trees{cgui.cat.i2tree}{ward}, cgui.ged.dd {ward});
            end
            cgui.mtr.tree = tran_tree (cgui.mtr.tree, cgui.ged.dd {cgui.cat.itree});
            cgui_tree ('mtr_image'); cgui_tree ('ged_image'); cgui_tree ('ged_settran');
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_unspread'         % unspread trees in a group
        if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
            if length (cgui.cat.trees {cgui.cat.i2tree}) == length (cgui.ged.dd),
                % revert back to coordinates before last spread by applying
                % the changing vectors back.
                cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
                % only active tree is kept in memory though
                for ward = 1 : length (cgui.ged.dd)
                    cgui.cat.trees{cgui.cat.i2tree}{ward} = ...
                        tran_tree (cgui.cat.trees{cgui.cat.i2tree}{ward}, -cgui.ged.dd {ward});
                end
                cgui.mtr.tree = tran_tree (cgui.mtr.tree, -cgui.ged.dd {cgui.cat.itree});
                cgui_tree ('mtr_image'); cgui_tree ('ged_image'); cgui_tree ('ged_settran');
                setactivepanel_tree (5); % activate ged_ panel for edit
            end
        end
    case 'ged_dp1'              % scale up diameter x1.1 to all trees in group
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply ('tree.D = tree.D * 1.1;');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'increased diameter', 'by 10%'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_dm1'              % scale down diameter x.9 to all trees in group
        % see "gedapply", applies simple tree global metric edits on either
        % one tree or all trees in a group:
        if ~isempty (cgui.mtr.tree),
            gedapply ('tree.D = tree.D * .9;');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'decreased diameter', 'by 10%'});
            setactivepanel_tree (5); % activate ged_ panel for edit
        end
    case 'ged_r1'               % radio button toggle: sketch other trees in group
        set (cgui.ged.ui.r2, 'value', 0); % never together with full plot!
        cgui_tree ('ged_image'); % redraw ged_ graphical output: other trees in group
    case 'ged_r2'               % radio button toggle: full brainbow colors!
        set (cgui.ged.ui.r1, 'value', 0); % never together with sketch plot!
        cgui_tree ('ged_image'); % redraw ged_ graphical output: all trees in group
    case 'ged_image'            % main graphical updating function for changes
        figure (cgui.ui.F); % recover figure control
        if ~isempty (cgui.ged.tHP), % delete handles to tree plots first
            for ward = 1 : length (cgui.ged.tHP),
                delete (cgui.ged.tHP {ward});
            end
            cgui.ged.tHP = {};
        end
        if (~isempty (cgui.cat.trees))
            if get (cgui.ged.ui.r1, 'value'),
                len = length (cgui.cat.trees {cgui.cat.i2tree});
                if len > 1,
                    ilen = 1 : len; ilen (cgui.cat.itree) = [];
                    % plot all trees in group apart from active tree
                    % (mtr_image does that)
                    for ward = ilen,
                        cgui.ged.tHP {end+1} = plot_tree (cgui.cat.trees{cgui.cat.i2tree}{ward}, ...
                            [], [], [], 2, '-b');
                        set (cgui.ged.tHP {end}, 'facecolor', 'none');
                        set (cgui.ged.tHP {end}, 'edgecolor', [0 0 0]);
                    end
                end
            end
            if get (cgui.ged.ui.r2, 'value'),
                len = length (cgui.cat.trees {cgui.cat.i2tree});
                if len > 1,
                    ilen = 1 : len; ilen (cgui.cat.itree) = [];
                    % plot all trees in group this time, and fully:
                    color = [[0 0 0]; [0 1 0]; [0 0 1]; rand(len - 3, 3)];
                    counter = 1;
                    for ward = ilen,
                        cgui.ged.tHP {end+1} = plot_tree (cgui.cat.trees{cgui.cat.i2tree}{ward}, ...
                            [], [], [], cgui.vis.res, '-p');
                        set (cgui.ged.tHP {end}, 'facecolor', color (counter, :));
                        counter = counter + 1;
                    end
                end
            end
        end
        axis (cgui.ui.g1, 'tight');
        
    case 'plx_dA'               % plot the adjacency matrix of currently active tree
        if ~isempty (cgui.mtr.tree),
            % external plot:
            figure; dA_tree (cgui.mtr.tree); view (2); % see "dA_tree"
            set (gca, 'visible', 'off');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'plotted adjacency matrix'});
        end
    case 'plx_dend'             % plot the dendrogram of currently active tree
        if ~isempty (cgui.mtr.tree),      % see "dendrogram_tree"
            figure; dendrogram_tree (cgui.mtr.tree);
            axis (cgui.ui.g1, 'tight'); view (2);
            set (gca, 'visible', 'off');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'drew dendrogram'});
        end
    case 'plx_x3d'              % export active tree to x3d format (incl. spheres)
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            x3d_tree (cgui.mtr.tree, ...
                [], 2 * cgui.slt.vec ./ max (cgui.slt.vec), [], [], '-w -o ->');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'x3d'});
        end
    case 'plx_x3d2'             % export active tree to x3d format
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            x3d_tree (cgui.mtr.tree, ...
                [], 2 * cgui.slt.vec ./ max (cgui.slt.vec), [], [], '-w ->');
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:','x3d'});
        end
    case 'plx_pov'              % export active tree to ray-tracer POV-Ray:GFP
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.mtr.tree, [], cgui.slt.vec, '-s1 -b -i -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov2'             % export active tree to ray-tracer POV-Ray:parchment
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.mtr.tree, [], cgui.slt.vec, '-s2 -b -i -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov3'             % export active tree to ray-tracer POV-Ray:blackwhite
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.mtr.tree, [], cgui.slt.vec, '-s3 -b -i -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:','POV-Ray'});
        end
    case 'plx_pov4'             % export active tree to ray-tracer POV-Ray:alien
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.mtr.tree, [], cgui.slt.vec, '-s4 -b -i -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:','POV-Ray'});
        end
    case 'plx_pov5'             % export active tree to ray-tracer POV-Ray:glass on cork
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.mtr.tree, [], cgui.slt.vec, '-s5 -b -i -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:','POV-Ray'});
        end
    case 'plx_pov6'             % export active tree to ray-tracer POV-Ray:red coral
        if ~isempty (cgui.mtr.tree),
            cgui_tree ('slt_vcomp');
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.mtr.tree, [], cgui.slt.vec, '-s6 -b -i -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:','POV-Ray'});
        end
    case 'plx_pov7'             % export active group to ray-tracer POV-Ray:brainbow
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.cat.trees {cgui.cat.i2tree}, [], [], '-s1 -b -c -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov8'             % export active group to ray-tracer POV-Ray:GFP
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.cat.trees {cgui.cat.i2tree}, [], [], '-s1 -b -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov9'             % export active group to ray-tracer POV-Ray:parchment
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.cat.trees {cgui.cat.i2tree}, [], [], '-s2 -b -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov10'            % export active group to ray-tracer POV-Ray:blackwhite
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.cat.trees {cgui.cat.i2tree}, [], [], '-s3 -b -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov11'            % export active group to ray-tracer POV-Ray:alien
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.cat.trees {cgui.cat.i2tree}, [], [], '-s4 -b -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov12'            % export active group to ray-tracer POV-Ray:glass on cork
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.cat.trees {cgui.cat.i2tree}, [], [], '-s5 -b -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov13'            % export active group to ray-tracer POV-Ray:red coral
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            pov_tree (cgui.cat.trees {cgui.cat.i2tree}, [], [], '-s6 -b -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_pov14'            % export all trees to ray-tracer POV-Ray:brainbow
        if ~isempty (cgui.mtr.tree),
            % this even calls POV-Ray (only windows), preserves the view
            % and maps a color vector:
            cattrees = {}; % can't find a way to get rid of "growing inside a loop"
            for ward = 1 : length (cgui.cat.trees),
                cattrees = [cattrees, cgui.cat.trees{ward}];
            end
            pov_tree (cattrees, [], [], '-s1 -c -b -w -v ->'); % see "pov_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'exported to:', 'POV-Ray'});
        end
    case 'plx_neuron'           % export active tree to simulator NEURON
        if ~isempty (cgui.mtr.tree),
            name = neuron_tree (cgui.mtr.tree, [], [], '-s -e -w ->'); % see "neuron_tree"
            if ~isempty (name)
                % echo on text frame of vis_ panel:
                set (cgui.vis.ui.txt1, 'string', {'exported to:', 'NEURON'});
            end
        end
    case 'plx_sse'              % plot the electrotonic signature of currently active tree
        if ~isempty (cgui.mtr.tree),
            figure; sse_tree (cgui.mtr.tree, [], '-s'); % see "sse_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'plotted:', 'electrotonic signature'});
        end
    case 'plx_sholl'            % plots the scholl intersections of the tree
        % these are intersections with spheres around the root with increasing diameters
        if ~isempty (cgui.mtr.tree),
            figure; sholl_tree (cgui.mtr.tree, [], '-s'); % see "sholl_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'plotted:', 'sholl intersections'});
        end
    case 'plx_sholl3D'          % plots the scholl intersections of the tree
        % these are intersections with spheres around the root with increasing diameters
        if ~isempty (cgui.mtr.tree),
            figure; sholl_tree (cgui.mtr.tree, [], '-3s'); % see "sholl_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'plotted 3D:', 'sholl intersections'});
        end
    case 'plx_stats'            % plots some statistics of grouped trees
        if ~isempty (cgui.cat.trees),
            figure;
            stats_tree (cgui.cat.trees, [], [], '-s -x -w'); % see "stats_tree"
            % echo on text frame of vis_ panel:
            set (cgui.vis.ui.txt1, 'string', {'plotted:', 'branching statistics'});
        end
        
    case 'keymap'               % keys attributed to functions (custom changes in cgui_tree_keys)
        lastkey = get (cgui.ui.F, 'CurrentCharacter');
        set (cgui.ui.F, 'currentcharacter', char(0));
        switch lastkey % keyboard shortcuts
            case 't'
                if exist('TreeAdmin.m','file')
                    answer = questdlg('Do you want to save your trees before continuing?','Save Trees?','Save all trees','Dont save','Cancel','Cancel');
                    if strcmp(answer,'Save all trees')
                        cgui_tree('cat_allsave')
                    elseif isempty(answer) || strcmp(answer,'Cancel')
                        return
                    end
                    answer = questdlg('What to load into TreeAdmin?','TreeAdmin','Active tree group','Only active tree','Cancel','Cancel');
                    if strcmp(answer,'Active tree group')
                        cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree} = cgui.mtr.tree;
                        tree = TreeAdmin(cgui.cat.trees{cgui.cat.i2tree});
                        cgui.cat.trees{cgui.cat.i2tree} = tree{1};
                        cgui.mtr.tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree};
                    elseif strcmp(answer,'Only active tree')
                        tree = TreeAdmin(cgui.mtr.tree);
                        cgui.mtr.tree = tree{1}{1};
                    end
                    
                    cgui_tree ('cat_update');   %update trees
                    name = cgui.mtr.tree.name;
                    set (cgui.cat.ui.ed_name1, 'string',name);
 
                    % update active tree and cat_ cell array name fields
                    if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                        cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree}.name = name;
                        str = cellfun(@(x) x.name,cgui.cat.trees{cgui.cat.i2tree},'UniformOutput',false);
                    else
                        cgui.cat.trees{cgui.cat.i2tree}.name = name;
                        str = {name};
                    end
                    % update frame window containing tree names in active group:
                    set (cgui.cat.ui.f1, 'string', str);
                    % echo on text frame of vis_ panel:
                    set (cgui.vis.ui.txt1, 'string', {'Used Tree Admin for:', name});
                    cgui_tree ('mtr_image');    %update figure
                end
            case 'h'
                if isfield(cgui.modes,'hold')
                    cgui.modes.hold = rem(cgui.modes.hold+1,2);
                else
                    cgui.modes.hold = 1;
                end
            case cgui.keys.ui   {1}        % select editor panel 1 up
                cgui_tree ('ui_editorpanelup');
            case cgui.keys.ui   {2}        % select editor panel 1 down
                cgui_tree ('ui_editorpaneldown');
            case cgui.keys.ui   {3}        % toggle edit mode on/off
                cgui_tree ('ui_editor');
            case cgui.keys.ui   {4}        % 2nd: toggle edit mode on/off
                cgui_tree ('ui_editor');
            case cgui.keys.ui   {5}        % toggle edit selection mode on/off
                cgui_tree ('ui_selector');
            case cgui.keys.ui   {6}        % 2nd: toggle edit selection mode on/off
                cgui_tree ('ui_selector');
            case cgui.keys.ui   {7}        % select stk_ panel for edit
                setactivepanel_tree (1);   % activate stk_ panel for edit
            case cgui.keys.ui   {8}        % select thr_ panel for edit
                setactivepanel_tree (2);   % activate thr_ panel for edit
            case cgui.keys.ui   {9}        % select skl_ panel for edit
                setactivepanel_tree (3);   % activate skl_ panel for edit
            case cgui.keys.ui  {10}        % select mtr_ panel for edit
                setactivepanel_tree (4);   % activate mtr_ panel for edit
            case cgui.keys.ui  {11}        % select ged_ panel for edit
                setactivepanel_tree (5);   % activate ged_ panel for edit
                
            case cgui.keys.vis  {1}        % redraw everything
                cgui_tree ('vis_cla');
            case cgui.keys.vis  {2}        % axis tight
                cgui_tree ('vis_tight');
            case cgui.keys.vis  {3}        % toggle grid
                cgui_tree ('vis_grid');
            case cgui.keys.vis  {4}        % toggle view to xy
                cgui_tree ('vis_xy');
            case cgui.keys.vis  {5}        % toggle view to xz
                cgui_tree ('vis_xz');
            case cgui.keys.vis  {6}        % toggle view to yz
                cgui_tree ('vis_yz');
            case cgui.keys.vis  {7}        % toggle views
                cgui_tree ('vis_2d3d');
            case cgui.keys.vis  {8}        % add sun shine switch to opengl
                cgui_tree ('vis_shine');
            case cgui.keys.vis  {9}        % toggle axis visibility
                cgui_tree ('vis_axoff');
            case cgui.keys.vis {10}        % toggle colorbar on/off
                cgui_tree ('vis_cbar');
            case cgui.keys.vis {11}        % toggle scalebar on/off
                cgui_tree ('vis_scale');
            case cgui.keys.vis {12}        % zoomout a bit
                angle = get (cgui.ui.g1, 'cameraviewangle');
                set (cgui.ui.g1, 'cameraviewangle', angle * 1.05);
            case cgui.keys.vis {13}        % zoomout a lot
                angle = get (cgui.ui.g1, 'cameraviewangle');
                set (cgui.ui.g1, 'cameraviewangle', angle * 1.2);
            case cgui.keys.vis {14}        % zoomin a bit
                angle = get (cgui.ui.g1, 'cameraviewangle');
                set (cgui.ui.g1, 'cameraviewangle', angle * 0.95);
            case cgui.keys.vis {15}        % zoomin a lot
                angle = get (cgui.ui.g1, 'cameraviewangle');
                set (cgui.ui.g1, 'cameraviewangle', angle * 0.8);
            case cgui.keys.vis {16}        % + dimension 1 a bit (depends on view mode)
                movecamera (1,  0.0025);
            case cgui.keys.vis {17}        % + dimension 1 a lot
                movecamera (1,    0.02);
            case cgui.keys.vis {18}        % - dimension 1 a bit
                movecamera (1, -0.0025);
            case cgui.keys.vis {19}        % - dimension 1 a lot
                movecamera (1,   -0.02);
            case cgui.keys.vis {20}        % + dimension 2 a bit
                movecamera (2,  0.0025);
            case cgui.keys.vis {21}        % + dimension 2 a lot
                movecamera (2,    0.02);
            case cgui.keys.vis {22}        % - dimension 2 a bit
                movecamera (2, -0.0025);
            case cgui.keys.vis {23}        % - dimension 2 a lot
                movecamera (2,   -0.02);
            case cgui.keys.vis {28}        % decrease third coordinate (depends on view)
                cgui_tree ('vis_iMm1');
            case cgui.keys.vis {29}        % decrease third coordinate more(depends on view)
                cgui_tree ('vis_iMm5');
            case cgui.keys.vis {30}        % increase third coordinate (depends on view)
                cgui_tree ('vis_iMp1');
            case cgui.keys.vis {31}        % increase third coordinate more (depends on view)
                cgui_tree ('vis_iMp5');
                 
            case cgui.keys.cat  {1}        % select previous tree in group
                if ~isempty (cgui.cat.trees),
                    if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                        if  get (cgui.cat.ui.f1, 'value') > 1,
                            set (cgui.cat.ui.f1, 'value', get (cgui.cat.ui.f1, 'value') - 1);
                            cgui_tree ('cat_selecttree');
                        end
                    end
                end
            case cgui.keys.cat  {2}        % select next tree in group
                if ~isempty (cgui.cat.trees),
                    if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                        if  get (cgui.cat.ui.f1, 'value') < length (cgui.cat.trees {cgui.cat.i2tree}),
                            set (cgui.cat.ui.f1, 'value', get (cgui.cat.ui.f1, 'value') + 1);
                            cgui_tree ('cat_selecttree');
                        end
                    end
                end
            case cgui.keys.cat  {3}        % undo changes on active tree
                cgui_tree ('cat_undo');
                
            case cgui.keys.over {1}        % general cutting functions 1
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 1 % stk_ edit-select cutout selected ROI area
                                if numel (cgui.stk.selected) > 3
                                    HW = waitbar (0.3, 'filling in...');
                                    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
                                    switch cgui.modes.view
                                        case 2
                                            [X Z] = meshgrid ( ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 2) - 1, ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 3) - 1);
                                            X = cgui.stk.voxel (1) * X + ...
                                                cgui.stk.coord (cgui.stk.active, 1) - .5;
                                            Z = cgui.stk.voxel (3) * Z + ...
                                                cgui.stk.coord (cgui.stk.active, 3) - .5;
                                            X1 = imresize (X, 0.2); Z1 = imresize (Z, 0.2);
                                            IN = inpolygon (X1, Z1, cgui.stk.selected (:, 1), ...
                                                cgui.stk.selected (:, 3));
                                            IN = imresize (IN, size (X, 1) ./ size (IN, 1));
                                            [im2 im1] = ind2sub (size (X), find (IN));
                                            sim3 = size (cgui.stk.M {cgui.stk.active}, 1);
                                            im3  = repmat  (1 : sim3, size (im1, 1), 1);
                                            im3  = reshape (im3, numel (im3), 1);
                                            cgui.stk.M {cgui.stk.active} ...
                                                (sub2ind (size (cgui.stk.M {cgui.stk.active}), ...
                                                im3, ...
                                                repmat (im1, sim3, 1), ...
                                                repmat (im2, sim3, 1))) = 0;
                                        case 3
                                            [Y Z] = meshgrid( ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 1) - 1, ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 3) - 1);
                                            Y = cgui.stk.voxel (2) * Y + ...
                                                cgui.stk.coord (cgui.stk.active, 2) - .5;
                                            Z = cgui.stk.voxel (3) * Z + ...
                                                cgui.stk.coord (cgui.stk.active, 3) - .5;
                                            Y1 = imresize (Y, 0.2); Z1 = imresize (Z, 0.2);
                                            IN = inpolygon (Y1, Z1, cgui.stk.selected (:, 2), ...
                                                cgui.stk.selected (:, 3));
                                            IN = imresize (IN, size (Y, 1) ./ size (IN, 1));
                                            [im2 im1] = ind2sub (size (Y), find (IN));
                                            sim3 = size (cgui.stk.M {cgui.stk.active}, 2);
                                            im3  = repmat  (1 : sim3, size (im1, 1), 1);
                                            im3  = reshape (im3, numel (im3), 1);
                                            cgui.stk.M {cgui.stk.active} ...
                                                (sub2ind (size (cgui.stk.M {cgui.stk.active}), ...
                                                repmat (im1, sim3, 1), ...
                                                im3, ...
                                                repmat (im2, sim3, 1))) = 0;
                                        otherwise
                                            [X Y] = meshgrid ( ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 2) - 1, ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 1) - 1);
                                            X = cgui.stk.voxel (1) * X + ...
                                                cgui.stk.coord (cgui.stk.active, 1) - .5;
                                            Y = cgui.stk.voxel (2) * Y + ...
                                                cgui.stk.coord (cgui.stk.active, 2) - .5;
                                            X1 = imresize (X, 0.2); Y1 = imresize (Y, 0.2);
                                            IN = inpolygon (X1, Y1, cgui.stk.selected (:, 1), ...
                                                cgui.stk.selected (:, 2));
                                            IN = imresize (IN, size (X, 1) ./ size (IN, 1));
                                            [im2 im1] = ind2sub (size (X), find (IN));
                                            sim3 = size (cgui.stk.M {cgui.stk.active}, 3);
                                            im3 = repmat  (1 : sim3, size (im1, 1), 1);
                                            im3 = reshape (im3, numel (im3), 1);
                                            cgui.stk.M {cgui.stk.active} ...
                                                (sub2ind (size (cgui.stk.M {cgui.stk.active}), ...
                                                repmat (im2 ,sim3, 1), ...
                                                repmat (im1, sim3, 1), ...
                                                im3)) = 0;
                                    end
                                    close (HW);
                                    cgui.thr.BW = {};
                                    cgui_tree ('stk_trim'); % trim rectangularly zerosvalues in stacks
                                end
                            case 3 % skl_ edit-select delete selected skeleton point
                                if ~isempty (cgui.skl.I)
                                    if cgui.skl.distance < 5,
                                        cgui.skl.I  (cgui.skl.active, :) = [];
                                        cgui.skl.BI (cgui.skl.active, :) = [];
                                        cgui.skl.CI (cgui.skl.active, :) = [];
                                        if ~isempty (cgui.skl.DI),
                                            cgui.skl.DI  (cgui.skl.active, :) = [];
                                        end
                                        if ~isempty (cgui.skl.LI),
                                            cgui.skl.LI  (cgui.skl.active, :) = [];
                                        end
                                        if ~isempty (cgui.skl.tCN),
                                            cgui.skl.tCN (cgui.skl.active, :) = [];
                                            cgui.skl.tCN (:, cgui.skl.active) = [];
                                        end
                                        if ~isempty (cgui.skl.dCN),
                                            cgui.skl.dCN (cgui.skl.active, :) = [];
                                            cgui.skl.dCN (:, cgui.skl.active) = [];
                                        end
                                        if ~isempty (cgui.skl.CN),
                                            cgui.skl.CN  (cgui.skl.active, :) = [];
                                            cgui.skl.CN  (:, cgui.skl.active) = [];
                                        end
                                        % redraw skl_ graphical output:
                                        % skeletonized points:
                                        cgui_tree ('skl_image');
                                        % text output on number of skel
                                        % points:
                                        cgui_tree ('skl_inform');
                                    end
                                end
                            case 4
                                if ~isempty (cgui.mtr.selected)
                                    if ~isempty (cgui.mtr.tree)
                                        % keep track of old tree for undo:
                                        cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                        cgui.mtr.tree = delete_tree (cgui.mtr.tree, ...
                                            cgui.mtr.selected,'-r');
                                        cgui.mtr.selected = [];  cgui.mtr.lastnode = 1;
                                        % after tree alteration selected nodes
                                        % are discarded:
                                        cgui_tree ('slt_relsel');
                                        % check if tree alteration affected
                                        % region index:
                                        cgui_tree ('slt_regupdate');
                                        if isempty (cgui.mtr.tree),
                                            cgui_tree ('cat_cleartree');
                                        else
                                            % redraw mtr_ graphical output:
                                            % active tree:
                                            cgui_tree ('mtr_image');
                                            % text output on tree length and
                                            % number of nodes:
                                            cgui_tree ('mtr_inform');
                                        end
                                    end
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 3 % skl_ edit delete selected starting point
                                if ~isempty (cgui.skl.S)
                                    if cgui.skl.distance < 5,
                                        cgui.skl.S (cgui.skl.active, :) = [];
                                        % redraw skl_ graphical output:
                                        % skeletonized points:
                                        cgui_tree ('skl_image');
                                        % text output on number of skel
                                        % points:
                                        cgui_tree ('skl_inform');
                                    end
                                end
                            case 4 % mtr_ edit delete a single node
                                if ~isempty (cgui.mtr.tree)
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees{end+1} = cgui.mtr.tree;
                                    if isfield(cgui.modes,'hold') && cgui.modes.hold == 1
                                        lastnode = find(cgui.mtr.tree.dA(cgui.mtr.lastnode,:));
                                        cgui.mtr.tree = delete_tree (cgui.mtr.tree, ...
                                            cgui.mtr.lastnode,'-r');
                                        cgui.mtr.lastnode = lastnode;
                                    else
                                    cgui.mtr.tree = delete_tree (cgui.mtr.tree, ...
                                        cgui.mtr.active,'-r');
                                    end
                                    % after tree alteration selected nodes
                                    % are discarded:
                                    cgui_tree ('slt_relsel');
                                    % check if tree alteration affected
                                    % region index:
                                    cgui_tree ('slt_regupdate');
                                    if isempty (cgui.mtr.tree),
                                        cgui_tree ('cat_cleartree');
                                    else
                                        % redraw mtr_ graphical output:
                                        % active tree:
                                        cgui_tree ('mtr_image');
                                        % text output on tree length and
                                        % number of nodes:
                                        cgui_tree ('mtr_inform');
                                    end
                                end
                        end
                    end
                end
            case cgui.keys.over {2}        % general cutting functions 2
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 1 % stk_ edit-select cut outside of selected ROI area
                                if numel (cgui.stk.selected) > 3
                                    HW = waitbar (0.3, 'filling in...');
                                    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
                                    switch cgui.modes.view
                                        case 2
                                            [X Z] = meshgrid ( ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 2) - 1, ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 3) - 1);
                                            X = cgui.stk.voxel (1) * X + ...
                                                cgui.stk.coord (cgui.stk.active, 1) - .5;
                                            Z = cgui.stk.voxel (3) * Z + ...
                                                cgui.stk.coord (cgui.stk.active, 3) - .5;
                                            X1 = imresize (X, 0.2); Z1 = imresize (Z, 0.2);
                                            IN = ~inpolygon (X1, Z1, cgui.stk.selected (:, 1), ...
                                                cgui.stk.selected (:, 3));
                                            IN = imresize (IN, size (X, 1) ./ size (IN, 1));
                                            [im2 im1] = ind2sub (size (X), find (IN));
                                            sim3 = size (cgui.stk.M {cgui.stk.active}, 1);
                                            im3  = repmat  (1 : sim3, size (im1, 1), 1);
                                            im3  = reshape (im3, numel (im3), 1);
                                            cgui.stk.M {cgui.stk.active} ...
                                                (sub2ind (size (cgui.stk.M {cgui.stk.active}), ...
                                                im3, ...
                                                repmat (im1, sim3, 1), ...
                                                repmat (im2, sim3, 1))) = 0;
                                        case 3
                                            [Y Z] = meshgrid ( ...
                                                0 : size (cgui.stk.M {cgui.stk.active} ,1) - 1, ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 3) - 1);
                                            Y = cgui.stk.voxel (2) * Y + ...
                                                cgui.stk.coord (cgui.stk.active, 2) - .5;
                                            Z = cgui.stk.voxel (3) * Z + ...
                                                cgui.stk.coord (cgui.stk.active, 3) - .5;
                                            Y1 = imresize (Y, 0.2); Z1 = imresize (Z, 0.2);
                                            IN = ~inpolygon (Y1, Z1, cgui.stk.selected (:, 2), ...
                                                cgui.stk.selected (:, 3));
                                            IN = imresize (IN, size (Y, 1) ./ size (IN, 1));
                                            [im2 im1] = ind2sub (size (Y), find (IN));
                                            sim3 = size (cgui.stk.M {cgui.stk.active}, 2);
                                            im3  = repmat  (1 : sim3, size (im1, 1), 1);
                                            im3  = reshape (im3, numel (im3), 1);
                                            cgui.stk.M {cgui.stk.active} ...
                                                (sub2ind (size (cgui.stk.M {cgui.stk.active}), ...
                                                repmat (im1, sim3, 1), ...
                                                im3, ...
                                                repmat (im2, sim3, 1))) = 0;
                                        otherwise
                                            [X Y] = meshgrid ( ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 2) - 1, ...
                                                0 : size (cgui.stk.M {cgui.stk.active}, 1) - 1);
                                            X = cgui.stk.voxel (1) * X + ...
                                                cgui.stk.coord (cgui.stk.active, 1) - .5;
                                            Y = cgui.stk.voxel (2) * Y + ...
                                                cgui.stk.coord (cgui.stk.active, 2) - .5;
                                            X1 = imresize (X, 0.2); Y1 = imresize (Y, 0.2);
                                            IN = ~inpolygon (X1, Y1, cgui.stk.selected (:, 1), ...
                                                cgui.stk.selected (:, 2));
                                            IN = imresize (IN, size(X, 1) ./ size (IN, 1));
                                            [im2 im1] = ind2sub (size (X), find (IN));
                                            sim3 = size (cgui.stk.M {cgui.stk.active}, 3);
                                            im3  = repmat  (1 : sim3, size (im1, 1), 1);
                                            im3  = reshape (im3, numel (im3), 1);
                                            cgui.stk.M {cgui.stk.active} ...
                                                (sub2ind (size (cgui.stk.M {cgui.stk.active}), ...
                                                repmat (im2, sim3, 1), ...
                                                repmat (im1, sim3, 1), ...
                                                im3)) = 0;
                                    end
                                    close (HW);
                                    cgui.thr.BW = {};
                                    cgui_tree ('stk_trim'); % trim rectangularly zerosvalues in stacks
                                end
                            case 3 % skl_ edit-select cut skel points in vicinity
                                if ~isempty (cgui.skl.S)
                                    if cgui.skl.distance < 5,
                                        i = cgui.skl.I (cgui.skl.active, :);
                                        dist = sqrt (sum ((repmat (i, size (cgui.skl.I, 1), 1) - ...
                                            cgui.skl.I).^2, 2));
                                        cgui.skl.I  (dist < 15, :) = [];
                                        cgui.skl.BI (dist < 15, :) = [];
                                        cgui.skl.CI (dist < 15, :) = [];
                                        if ~isempty (cgui.skl.DI),
                                            cgui.skl.DI  (dist < 15, :) = [];
                                        end
                                        if ~isempty (cgui.skl.LI),
                                            cgui.skl.LI  (dist < 15, :) = [];
                                        end
                                        if ~isempty (cgui.skl.tCN),
                                            cgui.skl.tCN (dist < 15, :) = [];
                                            cgui.skl.tCN (:, dist < 15) = [];
                                        end
                                        if ~isempty (cgui.skl.dCN),
                                            cgui.skl.dCN (dist < 15, :) = [];
                                            cgui.skl.dCN (:, dist < 15) = [];
                                        end
                                        if ~isempty (cgui.skl.CN),
                                            cgui.skl.CN  (dist < 15, :) = [];
                                            cgui.skl.CN  (:, dist < 15) = [];
                                        end
                                        % redraw skl_ graphical output:
                                        % skeletonized points:
                                        cgui_tree ('skl_image');
                                        % text output on number of skel
                                        % points:
                                        cgui_tree ('skl_inform');
                                    end
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 4 % mtr_ edit delete a full subtree
                                if ~isempty (cgui.mtr.tree)
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree = delete_tree (cgui.mtr.tree, ...
                                        find (sub_tree (cgui.mtr.tree, cgui.mtr.active)),'-r');
                                    % after tree alteration selected nodes
                                    % are discarded:
                                    cgui_tree ('slt_relsel');
                                    % check if tree alteration affected
                                    % region index:
                                    cgui_tree ('slt_regupdate');
                                    if isempty (cgui.mtr.tree),
                                        cgui_tree ('cat_cleartree');
                                    else
                                        % redraw mtr_ graphical output:
                                        % active tree:
                                        cgui_tree ('mtr_image');
                                        % text output on tree length and
                                        % number of nodes:
                                        cgui_tree ('mtr_inform');
                                    end
                                end
                        end
                    end
                end
            case cgui.keys.over {3}        % preview rebuild (see also next case)
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 3 % skl_ edit-select preview skel point sparsening
                                if (~isempty (cgui.skl.I)) && (~isempty (cgui.skl.BI))
                                    % rid editor and selector graphic
                                    % handles:
                                    cgui_tree ('ui_clean');
                                    [m iM1] = sort (cgui.skl.BI, 1, 'descend');
                                    EX = ones (length (iM1), 1);
                                    for counter = 1:length (iM1)
                                        if EX (counter),
                                            dis = sqrt (((cgui.skl.I (iM1 (counter), 1) - cgui.skl.I (iM1, 1)).^2) + ...
                                                ((cgui.skl.I (iM1 (counter), 2) - cgui.skl.I (iM1, 2)).^2) + ...
                                                ((cgui.skl.I (iM1 (counter), 3) - cgui.skl.I (iM1, 3)).^2));
                                            idis = dis < ...
                                                str2double (get (cgui.skl.ui.ed_clean1, 'string'));
                                            idis (counter) = 0;
                                            EX (idis) = 0;
                                        end
                                    end
                                    iEX = find (EX);
                                    cgui.ui.pHP = plot3 (cgui.skl.I (iM1(iEX), 2), ...
                                        cgui.skl.I (iM1 (iEX), 1), cgui.skl.I (iM1 (iEX), 3), 'yo');
                                    set (cgui.ui.pHP, 'markersize', 10);
                                    pause (1);
                                    % rid editor and selector graphic
                                    % handles:
                                    cgui_tree ('ui_clean');
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 4 % mtr_ edit preview re-connecting nodes of sub-tree
                                if ~isempty (cgui.mtr.tree)
                                    isub = find (sub_tree (cgui.mtr.tree, cgui.mtr.active));
                                    X = cgui.mtr.tree.X (isub); Y = cgui.mtr.tree.Y (isub);
                                    Z = cgui.mtr.tree.Z (isub); D = cgui.mtr.tree.D (isub);
                                    tree = delete_tree (cgui.mtr.tree, isub,'-r');
                                    [tree indx] = MST_tree({tree}, X, Y, Z, ...
                                        str2double (get (cgui.mtr.ui.ed_mst1, 'string')), ...
                                        str2double (get (cgui.mtr.ui.ed_mst2, 'string')), ...
                                        str2double (get (cgui.mtr.ui.ed_mst3, 'string')), ...
                                        [], 'none');
                                    tree.D (indx ((indx (:, 2) ~= 0), 2)) = D (indx (:, 2) ~= 0);
                                    cgui.ui.pHP = plot_tree (tree, [1 1 0]);
                                    pause (1);
                                    % rid editor and selector graphic
                                    % handles:
                                    cgui_tree ('ui_clean');
                                end
                        end
                    end
                end
            case cgui.keys.over {4}        % general rebuild functions
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 3 % skl_ edit-select actual skel point sparsening
                                cgui_tree ('skl_clean');
                        end
                    else
                        switch cgui.modes.panel
                            case 4 % mtr_ edit actual re-connecting nodes of sub-tree
                                if ~isempty (cgui.mtr.tree)
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    isub = find (sub_tree (cgui.mtr.tree, cgui.mtr.active));
                                    X = cgui.mtr.tree.X (isub); Y = cgui.mtr.tree.Y (isub);
                                    Z = cgui.mtr.tree.Z (isub); D = cgui.mtr.tree.D (isub);
                                    cgui.mtr.tree = delete_tree (cgui.mtr.tree, isub,'-r');
                                    [cgui.mtr.tree indx] = MST_tree ({cgui.mtr.tree}, X, Y, Z, ...
                                        str2double (get (cgui.mtr.ui.ed_mst1, 'string')), ...
                                        str2double (get (cgui.mtr.ui.ed_mst2, 'string')), ...
                                        str2double (get (cgui.mtr.ui.ed_mst3, 'string')), ...
                                        [], 'none');
                                    cgui.mtr.tree.D (indx (indx (:, 2) ~= 0, 2)) = D (indx (:, 2) ~= 0);
                                    cgui.mtr.lastnode = 1;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    end
                end
                
            case cgui.keys.over {5}        % decrease diameter
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 3 % skl_ edit-select decrease cleaning limit
                                set (cgui.skl.ui.ed_clean1, 'string', ...
                                    str2double (get (cgui.skl.ui.ed_clean1, 'string')) - .5);
                            case 4 % mtr_ edit-select decrease node diameter of selected nodes
                                if (~isempty (cgui.mtr.tree)) && (~isempty (cgui.mtr.selected))
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.selected) = ...
                                        cgui.mtr.tree.D (cgui.mtr.selected) * .9;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 2 % thr_ edit decrease local thresholding diameter
                                if ~isempty (cgui.thr.BW)
                                    if  cgui.thr.radius > 4
                                        cgui.thr.radius = cgui.thr.radius - 1;
                                    end
                                end
                            case 4 % mtr_ edit decrease node diameter at tree
                                if ~isempty (cgui.mtr.tree)
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.active) = ...
                                        cgui.mtr.tree.D (cgui.mtr.active) * 0.9;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    end
                end
            case cgui.keys.over {6}        % decrease diameter lots
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 3 % skl_ edit-select decrease cleaning limit
                                set (cgui.skl.ui.ed_clean1, 'string', ...
                                    str2double (get (cgui.skl.ui.ed_clean1, 'string')) - 2);
                            case 4 % mtr_ edit-select decrease node diameter of selected nodes
                                if (~isempty (cgui.mtr.tree)) && (~isempty (cgui.mtr.selected))
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.selected) = ...
                                        cgui.mtr.tree.D (cgui.mtr.selected) * .8;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 2 % thr_ edit decrease local thresholding diameter
                                if ~isempty (cgui.thr.BW)
                                    if cgui.thr.radius > 8
                                        cgui.thr.radius = cgui.thr.radius - 5;
                                    end
                                end
                            case 4 % mtr_ edit decrease node diameter at tree
                                if ~isempty (cgui.mtr.tree)
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.active) = ...
                                        cgui.mtr.tree.D (cgui.mtr.active) * .8;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    end
                end
            case cgui.keys.over {7}        % increase diameter
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 3 % skl_ edit-select increase cleaning limit
                                set (cgui.skl.ui.ed_clean1, 'string', ...
                                    str2double (get (cgui.skl.ui.ed_clean1, 'string')) + .5);
                            case 4 % mtr_ edit-select increase node diameter of selected nodes
                                if (~isempty (cgui.mtr.tree)) && (~isempty (cgui.mtr.selected))
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.selected) = ...
                                        cgui.mtr.tree.D (cgui.mtr.selected) * 1.1;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 2 % thr_ edit increase local thresholding diameter
                                if ~isempty (cgui.thr.BW)
                                    cgui.thr.radius = cgui.thr.radius + 1;
                                end
                            case 4 % mtr_ edit increase node diameter at tree
                                if ~isempty (cgui.mtr.tree)
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.active) = ...
                                        cgui.mtr.tree.D (cgui.mtr.active) * 1.1;
                                    cgui.mtr.lastnode = cgui.mtr.active;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    end
                end
            case cgui.keys.over {8}        % increase diameter lots
                if cgui.modes.edit
                    if cgui.modes.select
                        switch cgui.modes.panel
                            case 3 % skl_ edit-select increase cleaning limit
                                set (cgui.skl.ui.ed_clean1, 'string', ...
                                    str2double (get (cgui.skl.ui.ed_clean1, 'string')) + 2);
                            case 4 % mtr_ edit-select increase node diameter of selected nodes
                                if (~isempty (cgui.mtr.tree)) && (~isempty (cgui.mtr.selected))
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.selected) = ...
                                        cgui.mtr.tree.D (cgui.mtr.selected) * 1.2;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 2 % thr_ edit increase local thresholding diameter
                                if ~isempty (cgui.thr.BW)
                                    cgui.thr.radius = cgui.thr.radius + 5;
                                end
                            case 4 % mtr_ edit increase node diameter at tree
                                if ~isempty (cgui.mtr.tree)
                                    % keep track of old tree for undo:
                                    cgui.cat.untrees {end+1} = cgui.mtr.tree;
                                    cgui.mtr.tree.D (cgui.mtr.active) = ...
                                        cgui.mtr.tree.D (cgui.mtr.active) * 1.2;
                                    cgui.mtr.lastnode = cgui.mtr.active;
                                    % redraw mtr_ graphical output: active tree:
                                    cgui_tree ('mtr_image');
                                    % text output on tree length and number of nodes:
                                    cgui_tree ('mtr_inform');
                                end
                        end
                    end
                end
            case cgui.keys.over {9}        % set branchpoint %!%!%!
                if isfield(cgui.mtr.tree,'jpoints')
                    if numel(cgui.mtr.tree.jpoints) < numel(cgui.mtr.tree.X)
                        cgui.mtr.tree.jpoints(numel(cgui.mtr.tree.X),1) = 0;
                    end
                    cgui.mtr.tree.jpoints(cgui.mtr.lastnode,1) = sum(cgui.mtr.tree.jpoints>0)+1;
                else
                    cgui.mtr.tree.jpoints = zeros(numel(cgui.mtr.tree.X),1);
                    cgui.mtr.tree.jpoints(cgui.mtr.lastnode,1) = 1;
                end
                % redraw mtr_ graphical output: active tree:
                cgui_tree ('mtr_image');
                % text output on tree length and number of nodes:
                cgui_tree ('mtr_inform');
            case cgui.keys.over {10}        % jump to last branchpoint %!%!%!
                if isfield(cgui.mtr.tree,'jpoints') && sum(cgui.mtr.tree.jpoints)
                    cgui.mtr.lastnode = find(cgui.mtr.tree.jpoints==max(cgui.mtr.tree.jpoints),1,'last');%find(cgui.mtr.tree.jpoints,1,'last');
                    cgui.mtr.tree.jpoints(cgui.mtr.lastnode) = 0;
                    % remember initial mouse coordinates and camera:
                    set (cgui.ui.g1, 'cameratarget', double([cgui.mtr.tree.X(cgui.mtr.lastnode), cgui.mtr.tree.Y(cgui.mtr.lastnode), cgui.mtr.tree.Z(cgui.mtr.lastnode)]));
                    cgui.ui.camtarget = get (cgui.ui.g1, 'cameratarget');
                    set (cgui.ui.g1, 'cameraposition',cgui.ui.camtarget+[0 0 4000]);
                    cgui.ui.campos    = get (cgui.ui.g1, 'cameraposition');
                    % redraw mtr_ graphical output: active tree:
                    cgui_tree ('mtr_image');
                    % text output on tree length and number of nodes:
                    cgui_tree ('mtr_inform');
                    set (cgui.vis.ui.ed_setz, 'string',cgui.mtr.tree.Z(cgui.mtr.lastnode));
                     cgui_tree ('vis_setz');
                end
        end
end
end

%% additional functions

function cgui_mouse_tree (src, evnt, action)
global cgui
switch action, % respond to mouse in dependence of edit/select/viewing mode
    case 'mouse_bdown'              % button down actions
        switch get (src, 'SelectionType'), % check which type of button press:
            case 'normal'           % left mouse button down
                if cgui.modes.edit,
                    if cgui.modes.select,
                        switch cgui.modes.panel
                            case 1 % stk_ edit-select: draw ROI on stack
                                if ~isempty(cgui.stk.M)
                                    % reset all other edit mode handles:
                                    cgui.stk.selected = [];
                                    % rid editor and selector graphic handles:
                                    cgui_tree ('ui_clean');
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_stk_roi'});
                                end
                            case 2 % thr_ edit-select: no action here
                            case 3 % skl_ edit-select: move or add skeleton points
                                % rid editor and selector graphic handles:
                                cgui_tree ('ui_clean');
                                if cgui.skl.distance < 5
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_skl_movepoint'});
                                else
                                    % add skeleton point
                                    if (get (cgui.mtr.ui.t_snap3, 'value')),
                                        % find closest point on stack using zmax
                                        [x y z ix iy iz] = zmaxcursoronstack;
                                    else
                                        % find closest point on stack using slicer
                                        [ix iy iz] = cursoronstack;
                                        [x y z] = simplecursor (cgui.vis.iM, cgui.vis.iM, ...
                                            cgui.vis.iM);
                                    end
                                    cgui.skl.I  (end + 1, :) = [y x z];
                                    cgui.skl.BI (end + 1, :) = cgui.stk.M {end} (iy, ix, iz);
                                    cgui.skl.CI (end + 1, :) = [length(cgui.stk.M), iy, ix, iz];
                                    if ~isempty (cgui.skl.DI),
                                        % for now "estimates" diameter as 1
                                        cgui.skl.DI  (end + 1, :) = sdiameterestimate (ix, iy, iz, ...
                                            length (cgui.stk.M));
                                    end
                                    if ~isempty (cgui.skl.LI),
                                        cgui.skl.LI  (end + 1, :) = max (cgui.skl.LI) + 1;
                                    end
                                    if ~isempty (cgui.skl.CN),
                                        cgui.skl.CN  (:, end + 1) = 0;
                                        cgui.skl.CN  (end + 1, :) = 0;
                                    end
                                    if ~isempty (cgui.skl.tCN),
                                        cgui.skl.tCN (:, end + 1) = 0;
                                        cgui.skl.tCN (end + 1, :) = 0;
                                    end
                                    if ~isempty (cgui.skl.dCN),
                                        cgui.skl.dCN (:, end + 1) = 0;
                                        cgui.skl.dCN (end + 1, :) = 0;
                                    end
                                    % redraw skl_ graphical output:
                                    % skeletonized points:
                                    cgui_tree ('skl_image');
                                    % text output on number of skel
                                    % points:
                                    cgui_tree ('skl_inform');
                                end
                            case 4 % mtr_ edit-select: select nodes
                                if ~isempty (cgui.mtr.tree)
                                    cgui.mtr.startselect = cgui.mtr.active;
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_mtr_selectbranch'});
                                end
                            case 5 % ged_ edit-select: no action
                        end
                    else
                        switch cgui.modes.panel
                            case 1 % stk_ edit: move or choose a stack
                                if ~isempty (cgui.stk.M)
                                    % rid editor and selector graphic
                                    % handles:
                                    cgui_tree ('ui_clean');
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_stk_movestack'});
                                end
                            case 2 % thr_ edit: change the threshold locally
                                if ~isempty (cgui.thr.BW)
                                    cgui_mouse_tree ([], [], 'mouse_thr_lowthres');
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_thr_lowthres'});
                                end
                            case 3 % skl_ edit: move or add somata / selection points
                                % rid editor and selector graphic handles:
                                cgui_tree ('ui_clean');
                                if cgui.skl.distance < 5
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_skl_movesoma'});
                                else
                                    % add soma
                                    [x y z] = simplecursor (cgui.vis.iM, cgui.vis.iM, ...
                                        cgui.vis.iM);
                                    cgui.skl.S (end + 1, :) = [y x z];
                                    % redraw skl_ graphical output:
                                    % skeletonized points:
                                    cgui_tree ('skl_image');
                                    % text output on number of skel
                                    % points:
                                    cgui_tree ('skl_inform')
                                end
                            case 4 % mtr_ edit: move or add points
                                if ~isempty (cgui.mtr.tree)
                                    if (isfield(cgui.modes,'hold') && cgui.modes.hold == 0 && cgui.mtr.distance < (mean (cgui.stk.voxel (1 : 2)) * 3)) || ~isfield(cgui.modes,'hold') && cgui.mtr.distance < (mean (cgui.stk.voxel (1 : 2)) * 3)
                                        % rid editor and selector graphic
                                        % handles:
                                        cgui_tree ('ui_clean');
                                        % many ways to move nodes are
                                        % implemented:
                                        if get (cgui.mtr.ui.t_move4, 'value'),
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_rubbermove'});
                                        elseif  get(cgui.mtr.ui.t_move3, 'value'),
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_movesubtree'});
                                        elseif  get (cgui.mtr.ui.t_move2, 'value'),
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_moveselected'});
                                        else
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_movepoint'});
                                        end
                                        cgui.mtr.lastnode = cgui.mtr.active;
                                        % redraw mtr_ graphical output: active
                                        % tree:
                                        cgui_tree ('mtr_image');
                                    else
                                        % the added point can be either on
                                        % the slicer third dimension or on
                                        % the same third dimension value as
                                        % the parent point in the tree or
                                        % the maximum intensity value
                                        % (zmax) or the added point can
                                        % snap to a skeleton point or
                                        % finally a point which is maximal
                                        % in intensity in the neighborhood:
                                        if get (cgui.mtr.ui.t_snap2, 'value') && ...
                                                (~isempty (cgui.skl.I)),
                                            cgui_mouse_tree ([], [], 'mouse_mtr_addskelpoints');
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_addskelpoints'});
                                        elseif get (cgui.mtr.ui.t_snap1, 'value') && ...
                                                (~isempty (cgui.stk.M)),
                                            cgui_mouse_tree ([], [], 'mouse_mtr_addthrpoints');
                                            set (cgui.ui.F, 'WindowButtonMotionFcn',...
                                                {@cgui_mouse_tree, 'mouse_mtr_addthrpoints'});
                                        elseif get (cgui.mtr.ui.t_snap3, 'value') && ...
                                                (~isempty (cgui.stk.M)),
                                            cgui_mouse_tree ([], [], 'mouse_mtr_addpointszmax');
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_addpointszmax'});
                                        elseif get (cgui.mtr.ui.t_snap4, 'value'),
                                            cgui_mouse_tree ([], [], 'mouse_mtr_addpointsztree');
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_addpointsztree'});
                                        else
                                            cgui_mouse_tree ([], [], 'mouse_mtr_addpoints');
                                            set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                                {@cgui_mouse_tree, 'mouse_mtr_addpoints'});
                                        end
                                    end
                                end
                            case 5 % ged_ edit: move/scale/rotate tree
                                cgui.ged.initpoint = get (cgui.ui.g1, 'CurrentPoint');
                                cgui.ged.tree = cgui.mtr.tree;
                                if get (cgui.ged.ui.t1, 'value'), % read toggle-buttons
                                    cgui.ged.remember = 1;
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_ged_scaletree'});
                                elseif get (cgui.ged.ui.t2, 'value'),
                                    cgui.ged.remember = [0 0 0];
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_ged_rottree'});
                                else
                                    cgui.ged.remember = [cgui.mtr.tree.X(1), ...
                                        cgui.mtr.tree.Y(1), cgui.mtr.tree.Z(1)];
                                    set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                                        {@cgui_mouse_tree, 'mouse_ged_movetree'});
                                end
                        end
                    end
                else
                    % zoom in briefly to indicate mouse click in no edit
                    % mode:
                    angle = get (cgui.ui.g1, 'cameraviewangle');
                    for ward = 1 : -.1 : .9,
                        set (cgui.ui.g1, 'cameraviewangle', angle * ward);
                        pause (.05);
                    end
                    set (cgui.ui.g1, 'cameraviewangle', angle);
                end
            case 'open'             % double click
                if cgui.modes.edit,
                    if cgui.modes.select,
                        switch cgui.modes.panel
                            case 1 % stk_ edit-select: activate closest stack:
                                if cgui.stk.active ~= length (cgui.stk.M),
                                    % if closest stack is not active then
                                    % activate it:
                                    set (cgui.stk.ui.pop, 'value', cgui.stk.active);
                                    cgui_tree ('stk_pop');
                                end
                            case 4 % mtr_ edit-select: unselect all nodes
                                if ~isempty (cgui.mtr.tree)
                                    cgui.mtr.startselect = cgui.mtr.active;
                                    cgui.mtr.selected = [];
                                    % redraw mtr_ graphical output: active
                                    % tree:
                                    cgui_tree ('mtr_image');
                                end
                        end
                    else
                        switch cgui.modes.panel
                            case 1 % stk_ edit: activate closest stack:
                                if cgui.stk.active ~= length (cgui.stk.M),
                                    % if closest stack is not active then
                                    % activate it:
                                    set (cgui.stk.ui.pop, 'value', cgui.stk.active);
                                    cgui_tree ('stk_pop');
                                    cgui_mouse_tree ([], [], 'mouse_stk_editor');
                                end
                            case 4 % mtr_ edit: add point 1um before active node
                                if ~isempty (cgui.mtr.tree)
                                    if cgui.mtr.distance < 3 && (~isfield(cgui.modes,'hold') || cgui.modes.hold == 0)
                                        Plen = Pvec_tree (cgui.mtr.tree);
                                        Plen (cgui.mtr.active);
                                        if Plen (cgui.mtr.active) > 3,
                                            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
                                            cgui.mtr.tree = insertp_tree (cgui.mtr.tree, cgui.mtr.active,Plen (cgui.mtr.active) - 1, 'none');
                                            cgui.mtr.lastnode = 1;
                                            cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
                                            % redraw mtr_ graphical output: active
                                            % tree:
                                            cgui_tree ('mtr_image');
                                            % text output on tree length and
                                            % number of nodes:
                                            cgui_tree ('mtr_inform');
                                        end
                                    end
                                end
                            case 5 % ged_ edit: choose different cell
                                if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
                                    set (cgui.cat.ui.f1, 'value', cgui.ged.active);
                                    cgui_tree ('cat_selecttree');
                                end
                        end
                    end
                end
            case 'alt'              % right mouse button down: rotate
                if get (cgui.plt.ui.r1, 'value') == 0,
                    for ward = 1 : length (cgui.plt.HPs),
                        set (cgui.plt.HPs {ward}, 'visible', 'off');
                    end
                    if ~isempty(cgui.thr.HP),
                        for ward = 1 : length(cgui.thr.HP),
                            set(cgui.thr.HP {ward}, 'visible', 'off');
                        end
                    end
                end
                set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                    {@cgui_mouse_tree, 'mouse_rotate'});
                setptr(cgui.ui.F, 'fleur'); % change mouse cursor
                % remember initial mouse coordinates and camera:
                cgui.ui.initpoint = get (cgui.ui.g1, 'CurrentPoint');
                cgui.ui.campos    = get (cgui.ui.g1, 'cameraposition');
                cgui.ui.camtarget = get (cgui.ui.g1, 'cameratarget');
            case 'extend'           % middle mouse button down: pan
                if get (cgui.plt.ui.r1, 'value' ) == 0 ,
                    for ward = 1 : length(cgui.plt.HPs),
                        set (cgui.plt.HPs {ward}, 'visible', 'off');
                    end
                    if ~isempty (cgui.thr.HP),
                        for ward = 1 : length (cgui.thr.HP),
                            set (cgui.thr.HP {ward}, 'visible', 'off');
                        end
                    end
                end
                set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                    {@cgui_mouse_tree, 'mouse_pan'});
                setptr (cgui.ui.F, 'closedhand'); % change mouse cursor
                % remember initial mouse coordinates and camera:
                cgui.ui.initpoint = get (cgui.ui.g1, 'CurrentPoint');
                cgui.ui.campos =    get (cgui.ui.g1, 'cameraposition');
                cgui.ui.camtarget = get (cgui.ui.g1, 'cameratarget');
        end
    case 'mouse_udown'              % button up actions
        set (cgui.ui.F, 'WindowButtonMotionFcn', '');
        if cgui.modes.edit,
            % back to simple editor or selector mode after some mouse
            % action
            set (cgui.ui.F, 'pointer', 'circle'); % edit mode mouse cursor
            if cgui.modes.select
                switch cgui.modes.panel
                    case 1 % stk_ edit-select: reactivate selector
                        cgui_mouse_tree ([], [], 'mouse_stk_selector');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_stk_selector'});
                    case 2 % thr_ edit-select: reactivate selector
                        cgui_tree ('thr_image'); % redraw thr_ graphical output
                        cgui_mouse_tree ([], [], 'mouse_thr_selector');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_thr_selector'});
                    case 3 % skl_ edit-select: reactivate selector
                        % rid editor and selector graphic handles
                        cgui_tree ('ui_clean');
                        cgui_mouse_tree ([], [], 'mouse_skl_selector');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_skl_selector'});
                    case 4 % mtr_ edit-select: reactivate selector
                        if strcmp (get (src, 'SelectionType'), 'normal'),
                            % on the path selection happens exactly when you
                            % unpress the mouse button:
                            % parent index structure (see
                            % "ipar_tree"):
                            ipar = ipar_tree (cgui.mtr.tree);
                            % try to find any of starting or end node in
                            % the path of the other:
                            i0 = find (ipar (cgui.mtr.startselect,:) == cgui.mtr.active);
                            i1 = find (ipar (cgui.mtr.active,     :) == cgui.mtr.startselect);
                            if ~isempty (i0),
                                selected = ipar (cgui.mtr.startselect, 1 : i0)';
                            else
                                selected = ipar (cgui.mtr.active,      1 : i1)';
                            end
                            % add to selection or take away from selection
                            % depending on whether starting node was
                            % selected:
                            if ismember (cgui.mtr.startselect, cgui.mtr.selected),
                                cgui.mtr.selected = setdiff (cgui.mtr.selected, ...
                                    selected);
                            else
                                cgui.mtr.selected = unique ([cgui.mtr.selected; ...
                                    selected]);
                            end
                            if ~isempty (selected)
                                cgui.mtr.lastnode = selected (end);
                            end
                            cgui_tree ('mtr_image');
                        end
                        cgui_mouse_tree ([], [], 'mouse_mtr_selector');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_mtr_selector'});
                    case 5 % ged_ edit-select: reactivate selector
                        cgui_mouse_tree ([], [], 'mouse_ged_selector');
                        set (cgui.ui.F,'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_ged_selector'});
                end
            else
                switch cgui.modes.panel
                    case 1 % stk_ edit: reactivate editor
                        cgui_mouse_tree ([], [], 'mouse_stk_editor');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_stk_editor'});
                    case 2 % thr_ edit: reactivate editor
                        % redraw stk_ graphical output: image
                        % stacks:
                        cgui_tree ('stk_image');
                        cgui_tree ('thr_image'); % redraw thr_ graphical output
                        cgui_mouse_tree ([], [], 'mouse_thr_editor');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_thr_editor'});
                    case 3 % skl_ edit: reactivate editor
                        cgui_mouse_tree ([], [], 'mouse_skl_editor');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_skl_editor'});
                    case 4 % mtr_ edit: reactivate editor
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
            cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
                        
                        cgui_mouse_tree ([], [], 'mouse_mtr_editor');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_mtr_editor'});
                    case 5 % ged_ edit: reactivate editor
                        if strcmp (get (src, 'SelectionType'), 'normal'),
                            if get (cgui.ged.ui.t1, 'value'), % read toggle-buttons
                                % do full scaling
                                cgui.mtr.tree = cgui.ged.tree;
                                gedapply2 ('scale_tree', cgui.ged.remember, 1);
                            elseif get (cgui.ged.ui.t2, 'value'),
                                % do full rotation
                                cgui.mtr.tree = cgui.ged.tree;
                                gedapply2 ('rot_tree', cgui.ged.remember, 1);
                            else
                                % do full moving:
                                motion_vector = [cgui.mtr.tree.X(1), cgui.mtr.tree.Y(1), ...
                                    cgui.mtr.tree.Z(1)] - cgui.ged.remember;
                                cgui.mtr.tree = cgui.ged.tree;
                                gedapply2 ('tran_tree', motion_vector);
                            end
                            cgui_tree ('ged_settran');
                        end
                        cgui_mouse_tree ([], [], 'mouse_ged_editor');
                        set (cgui.ui.F, 'WindowButtonMotionFcn', ...
                            {@cgui_mouse_tree, 'mouse_ged_editor'});
                end
            end
        else
            % if we were in simple vis_ submodes (rotation, pan or zoom)
            % then revert to none-edit mouse cursor:
            setptr (cgui.ui.F, 'arrow');
        end
        if get (cgui.plt.ui.r1, 'value') == 0,
            for ward = 1 : length (cgui.plt.HPs),
                set (cgui.plt.HPs {ward}, 'visible', 'on');
            end
            if ~isempty (cgui.thr.HP),
                for ward = 1 : length (cgui.thr.HP),
                    set (cgui.thr.HP {ward}, 'visible', 'on');
                end
            end
        end
        
        % vis_ general navigation with the mouse:
    case 'mouse_pan'                % pan the axis (press middle mouse button)
        % first of three vis_ panel mouse actions: pan
        % this function is active while button down only and is called by
        % mouse movement:
        cp = get (cgui.ui.g1, 'CurrentPoint'); % get mouse coordinates
        change = cp (1, 1 : 3) - cgui.ui.initpoint (1, 1 : 3); % compare to reference
        % change camera position accordingly:
        set (cgui.ui.g1, 'cameratarget', -change + cgui.ui.camtarget (1 : 3), ...
            'cameraposition', -change + cgui.ui.campos (1 : 3));
        cp2 = get (cgui.ui.g1, 'CurrentPoint'); % get mouse coordinates
        % reset reference point:
        cgui.ui.initpoint = cgui.ui.initpoint + (cp2 - cp);
    case 'mouse_rotate'             % rotate axis (press right mouse button)
        % second of three vis_ panel mouse actions: rotate
        % this function is active while button down only and is called by
        % mouse movement:
        cp     = get (cgui.ui.g1, 'CurrentPoint'); % get mouse coordinates
        % compare to reference (set on button down):
        change = cp (1, 1 : 3) - cgui.ui.initpoint (1, 1 : 3);
        if sqrt (sum (change.^2)) > 100
            change = change / 3;
        end
        % change camera position accordingly:
        campos = get (cgui.ui.g1, 'cameraposition');
        amp    = sqrt (sum ((cgui.ui.campos - cgui.ui.camtarget).^2));
        campos = - change + campos;
        amp2   = sqrt (sum ((campos         - cgui.ui.camtarget).^2));
        set (cgui.ui.g1, 'cameraposition', cgui.ui.camtarget + (amp ./ amp2) * ...
            (campos - cgui.ui.camtarget));
    case 'mouse_wheel'              % zoom axis and with cntrl change slicer
        modifier = get (cgui.ui.F, 'Currentmodifier');
        if isempty (modifier), % zoom axis
            % second of three vis_ panel mouse actions: zoom
            % this function is activated by mouse wheel turning
            % simply adjust camera angle:
            angle = get (cgui.ui.g1, 'cameraviewangle');
            set (cgui.ui.g1, 'cameraviewangle', angle * (1 + 0.1 * evnt.VerticalScrollCount));
        else
            switch modifier {1},
                case 'shift' % change slicer lots
                    % this function is activated by mouse wheel turning
                    if evnt.VerticalScrollCount > 0
                        cgui_tree ('vis_iMm5');
                    else
                        cgui_tree ('vis_iMp5');
                    end
                case 'alt'     % nothing yet!
                case 'control' % change slicer
                    % this function is activated by mouse wheel turning
                    if evnt.VerticalScrollCount > 0
                        cgui_tree ('vis_iMm1');
                    else
                        cgui_tree ('vis_iMp1');
                    end
                otherwise
            end
        end
        
    case 'mouse_stk_editor'         % edit mode: select a stack
        if ~isempty (cgui.stk.M)
            % get mouse cursor position and check which stack is closest
            [x y z cgui.stk.distance cgui.stk.active] = ...
                close2cursor (cgui.stk.coord (:, 1), cgui.stk.coord (:, 2), ...
                cgui.stk.coord (:, 3), 0);
            % draw green line to closest image stack origin:
            drawcursorline (x, y, z, cgui.stk.coord (cgui.stk.active, 1), ...
                cgui.stk.coord (cgui.stk.active, 2), cgui.stk.coord (cgui.stk.active, 3));
            x1 = cgui.stk.coord (end, 1) - cgui.stk.voxel (1) / 2;
            x2 = cgui.stk.voxel (1) * size (cgui.stk.M {end}, 2) - cgui.stk.voxel (1) / 2;
            y1 = cgui.stk.coord (end, 2) - cgui.stk.voxel (2) / 2;
            y2 = cgui.stk.voxel (2) * size (cgui.stk.M {end}, 1) - cgui.stk.voxel (2) / 2;
            z1 = cgui.stk.coord (end, 3) - cgui.stk.voxel (3) / 2;
            z2 = cgui.stk.voxel (3) * size (cgui.stk.M {end}, 3) - cgui.stk.voxel (3) / 2;
            % cube
            cX = [0 0 0 0; 0 1 1 0; 0 1 1 0; 1 1 0 0; 1 1 0 0; 1 1 1 1];
            cY = [0 0 1 1; 0 0 1 1; 1 1 1 1; 0 1 1 0; 0 0 0 0; 0 0 1 1];
            cZ = [0 1 1 0; 0 0 0 0; 1 1 0 0; 1 1 1 1; 1 0 0 1; 0 1 1 0];
            % patch a red box around the activated stack:
            if (~isempty (cgui.ui.pHP)) && ishandle (cgui.ui.pHP),
                % if patch handle exists update its coordinates:
                set (cgui.ui.pHP, 'xdata', x1 + cX' * x2);
                set (cgui.ui.pHP, 'ydata', y1 + cY' * y2);
                set (cgui.ui.pHP, 'zdata', z1 + cZ' * z2);
            else
                % draw a patch around active stack:
                cgui.ui.pHP = patch (x1 + cX' * x2, y1 + cY' * y2, z1 + cZ' * z2);
                % hein?
                set (cgui.ui.pHP, 'xdata', x1 + cX' * x2);
                set (cgui.ui.pHP, 'ydata', y1 + cY' * y2);
                set (cgui.ui.pHP, 'zdata', z1 + cZ' * z2);
                set (cgui.ui.pHP, 'linestyle', ':', 'linewidth', 4, 'cdata', 0, ...
                    'edgecolor', [1 0 0], 'facecolor', [1 0 0], 'facealpha', .2);
            end
        end
    case 'mouse_stk_movestack'      % edit submode: move active stack
        if ~isempty (cgui.stk.M),
            % simply change stack coordinates in edit fields
            [x y z] = simplecursor (cgui.stk.coord (end, 1), ...
                cgui.stk.coord (end, 2), cgui.stk.coord (end, 3));
            set (cgui.stk.ui.ed_tran1, 'string', num2str (round (x)));
            set (cgui.stk.ui.ed_tran2, 'string', num2str (round (y)));
            set (cgui.stk.ui.ed_tran3, 'string', num2str (round (z)));
            cgui_tree ('stk_setcoord'); % and update stk_ coordinates
        end
    case 'mouse_stk_selector'       % edit-select mode: show which stack is ROIed:
        if ~isempty (cgui.stk.M)
            % get mouse cursor position and check which stack is closest
            [x y z cgui.stk.distance cgui.stk.active] = ...
                close2cursor (cgui.stk.coord (:, 1), cgui.stk.coord (:, 2), ...
                cgui.stk.coord (:, 3), 0);
            % draw a yellow line to closest image stack origin, the ROI
            % would be cut out in that stack. One ROI can be used on many
            % overlapping stacks in this way:
            drawcursorline (x, y, z, cgui.stk.coord (cgui.stk.active, 1), ...
                cgui.stk.coord (cgui.stk.active, 2), ...
                cgui.stk.coord (cgui.stk.active, 3));
            % edit-select-mode color is yellow:
            set (cgui.ui.lHP, 'color', [1 1 0]);
        end
    case 'mouse_stk_roi'            % edit-select submode: select region of interest (ROI)
        if ~isempty (cgui.stk.M),
            % update selection polygon with current cursor position
            cgui_tree ('ui_clean'); % rid editor and selector graphic handles
            [x y z] = simplecursor (cgui.vis.iM, cgui.vis.iM, cgui.vis.iM);
            cgui.stk.selected = [cgui.stk.selected; x y z];
            % path a yellow transparent ROI:
            cgui.ui.pHP = patch (cgui.stk.selected (:, 1), cgui.stk.selected (:, 2), ...
                cgui.stk.selected (:, 3), [0 0 0]);
            set (cgui.ui.pHP, 'linestyle', ':', 'linewidth', 2, 'facecolor', ...
                [1 1 0], 'edgecolor', [1 1 0], 'facealpha', 0.5);
        end
        
    case 'mouse_thr_editor'         % edit mode: show locus of local thresholding
        if ~isempty (cgui.thr.BW)
            if isempty (cgui.stk.active),
                cgui.stk.active = length (cgui.stk.M);
            end
            cp = get (cgui.ui.g1, 'CurrentPoint');
            switch cgui.modes.view
                case 2  % xz view
                    x = cp (1, 1) + [-1 1 1 -1 -1] * cgui.thr.radius;
                    y = cgui.vis.iM + [0 0 0 0 0];
                    z = cp (1, 3) + [-1 -1 1 1 -1] * cgui.thr.radius;
                case 3  % yz view
                    x = cgui.vis.iM + [0 0 0 0 0];
                    y = cp (1, 2) + [-1 1 1 -1 -1] * cgui.thr.radius;
                    z = cp (1, 3) + [-1 -1 1 1 -1] * cgui.thr.radius;
                otherwise  % xy and 3D view
                    x = cp (1, 1) + [-1 1 1 -1 -1] * cgui.thr.radius;
                    y = cp (1, 2) + [-1 -1 1 1 -1] * cgui.thr.radius;
                    z = cgui.vis.iM + [0 0 0 0 0];
            end
            % draw green tile in which threshold is reset according to edit
            % field, this happens in the active stack.
            drawcursorline (x, y, z, cgui.stk.coord (cgui.stk.active, 1), ...
                cgui.stk.coord (cgui.stk.active, 2), ...
                cgui.stk.coord (cgui.stk.active, 3));
        end
    case 'mouse_thr_lowthres'       % edit submode: lower the threshold locally
        if ~isempty (cgui.thr.BW),
            cgui_mouse_tree ([], [], 'mouse_thr_editor');
            % the tile becomes red when thresholding is active:
            set (cgui.ui.lHP, 'color', [1 0 0]);
            cp = get (cgui.ui.g1, 'CurrentPoint');
            switch cgui.modes.view % local thresholding depends on view:
                case 2  % xz view
                    x1 = round ((cp (1, 1) - cgui.stk.coord (cgui.stk.active, 1) - cgui.thr.radius) ./ ...
                        cgui.stk.voxel (1));
                    if x1 < 1, x1 = 1; end
                    x2 = round ((cp (1, 1) - cgui.stk.coord (cgui.stk.active, 1) + cgui.thr.radius) ./ ...
                        cgui.stk.voxel (1));
                    if x2 >  size (cgui.thr.BW {cgui.stk.active}, 2),
                        x2 = size (cgui.thr.BW {cgui.stk.active}, 2);
                    end
                    z1 = round ((cp (1, 3) - cgui.stk.coord (cgui.stk.active, 3) - cgui.thr.radius) ./ ...
                        cgui.stk.voxel (3));
                    if z1 < 1, z1 = 1; end
                    z2 = round ((cp (1, 3) - cgui.stk.coord (cgui.stk.active, 3) + cgui.thr.radius) ./ ...
                        cgui.stk.voxel (3));
                    if z2 > size  (cgui.thr.BW {cgui.stk.active}, 3),
                        z2 = size (cgui.thr.BW {cgui.stk.active}, 3);
                    end
                    cgui.thr.BW {cgui.stk.active} (:, x1 : x2, z1 : z2) = ...
                        cgui.stk.M {cgui.stk.active} (:, x1 : x2, z1 : z2) > ...
                        str2double (get (cgui.thr.ui.ed_thr1, 'string'));
                case 3  % yz view
                    y1 = round ((cp (1, 2) - cgui.stk.coord (cgui.stk.active, 2) - cgui.thr.radius) ./ ...
                        cgui.stk.voxel (2));
                    if y1 < 1, y1 = 1; end
                    y2 = round ((cp (1, 2) - cgui.stk.coord (cgui.stk.active, 2) + cgui.thr.radius) ./ ...
                        cgui.stk.voxel (2));
                    if y2 > size  (cgui.thr.BW {cgui.stk.active}, 1),
                        y2 = size (cgui.thr.BW {cgui.stk.active}, 1);
                    end
                    z1 = round ((cp (1, 3) - cgui.stk.coord (cgui.stk.active, 3) - cgui.thr.radius) ./ ...
                        cgui.stk.voxel (3));
                    if z1<1, z1 = 1; end
                    z2 = round ((cp (1, 3) - cgui.stk.coord (cgui.stk.active, 3) + cgui.thr.radius) ./ ...
                        cgui.stk.voxel (3));
                    if z2 >  size (cgui.thr.BW {cgui.stk.active}, 3),
                        z2 = size (cgui.thr.BW {cgui.stk.active}, 3);
                    end
                    cgui.thr.BW {cgui.stk.active} (y1 : y2, :, z1 : z2) = ...
                        cgui.stk.M {cgui.stk.active} (y1 : y2, :, z1 : z2) > ...
                        str2double (get (cgui.thr.ui.ed_thr1, 'string'));
                otherwise  % xy and 3D view
                    x1 = round ((cp (1, 1) - cgui.stk.coord (cgui.stk.active, 1) - cgui.thr.radius) ./ ...
                        cgui.stk.voxel (1));
                    if x1 < 1, x1 = 1; end
                    x2 = round ((cp (1, 1) - cgui.stk.coord (cgui.stk.active, 1) + cgui.thr.radius) ./ ...
                        cgui.stk.voxel (1));
                    if x2 > size  (cgui.thr.BW {cgui.stk.active}, 2),
                        x2 = size (cgui.thr.BW {cgui.stk.active}, 2);
                    end
                    y1 = round ((cp (1, 2) - cgui.stk.coord (cgui.stk.active, 2) - cgui.thr.radius) ./ ...
                        cgui.stk.voxel (2));
                    if y1 < 1, y1 = 1; end
                    y2 = round ((cp (1, 2) - cgui.stk.coord (cgui.stk.active, 2) + cgui.thr.radius) ./ ...
                        cgui.stk.voxel (2));
                    if y2 > size  (cgui.thr.BW {cgui.stk.active}, 1),
                        y2 = size (cgui.thr.BW {cgui.stk.active}, 1);
                    end
                    cgui.thr.BW {cgui.stk.active} (y1 : y2, x1 : x2, :) = ...
                        cgui.stk.M {cgui.stk.active} (y1 : y2, x1 : x2, :) > ...
                        str2double (get (cgui.thr.ui.ed_thr1, 'string'));
            end
        end
    case 'mouse_thr_selector'       % nothing really
        if ~isempty (cgui.thr.BW)
            if isempty (cgui.stk.active),
                cgui.stk.active = length (cgui.stk.M);
            end
            % get mouse cursor position and check which stack is closest
            [x y z] = simplecursor (cgui.stk.coord (end, 1), cgui.stk.coord (end, 2), ...
                cgui.stk.coord (end, 3));
            drawcursorline (x, y, z, cgui.stk.coord (cgui.stk.active, 1), ...
                cgui.stk.coord (cgui.stk.active, 2), cgui.stk.coord (cgui.stk.active, 3));
            set (cgui.ui.lHP, 'color', [1 1 0]);
        end
        
    case 'mouse_skl_editor'         % edit modes: position somata
        % position somata:
        if ~isempty (cgui.skl.S),
            % select closest soma:
            [x y z cgui.skl.distance cgui.skl.active] = ...
                close2cursor (cgui.skl.S (:, 2), cgui.skl.S (:, 1), ...
                cgui.skl.S (:, 3), cgui.vis.iM);
        else
            [x y z] = simplecursor (cgui.vis.iM, cgui.vis.iM, cgui.vis.iM);
            cgui.skl.distance = inf;
        end
        if cgui.skl.distance < 10 % draw a green line to closest soma
            drawcursorline (x, y, z, cgui.skl.S (cgui.skl.active, 2), ...
                cgui.skl.S (cgui.skl.active, 1), cgui.skl.S (cgui.skl.active, 3));
        else % or just a complicated red cross
            drawcursorcross (x, y, z);
        end
    case 'mouse_skl_movesoma'       % edit submode: move an existing soma
        if ~isempty (cgui.skl.S),
            [x y z] = simplecursor (cgui.skl.S (cgui.skl.active, 2), ...
                cgui.skl.S (cgui.skl.active, 1), cgui.skl.S (cgui.skl.active, 3));
            cgui.skl.S (cgui.skl.active, :) = [y x z];
            cgui_tree ('skl_image'); % redraw skl_ graphical output: skeletonized points
        end
    case 'mouse_skl_selector'       % edit-select mode: position skeleton points
        if ~isempty (cgui.skl.I),
            % select closest skeleton point:
            [x y z cgui.skl.distance cgui.skl.active] = ...
                close2cursor (cgui.skl.I (:, 2), cgui.skl.I (:, 1), ...
                cgui.skl.I (:, 3), cgui.vis.iM);
            % draw a yellow line to closest skeleton point
            drawcursorline (x, y, z, cgui.skl.I (cgui.skl.active, 2), ...
                cgui.skl.I (cgui.skl.active, 1), cgui.skl.I (cgui.skl.active, 3));
            set (cgui.ui.lHP, 'color', [1 1 0]);
        else
            % or (only if no skel. point exists) a complicated yellow
            % cross:
            [x y z] = simplecursor (cgui.vis.iM, cgui.vis.iM, cgui.vis.iM);
            drawcursorcross (x, y, z);
            set (cgui.ui.lHP, 'color', [1 1 0]);
        end
    case 'mouse_skl_movepoint'      % edit-select submode: move an existing skeletonized point
        if ~isempty (cgui.skl.I),
            [x y z] = simplecursor (cgui.skl.I (cgui.skl.active,2), ...
                cgui.skl.I (cgui.skl.active, 1), cgui.skl.I (cgui.skl.active, 3));
            cgui.skl.I (cgui.skl.active, :) = [y x z];
            cgui_tree ('skl_image'); % redraw skl_ graphical output: skeletonized points
        end
        
    case 'mouse_mtr_editor'         % edit mode: select a node on a tree
        if ~isempty (cgui.mtr.tree)
            % draw a line between cursor and closest node on tree
            if get (cgui.mtr.ui.t_snap1, 'value') && (~isempty (cgui.stk.M)),
                [x y z cgui.mtr.distance cgui.mtr.active] = ...
                    close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, cgui.mtr.tree.Z);
                [x y z] = brightestneighbor;
                drawcursorline (x, y, z, cgui.mtr.tree.X (cgui.mtr.active), ...
                    cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            elseif get (cgui.mtr.ui.t_snap2, 'value') && (~isempty (cgui.skl.I)),
                [x y z cgui.mtr.distance cgui.mtr.active] = ...
                    close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, ...
                    cgui.mtr.tree.Z, cgui.vis.iM);
                [x y z cgui.skl.distance cgui.skl.active] = ...
                    close2cursor (cgui.skl.I (:, 2), cgui.skl.I (:, 1), ...
                    cgui.skl.I (:,3), cgui.vis.iM);
                drawcursorline (cgui.skl.I (cgui.skl.active, 2), cgui.skl.I (cgui.skl.active, 1), ...
                    cgui.skl.I (cgui.skl.active, 3),   cgui.mtr.tree.X (cgui.mtr.active), ...
                    cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            else
                if isfield(cgui.modes,'hold') && cgui.modes.hold == 1
                    [x y z cgui.mtr.distance cgui.mtr.active] = ...
                        close2cursor (cgui.mtr.tree.X(cgui.mtr.lastnode), cgui.mtr.tree.Y(cgui.mtr.lastnode), ...
                        cgui.mtr.tree.Z(cgui.mtr.lastnode), cgui.vis.iM);
                    cgui.mtr.active = cgui.mtr.lastnode;
                else
                    [x y z cgui.mtr.distance cgui.mtr.active] = ...
                        close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, ...
                        cgui.mtr.tree.Z, cgui.vis.iM);
                end
                drawcursorline (x, y, z, cgui.mtr.tree.X (cgui.mtr.active), ...
                    cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            end
            if cgui.mtr.distance < (mean (cgui.stk.voxel (1 : 2)) * 3),
                set (cgui.ui.lHP, 'color', [0 1 0]); % if close: paint green
            else
                set (cgui.ui.lHP, 'color', [1 0 0]); % otherwise red
            end
        end
    case 'mouse_mtr_movepoint'      % edit submode: move a single node on the tree
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            [x y z] = simplecursor (cgui.mtr.tree.X (cgui.mtr.active), ...
                cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            cgui.mtr.tree.X (cgui.mtr.active) = x;
            cgui.mtr.tree.Y (cgui.mtr.active) = y;
            cgui.mtr.tree.Z (cgui.mtr.active) = z;
            cgui.mtr.lastnode = cgui.mtr.active;
            drawcursorcross (x, y, z);
%             cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
%             cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
    case 'mouse_mtr_rubbermove'     % edit submode: move all nodes in neighborhood
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            % make movement dependent on the gauss of the euclidean
            % distance to the closest node in tree:
            eucl = eucl_tree (cgui.mtr.tree, cgui.mtr.active);
            eucl = gauss (eucl, 0, 3) ./ gauss (0, 0, 3); % moving factor for rest of tree
            [x y z] = simplecursor (cgui.mtr.tree.X (cgui.mtr.active), ...
                cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            cgui.mtr.tree.X = cgui.mtr.tree.X + ...
                eucl .* (x - cgui.mtr.tree.X (cgui.mtr.active));
            cgui.mtr.tree.Y = cgui.mtr.tree.Y + ...
                eucl .* (y - cgui.mtr.tree.Y (cgui.mtr.active));
            cgui.mtr.tree.Z = cgui.mtr.tree.Z + ...
                eucl .* (z - cgui.mtr.tree.Z (cgui.mtr.active));
            cgui.mtr.lastnode = cgui.mtr.active;
            drawcursorcross (x, y, z);            
%             cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
%             cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
    case 'mouse_mtr_moveselected'	% edit submode: move selected points on the tree
        if (~isempty (cgui.mtr.tree)) && (~isempty (cgui.mtr.selected)),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            [x y z] = simplecursor (cgui.mtr.tree.X (cgui.mtr.active), ...
                cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            cgui.mtr.tree.X (cgui.mtr.selected) = cgui.mtr.tree.X (cgui.mtr.selected) + ...
                (x - cgui.mtr.tree.X (cgui.mtr.active));
            cgui.mtr.tree.Y (cgui.mtr.selected) = cgui.mtr.tree.Y (cgui.mtr.selected) + ...
                (y - cgui.mtr.tree.Y (cgui.mtr.active));
            cgui.mtr.tree.Z (cgui.mtr.selected) = cgui.mtr.tree.Z (cgui.mtr.selected) + ...
                (z - cgui.mtr.tree.Z (cgui.mtr.active));
            cgui.mtr.lastnode = cgui.mtr.active;
            drawcursorcross (x, y, z);            
%             cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
%             cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
    case 'mouse_mtr_movesubtree'    % edit submode: move selected points on the tree
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            [x y z] = simplecursor (cgui.mtr.tree.X (cgui.mtr.active), ...
                cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            isub = [cgui.mtr.active; find(sub_tree (cgui.mtr.tree, cgui.mtr.active))];
            cgui.mtr.tree.X (isub) = cgui.mtr.tree.X (isub) + ...
                (x - cgui.mtr.tree.X (cgui.mtr.active));
            cgui.mtr.tree.Y (isub) = cgui.mtr.tree.Y (isub) + ...
                (y - cgui.mtr.tree.Y (cgui.mtr.active));
            cgui.mtr.tree.Z (isub) = cgui.mtr.tree.Z (isub) + ...
                (z - cgui.mtr.tree.Z (cgui.mtr.active));
            cgui.mtr.lastnode = cgui.mtr.active;
            drawcursorcross (x, y, z);            
%             cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
%             cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
        end
    case 'mouse_mtr_addpoints'      % edit submode: add points as children to closest node
        % third dimension value from slicer
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
%             MotionFcn = get(cgui.ui.F,'WindowButtonMotionFcn');
            if ~isempty (get (src, 'SelectionType'))    %if button is down, use only last point to measure distance
                [x y z cgui.mtr.distance cgui.mtr.active] = ...
                    close2cursor (cgui.mtr.tree.X(cgui.mtr.lastnode), cgui.mtr.tree.Y(cgui.mtr.lastnode), cgui.mtr.tree.Z(cgui.mtr.lastnode), ...
                    cgui.vis.iM); % value from slicer
                cgui.mtr.active = cgui.mtr.lastnode(cgui.mtr.active);
            else
                if isfield(cgui.modes,'hold') && cgui.modes.hold == 1
%                     cgui.mtr.active = cgui.mtr.lastnode;
%                     cp = get (cgui.ui.g1, 'CurrentPoint');
%                     x = cp(1,1);
%                     y = cp(1,2);
%                     z = cgui.vis.iM;
%                     cgui.mtr.distance = x-cgui.mtr.tree.X(cgui.mtr
                                    [x y z cgui.mtr.distance cgui.mtr.active] = ...
                    close2cursor (cgui.mtr.tree.X(cgui.mtr.lastnode), cgui.mtr.tree.Y(cgui.mtr.lastnode), cgui.mtr.tree.Z(cgui.mtr.lastnode), ...
                    cgui.vis.iM); % value from slicer
                cgui.mtr.active = cgui.mtr.lastnode(cgui.mtr.active);
                else
                    [x y z cgui.mtr.distance cgui.mtr.active] = ...
                        close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, cgui.mtr.tree.Z, ...
                        cgui.vis.iM); % value from slicer
                end
            end
            if cgui.mtr.distance > (mean (cgui.stk.voxel (1 : 2)) * 3)
                if ~isempty (get (src, 'SelectionType'))    
                cgui.mtr.tree = insert_tree (cgui.mtr.tree, ...
                    [1 get(cgui.slt.ui.pop3, 'value') x y z ...
                    cgui.mtr.tree.D(cgui.mtr.lastnode) cgui.mtr.lastnode], 'none');
                else
                                 cgui.mtr.tree = insert_tree (cgui.mtr.tree, ...
                    [1 get(cgui.slt.ui.pop3, 'value') x y z ...
                    cgui.mtr.tree.D(cgui.mtr.active) cgui.mtr.active], 'none');
                end
                cgui.mtr.lastnode = size (cgui.mtr.tree.dA, 1);
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            end
        end
    case 'mouse_mtr_addpointsztree' % edit submode: add points as children to closest node
        % same third dimension value as the parent point in the tree
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            if ~isempty (get (src, 'SelectionType'))  %if button is down, use only last point to measure distance
                [x y z cgui.mtr.distance cgui.mtr.active] = ...
                    close2cursor (cgui.mtr.tree.X(cgui.mtr.lastnode), cgui.mtr.tree.Y(cgui.mtr.lastnode), cgui.mtr.tree.Z(cgui.mtr.lastnode), ...
                    cgui.vis.iM); % value from slicer
                cgui.mtr.active = cgui.mtr.lastnode(cgui.mtr.active);
            else
                [x y z cgui.mtr.distance cgui.mtr.active] = ...
                    close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, cgui.mtr.tree.Z);
            end
             
             
            if cgui.mtr.distance > (mean (cgui.stk.voxel (1 : 2)) * 3)
                cgui.mtr.tree = insert_tree (cgui.mtr.tree, ...
                    [1 get(cgui.slt.ui.pop3, 'value') x y z ...
                    cgui.mtr.tree.D(cgui.mtr.active) cgui.mtr.active], 'none');
                cgui.mtr.lastnode = size(cgui.mtr.tree.dA,1);
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            end
        end
    case 'mouse_mtr_addpointszmax'  % edit submode: add point as child to closest node zmax
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            [x y z cgui.mtr.distance cgui.mtr.active] = ...
                close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, cgui.mtr.tree.Z);
            [x y z] = zmaxcursoronstack;
            if cgui.mtr.distance > (mean (cgui.stk.voxel (1 : 2)) * 3)
                cgui.mtr.tree = insert_tree (cgui.mtr.tree, ...
                    [1 get(cgui.slt.ui.pop3, 'value') x y z ...
                    cgui.mtr.tree.D(cgui.mtr.active) cgui.mtr.active], 'none');
                cgui.mtr.lastnode = size (cgui.mtr.tree.dA, 1);
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            end
        end
    case 'mouse_mtr_addthrpoints'	% edit submode: add brightest point as child to closest node
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            [x y z cgui.mtr.distance cgui.mtr.active] = ...
                close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, cgui.mtr.tree.Z);
            [x y z] = brightestneighbor;
            if cgui.mtr.distance > (mean (cgui.stk.voxel (1 : 2)) * 3)
                cgui.mtr.tree = insert_tree (cgui.mtr.tree, ...
                    [1 get(cgui.slt.ui.pop3, 'value') x y z ...
                    cgui.mtr.tree.D(cgui.mtr.active) cgui.mtr.active], 'none');
                cgui.mtr.lastnode = size (cgui.mtr.tree.dA, 1);
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            end
        end
    case 'mouse_mtr_addskelpoints'	% edit submode: add skeletonized points as children to closest node
        if ~isempty (cgui.mtr.tree),
            cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
            [x y z cgui.mtr.distance cgui.mtr.active] = ...
                close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y, cgui.mtr.tree.Z);
            [x y z cgui.skl.distance cgui.skl.active] = ...
                close2cursor (cgui.skl.I (:, 2), cgui.skl.I (:, 1), ...
                cgui.skl.I (:, 3), cgui.vis.iM);
            treedist2skeldist = sqrt ( ...
                (cgui.mtr.tree.X (cgui.mtr.active) - cgui.skl.I (cgui.skl.active, 2)).^2 + ...
                (cgui.mtr.tree.Y (cgui.mtr.active) - cgui.skl.I (cgui.skl.active, 1)).^2 + ...
                (cgui.mtr.tree.Z (cgui.mtr.active) - cgui.skl.I (cgui.skl.active, 3)).^2);
            if treedist2skeldist > (mean (cgui.stk.voxel (1 : 2)) * 3)
                cgui.mtr.tree = insert_tree (cgui.mtr.tree, ...
                    [1 get(cgui.slt.ui.pop3, 'value') cgui.skl.I(cgui.skl.active, 2) ...
                    cgui.skl.I(cgui.skl.active, 1) cgui.skl.I(cgui.skl.active, 3) ...
                    cgui.skl.DI(cgui.skl.active) cgui.mtr.active], 'none');
                cgui.mtr.lastnode = size (cgui.mtr.tree.dA, 1);
                cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
                cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
            end
        end
    case 'mouse_mtr_selector'       % edit-select mode:select a node on a tree
        if ~isempty (cgui.mtr.tree)
            % draw a line to closest node on tree
            [x y z cgui.mtr.distance cgui.mtr.active] = ...
                close2cursor (cgui.mtr.tree.X, cgui.mtr.tree.Y,...
                cgui.mtr.tree.Z, cgui.vis.iM);
            drawcursorline (x, y, z, cgui.mtr.tree.X (cgui.mtr.active), ...
                cgui.mtr.tree.Y (cgui.mtr.active), cgui.mtr.tree.Z (cgui.mtr.active));
            if cgui.mtr.distance < (mean (cgui.stk.voxel(1 : 2)) * 3),
                set (cgui.ui.lHP, 'color', [0 1 0]); % green if closeby
            else
                set (cgui.ui.lHP, 'color', [1 1 0]); % otherwise yellow
            end
        end
    case 'mouse_mtr_selectbranch'   % edit-select submode:
        if ~isempty (cgui.mtr.tree)
            % draw a green line between two nodes on a tree, the actual
            % selection happens when button is released:
            cp = get (cgui.ui.g1, 'CurrentPoint');
            switch cgui.modes.view
                case 2  % xz view
                    dist = sqrt (sum ((repmat (cp (1, [1 3]),length (cgui.mtr.tree.X), 1) - ...
                        [cgui.mtr.tree.X cgui.mtr.tree.Z]).^2, 2));
                    [cgui.mtr.distance cgui.mtr.active] = min (dist);
                case 3
                    dist = sqrt (sum ((repmat (cp (1, [2 3]),length (cgui.mtr.tree.X), 1) - ...
                        [cgui.mtr.tree.Y cgui.mtr.tree.Z]).^2, 2));
                    [cgui.mtr.distance cgui.mtr.active] = min(dist);
                otherwise
                    dist = sqrt (sum ((repmat (cp (1, [1 2]),length (cgui.mtr.tree.X), 1) - ...
                        [cgui.mtr.tree.X cgui.mtr.tree.Y]).^2, 2));
                    [cgui.mtr.distance cgui.mtr.active] = min (dist);
            end
            if (~isempty (cgui.ui.lHP)) && ishandle (cgui.ui.lHP),
                set (cgui.ui.lHP, 'xdata', ...
                    [cgui.mtr.tree.X(cgui.mtr.active) cgui.mtr.tree.X(cgui.mtr.startselect)]);
                set (cgui.ui.lHP, 'ydata', ...
                    [cgui.mtr.tree.Y(cgui.mtr.active) cgui.mtr.tree.Y(cgui.mtr.startselect)]);
                set (cgui.ui.lHP, 'zdata', ...
                    [cgui.mtr.tree.Z(cgui.mtr.active) cgui.mtr.tree.Z(cgui.mtr.startselect)]);
            else
                cgui.ui.lHP = line ( ...
                    [cgui.mtr.tree.X(cgui.mtr.active) cgui.mtr.tree.X(cgui.mtr.startselect)], ...
                    [cgui.mtr.tree.Y(cgui.mtr.active) cgui.mtr.tree.Y(cgui.mtr.startselect)], ...
                    [cgui.mtr.tree.Z(cgui.mtr.active) cgui.mtr.tree.Z(cgui.mtr.startselect)]);
                set (cgui.ui.lHP, 'linestyle', ':', 'linewidth', 4);
            end
            set (cgui.ui.lHP, 'color', [0 1 0]);
        end
        
    case 'mouse_ged_editor'         % edit mode: select tree and move it
        if ~isempty (cgui.mtr.tree)
            len = length (cgui.cat.trees {cgui.cat.i2tree});
            if len > 1,
                X = zeros (len, 1); Y = zeros (len, 1); Z = zeros (len, 1);
                for ward = 1 : len,
                    X (ward) = cgui.cat.trees{cgui.cat.i2tree}{ward}.X(1);
                    Y (ward) = cgui.cat.trees{cgui.cat.i2tree}{ward}.Y(1);
                    Z (ward) = cgui.cat.trees{cgui.cat.i2tree}{ward}.Z(1);
                end
            else
                X = cgui.cat.trees {cgui.cat.i2tree}.X(1);
                Y = cgui.cat.trees {cgui.cat.i2tree}.Y(1);
                Z = cgui.cat.trees {cgui.cat.i2tree}.Z(1);
            end
            [x y z cgui.ged.distance cgui.ged.active] = close2cursor (X, Y, Z);
            if (~isempty (cgui.ui.lHP)) && ishandle (cgui.ui.lHP),
                set (cgui.ui.lHP, 'xdata', [X(cgui.ged.active) x]);
                set (cgui.ui.lHP, 'ydata', [Y(cgui.ged.active) y]);
                set (cgui.ui.lHP, 'zdata', [Z(cgui.ged.active) z]);
            else
                cgui.ui.lHP = line ([X(cgui.ged.active) x], ...
                    [Y(cgui.ged.active) y], [Z(cgui.ged.active) z]);
                set (cgui.ui.lHP, 'linestyle', ':', 'linewidth', 4);
            end
            set (cgui.ui.lHP, 'color', [1 0 0]);
        end
    case 'mouse_ged_movetree'       % edit submode: move a tree
        if ~isempty (cgui.mtr.tree),
            [x y z] = ...
                simplecursor (cgui.mtr.tree.X(1), cgui.mtr.tree.Y(1), cgui.mtr.tree.Z(1));
            cgui.mtr.tree = tran_tree (cgui.mtr.tree);
            cgui.mtr.tree = tran_tree (cgui.mtr.tree, [x y z]);
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
    case 'mouse_ged_scaletree'      % edit submode: scale a tree
        if ~isempty (cgui.mtr.tree),
            cp = get (cgui.ui.g1, 'CurrentPoint');
            % compare to reference (set on button down):
            change = cp (1, 1 : 3) - cgui.ged.initpoint (1, 1 : 3);
            lambda = 5000;
            switch cgui.modes.view
                case 2 % xz view
                    scale = exp ((change (1) + change (3)) / lambda);
                case 3 % yz view
                    scale = exp ((change (2) + change (3)) / lambda);
                otherwise % xy and 3D view
                    scale = exp ((change (1) + change (2)) / lambda);
            end
            dd = [cgui.mtr.tree.X(1) cgui.mtr.tree.Y(1) cgui.mtr.tree.Z(1)];
            cgui.mtr.tree = tran_tree  (cgui.mtr.tree);
            cgui.mtr.tree = scale_tree (cgui.mtr.tree, scale);
            cgui.mtr.tree = tran_tree  (cgui.mtr.tree, dd);
            cgui.ged.remember = cgui.ged.remember * scale;
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
    case 'mouse_ged_rottree'        % edit submode: rotate a tree
        if ~isempty (cgui.mtr.tree),
            cp = get (cgui.ui.g1, 'CurrentPoint');
            % compare to reference (set on button down)
            change = cp (1, 1 : 3) - cgui.ged.initpoint (1, 1 : 3);
            switch cgui.modes.view
                case 2  % xz view
                    rote = [0 .3*change(1, 3) 0];
                case 3  % yz view
                    rote = [.3*change(1, 2) 0 0];
                otherwise  % xy and 3D view
                    rote = [0 0 .3*change(1, 1)];
            end
            dd = [cgui.mtr.tree.X(1) cgui.mtr.tree.Y(1) cgui.mtr.tree.Z(1)];
            cgui.mtr.tree = tran_tree (cgui.mtr.tree);
            cgui.mtr.tree = rot_tree  (cgui.mtr.tree, rote);
            cgui.mtr.tree = tran_tree (cgui.mtr.tree, dd);
            cgui.ged.remember = cgui.ged.remember + rote;
            cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
        end
end
end

function setactivepanel_tree (panel)
global cgui
if cgui.modes.panel ~= panel,
    cgui_tree ('ui_editorunframe');
    cgui.modes.panel = panel;
    cgui_tree ('ui_editorframe');
    if cgui.modes.edit, % if editor is on reset editor mode to new editor
        cgui_tree ('ui_editoroff');
        cgui_tree ('ui_editoron');
    end
end
end

function incorporateloaded_tree (tree, name)
% incorporate a tree or many trees into the tree selector etc...
% these can have been loaded or created from procedures such as "MST"
global cgui
if ~isempty (tree),
    counts = 0;
    if ~iscell (tree), % add name Ri Gm Cm fields
        % if tree is just a single tree
        if ~isfield (tree, 'name'), % create a name if non-existent
            counts = counts + 1; tree.name = [name num2str(counts)];
        end
        if ~isfield (tree, 'Ri'), % create an axial resistance value if non-existent
            tree.Ri = str2double (get (cgui.ele.ui.ed_elec1, 'string'));
        end
        if ~isfield (tree, 'Gm'), % create a membrane conductance if non-existent
            tree.Gm = str2double (get (cgui.ele.ui.ed_elec2, 'string'));
        end
        if ~isfield (tree, 'Cm'), % create a membrane capacitance if non-existent
            tree.Cm = str2double (get (cgui.ele.ui.ed_elec3, 'string'));
        end
    else
        if size(tree,1) > size(tree,2)  % make trees horizontal
            tree = tree';
        end
        for ward = 1 : length (tree), % if tree is a cell array walk through array
            if iscell (tree {ward}), % each cell can still be an array of trees
                if size(tree{ward},1) > size(tree{ward},2)    % make trees horizontal
                    tree{ward} = tree{ward}';
                end
                for te = 1 : length (tree {ward}), % then walk through cell array
                    if ~isfield (tree{ward}{te}, 'name'), % create a name if non-existent
                        counts = counts + 1; tree{ward}{te}.name = [name num2str(counts)];
                    end
                    if ~isfield (tree{ward}{te}, 'Ri'), % create an axial resistance value if non-existent
                        tree{ward}{te}.Ri = str2double (get (cgui.ele.ui.ed_elec1, 'string'));
                    end
                    if ~isfield (tree{ward}{te}, 'Gm'), % create a membrane conductance if non-existent
                        tree{ward}{te}.Gm = str2double (get (cgui.ele.ui.ed_elec2, 'string'));
                    end
                    if ~isfield (tree{ward}{te}, 'Cm'), % create a membrane capacitance if non-existent
                        tree{ward}{te}.Cm = str2double (get (cgui.ele.ui.ed_elec3, 'string'));
                    end
                end
            else % if now it is not a cell array treat as tree:
                if ~isfield (tree{ward}, 'name'), % create a name if non-existent
                    counts = counts + 1; tree{ward}.name = [name num2str(counts)];
                end
                if ~isfield (tree{ward}, 'Ri'), % create an axial resistance value if non-existent
                    tree {ward}.Ri = str2double (get (cgui.ele.ui.ed_elec1, 'string'));
                end
                if ~isfield (tree{ward}, 'Gm'), % create a membrane conductance if non-existent
                    tree {ward}.Gm = str2double (get (cgui.ele.ui.ed_elec2, 'string'));
                end
                if ~isfield (tree{ward}, 'Cm'), % create a membrane capacitance if non-existent
                    tree {ward}.Cm = str2double (get (cgui.ele.ui.ed_elec3, 'string'));
                end
            end
        end
    end
    cgui_tree ('cat_update'); % update cat_ trees with active altered tree
    if ~iscell (tree), % set one of the new trees to be active
        cgui.mtr.tree = tree;
    else
        if length (tree {1}) > 1 || iscell(tree{1})
            cgui.mtr.tree = tree{1}{1};
        else
            cgui.mtr.tree = tree {1};
        end
    end
    cgui.cat.i2tree = length (cgui.cat.trees) + 1; % activate new group
    % simply concatenate new trees to old ones
    cgui.cat.trees = [cgui.cat.trees tree];
    cgui.cat.itree = 1; % in new group activate first tree
    % deal with the fact that cat_trees can be array of arrays:
    % update group selector:
    set (cgui.cat.ui.f2, 'string', num2str ((1 : length (cgui.cat.trees))'));
    set (cgui.cat.ui.f2, 'value', cgui.cat.i2tree)  % needs to be two lines otherwise value not selected since string has not been refreshed
    % update tree selector:
    if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
        str = cell (1,length (cgui.cat.trees {cgui.cat.i2tree}));
        for ward = 1 : length (cgui.cat.trees {cgui.cat.i2tree}),
            str {ward} = cgui.cat.trees{cgui.cat.i2tree}{ward}.name;
        end
        set (cgui.cat.ui.f1, 'value', cgui.cat.itree, 'string', ...
            str);
    else
        set (cgui.cat.ui.f1, 'value', cgui.cat.itree, 'string', ...
            cgui.cat.trees {cgui.cat.i2tree}.name);
    end
    cgui_tree ('slt_relsel'); % after tree alteration selected nodes are discarded
    cgui.mtr.lastnode =  1; % active single node is reset to root
    cgui_tree ('mtr_image'); cgui_tree ('ged_image'); % redraw trees
    % update edit field for tree name:
    set (cgui.cat.ui.ed_name1, 'string', cgui.mtr.tree.name);
    % update root location, electrotonics and regions edit fields
    cgui_tree ('ged_settran'); cgui_tree ('ele_setelec'); cgui_tree ('slt_setreg');
    cgui.cat.untrees  = {}; % reset undo

    cgui_tree ('mtr_showpanels'); % check if tree control panels need to be active
    cgui_tree ('mtr_inform'); % text output on tree length and number of nodes
end
end

function incorporateloaded_stack (stack)
% incorporate newly loaded tiled image stacks.
global cgui
if ~isempty (stack)
    % integrate stack and set on top:
    cgui.stk.M {end+1} = stack.M {1}; cgui.stk.sM {end+1} = stack.sM {1};
    % set a threshold corresponding to brightness values of stack:
    cgui_tree ('thr_setstd');
    cgui.stk.coord (end + 1, :) = [0 0 0];
    % update popup (stack becomes active stack):
    set (cgui.stk.ui.pop, 'string', cgui.stk.sM, 'value', length (cgui.stk.sM));
    cgui_tree ('stk_update'); % update stk_ maximum intensity projections
    cgui_tree ('stk_image'); % redraw stk_ graphical output: image stacks
    cgui_tree ('thr_image'); % redraw thr_ graphical output: thresholded stacks
    % activate ui elements and text output stack size:
    cgui_tree ('stk_showpanels'); cgui_tree ('stk_inform');
end
end

function gedapply (streval)
% apply global edit functions in streval on either active tree or on entire
% group of trees:
global cgui
len = length (cgui.cat.trees {cgui.cat.i2tree});
if (get (cgui.ged.ui.t_group, 'value') == 1) && (len > 1),
    for ward = 1 : len,
        tree = cgui.cat.trees{cgui.cat.i2tree}{ward}; eval (streval);
        cgui.cat.trees{cgui.cat.i2tree}{ward} = tree;
    end
    cgui_tree ('ged_image'); % redraw ged_ graphical output: other trees in group
else
    if len > 1,
        tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree}; eval (streval);
        cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree} = tree;
    else
        tree = cgui.cat.trees{cgui.cat.i2tree}; eval (streval);
        cgui.cat.trees{cgui.cat.i2tree} = tree;
    end
end
cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
tree = cgui.mtr.tree; eval (streval); cgui.mtr.tree = tree;
cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
cgui_tree ('ged_settran'); % update edit field
end

function gedapply2 (streval, P, tranflag)
if nargin < 3
    tranflag = 0;
end
% apply global edit functions in streval on either active tree or on entire
% group of trees:
global cgui
len = length (cgui.cat.trees {cgui.cat.i2tree});
if (get (cgui.ged.ui.t_group, 'value') == 1) && (len > 1),
    for ward = 1 : len,
        tree = cgui.cat.trees{cgui.cat.i2tree}{ward};
        if tranflag,
            dd   = [tree.X(1) tree.Y(1) tree.Z(1)];
            tree = tran_tree (tree);
        end
        tree = feval (streval, tree, P);
        if tranflag, tree = tran_tree (tree, dd); end
        cgui.cat.trees{cgui.cat.i2tree}{ward} = tree;
    end
    cgui_tree ('ged_image'); % redraw ged_ graphical output: other trees in group
else
    if len > 1,
        tree = cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree};
        if tranflag,
            dd = [tree.X(1) tree.Y(1) tree.Z(1)];
            tree = tran_tree (tree);
        end
        tree = feval (streval, tree, P);
        if tranflag, tree = tran_tree (tree, dd); end
        cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree} = tree;
    else
        tree = cgui.cat.trees {cgui.cat.i2tree};
        if tranflag,
            dd = [tree.X(1) tree.Y(1) tree.Z(1)];
            tree = tran_tree (tree);
        end
        tree = feval (streval, tree, P);
        if tranflag, tree = tran_tree (tree, dd); end
        cgui.cat.trees {cgui.cat.i2tree} = tree;
    end
end
cgui.cat.untrees {end+1} = cgui.mtr.tree;    % keep track of old tree for undo
tree = cgui.mtr.tree;
if tranflag,
    dd = [tree.X(1) tree.Y(1) tree.Z(1)];
    tree = tran_tree (tree);
end
tree = feval (streval, tree, P);
if tranflag, tree = tran_tree (tree, dd); end
cgui.mtr.tree = tree;
cgui_tree ('mtr_image'); % redraw mtr_ graphical output: active tree
cgui_tree ('ged_settran'); % update edit field
end

function err = qfit (P, intree)
% fitting function to find the scaling and offset parameters for the
% function "quaddiameter_tree". See "quadfit_tree".
global cgui
qtree = quaddiameter_tree (intree, P(1), P(2));
err = norm (intree.D - qtree.D);
% echo on text frame of vis_ panel:
set (cgui.vis.ui.txt1, 'string', {'fitting diameter:', ['err:' num2str(err)]});
drawnow;
end

function [x y z] = simplecursor (X, Y, Z)
% depending on chosen 2D view the two coordinates are read out of mouse
% cursor and the third one comes from the complementary input X Y or Z
global cgui
cp = get (cgui.ui.g1, 'CurrentPoint');
switch cgui.modes.view
    case 2  % xz view
        x = cp (1, 1); y = Y; z = cp (1, 3);
    case 3
        x = X; y = cp (1, 2); z = cp (1, 3);
    otherwise
        x = cp (1, 1); y = cp (1, 2); z = Z;
end
end

function [x y z dist indy] = close2cursor (X, Y, Z, constx, consty, constz)
global cgui
% get mouse cursor position and check which point defined by X Y Z is
% closest.
cp = get (cgui.ui.g1, 'CurrentPoint');
switch cgui.modes.view % this depends on the view:
    case 2 % xz view
        dist = sqrt (sum ((repmat (cp (1, [1 3]), length (X), 1) - ...
            [X Z]).^2, 2));
        % distance and index of closest point are kept in memory:
        [dist indy] = min (dist);
        x = cp (1, 1); z = cp (1, 3);
        if nargin > 4, y = consty; elseif nargin == 4, y = constx; else y = Y (indy); end
    case 3 % yz view
        dist = sqrt (sum ((repmat (cp (1, [2 3]), length (X), 1) - ...
            [Y Z]).^2, 2));
        % distance and index of closest point are kept in memory:
        [dist indy] = min (dist);
        y = cp (1, 2); z = cp (1, 3);
        if nargin > 3, x = constx; else x = X (indy); end
    otherwise % xy and 3D view
        dist = sqrt (sum ((repmat (cp (1, 1 : 2), length (X), 1) - ...
            [X Y]).^2, 2));
        % distance and index of closest point are kept in memory:
        [dist indy] = min (dist);
        x = cp (1, 1); y = cp (1, 2);
        if nargin > 4, z = constz; elseif nargin > 3, z = constx; else z = Z (indy); end
end
end

function [x y z ix iy iz] = zmaxcursoronstack
global cgui
% get mouse cursor position and check which point on active stack is
% closest, use maximum intensity projection
cp = get (cgui.ui.g1, 'CurrentPoint');
x0 = cgui.stk.coord (end, 1); dx = cgui.stk.voxel (1); Sx = size (cgui.stk.M {end}, 1);
xr = dx / 2 + (x0 : dx : x0 + (Sx - 1) * dx)'; % x coordinates of active image stack
y0 = cgui.stk.coord (end, 2); dy = cgui.stk.voxel (2); Sy = size (cgui.stk.M {end}, 2);
yr = dy / 2 + (y0 : dy : y0 + (Sy - 1) * dy)'; % y coordinates of active image stack
z0 = cgui.stk.coord (end, 3); dz = cgui.stk.voxel (3); Sz = size (cgui.stk.M {end} ,3);
zr = dz / 2 + (z0 : dz : z0 + (Sz - 1) * dz)'; % y coordinates of active image stack
switch cgui.modes.view % this depends on the view:
    case 2 % xz view
        [i1 ix] = min (abs (cp (1, 1) - xr));
        [i3 iz] = min (abs (cp (1, 3) - zr));
        iy = cgui.stk.imM2 {end} (iz, ix);
        y = dy / 2 + y0 + dy * iy; x = cp (1, 1); z = cp (1, 3);
    case 3 % yz view
        [i2 iy] = min (abs (cp (1, 2) - yr));
        [i3 iz] = min (abs (cp (1, 3) - zr));
        ix = cgui.stk.imM3 {end} (iz, iy);
        x = dx / 2 + x0 + dx * ix; y = cp (1, 2); z = cp (1, 3);
    otherwise % xy and 3D view
        [i1 ix] = min (abs (cp (1, 1) - xr));
        [i2 iy] = min (abs (cp (1, 2) - yr));
        iz = cgui.stk.imM1 {end} (iy, ix);
        z = dz / 2 + z0 + dz * iz; x = cp (1, 1); y = cp (1, 2);
end
end

function [ix iy iz x y z] = cursoronstack
global cgui
% get mouse cursor position and check which point on active stack is
% closest. The third dimension is given by the slicer.
cp = get (cgui.ui.g1, 'CurrentPoint');
x0 = cgui.stk.coord (end, 1); dx = cgui.stk.voxel (1); Sx = size (cgui.stk.M {end}, 1);
xr = dx / 2 + (x0 : dx : x0 + (Sx - 1) * dx)'; % x coordinates of active image stack
y0 = cgui.stk.coord (end, 2); dy = cgui.stk.voxel (2); Sy = size (cgui.stk.M {end}, 2);
yr = dy / 2 + (y0 : dy : y0 + (Sy - 1) * dy)'; % y coordinates of active image stack
z0 = cgui.stk.coord (end, 3); dz = cgui.stk.voxel (3); Sz = size (cgui.stk.M {end}, 3);
zr = dz / 2 + (z0 : dz : z0 + (Sz - 1) * dz)'; % z coordinates of active image stack
switch cgui.modes.view % this depends on the view:
    case 2 % xz view
        [i1 ix] = min (abs (cp (1, 1) - xr));
        [i3 iz] = min (abs (cp (1, 3) - zr));
        [i2 iy] = min (abs (cgui.vis.iM - yr));
        y = dy / 2 + y0 + dy * iy; x = cp (1, 1); z = cp (1, 3);
    case 3 % yz view
        [i2 iy] = min (abs (cp (1, 2) - yr));
        [i3 iz] = min (abs (cp (1, 3) - zr));
        [i1 ix] = min (abs (cgui.vis.iM - xr));
        x = dx / 2 + x0 + dx * ix; y = cp (1, 2); z = cp (1, 3);
    otherwise % xy and 3D view
        [i1 ix] = min (abs (cp (1, 1) - xr));
        [i2 iy] = min (abs (cp (1, 2) - yr));
        [i3 iz] = min (abs (cgui.vis.iM - zr));
        z = dz / 2 + z0 + dz * iz; x = cp (1, 1); y = cp (1, 2);
end
end

function [x y z] = brightestneighbor
global cgui
% get mouse cursor position and check which nearby point on active stack is
% brightest
cp = get(cgui.ui.g1, 'CurrentPoint');
x0 = cgui.stk.coord (end, 1); dx = cgui.stk.voxel (1); Sx = size (cgui.stk.M {end}, 1);
xr = dx / 2 + (x0 : dx : x0 + (Sx - 1) * dx)'; % x coordinates of active image stack
y0 = cgui.stk.coord (end, 2); dy = cgui.stk.voxel (2); Sy = size (cgui.stk.M {end}, 2);
yr = dy / 2 + (y0 : dy : y0 + (Sy - 1) * dy)'; % y coordinates of active image stack
z0 = cgui.stk.coord (end, 3); dz = cgui.stk.voxel (3); Sz = size (cgui.stk.M {end}, 3);
zr = dz / 2 + (z0 : dz : z0 + (Sz - 1) * dz)'; % z coordinates of active image stack
switch cgui.modes.view % this depends on the view:
    case 2 % xz view
        [i1 x] = min (abs (cp (1, 1) - xr));
        [i3 z] = min (abs (cp (1, 3) - zr));
        [X Z] = meshgrid (x - 5 : x + 5, z - 5 : z + 5);
        indy = find(X > 0 & X <= Sx & Z > 0 & Z <= Sz);
        [i1 i2] = max (cgui.stk.mM2 {end} ...
            (sub2ind (size (cgui.stk.mM2 {end}), Z (indy), X (indy))));
        x = X (indy (i2));
        z = Z (indy (i2));
        y = cgui.stk.imM2 {end} (z, x);
        x = x + cgui.stk.coord (end, 1); z = z + cgui.stk.coord (end, 3);
    case 3 % yz view
        [i2 y] = min (abs (cp (1, 2) - yr));
        [i3 z] = min (abs (cp (1, 3) - zr));
        [Y Z] = meshgrid (y - 5 : y + 5, z - 5 : z + 5);
        indy = find(Y > 0 & Y <= Sy & Z > 0 & Z <= Sz);
        [i1 i2] = max (cgui.stk.mM3 {end} ...
            (sub2ind (size (cgui.stk.mM3 {end}), Z (indy), Y (indy))));
        y = Y (indy (i2));
        z = Z (indy (i2));
        x = cgui.stk.imM3 {end} (z, y);
        y = y + cgui.stk.coord (end, 2); z = z + cgui.stk.coord (end, 3);
    otherwise % xy and 3D view
        [i1 x] = min (abs (cp (1, 1) - xr));
        [i2 y] = min (abs (cp (1, 2) - yr));
        [X Y] = meshgrid (x - 5 : x + 5, y - 5 : y + 5);
        indy = find (X > 0 & X <= Sx & Y > 0 & Y <= Sy);
        [i1 i2] = max (cgui.stk.mM1 {end} ...
            (sub2ind (size (cgui.stk.mM1 {end}), Y (indy), X (indy))));
        x = X (indy (i2));
        y = Y (indy (i2));
        z = cgui.stk.imM1 {end} (y, x);
        x = x + cgui.stk.coord (end, 1); y = y + cgui.stk.coord (end, 2);
end
end

function D = diameterestimate (ix, iy, iz, stackn) % estimate diameter for a number of nodes
global cgui
% extract diameter values from binary distance to
% non-zero values (see "bwdist" of image processing
% toolbox):
D = max (cgui.stk.voxel) * bwdist (~cgui.thr.BW {stackn}); D (D == 0) = 0.25;
D = 2 * D (sub2ind (size (D), iy - 1, ix - 1, iz - 1));
end

function D = sdiameterestimate (ix, iy, iz, stackn) % estimate diameter for a single node
global cgui
% extract diameter values from binary distance to
% non-zero values (see "bwdist" of image processing
% toolbox):
% to be implemented, for now outputs 1
D = max (cgui.stk.voxel) * 1 + 0 * ix + 0 * iy + 0 * iz + 0 * stackn;
end

function drawcursorline (x, y, z, X, Y, Z)
% draws a line beetween (x,y,z) and (X,Y,Z) onto UI edit line handle lHP.
global cgui
if (~isempty (cgui.ui.lHP)) && ishandle (cgui.ui.lHP),
    set (cgui.ui.lHP, 'xdata', [X x]);
    set (cgui.ui.lHP, 'ydata', [Y y]);
    set (cgui.ui.lHP, 'zdata', [Z z]);
else
    cgui.ui.lHP = line ([X x], [Y y], [Z z]);
    set (cgui.ui.lHP, 'linestyle', ':', 'linewidth', 4);
end
set (cgui.ui.lHP, 'color', [0 1 0]);
end

function drawcursorcross (x, y, z)
% draws a complicated 3D cross at position (x,y,Z) onto UI edit line handle
% lHP.
global cgui
if (~isempty (cgui.ui.lHP)) && ishandle (cgui.ui.lHP),
    set (cgui.ui.lHP, 'xdata', x + [0 -10  10 0 -10  10 0]);
    set (cgui.ui.lHP, 'ydata', y + [0 -10 -10 0  10  10 0]);
    set (cgui.ui.lHP, 'zdata', z + [0  10 -10 0 -10  10 0]);
else
    cgui.ui.lHP = line( ...
        x + [0 -10  10 0 -10  10 0], ...
        y + [0 -10 -10 0  10  10 0], ...
        z + [0  10 -10 0 -10  10 0]);
    set (cgui.ui.lHP, 'linestyle', ':', 'linewidth', 4);
end
set (cgui.ui.lHP, 'color', [1 0 0]);
end

function movecamera (dim, perc)
% implements camera translations, depends on the view. (perc is a value in
% percent, well 0..1)
global cgui
switch cgui.modes.view % this depends on the view:
    case 2 % xz view
        if dim == 2, dim = 3; end
    case 3 % yz view
        if dim == 2, dim = 3; end
        if dim == 1, dim = 2; end
    otherwise % xy and 3D view, change nothing
end
switch dim,
    case 1
        xl = xlim;
        camtarget        = get (cgui.ui.g1, 'cameratarget');
        camtarget (1)    = camtarget (1)   - perc * diff (xl);
        camposition      = get (cgui.ui.g1, 'cameraposition');
        camposition (1)  = camposition (1) - perc * diff (xl);
        set (cgui.ui.g1, 'cameratarget', camtarget, ...
            'cameraposition', camposition);
    case 2
        yl = ylim;
        camtarget        = get (cgui.ui.g1, 'cameratarget');
        camtarget (2)    = camtarget (2)   - perc * diff (yl);
        camposition      = get (cgui.ui.g1, 'cameraposition');
        camposition (2)  = camposition (2) - perc  *diff (yl);
        set (cgui.ui.g1, 'cameratarget', camtarget, ...
            'cameraposition', camposition);
    case 3
        zl = zlim;
        camtarget       = get (cgui.ui.g1, 'cameratarget');
        camtarget (3)   = camtarget (3)   - perc * diff (zl);
        camposition     = get (cgui.ui.g1, 'cameraposition');
        camposition (3) = camposition (3) - perc * diff (zl);
        set (cgui.ui.g1, 'cameratarget', camtarget, ...
            'cameraposition', camposition);
end
end

% time function of autosave timer
function autosave(hObject,eventdata)

global cgui
cl = get(hObject,'UserData');
name = cl{2};
path = cl{1};
if length (cgui.cat.trees {cgui.cat.i2tree}) > 1,
    cgui.cat.trees{cgui.cat.i2tree}{cgui.cat.itree} = cgui.mtr.tree;
else
    cgui.cat.trees{cgui.cat.i2tree} = cgui.mtr.tree;
end
name = save_tree (cgui.cat.trees,fullfile(path,sprintf('%s.asv',name)));
% echo on text frame of vis_ panel:
if ~isempty (name),
    set (cgui.vis.ui.txt1, 'string', {'all trees autosaved', name});
end

end

% start function of autosave timer
function startasv(hObject,eventdata)
setasvtimer('ask',0)
end

% stop function of autosave timer
function deleteasv(hObject,eventdata)
global cgui
cl = get(hObject,'UserData');
name = cl{2};
path = cl{1};
if exist(fullfile(path,sprintf('%s.asv',name)),'file') && (~ishandle(cgui.ui.F) || cl{3}) %if Toolbox has closed
    answer = questdlg('Delete autosave file?','Delete Backup','Yes','No','No');
    if strcmp(answer,'Yes')
        delete(fullfile(path,sprintf('%s.asv',name)))
    end
end
end

% sets user data of autosave timer (e.g. save path)
function setasvtimer(field,value)
global cgui
cl = get(cgui.cat.tautosave,'UserData');
if ~iscell(field)
    field = {field};
end
if ~iscell(value)
    value = {value};
end
for f = 1:numel(field)
    switch field{f}
        case 'path'
            cl{1} = value{f};
        case 'name'
            cl{2} = value{f};
        case 'ask'
            cl{3} = value{f};
    end
end
set(cgui.cat.tautosave,'UserData',cl)
end

% returns user data of autosave timer (eg for saving)
function out = getasvtimer(field)
global cgui
cl = get(cgui.cat.tautosave,'UserData');
if ~iscell(field)
    field = {field};
end
out = cell(1,numel(field));
for f = 1:numel(field)
    switch field{f}
        case 'path'
            out{f} = cl{1};
        case 'name'
            out{f} = cl{2};
        case 'ask'
            out{f} = cl{3};
    end
end
if numel(out) == 1
    out = out{1};
end
end