% ROTATION_MATRIX   Calculates rotation matrix for given angles.
% (scheme package)
%
% M = rotation_matrix (degx, degy, degz, hand)
% --------------------------------------------
%
% Treats the different rotations in order x then y then z. In other words
% it's the rotation_matrix R = Rz*Ry*Rx. Degrees of rotation are given in
% radians.
%
% Input
% -----
% - degx, degy, degz ::values: degrees of rotation (in radian)
% - hand             ::string 'right|left': for right/left-handed system
%     {DEFAULT: 'right'}
%
% Output
% ------
% - M        ::matrix 3x3: rotation matrix
%
% Example
% -------
% rotation_matrix (pi/2, 0, 0)
%
% See also
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function M   = rotation_matrix (degx, degy, degz, hand)

if (nargin < 4) || isempty (hand)
    hand     = 'right';
end

if strcmp    (hand, 'left')
    M        = -1 .* [ ...
        (cos  (degy) * cos (degz)) ...
        (sin  (degx) * sin (degy) * cos (degz) - cos (degx) * sin (degz))  ...
        (cos  (degx) * sin (degy) * cos (degz) + sin (degx) * sin (degz)); ...
        (cos  (degy) * sin (degz)) ...
        (sin  (degx) * sin (degy) * sin (degz) + cos (degx) * cos (degz))  ...
        (cos  (degx) * sin (degy) * sin (degz) - sin (degx) * cos (degz)); ...
        (-sin (degy)) ...
        (sin  (degx) * cos (degy)) ...
        (cos  (degx) * cos (degy))];
else
    M        = [ ...
        (cos  (degy) * cos (degz)) ...
        (sin  (degx) * sin (degy) * cos (degz) - cos (degx) * sin (degz))  ...
        (cos  (degx) * sin (degy) * cos (degz) + sin (degx) * sin (degz)); ...
        (cos  (degy) * sin (degz)) ...
        (sin  (degx) * sin (degy) * sin (degz) + cos (degx) * cos (degz))  ...
        (cos  (degx) * sin (degy) * sin (degz) - sin (degx) * cos (degz)); ...
        (-sin (degy)) ...
        (sin  (degx) * cos (degy)) ...
        (cos  (degx) * cos (degy))];
end



