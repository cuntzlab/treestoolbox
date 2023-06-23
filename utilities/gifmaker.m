% GIFMAKER    Simple movie on transparent background.
% (scheme package)
%
% gifmaker (action, name, Tsize, delaytime)
% -----------------------------------------
%
% Creates a transparent movie. Put this function in strategic places in
% your code to append frames one by one to a movie with transparent
% background (white = transparent). Leaves a temporary file "zzzzzz.tif" in
% the current directory.
%
% Input
% -----
% - action   ::string:  'init' 'loop' or 'finish'
% - name     ::string:  name of the output-file with extension
%     {DEFAULT: 'test.gif'}
% - Tsize    ::2-tupel: fixed size in cm [horiz. x vertical]
%     {DEFAULT: 10cm x 10cm}
% - delaytime ::value:  time between frames
%     {DEFAULT: .1 sec}
%
% Output
% ------
%
% Example
% -------
% tree         = sample_tree;
% clf; axis off;
% gifmaker     ('init', 'sample.gif', [10 5]);
% for te       = 0 : 10 : 355
%     clf; axis off;
%     rtree    = tree;
%     X0       = rtree.X (1);
%     Y0       = rtree.Y (1);
%     Z0       = rtree.Z (1);
%     rtree    = rot_tree  (tran_tree (rtree),[0 te 0]);
%     rtree    = tran_tree (rtree, [X0, Y0, Z0]);
%     plot_tree (rtree, [], [], [], 32, '-3l');
%     xlim     ([-140 140]);
%     ylim     ([-20  120]);
%     gifmaker ('loop',   'sample.gif', [10 5]);
% end
% gifmaker     ('finish', 'sample.gif', [10 5]);
% 
% See also tprint
% Uses tprint
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2016  Hermann Cuntz

function gifmaker (action, name, Tsize, delaytime)

global ZZZZZZ

if (nargin < 2) || isempty (name)
    name     = 'test.gif';
end

if (nargin < 3) || isempty (Tsize)
    Tsize    = [10 10];
end

if (nargin < 4) || isempty (delaytime)
    delaytime = 0.1;
end

switch action
    case 'init'
        ZZZZZZ   = {};
        set      (gcf, 'doublebuffer', 'on');
        colormap gray (256);
    case 'loop'
        drawnow;
        tprint   ('zzzzzz', '-tif', Tsize);
        M        = imread ('zzzzzz.tif');
        ZZZZZZ{end + 1} = M(:, :, 1);
    case 'finish'
        ZZZZZZ   = cat (4, ZZZZZZ{:});
        imwrite  ( ...
            ZZZZZZ,              gray (256), ...
            name,                'gif', ...
            'delaytime',         delaytime, ...
            'LoopCount',         inf, ...
            'TransparentColor',  255, ....
            'backgroundcolor',   255, ...
            'DisposalMethod',    'restoreBG');
        clear    ZZZZZZ
end



