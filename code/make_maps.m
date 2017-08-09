%make_maps.m
%generates all maps for this experiment

%make small toy map
clear all;
real_grid = [0 0 50 0 0; 0 NaN NaN NaN 0; 0 0 0 0 20; 0 NaN NaN NaN 0; 50 0 0 0 30];
home = [1 1];
real_resources = [1 3 20; 3 3 80];
save('small.mat');

%make toy map good for explorers
clear all
real_grid = [0 0 0 0 0; 0 NaN NaN NaN 50; 0 0 0 50 0; 50 NaN NaN NaN 50; 0 50 0 50 0];
home = [1 1];
real_resources = [1 2 10; 3 1 30; 3 5 99; 5 1 99; 5 5 99];
save('small_explore.mat');

%make toy map good for exploiters
clear all;
real_grid = [0 0 0 0 0; 0 NaN NaN NaN 50; 0 0 0 50 0; 50 NaN NaN NaN 50; 0 50 0 50 0];
home = [1 1];
real_resources = [1 2 10; 3 1 20; 3 5 10; 5 1 10; 5 5 10];
save('small_exploit.mat');

%make toy map good for in-betweeners
clear all;
real_grid = [0 0 0 0 0; 0 NaN NaN NaN 50; 0 0 0 50 0; 50 NaN NaN NaN 50; 0 50 0 50 0];
home = [1 1];
real_resources = [1 2 10; 3 1 30; 3 5 10; 5 1 90; 5 5 10];
save('small_middle.mat');

%make blank aldrich map
clear all;
real_grid = [0 0 0 0 0 0 0 0 0 0;...
             0 NaN NaN NaN NaN NaN NaN 0 NaN 0;...
             0 0 0 0 0 0 0 0 0 0;...
             0 NaN 0 NaN NaN NaN NaN 0 NaN 0;...
             0 0 0 NaN NaN NaN NaN 0 NaN 0;...
             0 NaN 0 NaN NaN NaN NaN 0 NaN 0;...
             0 0 0 NaN NaN NaN NaN 0 NaN 0;...
             0 NaN 0 0 0 0 0 0 0 0;...
             0 NaN 0 NaN NaN NaN NaN 0 NaN 0;...
             0 0 0 0 0 0 0 0 0 0];                         
home = [1 1];
real_resources = [1 3 20; 3 3 80];
save('aldrich_blank.mat');