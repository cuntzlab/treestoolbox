% angleBd_tree   Angle value at branch points in a tree with variable
% distance. The longest branches of the largest subtree are choosen.
%
% tree must be resampled previousy ( tree = resample_tree (intree, 1); )
%
% angleBd = angleBd_tree (intree, dist)
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
% angleBd_tree  (tree, 100);
%
% See also   angleB_tree
% Uses       resample_tree typeN_tree child_tree 


function angleBd = angleBd_tree (intree, dist)

%tree             = resample_tree (intree, 10);
tree      = intree;
typeN     = typeN_tree (tree, '-bct');
Child     = child_tree (tree); % Welcher Unterbaum größer ist
IB        = find  (B_tree (tree));

angleBd   = zeros (length (IB), 1); % angle values for each BP

for b = 1 : length (IB)

    P               = zeros (dist,2);
    Z               = zeros (1,2);    
    % indices of Angular point daughters:
    A               = find (tree.dA (:, IB(b)));
    for j = 1:2
        Ac        = A (j);
        P (1, j)  = Ac;
        %
        i = 2;

        while i <= dist
          
            if typeN (P (i - 1, j)) == 'C'
                Ac  = find (tree.dA (:, Ac));            
            end
        
            if typeN (P (i - 1, j)) == 'B'
                % finde both daugther nodes
                Bc  = find (tree.dA (:, Ac));
                      
                if Child (Bc (1)) == Child (Bc (2))
                    Ac = Bc (j);
    
                elseif Child (Bc (1)) ~= Child (Bc (2))
                    CBc = [ (Child (Bc (1))), (Child (Bc (2))) ]; % number of children in both BP
                    Ac  = Bc (find (CBc == max (CBc))); % im größeren Unterbaum weiter laufen
                end
            end
       
            P (i, j) = Ac;
            i        = i + 1;
        end
        Z (j) = Ac;
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
        angleBd (b) = 0;
    else
        angleBd (b) = acos (dot (nV1, nV2));
    end  
    
end
