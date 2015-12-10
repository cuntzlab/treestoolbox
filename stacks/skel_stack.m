% SKEL_STACK   Skeletonize a 3D image matrix.
% (trees package)
%
% [i1 i2 i3] = skel_stack (iM, thr, options)
% ------------------------------------------
%
% Inspired by algorithms described by Palagyi and Kuba. Nice piece of
% code, hopefully correctly interpreted from their papers. It involves
% numerous permutations of indices and logical operators on a
% 26-neighbourhood.
%
% Input
% -----
% - iM       ::matrix: contains brightness levels
% - thr      ::value:  threshold value
%     {DEFAULT: so that it starts with 30000 points}
% - options  ::string:
%     '-m'   : demo movie
%     '-c'   : closes stack with small window
%     '-w'   : waitbar
%     {DEFAULT: '-s'}
%
% Output
% ------
% - i1, i2, i3:: :coordinates within the stack of remaining points.
%
% Example
% -------
% skel_stack   ([], [], '-m -c')
% % compare without stack closing:
% skel_stack   ([], [], '-m')
%
% See also cgui_tree load_stack show_stack
% Uses (-c image processing toolbox)
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [I1, I2, I3] = skel_stack (iM, thr, options)

if (nargin < 1) || isempty (iM)
    iM       = false (250, 250, 50);
    iM (20 : 230, 120 : 140, 20 : 30) = 1;
    iM (ceil (rand (1000, 1) * numel (iM))) = 0;
end

if (nargin < 2) || isempty (thr)
    minM     = min (min (min (iM)));
    maxM     = max (max (max (iM)));
    c        = histc ( ...
        reshape (double (iM), numel (iM), 1), ...
        [minM ((maxM - minM) / 99) maxM]);
    cc       = cumsum (flipud (c));
    ic       = min (find (cc > 30000));
    thr      = (99 - ic) * double ((maxM - minM) / 99) + minM;
end

if (nargin < 3) || isempty (options)
    options  = '-w';
end

I1           = [];
I2           = [];
I3           = [];

% memory problems and speed: cutdown in pieces:
nM           = ceil (numel (iM) /20000000);
% if problems persist go down to 1000000 per piece..
cM           = floor (size (iM, 1) / nM);
if strfind   (options, '-w') % waitbar option: initialization
    HW       = waitbar (0, 'skeletonizing...');
    set      (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end

for counter1     = 1 : nM
    if strfind   (options, '-w') % waitbar option: update
        waitbar  (counter1 / nM, HW);
    end

    if counter1  == nM
        MI       = iM (1 + (counter1 - 1) * cM : end, :, :);
    else
        MI       = iM (1 + (counter1 - 1) * cM : (counter1) * cM, :, :);
    end

    if strfind   (options, '-c')
        MI       = imclose (MI, ones (2, 2, 2));
    end

    % add border:
    MI           = [ ...
        (false (1, size (MI, 2), size (MI, 3))); ...
        MI; ...
        (false (1, size (MI, 2), size (MI, 3)))];
    MI           =    [ ...
        (false (size (MI, 1), 1, size (MI, 3))) ...
        MI  ...
        (false (size (MI, 1), 1, size (MI, 3)))];
    MI           = cat (3, ...
        (false (size (MI, 1),    size (MI, 2))), ...
        MI, ...
        (false (size (MI, 1),    size (MI, 2))));

    % binary threshold
    MI = MI > thr;

    if strfind (options, '-m'),
        clf; 
        subplot (211); 
        imagesc (max (iM, [], 3));
        colormap gray;
        axis equal;
        set (gca, 'visible', 'off');
    end
    iFlo = 0;
    iFl = 1;
    while iFlo ~= iFl
        iFl = iFlo;
        if strfind (options, '-m'),
            subplot (212);
            imagesc (max (MI, [], 3));
            axis equal;
            set (gca, 'visible', 'off');
            drawnow;
        end
        indy = find (MI);
        [i1, i2, i3] = ind2sub (size (MI), indy);
        i1 = int16 (i1);
        i2 = int16 (i2);
        i3 = int16 (i3);
        i1NE = repmat( ...
            [(i1 - 1) i1 (i1 + 1)], ...
            1, 9);
        i2NE = repmat([ ...
            (i2 - 1) (i2 - 1) (i2 - 1) ...
            i2        i2       i2 ...
            (i2 + 1) (i2 + 1) (i2 + 1)], 1, 3);
        i3NE = [ ...
            (repmat (i3 - 1, 1, 9)) ...
            (repmat (i3,  1, 9)) ...
            (repmat (i3 + 1, 1, 9))];
        indo = double ( ...
            sub2ind (size (MI), ...
            double  (i1NE), ...
            double  (i2NE), ...
            double  (i3NE)));
        clear    i1NE i2NE i3NE
        NE       = MI (indo);
        clear    indo;
        NEbak    = NE;

        P = [ ...
            1 4 7 10 13 16 19 22 25 2 5 8 11 14 17 20 23 26 3 6 9 12 15 18 21 24 27; ...
            9 18 27 8 17 26 7 16 25 6 15 24 5 14 23 4 13 22 3 12 21 2 11 20 1 10 19; ...
            7 4 1 8 5 2 9 6 3 16 13 10 17 14 11 18 15 12 25 22 19 26 23 20 27 24 21; ...
            9 8 7 6 5 4 3 2 1 18 17 16 15 14 13 12 11 10 27 26 25 24 23 22 21 20 19; ...
            3 6 9 2 5 8 1 4 7 12 15 18 11 14 17 10 13 16 21 24 27 20 23 26 19 22 25; ...
            3 12 21 6 15 24 9 18 27 2 11 20 5 14 23 8 17 26 1 10 19 4 13 22 7 16 25; ...
            21 20 19 24 23 22 27 26 25 12 11 10 15 14 13 18 17 16 3 2 1 6 5 4 9 8 7; ...
            25 22 19 16 13 10 7 4 1 26 23 20 17 14 11 8 5 2 27 24 21 18 15 12 9 6 3; ...
            1 10 19 2 11 20 3 12 21 4 13 22 5 14 23 6 15 24 7 16 25 8 17 26 9 18 27; ...
            19 20 21 10 11 12 1 2 3 22 23 24 13 14 15 4 5 6 25 26 27 16 17 18 7 8 9; ...
            7 8 9 16 17 18 25 26 27 4 5 6 13 14 15 22 23 24 1 2 3 10 11 12 19 20 21];

        iNE = find  (sum (NE, 2) >= 3 & sum (~NE, 2) >= 5);
        iF  = false (length (iNE), 1);

        for counter2 = 1 : 12
            if counter2 > 1
                NE = NEbak (:, P (counter2 - 1, :));
            end
            iF1 = (sum (NE (iNE, [19 20 21 22 23 24 25 26 27]), 2) == 0) & ...
                (  sum (NE (iNE, [1 2 3 4 6 7 8 9 10 11 12 13 15 16 17 18]), 2) > 0) & ...
                (NE (iNE, 5)  == 1);
            iF2 = (sum (NE (iNE, [1 4 7 10 13 16 19 22 25]), 2) == 0) & ...
                (  sum (NE (iNE, [2 3 5 6 8 9 11 12 17 18 20 21 23 24 26 27]), 2) > 0) & ...
                (NE (iNE, 15) == 1);
            iF3 = (sum (NE (iNE, [1 4 5 7 10 13 15 16 19 20 21 22 23 24 25 26 27]), 2) == 0) & ...
                (  sum (NE (iNE ,[2 3 8 9 11 12 17 18]), 2) > 0) & ...
                (NE (iNE, 6)  == 1);

            iF4 = (sum (NE (iNE, [13 19 22 23 25]), 2) == 0) & ...
                (  sum (NE (iNE, [10 20]), 2) < 2) & ...
                (  sum (NE (iNE, [17 26]), 2) < 2) & ...
                (  sum (NE (iNE, [5 15]), 2) == 2);
            iF5 = (sum (NE (iNE, [13 19 22 23]), 2) == 0) & ...
                (  sum (NE (iNE, [10 20]), 2) < 2) & ...
                (  sum (NE (iNE, [5 15 17]), 2) == 3);
            iF6 = (sum (NE (iNE, [13 22 23 25]), 2) == 0) & ...
                (  sum (NE (iNE, [16 26]), 2) < 2) & ...
                (  sum (NE (iNE, [5 15 11]), 2) == 3);

            iF7 = (sum (NE (iNE, [13 19 22 23]), 2) == 0) & ...
                (  sum (NE (iNE, [10 20]), 2) < 2) & ...
                (  sum (NE (iNE, [16 26]), 2) == 1) & ...
                (  sum (NE (iNE, [5 15 25]), 2) == 3);
            iF8 = (sum (NE (iNE, [13 22 23 25]), 2) == 0) & ...
                (  sum (NE (iNE, [16 26]), 2) < 2) & ...
                (  sum (NE (iNE, [10 20]), 2) == 1) & ...
                (  sum (NE (iNE, [5 15 19]), 2) == 3);
            iF9 = (sum (NE (iNE, [1 4 5 10 13 19 20 21 22 23 24 25 26 27]), 2) == 0) & ...
                (  sum (NE (iNE, [6 8]), 2) == 2);

            iF10 = (sum (NE (iNE, [4 5 7 13 16 19 20 21 22 23 24 25 26 27]), 2) == 0) & ...
                (sum (NE (iNE, [2 6]), 2) == 2);
            iF11 = (sum (NE (iNE, [1 4 5 7 10 13 15 16 19 20 21 22 23 24 25]), 2) == 0) & ...
                (sum (NE (iNE, [6 18]), 2) == 2);
            iF12 = (sum (NE (iNE, [1 4 5 7 10 13 15 16 18 19 22 23 24 25 26 27]), 2) == 0) & ...
                (sum (NE (iNE, [6 12]), 2) == 2);

            iF = iF | iF1 | iF2 | iF3 | iF4 | iF5 | iF6 | iF7 | iF8 | iF9 | iF10 | iF11 | iF12;
        end

        MI (indy (iNE (iF))) = 0;
        iFlo = length (iF);

    end
    i1 = double (i1);
    i2 = double (i2);
    i3 = double (i3);
    I1 = [I1; i1+(counter1 - 1)*cM];
    I2 = [I2; i2];
    I3 = [I3; i3];
end
if strfind (options, '-w') % waitbar option: close
    close (HW);
end

