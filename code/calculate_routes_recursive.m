%input: destination location, visited locations (empty at first call),routes belief grid
%output: cell array with routes. a route of length n is a matrix of nx2
%with x coordinates in column 1 and y coordinates in column 2.
%using algorithm from http://stackoverflow.com/questions/58306/graph-algorithm-to-find-all-connections-between-two-arbitrary-vertices
function [routes] = calculate_routes_recursive(dest_loc, visited, belief_grid)
    routes = {};
    nodes = find_neighbors(visited(size(visited,1),:),belief_grid);
    for i = 1:size(nodes,1)
        node = nodes(i,:);
        if ismember(visited,node,'rows')
            continue;
        end
        if isequal(node,dest_loc)
            visited = [visited; node];
            routes = [routes;visited];
            visited(size(visited,1),:) = [];
            break;
        end
    end    
    for i = 1:size(nodes,1)
        node = nodes(i,:);
        %member = sum(builtin('_ismemberoneoutput',visited, node),2)==2;
        if sum(ismember(visited,node,'rows')) || isequal(node,dest_loc)
        %if sum(member) || isequal(node,dest_loc)
            continue
        end
        visited = [visited; node];
        routes = [routes; calculate_routes_recursive(dest_loc, visited, belief_grid)];
        visited(size(visited,1),:) = [];
    end
end