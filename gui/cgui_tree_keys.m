% define the keyboard mapping
% change these to your personal preferences
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function cgui_tree_keys

global cgui

% ui_ related:
cgui.keys.ui       = {};
cgui.keys.ui  {1}  = char (30);     % (arrow up) change active editor panel up
cgui.keys.ui  {2}  = char (31);     % (arrow down) change active editor panel down
cgui.keys.ui  {3}  = char (28);     % (arrow left) toggle editor on/off
cgui.keys.ui  {4}  = '!';           % 2nd: toggle editor on/off
cgui.keys.ui  {5}  = char (29);     % (arrow right) toggle editor selection mode on/off
cgui.keys.ui  {6}  = '$';           % 2nd: toggle editor selection mode on/off
cgui.keys.ui  {7}  = char (17);     % (ctrl q) select stk_ panel for edit
cgui.keys.ui  {8}  = char (23);     % (ctrl w) select thr_ panel for edit
cgui.keys.ui  {9}  = char (5);      % (ctrl e) select skl_ panel for edit
cgui.keys.ui  {10} = char (18);     % (ctrl r) select mtr_ panel for edit
cgui.keys.ui  {11} = char (20);     % (ctrl t) select ged_ panel for edit


% vis_ panel:
cgui.keys.vis      = {};
cgui.keys.vis {1}  = char (13);     % (enter)   clear axis and redraw all
cgui.keys.vis {2}  = char (27);     % (escape)  axis tight
cgui.keys.vis {3}  = '#';           % grid toggle
cgui.keys.vis {4}  = '1';           % xy-view toggle
cgui.keys.vis {5}  = '2';           % xz-view toggle
cgui.keys.vis {6}  = '3';           % yz-view toggle
cgui.keys.vis {7}  = '4';           % xyz-view
cgui.keys.vis {8}  = 'o';           % shine - switches to opengl with a gouraud phong
cgui.keys.vis {9}  = '\';           % axis on/off toggle
cgui.keys.vis {10} = '|';           % colorbar on/off toggle
cgui.keys.vis {11} = '_';           % scalebar on/off toggle
cgui.keys.vis {12} = 'q';           % zoom out a bit
cgui.keys.vis {13} = 'Q';           % zoom out more
cgui.keys.vis {14} = 'e';           % zoom in a bit
cgui.keys.vis {15} = 'E';           % zoom in more
cgui.keys.vis {16} = 'd';           % +x a bit
cgui.keys.vis {17} = 'D';           % +x more
cgui.keys.vis {18} = 'a';           % -x a bit
cgui.keys.vis {19} = 'A';           % -x more
cgui.keys.vis {20} = 'w';           % +y a bit
cgui.keys.vis {21} = 'W';           % +y more
cgui.keys.vis {22} = 's';           % -y a bit
cgui.keys.vis {23} = 'S';           % -y more
cgui.keys.vis {28} = 'z';           % third dimension - 1
cgui.keys.vis {29} = 'Z';           % third dimension - 5
cgui.keys.vis {30} = 'x';           % third dimension + 1
cgui.keys.vis {31} = 'X';           % third dimension + 5

% cat_ panel:
cgui.keys.cat      = {};
cgui.keys.cat {1}  = char (1);      % (ctrl a) select previous tree in group
cgui.keys.cat {2}  = char (4);      % (ctrl d) select next tree in group
cgui.keys.cat {3}  = char (26);     % (ctrl z) undo changes on active tree

% stk_ panel:
cgui.keys.stk      = {};

% overloaded keys:
cgui.keys.over     = {};
cgui.keys.over {1} = 'c';           % general cut functions
cgui.keys.over {2} = 'C';           % 2nd general cut functions
cgui.keys.over {3} = 'v';           % preview rebuild (rebuild for skel. points)
cgui.keys.over {4} = 'V';           % rebuild (e.g. rebuild tree from subpoints)
cgui.keys.over {5} = 'f';           % decrease diameter
cgui.keys.over {6} = 'F';           % decrease diameter lots
cgui.keys.over {7} = 'r';           % increase diameter
cgui.keys.over {8} = 'R';           % increase diameter lots
