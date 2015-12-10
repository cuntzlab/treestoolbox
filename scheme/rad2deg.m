% RAD2DEG   Transposes from radians to degrees.
% (scheme package)
%
% result = rad2deg (x)
% --------------------
%
% Simple equation: result = mod ((x / (2 * pi)) * 360, 360)
%
% Input
% -----
% - x        ::vector: vector of values in radian
%
% Output
% ------
% - result   ::vector: vector of values in degrees
%
% Example
% -------
% rad2deg      (pi)
%
% See also deg2rad
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function result  = rad2deg (x)

result           = mod ((x / (2 * pi)) * 360, 360);