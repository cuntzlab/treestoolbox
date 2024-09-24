% BEZAHLT   Make string from number.
% (scheme package)
%
% str = bezahlt (zahl, num)
% -------------------------
%
% Pads string from number num with zeros to make zahl length string.
%
% Input
% -----
% - zahl     ::integer: number to be stringed
% - num      ::integer: length of string
%
% Output
% ------
% - str      ::string: resulting padded string
%
% Example
% -------
% bezahlt      (4, 12)
%
% See also
% Uses
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function str = bezahlt (zahl, num)

str          = [ ...
    (num2str (zeros (num - length (num2str (zahl)), 1))') ...
    (num2str (zahl))];