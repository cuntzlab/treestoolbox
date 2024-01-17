% DEMOs reference

stack = load_stack('stack2.stk','-s');
tree = load_tree ('tree2.mtr','-s');


%% fitD1_stack
clf; shine;
HP = show_stack (stack); colormap gray
HP = plot_tree(tree,[1 0 0],[],[],32);set(HP,'facealpha',.5);
view(2); axis off tight;
tprint ('DEMO_fitD1_stack','-tif -HR',[20 20]);

%% fitD2_stack
clf; shine;
HP = show_stack (stack); colormap gray
D = fitD_stack (tree, stack, 50); tree1 = tree; tree1.D = D;
HP = plot_tree(tree1,[1 0 0],[],[],32);set(HP,'facealpha',.5);
view(2); axis off tight;
tprint ('DEMO_fitD2_stack','-tif -HR',[20 20]);




%% show_stack
clf; shine;
HP = show_stack (stack); colormap gray
view(3); axis off tight;
tprint ('DEMO_show_stack','-tif -HR',[20 20]);

%% skel_stack
[X, Y, Z] = skel_stack (stack.M{1}, 100);
%%
clf; shine; hold on;
HP = show_stack (stack); colormap gray
plot3(Y,X,Z,'r.')
view(3); axis off tight;
tprint ('DEMO_skel_stack','-tif -HR',[20 20]);