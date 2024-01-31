% BIN_TREE   Binning nodes in a tree.
% (trees package)
% 
% [bi, bins, bh] = bin_tree (intree, v, bins, options)
% ----------------------------------------------------
%
% Subdivides the nodes into bins according to a vector v. This is simply
% the histogram and can be applied for example on x-values, euclidean
% distances (like scholl analysis) or any other values. This is a
% META-FUNCTION and can lead to various applications. Does not use the tree
% at all and can be replaced by: [bh, bi] = histc (v, bins).
%
% Input
% -----
% - intree   ::integer:      index of tree in trees or structured tree
% - v        ::Nx1 vector:   vector to perform the binning on
%     {DEFAULT euclidean distance to root}
% - bins     ::scalar:       number of bins between minimum and maximum
%      or      vector:       bin separators such that 
%                                      bins (1) <= bin #1 < bins (2)
%                                      and 
%                                      bins (2) <= bin #2 < bins (3)
%                                      etc..   {DEFAULT: 10 bins}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT: ''}
%
% Output
% ------
% - bi       ::Nx1 vector:   binning index
%     (0 corresponds to not in any bin)
% - bins     ::vector:       binning attributes
%     (corresponds to input bins, if vector)
% - bh       ::vert vector:  binning histogram
%     (how many segments fall in each bin)
%
% Example
% -------
% bin_tree     (sample_tree, [], [], '-s')
%
% See also   ratio_tree child_tree Pvec_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [bi, bins, bh] = bin_tree (intree, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('v', eucl_tree (intree)) % TODO check the size and type of v
p.addParameter('bins', 10, @isnumeric) % TODO check the size and type of bins
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {'v', 'bins'}, {'s'});
%==============================================================================%

bins = pars.bins;
if numel (bins)  == 1
    bins         =  min (pars.v) : ...
                    (max (pars.v) * 1.0001 - min (pars.v)) / bins : ...
                    max (pars.v) * 1.0001;
end

[bh, bi]         = histc (pars.v, bins);

if pars.s % show option
    clf;
    hold         on;
    plot_tree    (intree, bi);
    title        ('bin index');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
    colorbar;
end

