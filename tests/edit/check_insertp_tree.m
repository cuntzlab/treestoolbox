%% check_insertp_tree

%% test 1
dLPTCs       = load_tree ('dLPTCs.mtr');
for counterN = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        insertp_tree (tree, [], 'none');
    end
end

%% test 2
insertp_tree (sample_tree, 43, 50 : 10 : 100, '-s');
tprint       ('./panels/insertp_tree1', ...
    '-jpg -HR',                [10 10]);




