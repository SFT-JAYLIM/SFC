function [WindowSize] = calLinkWindowSize(Link, WindowSize)

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

if WindowSize(1) > Xmin
    WindowSize(1) = Xmin;
end
if WindowSize(3) > Ymin
    WindowSize(3) = Ymin;
end
if WindowSize(5) > Zmin
    WindowSize(5) = Zmin;
end

if WindowSize(2) < Xmax
    WindowSize(2) = Xmax;
end
if WindowSize(4) < Ymax
    WindowSize(4) = Ymax;
end
if WindowSize(6) < Zmax
    WindowSize(6) = Zmax;
end
end