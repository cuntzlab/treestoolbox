% [ tree ] = dscam_tree( tree, iteration, options  )
% mutate tree 
%
% Input
% ----
% - tree              ::tree: 	input tree
% - iterations 		  ::number: N iterations
% Output
% ------
%  - tree     ::struct::    tree
%
function [ intree ] = dscam_tree( intree, iteration, options  )

% default num iterations
if (nargin <2)||isempty(iteration)
    iteration = length(intree.X)*5;
end

if (nargin<5)||isempty(options)
    options ='none';
end

%How far should a node be moved to closest node?
movePercent = 0.1;
	for i = 1:iteration
        
        %create index vector
        iVector 	= logical(ones(length(intree.X),1));
        
        %find a node, that is not terminal to start from
        %iStart   = find(typeN_tree(intree)>0);
       % iStart   = iStart(randi(length(iStart),1));
       % random startnode
    
       iStart = randi(length(intree.X)-1)+1;
       
        %find parentnodes of iStart and mark them
        iParent 			= ipar_tree(intree);
        iParent         	= iParent(iStart,:)';
        iParent(iParent==0) = [];
        iVector(iParent)  	= 0;
        
        %find subtree of iStart and mark it
        iChild              = logical(sub_tree(intree,iStart));
        iVector(iChild) 	= 0;
        
           
        % calculate distance from iStart to all other nodes
        distance = sqrt(...
            (intree.X-intree.X(iStart)).^2+...
            (intree.Y-intree.Y(iStart)).^2+...
            (intree.Z-intree.Z(iStart)).^2);

        % cluster nodes
        iVector(distance<2) = 0;

            %if all nodes are marked (e.g. root is iStart) skip iteration
        if sum (iVector) == 0
            continue
        end

        %find the closest node that is not parent or iChildtree
        iClose   = find(distance         == min(distance(iVector)));
        iClose   = iClose(1);
        
        %move nodes  10 percent closer together
        XYZMove  = [intree.X(iClose) - intree.X(iStart);...
            		intree.Y(iClose) - intree.Y(iStart);...
            		intree.Z(iClose) - intree.Z(iStart)]...
            		.*movePercent;
        
        intree.X(iStart) = intree.X(iStart)+XYZMove(1);
        intree.Y(iStart) = intree.Y(iStart)+XYZMove(2);
        intree.Z(iStart) = intree.Z(iStart)+XYZMove(3);
        
        %move subtree with node
        intree.X(iChild) = intree.X(iChild)+XYZMove(1);
        intree.Y(iChild) = intree.Y(iChild)+XYZMove(2);
        intree.Z(iChild) = intree.Z(iChild)+XYZMove(3);   
    end

end
