% NEUROML_TREE   Export tree to NeuroML format.
% (trees package)
% 
% [name path] = neuroml_tree (intree, name, options)
% --------------------------------------------------
%
% exports a tree to NeuroML format for use for example 
% MORE...

% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - name::string: name of file including the extension ".xml"
%     {DEFAULT : open gui fileselect}
% - options::string: {DEFAULT '-v2a'}
%     '-w'    : waitbar
%     '-v1l1' : version v1l1
%     '-v2a'  : version v2a
%
% Output
% ------
% - name::string: name of output file; [] no file was selected -> no output
% - path::sting: path of the file, complete string is therefore: [path name]
%
% Example
% -------
% neuroml_tree (sample_tree)
%
% See also load_tree and start_trees
% Uses ver_tree
%
% code by Padraig Gleeson 16 March 2011
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function [tname path] = neuroml_tree (intree, tname, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 2)||isempty(intree),
    intree = length (trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

% defining a name for saved file
if (nargin < 2)||isempty(tname),
    [tname path] = uiputfile ('.xml', 'export to NeuroML', 'tree.xml');
    if tname  == 0,
        tname = [];
        return
    end
else
    path = '';
end
% extract a sensible name from the filename string:
nstart = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
nend   = [length(tname) strfind(tname, '.xml')];
name   = tname (nstart (end) + 1 : nend (end) - 1);

if (nargin < 3)||isempty(options),
    options = '-v2a';
end;

if strfind (options, '-v1l1'),
    nml_ver = 'nml_v1_l1';
else
    nml_ver = 'nml_v2a';
end

D = tree.D;      % local diameter values of nodes on tree
N = size (D, 1); % number of nodes in tree

idpar0 = idpar_tree (tree, '-0'); % vector containing index to direct parent
idpar0 (idpar0 == 0) = -1;

nmlfile = fopen ([path tname], 'w'); % open file

fwrite  (nmlfile, ['<?xml version="1.0" encoding="UTF-8"?>', char(13), char(10)],'char');

nml_v1_l1 = strcmp ('nml_v1_l1', nml_ver);
nml_v2a   = strcmp ('nml_v2a',   nml_ver);
notes_el  = 'meta:notes';

if nml_v1_l1
    fwrite  (nmlfile, ['<neuroml xmlns="http://morphml.org/neuroml/schema" ',        char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    xmlns:meta="http://morphml.org/metadata/schema"',        char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    xmlns:mml="http://morphml.org/morphml/schema"',          char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ', char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    xsi:schemaLocation="http://morphml.org/neuroml/schema ', ...
        'http://www.neuroml.org/NeuroMLValidator/NeuroMLFiles/Schemata/v1.8.1/Level1/NeuroML_Level1_v1.8.1.xsd"', char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    length_units="micrometer">',         char(13), char(10), char(13), char(10)], 'char');
elseif nml_v2a
    notes_el = 'notes';
    fwrite  (nmlfile, ['<neuroml xmlns="http://www.neuroml.org/schema/neuroml2"',    char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',  char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    xsi:schemaLocation="http://www.neuroml.org/schema/neuroml2', ...
        'http://neuroml.svn.sourceforge.net/viewvc/neuroml/DemoVer2.0/lems/Schemas/NeuroML2/NeuroML_v2alpha.xsd"', char(13), char(10)], 'char');
    fwrite  (nmlfile, ['    id="', name,'">',                                        char(13), char(10)], 'char');
end
fwrite      (nmlfile, ['<',notes_el,'>',                                             char(13), char(10)], 'char');
fwrite      (nmlfile, ['  TREES toolbox tree - ' name,                               char(13), char(10)], 'char');
fwrite      (nmlfile, ['  written by an automatic procedure "neuroml_tree" part of the TREES package', char(13), char(10)], 'char');
fwrite      (nmlfile, ['  in MATLAB (Copyright 2009 Hermann Cuntz)',                 char(13), char(10)], 'char');
fwrite      (nmlfile, ['  NeuroML export functionality by Padraig Gleeson',            char(13), char(10)], 'char');
fwrite      (nmlfile, ['  Export version: ', nml_ver,                                  char(13), char(10)], 'char');
fwrite      (nmlfile, ['</', notes_el, '>',                      char(13), char(10), char(13), char(10)], 'char');

if nml_v1_l1
    fwrite  (nmlfile, ['<cells>',                                                    char(13), char(10)],'char');
    fwrite  (nmlfile, ['<cell name="', name, '">',                                 char(13), char(10)],'char');
elseif nml_v2a
    fwrite  (nmlfile, ['<cell id="', name,'">',                                    char(13), char(10)],'char');
end

if nml_v1_l1
    fwrite  (nmlfile, ['  <segments xmlns="http://morphml.org/morphml/schema">',     char(13), char(10)],'char');
elseif nml_v2a
    fwrite  (nmlfile, ['  <morphology id="', name,'_morphology">',                   char(13), char(10)],'char');
end 

if strfind (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'writing tree ...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for ward = 2 : N,
    if strfind (options, '-w'), % waitbar option: update
        waitbar (ward ./ N, HW);
    end
    segid     = ward - 2 ;
    distpoint = ward;
    proxpoint = idpar0 (ward);
    parentid  = idpar0 (ward) -2;
    if (parentid == -1)
        parentid = 0;
    end
    parentinfo = sprintf ('parent = "%i"', parentid);
    if (ward == 2)
        parentinfo = ' ';
    end
    if (nml_v2a && ward~=2)
        parentinfo = sprintf ('>\n      <parent segment = "%i"/', parentid);
    end
    seginfo = sprintf ('    <segment id = "%i" name = "Seg_%i_P%i_to_P%i" %s>', ...
        [segid segid proxpoint distpoint parentinfo]);
    
    fwrite  (nmlfile, [seginfo,                                                      char(13), char(10)],'char');
    
    fprintf (nmlfile,  '      <proximal x = "%12.8f" y = "%12.8f" z = "%12.8f" diameter="%12.8f"/>\n', ...
        [tree.X(proxpoint) tree.Y(proxpoint) tree.Z(proxpoint) tree.D(distpoint)]); % NOTE: dist diameter!!
    fprintf (nmlfile,  '      <distal   x = "%12.8f" y = "%12.8f" z = "%12.8f" diameter="%12.8f"/>\n', ...
        [tree.X(distpoint) tree.Y(distpoint) tree.Z(distpoint) tree.D(distpoint)]);
    fprintf (nmlfile,  '    </segment>\n');
end
if strfind (options, '-w'), % waitbar option: close
    close (HW);
end

if nml_v1_l1
    fwrite  (nmlfile, ['  </segments>',                                              char(13), char(10)],'char');
elseif nml_v2a
    fwrite  (nmlfile, ['  </morphology>',                                            char(13), char(10)],'char');
end 

fwrite      (nmlfile, ['</cell>',                                                    char(13), char(10)],'char');

if nml_v1_l1
    fwrite  (nmlfile, ['</cells>',                                                   char(13), char(10)],'char');
end

fwrite      (nmlfile, [char(13), char(10), '</neuroml>',                             char(13), char(10)],'char');
fclose (nmlfile);



