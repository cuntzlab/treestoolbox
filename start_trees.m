% START_TREES   Initialization for TREES toolbox.
% (trees package)
% 
% start_trees 
% -----------
%
% Creates the global cell array trees and includes the toolbox in the
% path. Newly created trees are appended to this array by default if no
% other output variable is set. Any subsequent function call is applied to
% the last tree inserted in the trees structure (highest index).
% Alternatively, any function allows the input tree to be an index to the
% trees array or a completely independent tree structure. A tree
% structure can be loaded from an .swc-file or indirectly from NEURON
% through the TREES package internal .neu format (function load_tree
% read_tree). The latter can be obtained by using a NEURON function 
% neu_tree provided as a .hoc-file with this package. Trees can then be
% saved in .swc, NEURON .hoc or .nrn formats or alternatively as a
% graphical output to the POVray ray-tracer (see graphical output function
% pov_tree).
%
% A tree variable in the TREES package consists of a structure containing
% the sparse representation of the adjacency matrix dA connecting the
% indexed nodes. Vectors attributing to each element index individual
% metric or descriptive features. Typical vectors are X Y Z coordinates, D
% the diameter and R a region index. To this region index a cell array of
% strings containing the region names can be added. Also, homogenously
% distributed properties as single values can complete the description of
% the tree. 
%
% Example
%
% trees	=
% dA: [2252x2252 double]
% R:  [2252x1 double]
% X:  [2252x1 double]
% Y:  [2252x1 double]
% Z:  [2252x1 double]
% D:  [2252x1 double]
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2018  Hermann Cuntz

% This file and all files in this package are part of the TREES toolbox.
% 
%     the TREES toolbox is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     the TREES toolbox is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with the TREES toolbox. If not, see <http://www.gnu.org/licenses/>.

% trees : contains the tree structures in the trees package
global       trees
trees        = {};

% matlab apparently doesn't have a function to determine the directory in
% which a function is located:
PPPP         = which ('start_trees');
PPPP         = PPPP  (1 : strfind (PPPP, 'start_trees.m') - 1);
% add the subdirectory structure of TREES to path:
addpath      (genpath (PPPP));
clear        PPPP

display      ('the TREES toolbox  Copyright (C) 2009 - 2018  Hermann Cuntz');
display      ('This program comes with ABSOLUTELY NO WARRANTY.');
display      ('This is free software, and you are welcome to redistribute it');
display      ('under certain conditions. Type "type(''license.txt'')" for details.');
