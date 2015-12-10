% NEUROLUCIDA_TREE   Loads a tree from the neurolucida ASCII format.
% (trees package)
%
% [tree, coords, contours, name, path] = neurolucida_tree (name, options)
% -----------------------------------------------------------------------
%
% loads the metrics and the corresponding directed adjacency matrix to
% create a tree directly from an ASCII neurolucida description. NOTE! For
% example to infer the cylinder-representation of the soma I chose quite
% arbitrary algorithms. Sub-trees are attributed to somata by
% who-is-closest. This function can be much further optimized or just
% rewritten. The function however has additional features to the NEURON
% neurolucida import, for example spines are imported (as cylinders with
% region names "spines"). Furthermore, imported markers can be added as
% spines via "spines_tree".
%
% Input
% -----
% - name::string: name of the file to be loaded, {DEFAULT : GUI will open}
% - options::string {DEFAULT : '-r -c -w'}
%     '-s' : show
%     '-r' : repair tree, preparing it for most TREES functions
%     '-c' : load spines
%     '-o' : force one soma
%     '-w' : waitbar
%
% Output
% ------
% - tree::tree: if an output is defined the trees are written there, otherwise they go in
% trees
% - coords:: vectors with coordinates of markers
% - contours:: original contours of somata
%
% Example
% -------
% tree = neurolucida_tree
%
% See also load_tree spines_tree start_trees (neu_tree.hoc)
% Uses
%
% Thanks to Arnd Roth for providing the neurolucida specification file.
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function varargout = neurolucida_tree (tname, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin<1)||isempty(tname),
    [tname tpath] = uigetfile ('*.asc', 'load tree in ASCII format');
    if tname == 0,
        varargout{1} = []; varargout{2} = [];
        varargout{3} = []; varargout{4} = tname; varargout{5} = tpath;
        return
    end
else
    tpath = '';
end

if (nargin<2)||isempty(options)
    options = '-r -c -w';
end

markers = {'Dot',         'OpenStar',         'FilledQuadStar',   'CircleArrow',    'OpenCircle', ...
    'DoubleCircle',       'OpenQuadStar',     'CircleCross',      'Cross',          'Circle1', ...
    'Flower3',            'Plus', 'Circle2',  'Pinwheel',         'OpenUpTriangle', 'Circle3', ...
    'TexacoStar',         'OpenDownTriangle', 'Circle4',          'ShadedStar',     'OpenSquare', ...
    'Circle5',            'SkiBasket',        'Asterisk',         'Circle6',        'Clock',      'OpenDiamond', ...
    'Circle7',            'ThinArrow',        'FilledStar',       'Circle8',        'ThickArrow', 'FilledCircle', ...
    'Circle9',            'SquareGunSight',   'FilledUpTriangle', 'Flower2',        'GunSight', ...
    'FilledDownTriangle', 'SnowFlake',        'TriStar',          'FilledSquare',   'OpenFinial', ...
    'NinjaStar',          'FilledDiamond',    'FilledFinial',     'KnightsCross',   'Flower', ...
    'MalteseCross',       'Splat'};

nonsense_full   = {'(Name', '(ImageCoords', '(Thumbnail', '(Color', '(Sections', ...
    '(SSM', '("dZI"'};
nonsense_simple = {'Normal', 'Low', 'High', 'Generated', 'Incomplete'};

% create a cell array of strings containing the lines of code
file = textread ([tpath tname], '%s', 'delimiter', '\n');

if strfind (options, '-w'),
    HW = waitbar (0, 'extract tree information...'); % waitbar option: initialization
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end

% eliminate any comments, Color, Name, ImageCoords, Thumbnail
% eliminate even descriptors for termination type (sorry don't know what
% they mean..)
for ward = 1 : length (file),
    p1 = strfind (file{ward}, ';');
    if ~isempty (p1)
        file{ward} = file{ward}(1 : (p1 - 1));
    end
    for te = 1 : length (nonsense_full),
        p1 = strfind (file{ward}, nonsense_full{te});
        if ~isempty (p1)
            [file, y1]  = eliminate_entry (ward, p1(1), file);
            ward = y1;
        end
    end
    for te = 1 : length (nonsense_simple),
        p1 = strfind (file{ward}, nonsense_simple{te});
        if ~isempty (p1)
            file{ward} = file{ward}(p1 : (p1 + length (nonsense_simple{te}) - 1));
        end
    end
end

if strfind (options, '-w'), % waitbar option: reinitialization
    waitbar (0.2, HW, 'tag regions...');
end

% region-tagging
regions = zeros (length (file), 1); rnames = {'noregion'}; region = 1;
for ward = 1 : length (file),
     % regular expression for anything directly surrounded by 2
    % parantheses (usually indicating region names):
    [a b] = regexp (file{ward}, '\(\w*\)');
    if ~isempty (a)
        rnames{end+1} = file{ward}(a + 1 : b - 1); region = region + 1;
        file{ward}(a : b)='';
    end
    regions (ward) = region;
end
[i1 i2 i3] = unique (rnames);
regions = i3 (regions)';
rnames = i1;
R = [];

if strfind (options, '-w'), % waitbar option: reinitialization
    waitbar (0.4, HW, 'extract markers...');
end

mcoords = [];
% extract coordinates of markers
for ward = 1 : length (file),
    for te = 1 : length (markers)
        p1 = strfind (file{ward}, ['(' markers{te}]);
        if ~isempty (p1)
            [coords, file, y1]  = extract_entry (ward, p1(1), file);
            mcoords = [mcoords; coords];
            ward = y1;
        end
    end
end

if strfind (options,'-w'), % waitbar option: reinitialization
    waitbar (0.6, HW, 'extract contours...');
end

mcontours = {};
% extract contours (considered to delimit the soma)
for ward = 1 : length (file),
    [a b] = regexp (file{ward}, '\("\D+"');
    if ~isempty (a)
        mcontours{end+1}.name = file{ward}(a + 2 : b - 1);
        [conto, name2, file, y1, regions]  = extract_contour (ward, a (1), file, regions);
        mcontours{end}.name2  = name2;
        mcontours{end}.c      = conto;
        ward = y1;
    end
end

if strfind (options, '-w'), % waitbar option: reinitialization
    waitbar (0.8, HW, 'make somata...');
end

% make somata
mtree = cell (1, length (mcontours));
for ward = 1 : length (mcontours)
    X = mcontours{ward}.c(:, 1);
    Y = mcontours{ward}.c(:, 2);
    Z = mcontours{ward}.c(:, 3);
    Gpath = [0; sqrt((X (2 : end) - X (1 : end - 1)).^2 + ...
        (Y (2 : end) - Y (1 : end - 1)).^2+ ...
        (Z (2 : end) - Z (1 : end - 1)).^2)];  Gpath = cumsum (Gpath);
    [l lindy] = unique (Gpath);
    [RXYZ] = interp1 (Gpath (lindy), [X(lindy) Y(lindy) Z(lindy)], ...
        (0 : floor (max (Gpath (lindy))))');
    X = RXYZ (:, 1);    Y = RXYZ (:, 2);    Z = RXYZ (:, 3);
    num = size (X, 1);
    mX = mean (X); mY = mean (Y); mZ = mean (Z);
    mdist = sqrt((mX - X).^2 + (mY - Y).^2 + (mZ - Z).^2);
    [i1 i2] = max (mdist);
    nXYZ = [X Y Z]-[mX(ones(num, 1)) mY(ones(num, 1)) mZ(ones(num, 1))];
    [p d] = eigs (cov (nXYZ (:, [1 2]))); % only 2D % replaces princomp by eigs(cov(
    XYZ = nXYZ (:, [1 2]) * p';
    X1 = XYZ (:, 1); Y1 = XYZ (:, 2); Z1 = zeros (size (X1, 1), 1);
    [o indy] = unique (X1);
    RD = sqrt (Y1 (indy).^2 + Z1 (indy).^2);
    dX = ceil (min (X1 (indy))) : floor (max (X1 (indy)));
    D1 = interp1 (X1 (indy), RD, dX, 'linear', 'extrap');
    D1 = convn (D1, ones (1, 10) / 10, 'same');
    num1 = length (dX);
    XYZR = [[dX' zeros(num1, 1)]/p' zeros(num1, 1)]+...
        [mX(ones(num1, 1)) mY(ones(num1, 1)) mZ(ones(num1, 1))];
    num = size (XYZR, 1);
    dA = sparse (num, num);
    for te = 2 : num;
        dA (te, te - 1) = 1;
    end
    mtree{ward}.dA     = dA;
    mtree{ward}.X      = XYZR (:, 1);
    mtree{ward}.Y      = XYZR (:, 2);
    mtree{ward}.Z      = XYZR (:, 3);
    mtree{ward}.D      = 2 * D1';
    mtree{ward}.R      = ones (num, 1);
    mtree{ward}.rnames = {rnames{mcontours{ward}.name2}};
end

if strfind (options, '-o'), % force one soma, the one with largest volume
    voli = 1; volu = 0;
    for ward = 1 : length (mtree)
        if sum (vol_tree (mtree{ward})) > volu,
            voli = ward; volu = sum (vol_tree (mtree{ward}));
        end
    end
    mtree = {mtree{voli}};
end

if strfind (options, '-w'), % waitbar option: reinitialization
    waitbar (0.9, HW, 'eliminate empty entries...');
end

% eliminate all empty entries
emptied  = [];
for ward = 1 : length (file),
    [a b] = regexp (file{ward}, '\s*');
    if numel (a) == 1,
        if ((a == 1) && (b == length (file{ward}))),
            emptied (end + 1) = ward;
        end
    elseif isempty (file{ward})
        emptied (end + 1) = ward;
    end

end
file(emptied) = []; regions(emptied) = [];

if strfind (options, '-w'), % waitbar option: reinitialization
    waitbar (0, HW, 'reconstruct tree...');
end

% remainder in file is the actual tree structure:
% extract tree structure
P = {[]}; PL = {[]}; Plevel = 0; ipar = {1}; R = {[]};
Tflag = 0; Zflag = 0; inspine = 0; spines = {}; ispine = []; i2spine = [];
lenf = length (file);
for ward = 1 : lenf
    if strfind (options, '-w'),
        waitbar (ward / lenf);
    end
    a = strfind (file{ward}, '<'); % first check if there is a spine
    b = strfind (file{ward}, '>');
    if ~isempty (a),
         % find coordinates - used to be:'\(([\d\s,.-])+\)'  :
        [a2 b2] = regexp  (file{ward}(a : b), '\(([\d\s,.-])*([\d.-])+([\d\s,.-])+');
        P0      = str2num (file{ward}(a2 + 1 : b2)); % extract numerical values of coordinates
        P0 = [P0, zeros(1, 4 - length (P0))];        % fill up with zeroes if not full
        file{ward}(a : b) = '';
        if inspine,
            dA = spines{end}.dA; num = size(dA, 1);
            dA = [[dA zeros(num, 1)]; zeros(1, num + 1)];
            dA (num + 1, num) = 1;
            spines{end}.dA = dA;
            spines{end}.X  = [spines{end}.X; P0(1)];
            spines{end}.Y  = [spines{end}.Y; P0(2)];
            spines{end}.Z  = [spines{end}.Z; P0(3)];
            spines{end}.D  = [spines{end}.D; P0(4)];
            spines{end}.R  = [spines{end}.R; 1];
        else
            spines{end+1}.dA = sparse (1, 1);
            spines{end}.X    = P0 (1);
            spines{end}.Y    = P0 (2);
            spines{end}.Z    = P0 (3);
            spines{end}.D    = P0 (4);
            spines{end}.R    = 1;
            spines{end}.rnames = {'spines'};
            ispine = [ispine; length(P)]; i2spine = [i2spine; length(P{end})];
        end
        inspine = 1;
    else
        inspine = 0;
        [a b] = regexp (file{ward}, '\(([\d\s,.-])*([\d.-])+([\d\s,.-])+[\w]*\)'); % find coordinates
        if ~isempty (a),
             % find coordinates - used to be:'\(([\d\s,.-])+\)'   :
            [a2 b2] = regexp  (file{ward}(a : b), '\(([\d\s,.-])*([\d.-])+([\d\s,.-])+');
            P0      = str2num (file{ward}(a + 1 : b2)); % extract numerical values of coordinates
            P0 = [P0, zeros(1, 4 - length (P0))];       % fill up with zeroes if not full
            P{end} =[P{end}; P0]; PL{end} = [PL{end}; Plevel]; R{end} = [R{end}; regions(ward)];
            file{ward}(a : b) = '';
            if length (PL{end}) > 1,
                if Zflag, % if tree was just closed open a new tree with the new coordinates
                    ipar{end + 1} = 1;
                    P{end + 1}  =  P{end}(end,:);  P{end-1}(end,:) = [];
                    PL{end + 1} = PL{end}(end,:); PL{end-1}(end,:) = [];
                    R{end+1}    =  R{end}(end,:);  R{end-1}(end,:) = [];
                    Tflag = 0; Zflag = 0;
                else
                    if PL{end}(end) < PL{end}(end - 1)
                        ipar{end}(end + 1) = find (PL{end}(1 : end - 1) == Plevel - 1, 1, 'last');
                        Tflag = 0;
                    else
                        if (Tflag && (PL{end}(end) == Plevel)),
                            if (Plevel > 1)
                                ipar{end}(end + 1) = find (PL{end}(1 : (end - 1)) == Plevel - 1, 1, 'last');
                                Tflag = 0;
                            else
                                ipar{end + 1} = 1;
                                P{end + 1}    = P{end}(end, :);  P{end-1}(end, :)  = [];
                                PL{end+1}     = PL{end}(end, :); PL{end-1}(end, :) = [];
                                R{end+1}      = R{end}(end, :);  R{end-1}(end, :)  = [];
                                Tflag = 0;
                            end
                        else
                            ipar{end}(end + 1) = length (PL{end}) - 1;
                        end
                    end
                end

            end
        end
        u1 = strfind (file{ward}, '(');
        u2 = strfind (file{ward}, ')');
        if ~isempty (u1),
            Plevel = Plevel + 1; % open a new branch and increase level
        end
        if ~isempty (u2),
            Plevel = Plevel - 1; Tflag = 1; % close a branch
            if Plevel <= 1
                Zflag = 1; % close tree if back at ground level
            end
        end
        uT = strfind (file{ward}, '|');
        if ~isempty (uT),
            Tflag = 1;  % close a branch
        end
    end
end
for ward = 1 : length (ipar)
    num = size (P{ward}, 1);
    dA = sparse (num, num);
    for te = 2 : num;
        dA (te, ipar{ward}(te)) = 1;
    end
    tree{ward}.dA = dA;
    tree{ward}.X  = P{ward}(:, 1);
    tree{ward}.Y  = P{ward}(:, 2);
    tree{ward}.Z  = P{ward}(:, 3);
    tree{ward}.D  = P{ward}(:, 4);
    [i1 i2 i3]    = unique(R{ward});
    tree{ward}.R  = i3;
    tree{ward}.rnames = rnames (i1);
end
uispine = unique (ispine);
if ~isempty (uispine),
    % borrowed from cat_tree!
    for ward = 1 : length (uispine),
        indy = find (ispine == uispine (ward));
        ndA = tree{uispine(ward)}.dA;
        for te = 1 : length (indy),
            N1 = size (ndA, 1);
            N2 = size (spines{indy(te)}.dA, 1);
            ndA = sparse ([[ndA; sparse(N2, N1)] [sparse(N1, N2); spines{indy(te)}.dA]]);
            ndA (1 + N1, i2spine (indy (te))) = 1;
            % expand all fields, take only tree fields
            S = fieldnames (tree{uispine(ward)});
            for tissimo = 1 : length (S),
                if (~strcmp (S{tissimo}, 'dA')) && (~strcmp (S{tissimo}, 'rnames')),
                    if strcmp (S{tissimo}, 'R'),
                        [i1 i2 i3] = unique ([tree{uispine(ward)}.rnames  spines{indy(te)}.rnames]);
                        R = [tree{uispine(ward)}.R;  spines{indy(te)}.R+length(tree{uispine(ward)}.rnames)];
                        i3 = i3'; tree{uispine(ward)}.R = i3 (R);
                        tree{uispine(ward)}.rnames = i1;
                    else
                        tree{uispine(ward)}.(S{tissimo}) = [tree{uispine(ward)}.(S{tissimo}); ...
                            spines{indy(te)}.(S{tissimo})];
                    end
                end
            end
        end
        tree{uispine(ward)}.dA = ndA;
        tree{uispine(ward)} = sort_tree (tree{uispine(ward)}, '-LO');
    end
end
% complete tree by starting at the contours
if isempty (mtree),
    mtree{1} = tree{1}; tree(1) = [];
end
for ward = 1 : length (tree)
    XR = tree{ward}.X(1);
    YR = tree{ward}.Y(1);
    ZR = tree{ward}.Z(1);
    IRY = 1000; INDY = 1; TEY = 1;
    for te = 1 : length (mtree)
        Dist = sqrt ((mtree{te}.X - XR).^2 + ...
            (mtree{te}.Y - YR).^2 + ...
            (mtree{te}.Z - ZR).^2) - ...
            mtree{te}.D./2;
        [iry indy] = min (Dist);
        if iry < IRY,
            INDY = indy;
            IRY  = iry;
            TEY  = te;
        end
    end
    mtree{TEY} = cat_tree (mtree{TEY}, tree{ward}, INDY, 1);
end

if strfind (options, '-w'), % waitbar option: close
    close (HW);
end

if findstr (options, '-r'),
    for ward = 1 : length (mtree)
        mtree{ward} = repair_tree (mtree{ward});
    end
end

if findstr (options, '-s'), % show option
    clf; hold on; title ('loaded trees');
    for ward = 1 : length (mtree)
        plot_tree (mtree{ward});
    end
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (3); grid on; axis image;
end

if length (mtree) == 1
    tree = mtree{1};
else
    tree = mtree;
end

if (nargout > 0)
    varargout{1} = tree; % if output is defined then it becomes the tree
    varargout{2} = mcoords;
    varargout{3} = mcontours;
    varargout{4} = tname;
    varargout{5} = tpath;
else
    trees{length(trees) + 1} = tree; % otherwise the orginal tree in trees is replaced
end
end

% delete everything that is between two parantheses
% y: line number for starting paranthesis
% x: character number within that line
% file: updated cell array of strings containing the file
function [file, y1, x1] = eliminate_entry (y, x, file)
pcounter = 1;
ward     = y;
while y < length (file)
    u1 = strfind (file{ward}, '(');
    u2 = strfind (file{ward}, ')');
    if ward == y,
        u1 (u1 <= x) = [];
        u2 (u2 <= x) = [];
    end
    ux = [(u1.*0 + 1) (u2.*0 - 1)];
    [u i] = sort([u1 u2]);
    pc  = pcounter + cumsum (ux (i));
    ipc = find (pc == 0);
    if ~isempty (ipc),
        y1 = ward;
        x1 = u (ipc);
        if ward == y,
            file{ward}(x : x1) = '';
        else
            file{ward}(1 : x1) = '';
        end
        break
    else
        if ward == y,
            file{ward}(x : end) = '';
            if ~isempty (ux (i)),
                pcounter = pc (end);
            end
        else
            file{ward} = '';
        end
    end
    ward = ward + 1;
end
end

% extract coordinates that are between two parantheses
% same aufbau as eliminate_entry
% y: line number for starting paranthesis
% x: character number within that line
% file: updated cell array of strings containing the file
function [coords, file, y1] = extract_entry (y, x, file)
coords   = [];
pcounter = 1;
ward     = y;
while y < length (file)
    [a b] = regexp (file{ward}, '\(([\d\s,.-])*([\d.-])+([\d\s,.-])+[\w]*\)'); % find coordinates
    if ~isempty (a),
        coordo = str2num (file{ward}(a + 1 : b - 1));
        coordo = [coordo, zeros(1, 4 - length (coordo))];
        coords = [coords; coordo];
    end
    u1 = strfind (file{ward}, '(');
    u2 = strfind (file{ward}, ')');
    if ward == y,
        u1 (u1 <= x) = [];
        u2 (u2 <= x) = [];
    end
    ux = [(u1.*0 + 1) (u2.*0 - 1)];
    [u i] = sort ([u1 u2]);
    pc = pcounter + cumsum (ux (i));
    ipc = find (pc == 0);
    if ~isempty (ipc),
        y1 = ward;
        x1 = u (ipc);
        if ward == y,
            file{ward}(x : x1) = '';
        else
            file{ward}(1 : x1) = '';
        end
        break
    else
        if ward == y,
            file{ward}(x : end) = '';
            if ~isempty (ux (i)),
                pcounter = pc (end);
            end
        else
            file{ward} = '';
        end
    end
    ward = ward +1;
end
end

% extract contours that are between two parantheses
% same aufbau as eliminate_entry
% y: line number for starting paranthesis
% x: character number within that line
% file: updated cell array of strings containing the file
function [coords, name2, file, y1, regions] = extract_contour (y, x, file, regions)
coords   = []; name2 = [];
pcounter = 1;
% file{y}(x+1:end); % unused name of the contour
ward = y;
while y < length (file)
     % find coordinates - used to be:'\(([\d\s,.-])+\)'    :
    [a b] = regexp (file{ward}, '\(([\d\s,.-])*([\d.-])+([\d\s,.-])+[\w]*\)');
    if ~isempty (a),
        if isempty (name2),
            name2 = regions (ward);
        end
         % find coordinates - used to be:'\(([\d\s,.-])+\)'   :
        [a2 b2] = regexp (file{ward}(a : b), '\(([\d\s,.-])*([\d.-])+([\d\s,.-])+');
        coordo  = str2num (file{ward}(a + 1 : b2));
        coordo  = [coordo,zeros(1, 4 - length (coordo))];
        coords  = [coords; coordo];
    end
    u1 = strfind (file{ward}, '(');
    u2 = strfind (file{ward}, ')');
    if ward == y,
        u1 (u1 <= x) = [];
        u2 (u2 <= x) = [];
    end
    ux = [(u1.*0 + 1) (u2.*0 - 1)];
    [u i] = sort ([u1 u2]);
    pc = pcounter + cumsum (ux (i));
    ipc = find (pc == 0);
    if ~isempty (ipc),
        y1 = ward;
        x1 = u (ipc);
        if ward == y,
            file{ward}(x : x1) = '';
        else
            file{ward}(1 : x1) = '';
        end
        break
    else
        if ward == y,
            file{ward}(x : end) = '';
            if ~isempty (ux (i)),
                pcounter = pc (end);
            end
        else
            file{ward} = '';
        end
    end
    ward = ward + 1;
end
end