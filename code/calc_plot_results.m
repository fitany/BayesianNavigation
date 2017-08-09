%Calculate and plot results
exploration_vals = [.1 .3 .5 .7 .9];
time = 500;
load('small_explore.mat');
results_explore = {};
for i = 1:length(exploration_vals)
    exploration = exploration_vals(i);
    disp(['Running small explore map, exploration= ' num2str(exploration)])
    results_explore{i} = bayesianNavigation4(real_grid,home,real_resources,exploration,time);
end
load('small_exploit.mat');
results_exploit = {};
for i = 1:length(exploration_vals)
    exploration = exploration_vals(i);
    disp(['Running small exploit map, exploration= ' num2str(exploration)])
    results_exploit{i} = bayesianNavigation4(real_grid,home,real_resources,exploration,time);
end
load('small_middle.mat');
results_middle = {};
for i = 1:length(exploration_vals)
    exploration = exploration_vals(i);
    disp(['Running small middle map, exploration= ' num2str(exploration)])
    results_middle{i} = bayesianNavigation4(real_grid,home,real_resources,exploration,time);
end