%% check_dissect_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 100
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        dissect_tree (tree);
    end
end

%% test 2
dissect_tree     (sample_tree, '-s');
tprint           ('./panels/dissect_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
tree             = sample2_tree;
sect             = dissect_tree (tree);
startB           = sect (:, 1);
endB             = sect (:, 2);
clf;
hold             on; 
HP               = plot_tree (tree, [], [], [], [], '-b');
set              (HP, 'facealpha', 0.3);
L                = line( ...
    [(tree.X (startB)) (tree.X (endB))]', ...
    [(tree.Y (startB)) (tree.Y (endB))]', ...
    [(tree.Z (startB)) (tree.Z (endB))]');
set              (L, ...
    'color',                   [1 0 0], ...
    'linewidth',               2);
HP (1)           = plot   (1, 1, 'k-');
HP (2)           = plot   (1, 1, 'r-');
HT               = legend (HP, ...
    {'intact tree', 'dissected branches'}, ...
    'box',                     'on', ...
    'location',                'southeast');
vtext_tree       (tree);
view             (2);
axis             off
tprint           ('./panels/dissect_tree2', ...
    '-jpg -HR',                [10 10]);


