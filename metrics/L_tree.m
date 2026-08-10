% L_TREE   Total length of tree.
% (trees package)
%
% L = L_tree (intree, options)
% --------------------------------
%
% Returns the total summed length of all the branches in tree tree [in um].
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string:
%     '-2d'  : 2-dimensional lengths
%     {DEFAULT: ''}
%
% Output
% -------
% - L        ::Value: total length
%
% Example
% -------
% L_tree     (sample_tree)
%
% See also len_tree cvol_tree vol_tree surf_tree
% Uses len_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function L = L_tree (intree, options)

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

L                = sum (len_tree (intree, options));


