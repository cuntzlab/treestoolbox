%% check_sub_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 10
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        for counteri = 1 : 100
            sub_tree (tree, counteri);
        end
    end
end

%% test 2
sub              = sub_tree (sample_tree, 166, '-s');
tprint           ('./panels/sub_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation


