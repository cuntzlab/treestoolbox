%% check_resample_tree

%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counter      = 1 : length (dLPTCs{1})
    tree         = dLPTCs{1}{counter};
    resample_tree (tree, 5, 'none');
end
    
%% test 2
resample_tree    (sample2_tree, 5, '-s -e -w');
tprint           ('./panels/resample_tree1', ...
    '-jpg -HR',                [10 10]);

%% test 3
tree             = resample_tree (sample_tree, 5, '-s -e');
tprint           ('./panels/resample_tree2', ...
    '-jpg -HR',                [10 10]);    % documentation




