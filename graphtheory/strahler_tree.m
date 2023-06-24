% STRAHLER_TREE   Strahler values in a tree.
% (trees package)
% 
% strahler = strahler_tree (intree, options)
% ------------------------------------------
% 
% returns the Strahler values for each node:
% - if the node is a terminal, its Strahler number is one.
% - if the node has one child with Strahler number i, and all other
%   children have Strahler numbers less than i, then the Strahler number of
%   the node is i again.
% - if the node has two or more children with Strahler number i, and no
%   children with greater number, then the Strahler number of the node is i +
%   1.
% (from Wikipedia article : "Strahler number")
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - options::string: {DEFAULT: ''}
%     '-s' : show
%
% Output
% ------
% strahler::Nx1 vector: vector of strahler values
%
% Example
% -------
% strahler_tree (sample_tree, '-s')
%
% See also PL_tree BO_tree
% Uses ver_tree idpar_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function strahler = strahler_tree (intree, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array} 
    intree   = length(trees);
end

ver_tree (intree); % verify that input is a tree structure

if (nargin < 2) || isempty (options)
    options  = ''; % {DEFAULT: no option}
end

T                = T_tree (intree);
strahler         = double (T);
idpar            = idpar_tree (intree, '-0');
pid              = idpar  (T);

counter          = 1;
while ~isempty   (find (strahler == 0, 1))
    ipid         = pid (counter);
    ichilds      = find (intree.dA (:, ipid)); % find children for ipid
    if length (ichilds) == 1
        strahler (ipid) = strahler (ichilds);
        if idpar (ipid) ~=0 % if parent is not root
            pid (counter) = idpar (ipid); % its parent replaces it in the list
        else
            pid (counter) = []; % else get rid of it simply
            counter = counter + 1;
        end
    else
        if isempty (find (strahler (ichilds) == 0, 1))
             % find all children with maximal Strahler:
            iall = find (strahler (ichilds) == max (strahler (ichilds)));
            if length (iall) > 1
                strahler (ipid) = max (strahler (ichilds)) + 1;
                if idpar (ipid) ~=0 % if parent is not root
                    % its parent replaces it in the list:
                    pid (counter) = idpar (ipid); 
                else
                     % else get rid of it simply:
                    pid (counter) = [];
                    counter = counter + 1;
                end
            else
                strahler (ipid) = max (strahler (ichilds));
                if idpar (ipid) ~=0 % if parent is not root
                    % its parent replaces it in the list:
                    pid (counter) = idpar (ipid);
                else
                    % else get rid of it simply:
                    pid (counter) = [];
                    counter = counter + 1;
                end
            end
        else
            counter = counter + 1;
        end
    end
    if counter > length (pid)
        counter  = 1;
    end
end

if contains (options, '-s') % show option
    clf;
    hold         on;
    HP           = plot_tree (intree, strahler, [], [], [], '-b');
    set          (HP, ...
        'edgecolor',           'none');
    colorbar;
    title        ('Strahler number');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end


