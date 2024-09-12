%% check_elim0_tree

%% test 1
dLPTCs       = load_tree ('dLPTCs.mtr');
for counterN = 1 : 100
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        tree.X (5)   = tree.X (4); % setting coordinates same means
        tree.Y (5)   = tree.Y (4); % making a zero length segment
        tree.Z (5)   = tree.Z (4);
        elim0_tree   (tree, 'none');
    end
end

%% test 2
tree         = sample2_tree;
tree.X (5)   = tree.X (4);
tree.Y (5)   = tree.Y (4);
tree.Z (5)   = tree.Z (4);
etree        = elim0_tree (tree, '-s');
axis         off
tprint       ('./panels/elim0_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation
