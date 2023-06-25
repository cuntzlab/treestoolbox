% FITD_STACK   get cylinder diameter values from image stack.
% (trees package)
%
% D = fitD_stack (intree, stack, maxR, options)
% ---------------------------------------------
%
% Attempts to derive diameter values for tree intree based on the
% underlying image stack stack. maxR determines a threshold maximum radius
% for a segment in the tree (should be much larger than the maximum radius,
% but not too large...).
%
% the stack structure as in "save_stack":
% stack has to be in the following form:
% stack.M     ::cell-array of 3D-matrices: n tiled image stacks containing
%    fluorescent image
% stack.sM    ::cell-array of string, 1xn: names of individual stacks
% stack.coord ::matrix nx3: x, y, z coordinates of starting points of each
%    stack
% stack.voxel ::vector 1x3: xyz size of a voxel
%
% Input
% -----
% - intree    ::integer: index of tree in trees or structured tree
% - stack     ::struct:  image stacks in structure form (see above)
% - maxR      ::value:   threshold radius
%     {DEFAULT: 30}
% - options   ::string:  
%     '-m'    : demo movie
%     '-w'    : waitbar
%     {DEFAULT: '-w'}
%
% Output
% ------
% - D         ::Nx1 vector: diameter values on tree inferred from the stack
%
% Example
% -------
%
%
% See also quaddiameter_tree quadfit_tree cgui_tree load_stack
%
% written by Friedrich Forstner 2008
% adpated for TREES toolbox by Hermann Cuntz
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2017  Hermann Cuntz

function D   = fitD_stack (intree, stack, maxR, options)

if (nargin < 3) || isempty (maxR)
    maxR     = 30;
end
if (nargin < 4) || isempty (options)
    options  = '-w';
end

m                = length (stack.M);
mM               = cell (1, m);
xr               = cell (1, m);
yr               = cell (1, m);
zr               = cell (1, m);
for counter      = 1 : m
    mM{counter}  = max (stack.M{counter}, [], 3);
    x0           = stack.coord (counter, 1);
    dx           = stack.voxel (1);
    Sx           = size        (stack.M{counter}, 1);
    % x coordinates of active image stack:
    xr{counter}  = dx / 2 +    (x0 : dx : x0 + (Sx - 1) * dx)';
    y0           = stack.coord (counter, 2);
    dy           = stack.voxel (2);
    Sy           = size        (stack.M{counter}, 2);
    % y coordinates of active image stack:
    yr{counter}  = dy / 2 +    (y0 : dy : y0 + (Sy - 1) * dy)';
    z0           = stack.coord (counter, 3);
    dz           = stack.voxel (3);
    Sz           = size        (stack.M{counter}, 3);
    % z coordinates of active image stack:
    zr{counter}  = dz / 2 +    (z0 : dz : z0 + (Sz - 1) * dz)';
end
[X1, X2, Y1, Y2] = cyl_tree (intree);
N                = length (X1);
D                = ones   (N, 1);
if strfind       (options, '-m')       % cutest animation ever
    F            = figure;
end
if strfind       (options, '-w')       % waitbar option: initialization
    HW           = waitbar (0, 'friedrich diametering...');
    set          (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for counter      = 1 : N
    if strfind   (options, '-w')         % waitbar option: update
        waitbar  (counter / N, HW);
    end
    
    % find closest stack
    dist         = zeros (m, 1);
    for te       = 1 : m
        dist (te) = min ( ...
            (xr{te} - X1 (counter)).^2 + ...
            (yr{te} - Y1 (counter)).^2 + ...
            (xr{te} - X2 (counter)).^2 + ...
            (yr{te} - Y2 (counter)).^2);
    end
    [~, i2]      = min (dist);
    inputImage   = mM{i2};
    
    % readjust coordinates relative to stack:
    P1           = [ ...
        ((X1 (counter) - stack.coord (i2, 1) + stack.voxel (1) / 2) / ...
        stack.voxel (1)) ...
        ((Y1 (counter) - stack.coord (i2, 2) + stack.voxel (2) / 2) / ...
        stack.voxel (2))];
    P2           = [ ...
        ((X2 (counter) - stack.coord (i2, 1) + stack.voxel (1) / 2) / ...
        stack.voxel (1)) ...
        ((Y2 (counter) - stack.coord (i2, 2) + stack.voxel (2) / 2) / ...
        stack.voxel (2))];
    
    % create direction vector
    cV           = P2 - P1;
    
    if ~(sum (P2 == P1) == 2)
        % create sampling steps in the direction of the direction vector
        % TODO, CRITICAL: RIGHT NOW ONLY THE TERMINAL POINT IS TAKEN
        mPX          = [(P1 (1) + cV (1)) (P1 (1) + cV (1)) (P2 (1))];
        mPY          = [(P1 (2) + cV (2)) (P1 (2) + cV (2)) (P2 (2))];
        
        % calculate orthonomal, by [-b;a]] and normalize it
        nV           = [(-cV (2)); (cV (1))] / norm (cV);
        
        % ---- orthonormalMatrix ----
        % orthoMem = [orthoStore; cV', nV'];
        % create sampling that is setup by direction vector and it's normal
        % vector
        % start with the vectors:
        nSVX         = nV (1) .* (-maxR : maxR)';
        nSVY         = nV (2) .* (-maxR : maxR)';
        
        % create sampling grid
        vectorGridY  = ...
            repmat (mPX, 2 * maxR + 1, 1) + ...
            repmat (nSVX, 1, 3);
        vectorGridX  = ...
            repmat (mPY, 2 * maxR + 1, 1) + ...
            repmat (nSVY, 1, 3);
        
        % sample from the input image
        imageExtract = interp2 ( ...
            inputImage, ...
            vectorGridY, ...
            vectorGridX, 'nearest');
        % get mean signal of the image extract
        meanExtract  = mean (imageExtract');
        % calculate the index of the maximum in the mean function, in the
        % middle of the signal
        [~, i_max]   = max  (meanExtract (maxR : maxR + maxR / 2));
        i_max        = i_max + maxR;
        
        % derivative of gauss, mean 0, std 3:
        G            = gauss (-maxR : maxR, 0, 3);
        dG           = diff  (G);
        
        % convolution with the mean signal and the gauss derivative to get
        % sharper edges
        CV           = convn (meanExtract, dG, 'same');
        % 1. derivate of this convolution and extract positive values
        % to get the turning points
        % MODIFICATION of the value after the relational operator defines
        % the selectivity
        dCV          = diff (CV);
        q            = find (dCV > 0.1)        -  i_max;
        m_1          = max  (q (find (q < 0))) +  i_max;
        m_2          = min  (q (find (q > 0))) + (i_max - 1);
        % extract diameter:
        d            = (m_2 - m_1);
        if isempty   (d)
            d        = 1;
        end
        D (counter)  = d;
    else
        D (counter)  = 1;
    end
    if strfind   (options, '-m') % cutest animation ever
        figure   (F);
        clf;
        colormap gray;
        imagesc  (inputImage); 
        HL       = line ( ...
            [(P1 (1)) (P2 (1))], ...
            [(P1 (2)) (P2 (2))]);
        set      (HL, ...
            'color',           [1 0 0], ...
            'linewidth',       D (counter));
        drawnow;
        pause    (0.01);
    end
end
if strfind       (options, '-w') % waitbar option: close
    close        (HW);
end

if strfind       (options, '-m') % cutest animation ever
    close        (F)
end
