%% check_load_stack

%% test 1
stack            = load_stack ('sample.stk', '-s');
tprint           ('./panels/load_stack1', ...
    '-jpg -HR',                [10 10]);    % documentation

