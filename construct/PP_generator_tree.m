% PP_GENERATOR_TREE   Distributes points with given R value.
% (trees package)
%
% [P, numIt, Rvalues] = PP_generator_tree ( ...
%   N, R, a, alpha, n_mc, level, epsilon, options)
% -------------------------------------------------------------
%
% Distributes N random points in a 200 x 200 um2 square or in a
% 200 x 200 x 200 um3 cubus with a given R value that determines
% whether points are clustered ( R < 1 ), Poisson distributed ( R = 1 )
% or regularly distributed ( R > 1 ). If N is an Nx3 matrix it is
% considered starting coordinates that will be transformed into a
% distribution with the given R value.
%
% The function implements a exclusion zone around the target 
% points due to, for example, the physical dimension of synapses 
% that these might represent.
%
% Inputs
% ------
% - N        ::integer    : number of points to be distributed or Nx3 xyz
%      	coordinates
% - R        ::value	  : R value of the target point cloud
% - a        ::value	  : controls the size of the movements of the
%		points when looking for the given R value. Must be nonzero
%     	{DEFAULT: 0.1}
% - alpha    ::value	  : shrink factor used to obtain the volume
%		supporting a given point cloud. alpha is a scalar between 0 and 1.
%		Setting alpha to 0 gives the convex hull, and setting alpha to 1
%		gives a compact boundary that envelops the points
%		(for r_mc_tree function)
%     	{DEFAULT: 0.5}
% - n_mc     :: integer   : maximum number of Monte Carlo iterations
%		(for r_mc_tree function)
%     	{DEFAULT: 100}
% - level    ::value	  : confidence intervals are obtained with
%		confidence level (1 - level)
%		(for r_mc_tree function)
%     	{DEFAULT: 0.05}
% - epsilon  :: minimum distance between points 
%     	{DEFAULT: 0}
% - options  ::string:
%     	'-m'  : show the point cloud in each iteration
%		'-s'  : show the resulting point cloud
%	  	'-3d' : 3D point cloud
%       '-e'  : echo
%     	{DEFAULT: '-2d -m'}
%
% Output
% ------
% - P :: Nx2 matrix with xy coordinates (2D) or Nx3 matrix with xyz
%       coordinates (3D)
%		of the points with the given R value
% - numIt :: number of iterations needed to obtain the given R value
% - Rvalues :: R values in all iterations
%
% Example
% -------
% P = PP_generator_tree (100, 1.2);
%
% See also r_mc_tree
% Uses
%
% Contributed by Laura Anton
%
% the TREES toolbox: edit, generate, visualise and analyse neuronal trees
% Copyright (C) 2009 - 2023  Hermann Cuntz

function [P, numIt, Rvalues] = PP_generator_tree ( ...
    N, R, a, alpha, n_mc, level, epsilon, options)

if nargin    < 1 || isempty (N)
    N        = 100;
end

if nargin    < 2 || isempty (R)
    R        = 1.2;
end

if nargin    < 3 || isempty (a)
    a        = 0.1;
end

if nargin    < 4 || isempty (alpha)
    alpha    = 0.5;
end

if nargin    < 5 || isempty (n_mc)
    n_mc     = 100;
end

if nargin    < 6 || isempty (level)
    level    = 0.05;
end

if nargin    < 7 || isempty (epsilon)
    epsilon  = 0;
end

if nargin    < 8 || isempty (options)
    options  = '-2d -m -e';
end

if (epsilon > 0) % volume exclusion (epsilon is the minimum distance between points)
	X                    = 0;
	Y                    = 0;
	if contains           (options, '-3d')
		Z                = 0;
	end
	counter              = 1;
	while                (counter < N)
		xini             = ceil (rand (1, 1) * 200 - 100);
		yini             = ceil (rand (1, 1) * 200 - 100);
		if contains       (options, '-3d')
			zini         = ceil (rand (1, 1) * 200 - 100);
			distance     = sqrt ( ...
				(xini - X).^2 + ...
				(yini - Y).^2 + ...
				(zini - Z).^2);
		else
			distance     = sqrt ( ...
				(xini - X).^2 + ...
				(yini - Y).^2);
		end
		if (sum (distance < epsilon) == 0) % no intersections
			X            = [X; xini];
			Y            = [Y; yini];
			if contains   (options, '-3d')
				Z        = [Z; zini];
			end
			counter      = counter + 1;
		end
	end

	if contains           (options, '-3d')
		P                = [X, Y, Z];
		t                = struct( ...
			'X', X, ...
			'Y', Y, ...
			'Z', Z);
		Ract             = r_mc_tree (t, alpha, n_mc, level, '-3d');
	else
		P                = [X, Y];
		t                = struct ( ...
			'X', X, ...
			'Y', Y, ...
			'Z', 0 * X);
		Ract             = r_mc_tree (t, alpha, n_mc, level, '-2d');
	end
	Rvalues              = Ract; % initial R value

	if contains           (options, '-m')
		clf;
		if contains       (options, '-3d')
			plot3        (X, Y, Z, 'k.');
            view         (3);
		else
			plot         (X, Y, 'k.');
		end
		axis             equal off;
		title            (Ract);
		drawnow;
	end

	if ( ((Ract > R) && (a > 0)) || ((Ract < R) && (a < 0)))
		a                = -a;
	end

	numIt                = 0;
	while ((Ract < R - 0.01) || (Ract > R + 0.01))
        if contains      (options, '-e')
    		disp         ([Ract R]);
        end
		iNN              = zeros (N, 1);
		dR               = abs   (R - Ract);
		for counterNN    = 1 : N
			if contains   (options, '-3d')
				d        = sqrt ( ...
					(X (counterNN) - X).^2 + ...
					(Y (counterNN) - Y).^2 + ...
					(Z (counterNN) - Z).^2);
			else
				d        = sqrt ( ...
					(X (counterNN) - X).^2 + ...
					(Y (counterNN) - Y).^2);
			end
			d (counterNN) = inf;
			movedPoint   = 0;
			neighbors    = N - 1;
			while ((movedPoint == 0) && (neighbors > 0))
				
				[~, i1]  = min (d);
				iNN (counterNN) = i1;
				dX       = (X (counterNN) - X (iNN (counterNN)));
				dY       = (Y (counterNN) - Y (iNN (counterNN)));
				newx     = X (counterNN) + dR * a * dX;
				newy     = Y (counterNN) + dR * a * dY;
				if (newx < -100)
					newx = -100;
				end
				if (newx > 100)
					newx = 100;
				end
				if (newy < -100)
					newy = -100;
				end
				if (newy > 100)
					newy = 100;
				end
				if contains (options, '-3d')
					dZ   = (Z (counterNN) - Z (iNN (counterNN)));
					newz = Z (counterNN) + dR * a * dZ;
					if (newz < -100)
						newz = -100;
					end
					if (newz > 100)
						newz = 100;
					end
					distance = sqrt ( ...
						(newx - X).^2 + ...
						(Y (counterNN) - Y).^2 + ...
						(Z (counterNN) - Z).^2);
				else
					distance = sqrt ( ...
						(newx - X).^2 + ...
						(Y (counterNN) - Y).^2);
				end
				distance (counterNN) = inf;
				if (sum(distance < epsilon) == 0) % no intersections
					X (counterNN) = newx;
					Y (counterNN) = newy;
					if contains (options, '-3d')
						Z (counterNN) = newz;
					end
					movedPoint = 1;
				else
					% we can't move the point in the direction of this
					% neighbor:
					d (i1) = inf;
					neighbors = neighbors - 1;
				end
			end
        end
        
		if contains       (options, '-3d')
			P            = [X, Y, Z];
			t            = struct ( ...
				'X', X, ...
				'Y', Y, ...
				'Z', Z);
			Ract         = r_mc_tree (t, alpha, n_mc, level, '-3d');
		else
			P            = [X, Y];
			t            = struct ( ...
				'X', X, ...
				'Y', Y, ...
				'Z', 0 * X);
			Ract         = r_mc_tree (t, alpha, n_mc, level, '-2d');
		end
		Rvalues          = [Rvalues, Ract];
		
		if (((Ract > R) && (a > 0)) || ((Ract < R) && (a < 0)))
			a            = -a;
		end
		
		if contains       (options, '-m')
			clf; hold    on;
			if contains   (options, '-3d')
				plot3    (X, Y, Z, 'k.');
                view     (3)
			else
				plot     (X, Y, 'k.');
			end
			axis         equal off;
			title        (Ract);
			drawnow;
		end
		numIt            = numIt + 1;
	end
	
else % no volume exclusion
	xini                 = ceil (rand ((N - 1), 1) * 200 - 100);
	yini                 = ceil (rand ((N - 1), 1) * 200 - 100);
	X                    = [0; xini];
	Y                    = [0; yini];
	if contains           (options, '-3d')
		zini             = ceil (rand ((N - 1), 1) * 200 - 100);
		Z                = [0; zini];
		P                = [X, Y, Z];
		t                = struct ('X', X, 'Y', Y, 'Z', Z);
		Ract             = r_mc_tree (t, alpha, n_mc, level, '-3d'); 
	else
		P                = [X, Y];
		t                = struct ('X', X, 'Y', Y, 'Z', 0*X);
		Ract             = r_mc_tree (t, alpha, n_mc, level, '-2d'); 
	end
	Rvalues              = Ract; % initial R value

	if contains           (options, '-m')
		clf;
		if contains       (options, '-3d')
			plot3        (X, Y, Z, 'k.');
            view         (3);
		else
			plot         (X, Y, 'k.'); 
		end
		axis             equal off;
		title            (Ract);
		drawnow;
	end

	if (((Ract > R) && (a > 0)) || ((Ract < R) && (a < 0)))
		a                = -a;
	end

	numIt                = 0;
	while ((Ract < R - 0.01) || (Ract > R + 0.01))
        if contains      (options, '-e')
    		disp         ([Ract R]);
        end
		iNN              = zeros (N, 1);
		dR               = abs   (R - Ract);
		for counterNN    = 1 : N
			if contains   (options, '-3d')
				d        = sqrt ( ...
                    (X (counterNN) - X).^2 + ...
                    (Y (counterNN) - Y).^2 + ...
                    (Z (counterNN) - Z).^2);
			else
				d        = sqrt ( ...
                    (X (counterNN) - X).^2 + ...
                    (Y (counterNN) - Y).^2);
			end
			d (counterNN) = inf;
			[~, i1]      = min (d);
			iNN (counterNN) = i1;
		end
		dX               = (X - X (iNN));
		dY               = (Y - Y (iNN));
		X                = X + dR * a * dX;
		Y                = Y + dR * a * dY;
		X (X < -100)     = -100;
		Y (Y < -100)     = -100;
		X (X >  100)     =  100;
		Y (Y >  100)     =  100;
		
		if contains       (options, '-3d')
			dZ           = (Z - Z (iNN));
			Z            = Z + dR * a * dZ;
			Z (Z < -100) = -100;
			Z (Z >  100) =  100;
			P            = [X, Y, Z];
			t            = struct ('X', X, 'Y', Y, 'Z', Z);
			Ract         = r_mc_tree (t, alpha, n_mc, level, '-3d');
		else
			P            = [X, Y];
			t            = struct ('X', X, 'Y', Y, 'Z', 0 * X);
			Ract         = r_mc_tree (t, alpha, n_mc, level, '-2d');
		end
		Rvalues = [Rvalues, Ract];
		
		if ( ((Ract > R) && (a > 0)) || ((Ract < R) && (a < 0)))
			a = -a;
		end

		if contains (options, '-m')
			clf;
			if contains (options, '-3d')
				plot3 (X, Y, Z, 'k.');
                view (3);
			else
				plot (X, Y, 'k.'); 
			end
			axis         equal off;
			title        (Ract);
			drawnow;
		end
		numIt = numIt + 1;
		
	end 

end

if contains      (options, '-s')
    clf;
    hold         on;
    if contains   (options, '-3d')
        plot3    (X, Y, Z, 'k.');
    else
        plot     (X, Y, 'k.');
    end
    axis         equal off;
    title        (Ract);
    drawnow;
end
end

