% ABEL_TREE   Euclidean length of tree segments (mean).
% (trees package)
%
% abel = abel_tree (intree, options)
% ----------------------------------
%
% Returns the average Euclidean distance between branch points and
% termination points [in um].
%
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% -------
% - abel     ::double: average Euclidean distance
%
% Example
% -------
% abel_tree  (sample_tree, '-s')
%
% See also len_tree
% Uses len_tree C_tree delete_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function abel = abel_tree (intree, options)

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

iC               = C_tree (intree);
iC (1)           = 0;
dtree            = delete_tree (intree, find (iC));
len              = len_tree (dtree);
abel             = mean (len);

if contains       (options, '-s') % show option
    clf;
    hold         on;
    clf;
    HP           = plot_tree (dtree, len, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colorbar;
    title        ( ...
        ['ABEL: ' (num2str (round (mean (len)))) ' µm']);
    xlabel       ('x [µm]');
    ylabel       ('y [µm]');
    zlabel       ('z [µm]');
    view         (2);
    grid         on;
    axis         image;
end



