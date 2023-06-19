function Figure = SetFigureWindows()
% configuration.
% Figure setup data, create a new figure for the GUI
Figure = figure('Position', [0,0,1080,1080], 'Name', '3DAni', 'NumberTitle', 'off','Color', [1 1 1], 'visible', 'on');
% Figure = figure('Position', [0,0,1920,1080], 'Name', '3DAni', 'NumberTitle', 'off','Color', [1 1 1], 'visible', 'on');
ax = gca;
ax.Toolbar.Visible = 'off';

daspect([1 1 1])  % Setting the aspect ratio
colormap(jet);
caxis([0.0, 2.0]);
h = colorbar;
h.Position = [0.85, 0.2, 0.02, 0.6];
h.FontSize = 20;
set(get(h,'title'),'string','CRI');
set(gca,'XColor', 'none','YColor','none','ZColor','none')
grid off;
light('Position',[1 0.5 0.5]);
light
material('dull');
hold on;

cameratoolbar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% caxis([0, 520]);
% set(get(h,'title'),'string','Force');

% caxis([0, 540]);
% set(get(h,'title'),'string','Pressure');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end