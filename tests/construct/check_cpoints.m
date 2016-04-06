%% check_cpoints

%% test 1
c            = hull_tree (sample_tree, 4, [], [], [], '-2d');
for counter  = 1 : 1000
    cpoints  (c);
end

%% test 2
clf;
c            = hull_tree (sample_tree, 4, [], [], [], '-2d');
HP           = cplotter  (c, [0.75 0.75 0.75]);
set          (HP, 'linewidth', 1, 'linestyle', '-');
[X, Y]       = cpoints   (c);
HP           = plot (X, Y, 'k.');
set          (HP, 'markersize', 8);
axis         off tight equal
tprint       ('./panels/cpoints1', ...
    '-jpg -HR', [10 10]);
