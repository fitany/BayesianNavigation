%plots imagesc of grid with NaNs as white
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/140607
function imgsc = plot_grid(grid, curr_loc, dest_loc, home, resources)
    maxval = 110;
    grid(isnan(grid)) = maxval + maxval/10;
    imgsc = imagesc(grid);
    caxis([-100 110]);
    set(gca,'ytick',1:size(grid,1));
    set(gca,'xtick',1:size(grid,2));
    colordata = colormap;
    colordata(end,:) = [.75 .75 .75];
    colormap(colordata);
    resource_colormap = flipud(winter(101));
    hold on;
    for i = 1:size(resources,1)
        p = plot(resources(i,2),resources(i,1),'p','markersize', 60);
        set(p,'MarkerFaceColor',resource_colormap(min(100,resources(i,3)+1),:));
    end
    plot(curr_loc(2),curr_loc(1),'black.-','markersize', 30);
    plot(dest_loc(2),dest_loc(1),'black*-','markersize', 30);
    rectangle('position',[home(2)-.5 home(1)-.5 1 1],'edgecolor','k','LineWidth',2)
    hold off;
end

