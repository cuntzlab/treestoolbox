% NEURON_TREE   Export tree as NEURON file.
% (trees package)
%
% [name path] = neuron_tree (intree, name, res, options)
% ------------------------------------------------------
%
% saves a complete tree in the section based neuron '.hoc' format.
% Alternatively tree can also be stored as '.nrn' file in which each
% segment from the tree graph becomes an independent section in neuron.
%
% Inputs
% ------
% - intree::integer:index of tree in trees or structured tree
% - name::string: name of file including the extension ".hoc" or ".nrn"
%     {DEFAULT : open gui fileselect} spaces and other weird symbols not
%     allowed!
% - res::number or vector: number of segments per compartment. If vector, one
%     value per compartment, otherwise single value same for all compartments
%     {DEFAULT : ceiling of length in um of compartment}
% - options::string: {DEFAULT : ''}
%     '-s'   : write procedures to collect
%     '-w'   : waitbar
%     '-e'   : include passive electrotonic parameters
%     '->'   : send directly to windows (necessitates -s option)
%
% See also load_tree swc_tree start_trees (neu_tree.hoc)
% Uses root_tree cyl_tree dissect_tree ver_tree D
%
% Output
% ------
% - name::string: name of output file; [] no file was selected -> no output
% - path::sting: path of the file, complete string is therefore: [path name]
%
% Example
% -------
% neuron_tree (sample_tree);
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function [tname path] = neuron_tree (intree, tname, res, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin<1)||isempty(intree),
    intree = length (trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

if (nargin<3)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

% defining a name for the neuron-tree
if (nargin<2)||isempty(tname),
    [tname path] = uiputfile ({'.hoc', 'export to hoc';...
        '.nrn', 'export to nrn'}, 'Save as', 'tree.hoc');
    if tname  == 0,
        tname = [];
        return
    end
else
    path = '';
end
format = tname  (end - 3 : end); % input format from extension:
% extract a sensible name from the filename string:
nstart = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
name   = tname  (nstart (end) + 1 : end - 4);
name1  = tname  (nstart (end) + 1 : end);
if nstart (end) > 0,
    path = [path tname(1 : nstart (end))];
    tname (1 : nstart (end)) = '';
end
name2 = [path 'run_' name '.hoc']; % show file, with '-s' option

tree = root_tree (tree); % add a starting node in root to avoid all starting branch point

if (nargin<3)||isempty(res),
    res = ceil (len_tree (tree)); % {DEFAULT: resolution depends on lenght of segment}
end

ipar  = ipar_tree (tree); % parent index structure (see "ipar_tree")
idpar = ipar (:, 2);      % vector containing index to direct parent
D     = tree.D;           % local diameter values of nodes on tree
N     = size (D, 1);      % number of nodes in tree
if isfield (tree, 'R'),
    R = tree.R;           % region values on nodes in the tree
else
    R = ones (N, 1);      % add a homogeneous regions field of all ones
end
sect  = dissect_tree (tree); % starting and end points of all branches
Rsect = R (sect (:, 2));  % region attribute to sections
uR    = unique (R);       % sorted regions
luR   = length (uR);      % number of regions

if isfield (tree, 'rnames'),
    rnames = tree.rnames (uR);
    for ward = 1 : length (uR),
        rnames {ward} = [name '_' rnames{ward}];
    end
else
    if luR == 1,
        rnames = {name};
    else
        rnames = cell (1, luR);
        for ward = 1 : luR,
            rnames {ward} = [name '_' num2str(uR (ward))];
        end
    end
end

switch format
    case '.nrn' % save file in the NEURON .nrn format
        H1         = histc (R, uR); % histogram of regions
        H1 (R (1)) = H1 (R (1)) - 1;
        [i1 i2]    = sort (R); % i2 : index of sorted regions...
        iR         = ones (N, 1);
        for te = 1 : luR,
            if uR (te) == R (1),
                iR (1 + find (R (2 : N) == uR (te))') = (1 : H1 (te))';
            else
                iR (find (R == uR (te))') = (1 : H1 (te))';
            end
        end
        % file-pointer to the neuron-file
        neuron = fopen ([path tname], 'w');
        % HEADER of the file
        % declaring the regions
        if luR > 1,
            for te = 1 : luR,
                fwrite (neuron, ['create ' name '_' num2str(uR (te)) '[' num2str(H1 (te)) ']', ...
                    char(13), char(10)], 'char');
            end
        else
            fwrite (neuron, ['create ' name '[' num2str(H1 (te)) ']', ...
                char(13), char(10)], 'char');
        end
        % Connections:
        HW = waitbar (0, 'writing connections  ...');
        set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
        fwrite (neuron, ['proc topolneuron() {', char(13), char(10)], 'char');
        o = 0;
        for ward = 3 : N,
            o = o + 1;
            waitbar (ward / N, HW);
            if luR > 1,
                fwrite (neuron, [name '_' num2str(tree.R (idpar (ward))) '['], 'char');
            else
                fwrite (neuron, [name '['], 'char');
            end
            fwrite (neuron, [num2str(iR (idpar (ward)) - 1) '] connect '], 'char');
            if luR>1,
                fwrite (neuron, [name '_' num2str(tree.R (ward)) '['], 'char');
            else
                fwrite (neuron, [name '['], 'char');
            end
            fwrite (neuron, [num2str(iR (ward) - 1) '] (0), 1',  char(13), char(10)], 'char');
            if o == 200,
                o = 0;
                fwrite (neuron, ['topolneuron' num2str(ward) '()', char(13), char(10)], 'char');
                fwrite (neuron, ['}',                            char(13), char(10)], 'char');
                fwrite (neuron, ['proc topolneuron' num2str(ward) '() {', ...
                    char(13), char(10)], 'char');
            end
        end
        close (HW)
        fwrite (neuron, ['}', char(13), char(10)], 'char');
        % Cylinder-Geometry
        fwrite (neuron, ['proc geometry() { local ward',    char(13), char(10)], 'char');
        for te = 1 : luR,
            fwrite (neuron, ['   for ward = 0,' num2str(H1 (te) - 1) ' {',    char(13), char(10)], 'char');
            if luR > 1,
                fwrite (neuron, ['      ' name '_' num2str(uR(te)) '[ward]{', char(13), char(10)], 'char');
            else
                fwrite (neuron, ['      ' name '[ward]{',   char(13), char(10)], 'char');
            end
            fwrite (neuron, ['         pt3dclear()',        char(13), char(10)], 'char');
            fwrite (neuron, ['         nseg = fscan()',     char(13), char(10)], 'char');
            fwrite (neuron, ['         pt3dadd(fscan(),fscan(),fscan(),fscan())', ...
                char(13), char(10)], 'char');
            fwrite (neuron, ['         pt3dadd(fscan(),fscan(),fscan(),fscan())', ...
                char(13), char(10)], 'char');
            if strfind (options, '-e'),
                % passive properties :
                if isfield (tree, 'Ri'),
                    fwrite (neuron, ['         insert pas', char(13), char(10)], 'char');
                    if isfield (tree, 'Ri')
                        fwrite (neuron, ['         Ra = ',    num2str(tree.Ri), ...
                            char(13), char(10)], 'char');
                    end
                    if isfield (tree, 'Gm')
                        fwrite (neuron, ['         g_pas = ', num2str(tree.Gm), ...
                            char(13), char(10)], 'char');
                    end
                    if isfield (tree, 'Cm')
                        fwrite (neuron, ['         cm = ',    num2str(tree.Cm), ...
                            char(13), char(10)], 'char');
                    else
                        fwrite (neuron, ['         cm = 1', char(13), char(10)], 'char');
                    end
                end
                fwrite (neuron, ['         e_pas = 0', char(13), char(10)], 'char');
            end
            fwrite (neuron, ['      }', char(13), char(10)], 'char');
            fwrite (neuron, ['   }',    char(13), char(10)], 'char');
        end
        
        if strfind (options, '-e'),
            % global passive properties if needed:
            fwrite (neuron, ['forall insert pas',                      char(13), char(10)], 'char');
            fwrite (neuron, ['forall Ra = ', num2str(tree.ri),         char(13), char(10)], 'char');
            fwrite (neuron, ['forall g_pas = ', num2str(1 ./ tree.rm), char(13), char(10)], 'char');
            fwrite (neuron, ['forall cm = ',num2str(tree.cm * 1e6),    char(13), char(10)], 'char');
            fwrite (neuron, ['forall e_pas = 0',                       char(13), char(10)], 'char');
        end
        % link to the connections
        fwrite (neuron, ['topolneuron()', char(13), char(10)], 'char');
        % footer
        fwrite (neuron, ['}',             char(13), char(10)], 'char');
        fwrite (neuron, ['geometry()',    char(13), char(10)], 'char');
        % DATA:
        bindex = 1;
        for te = 1 : luR,
            if uR (te) == R (1),
                bindex = bindex + 1;
            end
            HW = waitbar (0, ['writing cylinders of region' num2str(uR (te)) ' ...']);
            set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
            for ward = 1 : H1 (te),
                waitbar (ward / H1 (te), HW);
                fwrite (neuron, [num2str(res (i2 (bindex))), ' ', ...
                    num2str(tree.X (idpar (i2 (bindex)))), ' ', ...
                    num2str(tree.Y (idpar (i2 (bindex)))), ' ', ...
                    num2str(tree.Z (idpar (i2 (bindex)))), ' ', ...
                    num2str(tree.D (i2 (bindex))), ' ', ...
                    num2str(tree.X (i2 (bindex))), ' ', ...
                    num2str(tree.Y (i2 (bindex))), ' ', ...
                    num2str(tree.Z (i2 (bindex))), ' ', ...
                    num2str(tree.D (i2 (bindex))), char(13), char(10)]);
                bindex = bindex + 1;
            end
            close (HW);
        end
        fclose (neuron);
    case '.hoc' % save file in the NEURON .hoc format
        H1 = histc (Rsect, uR); % distribution of section regions in H1
        % file-pointer to the neuron-file
        neuron = fopen ([path tname], 'w');
        % HEADER of the file
        fwrite (neuron, ['/*',                char(13), char(10)], 'char');
        fwrite (neuron, ['This is a CellBuilder-like file written for the simulator NEURON', ...
            char(13), char(10)], 'char');
        fwrite (neuron, ['by an automatic procedure "neuron_tree" part of the TREES package', ...
            char(13), char(10)], 'char');
        fwrite (neuron, ['in MATLAB',         char(13), char(10)], 'char');
        fwrite (neuron, ['copyright 2009 Hermann Cuntz', char(13), char(10)], 'char');
        fwrite (neuron, ['*/',                char(13), char(10)], 'char');
        fwrite (neuron, ['',                  char(13), char(10)], 'char');
        fwrite (neuron, ['proc celldef() {',  char(13), char(10)], 'char');
        fwrite (neuron, ['  topol()',         char(13), char(10)], 'char');
        fwrite (neuron, ['  subsets()',       char(13), char(10)], 'char');
        fwrite (neuron, ['  geom()',          char(13), char(10)], 'char');
        fwrite (neuron, ['  biophys()',       char(13), char(10)], 'char');
        fwrite (neuron, ['  geom_nseg()',     char(13), char(10)], 'char');
        fwrite (neuron, ['}',                 char(13), char(10)], 'char');
        fwrite (neuron, ['',                  char(13), char(10)], 'char');
        % declaring the regions
        for te = 1 : luR,
            fwrite (neuron, ['create ' rnames{te} '[' num2str(H1(te)) ']', ...
                char(13), char(10)], 'char');
        end
        fwrite (neuron, ['', char(13), char(10)], 'char');
        % topology procedure
        fwrite (neuron, ['proc topol_1() {', char(13), char(10)], 'char');
        countero = 1;
        counteri = 1;
        for ward = 1 : size (sect, 1),
            s      = sect (ward, 1); % start compartment of section
            e      = sect (ward, 2); % end compartment of section
            ipsect = find (s == sect (:, 2)); % parent section
            ip     = sect (ipsect, 2); % parent index of section
            if ~isempty(ip),
                ie  = find (ward   == find (Rsect == R (e)));
                ipe = find (ipsect == find (Rsect == R (ip)));
                fwrite (neuron, ['  connect ', ...
                    rnames{find(uR == R (e))}  '[' num2str(ie  - 1) '](0),' ...
                    rnames{find(uR == R (ip))} '[' num2str(ipe - 1) '](1)', ...
                    char(13), char(10)], 'char');
                countero = countero + 1;
                if countero  == 250,
                    countero = 1;
                    counteri = counteri + 1;
                    fwrite (neuron, ['}', char(13), char(10)], 'char');
                    fwrite (neuron, ['proc topol_' num2str(counteri) '() {', ...
                        char(13), char(10)], 'char');
                end
            end
        end
        fwrite (neuron, ['}',                               char(13), char(10)], 'char');
        fwrite (neuron, ['proc topol() {',                  char(13), char(10)], 'char');
        for ward = 1 : counteri,
            fwrite (neuron, ['  topol_' num2str(ward) '()', char(13), char(10)], 'char');
        end
        fwrite (neuron, ['  basic_shape()',                 char(13), char(10)], 'char');
        fwrite (neuron, ['}',                               char(13), char(10)], 'char');
        fwrite (neuron, ['',                                char(13), char(10)], 'char');
        fwrite (neuron, ['proc shape3d_1() {',              char(13), char(10)], 'char');
        countero = 1;
        counteri = 1;
        for ward = 1 : size (sect, 1),
            s = sect (ward, 1); % start compartment of section
            e = sect (ward, 2); % end compartment of section
            ie = find (ward == find (Rsect == R (e)));
            fwrite (neuron, ['  ' rnames{find(uR == R(e))} ...
                '[' num2str(ie - 1) '] {pt3dclear()', char(13), char(10)], 'char');
            indy = fliplr (ipar (e, 1 : find (ipar (e, :) == s)));
            for te = 1 : length (indy),
                fwrite (neuron, ['    pt3dadd(', ...
                    num2str(tree.X (indy (te))),', ', ...
                    num2str(tree.Y (indy (te))),', ', ...
                    num2str(tree.Z (indy (te))),', ', ...
                    num2str(tree.D (indy (te))),')',  char(13), char(10)], 'char');
                countero = countero + 1;
                if countero  == 250,
                    countero = 1;
                    counteri = counteri + 1;
                    fwrite (neuron, ['  }',           char(13), char(10)], 'char');
                    fwrite (neuron, ['}',             char(13), char(10)], 'char');
                    fwrite (neuron, ['proc shape3d_' num2str(counteri) '() {', ...
                        char(13), char(10)], 'char');
                    fwrite (neuron, ['  ' rnames{find(uR == R(e))} ...
                        '[' num2str(ie - 1) '] {', char(13), char(10)], 'char');
                end
            end
            fwrite (neuron, ['  }',              char(13), char(10)], 'char');
        end
        fwrite (neuron, ['}',                    char(13), char(10)], 'char');
        fwrite (neuron, ['proc basic_shape() {', char(13), char(10)], 'char');
        for ward = 1 : counteri,
            fwrite (neuron, ['  shape3d_' num2str(ward) '()', ...
                char(13), char(10)], 'char');
        end
        fwrite (neuron, ['}',                    char(13), char(10)], 'char');
        fwrite (neuron, ['',                     char(13), char(10)], 'char');
        fwrite (neuron, ['objref reg_' name, '_all', ...
            char(13), char(10)], 'char');
        for ward = 1 : luR,
            fwrite (neuron, ['objref reg_' rnames{ward}, ...
                char(13), char(10)], 'char');
        end
        fwrite (neuron, ['proc subsets() { local ward', ...
            char(13), char(10)], 'char');
        fwrite (neuron, ['  reg_' name '_all = new SectionList()', ...
            char(13), char(10)], 'char');
        for ward = 1 : luR,
            fwrite (neuron, ['  reg_' rnames{ward} ' = new SectionList()', ...
                char(13), char(10)], 'char');
            fwrite (neuron, ['  for ward = 0, ' num2str(H1 (ward) - 1) ' ' ...
                rnames{ward} '[ward] {', char(13), char(10)], 'char');
            fwrite (neuron, ['    reg_' rnames{ward} '.append()', char(13), char(10)], 'char');
            fwrite (neuron, ['    reg_', name, '_all.append()',   char(13), char(10)], 'char');
            fwrite (neuron, ['  }',                               char(13), char(10)], 'char');
        end
        fwrite (neuron, ['}',                   char(13), char(10)], 'char');
        fwrite (neuron, ['proc geom() {',       char(13), char(10)], 'char');
        fwrite (neuron, ['}',                   char(13), char(10)], 'char');
        fwrite (neuron, ['proc geom_nseg() {',  char(13), char(10)], 'char');
        fwrite (neuron, ['}',                   char(13), char(10)], 'char');
        fwrite (neuron, ['proc biophys() {',    char(13), char(10)], 'char');
        fwrite (neuron, ['}',                   char(13), char(10)], 'char');
        fwrite (neuron, ['access ' rnames{1} ,  char(13), char(10)], 'char');
        fwrite (neuron, ['celldef()',           char(13), char(10)], 'char');
        fwrite (neuron, ['',                    char(13), char(10)], 'char');
        fwrite (neuron, ['',                    char(13), char(10)], 'char');
        if strfind (options, '-e'),
            fwrite (neuron, ['forsec reg_' name '_all insert pas', ...
                char(13), char(10)], 'char');
            fwrite (neuron, ['forsec reg_' name '_all g_pas = ' ...
                num2str(tree.Gm), char(13), char(10)], 'char');
            fwrite (neuron, ['forsec reg_' name '_all Ra = ' ...
                num2str(tree.Ri), char(13), char(10)], 'char');
            fwrite (neuron, ['forsec reg_' name '_all cm = ' ...
                num2str(tree.Cm), char(13), char(10)], 'char');
            fwrite (neuron, ['forsec reg_' name '_all e_pas = 0', ...
                char(13), char(10)], 'char');
            fwrite (neuron, ['',  char(13), char(10)], 'char');
        end
        fclose (neuron);
    otherwise
        warning ('TREES:IO', 'format unknown');
        return
end

if strfind (options, '-s'),
    % file-pointer to the run-file
    neuron = fopen (name2, 'w');
    fwrite (neuron, ['load_file ("nrngui.hoc")', char(13), char(10)], 'char');
    fwrite (neuron, ['xopen ("' name1 '")',      char(13), char(10)], 'char');
    fclose (neuron);
    if strfind (options, '->')
        if ispc,        % this even calls the file directly (only windows)
            winopen (name2);
        end
    end
end
