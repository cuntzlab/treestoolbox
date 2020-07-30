% POV_PATCH   POV-Ray rendering of a Matlab patch element.
% (trees package)
%
% [name path] = pov_patch (p, name, v, options)
% -------------------------------------------------
%
% writes POV-ray files using the data contained in a patch structure p.
%
% Input
% -----
% - p::structure:patch structure including a vertices and a faces field
% - name::string: name of file including the extension ".pov"
%     {DEFAULT : open gui fileselect} spaces and other weird symbols not
%     allowed!
% - v::vector: values to be color-coded {DEFAULT: none}.
% - options::string: {DEFAULT: '-b -w', because blob much much faster}
%     '-b' : blob, draws a skin around the patch (mesh)
%     '-s' : show, write an extra standard file to display the povray object -
%        filename is same but starts with 'sh'. Options are -s1.. -s6.
%        -s1 : green fluorescence on black {DEFAULT}
%        -s2 : black on sand (add a photoshop canvas texture afterwards)
%        -s3 : black on white (no color mapping either)
%        -s4 : alien
%        -s5 : glass on cork
%        -s6 : red coral and watersurface on z = 0 plane
%     '-w' : waitbar
%     '-v' : adopt viewpoint from currently active axis
%     '-minmax' : normalizes v values between min and max before
%         coloring, else: normalizes v values from zero to max before coloring
%     '->' : send directly to windows (necessitates -s option)
%
% Output
% ------
% - name::string: name of output file; [] no file was selected -> no output
% - path::sting: path of the file, complete string is therefore: [path name]
% - rpot::vector:output is the binned vector used for the coloring
%
% Example
% -------
% p = hull_tree (sample_tree);
% pov_patch (p, [], [], '-w -b -s ->')
%
% See also pov_tree plot_tree x3d_tree swc_tree
% Uses len_tree cyl_tree D
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function [tname path rpot] = pov_patch (p, tname, v, options)

if (nargin<1)||isempty(p),
    error ('forgot the patch?');
end;

% defining a name for the povray-tree
if (nargin<2)||isempty(tname),
    [tname path] = uiputfile ('.pov', 'export to POV-Ray', 'tree.pov');
    if tname  == 0,
        tname = [];
        return
    end
else
    path = '';
end
% extract a sensible name from the filename string:
nstart = unique ([0 strfind(tname, '/') strfind(tname, '\')]);
name = tname (nstart (end) + 1 : end - 4);
if nstart (end) > 0,
    path = [path tname(1 : nstart (end))];
    tname (1 : nstart (end)) = '';
end
name2 = [path name '.dat']; % imaging file, if v not empty or '-c' option
name3 = [path 'sh' name '.pov']; % show file, with '-s' option

if (nargin<3)||isempty(v),
    v = []; % {DEFAULT: no color mapping}
end

if (nargin<4)||isempty(options),
    options = '-b -w'; % {DEFAULT: blobs and waitbar}
end

if isempty (v)
    iflag = 0; % imaging is off, no specified colors.
else
    iflag = 1; % imaging is on, colors specified by v or random (brainbow)
    map    = jet (256);     % colormap, change if necessary
    lenm   = size (map, 1); % number of colormap entries
    povray = fopen (name2, 'w'); % open file
    if size (v, 2) == 3,
        if islogical (v), v = double (v); end
        v = v (len > 0.0001, :);
        colorcode = reshape (v', length (v) * 3, 1);
        rpot = {}; rpot {1} = v;
        fprintf (povray, '%12.8f,\n', colorcode);
    else
        if islogical (v), v = double (v); end
        v = v (len > 0.0001);
        if strfind (options, '-minmax'),
            irange = [min(v) max(v)];
        else
            irange = [0 max(v)];
        end
        v = floor((v - irange (1))./((irange (2) - irange (1)) ./ lenm));
        v (v < 1) = 1; v (v > lenm) = lenm;
        colorcode = map (v, :);
        colorcode = reshape (colorcode', length (v) * 3, 1);
        rpot = {}; rpot {1} = v;
        fprintf (povray, '%12.8f,\n', colorcode);
    end
    fclose (povray); % close file
end

% file-pointer to the povray-file
povray = fopen ([path tname], 'w');
% Writing the cylinders into a povray variable called 'name'
fwrite (povray, ['#declare ' name ' = union{', char(13), char(10)], 'char');

if strfind (options, '-w') % waitbar option: initialization
    HW = waitbar (0, 'writing vertices ...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
if strfind (options, '-b'), % blob option: skin around bodies, faster but sloppier
    fwrite (povray, ['blob { threshold .15', char(13), char(10)], 'char');
end
fwrite (povray, ['mesh2 {', char(13), char(10)], 'char');
fwrite (povray, ['  vertex_vectors {', char(13), char(10)], 'char');
N   = size (p.vertices, 1);
fwrite (povray, ['    ' num2str(N)], 'char');
for ward = 1 : N,
    if strfind (options, '-w') % waitbar option: update
        if mod (ward, 500) == 0,
            waitbar (ward ./ N, HW);
        end
    end
    fwrite (povray, [',', char(13), char(10)], 'char');
    fwrite (povray ,['    <', ...
        num2str(p.vertices (ward, 1)), ',', ...
        num2str(p.vertices (ward, 2)), ',', ...
        num2str(p.vertices (ward, 3)), '>'], 'char');
    if strfind (options, '-b'), % blob option: skin around bodies, faster but sloppier
        fwrite (povray, ', 1', 'char');
    end
    if iflag
        fwrite (povray, [' texture {#read (inning, R) #read (inning, G) #read (inning, B) ', ...
            'pigment {color red R green G blue B}}'], 'char');
    end
    
end
fwrite (povray, ['}', char(13), char(10)], 'char');
if strfind (options, '-w') % waitbar option: close
    close (HW);
end

if strfind (options, '-w') % waitbar option: initialization
    HW = waitbar (0, 'writing faces ...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
fwrite (povray, ['  face_indices {', char(13), char(10)], 'char');
N   = size (p.faces, 1);
fwrite (povray, ['    ' num2str(N)], 'char');
for ward = 1 : N,
    if strfind (options, '-w') % waitbar option: update
        if mod (ward, 500) == 0,
            waitbar (ward ./ N, HW);
        end
    end
    fwrite (povray, [',', char(13), char(10)], 'char');
    fwrite (povray ,['    <', ...
        num2str(p.faces (ward, 1) - 1), ',', ...
        num2str(p.faces (ward, 2) - 1), ',', ...
        num2str(p.faces (ward, 3) - 1), '>'], 'char');
    if strfind (options, '-b'), % blob option: skin around bodies, faster but sloppier
        fwrite (povray, ', 1', 'char');
    end
    if iflag
        fwrite (povray, [' texture {#read (inning, R) #read (inning, G) #read (inning, B) ', ...
            'pigment {color red R green G blue B}}'], 'char');
    end
end
fwrite (povray, ['}', char(13), char(10)], 'char');
if strfind (options, '-w') % waitbar option: close
    close (HW);
end
fwrite (povray, ['}', char(13), char(10)], 'char');
fwrite (povray, ['}', char(13), char(10)], 'char');
if strfind (options, '-b'), % blob option: skin around bodies, faster but sloppier
    fwrite (povray, ['}', char(13), char(10)], 'char');
end
fclose (povray);

%
% if strfind (options, '-s') % show option: extra file
%     a1 = strfind (options, '-s');
%     if length (options) > a1 + 1
%         typ = str2double (options (a1 + 2));
%         if isnan (typ),
%             typ = 1;
%         end
%     else
%         typ = 1;
%     end
%     povray = fopen (name3, 'w');
%     X  = cat (1, X {:}); Y = cat (1, Y {:});
%     dX = abs (max (X) - min (X));
%     mX = min (X)+(max (X) - min (X)) ./ 2;
%     mY = min (Y)+(max (Y) - min (Y)) ./ 2;
%     if strfind (options, '-v'),
%         ax = get (gcf, 'CurrentAxes');
%         if ~isempty (ax),
%             cpos =   get (ax, 'cameraposition');
%             cangle = get (ax, 'cameraviewangle') * 1.3;
%             tpos =   get (ax, 'cameratarget');
%             skyvec = get (ax, 'CameraUpVector');
%             uvec =   [1 0 0];
%             cX = cpos (1); cY = cpos (2); cZ = cpos (3);
%             tX = tpos (1); tY = tpos (2); tZ = tpos (3);
%         else
%              cX = mX; cY = mY; cZ = -dX;
%              tX = mX; tY = mY; tZ = 0; cangle = 65;
%         end
%     else
%        cX = mX; cY = mY; cZ = -dX;
%        tX = mX; tY = mY; tZ = 0; cangle = 65;
%     end
%
%     if iflag
%         fwrite (povray, ['#fopen inning "' name '.dat" read', char(13), char(10)], 'char');
%     end
%     fwrite (povray, ['#include "' name '.pov"', char(13), char(10)], 'char');
%     fwrite (povray, ['#include "colors.inc"', char(13), char(10)], 'char');
%     switch typ
%         case 1
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['background {rgbt <0,0,0,0.75>}', char(13), char(10)], 'char');
%             fwrite (povray, ['camera {', char(13), char(10)], 'char');
%             if strfind (options, '-v'),
%                 fwrite (povray, ['  sky<' num2str(skyvec (1)), ',' , num2str(skyvec (2)), ',' ,...
%                     num2str(skyvec (3)), '>' , char(13), char(10)], 'char');
%                 fwrite (povray, ['  up<' num2str(uvec (1)), ',' , num2str(uvec (2)), ',' ,...
%                     num2str(uvec (3)), '>' , char(13), char(10)], 'char');
%             end
%             fwrite (povray, ['  right x*image_width/image_height', char(13), char(10)], 'char');
%             fwrite (povray, ['  location <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  look_at <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  /*focal_point <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '-150> ', char(13), char(10)], 'char');
%             fwrite (povray, ['  aperture 50 // increase for more focal blur', char(13), char(10)], 'char');
%             fwrite (povray, ['  blur_samples 150*/ // add focal blur if you want', char(13), char(10)], 'char');
%             fwrite (povray, ['  angle ' num2str(cangle), char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fwrite (povray, ['',  char(13), char(10)], 'char');
%             fwrite (povray, ['light_source  { <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '> White fade_distance 500}', char(13), char(10)], 'char');
%             fwrite (povray, ['',  char(13), char(10)], 'char');
%             fwrite (povray, ['/*plane { // uncomment for water surface', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, 50', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{rgbt <1,1,0.9,0.95>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {ambient 0.15 diffuse 1 brilliance 16.0 reflection 0}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {bumps 0.5 scale 120 turbulence .1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, -200', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{rgbt <1,1,0.9,0.95>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {ambient 0.15 diffuse 0.55  brilliance 16.0 reflection 0.5}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {bumps 0.5 scale 60 turbulence .1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} */ ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source {', char(13), char(10)], 'char');
%             fwrite (povray, ['  <0, 0, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  color rgb  <1, 1, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  looks_like {' name, char(13), char(10)], 'char');
%             fwrite (povray, ['    texture {', char(13), char(10)], 'char');
%             fwrite (povray, ['      pigment {rgbft <0.2, 1.0, 0.2, 0.15,0.5>}', char(13), char(10)], 'char');
%             fwrite (povray, ['      finish {ambient 0.8 diffuse 0.6 reflection .28 ior 3 specular 1 roughness .001}', char(13), char(10)], 'char');
%             fwrite (povray, ['    }', char(13), char(10)], 'char');
%             fwrite (povray, ['  }', char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fclose (povray);
%         case 2
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['background {rgbt <0.95,0.85,0.75,0.55>}', char(13), char(10)], 'char');
%             fwrite (povray, ['camera {', char(13), char(10)], 'char');
%             if strfind(options,'-v'),
%                 fwrite (povray, ['  sky<' num2str(skyvec (1)), ',' , num2str(skyvec (2)), ',' ,...
%                     num2str(skyvec (3)), '>' , char(13), char(10)], 'char');
%                 fwrite (povray, ['  up<' num2str(uvec (1)), ',' , num2str(uvec (2)), ',' ,...
%                     num2str(uvec (3)), '>' , char(13), char(10)], 'char');
%             end
%             fwrite (povray, ['  right x*image_width/image_height', char(13), char(10)], 'char');
%             fwrite (povray, ['  location <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  look_at <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  angle ' num2str(cangle), char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source  { <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '> White fade_distance 500}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {    // paper 1', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, 50', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{ color rgbt <.95,.95,0.05,0.7>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {wrinkles 1 scale 0.4}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {diffuse .7 roughness .085 ambient 0.1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {    // paper 2', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, 51', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{ color rgbt <1,0,0,0.85>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {wrinkles 1 scale 100}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {diffuse .7 roughness .085 ambient 0.1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {    // paper 3', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, 52', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{ color rgbt <.5,1,0,.85>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {wrinkles 1 scale 1}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {diffuse .7 roughness .85 ambient 0.1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source {', char(13), char(10)], 'char');
%             fwrite (povray, ['  <0, 0, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  color rgbt  <0, 0, 0, 0.5>', char(13), char(10)], 'char');
%             fwrite (povray, ['  looks_like {' name, char(13), char(10)], 'char');
%             fwrite (povray, ['    normal {wrinkles 1 scale 0.4}', char(13), char(10)], 'char');
%             fwrite (povray, ['    finish {diffuse .7 roughness .085 ambient 0.1}', char(13), char(10)], 'char');
%             fwrite (povray, ['  }', char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fclose (povray);
%         case 3
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['background {rgbt <1,1,1,0>}', char(13), char(10)], 'char');
%             fwrite (povray, ['camera {', char(13), char(10)], 'char');
%             if strfind(options,'-v'),
%                 fwrite (povray, ['  sky<' num2str(skyvec (1)), ',' , num2str(skyvec (2)), ',' ,...
%                     num2str(skyvec (3)), '>' , char(13), char(10)], 'char');
%                 fwrite (povray, ['  up<' num2str(uvec (1)), ',' , num2str(uvec (2)), ',' ,...
%                     num2str(uvec (3)), '>' , char(13), char(10)], 'char');
%             end
%             fwrite (povray, ['  right x*image_width/image_height', char(13), char(10)], 'char');
%             fwrite (povray, ['  location <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  look_at <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  angle ' num2str(cangle), char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source  { <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '>}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source {', char(13), char(10)], 'char');
%             fwrite (povray, ['  <0, 0, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  color rgbt  <0, 0, 0, 0.5>', char(13), char(10)], 'char');
%             fwrite (povray, ['  looks_like {' name '}', char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fclose (povray);
%         case 4
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['background {rgbt <0.05,0.05,0.05,0.75>}', char(13), char(10)], 'char');
%             fwrite (povray, ['camera {', char(13), char(10)], 'char');
%             if strfind(options,'-v'),
%                 fwrite (povray, ['  sky<' num2str(skyvec (1)), ',' , num2str(skyvec (2)), ',' ,...
%                     num2str(skyvec (3)), '>' , char(13), char(10)], 'char');
%                 fwrite (povray, ['  up<' num2str(uvec (1)), ',' , num2str(uvec (2)), ',' ,...
%                     num2str(uvec (3)), '>' , char(13), char(10)], 'char');
%             end
%             fwrite (povray, ['  right x*image_width/image_height', char(13), char(10)], 'char');
%             fwrite (povray, ['  location <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  look_at <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  angle ' num2str(cangle), char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source  { <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '> White fade_distance 500}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, 50', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{rgbt <1,1,0.5,0.75>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {ambient 0.15 diffuse 1 brilliance 16.0 reflection 0}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {bumps 0.5 scale 120 turbulence .1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, -200', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{rgbt <1,1,0.5,0.75>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {ambient 0.15 diffuse 0.55 brilliance 16.0 reflection 0.5}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {bumps 0.5 scale 60 turbulence .1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source {', char(13), char(10)], 'char');
%             fwrite (povray, ['  <0, 0, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  color rgb  <1, 1, 1>', char(13), char(10)], 'char');
%             fwrite (povray, ['  looks_like {' name, char(13), char(10)], 'char');
%             fwrite (povray, ['    hollow interior{media {emission 0}}', char(13), char(10)], 'char');
%             fwrite (povray, ['    pigment{color rgbt <0.5,0,0,0.2>}', char(13), char(10)], 'char');
%             fwrite (povray, ['    normal {wrinkles 1.25 scale 0.35}', char(13), char(10)], 'char');
%             fwrite (povray, ['    finish { reflection 0.75}', char(13), char(10)], 'char');
%             fwrite (povray, ['  }', char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fclose (povray);
%         case 5
%             fwrite (povray, ['#include "textures.inc"', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['camera {', char(13), char(10)], 'char');
%             if strfind(options,'-v'),
%                 fwrite (povray, ['  sky<' num2str(skyvec (1)), ',' , num2str(skyvec (2)), ',' ,...
%                     num2str(skyvec (3)), '>' , char(13), char(10)], 'char');
%                 fwrite (povray, ['  up<' num2str(uvec (1)), ',' , num2str(uvec (2)), ',' ,...
%                     num2str(uvec (3)), '>' , char(13), char(10)], 'char');
%             end
%             fwrite (povray, ['  right x*image_width/image_height', char(13), char(10)], 'char');
%             fwrite (povray, ['  location <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  look_at <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  angle ' num2str(cangle), char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source  { <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '> White fade_distance 500}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, 150', char(13), char(10)], 'char');
%             fwrite (povray, ['  texture {White_Wood scale 5}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source {', char(13), char(10)], 'char');
%             fwrite (povray, ['  <0, 0, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  color rgb  <0, 0, 1>', char(13), char(10)], 'char');
%             fwrite (povray, ['  looks_like {' name, char(13), char(10)], 'char');
%             fwrite (povray, ['    pigment {rgbft <0.2, 0.2, 1, 1,0.7>}', char(13), char(10)], 'char');
%             fwrite (povray, ['    finish {ambient 0.1 diffuse 0.1 reflection .2 ior 1 specular 1 roughness .001}', char(13), char(10)], 'char');
%             fwrite (povray, ['  }', char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fclose (povray);
%         case 6
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['background {rgbt <0.7,0.7,0.7,0.75>}', char(13), char(10)], 'char');
%             fwrite (povray, ['camera {', char(13), char(10)], 'char');
%             if strfind(options,'-v'),
%                 fwrite (povray, ['  sky<' num2str(skyvec (1)), ',' , num2str(skyvec (2)), ',' ,...
%                     num2str(skyvec (3)), '>' , char(13), char(10)], 'char');
%                 fwrite (povray, ['  up<' num2str(uvec (1)), ',' , num2str(uvec (2)), ',' ,...
%                     num2str(uvec (3)), '>' , char(13), char(10)], 'char');
%             end
%             fwrite (povray, ['  right x*image_width/image_height', char(13), char(10)], 'char');
%             fwrite (povray, ['  location <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  look_at <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '>', char(13), char(10)], 'char');
%             fwrite (povray, ['  /*focal_point <' num2str(tX) ',' num2str(tY) ',' num2str(tZ) '-150> ', char(13), char(10)], 'char');
%             fwrite (povray, ['  aperture 50 // increase for more focal blur', char(13), char(10)], 'char');
%             fwrite (povray, ['  blur_samples 150*/ // add focal blur if you want', char(13), char(10)], 'char');
%             fwrite (povray, ['  angle ' num2str(cangle), char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source  { <' num2str(cX) ',' num2str(cY) ',' num2str(cZ) '> White fade_distance 500}', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['plane {    //plane of water at z=0', char(13), char(10)], 'char');
%             fwrite (povray, ['  z, 0', char(13), char(10)], 'char');
%             fwrite (povray, ['  pigment{rgbt <1,1,0.5,0.75>}', char(13), char(10)], 'char');
%             fwrite (povray, ['  finish {ambient 0.15 diffuse 0.55 brilliance 6.0 reflection 0.2}', char(13), char(10)], 'char');
%             fwrite (povray, ['  normal {bumps 0.5 scale 20 turbulence 1}', char(13), char(10)], 'char');
%             fwrite (povray, ['} ', char(13), char(10)], 'char');
%             fwrite (povray, ['', char(13), char(10)], 'char');
%             fwrite (povray, ['light_source {', char(13), char(10)], 'char');
%             fwrite (povray, ['  <0, 0, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  color rgb  <1, 1, 0>', char(13), char(10)], 'char');
%             fwrite (povray, ['  looks_like {' name, char(13), char(10)], 'char');
%             fwrite (povray, ['    hollow interior{ media {emission 0}}', char(13), char(10)], 'char');
%             fwrite (povray, ['    pigment{ color rgbt <0.5,0,0,0.2>}', char(13), char(10)], 'char');
%             fwrite (povray, ['    normal { wrinkles 1.25 scale 0.35}', char(13), char(10)], 'char');
%             fwrite (povray, ['  }', char(13), char(10)], 'char');
%             fwrite (povray, ['}', char(13), char(10)], 'char');
%             fclose (povray);
%     end
%     if strfind (options, '->')
%         if ispc,        % this even calls the file directly (only windows)
%             winopen (name3);
%         end
%     end
% end
