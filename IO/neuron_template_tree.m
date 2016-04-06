% NEURON_TEMPLATE_TREE   Export tree as NEURON file.
% (trees package)
%
% [name path] = neuron_template_tree (intree, name, options)
% ------------------------------------------------------
%
% saves a complete tree in the section based neuron '.hoc' format.
% This function saves the resulting neuron as a template (compare with
% neuron_tree)
%
% Inputs
% ------
% - intree::integer:index of tree in trees or structured tree
% - name::string: name of file including the extension ".hoc"
%     {DEFAULT : open gui fileselect} spaces and other weird symbols not
%     allowed!
% - options::string: {DEFAULT : ''}
%     '-s'   : write procedures to collect
%     '-w'   : waitbar
%     '-e'   : include passive electrotonic parameters
%     '->'   : send directly to windows (necessitates -s option)
%
% See also neuron_tree load_tree swc_tree start_trees (neu_tree.hoc)
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
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [tname, path] = neuron_template_tree (intree, tname, options)

% trees : contains the tree structures in the trees package
global       trees

if (nargin < 1) || isempty (intree)
    % {DEFAULT tree: last tree in trees cell array}
    intree   = length (trees);
end;

ver_tree     (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree     = trees {intree};
else
    tree     = intree;
end

if (nargin < 3) || isempty (options)
    options  = ''; % {DEFAULT: no option}
end

% defining a name for the neuron-tree
if (nargin < 2) || isempty (tname)
    [tname, path] = uiputfile ( ...
        {'.hoc', 'export to hoc'}, ...
        'Save as', ...
        'tree.hoc');
    if tname     == 0,
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

% add a starting node in root to avoid all starting branch point:
tree         = root_tree (tree);

ipar         = ipar_tree (tree); % parent index structure (see "ipar_tree")
% idpar        = ipar (:, 2);      % vector containing index to direct parent
D            = tree.D;           % local diameter values of nodes on tree
N            = size (D, 1);      % number of nodes in tree
if isfield  (tree, 'R')
    R        = tree.R;           % region values on nodes in the tree
else
    R        = ones (N, 1);      % add a homogeneous regions field of all ones
end
sect         = dissect_tree (tree);  % find separate branches
Rsect        = R (sect (:, 2));  % region attribute to sections
uR           = unique (R);       % sorted regions
luR          = length (uR);      % number of regions

if isfield   (tree, 'rnames')
    rnames   = tree.rnames (uR);
    for ward = 1 : length (uR)
        rnames {ward} = rnames{ward};
    end
else
    if luR   == 1
        rnames   = {name};
    else
        rnames   = cell (1, luR);
        for ward = 1 : luR
            rnames {ward} = num2str(uR (ward));
        end
    end
end

switch format
    case '.hoc' % save file in the NEURON .hoc format
        H1       = histc (Rsect, uR); % distribution of section regions in H1
        % file-pointer to the neuron-file
        neuron   = fopen ([path tname], 'w');
        % HEADER of the file
        fwrite   (neuron, ['/*', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, [ ...
            'This is a CellBuilder-like file', ...
            'written for the simulator NEURON', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, [ ...
            'by an automatic procedure "neuron_tree" ', ...
            'part of the TREES package', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['in MATLAB', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['copyright 2009 Hermann Cuntz', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['*/', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['begintemplate ', name, ...
            char(13), char(10)], 'char');        
        fwrite   (neuron, ['', ...
            char(13), char(10)], 'char');           
        fwrite   (neuron, ['proc celldef() {', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['  topol()', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['  subsets()', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['  geom()', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['  biophys()', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['  geom_nseg()', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['}', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['', ...
            char(13), char(10)], 'char');           
            
        % making regions public
        for te       = 1 : luR
            fwrite   (neuron, ['public ' rnames{te}, ...
                char(13), char(10)], 'char');
        end
        fwrite   (neuron, ['', ...
            char(13), char(10)], 'char');  
        
        % making sections public
        fwrite   (neuron, ['public allreg', ...
            char(13), char(10)], 'char');
        fwrite   (neuron, ['public alladendreg', ...
            char(13), char(10)], 'char');
        for ward     = 1 : luR,
            fwrite   (neuron, ['public reg', rnames{ward}, ...
                char(13), char(10)], 'char');
        end
        fwrite   (neuron, ['', char(13), char(10)], 'char'); 
        
        % declaring the regions
        for te = 1 : luR
            fwrite (neuron, ['create ' rnames{te} '[' num2str(H1(te)) ']', ...
                char(13), char(10)], 'char');
        end
        fwrite (neuron, ['', char(13), char(10)], 'char');
        % topology procedure
        fwrite (neuron, ['proc topol_1() {', char(13), char(10)], 'char');
        countero = 1;
        counteri = 1;
        for ward = 1 : size (sect, 1)
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
        for ward = 1 : counteri
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
        fwrite (neuron, ['objref allreg', ...
            char(13), char(10)], 'char');
        fwrite (neuron, ['objref alladendreg', ...
            char(13), char(10)], 'char');        
        for ward = 1 : luR,
            fwrite (neuron, ['objref reg' rnames{ward}, ...
                char(13), char(10)], 'char');
        end
        fwrite (neuron, ['proc subsets() { local ward', ...
            char(13), char(10)], 'char');
        fwrite (neuron, ['  allreg = new SectionList()', ...
            char(13), char(10)], 'char');
        fwrite (neuron, ['  alladendreg = new SectionList()', ...
            char(13), char(10)], 'char');        
        for ward = 1 : luR,
            fwrite (neuron, ['  reg' rnames{ward} ' = new SectionList()', ...
                char(13), char(10)], 'char');
            fwrite (neuron, ['  for ward = 0, ' num2str(H1 (ward) - 1) ' ' ...
                rnames{ward} '[ward] {', char(13), char(10)], 'char');
            fwrite (neuron, ['    reg' rnames{ward} '.append()', char(13), char(10)], 'char');
            fwrite (neuron, ['    allreg.append()',   char(13), char(10)], 'char');
            if  strfind (rnames{ward}, 'adend')
                fwrite (neuron, ['    alladendreg.append()',   char(13), char(10)], 'char');
            end
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
        fwrite (neuron, ['proc init() {',       char(13), char(10)], 'char');
        fwrite (neuron, ['  celldef()',         char(13), char(10)], 'char');
        fwrite (neuron, ['}',                   char(13), char(10)], 'char');
        fwrite (neuron, ['',                    char(13), char(10)], 'char');
        fwrite (neuron, ['endtemplate ', name, char(13), char(10)], 'char');        
        fwrite (neuron, ['', char(13), char(10)], 'char');           
        fclose (neuron);
    otherwise
        warning ('TREES:IO', 'format unknown');
        return
end

if strfind   (options, '-s')
    % file-pointer to the run-file
    neuron   = fopen (name2, 'w');
    fwrite   (neuron, ['load_file ("nrngui.hoc")', ...
        char(13), char(10)], 'char');
    fwrite   (neuron, ['xopen ("' name1 '")', ...
        char(13), char(10)], 'char');
    fclose   (neuron);
    if strfind (options, '->')
        if ispc % this even calls the file directly (only windows)
            winopen (name2);
        end
    end
end
