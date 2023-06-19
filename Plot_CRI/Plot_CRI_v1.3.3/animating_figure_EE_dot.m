function animating_figure_EE_dot(Link, RobotInfo)

patch('faces', Link{end}.Face, 'vertices' ,Link{end}.OriVertice(:,1:3), 'facec', [0.7 0.5 1.0], 'EdgeColor','none', 'facealpha', 0.3);
hold on
EECount = 0;
for jointloop = 1:size(RobotInfo.ColliJoint, 2)
    ImpactPosVec = RobotInfo.ColliPos(jointloop, :)';

    MarkerSize = 5;

    if RobotInfo.PointType(jointloop) == 1
        EECount = EECount + 1;
        P = plot3(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), 'o', 'MarkerSize', MarkerSize, 'LineWidth', 3, 'Color', RobotInfo.EEColor{EECount});
        text(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), strcat('      -----------------',num2str(EECount)), 'Color', P.Color, 'FontSize', 12, 'FontWeight','bold');
        
        % P를 가장 위로 올리기
        uistack(P, 'top');
    end
end

% End Effector 좌표축 만들기
EE_pos = [0; 0; 0];
EE_XPos = EE_pos + [100; 0; 0];
EE_YPos = EE_pos + [0; 100; 0];
EE_ZPos = EE_pos + [0; 0; 100];

EEText_XPos = EE_pos + [110; 0; 0];
EEText_YPos = EE_pos + [0; 110; 0];
EEText_ZPos = EE_pos + [0; 0; 110];
line([EE_pos(1) EE_XPos(1)], [EE_pos(2) EE_XPos(2)], [EE_pos(3) EE_XPos(3)], 'LineWidth', 5, 'Color', [1 0 0]); % x Line
text(EEText_XPos(1), EEText_XPos(2), EEText_XPos(3), 'X','FontSize', 20, 'Color', [1 0 0]);

line([EE_pos(1) EE_YPos(1)], [EE_pos(2) EE_YPos(2)], [EE_pos(3) EE_YPos(3)], 'LineWidth', 5, 'Color', [0 1 0]); % y Line
text(EEText_YPos(1), EEText_YPos(2), EEText_YPos(3), 'Y','FontSize', 20, 'Color', [0 1 0]);

line([EE_pos(1) EE_ZPos(1)], [EE_pos(2) EE_ZPos(2)], [EE_pos(3) EE_ZPos(3)], 'LineWidth', 5, 'Color', [0 0 1]); % z Line
text(EEText_ZPos(1), EEText_ZPos(2), EEText_ZPos(3), 'Z','FontSize', 20, 'Color', [0 0 1]);

end