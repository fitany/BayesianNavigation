%Route Planning
%Iteration 1: Only learns the safety level of each location
%Runs route planning simulation

%Parameters: sigma, safety_wt, exploration?, exploitation?
%Variables: real grid, belief grid, location, destination
%0:neutral, >0:safe, <0:unsafe, NaN:not a valid location

function bayesianNavigation()
    clear all;
    
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
    health_text = uicontrol('Parent',f,'Style','text','Position',[425,475,40,23],'String','Health: 1000');
    reward_text = uicontrol('Parent',f,'Style','text','Position',[475,475,40,23],'String','Reward: 30');
     
    %Set parameters
    sigma = 1;
    danger_wt = .5;

    %Set real and belief grid
    %real_grid = [0 0 50; 0 NaN 0; 0 0 0];
    %belief_grid = [0 0 0; 0 NaN 0; 0 0 0];
    real_grid = [0 0 50 0 0; 0 NaN NaN NaN 0; 0 0 0 0 20; 0 NaN NaN NaN 0; 50 0 0 0 30];
    belief_grid = [0 0 0 0 0; 0 NaN NaN NaN 0; 0 0 0 0 0; 0 NaN NaN NaN 0; 0 0 0 0 0];
    %Set home, real resources, belief resources
    home = [1 1];
    real_resources = [1 1 0];
    belief_resources = [1 1 0];
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

        %check whether goal has been reached
        if isequal(curr_loc,dest_loc)
            %compare journey with optimal journey and record results
            %set new dest
            dest_loc = new_dest(real_grid);
        else
            %make safety observation and update belief grid
            observation = randn + real_grid(curr_loc(1),curr_loc(2));
            curr_belief = belief_grid(curr_loc(1),curr_loc(2));
            belief_grid(curr_loc(1),curr_loc(2)) = (curr_belief+observation)/2; %assume sigma = 1
            %make safety observation and update belief grid for neighbors
            [ neighbors ] = find_neighbors(curr_loc, belief_grid);
            for i = 1:size(neighbors,1)
                observation = randn + real_grid(neighbors(i,1),neighbors(i,2));
                curr_belief = belief_grid(neighbors(i,1),neighbors(i,2));
                belief_grid(neighbors(i,1),neighbors(i,2)) = (curr_belief+observation)/2; %assume sigma = 1
            end
            %take resource and update belief_resources
            %update health counter
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