% SSE_TREE   steady-state electrotonic signature of a tree.
% (trees package)
%
% sse = sse_tree (intree, I, options)
% -----------------------------------
%
% Calculates the steady state matrix containing the current transfer from
% every node to every other node in the tree, i.e. each column i is the
% potential distribution for all nodes during injection of current into
% compartment i. The diagonal is therefore the local input resistances in
% each compartment. sse is symmetric.
%
% If input current I is not the identity matrix then H columns in sse
% correspond to potential distributions in separate experiments
% corresponding to the input current distribution in that column. Note that
% sse is obtained by inverse matrix calculation and therefore goes very
% quickly but takes memory. In special cases it is advisable to split calls
% into several input matrices I.
% 
% Input
% -----
% - intree   ::integer:  index of tree in trees or structured tree
% - I        ::NxH matrix or value: (optional) current injection vector
%     if I is a number, then 1 nA is injected in position I)
%     if I is omitted I is the identity matrix {DEFAULT}
% - options  ::string:
%     '-s'   : show      - full matrix if I is left empty (full sse)
%                        - tree distribution if I is Nx1 vector
%                        - other Is first column
%     {DEFAULT: ''}
%
% Output
% ------
% - sse      ::NxH matrix: electrotonic signature matrix
%
% Examples
% --------
% sse_tree     (sample_tree, [],  '-s')
% sse_tree     (sample_tree, 100, '-s')
%
% See also M_tree
% Uses M_tree ver_tree
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function sse = sse_tree (intree, varargin)

ver_tree     (intree);


%=============================== Parsing inputs ===============================%
p = inputParser;
p.addParameter('I', [])
p.addParameter('s', false)
pars = parseArgs(p, varargin, {'I'}, {'s'});
%==============================================================================%

M                = M_tree (intree);
if isempty (pars.I)
    sse          = full (inv (M));
else
    if numel (pars.I) == 1
        dI       = pars.I;
        pars.I   = sparse (size (M, 1), 1);
        pars.I (dI) = 1;
    end
    sse          = full (M \ pars.I);
end

if pars.s
    if numel     (M) == numel (sse)
        clf; 
        imagesc  (sse);
        colorbar;
        axis     image;
        xlabel   ('node #');
        ylabel   ('node #');
        title    ('potential distribution [mV]');
    else
        clf;
        hold     on;
        plot_tree (intree, sse (:, 1));
        colorbar;
        title    ('potential distribution [mV]');
        xlabel   ('x [\mum]');
        ylabel   ('y [\mum]');
        zlabel   ('z [\mum]');
        view     (2);
        grid     on;
        axis     image;
    end
end

