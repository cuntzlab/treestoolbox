%% check_cplotter

%% test 1
clf;
HP           = plot_tree  (sample2_tree, [0 0 0], [], [], [], '-b1');
for counter  = 1 : 3
    c        = hull_tree (sample2_tree, 4 * counter, [], [], [], '-2d');
    HP       = cplotter  (c, rand (1, 3), ...
        [(1.5 * counter) (2 * counter) counter]);
    set      (HP, 'linewidth', 1);
end
axis         off tight
tprint       ('./panels/cplotter1', ...
    '-jpg -HR', [10 10]);

%% test 2
clf;
dLPTCs       = load_tree ('dLPTCs.mtr');
for counter  = 1 : length (dLPTCs{1})
    c        = hull_tree (dLPTCs{1}{counter}, 20, [], [], [], '-2d');
    HP       = cplotter  (c, rand (1, 3));
    set      (HP, 'linewidth', 1);
end
axis         off tight equal
tprint       ('./panels/cplotter2', ...
    '-jpg -HR', [10 10]);



