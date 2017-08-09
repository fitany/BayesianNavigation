%input: current location, belief grid
%output: all valid neighboring locations to current location, expressed as
%an nx2 vector with x coordinates in col 1 and y coordinates in col 2.
function [ neighbors ] = find_neighbors(curr_loc, belief_grid)
    neighbors = [];
    %add left neighbor
    if curr_loc(1,1) > 1 && ~isnan(belief_grid(curr_loc(1,1)-1, curr_loc(1,2)))
        neighbors = [neighbors; curr_loc(1,1)-1, curr_loc(1,2)];
    end
    %add right neighbor
    if curr_loc(1,1) < size(belief_grid,2) && ~isnan(belief_grid(curr_loc(1,1)+1, curr_loc(1,2)))
        neighbors = [neighbors; curr_loc(1,1)+1, curr_loc(1,2)];
    end
    %add top neighbor
    if curr_loc(1,2) > 1 && ~isnan(belief_grid(curr_loc(1,1), curr_loc(1,2)-1))
        neighbors = [neighbors; curr_loc(1,1), curr_loc(1,2)-1];
    end
    %add bottom neighbor
    if curr_loc(1,2) < size(belief_grid,1) && ~isnan(belief_grid(curr_loc(1,1), curr_loc(1,2)+1))
        neighbors = [neighbors; curr_loc(1,1), curr_loc(1,2)+1];
    end
end

