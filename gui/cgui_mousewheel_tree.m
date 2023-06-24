% Defines the mouse behaviour for the GUI
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function cgui_mousewheel_tree (src, evnt, action)

global       cgui
modifier     = get (cgui.ui.F, 'Currentmodifier');

if isempty (modifier) % zoom axis
    % second of three vis_ panel mouse actions: zoom
    % this function is activated by mouse wheel turning
    % simply adjust camera angle:
    angle    = get (cgui.ui.g1, 'cameraviewangle');
    set      (cgui.ui.g1, ...
        'cameraviewangle', angle * (1 + 0.1 * evnt.VerticalScrollCount));
else
    switch modifier {1}
        case 'shift' % change slicer lots
            % this function is activated by mouse wheel turning
            if evnt.VerticalScrollCount > 0
                cgui_tree ('vis_iMm5');
            else
                cgui_tree ('vis_iMp5');
            end
        case 'alt'     % nothing yet!
        case 'control' % change slicer
            % this function is activated by mouse wheel turning
            if evnt.VerticalScrollCount > 0
                cgui_tree ('vis_iMm1');
            else
                cgui_tree ('vis_iMp1');
            end
        otherwise
    end
end
end



