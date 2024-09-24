%% check_scale_tree
 
%% test 1
dLPTCs           = load_tree ('dLPTCs.mtr');
for counterN     = 1 : 50
    for counter  = 1 : length (dLPTCs{1})
        tree     = dLPTCs{1}{counter};
        scale_tree  (tree, 2);
    end
end

%% test 2
scale_tree       (sample_tree, 1.2, '-s');
tprint           ('./panels/scale_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation