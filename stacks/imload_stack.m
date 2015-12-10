% IMLOAD_STACK   load image into a 3D matrix.
% (trees package)
%
% [stack name path] = imload_stack (name, options)
% ------------------------------------------------
%
% Loads image from file.
%
% the stack structure as in "save_stack":
% stack has to be in the following form:
% stack.M     ::cell-array of 3D-matrices: n tiled image stacks containing
%    fluorescent image
% stack.sM    ::cell-array of string, 1xn: names of individual stacks
% stack.coord ::matrix nx3: x, y, z coordinates of starting points of each
%    stack
% stack.voxel ::vector 1x3: xyz size of a voxel
%
% Input
% -----
% - name     ::string: name of the output-file without extension
%     {DEFAULT : open gui fileselect}
%     Spaces and other weird symbols not allowed!
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%   
% Output
% ------
% - stack    ::struct: image stacks in structure form (see above)
% - name     ::string: name of output file;
%     []     no file was selected -> no output
% - path     ::string: path of the file
%   complete file name is therefore: [path name]
%
% Example
% -------
% stack        = imload_stack ([],'-s')
%
% See also load_stack loaddir_stack loadtifs_stack save_stack show_stack
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [stack, tname, path] = imload_stack (tname, options)

if (nargin < 1) || isempty (tname)
    [tname, path]  = uigetfile ( ...
        {'*.jpg;*.tif;*.bmp','any image type'}, ...
        'Pick a file', ...
        'multiselect',         'off');
    if tname       == 0
        stack      = [];
        return
    end
else
    path           = '';
end
% extract a sensible name from the filename string:
nstart       = unique ([ ...
    0 ...
    (strfind (tname, '/')) ...
    (strfind (tname, '\'))]);
name         = tname  (nstart (end) + 1 : end - 4);
if nstart (end) > 0
    path     = [path  (tname (1 : nstart (end)))];
    tname (1 : nstart (end)) = '';
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

stack.M      = {};
stack.sM     = {};
stack.sM{1}  = name;
stack.coord  = [0 0 0]; 
stack.voxel  = [1 1 1];
stack.M{1}   = imread ([path tname]);

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


