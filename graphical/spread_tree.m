% SPREAD_TREE   Extracts coordinates to display trees separately.
% (trees package)
%
% [DD, outtrees] = spread_tree (intrees, dX, dY, options)
% -------------------------------------------------------
%
% Creates a cell array DD same organization as intrees which gives X, Y and
% Z coordinates to display trees spread over the surface of a graph. DD is
% then an input to most functions in the "graphical" folder of the TREES
% toolbox (see "plot_tree" for example). If nesting level is 2 deep trees
% are separated in groups additionally.
%
% Input
% -----
% - intrees  ::integer:      cell array of trees.
%     {DEFAULT: cell array trees}
% - dX       ::value: horizontal spacing
%     {DEFAULT: 50um}
% - dY       ::value: vertical   spacing
%     {DEFAULT: 50um}
% - options  ::string:
%     '-s'   : show
%     {DEFAULT ''}
%
% Output
% ------
% - DD::cell array of 3-tupels: X Y Z coordinates. Organization same as
%     intrees
% - outtrees::cell array of trees: trees with applied translations
%
% Example
% -------
% spread_tree  ( ...
%     {sample_tree, hsn_tree, hss_tree, sample2_tree}, [], [], '-s');
%
% See also   plot_tree xplore_tree
% Uses       X, Y, Z
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function [DD, outtrees] = spread_tree (intrees, dX, dY, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1) || isempty (intrees)
    % {DEFAULT: trees cell array}
    intrees  = trees;
end;

if (nargin < 2) || isempty (dX)
    % {DEFAULT: trees are 50 um apart horizontally}
    dX       = 50;
end;

if (nargin < 3) || isempty (dY)
    % {DEFAULT: trees are 50 um apart vertically}
    dY       = 50;
end;

if (nargin < 4) || isempty (options)
    % {DEFAULT: no option}
    options  = '';
end

if isstruct (intrees)
    level    = 0;
else
    level    = 1;
    for counter  = 1 : length (intrees)
        if ~isstruct (intrees{counter})
            level    = 2;
        end
    end
end

if (nargout > 1)
    outtrees = intrees;
end

switch           level
    case         2
        superY   = 0;
        DD       = cell (1, length (intrees));
        for counter1 = 1 : length (intrees)
            lent     = length (intrees {counter1});
            % minimum positions:
            X        = zeros (lent, 1);
            Y        = zeros (lent, 1);
            Z        = zeros (lent, 1);
            % position ranges:
            mX       = zeros (lent, 1);
            mY       = zeros (lent, 1);
            mZ       = zeros (lent, 1);
            for counter2 = 1 : lent
                % minimum positions:
                X  (counter2) = min (intrees{counter1}{counter2}.X);
                Y  (counter2) = max (intrees{counter1}{counter2}.Y);
                Z  (counter2) = min (intrees{counter1}{counter2}.Z);
                % widths:
                mX (counter2) = ...
                    max (intrees{counter1}{counter2}.X) - ...
                    min (intrees{counter1}{counter2}.X);
                mY (counter2) = ...
                    max (intrees{counter1}{counter2}.Y) - ...
                    min (intrees{counter1}{counter2}.Y);
                mZ (counter2) = ...
                    max (intrees{counter1}{counter2}.Z) - ...
                    min (intrees{counter1}{counter2}.Z);
            end
            % sqrtN gives a maximum deflection in X
            % (make the layout sort of square):
            sqrtN    = sum (mX + dX) ./ sqrt (length (mX));
            % divide summed up X ranges (+dX) by sqrtN and collect
            % remainder in DDX:
            DDX      = mod   ([0; (cumsum (mX + dX))], sqrtN);
            cY       = floor ([0; (cumsum (mX + dX))] / sqrtN);
            DDX      = DDX   (1 : end - 1);
            cY       = cY    (1 : end - 1);
            % take from DDX the first empty bit in each line:
            dDDX     = DDX   ([1; (diff(cY))] > 0);
            DDX      = DDX - dDDX (cY + 1);
            % add in Y the maximum Y-deflection in each line:
            ucY      = unique (cY);
            mmY      = zeros  (length (ucY), 1);
            for counter2  = 1 : length (ucY)
                mmY (counter2) = max (mY (cY == ucY (counter2)));
            end
            % DDY becomes the cumulative sum of these maximum deflections (+DY)
            mmY      = [0;  (-cumsum (mmY + dY))];
            DDXYZ    = [DDX (mmY (cY + 1))];
            % DDZ is kept zero, but for each cell:
            dDD      = ...
                [DDXYZ (zeros (size (DDXYZ, 1), 1))] - ...
                [X (Y - superY) Z];
            DD{counter1} = num2cell (dDD, 2)';
            superY   = superY + dDD (end, 2);
            if (nargout > 1)
                for counter2 = 1 : length (intrees {counter1})
                    outtrees{counter1}{counter2} = ...
                        tran_tree ( ...
                        intrees{counter1}{counter2}, ...
                        DD{counter1}{counter2});
                end
            end
        end
    case 1
        lent     = length (intrees); % number of trees
        % initialization
        X        = zeros (lent, 1);
        Y        = zeros (lent, 1);
        Z        = zeros (lent, 1); % minimum positions
        mX       = zeros (lent, 1);
        mY       = zeros (lent, 1);
        mZ       = zeros (lent, 1); % position ranges
        for counter  = 1 : lent % walk through all trees
            % minimum positions:
            X  (counter) = min (intrees {counter}.X);
            Y  (counter) = max (intrees {counter}.Y);
            Z  (counter) = min (intrees {counter}.Z);
            % widths:
            mX (counter) = ...
                max (intrees {counter}.X) - ...
                min (intrees {counter}.X);
            mY (counter) = ...
                max (intrees {counter}.Y) - ...
                min (intrees {counter}.Y);
            mZ (counter) = ...
                max (intrees {counter}.Z) - ...
                min (intrees {counter}.Z);
        end
        % sqrtN gives a maximum deflection in X
        % (make the layout sort of square):
        sqrtN    = sum (mX + dX) ./ sqrt (length (mX));
        % divide summed up X ranges (+dX) by sqrtN and collect remainder in DDX:
        DDX      = mod   ([0; (cumsum (mX + dX))], sqrtN);
        cY       = floor ([0; (cumsum (mX + dX))] / sqrtN);
        DDX      = DDX   (1 : end - 1);
        cY       = cY    (1 : end - 1);
        % take from DDX the first empty bit in each line:
        dDDX     = DDX ([1; (diff (cY))] > 0);
        DDX      = DDX - dDDX (cY + 1);
        % add in Y the maximum Y-deflection in each line:
        ucY      = unique (cY);
        mmY      = zeros (length (ucY), 1);
        for counter  = 1 : length (ucY)
            mmY (counter) = max (mY (cY == ucY (counter)));
        end
        % DDY becomes the cumulative sum of these maximum deflections (+DY)
        mmY      = [0;  (-cumsum (mmY + dY))];
        DDXYZ    = [DDX (mmY (cY + 1))];
        % DDZ is kept zero, but for each cell:
        dDD      = ...
            [DDXYZ (zeros (size (DDXYZ, 1), 1))] - ...
            [X Y Z];
        DD       = num2cell (dDD, 2)';
        if (nargout > 1)
            for counter = 1 : length (intrees)
                outtrees{counter} = tran_tree ( ...
                    intrees{counter}, DD{counter});
            end
        end
    case         0
        DD       = [0 0 0];
        if (nargout > 1)
            outtrees = tran_tree (intrees);
        end
end

if strfind       (options, '-s')
    clf;
    switch level
        case 2
            for counter1 = 1 : length (intrees)
                for counter2 = 1 : length (intrees {counter1})
                    plot_tree ( ...
                        intrees{counter1}{counter2}, [], ...
                        DD{counter1}{counter2});
                end
            end
        case     1
            clf;
            for counter = 1 : lent
                plot_tree (intrees {counter}, [], DD{counter});
            end
        case     0
            plot_tree (intrees);
    end
    title        ('spread trees');
    xlabel       ('x [\mum]');
    ylabel       ('y [\mum]');
    zlabel       ('z [\mum]');
    view         (2);
    grid         on;
    axis         image;
end

