%% check_clean_tree

%% test 1
dLPTCs       = load_tree ('dLPTCs.mtr');
for counter  = 1 : length (dLPTCs{1})
    clean_tree (dLPTCs{1}{counter}, 20);
end

%% test 2
clean_tree   (sample_tree, 20, '-s -w');
tprint       ('./panels/clean_tree1', ...
    '-jpg -HR', [10 10]);

%% test 3
clean_tree   (hsn_tree,    20, '-s -w');
tprint       ('./panels/clean_tree2', ...
    '-jpg -HR', [10 10]);



