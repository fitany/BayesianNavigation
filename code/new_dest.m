%input: grid
%output: row and col of destination location
function [dest_loc] = new_dest(grid)
    valid = 0;
    while ~valid
        rand_row = randi([1 size(grid,1)]);
        rand_col = randi([1 size(grid,2)]);
        if ~isnan(grid(rand_row,rand_col))
            dest_loc = [rand_row rand_col];
            valid = 1;
        end
    end
end

