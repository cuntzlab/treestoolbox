% VONMISES_TREE   Estimates centripetal bias k of a tree.
% (trees package)
%
% k = vonMises_tree (input, options)
% ----------------------------------
%
% Returns the centripetal bias k of a tree, vector of root angles, or cell
% array of trees under the assumption that the root angles follow a
% modified von Mises distribution (see Bird and Cuntz 2019).
%
% Input
% -----
% - input    ::integer, vector, or cell array:  index of tree in trees or
%     structured tree, vector of root angles, or cell array of trees
% - options  ::string:
%     '-3d'  : three-dimensional distribution (Careful, it used to be '-3d')
%     '-2d'  : two-dimensional distribution (Careful, it used to be '-2d')
%     '-s'   : show
%     {DEFAULT: '-dim3'}
%
% Output
% -------
% - k        ::scalar: Fitted centripetal bias.
% - gof      ::structure Goodness-of-fit info (Matlab standard).
%
% Example
% -------
% vonMises_tree (sample_tree, '-dim3 -s')
%
% See also rootangle_tree
% Uses rootangle_tree ver_tree
%
% Requires: Curve fitting toolbox
%
% Contributed by Alexander Bird (modified for TREES)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [k, gof] = vonMises_tree (inputData, varargin)

%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('dim2', false, @isBinary)
p.addParameter('dim3', true, @isBinary)
p.addParameter('s', false, @isBinary)
pars = parseArgs(p, varargin, {}, {'dim2', 'dim3', 's'});
%==============================================================================%


%==========================================================================
%==========================================================================
% Get rootangles (if necessary)
%==========================================================================
%==========================================================================
if isstruct (inputData)                % Input is a tree structure
    intree       = inputData;
    ver_tree     (intree);         % verify that input is a tree structure
    rootangle    = rootangle_tree (intree);
elseif iscell (inputData)              % Input is cell array of trees
    nTree        = length (inputData); % Number of trees in cell array
    rootangle    = [];
    for iTree    = 1 : nTree
        intree   = inputData{iTree};
        % verify that input contains tree structures:
        ver_tree (intree);
        irootangle = rootangle_tree (intree);
        % Collate individual rootangle distributions:
        rootangle  = [rootangle ; irootangle];
    end
elseif isnumeric (inputData) % Input is a vector of root angles
    if ...
            ((min (inputData (:))) >= 0) && ...
            ((max (inputData (:))) <= pi) && ...
            (isreal (inputData)) % Check all root angles are allowed
        rootangle = inputData;
    else
        error    ('Input contains invalid rootangles')
    end
else
    error        ('Input of invalid type')
end

%==========================================================================
%==========================================================================
% Collate root angles into a distribution and fit
%==========================================================================
%==========================================================================
AngV             = linspace (0, pi, 25);
pdf              = histcounts (rootangle, AngV);
mAngV            = (AngV (2 : 25) + AngV (1 : 24)) / 2; % Get midpoints
pdf              = pdf / trapz (mAngV, pdf); % Normalise
[xData, yData]   = prepareCurveData (mAngV, pdf);
if     pars.dim2
    ft           = fittype ( ...
        'exp(k*cos(x))/(pi*besseli(0,k))', ...
        'independent', 'x', ...
        'dependent',   'y' );
elseif pars.dim3
    ft           = fittype ( ...
        'k*sin(x).*exp(k*cos(x))/(2*sinh(k))', ...
        'independent', 'x', ...
        'dependent',   'y' );
else
    error        ('Options invalid')
end
opts             = fitoptions ('Method', 'NonlinearLeastSquares');
opts.Display     = 'Off';
opts.StartPoint  = 2;
[fitresult, gof] = fit (xData, yData, ft, opts);
k                = fitresult.k;

if pars.s % Show root angle distribution and best fit
    clf;
    hold         on;
    plot         (mAngV, pdf, 'black'); % True distribution
    AngVr        = linspace (0, pi, 1000);
    if pars.dim2
        vMpdf    = exp (k * cos (AngVr)) / (pi * besseli (0, k));
    elseif pars.dim3
        vMpdf    = k * sin (AngVr) .* exp (k * cos (AngVr)) / (2 * sinh (k));
    end
    plot         (AngVr, vMpdf, 'red'); % True distribution
    legend       ('Root angles', 'Best fit');
    xlabel       ('Angle');
    ylabel       ('Density');
    xlim         ([0 pi]);
end

