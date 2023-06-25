%% check_cat_tree

%% test 1
dLPTCs       = load_tree ('dLPTCs.mtr');
sample       = sample_tree;
for counter  = 1 : length (dLPTCs{1})
    cat_tree (dLPTCs{1}{counter}, sample);
end

%% test 2
sample2      = sample2_tree;
sample2T     = tran_tree (sample2, [55 25 0]);
cattree      = cat_tree  (sample2, sample2T, [], [], '-s');
tprint           ('./panels/cat_tree1', ...
    '-jpg -HR',                [10 10]);

