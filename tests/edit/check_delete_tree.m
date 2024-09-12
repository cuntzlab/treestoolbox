%% check_delete_tree

%% test 1
dLPTCs       = load_tree ('dLPTCs.mtr');
for counterN = 1 : 10
    for counter      = 1 : length (dLPTCs{1})
        delete_tree  (dLPTCs{1}{counter}, ...
            find     (BO_tree (dLPTCs{1}{counter}) > 5), 'none');
    end
end

%% test 2
tree         = sample2_tree;
delete_tree  (tree, [], '-w -s');

%% test 3
tree         = sample_tree;
delete_tree  (tree, ...
    find     (BO_tree (tree) > 5), '-w -s');
tprint       ('./panels/delete_tree1', ...
    '-jpg -HR',                [10 10]);    % documentation

%% test 4 - check that right regions are deleted:
tree         = sample_tree;
clf; hold on;
subplot      (2, 2, 1);
xplore_tree  (delete_tree (tree, find (tree.R == 1)), '-2');
colorbar
subplot      (2, 2, 2);
xplore_tree  (delete_tree (tree, find (tree.R == 2)), '-2');
colorbar
subplot      (2, 2, 3);
xplore_tree  (delete_tree (tree, find (tree.X > 90)), '-2');
colorbar
subplot      (2, 2, 4);
xplore_tree  (delete_tree (tree, find (tree.X > 50)), '-2');
colorbar
tprint       ('./panels/delete_tree2', ...
    '-jpg -HR',                [10 10]);

% NOTE! THAT DOESN'T WORK ANYMORE?

% %% test 5 -  delete root when branch point:
% tree         = sample_tree;
% dtree        = delete_tree (tree, [2 3]); % make root BP
% ddtree       = delete_tree (dtree, 1, '-s');    % delete root: two trees!
% tprint       ('./panels/delete_tree3', ...
%     '-jpg -HR',                [10 10]);
% clf;
% subplot      (2, 1, 1);
% plot_tree    (ddtree{1}, BO_tree (ddtree{1}));
% plot_tree    (ddtree{2}, BO_tree (ddtree{2}));
% colorbar;
% subplot      (2, 1, 2);
% xplore_tree  (ddtree{1}, '-2');
% xplore_tree  (ddtree{2}, '-2');
% tprint       ('./panels/delete_tree4', ...
%     '-jpg -HR',                [10 10]);


