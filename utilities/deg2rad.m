% DEG2RAD   Transposes from degrees to radians.
% (utilities package)
%
% result = deg2rad (x)
% --------------------
%
% Simple equation: result = mod ((x / 360) * 2 * pi, 2 * pi);
%
% Input
% -----
% - x        ::vector: vector of values in degrees
%
% Output
% ------
% - result   ::vector: vector of values in radians
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