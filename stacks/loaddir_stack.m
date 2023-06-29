% LOADDIR_STACK   load images from a folder into a stack structure.
% (trees package)
%
% [stack path] = loaddir_stack (path, options)
% --------------------------------------------
%
% Loads all images from a directory to an image stack. Images must have the
% same size. But no file error handling.
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
% - path     ::string:  name of existing folder
%     {DEFAULT open GUI}
% - options  ::string:
%     '-s' : show
%     '-k' : skip every second
%     '-w' : waitbar
%     {DEFAULT: '-w'}
%
% Output
% ------
% - stack    ::struct: image stacks in structure form (see above)
% - path     ::string: folder path
%
% Example
% -------
% loaddir_stack  ([], '-s');
%
% See also load_stack loadtifs_stack imload_stack save_stack show_stack
% Uses show_stack
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [stack, tpath] = loaddir_stack (tpath, options)

if (nargin < 1) || isempty (tpath)
    % {DEFAULT: open GUI folderselect}
    tpath    = uigetdir ('.', 'Pick a Directory');
end
% extract a sensible name from the foldername string:
nstart       = unique ([ ...
    0 ...
    (strfind (tpath, '/')) ...
    (strfind (path, '\'))]);
name         = tpath  (nstart (end) + 1 : end);

if (nargin < 2) || isempty (options)
    % {DEFAULT: waitbar}
    options  = '-w';
end

if tpath        ~= 0
    stack.M      = {};
    stack.sM {1} = name;
    stack.coord  = [0 0 0];
    stack.voxel  = [1 1 1];
    if contains   (options, '-w') % waitbar option: initialization
        HW       = waitbar (0, 'loading images...');
        set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
    end
    d            = pwd;
    cd           (tpath);
    P            = dir;
    if length (P) > 2
        if contains (options, '-k')
            for counter      = 3 : 2 : length (P)
                if contains (options, '-w') % waitbar option: update
                    waitbar  (counter / length (P), HW);
                end
                A            = imread (P (counter).name);
                if counter   == 3
                    stack.M {1} = A;
                else
                    stack.M {1} = cat (3, stack.M {1}, A);
                end
            end
        else
            for counter      = 3 : length (P)
                if contains (options, '-w') % waitbar option: update
                    waitbar  (counter / length (P), HW);
                end
                A            = imread (P (counter).name);
                if counter   == 3
                    stack.M {1} = A;
                else
                    stack.M {1} = cat (3, stack.M {1}, A);
                end
            end
        end
    end
    cd           (d);
    if contains (options, '-w') % waitbar option: close
        close    (HW);
    end
else
    stack        = [];
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


