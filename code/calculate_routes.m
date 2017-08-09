%input: current location, destination location, belief grid
%output: cell array with routes. a route of length n is a matrix of nx2
%with x coordinates in column 1 and y coordinates in column 2.
function [routes] = calculate_routes(curr_loc,dest_loc,belief_grid)
    %call the recursive function
    routes = calculate_routes_recursive(dest_loc,curr_loc,belief_grid);
end