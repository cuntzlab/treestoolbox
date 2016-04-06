%% check_gene_tree

%% test 1
clf;
dLPTCs           = load_tree ('dLPTCs.mtr');
gene_tree        (dLPTCs, '-s');
axis             off tight;
tprint           ('./panels/gene_tree1', ...
    '-jpg -HR',                [10 30]);

%% test 2
clf;
hold             on;
gene             = gene_tree ({{sample2_tree}}, '-s');
display          (gene{1});
axis             off;
tprint           ('./panels/gene_tree2', ...
    '-jpg -HR',                [10 10]);