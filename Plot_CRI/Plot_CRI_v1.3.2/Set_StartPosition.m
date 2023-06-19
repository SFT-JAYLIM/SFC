function StartPosition = Set_StartPosition(RobotInfo)

Theta = zeros(1, 4);
Theta(1) = pi / 2;
Theta(2) = pi / 2 + RobotInfo.BaseRotation(1);
Theta(3) = pi / 2 + RobotInfo.BaseRotation(2);
Theta(4) = RobotInfo.BaseRotation(3);

alpha = zeros(1, 4);
alpha(1) = pi / 2;
alpha(2) = pi / 2;
alpha(3) = pi / 2;
alpha(4) = 0;

Rotation = eye(3, 3);
for i = 1:4
    c = cos(Theta(i));
    s = sin(Theta(i));
    ca = cos(alpha(i));
    sa = sin(alpha(i));
    Rotation = Rotation * [c -s*ca s*sa; s c*ca -c*sa; 0 sa ca];
end

StartPosition = [Rotation, RobotInfo.BasePlanePosition'; 0, 0, 0, 1];

end