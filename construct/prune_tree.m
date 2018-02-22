% PRUNE_TREE   Prunes short branches.
% (trees package)
%
% tree = prune_tree (intree, radius, region, options)
% -------------------------------------------
%
% Cleans tree of terminating segment smaller than radius. If two sub
% branches are smaller, than the shorter one is deleted first
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - radius::value: max. length of terminating segments that are pruned
%                 {DEFAULT: 10 um}
% - options::string: {DEFAULT '-w'}
%     '-s' : show
%     '-w' : waitbar
%
% Output
% ------
% if no output is declared the trees are added in trees
% - tree:: structured output tree
%
% Example
% -------
% prune_tree (sample_tree, 10, '-s')
%
% contributed function by Marcel Beining, 2017
%
% See also restrain_tree, delete_tree, clean_tree
% Uses idpar_tree ver_tree dissect_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function [pruned_tree,count,delind] = prune_tree (intree, radius, region, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree)
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array}
end
ver_tree (intree); % verify that input is a tree structure

if (nargin<2)||isempty(radius)
    radius = 10;
end
if nargin < 3 || isempty(region)
    region = unique(intree.R); % all regions of tree
end
if size(region,1) > size(region,2)
    region = region';
end
if (nargin<4)||isempty(options)
    options = '-w';
end

tree=intree;

typeN = (ones (1, size (tree.dA, 1)) * tree.dA)';  % 0 = TP, 1 = CP, 2 = BP
count = 0 ;
delind = [];  %indices of dendrites to delete
    Segs = dissect_tree(tree,'-r');
    PL = Pvec_tree(tree);
    ipar = ipar_tree(tree);
    Segs(~any(repmat(tree.R(Segs(:,2)),1,numel(region)) == repmat(region,size(Segs,1),1),2),:) = [];  % delete all segments that are not in regions to be pruned
    while 1
        tsegs = find(typeN(Segs(:,2))==0 & typeN(Segs(:,1))==2); % get indices of all terminal segments
        [len, ind] = min(PL(Segs(tsegs,2))-PL(Segs(tsegs,1))); % find smallest terminal segment
        if len <= radius
            thisBP = Segs(tsegs(ind),1);
            delind = cat(2,delind,ipar(Segs(tsegs(ind),2),1:find(ipar(Segs(tsegs(ind),2),:)==thisBP)-1));  % remember this terminal segment for deletion (without BP)
            count = count + 1;
            % this part now handles the virtual deletion of the branch
            ind2 = setdiff(find(Segs(:,1)==thisBP),tsegs(ind)); % find the other subbranch
            Segs(Segs(:,2)==thisBP,2) = Segs(ind2,2); % put that subbranch segment together with its parent segment
            Segs([ind2,tsegs(ind)],:) = [];  % delete original subbranch entry and the "deleted branch"
            typeN(thisBP) = typeN(thisBP) -1;  % the BP is now a CP
        else
            break
        end
    end
    if count > 0
        if ~isempty(regexp (options, '-s','ONCE'))
            pruned_tree = delete_tree(tree,delind,'-r-s');
        else
            pruned_tree = delete_tree(tree,delind,'-r');
        end
    else
        pruned_tree = tree;
    end

if (nargout == 0) && ~(isstruct(intree))
    trees {intree} = tree; % otherwise the orginal tree in trees is replaced
end

