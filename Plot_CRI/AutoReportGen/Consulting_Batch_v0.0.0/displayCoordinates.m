function txt = displayCoordinates(~, info, A_Mat)

x = info.Position(1);
y = info.Position(2);
z = info.Position(3);

Result = A_Mat^-1 * [x;y;z;1];

txt = [num2str(Result(1)) ' ' num2str(Result(2)) ' ' num2str(Result(3))]

end