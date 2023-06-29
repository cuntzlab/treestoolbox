% LOADTIFS_STACK   load a tif image stack file into a stack structure.
% (trees package)
%
% [stack, name, path] = loadtifs_stack (name, options)
% ----------------------------------------------------
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
% - name     ::string: name of file including the extension ".tif"
%     spaces and other weird symbols not allowed!
%     {DEFAULT : open gui fileselect} 
% - options  ::string:
%     '-w'   : waitbar
%     '-s'   : show
%     {DEFAULT: '-w'}
%
% Output
% ------
% - stack    ::struct: image stacks in structure form (see above)
% - name     ::string: name of output file
%     [] no file was selected -> no output
% - path     ::sting:  path of the file
%     complete string is therefore: [path name]
%
% Example
% -------
% stack        = loadtifs_stack ([], '-s');
%
% See also load_stack loaddir_stack imload_stack save_stack show_stack
% Uses show_stack
%
% Significant speed improvement by Marcel Beining 2017
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [stack, tname, path] = loadtifs_stack (tname, options)

if (nargin < 1) || isempty (tname)
    [tname, path] = uigetfile ({'*.tif;*.tiff', 'multiframe tif (*.tif)'}, ...
        'Pick a file', 'multiselect', 'off');
    if tname  == 0
        stack = [];
        return
    end
else
    path     = '';
end
% extract a sensible name from the filename string:
nstart       = unique ([0 ...
    (strfind (tname, '/')) ...
    (strfind (tname, '\'))]);
name         = tname  (nstart (end) + 1 : end - 4);
if nstart (end) > 0
    path     = [path (tname (1 : nstart (end)))];
    tname (1 : nstart (end)) = '';
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: waitbar}
    options  = '-w';
end

stack.M          = {};
stack.sM{1}      = name;
stack.coord      = [0 0 0];
stack.voxel      = [1 1 1];

info             = imfinfo (fullfile (path, tname));
if info(1).BitDepth > 8 %!%!%!%!
    answer       = questdlg ( [...
        'Warning! The TIF file you are trying to load is more than 8bit!'...
        ' This can cause a wrong visualization!'...
        ' Please resample before loading. Proceed anyways?'], ...
        'Bit Depth too big!', 'No');
    if ~strcmp   (answer, 'Yes')
    stack        = [];
    return
    end
end
sizeM            = [(info(1).Height) (info(1).Width) (numel (info))];
lenl             = sizeM (3);

if contains (options, '-w') % waitbar option: initialization
    HW           = waitbar (0, 'loading images...');
    set          (HW, ...
        'Name',                '..PLEASE..WAIT..YEAH..');
end

stack.M{1}       = zeros (sizeM, 'uint8');

for counter      = 1 : lenl
    if contains (options, '-w') % waitbar option: update
        waitbar  (counter / lenl, HW);
    end
    stack.M{1}(:, :, counter) = ...
        imread (fullfile (path, tname), 'tif', counter);
end

if contains (options, '-w') % waitbar option: close
    close        (HW);
end

if contains (options, '-s') % show option
    clf;
    hold         on;
    show_stack   (stack);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end



