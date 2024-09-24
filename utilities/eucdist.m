% EUCDIST   2D Euclidean distances between two sets of points.
% (utilities package)
%
% M = eucdist (X1, X2, Y1, Y2)
% ----------------------------
%
% Calculates a distance matrix M between two sets of points described by
% their x and y coordinates.
%
% Input
% -----
% - X1 ::N1x1 vector: x-coordinates of first set of points
% - X2 ::N2x1 vector: x-coordinates of second set of points
% - Y1 ::N1x1 vector: y-coordinates of first set of points
% - Y2 ::N2x1 vector: y-coordinates of second set of points
%
% Output
% ------
% - M ::N1xN2 matrix: matrix containing Euclidean distance values
%
% Example
% -------
% X = rand (4, 1); Y = rand (4, 1); M = eucdist (X, X, Y, Y)
%
% See also 
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function M   = eucdist (X1, X2, Y1, Y2)

M            = sqrt ( ...
    (repmat (X1, 1, length (X2)) - repmat (X2', length (X1), 1)).^2 + ...
    (repmat (Y1, 1, length (Y2)) - repmat (Y2', length (Y1), 1)).^2);
