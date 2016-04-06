%% check_root_tree

%% test 1
dLPTCs               = load_tree ('dLPTCs.mtr');
for counterN         = 1 : 1000
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        root_tree    (tree, 'none');
    end
end
    
%% test 2
root_tree            (sample_tree, '-s');
tprint               ('./panels/root_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
root_tree            (sample2_tree, '-s');
tprint               ('./panels/root_tree2', ...
    '-jpg -HR',                [10 10]);