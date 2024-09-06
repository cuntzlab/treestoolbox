%% check_zcorr_tree

%% test 1
tree                = sample_tree;
zcorr_tree          (tree, 4,  '-s -m');
tprint              ('./panels/zcorr_tree1', ...
    '-jpg -HR',                [10 10]);


%% test 2
dLPTCs              = load_tree ('dLPTCs.mtr');
for counterN        = 1 : 100
    for counter     = 1 : length (dLPTCs{1})
        tree        = dLPTCs{1}{counter};
        zcorr_tree  (tree);
    end
end


