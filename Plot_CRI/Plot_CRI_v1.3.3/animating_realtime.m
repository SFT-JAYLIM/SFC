function L = animating_realtime(Link)
Linknum = size(Link, 2);
L(Linknum, :) = patch('faces', Link{Linknum}.Face, 'vertices' ,Link{Linknum}.Vertice(:,1:3), 'FaceVertexCData', real(Link{Linknum}.color),'FaceColor','interp', 'EdgeColor','none');
for i = 1:size(Link, 2)-1
    L(i, :) = patch('faces', Link{i}.Face, 'vertices' ,Link{i}.Vertice(:,1:3), 'FaceVertexCData', real(Link{i}.color),'FaceColor','interp', 'EdgeColor','none');
end
end