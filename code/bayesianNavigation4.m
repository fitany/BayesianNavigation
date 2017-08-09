%Route Planning
%Iteration 4: Same as 3 but comment out UI
%Runs route planning simulation

%Parameters: sigma, danger_wt, exploration, beta, start_health
%Variables: real grid, belief grid, location, destination
%0:neutral, >0:safe, <0:unsafe, NaN:not a valid location

function rewards = bayesianNavigation4(real_grid,home,real_resources,exploration,time)
    %Set parameters
    sigma = 1; %for safety prior
    beta = 1; %for resource prior
    danger_wt = .5;
    %exploration = .9;
    alpha = exploration * 100; %for resource prior
    default_health = 50;
    
    %Set tracking variable
    rewards = [];

    %ui functions and variables
    %speed = .2;
    %quit = false;
    %{
    function set_real_grid(points)
        points = round(points);
        real_grid(points(1,2),points(1,1))=str2double(get(danger_edit,'String'));
    end
    function set_speed(sp)
        speed = sp;
    end
    function qt()
        quit = true;
        rewards = [rewards reward_counter]
    end

    %Set up figure/UI
    f = figure('Position', [100, 100, 1200, 500]);
    danger_edit = uicontrol('Parent',f,'Style','edit','Position',[60,475,40,23],'String','0');
    danger_text = uicontrol('Parent',f,'Style','text','Position',[10,475,40,23],'String','Danger Rating:');
    qt_ui = uicontrol('Parent',f,'Style','pushbutton','Position',[110,475,40,23],'String','Quit','Callback',@(~,~)qt());
    spd_ui = uicontrol('Parent',f,'Style','slider','Position',[170,473,200,23],'Min',0,'Max',10,'SliderStep',[1 1]./10,...
        'Value',5,'Callback',@(h,~)set_speed(get(h,'Value')));
    health_text = uicontrol('Parent',f,'Style','text','Position',[425,475,70,23],'String',strcat('Health: ',num2str(default_health)));
    reward_text = uicontrol('Parent',f,'Style','text','Position',[500,475,70,23],'String','Reward: 0');
    %} 
    %Set real and belief grid
    orig_belief_grid = real_grid;
    orig_belief_grid(~isnan(real_grid)) = 0;
    belief_grid = orig_belief_grid;
    orig_belief_resources = real_resources(:,1:2);
    orig_belief_resources = [orig_belief_resources repmat([alpha/beta alpha beta 0 0],size(real_resources,1),1)];
    belief_resources = orig_belief_resources;
    %{
    real_grid = [0 0 50 0 0; 0 NaN NaN NaN 0; 0 0 0 0 20; 0 NaN NaN NaN 0; 50 0 0 0 30];
    orig_belief_grid = [0 0 0 0 0; 0 NaN NaN NaN 0; 0 0 0 0 0; 0 NaN NaN NaN 0; 0 0 0 0 0];
    belief_grid = orig_belief_grid;
    %Set home, real resources, belief resources
    home = [1 1];
    real_resources = [1 3 20; 3 3 80];
    orig_belief_resources = [1 3 alpha/beta alpha beta 0 0; 3 3 alpha/beta alpha beta 0 0];%need to keep track of mu, alpha, beta, total observations, n
    belief_resources = orig_belief_resources;
    %}
    
    %Set health counter
    health_counter = default_health;
    %Set reward counter
    reward_counter = 0;
    %Set current location and destination
    curr_loc = home;
    dest_loc = new_dest2(belief_grid, belief_resources, curr_loc, home, health_counter, exploration);

    %Loop through time until whenever
    t = 0;
    %while true
    while t<time
        t = t+1;
%        if quit
%            break
%        end
        %plot and wait
        %s1 = subplot(1,2,1);
        %imgsc = plot_grid(real_grid,curr_loc,dest_loc,home,real_resources);
        %ax = imgca;
        %set(imgsc,'ButtonDownFcn',@(~,~)set_real_grid(get(ax,'CurrentPoint')),'HitTest','on')
        %s2 = subplot(1,2,2);
        %plot_grid(belief_grid, curr_loc, dest_loc, home, belief_resources);
        %pause(1-speed/11);

        %change to check whether dead
        if health_counter < 0
            %record results
            rewards = [rewards reward_counter];
            %reset location back to home
            curr_loc = home;
            %restore health
            health_counter = default_health;
            if real_grid(curr_loc(1),curr_loc(2)) > 0
                health_counter = round(health_counter - 1 - round(safety_observation/10));
            else
                health_counter = health_counter - 1;
            end
            %set(health_text, 'String', strcat('Health: ',num2str(health_counter)));
            %reset rewards
            reward_counter = 0;
            %set(reward_text, 'String', strcat('Reward: ',num2str(reward_counter)));
            %reset beliefs
            belief_resources = orig_belief_resources;
            belief_grid = orig_belief_grid;
            %set new dest
            dest_loc = new_dest2(belief_grid, belief_resources, curr_loc, home, health_counter, exploration);
        else
            if isequal(curr_loc,dest_loc)
                %set new dest
                dest_loc = new_dest2(belief_grid, belief_resources, curr_loc, home, health_counter, exploration);
            end;
            %restore health if reached home
            if isequal(curr_loc,home)
                health_counter = default_health;
                %set(health_text, 'String', strcat('Health: ',num2str(health_counter)));
            end;
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
            %member = sum(builtin('_ismemberoneoutput',real_resources(:,1:2), curr_loc),2)==2;
            %if sum(member) > 2
                %resource_row = find(member);
                resource_row = find(ismember(real_resources(:,1:2), curr_loc, 'rows'));
                resource_observation = exprnd(real_resources(resource_row,3));
                belief_resources(resource_row,6) = belief_resources(resource_row,6)+resource_observation;
                belief_resources(resource_row,5) = belief_resources(resource_row,5)+belief_resources(resource_row,6);
                belief_resources(resource_row,4) = belief_resources(resource_row,4)+belief_resources(resource_row,7);
                belief_resources(resource_row,7) = belief_resources(resource_row,7) + 1;
                belief_resources(resource_row,3) = round(1/(belief_resources(resource_row,4)-1)/belief_resources(resource_row,5)+belief_resources(resource_row,6));
                reward_counter = round(reward_counter + resource_observation);
                %set(reward_text, 'String', strcat('Reward: ',num2str(reward_counter)));
            end
            %update health counter
            if real_grid(curr_loc(1),curr_loc(2)) > 0
                health_counter = round(health_counter - 1 - round(safety_observation/10));
            else
                health_counter = health_counter - 1;
            end
            %set(health_text, 'String', strcat('Health: ',num2str(health_counter)));
            %calculate routes
            routes = calculate_routes(curr_loc,dest_loc,belief_grid);
            %calculate safety belief of each route
            danger_ratings = zeros(1,size(routes,1));
            for i =1:size(routes,1)
                route = routes{i};
                idx = sub2ind(size(belief_grid), route(:,1), route(:,2));
                danger_ratings(i) = sum(round(belief_grid(idx)./10));
            end
            %calculate distance of each route
            distances = zeros(1,size(routes,1));
            for i =1:size(routes,1)
                route = routes{i};
                distances(i) = size(route,1);
            end
            %calculate desired route based on safety and distance
            desirability = danger_ratings + distances;
            [b,ind] = sort(desirability,'ascend');
            %take a step in the desired direction
            curr_loc = routes{ind(1)}(2,:);
        end
    end
end