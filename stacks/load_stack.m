% LOAD_STACK   load stack file into a stack structure.
% (trees package)
%
% [stack name path] = load_stack (name, options)
% ----------------------------------------------
%
% loads a stack structure from a file.
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
% - name     ::string: name of file including the extension ".stk"
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
% stack        = load_stack ('sample.stk', '-s');
%
% See also imload_stack loadtif_stack show_stack
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [stack, tname, path] = load_stack (tname, options)

if (nargin < 1) || isempty (tname)
    [tname, path]  = uigetfile ( ...
        {'*.stk', 'stack format (*.stk)'}, ...
        'Pick a file', ...
        'multiselect',         'off');
    if tname       == 0
        stack      = [];
        return
    end
else
    path           = '';
end

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if tname    ~= 0
    data     = load ([path tname], '-mat');
    stack    = data.stack;
else
    stack    = [];
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



