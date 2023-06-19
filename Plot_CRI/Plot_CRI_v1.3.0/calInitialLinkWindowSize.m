function [WindowSize] = calInitialLinkWindowSize(Link)

for i = 1:size(Link, 2)
    if i == 1
        Xmin = min(Link{i}.Vertice(:, 1));
        Xmax = max(Link{i}.Vertice(:, 1));
        Ymin = min(Link{i}.Vertice(:, 2));
        Ymax = max(Link{i}.Vertice(:, 2));
        Zmin = min(Link{i}.Vertice(:, 3));
        Zmax = max(Link{i}.Vertice(:, 3));
    else
        Xmin = min(Xmin, min(Link{i}.Vertice(:, 1)));
        Xmax = max(Xmax, max(Link{i}.Vertice(:, 1)));
        Ymin = min(Ymin, min(Link{i}.Vertice(:, 2)));
        Ymax = max(Ymax, max(Link{i}.Vertice(:, 2)));
        Zmin = min(Zmin, min(Link{i}.Vertice(:, 3)));
        Zmax = max(Zmax, max(Link{i}.Vertice(:, 3)));
    end
end

WindowSize = [Xmin, Xmax, Ymin, Ymax, Zmin, Zmax];

end