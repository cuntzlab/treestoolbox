% angleBd2_tree   Angle value at branch points in a tree with variable
% distance. The longest branches are choosen.
%
% tree must be resampled previousy ( tree = resample_tree (intree, 1); )
%
% angleBd2 = angleBd2_tree (intree, dist)
% --------------------------------------
%
% Input
% -----
% - intree   ::integer: (index of tree in trees or) structured tree
% - dist     ::integer: distance from branching point
%
% Output
% ------
% angleB     ::vertical vector: angle value for each branching point with
% the given distance
%
% Example
% -------
% tree = resample_tree (sample_tree, 10);
% angleB_tree  (tree, 100);
%
% See also   angleB_tree angleBd_tree
% Uses       resample_tree typeN_tree child_tree 


function angleBd2 = angleBd2_tree (intree, dist)

%tree             = resample_tree (intree, 10);
tree      = intree;
P         = ipar_tree (tree);
TP        = T_tree (tree);
iT        = find (TP); % Idice TP
L         = len_tree (tree);
IB        = find  (B_tree (tree)); % Idize BP

angleBd2  = zeros (length (IB), 1); % angle values for each BP

for b = 1 : length (IB)
   
    % indices of Angular point daughters:
    % find longest path to TP for each daugther node
    A     = find (tree.dA (:, IB (b)));
    Z     = [];

    % for every TP that went trough A: calculate branch length
    for j = 1:2
        Ac       = A (j);
        P (1, j) = Ac;
        % Pathlengths of all possible Paths
        PL       = zeros (sum (TP), 1);

        for t = 1 : sum (TP)
           
            % is the daugther of BP part of the parent nodes of TP?       
            if ismember (Ac, P (iT (t), :)) && TP(Ac) == 0
                col    = 1;
                i      = 2;
                % aslong parent node is not daugther of BP sum length
                while (P (iT (t), col)) ~= Ac && i <= dist 
                    PL (t) = PL (t) + L (P (iT (t), col));
                    col    = col + 1;
                    i      = i + 1;
                end
            end

        end
        % choose longest Path
        % die Zeile des maximalen Paths in iT ist der End Knoten
        if TP (Ac) == 0 && dist > 1
            Z (j) = iT (find (PL == max (PL)));
        end
        if TP (Ac) == 1 || dist == 1
            Z (j) = Ac;
        end
    end

    Pr           = [ ...                     % coordinates of BP
            (tree.X (IB(b))) ...
            (tree.Y (IB(b))) ...
            (tree.Z (IB(b)))];
    
    P1           = [ ...                     % coordinates of Branch 1
        (tree.X (Z(1))) ...
        (tree.Y (Z(1))) ...
        (tree.Z (Z(1)))];
    
    P2           = [ ...                     % coordinates of Branch 2
        (tree.X (Z(2))) ...
        (tree.Y (Z(2))) ...
        (tree.Z (Z(2)))];
    V1           = P1 - Pr;                  % daughter branch 1
    V2           = P2 - Pr;                  % daughter branch 2
    
    
    % normalized vectors:
    nV1          = V1 / sqrt (sum (V1.^2));
    nV2          = V2 / sqrt (sum (V2.^2));
    % the angle between two vectors in 3D is simply the inverse cosine of
    % their dot-product.
    if all       (nV1 == nV2)
        % otherwise strange imaginary parts might occur
        angleBd2 (b) = 0;
    else
        angleBd2 (b) = acos (dot (nV1, nV2));
    end  
    
end
