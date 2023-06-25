% NEURON_TEMPLATE_TREE   Export tree as NEURON file.
% (trees package)
%
% [name, path, minterf, tree] = ...
%                         neuron_template_tree (intree, name, options)
% --------------------------------------------------------------------
%
% Saves a complete tree in the section based neuron '.hoc' format.
% This function saves the resulting neuron as a template (compare with
% neuron_tree)
%
% Inputs
% ------
% - intree   ::integer: index of tree in trees or structured tree
% - name     ::string:  name of file including the extension ".hoc"
%     spaces and other weird symbols not allowed!
%     {DEFAULT : open gui fileselect}
% - options  ::string: {DEFAULT : ''}
%     '-s'   : write procedures to collect
%     '-w'   : waitbar
%     '-e'   : include passive electrotonic parameters
%     '->'   : send directly to windows (necessitates -s option)
%     '-m'   : writes T2N interface matrix in minterf.dat (in the same
%              folder)
%
% See also neuron_tree load_tree swc_tree start_trees (neu_tree.hoc)
% Uses root_tree cyl_tree dissect_tree ver_tree D
%
% Output
% ------
% - name     ::string:  name of output file;
%     [] no file was selected -> no output
% - path     ::sting:   path of the file
%     complete string is therefore: [path name]
% - minterf  ::matrix:  interface matrix with node positions in sections
% - tree     ::tree: tree in TREES format
%
% Example
% -------
% neuron_template_tree (sample_tree);
%
% Heavily modified by Marcel Beining for use with T2N, 2014
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function [tname, path, minterf, tree] = ...
    neuron_template_tree (intree, tname, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end

if (nargin < 3) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

% defining a name for the neuron-tree
if (nargin < 2) || isempty (tname)
    [tname, path] = uiputfile ( ...
        {'.hoc', 'export to hoc'}, ...
        'Save as', ...
        'tree.hoc');
    if tname     == 0
        tname    = [];
        return
    end
else
    path     = '';
end

% extract a sensible name from the filename string:
format       = tname  (end - 3 : end); % input format from extension:
nstart       = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
name         = tname  (nstart (end) + 1 : end - 4);
name1        = tname  (nstart (end) + 1 : end);
if nstart (end) > 0
    path     = [path tname(1 : nstart (end))];
    tname (1 : nstart (end)) = '';
end
name2        = [path 'run_' name '.hoc']; % show file, with '-s' option

if isfield       (intree, 'artificial')
    artflag      = true;
    tree         = intree;
    minterf      = [1 0 0];
else
    artflag      = false;
    ver_tree     (intree); % verify that input is a tree structure
    
    % use full tree for this function
    if ~isstruct (intree)
        tree     = trees{intree};
    else
        tree     = intree;
    end
    if (isfield (tree, 'frustum')) && (tree.frustum == 1)
        isfrustum  = 1;
    else
        isfrustum  = 0;
    end
    % add a starting node in root to avoid all starting branch point:
    tree         = root_tree (tree);
    ipar         = ipar_tree (tree); % parent index structure
    D            = tree.D;           % local diameter values of nodes
    N            = size (D, 1);      % number of nodes in tree
    if isfield  (tree, 'R')
        R        = tree.R;           % region values on nodes in the tree
    else
        R        = ones (N, 1);      % add a homogeneous regions field
    end
    sect         = dissect_tree (tree);  % find separate branches
    len          = len_tree (tree);
    Rsect        = R (sect (:, 2));  % region attribute to sections
    % initializing minterf:
    minterf      = NaN (numel (tree.X) + size (sect, 1) - 1, 3);
    uR           = unique (R);       % sorted regions
    luR          = length (uR);      % number of regions
    if isfield   (tree, 'rnames')
        rnames   = tree.rnames (uR);
        for counterR = 1 : length (uR)
            % delete rnames which have strange characters
            rnames{counterR} = ...
                regexprep (rnames{counterR}, '[^a-zA-Z0-9]','');
        end
    else
        if luR   == 1
            rnames   = {name};
        else
            rnames   = cell (1, luR);
            for counterR = 1 : luR
                rnames{counterR} = num2str (uR (counterR));
            end
        end
    end
end

nextline         = [(char (13)), (char (10))];

if ~strcmp       (format, '.hoc')
    warning      ('TREES:IO',  'format unknown');
    return
end

%%% save file in the NEURON .hoc format

% file-pointer to the neuron-file
neuron           = fopen ([path tname], 'w');
% HEADER of the file
fwrite           (neuron, ['/*'                         nextline], 'char');
fwrite           (neuron, ['This is a CellBuilder-like file ', ...
    'written for the simulator NEURON',                 nextline], 'char');
fwrite           (neuron, ['by an automatic procedure ', ...
    '"neuron_template_tree" part of the TREES package', nextline], 'char');
fwrite           (neuron, ['in MATLAB',                 nextline], 'char');
fwrite           (neuron, ['copyright 2009-2017 ', ...
    'Hermann Cuntz',                                    nextline], 'char');
fwrite           (neuron, ['heavy modifications ', ...
    'by Marcel Beining, 2014',                          nextline], 'char');
fwrite           (neuron, ['*/',                        nextline], 'char');
fwrite           (neuron, ['',                          nextline], 'char');
fwrite           (neuron, ['begintemplate ', name,      nextline], 'char');
fwrite           (neuron, ['',                          nextline], 'char');
if artflag
    fwrite       (neuron, ['public cell',               nextline], 'char');
    fwrite       (neuron, ['public is_artificial',      nextline], 'char');
    fwrite       (neuron, ['objref cell'                nextline], 'char');
    fwrite       (neuron, ['proc celldef() {',          nextline], 'char');
    fwrite       (neuron, [(sprintf ('cell = new %s()', ...
        tree.artificial))                               nextline], 'char');
    fwrite       (neuron, ['is_artificial = 1}',        nextline], 'char');
else
    fwrite       (neuron, ['proc celldef() {',          nextline], 'char');
    fwrite       (neuron, ['  topol()',                 nextline], 'char');
    fwrite       (neuron, ['  subsets()',               nextline], 'char');
    fwrite       (neuron, ['  geom()',                  nextline], 'char');
    fwrite       (neuron, ['  biophys()',               nextline], 'char');
    fwrite       (neuron, ['  geom_nseg()',             nextline], 'char');
    fwrite       (neuron, ['  is_artificial = 0',       nextline], 'char');
    fwrite       (neuron, ['}',                         nextline], 'char');
    fwrite       (neuron, ['',                          nextline], 'char');
    % distribution of section regions:
    H1           = histc (Rsect, uR); 
    % making regions public
    for counterR = 1 : luR
        fwrite   (neuron, ['public ' rnames{counterR},  nextline], 'char');
    end
    fwrite       (neuron, ['',                          nextline], 'char');
    % making sections public
    fwrite       (neuron, ['public allregobj',          nextline], 'char');    
    fwrite       (neuron, ['public allreg',             nextline], 'char');
    fwrite       (neuron, ['public alladendreg',        nextline], 'char');
    fwrite       (neuron, ['public allaxonreg',         nextline], 'char');    
    for counterR = 1 : luR
        fwrite   (neuron, ['public reg', ...
            rnames{counterR},                           nextline], 'char');
    end
    fwrite       (neuron, ['public is_artificial',      nextline], 'char');
    fwrite       (neuron, ['',                          nextline], 'char');
    % declaring the regions
    for counterR = 1 : luR
        fwrite   (neuron, ['create ', rnames{counterR}, ...
            '[' (num2str (H1 (counterR))) ']',          nextline], 'char');
    end
    fwrite       (neuron, ['',                          nextline], 'char');
    % topology procedure
    fwrite       (neuron, ['proc topol_1() {', nextline], 'char');
    countero     = 1;
    counteri     = 1;
    for counter  = 1 : size (sect, 1)
        s        = sect (counter, 1);       % start compartment of section
        e        = sect (counter, 2);       % end compartment of section
        ipsect   = find (s == sect (:, 2)); % parent section
        ip       = sect (ipsect, 2);        % parent index of section
        if ~isempty (ip)
            ie   = find (counter   == find (Rsect == R (e)));
            ipe  = find (ipsect    == find (Rsect == R (ip)));
            fwrite (neuron, ['  connect ', ...
                rnames{(uR == R (e))}, ...
                '[' (num2str (ie  - 1)) '](0),' ...
                rnames{(uR == R (ip))}, ...
                '[' (num2str (ipe - 1)) '](1)',         nextline], 'char');
            countero     = countero + 1;
            if countero  == 250
                countero = 1;
                counteri = counteri + 1;
                fwrite (neuron, ['}',                   nextline], 'char');
                fwrite (neuron, ['proc topol_', ...
                    (num2str (counteri)) '() {',        nextline], 'char');
            end
        end
    end
    fwrite (neuron, ['}',                               nextline], 'char');
    fwrite (neuron, ['proc topol() {',                  nextline], 'char');
    for counter = 1 : counteri
        fwrite (neuron, ['  topol_', ...
            (num2str (counter)), '()',                  nextline], 'char');
    end
    fwrite (neuron, ['  basic_shape()',                 nextline], 'char');
    fwrite (neuron, ['}',                               nextline], 'char');
    fwrite (neuron, ['',                                nextline], 'char');
    fwrite (neuron, ['proc shape3d_1() {',              nextline], 'char');
    countero     = 1;
    counteri     = 1;
    for counter  = 1 : size (sect, 1)
        s        = sect (counter, 1); % start compartment of section
        e        = sect (counter, 2); % end compartment of section
        % the how manyth section with this region is it?
        ie       = find (counter == find (Rsect == R (e)));
        fwrite   (neuron, ['  ', rnames{(uR == R(e))}, ...
            '[', (num2str (ie - 1)), ...
            '] {pt3dclear()',                           nextline], 'char');
        indy     = fliplr (ipar (e, 1 : find (ipar (e, :) == s)));
        seclen   = sum (len (indy (2 : end)));
        D        = tree.D (indy);
        if ~isfrustum || ...
                (~isempty (strfind (rnames {(uR == R (e))}, 'spine')))
            % a (spine) starting segment needs to have the neck
            % diameter, otherwise wrong surface:
            D (1) = D (2);
        end
        for counterP = 1 : length (indy)
            fwrite (neuron, ['    pt3dadd(', ...
                (num2str (tree.X (indy (counterP)), 15)), ', ', ...
                (num2str (tree.Y (indy (counterP)), 15)), ', ', ...
                (num2str (tree.Z (indy (counterP)), 15)), ', ', ...
                (num2str (D (counterP), 15)), ...
                ')',                                    nextline], 'char');
            % sectionref can be assessed with allregobj.o(minterf(x,2) %!%!
            minterf ((counteri - 1) * 249 + countero, :) = [ ...
                (indy (counterP) - 1), ...
                (sum (H1 (1 : find (uR == R (e)) - 1)) + ie-1), ...
                (round (1e+5 * (sum (len (indy (1 : counterP))) - ...
                len (indy (1))) / seclen) * 1e-5)];   
            countero = countero + 1;
            if countero  == 250
                countero = 1;
                counteri = counteri + 1;
                fwrite (neuron, ['  }',                 nextline], 'char');
                fwrite (neuron, ['}',                   nextline], 'char');
                fwrite (neuron, ['proc shape3d_' ...
                    (num2str (counteri)) '() {',        nextline], 'char');
                fwrite (neuron, ['  ' rnames{(uR == R(e))} ...
                    '[' (num2str (ie - 1)) '] {',       nextline], 'char');
            end
        end
        fwrite   (neuron, ['  }',                       nextline], 'char');
    end
    fwrite       (neuron, ['}',                         nextline], 'char');
    fwrite       (neuron, ['proc basic_shape() {',      nextline], 'char');
    for counter = 1 : counteri
        fwrite   (neuron, ['  shape3d_' ...
            (num2str (counter)) '()',                   nextline], 'char');
    end
    fwrite       (neuron, ['}',                         nextline], 'char');
    fwrite       (neuron, ['',                          nextline], 'char');
    fwrite       (neuron, ['objref allreg, allregobj, alladendreg, ', ...
        'allaxonreg, sec',                              nextline], 'char');
    for counterR = 1 : luR
        fwrite   (neuron, ['objref reg', ...
            rnames{counterR},                           nextline], 'char');
    end
    fwrite       (neuron, ['proc subsets() { ', ...
        'local counter',                                nextline], 'char');
    fwrite       (neuron, ['  allregobj   = ', ...
        'new List()',                                   nextline], 'char');
    fwrite       (neuron, ['  allreg      = ', ...
        'new SectionList()',                            nextline], 'char');
    fwrite       (neuron, ['  alladendreg = ', ...
        'new SectionList()',                            nextline], 'char');
    fwrite       (neuron, ['  allaxonreg  = ', ...
        'new SectionList()',                            nextline], 'char');
    for counterR  = 1 : luR
        fwrite   (neuron, ['  reg', rnames{counterR}, ...
            ' = new SectionList()',                     nextline], 'char');
        fwrite   (neuron, ['  for counter = 0, ', ...
            (num2str (H1 (counterR) - 1)), ' ', ...
            rnames{counterR}, '[counter] {',            nextline], 'char');
        fwrite   (neuron, ['    reg', rnames{counterR}, ...
            '.append()',                                nextline], 'char');
        fwrite   (neuron, ['    sec = new SectionRef()',  nextline], 'char');
        fwrite   (neuron, ['    allregobj.append(sec)',   nextline], 'char');
        fwrite   (neuron, ['    allreg.append()',       nextline], 'char');
        if  strfind (rnames{counterR}, 'adend')
            fwrite (neuron, ['    ', ....
                'alladendreg.append()',                 nextline], 'char');
        end
        if  strfind (rnames{counterR}, 'axon')
            fwrite (neuron, ['    allaxonreg.append()', nextline], 'char');
        end
        fwrite   (neuron, ['  }',                       nextline], 'char');
    end
    fwrite       (neuron, ['}',                         nextline], 'char');
    fwrite       (neuron, ['proc geom() {',             nextline], 'char');
    fwrite       (neuron, ['}',                         nextline], 'char');
    fwrite       (neuron, ['proc geom_nseg() {',        nextline], 'char');
    fwrite       (neuron, ['}',                         nextline], 'char');
    fwrite       (neuron, ['proc biophys() {',          nextline], 'char');
    fwrite       (neuron, ['}',                         nextline], 'char');
    fwrite       (neuron, ['access ', rnames{1},        nextline], 'char');
end
fwrite           (neuron, ['proc init() {',             nextline], 'char');
fwrite           (neuron, ['  celldef()',               nextline], 'char');
fwrite           (neuron, ['}',                         nextline], 'char');
fwrite           (neuron, ['',                          nextline], 'char');
fwrite           (neuron, ['endtemplate ', name,        nextline], 'char');
fwrite           (neuron, ['',                          nextline], 'char');
fclose           (neuron);

if strfind       (options, '-s')
    % file-pointer to the run-file
    neuron       = fopen (name2, 'w');
    fwrite       (neuron, ['load_file ("nrngui.hoc")',  nextline], 'char');
    fwrite       (neuron, ['xopen ("', name1, '")',     nextline], 'char');
    fclose       (neuron);
    if strfind   (options, '->')
        if ispc  % this even calls the file directly (only windows)
            winopen (name2);
        end
    end
end

if strfind       (options, '-m')
    neuron       = fopen ( ...
        fullfile (path, sprintf ('%s_minterf.dat', name)), 'w');
    for m        = 1 : size (minterf, 1)
        fwrite   (neuron, [(num2str (minterf (m, :))),  nextline], 'char');
    end
    fclose       (neuron);
    save         (fullfile (path, sprintf ('%s_minterf.mat', name)), ...
        'minterf')
end



