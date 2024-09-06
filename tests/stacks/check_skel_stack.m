%% check_skel_stack

%% test 1
clf;
skel_stack   ([], [], '-m -c');
tprint       ('./panels/skel_stack1', ...
    '-jpg -HR',                [10 10]); % documentation


%% test 2
clf;
skel_stack   ([], [], '-m -w');
tprint       ('./panels/skel_stack2', ...
    '-jpg -HR',                [10 10]); % documentation