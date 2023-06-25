% SAVE_STACK   save images into a file.
% (trees package)
%
% name = save_stack (stack, name, options)
% ----------------------------------------
%
% save images from a stack into a matlab type file
% data has to be in the following form:
% stack.M::cell-array of 3D-matrices: n tiled image stacks containing
%    fluorescent image
% stack.sM::cell-array of string,1xn: names of individual stacks
% stack.coord::matrix nx3: x,y,z coordinates of starting points of each
%    stack
% stack.voxel::vector 1x3: xyz size of a voxel
%
% Input
% -----
% - stack::struct: image stacks in structure form (see above)
% - name::string: {DEFAULT open GUI}
% - options::string: {DEFAULT: ''}
%
% Output
% ------
% name::string: file name
%
% Example
% -------
% save_stack ('mso_stack.stk')
%
% See also
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function name = save_stack (stack, name, options)

if (nargin < 2)||isempty(name),
    [name tpath] = uiputfile ('.stk','save stack', 'stack.stk');
    if name  == 0,
        name = [];
        return
    end
else
    tpath = '';
end

if (nargin < 3)||isempty(options),
    options = '';
end

if name~=0,
    save ([tpath name], 'stack');
end



