%% check_gscale_tree

%% test 1
dLPTCs       = load_tree  ('dLPTCs.mtr');
spanning     = gscale_tree (dLPTCs{1}, '-s');
display      (spanning);
tprint       ('./panels/gscale_tree1', ...
    '-jpg -HR', [10 10]);    % documentation



