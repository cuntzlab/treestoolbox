% LOAD_TREE   Loads a tree from the swc/neu/Trees format.
% (trees package)
%
% [tree, name, path] = load_tree (name, options)
% ----------------------------------------------
%
% Loads the metrics and the corresponding directed adjacency matrix to
% create a tree in the trees structure.
%
% Input
% -----
% - name     ::string: name of the file to be loaded, incl. the extension.
%     {DEFAULT: open gui fileselect, replaces format entry}
%     formats are file extensions:
%     '.mtr' : TREES toolbox internal format
%        (this is just a matlab workspace!)
%        such a file can contain more than one tree, up to 2 depth for e.g.
%        cgui_tree: {{treei1, treei2,... }, {treej1, treej2,...}, ...}
%        or: {tree1, tree2, ...} or just tree.
%     '.swc' : from the Neurolucida swc format ([inode R X Y Z D/2 idpar])
%        comments prefixed with "#", otherwise only pure ASCII data
%        May contain multiple trees!!
%     '.neu' : from NEURON transfer format .neu (see neu_tree)
%        not every NEURON hoc-file represents a correct graph, read
%        about restrictions in the documentation.
%     {DEFAULT: '.mtr'}
% - options  ::string:
%     '-s'   : show
%     '-r'   : repair tree, preparing trees for most TREES functions
%     '-ks'  : keep sections from NEURON as regions
%     {DEFAULT: '-r' for .swc/.neu 'none' for .mtr}
%
% Output
% ------
% If no output is declared the tree is added to trees
% - tree     :: structured output tree
% - name     ::string: name of output file;
%     []     no file was selected -> no output
% - path     ::string: path of the file
%   complete file name is therefore: [path name]
%
% Example
% -------
% tree         = load_tree;
%
% See also neuron_tree swc_tree start_trees (neu_tree.hoc)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function varargout = load_tree (tname, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (tname)
    [tname, path] = uigetfile ( ...
        {'*.mtr; *swc; *.neu; *.nmf', ...
        'TREES formats (TREES *.mtr or *.swc or *.neu *.nmf)'}, ...
        'Pick a file', ...
        'multiselect',         'off');
    if tname == 0
        varargout{1} = [];
        varargout{2} = [];
        varargout{3} = [];
        return
    end
else
    path     = '';
end

% input format from extension:
format       = tname  (end - 3 : end);
% extract a sensible name from the filename string:
nstart       = unique ([ ...
    0 ...
    (strfind (tname, '/')) ...
    (strfind (tname, '\'))]);
name         = tname  (nstart (end) + 1 : end - 4);

if (nargin < 2) || isempty (options)
    if strcmp (format, '.swc') || ...
            strcmp (format, '.neu') || ...
            strcmp (format, '.nmf')
        options  = '-r';
    else
        options  = '';
    end
end

switch               format
    case             '.nmf' % our new version of .swc
        if ~exist    ([path tname], 'file')
            error    ('.nmf file nonexistent...');
        end
        hinfo        = h5info ([path tname], '/swc');
        tree         = [];
        for counter  = 1 : length (hinfo.Datasets)
            switch   hinfo.Datasets(counter).Name
                case 'index'
                case 'parent_index'
                    idpar  = h5read ([path tname],...
                        '/swc/parent_index');
                    N      = length (idpar);
                    dA     = sparse (N, N);
                    for counter2 = 2 : N
                        dA (counter2, idpar (counter2)) = 1;
                    end
                    tree.dA = dA;
                case 'type'
                    R      = h5read ([path tname], '/swc/type');
                    [i1, ~, i3] = unique (R);
                    tree.R      = i3;
                    tree.rnames = cellstr (num2str (i1))';
                case 'r'
                    D      = h5read ([path tname], '/swc/r') * 2;
                    tree.D = D;
                case 'x'
                    X      = h5read ([path tname], '/swc/x');
                    tree.X = X;
                case 'y'
                    Y      = h5read ([path tname], '/swc/y');
                    tree.Y = Y;
                case 'z'
                    Z      = h5read ([path tname], '/swc/z');
                    tree.Z = Z;
                otherwise
                    tree   = setfield (tree, ...
                        hinfo.Datasets(counter).Name, ...
                        h5read ([path tname], ...
                        ['/swc/' hinfo.Datasets(counter).Name]));
            end
        end
        tree.name      = name;
    case             '.neu' % this is import from NEURON
        if ~exist    ([path tname], 'file')
            error    ('.neu file nonexistent...');
        end
        neufid       = fopen ([path tname], 'r');
        textscan     (neufid, '%s', 16);
        % topology:
        nsec         = textscan (neufid, '%n', 1);
        a            = textscan (neufid, '%s %n %s %n %n', nsec{1});
        a1           = a{1};
        a2           = a{3};
        a3           = a{5};
        c0           = a{2};
        c1           = a{4};
        if sum       (c0 ~= 0)
            error    (['sorry!!' ...
                ' I assume that each new branch is attached at 0 end']);
        end
        textscan     (neufid, '%s', 3);
        % metrics:
        textscan     (neufid, '%n', 1);
        mett         = textscan (neufid, '%n %n %n %n');
        fclose       (neufid);
        geo          = [mett{1} mett{2} mett{3} mett{4}];
        nsec         = length (a1);
        % search parent compartment to each compartment
        d            = zeros (nsec, 1);
        for counter  = 1 : nsec
            if strcmp (a1, a2 (counter)) == 0
                d (counter) = 0; % root
            else
                d (counter) = find (strcmp (a1, a2 (counter)));
            end
        end
        % allow region vectors
        if strfind   (options, '-ks')
            strings  = a1;
        else
            strings      = cell (1, nsec);
            for counter  = 1 : nsec
                sa       = char (a1 (counter));
                insa     = findstr (sa, '[');
                if ~isempty (insa)
                    sa   = [(sa (1 : insa - 1)) '[]'];
                end
                strings{counter} = char (sa);
            end
        end
        % assign region numbers and names:
        [rnames, ~, i2] = unique (strings);
        R            = [];
        for counter  = 1 : length (a3)
            R        = [R; (ones  (a3 (counter), 1) .* i2 (counter))];
        end
        as           = sum (a3); % total number of nodes
        % cumulative sum of nodes for each branch:
        a4           = [0; (cumsum (a3))];
        a5           = [0; 1; (cumsum (a3) + 1)];
        parid        = (0 : as - 1)'; % via the parent id build the swc
        % parent beginning elements: a5(d+1)
        % parent end elements: a4(d+1);
        parid (a4 (1 : end - 1) + 1) = a4 (d + 1);
        indx         = a4 (1 : end - 1) + 1;
        indy         = find (c1 == 0);
        parid (indx (indy)) = a5 (d (indy) + 1);
        parid (parid == 0)  = -1;
        swc          = [(1 : as)', R, geo, parid];
        % tree from swc|(see below) except that it can be more than one
        % tree
        treelimits   = [ ...
            (find (swc (:, 7) == -1)); ...
            (size (swc, 1) + 1)];
        if length (treelimits) > 2
            tree     = cell (1, 1);
            for counter1 = 1 : length (treelimits) - 1
                N    = treelimits (counter1 + 1) - treelimits (counter1);
                dA   = sparse (N, N);
                for counter2 = 2 : N
                    dA (counter2, ...
                        parid (counter2 + treelimits (counter1) - 1) - ...
                        treelimits (counter1) + 1) = 1;
                end
                tree{counter1}.dA = dA;
                tree{counter1}.X  = geo ( ...
                    treelimits (counter1) : ...
                    treelimits (counter1 + 1) - 1, 1);
                tree{counter1}.Y  = geo ( ...
                    treelimits (counter1) : ...
                    treelimits (counter1 + 1) - 1, 2);
                tree{counter1}.Z  = geo (...
                    treelimits (counter1) : ...
                    treelimits (counter1 + 1) - 1, 3);
                tree{counter1}.D  = geo (...
                    treelimits (counter1) : ...
                    treelimits (counter1 + 1) - 1, 4);
                tree{counter1}.R  = R   (...
                    treelimits (counter1) : ...
                    treelimits (counter1 + 1) - 1);
                [i1, ~, i3]      = unique (R (...
                    treelimits (counter1) : ...
                    treelimits (counter1 + 1) - 1));
                tree{counter1}.R      = i3;
                tree{counter1}.rnames = rnames (i1);
            end
        else
            N        = size (swc, 1);
            dA       = sparse (N, N);
            for counter = 2 : N
                dA (counter, parid (counter)) = 1;
            end
            tree.dA  = dA;
            tree.X   = geo (:, 1);
            tree.Y   = geo (:, 2);
            tree.Z   = geo (:, 3);
            tree.D   = geo (:, 4);
            tree.R   = R;
            tree.rnames = rnames;
        end
    case             '.swc' % this is then swc
        if ~exist    ([path tname], 'file')
            error    ('no such file...');
        end
        swcfid       = fopen    ([path tname]);
        A            = textscan (swcfid, '%s', 'delimiter', '\n');
        A            = A{1};
        fclose       (swcfid);
        swc          = [];
        for counter  = 1 : length (A)
            if ~isempty (A{counter})  % allow empty lines in between
                % allow comments: lines starting with #:
                if ~strcmp (A{counter} (1), '#')
                    swc0   = textscan (A{counter}, '%f')';
                    swc    = [swc; swc0{1}'];
                end
            end
        end
        iroots        = find (swc (:, 7) == -1);
        if length    (iroots) > 1
            N        = size (swc, 1);
            
            idpar    = swc (:, 7);
            R        = swc (:, 2);
            X        = swc (:, 3);
            Y        = swc (:, 4);
            Z        = swc (:, 5);
            D        = swc (:, 6) * 2;

            
            
            
            iroots   = find (idpar == -1);
            indy     = 1 : N;
            indy (iroots) = [];
            oners    = ones (N, 1);
            oners (iroots) = [];
            dA       = sparse (indy, idpar (indy), oners, N, N);
            
            tree         = cell (1, length (iroots));
            
            for rcounter = 1 : length (iroots)
                counter      = 1;
                rooty           = dA (:, iroots (rcounter));
                itree        = rooty;
                inodes       = [(iroots (rcounter)); (find (itree))];
                while sum (itree == 1) ~= 0
                    counter  = counter + 1;
                    % use adjacency matrix to walk through tree:
                    itree    = dA * itree;
                    inodes = [inodes; find(itree)];
                end
                inodes = sort (inodes);
                tree{rcounter}.dA = dA (inodes, inodes);
                tree{rcounter}.X = X (inodes);
                tree{rcounter}.Y = Y (inodes);
                tree{rcounter}.Z = Z (inodes);
                tree{rcounter}.D = D (inodes);
                [i1, ~, i3] = unique (R (inodes));
                tree{rcounter}.R   = i3;
                tree{rcounter}.rnames = cellstr (num2str (i1))';
                tree{rcounter} = repair_tree (tree{rcounter});
            end
% % if they are in order:            
%             itree    = [itree; (size (swc, 1))];
%             tree     = cell (1, 1);
%             tcounter = 1;
%             for counter  = 1 : length (itree) - 1
%                 iswc     = swc ( ...
%                     itree (counter) : ...
%                     itree (counter + 1) - 1, :);
%                 N        = size (iswc, 1);
%                 if N > 1
%                     iswc (:, 1)       = iswc (:, 1) - ...
%                         itree (counter) + 1;
%                     iswc (2 : end, 7) = iswc (2 : end, 7) - ...
%                         itree (counter) + 1;
%                     % check index in first column:
%                     if sum     (iswc (:, 1) ~= (1 : N)')
%                         error  ('index needs to be 1 .. n');
%                     end
%                     % vector containing index to direct parent:
%                     idpar    = iswc   (:, 7);
%                     dA       = sparse (N, N);
%                     for acounter = 2 : N
%                         dA (acounter, idpar (acounter)) = 1;
%                     end
%                     tree{tcounter}.dA = dA;
%                     % X-locations of nodes on tree:
%                     tree{tcounter}.X  = iswc (:, 3);
%                     % Y-locations of nodes on tree:
%                     tree{tcounter}.Y  = iswc (:, 4);
%                     % Z-locations of nodes on tree:
%                     tree{tcounter}.Z  = iswc (:, 5);
%                     % local diameter values of nodes on tree:
%                     tree{tcounter}.D  = iswc (:, 6) * 2;
%                     [i1, ~, i3]       = unique (iswc (:, 2));
%                     tree{tcounter}.R  = i3;
%                     tree{tcounter}.rnames = cellstr (num2str (i1))';
%                     tree{tcounter}.name   = [name '_' (num2str (counter))];
%                     tcounter   = tcounter + 1;
%                 end
%             end
        else
            % sort to make sure node #1 comes first
            swc      = sortrows (swc);
            N        = size (swc, 1);
            % check index in first column:
            if any(swc (:, 1) ~= (1 : N)')
                for counter = 2 : N
                    swc (counter, 7) = ...
                        find (swc (counter, 7) == swc (:, 1));
                end
                warning  ('index needs to be 1 .. n, correcting...');
            end
            % index to direct parent:
            idpar    = swc (:, 7);
            dA       = sparse (2 : N, idpar (2 : N), ones (N - 1, 1), N, N);
            tree.dA  = dA;
            % X-locations of nodes on tree:
            tree.X   = swc (:, 3);
            % Y-locations of nodes on tree:
            tree.Y   = swc (:, 4);
            % Z-locations of nodes on tree:
            tree.Z   = swc (:, 5);
            % local diameter values of nodes on tree:
            tree.D   = swc (:, 6) * 2;
            [i1, ~, i3] = unique (swc (:, 2));
            tree.R   = i3;
            tree.rnames = cellstr (num2str (i1))';
            tree.name   = name;
        end
    case             '.mtr' % this is the TREES format
        data         = load ([path tname], '-mat');
        tree         = data.tree;
    otherwise
        warning      ('TREES:IO', 'format unknown');
        varargout{1} = [];
        varargout{2} = tname;
        varargout{3} = path;
        return
end

if strfind           (options, '-r')
    if iscell        (tree)
        for counter1  = 1 : length (tree)
            if iscell (tree{counter1})
                for counter2 = 1 : length (tree{counter1})
                    tree{counter1}{counter2} = repair_tree ( ...
                        tree{counter1}{counter2});
                end
            else
                tree {counter1} = repair_tree (tree{counter1});
            end
        end
    else
        tree         = repair_tree (tree);
    end
end

if strfind           (options, '-s')
    clf; hold on;
    title            ('loaded trees');
    if iscell        (tree)
        for counter1  = 1 : length (tree)
            if iscell (tree {counter1})
                for counter2 = 1 : length (tree {counter1})
                    plot_tree (tree{counter1}{counter2});
                end
            else
                plot_tree (tree{counter1});
            end
        end
    else
        plot_tree (tree);
    end
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (3);
    grid         on;
    axis         image;
end

% check tree for loops
if exist ('graphisdag', 'file')
    checkLoop (tree)
else
    warning ([ ...
        'Could not check for loops in tree as required ' ...
        'Matlab function "graphisdag" was not found. ' ...
        'Please check on yourself']);
end

if (nargout > 0)
    % if output is defined then it becomes the tree:
    varargout{1} = tree;
    varargout{2} = tname;
    varargout{3} = path;
else
    % otherwise add to end of trees cell array:
    trees{length (trees) + 1} = tree;
end

function checkLoop (tree)
if iscell (tree)
    for t = 1 : numel (tree)
        checkLoop (tree{t})
    end
else
    if  ~graphisdag (tree.dA) 
        warning (['Tree %s contains one or multiple loops, ' ...
            'which should not be allowed for directed trees. ' ...
            'Please fix them!'],tree.name);
    end
end



