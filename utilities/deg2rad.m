% DEG2RAD   Transposes from degrees to radians.
% (scheme package)
%
% result = deg2rad (x)
% --------------------
%
% Simple equation: result = mod ((x / 360) * 2 * pi, 2 * pi);
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
% deg2rad      (180)
%
% See also rad2deg
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function result  = deg2rad (x)

result           = mod ((x / 360) * 2 * pi, 2 * pi);