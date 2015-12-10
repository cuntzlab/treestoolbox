% X3D_TREE   Plots a tree as cylinders.
% (trees package)
%
% [name path] = x3d_tree (intree, name, color, DD, ipart, options)
% ----------------------------------------------------------------
%
% exports a tree as a set of cylinders in the ".x3d" html format. A viewer
% is necessary to use these files. "blender" and others can load ".x3d"
% files. If a viewer is installed and TREES runs on windows matlab can call
% the viewer directly.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - name::string: name of file including the extension ".x3d"
%     {DEFAULT : open gui fileselect}
% - color::RGB 3-tupel, vector or matrix: RGB values {DEFAULT [0 0 0]}
%     if vector then values are treated in colormap (must contain one value
%     per node then!).
%     if matrix (num x 3) then individual colors are mapped to each
%     element, works only on line-plots
% - DD:: 1x3 vector: coordinates offset {DEFAULT [0,0,0]}
% - ipart::index:index to the subpart to be plotted (child nodes)
% - options::string: {DEFAULT '-w'}
%     '-w' : waitbar
%     '->' : send directly to windows
%     '-o' : add spheres at the joints (nodes)
%     '-v' : adopt viewpoint from currently active axis
%   additional options:
%     '-thin'  : all diameters 1um
%     '-thick' : all diameters + 3um
%
% Output
% ------
% - name::string: name of output file; [] no file was selected -> no output
% - path::sting: path of the file, complete string is therefore: [path name]
%
% Example
% -------
% x3d_tree (sample_tree, [], PL_tree (sample_tree) / 20, [], [], '-w -o ->')
% attempts to immediately display sample tree with default windows viewer
%
% See also vtext_tree xplore_tree
% Uses cyl_tree ver_tree
%
% code by Friedrich Forstner 12 December 2008
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function [tname path] = x3d_tree (intree, tname, color, DD, ipart, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length (trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

if (~isfield (tree, 'X')) || (~isfield (tree, 'Y'))
    [xdend tree] = xdend_tree (intree);
end

idpar = idpar_tree (intree); % vector containing index to direct parent
N =     size (idpar, 1); % number of nodes in tree

if (nargin < 2)||isempty(tname),
    [tname path] = uiputfile ('.x3d', 'export to x3d', 'tree.x3d');
    if tname  == 0,
        tname = [];
        return
    end
else
    path = '';
end
% extract a sensible name from the filename string:
nstart = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
name   = tname  (nstart (end) + 1 : end - 4);

if (nargin < 3)||isempty(color),
    color = [0 0 0]; % {DEFAULT color: black}
end;
if size (color, 1) == 1,
    color = repmat (color, N, 1);
end

if (nargin < 4)||isempty(DD),
    DD = [0 0 0]; % {DEFAULT 3-tupel: no spatial displacement from the root}
end
if length(DD)<3,
    DD = [DD zeros(1, 3 - length (DD))]; % append 3-tupel with zeros
end

if (nargin < 5)||isempty(ipart),
    ipart = (1 : N)'; % {DEFAULT index: select all nodes/points}
end

if (nargin < 6)||isempty(options),
    options = '-w'; % {DEFAULT: waitbar}
end

if isfield (tree, 'D'),
    D = tree.D; % local diameter values of nodes on tree
else
    D = ones (N, 1); % if values don't exist fill with diameter = 1um
end

if strfind (options, '-thin'),
    D = ones (N, 1); % thin diameter option: all nodes 1um diameter
end
if strfind (options, '-thick'),
    D = D + 3; % thick diameter option: all nodes + 3um diameter
end

XYZ   = [tree.X tree.Y tree.Z]; % node coordinates
vXYZ  = XYZ - XYZ (idpar, :); % edge vectors
vnorm = sqrt (sum (vXYZ.^2, 2)); % norm (length) of all vectors

% raw compartments
rawComps = [zeros(N, 1) vnorm zeros(N, 1)];
% calculate compartment rotation:
% cross product to get rotation axis
rotX = (rawComps (:, 2) .* vXYZ (:, 3)) - (rawComps (:, 3) .* vXYZ (:, 2));
rotY = (rawComps (:, 3) .* vXYZ (:, 1)) - (rawComps (:, 1) .* vXYZ (:, 3));
rotZ = (rawComps (:, 1) .* vXYZ (:, 2)) - (rawComps (:, 2) .* vXYZ (:, 1));
get_zero = find (rotX == 0 & rotY == 0 & rotZ == 0);
rotX (get_zero) = 0; rotY (get_zero) = 1; rotZ (get_zero) = 0;
rotaxis = [rotX rotY rotZ];
% normalize axis
rotaxis_norm = sqrt (sum (rotaxis.^2, 2)); % norm (length) of all vectors
warning ('off', 'MATLAB:divideByZero'); rotaxis = rotaxis ./ repmat (rotaxis_norm, 1, 3);
% derive angle between rotation axis and compartment ground line
cproduct = zeros (N, 1);
for ward = 1 : N,
    cproduct (ward) = rawComps (ward, :) * vXYZ (ward, :)';
end
rotangle = acos (cproduct ./ (vnorm.^2));
warning ('on', 'MATLAB:divideByZero');
% avoid NANs
rotangle (isnan (rotangle)) = 0;
rotationMatrix    = [rotaxis, rotangle];
translationMatrix = repmat (DD, N, 1) + XYZ (idpar, :) + 1/2 * vXYZ;
heightVector      = vnorm;
radiusVector      = D/2;

% file-pointer to the povray-file
x3d = fopen ([path tname], 'w');
% Writing the cylinders into a povray variable called 'name'
fwrite (x3d, ['<?xml version="1.0" encoding="UTF-8"?>', char(13), char(10)], 'char');
fwrite (x3d, ['<X3D >',                                 char(13), char(10)], 'char');
fwrite (x3d, ['  <head>',                               char(13), char(10)], 'char');
fwrite (x3d, ['    <meta content=''TREES toolbox tree'' name=''' name '''/>', ...
    char(13), char(10)], 'char');
fwrite (x3d, ['  </head>',                              char(13), char(10)], 'char');
fwrite (x3d, ['  <Scene>',                              char(13), char(10)], 'char');
fwrite (x3d, ['    <Background skyColor=''1 1 1''/>',   char(13), char(10)], 'char');

if strfind (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'writing trees ...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for ward = 1 : N,
    if strfind (options, '-w'), % waitbar option: update
        waitbar (ward ./ N, HW);
    end
    if ipart (ward),
        if isempty (strfind (options, '-o')), % add a sphere at each node
            if ~isnan (rotaxis (ward, 1)),
                fwrite (x3d, ['    <Transform rotation = ''' num2str(rotationMatrix (ward, :)), ...
                    ''' translation = ''', num2str(translationMatrix (ward, :)), ...
                    ''' >', char(13), char(10)], 'char');
                fwrite (x3d, ['    <Shape>',         char(13), char(10)], 'char');
                fwrite (x3d, ['      <Cylinder bottom=''false'' height = ''', num2str(heightVector (ward, :)), ...
                    ''' radius=''' num2str(radiusVector (ward, :)), ...
                    ''' side=''true'' solid=''false'' top=''false''/>', char(13), char(10)], 'char');
                fwrite (x3d, ['      <Appearance>',  char(13), char(10)], 'char');
                fwrite (x3d, ['        <Material diffuseColor = ''' num2str(color(ward,:)) ''' ', ...
                    ' transparency =  ''0.3'' />',   char(13), char(10)], 'char');
                fwrite (x3d, ['      </Appearance>', char(13), char(10)], 'char');
                fwrite (x3d, ['    </Shape>',        char(13), char(10)], 'char');
                fwrite (x3d, ['    </Transform>',    char(13), char(10)], 'char');
            end
        else
            if ~isnan (rotaxis (ward, 1)),
                fwrite (x3d, ['    <Transform rotation = ''' num2str(rotationMatrix (ward, :)), ...
                    ''' translation = ''', num2str(translationMatrix (ward, :)), ...
                    ''' >',                          char(13), char(10)], 'char');
                fwrite (x3d, ['    <Shape>',         char(13), char(10)], 'char');
                fwrite (x3d, ['      <Cylinder bottom=''false'' height = ''', num2str(heightVector (ward, :)),...
                    ''' radius=''' num2str(radiusVector (ward, :)),...
                    ''' side=''true'' solid=''false'' top=''false''/>', ...
                    char(13), char(10)], 'char');
                fwrite (x3d, ['      <Appearance>',  char(13), char(10)], 'char');
                fwrite (x3d, ['        <Material diffuseColor = ''' ...
                    num2str(color (ward, :)) ''' />', char(13), char(10)], 'char');
                fwrite (x3d, ['      </Appearance>', char(13), char(10)], 'char');
                
                fwrite (x3d, ['    </Shape>',        char(13), char(10)], 'char');
                fwrite (x3d, ['    </Transform>',    char(13), char(10)], 'char');
            end
            fwrite (x3d, ['    <Transform translation = ''', num2str(DD + XYZ (ward, :)), ...
                ''' >',                              char(13), char(10)], 'char');
            fwrite (x3d, ['    <Shape>',             char(13), char(10)], 'char');
            fwrite (x3d, ['      <Sphere radius=''' ...
                num2str(radiusVector (ward, :)) ''' />', char(13), char(10)], 'char');
            fwrite (x3d, ['      <Appearance>',      char(13), char(10)], 'char');
            fwrite (x3d, ['        <Material diffuseColor = ''' ...
                num2str(color (ward, :)) ''' />',    char(13), char(10)], 'char');
            fwrite (x3d, ['      </Appearance>',     char(13), char(10)], 'char');
            fwrite (x3d, ['    </Shape>',            char(13), char(10)], 'char');
            fwrite (x3d, ['    </Transform>',        char(13), char(10)], 'char');
        end
        fwrite (x3d, ['', char(13), char(10)], 'char');
    end
end
if strfind (options, '-w'), % waitbar option: close
    close (HW);
end

if strfind (options, '-v'),
    ax = get (gcf, 'CurrentAxes');
    if ~isempty (ax),
        cpos = get (ax, 'cameraposition');
        % NOTE! Angle still needs to be incorporated: cangle = get(ax, 'cameraviewangle');
        tpos = get (ax, 'cameratarget');
        cX   = cpos (1); cY = cpos (2); cZ = -cpos (3);
        tX   = tpos (1); tY = tpos (2); tZ = -tpos (3);
        fwrite (x3d, ['    <Viewpoint position = ''', num2str([cX cY -cZ]),...
            ''' centerOfRotation = ''', num2str([tX tY -tZ]), ...
            ''' />', char(13), char(10)], 'char');
    else
        % calculate some acceptable viewpoint:
        viewpoint =[...
            min(XYZ (:, 1))+(max (XYZ (:, 1)) - min (XYZ (:, 1)))/2,...
            min(XYZ (:, 2))+(max (XYZ (:, 2)) - min (XYZ (:, 2)))/2,...
            min(XYZ (:, 3))+(max (XYZ (:, 3)) - min (XYZ (:, 3)))/2,...
            ];
        cameraDistance = (max (XYZ (:, 1)) - min (XYZ (:, 1))) / 0.81;
        fwrite (x3d, ['    <Viewpoint position = ''', ...
            num2str([viewpoint(1 : 2) cameraDistance]),...
            ''' centerOfRotation = ''', num2str(viewpoint), ...
            ''' />', char(13), char(10)], 'char');
    end
end

fwrite (x3d, ['  </Scene>',                          char(13), char(10)], 'char');
fwrite (x3d, ['</X3D>',                              char(13), char(10)], 'char');
fclose (x3d);

if strfind (options, '->')
    if ispc,        % this even calls the file directly (only windows)
        winopen ([path tname]);
    end
end

