%% check_flatten_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        flatten_tree (tree, 'none');
    end
end

%% test 2
flatten_tree     (sample_tree, '-m');

%% test 3
flatten_tree     (sample_tree, '-s -w');
tprint           ('./panels/flatten_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 4
flatten_tree     (hss_tree,    '-s -w');
tprint           ('./panels/flatten_tree2', ...
    '-jpg -HR',                [10 10]);


