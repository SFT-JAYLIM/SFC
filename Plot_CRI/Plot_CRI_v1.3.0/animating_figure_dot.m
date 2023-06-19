function animating_figure_dot(Link, RobotInfo)

for i = 1:size(Link, 2)
    patch('faces', Link{i}.Face, 'vertices' ,Link{i}.Vertice(:,1:3), 'facec', [0.7 0.5 1.0], 'EdgeColor','none', 'facealpha', 0.3);
end

hold on
LinkCount = 0;
EECount = 0;
for jointloop = 1:size(RobotInfo.ColliJoint, 2)
    ImpactPosVec = Link{RobotInfo.ColliJoint(jointloop) + 1}.TBList * [RobotInfo.ColliPos(jointloop, :), 1]';
    ImpactPosVec = ImpactPosVec(1:3, :);
    
    MarkerSize = 5;
    
    if RobotInfo.ColliJoint(jointloop) == 6
        EECount = EECount + 1;
        P = plot3(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), 'o', 'MarkerSize', MarkerSize, 'LineWidth', 5, 'Color', RobotInfo.EEColor(EECount));
        T = text(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), strcat('    -----------------',num2str(jointloop)), 'Color', P.Color, 'FontSize', 12, 'FontWeight','bold');
    else
        LinkCount =  LinkCount + 1;
        if RobotInfo.CheckBox(LinkCount)
            P = plot3(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), 'o', 'MarkerSize', MarkerSize, 'LineWidth', 5, 'Color', RobotInfo.LinkColor(LinkCount));
            T = text(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), strcat('     -----------------',num2str(jointloop)), 'Color', P.Color, 'FontSize', 12, 'FontWeight','bold');
        end
    end
    
    % P를 가장 위로 올리기
    uistack(P, 'top');
end

% 원점 좌표축 만들기
Ori_Pos = [0; 0; 0];

Ori_XPos = [100; 0; 0];
Ori_YPos = [0; 100; 0];
Ori_ZPos = [0; 0; 100];

OriText_XPos = [110; 0; 0];
OriText_YPos = [0; 110; 0];
OriText_ZPos = [0; 0; 110];

line([Ori_Pos(1) Ori_XPos(1)], [Ori_Pos(2) Ori_XPos(2)], [Ori_Pos(3) Ori_XPos(3)], 'LineWidth', 5, 'Color', [1 0 0]); % x Line
text(OriText_XPos(1), OriText_XPos(2), OriText_XPos(3), 'X','FontSize', 20, 'Color', [1 0 0]);

line([Ori_Pos(1) Ori_YPos(1)], [Ori_Pos(2) Ori_YPos(2)], [Ori_Pos(3) Ori_YPos(3)], 'LineWidth', 5, 'Color', [0 1 0]); % x Line
text(OriText_YPos(1), OriText_YPos(2), OriText_YPos(3), 'Y','FontSize', 20, 'Color', [0 1 0]);

line([Ori_Pos(1) Ori_ZPos(1)], [Ori_Pos(2) Ori_ZPos(2)], [Ori_Pos(3) Ori_ZPos(3)], 'LineWidth', 5, 'Color', [0 0 1]); % x Line
text(OriText_ZPos(1), OriText_ZPos(2), OriText_ZPos(3), 'Z','FontSize', 20, 'Color', [0 1 0]);


% End Effector 좌표축 만들기
EE_pos = Link{end}.TBList(1:3,4);
EE_XPos = EE_pos + Link{end}.TBList(1:3,1:3) * [100; 0; 0];
EE_YPos = EE_pos + Link{end}.TBList(1:3,1:3) * [0; 100; 0];
EE_ZPos = EE_pos + Link{end}.TBList(1:3,1:3) * [0; 0; 100];

EEText_XPos = EE_pos + Link{end}.TBList(1:3,1:3) * [110; 0; 0];
EEText_YPos = EE_pos + Link{end}.TBList(1:3,1:3) * [0; 110; 0];
EEText_ZPos = EE_pos + Link{end}.TBList(1:3,1:3) * [0; 0; 110];
line([EE_pos(1) EE_XPos(1)], [EE_pos(2) EE_XPos(2)], [EE_pos(3) EE_XPos(3)], 'LineWidth', 5, 'Color', [1 0 0]); % x Line
text(EEText_XPos(1), EEText_XPos(2), EEText_XPos(3), 'X','FontSize', 20, 'Color', [1 0 0]);

line([EE_pos(1) EE_YPos(1)], [EE_pos(2) EE_YPos(2)], [EE_pos(3) EE_YPos(3)], 'LineWidth', 5, 'Color', [0 1 0]); % y Line
text(EEText_YPos(1), EEText_YPos(2), EEText_YPos(3), 'Y','FontSize', 20, 'Color', [0 1 0]);

line([EE_pos(1) EE_ZPos(1)], [EE_pos(2) EE_ZPos(2)], [EE_pos(3) EE_ZPos(3)], 'LineWidth', 5, 'Color', [0 0 1]); % z Line
text(EEText_ZPos(1), EEText_ZPos(2), EEText_ZPos(3), 'Z','FontSize', 20, 'Color', [0 0 1]);

end