function dest = new_dest2(grid, resources, curr_loc, home, health, exploration)
    %calculate health needed to get home 
    %calculate routes
    routes = calculate_routes(curr_loc,home,grid);
    %calculate damage belief of each route
    danger_ratings = zeros(1,size(routes,1));
    for i =1:size(routes,1)
        route = routes{i};
        idx = sub2ind(size(grid), route(:,1), route(:,2));
        danger_ratings(i) = sum(grid(idx));
    end
    danger_ratings = round(danger_ratings/10); %adjust for toy map
    %calculate distance of each route
    distances = zeros(1,size(routes,1));
    for i =1:size(routes,1)
        route = routes{i};
        distances(i) = size(route,1);
    end
    %sum distance and damage
    dist_dam = distances + danger_ratings;
    %min of this is minimum health needed
    health_needed = min(dist_dam);
    
    %A more exploitative/scared agent wants a bigger buffer
    buffer = (1 - exploration)*10;
    health_needed = health_needed + buffer;
    
    if health <= health_needed
        dest = home;
    else
        %a more explorative agent will pick a random resource
        if rand < exploration
            dest = resources(randi([1 size(resources,1)]),1:2);
        %a more exploitative agent will pick the resource with greatest payoff
        else
            [M,I] = max(resources(:,3));
            dest = resources(I,1:2);
        end
    end
end