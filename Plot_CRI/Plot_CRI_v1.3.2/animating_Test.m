function [L, P] = animating_Test(Link, RobotInfo, ImpactPos, AnalyzeStep, MotionDivisionIndex)

for i = 1:size(Link, 2)
    L(i, :) = patch('faces', Link{i}.Face, 'vertices' ,Link{i}.Vertice(:,1:3), 'FaceVertexCData', real(Link{i}.color),'FaceColor','interp', 'EdgeColor','none');
end

% Step별 Plot할 ColliPoint 선정
SelectColliPoint = [cell2mat(RobotInfo.RobotLinkNum(MotionDivisionIndex(i) + 1)), cell2mat(RobotInfo.EENum(MotionDivisionIndex(i) + 1)) + max(cell2mat(RobotInfo.RobotLinkNum(MotionDivisionIndex(i) + 1)))];

set(gca,'ColorOrderIndex',1) % colororder index 초기화
for jointloop = 1:size(SelectColliPoint, 2)
    if RobotInfo.ColliJoint(jointloop) == 6
        P(jointloop) = plot3(ImpactPos{SelectColliPoint(jointloop)}(1, AnalyzeStep), ImpactPos{SelectColliPoint(jointloop)}(2, AnalyzeStep), ImpactPos{SelectColliPoint(jointloop)}(3, AnalyzeStep), 'o', 'MarkerSize', 30, 'LineWidth',8);
    else
        P(jointloop) = plot3(ImpactPos{SelectColliPoint(jointloop)}(1, AnalyzeStep), ImpactPos{SelectColliPoint(jointloop)}(2, AnalyzeStep), ImpactPos{SelectColliPoint(jointloop)}(3, AnalyzeStep), 'o', 'MarkerSize', 100, 'LineWidth',8);
    end
end

% P를 가장 위로 올리기
uistack(P, 'top');

end