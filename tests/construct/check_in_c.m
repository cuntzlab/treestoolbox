%% check_in_c

%% test 1

clf;
tree         = resample_tree     (sample_tree, 1, 'none');
c          = hull_tree (tree, 5, [], [], [], 'dim2');
X          = 100 * rand (1000, 1);
Y          = 100 * rand (1000, 1);
IN         = in_c (X, Y, c);
plot       (X (IN), Y (IN), 'k.');
tprint       ('./panels/in_c1', ...
    '-jpg -HR', [10 10]);

%% test 2

clf;
tree         = resample_tree     (sample_tree, 1, 'none');
c          = hull_tree (tree, 5, [], [], [], 'dim2');
X          = 100 * rand (1000, 1);
Y          = 100 * rand (1000, 1);
dx = 10;
dy = 10;
IN         = in_c (X, Y, c, dx, dy);
plot       (X (IN), Y (IN), 'k.');
tprint       ('./panels/in_c1', ...
    '-jpg -HR', [10 10]);