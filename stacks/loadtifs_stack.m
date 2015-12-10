% LOADTIFS_STACK   load a tif image stack file into a stack structure.
% (trees package)
%
% [stack name path] = loadtifs_stack (name, options)
% --------------------------------------------------
%
% Loads an image stack from a tif file. As in "save_stack" the data stack
% is in the following form:
% stack.M::cell-array of 3D-matrices: n tiled image stacks containing
%    fluorescent image
% stack.sM::cell-array of string, 1xn: names of individual stacks
% stack.coord::matrix nx3: x,y,z coordinates of starting points of each
%    stack
% stack.voxel::vector 1x3: xyz size of a voxel
%
% Input
% -----
% - name::string: name of file including the extension ".tif"
%     {DEFAULT : open gui fileselect} spaces and other weird symbols not
%     allowed!
% - options::string: {DEFAULT: '-w'}
%     '-w' : waitbar
%     '-s' : show
%
% Output
% ------
% - stack::struct: image stacks in structure form (see above)
% - name::string: name of output file; [] no file was selected -> no output
% - path::sting: path of the file, complete string is therefore: [path name]
%
% Example
% -------
% stack = loadtifs_stack ([], '-s');
%
% See also load_stack loaddir_stack imload_stack save_stack show_stack
% Uses show_stack
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [stack, tname, path] = loadtifs_stack (tname, options)

if (nargin < 1)||isempty(tname),
    [tname, path] = uigetfile ({'*.tif;*.tiff', 'multiframe tif (*.tif)'}, ...
        'Pick a file', 'multiselect', 'off');
    if tname  == 0,
        stack = [];
        return
    end
else
    path = '';
end
% extract a sensible name from the filename string:
nstart = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
name   = tname  (nstart (end) + 1 : end - 4);
if nstart (end) > 0,
    path = [path tname(1 : nstart (end))];
    tname(1 : nstart (end)) = '';
end

if (nargin < 2)||isempty(options),
    options = '-w'; % {DEFAULT: waitbar}
end

stack.M      = {};
stack.sM {1} = name;
stack.coord  = [0 0 0];
stack.voxel  = [1 1 1];
lenl = length ((imfinfo ([path tname])));
if strfind (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'loading images...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for ward = 1 : lenl,
    if strfind (options, '-w'), % waitbar option: update
        waitbar (ward / lenl, HW);
    end
    if ward == 1,
        stack.M {1} = imread ([path tname], ward);
    else
        stack.M {1} = cat (3, stack.M {1}, imread ([path tname], ward));
    end
end
if strfind (options,'-w'), % waitbar option: close
    close (HW);
end

if strfind (options, '-s') % show option
    clf; hold on;
    show_stack   (stack);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end


