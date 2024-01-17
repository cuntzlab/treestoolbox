% ELEN_TREE   Electrotonic length of segments in a tree.
% (trees package)
% 
% elen = elen_tree (intree, options)
% ----------------------------------
%
% Returns the electrotonic length of each segment (length/lambda).
%
% Input
% -----
% - intree   ::integer:    index of tree in trees or structured tree
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - elen     ::Nx1 vector: electrotonic length values of each segment
%
% Example
% -------
% elen_tree    (sample_tree, '-s')
%
% See also lambda_tree len_tree
% Uses lambda_tree len_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function elen = elen_tree (intree, options)

ver_tree     (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

elen             = len_tree (intree) ./ lambda_tree (intree) / 10000;
% conversion here from [um] length to [cm] since electrotonic properties
% are per cm

if contains      (options, '-s')
    ipart        = find (elen ~= 0); % single out non-0-length segments
    clf; hold on;
    plot_tree    (intree, elen, [], ipart);
    colorbar;
    title        ([ ...
        'electrotonic length (total: ~' ...
        (num2str (round (sum (elen)))) ...
        ') [in length constants]']);
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

