% GENE_TREE   String describing tree topology.
% (trees package)
% 
% genes = gene_tree (intrees, options)
% ------------------------------------
% 
% Returns for a cell array of cell arrays of trees intrees, a cell array of
% cell arrays of topological genes (for each tree one). The two-depth of
% the input/output arrays allows the comparison between different groups of
% neuronal trees. The topological gene returns for a sorted labelling of a
% tree (see "sort_tree") for all branches (delimited by topological points)
% the ending point type (termination or branch) and the metric length of
% the branch.
%
% Input
% -----
% - intrees  ::2-depth cell array: cell array of cell array of trees
%     {DEFAULT: {trees}}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - genes    ::cell array of cell array of 2 horizontal vectors:
%     topology strings.
%
% Example
% -------
% gene         = gene_tree ({{sample2_tree}}, '-s');
% gene{1}
% % or:
% dLPTCs       = load_tree ('dLPTCs.mtr');
% gene         = gene_tree (dLPTCs, '-s');
%
% See also   BCT_tree isBCT_tree sort_tree
% Uses       sort_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function  genes = gene_tree (intrees, options)

if (nargin < 2) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

genes            = cell (1, 1);
names            = cell (1, 1);
counterG         = 0;
if contains (options, '-w') % waitbar option: initialization
    HW           = waitbar (0, 'sequencing trees...');
    set          (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for counter1                   = 1 : length (intrees)
    for counter2               = 1 : length (intrees{counter1})
        if contains       (options, '-w') % waitbar option: update
            waitbar            (counter2 / length (intrees{counter1}), HW);
        end
        counterG               = counterG + 1;
        name                   = intrees{counter1}{counter2}.name;
        names{counterG}        = name;
        [gene, pathlen]        = getgene (intrees{counter1}{counter2});
        genes{counterG}        = gene;
        if contains       (options, '-s') % show option
            clen               = cumsum (pathlen + 5);
            HL                 = line ( ...
                [[0; (clen (1 : end - 1))], (clen - 5)]', ...
                (counterG - 1 + 2 * (counter1 - 1)) + ...
                zeros (length (clen), 2)');
            set                (HL, ...
                'linewidth',           4);
            HT                 = text ( ...
                -10, ...
                counterG - 1 + 2 * (counter1 - 1), ...
                name);
            set  (HT, ...
                'HorizontalAlignment', 'right');
            for counterHL      = 1 : length (HL)
                if genes{counterG} (counterHL, 2) == 0
                    set    (HL (counterHL), ...
                        'color',       [0 0 0]);
                else
                    set    (HL (counterHL), ...
                        'color',       [0 1 0]);
                end
            end
        end
    end
end
if contains (options,'-w')        % waitbar option: close
    close        (HW);
end

end


%===============================================================================
function [gene, pathlen] = getgene (tree)
% sort tree to be BCT conform, heavy parts left:
tree             = sort_tree   (tree, '-LO');
% vector containing termination and branch point indices:
iBT              = find        (~C_tree (tree));
% parent index structure (see "ipar_tree"):
ipar             = ipar_tree   (tree);
% find index to parent paths only until first branch point:
iparcheck        = zeros (size (ipar));
for counterBT    = 1 : size (iBT, 1)
    iparcheck (ipar == iBT (counterBT)) = 1;
end
iparcheck (:, 1) = 0;
iparcheck        = cumsum      (iparcheck, 2) > 0;
ipar             = ipar .*     (1 - iparcheck); % cutout those paths
% vector containing length values of tree segments [um]:
len0             = [0;         (len_tree (tree))];  
% path length along those paths:
pathlen          = sum         (len0 (ipar + 1), 2);
pathlen          = pathlen     (iBT);
typeN            = typeN_tree  (tree);
% branch and termination point number of daughters:
typer            = typeN       (iBT);
M                = [pathlen typer];
reshape          (M', numel (M), 1);
gene             = M;
end
%===============================================================================