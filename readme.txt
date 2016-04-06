Main issues, not entirely completed files:

- clone_tree, gscale_tree
- stats_tree, dstats_tree
- neurolucida_tree
- simplified hull/vhull for quick and XYZ
- profile the GUI
- delete_tree: issue with regions


(B=bug, BB= serious bug) and suggested improvements (N=new)

Known issues:
- B redirect_tree: after deleting the root redirect does not work
- B quaddiameter_tree: was fitted only to approx 1000um, beyond that does nonsense
- N branch_tree: a function which returns the nodes of a branch, input is a node from the branch
- N strahler_tree: calculate strahler order
- N etau_tree/cap_tree: time course of current injection (non-steady-state electrotonics)
- N diameter-related and other statistics
- N plot_tree: no alpha mapping
- B cyl_tree: has no '-s' option
- B ver_tree: does not have input in trees array
- N insert_tree: output where new nodes went in new tree
- B neuron_tree: replace underscore region names

GUI related:
- N export GUI axes to matlab '.fig'
- N ele_ panel:
  .electrode positions and names;
  .synapse positions and names;
  .electrical synapses connecting two cells
  .simple neuron run_ function
- N cam_ panel:
  . create camera paths
  . export to povray and blender for movies
  . internal movie function
- BB jumpy rotation
- B printing page size not under my control
- N until now: zmaxcursoronstack looks only at active stack
- N sdiametertestimage not implemented
- BB colorbar crashes when left on
- stk_ edit: cutout in 2 dimension (shift-c) does not always work

- specific GUI problem identification:
  .vis_cla line ~497 colorbar
  .vis_tight problem line ~540
  .vis_cbar line ~670 colorbar
  .vis_jpg can't set page size
  .vis_cmap_t5/t0 cbar problems line ~896
  .incorporate_tree malfunction line ~5538
  .cat_cleartree colorbar line ~1738


New functions:
- neuron_template_tree
- updated soma_tree