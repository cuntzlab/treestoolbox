%% check_vol_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 1000
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        vol_tree (tree);
    end
end

%% test 2
vol_tree         (sample_tree, '-s');
tprint           ('./panels/vol_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation




