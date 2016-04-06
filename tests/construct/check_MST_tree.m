%% check_MST_tree

%% test 1
X            = rand  (100, 1) * 100;
Y            = rand  (100, 1) * 100;
Z            = zeros (100, 1);
tree         = MST_tree (1, ...
    [50; X], [50; Y], [0; Z], 0.5, 50, 1000, [], 'none');
clf; hold on;
axis         off
HP           = plot_tree (tree, [0.75 0.75 0.75], [], [], [], '-b1');
set          (HP, 'edgecolor', 'none');
HP           = plot  (X, Y, 'k.');
set          (HP, 'markersize', 8);
xlim         ([-5 105]);
ylim         ([-5 105]);
tprint       ('./panels/MST_tree1', ...
    '-jpg -HR', [10 10]);

%% test 2
for counter  = 1 : 20
    display  (counter)
    MST_tree ([], [], [], [], [], [], [], [], 'none');
end