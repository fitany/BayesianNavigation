%Route Planning
%Iteration 2: Learns safety and resource beliefs, but no AI
%Runs route planning simulation

%Parameters: sigma, danger_wt, exploration, beta
%Variables: real grid, belief grid, location, destination
%0:neutral, >0:safe, <0:unsafe, NaN:not a valid location

function bayesianNavigation2()
    clear all;
    %Set parameters
    sigma = 1; %for safety prior
    beta = 1; %for normal prior
    danger_wt = .5;
    exploration = .5;
    alpha = exploration * 100;

    %ui functions and variables
    speed = .2;
    quit = false;
    
    function set_real_grid(points)
        points = round(points);
        real_grid(points(1,2),points(1,1))=str2double(get(danger_edit,'String'));
    end
    function set_speed(sp)
        speed = sp;
    end
    function qt()
        quit = true;
    end

    %Set up figure/UI
    f = figure('Position', [100, 100, 1200, 500]);
    danger_edit = uicontrol('Parent',f,'Style','edit','Position',[60,475,40,23],'String','0');
    danger_text = uicontrol('Parent',f,'Style','text','Position',[10,475,40,23],'String','Danger Rating:');
    qt_ui = uicontrol('Parent',f,'Style','pushbutton','Position',[110,475,40,23],'String','Quit','Callback',@(~,~)qt());
    spd_ui = uicontrol('Parent',f,'Style','slider','Position',[170,473,200,23],'Min',0,'Max',10,'SliderStep',[1 1]./10,...
        'Value',5,'Callback',@(h,~)set_speed(get(h,'Value')));
    health_text = uicontrol('Parent',f,'Style','text','Position',[425,475,70,23],'String','Health: 1000');
    reward_text = uicontrol('Parent',f,'Style','text','Position',[500,475,70,23],'String','Reward: 0');
     
    %Set real and belief grid
    %real_grid = [0 0 50; 0 NaN 0; 0 0 0];
    %belief_grid = [0 0 0; 0 NaN 0; 0 0 0];
    real_grid = [0 0 50 0 0; 0 NaN NaN NaN 0; 0 0 0 0 20; 0 NaN NaN NaN 0; 50 0 0 0 30];
    orig_belief_grid = [0 0 0 0 0; 0 NaN NaN NaN 0; 0 0 0 0 0; 0 NaN NaN NaN 0; 0 0 0 0 0];
    belief_grid = orig_belief_grid;
    %Set home, real resources, belief resources
    home = [1 1];
    real_resources = [1 3 20];
    orig_belief_resources = [1 3 alpha/beta alpha beta 0];%need to keep track of alpha, beta, and total observations
    n = 0;%needed to keep track of number of resource observations. set to 0 after every death
    belief_resources = orig_belief_resources;
    %Set health counter
    health_counter = 1000;
    %Set reward counter
    reward_counter = 0;
    %Set current location and destination
    %curr_loc = [3 3];
    %dest_loc = [1 1];
    curr_loc = [1 1];
    dest_loc = [5 5];

    %Loop through time until whenever
    while true
        if quit
            break
        end
        %plot and wait
        s1 = subplot(1,2,1);
        imgsc = plot_grid(real_grid,curr_loc,dest_loc,home,real_resources);
        ax = imgca;
        set(imgsc,'ButtonDownFcn',@(~,~)set_real_grid(get(ax,'CurrentPoint')),'HitTest','on')
        s2 = subplot(1,2,2);
        plot_grid(belief_grid, curr_loc, dest_loc, home, belief_resources);
        pause(1-speed/11);

        %check whether goal has been reached %change to check whether dead
        if isequal(curr_loc,dest_loc)
            %compare journey with optimal journey and record results
            %set new dest
            dest_loc = new_dest(real_grid);
        else
            %make observation and update belief grid
            safety_observation = randn + real_grid(curr_loc(1),curr_loc(2));
            curr_belief = belief_grid(curr_loc(1),curr_loc(2));
            belief_grid(curr_loc(1),curr_loc(2)) = (curr_belief+safety_observation)/2; %assume sigma = 1
            %make observation and update belief grid for neighbors
            [ neighbors ] = find_neighbors(curr_loc, belief_grid);
            for i = 1:size(neighbors,1)
                safety_neighbor_observation = randn + real_grid(neighbors(i,1),neighbors(i,2));
                curr_belief = belief_grid(neighbors(i,1),neighbors(i,2));
                belief_grid(neighbors(i,1),neighbors(i,2)) = (curr_belief+safety_neighbor_observation)/2; %assume sigma = 1
            end
            %sample resource and update belief_resources
            if sum(ismember(real_resources(:,1:2), curr_loc, 'rows')) > 0
                resource_row = find(ismember(real_resources(:,1:2), curr_loc, 'rows'));
                resource_observation = exprnd(real_resources(resource_row,3));
                belief_resources(resource_row,6) = belief_resources(resource_row,6)+resource_observation;
                belief_resources(resource_row,5) = belief_resources(resource_row,5)+belief_resources(resource_row,6);
                belief_resources(resource_row,4) = belief_resources(resource_row,4)+n;
                n = n+1;
                belief_resources(resource_row,3) = round(1/(belief_resources(resource_row,4)-1)/belief_resources(resource_row,5)+belief_resources(resource_row,6))
                reward_counter = round(reward_counter + resource_observation);
                set(reward_text, 'String', strcat('Reward: ',num2str(reward_counter)));
            end
            %update health counter
            if real_grid(curr_loc(1),curr_loc(2)) > 0
                health_counter = round(health_counter - 1 - safety_observation);
            else
                health_counter = health_counter - 1;
            end
            set(health_text, 'String', strcat('Health: ',num2str(health_counter)));
            %calculate routes
            routes = calculate_routes(curr_loc,dest_loc,belief_grid);
            %calculate safety belief of each route
            danger_ratings = zeros(1,size(routes,1));
            for i =1:size(routes,1)
                route = routes{i};
                idx = sub2ind(size(belief_grid), route(:,1), route(:,2));
                danger_ratings(i) = sum(belief_grid(idx));
            end
            %calculate distance of each route
            distances = zeros(1,size(routes,1));
            for i =1:size(routes,1)
                route = routes{i};
                distances(i) = size(route,1);
            end
            %calculate desired route based on safety and distance
            desirability = danger_wt .* danger_ratings + distances;
            [b,ind] = sort(desirability,'ascend');
            %take a step in the desired direction
            curr_loc = routes{ind(1)}(2,:);
        end
    end

%Plot difference in safety/efficiency of actual vs optimal route taken as a function of time
end