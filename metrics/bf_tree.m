% BF_TREE   Estimates the balancing factor of a tree.
% (trees package)
%
% [bf, k] = bf_tree (inputData, values, options)
% ----------------------------------
%
% Returns the centripetal bias k of a tree, vector of root angles, or cell
% array of trees under the assumption that the root angles follow a
% modified von Mises distribution (see Bird and Cuntz 2019).
%
% Input
% -----
% - inputData   ::integer, vector, or cell array: structured tree, vector of 
%      root angles, or cell array of trees
% - options  ::string:
%     '-dim3'  : three-dimensional distribution (Careful, it used to be '-3d')
%     '-dim2'  : two-dimensional distribution (Careful, it used to be '-2d')
%     {DEFAULT: '-dim3'}
% - Values   ::cell array:  contains parameters relating centripetal bias to
%     balancing factor.
%     {DEFAULT: Values estimated in Bird and Cuntz 2019}
%
% Output
% -------
% - bf       ::scalar: Estimated balancing factor.
% - k        ::scalar: Fitted centripetal bias.
%
% Example
% -------
% bf_tree (sample_tree, '-dim3')
%
% See also rootangle_tree vonMises_tree MST_tree
% Uses vonMises_tree
%
% Contributed by Alexander Bird (modified for TREES)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [bf, k] = bf_tree (inputData, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('dim2', false, @isBinary)
p.addParameter('dim3', true, @isBinary)
p.addParameter('values', [], @iscell)
pars = parseArgs(p, varargin, {'values'}, {'dim2', 'dim3'});
%==============================================================================%

k             = vonMises_tree (inputData, ...
    'dim2', pars.dim2, 'dim3', pars.dim3); % Calculate centripetal bias

if  isempty (pars.values)
    % {DEFAULT: fit from Bird and Cuntz 2019}
    pars.values    = cell (2, 1);
    
    Params.a  = 1.201;
    Params.b  = 4.39;
    Params.c  = 0.2857;
    pars.values{1} = Params;
    
    Params.a  = 0.7331;
    Params.b  = 3.714;
    Params.c  = 0.3331;
    pars.values{2} = Params;
end

if pars.dim2
    Params    = pars.values{1};
    p1        = Params.a;
    p2        = Params.b;
    p3        = Params.c;
else
    Params    = pars.values{2};
    p1        = Params.a;
    p2        = Params.b;
    p3        = Params.c;
end

% Calculate balancing factor from centripetal bias:
bf                = 1 - (1 + (k / p1) ^ (1 / p3)) ^ (-1 / p2);  

if bf < 0 % Remove extreme values
    bf            = 0;
    warning       ('Balancing factor out of usual range')
elseif bf > 1
    bf            = 1;
    warning       ('Balancing factor out of usual range')
end


