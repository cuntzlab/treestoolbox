%% check_neurolucida_tree

%% test 1
clf;
neurolucida_tree('./test files/twop9purks.ASC', '-s');
tprint           ('./panels/neurolucida_tree1', ...
    '-jpg -HR',                [10 10]);	% documentation

%% test 2
neurolucida_tree('./test files/twop9purks.ASC', '-r -c -w -o');



