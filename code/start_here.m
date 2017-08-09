
%Run any of the following commands to view the simulation

%Start original simulation
bayesianNavigation

%Load small map and start simulation with exploration = .5
load 'small_explore.mat'
bayesianNavigation3(real_grid,home,real_resources,.5)

%exploration = .01
bayesianNavigation3(real_grid,home,real_resources,.01)

%exploration = .99
bayesianNavigation3(real_grid,home,real_resources,.99)