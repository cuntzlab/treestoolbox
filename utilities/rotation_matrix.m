% ROTATION_MATRIX   Calculates rotation matrix for given angles.
% (utilities package)
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


if strcmp(hand, 'left') % 'left'

    Rx = [1, 0, 0;
        0, cos(degx), sin(degx);
        0, -sin(degx), cos(degx)];

    Ry = [cos(degy), 0, -sin(degy);
        0, 1, 0;
        sin(degy), 0, cos(degy)];

    Rz = [cos(degz), sin(degz), 0;
        -sin(degz), cos(degz), 0;
        0, 0, 1];

else  % 'right'


    Rx = [1, 0, 0;
        0, cos(degx), -sin(degx);
        0, sin(degx), cos(degx)];

    Ry = [cos(degy), 0, sin(degy);
        0, 1, 0;
        -sin(degy), 0, cos(degy)];

    Rz = [cos(degz), -sin(degz), 0;
        sin(degz), cos(degz), 0;
        0, 0, 1];

end

M = Rz * Ry * Rx;
end

