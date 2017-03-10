% ISBCT_TREE   Checks if tree is sorted to be BCT conform.
% (trees package)
% 
% isBCT = isBCT_tree (intree)
% ---------------------------
%
% checks if a tree (or a BCT vector of terminals (0), continuations (1) and
% branches (2)) is conform to BCT order.
% NOTE! does not always work (doesn't check for trifurcations...)
%
% Input
% -----
% - intree   ::if it is a horizontal vector it is treated as a BCT string
%     containing (0|1|2)*, otherwise
%     index of tree in trees structure or structured tree
%
% Output
% ------
% - isBCT    ::bin: true (BCT) or false
%
% Example
% -------
% isBCT_tree ([1 1 1 1])   % no termination so is not BCT
% isBCT_tree ([1 1 1 1 0]) % termination and it becomes BCT
%
% See also BCT_tree allBCT_tree typeN_tree
% Uses BCT_tree dA
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function isBCT = isBCT_tree (intree)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1) || isempty (intree)
    intree   = length (trees);
end;

if ~isstruct (intree)
    if numel (intree) >= 1
        BCT  = intree;
    else
        BCT  = sum (trees (intree).dA);
    end
else
    BCT      = sum (intree.dA);
end

len          = length (BCT);
C            = cumsum (BCT - 1) + 1;
iF           = find (C == 0);
isBCT        = 1;
if isempty   (iF)
    isBCT    = 0;
else
    if iF (1) < len
        isBCT = 0;
    end    
end


