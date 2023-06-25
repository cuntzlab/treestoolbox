% BF_TREE   Estimates the balancing factor of a tree.
% (trees package)
%
% [bf, k] = bf_tree (input, options)
% ----------------------------------
%
% Returns the centripetal bias k of a tree, vector of root angles, or cell
% array of trees under the assumption that the root angles follow a
% modified von Mises distribution (see Bird and Cuntz 2019).
%
% Input
% -----
% - input   ::integer, vector, or cell array:  index of tree in trees or
%     structured tree, vector of root angles, or cell array of trees
% - options  ::string:
%     '-3d'  : three-dimensional distribution
%     '-2d'  : two-dimensional distribution
%     {DEFAULT: '-3d'}
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
% bf_tree (sample_tree, '-3d')
%
% See also rootangle_tree vonMises_tree MST_tree
% Uses vonMises_tree
%
% Contributed by Alexander Bird (modified for TREES)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [bf, k] = bf_tree (input, options, Values)

if (nargin < 2) || isempty (options)
    % {DEFAULT: three dimensional}
    options   = '-3d';
end

k             = vonMises_tree (input, options); % Calculate centripetal bias

if (nargin < 3) || isempty (Values)
    % {DEFAULT: fit from Bird and Cuntz 2019}
    Values    = cell (2, 1);
    
    Params.a  = 1.201;
    Params.b  = 4.39;
    Params.c  = 0.2857;
    Values{1} = Params;
    
    Params.a  = 0.7331;
    Params.b  = 3.714;
    Params.c  = 0.3331;
    Values{2} = Params;
end

if contains (options, '-2d')
    Params    = Values{1};
    p1        = Params.a;
    p2        = Params.b;
    p3        = Params.c;
else
    Params    = Values{2};
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


