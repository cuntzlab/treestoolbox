%% check_recon_tree

%% test 1
dLPTCs       = load_tree ('dLPTCs.mtr');
for counterN = 1 : 1000
    for counter      = 1 : length (dLPTCs{1})
        tree         = dLPTCs{1}{counter};
        recon_tree   (tree, 10, 20, 'none');
    end
end

%% test 2
recon_tree   (sample_tree, 105, 160, '-s');
tprint       ('./panels/recon_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 3
recon_tree   (sample_tree, 105, 160, '-s -h');
tprint       ('./panels/recon_tree2', ...
    '-jpg -HR',                [10 10]);

