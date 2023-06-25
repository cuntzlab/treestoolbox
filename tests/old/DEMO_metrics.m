% DEMOs reference


%% scale1_tree
clf; shine;
for ward = 1:5,
    HP = plot_tree(scale_tree(sample2_tree,[1+(ward-1)/8 1 1]),[],[],[],32);
    set(HP,'facealpha',ward/10);
end
axis off tight
tprint ('DEMO_scale1_tree','-tif -HR',[20 20]);

%% sholl_tree
clf; shine;
sholl_tree (sample2_tree, 20,'-s');
title ('');legend off;
tprint ('DEMO_sholl_tree','-tif -HR',[20 20]);

%% sholl_tree
clf; shine;
sholl_tree (sample2_tree, 20,'-3s');
axis off;title ('');legend off;
tprint ('DEMO_sholl2_tree','-tif -HR',[20 20]);


%% surf_tree
clf; shine;
HP = plot_tree(sample2_tree,surf_tree(sample2_tree));
HT = vtext_tree(sample2_tree,round(surf_tree(sample2_tree)));
set(HT,'color',[0 0 0],'fontsize',18);
set(HP,'facealpha',.2);
axis off tight
tprint ('DEMO_surf_tree','-tif -HR',[20 20]);
%% tran_tree
clf; shine;
for ward = 1:5,
    HP = plot_tree(tran_tree(sample2_tree,[(ward-1)*10 0 0]),[],[],[],32);
    set(HP,'facealpha',ward/10);
end
axis off tight
tprint ('DEMO_tran1_tree','-tif -HR',[20 20]);
%% vol_tree
clf; shine;
HP = plot_tree(sample2_tree,vol_tree(sample2_tree));
HT = vtext_tree(sample2_tree,round(vol_tree(sample2_tree)));
set(HT,'color',[0 0 0],'fontsize',18);
set(HP,'facealpha',.2);
axis off tight
tprint ('DEMO_vol_tree','-tif -HR',[20 20]);

%% zcorr_tree
clf; shine;
sample2 = sample2_tree; isub = find(sub_tree (sample2_tree, 5));
sample2.Z(isub) = sample2.Z(isub)-20;
HP = plot_tree(sample2,[],[],[],32);
HT = vtext_tree(sample2);
set(HT,'color',[0 0 0],'fontsize',18);
set(HP,'facealpha',.2);
axis off tight
view([0 45])
tprint ('DEMO_zcorr1_tree','-tif -HR',[20 20]);

%% zcorr_tree
clf; shine;
sample2 = sample2_tree; isub = find(sub_tree (sample2_tree, 5));
sample2.Z(isub) = sample2.Z(isub)-20;
sample2 = zcorr_tree(sample2,15);
HP = plot_tree(sample2,[],[],[],32);
HT = vtext_tree(sample2);
set(HT,'color',[0 0 0],'fontsize',18);
set(HP,'facealpha',.2);
axis off tight
view([0 45])
tprint ('DEMO_zcorr2_tree','-tif -HR',[20 20]);
