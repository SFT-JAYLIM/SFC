function LinkMat = calLinkMatrix(LinksOrigin, DHparam, solverData, RobotInfo, StartPosition)

% Iteration 횟수
endNum = size(solverData.CRI, 1);

% cell 크기 사전할당
LinkMat{endNum} = move(LinksOrigin, DHparam, RobotInfo, solverData.q_series(1,:), solverData.BasePosition(1,:), StartPosition);

% LinkMat 계산
for i = 1:endNum

    % STL의 Step별 위치 계산
    LinkMat{i} = move(LinksOrigin, DHparam, RobotInfo, solverData.q_series(i,:), solverData.BasePosition(i,:), StartPosition);
    
    % Step별 Plot할 ColliPoint 선정
    SelectColliPoint = [cell2mat(RobotInfo.RobotLinkNum(solverData.MotionDivisionIndex(i) + 1)), cell2mat(RobotInfo.EENum(solverData.MotionDivisionIndex(i) + 1)) + max(cell2mat(RobotInfo.RobotLinkNum(solverData.MotionDivisionIndex(i) + 1)))];

    % NaN값 제거
    SelectColliPoint = rmmissing(SelectColliPoint);
    
    % ImpactPos 추출
    SelectPointNum = size(SelectColliPoint, 2);
    IterationImpactPosData = zeros(SelectPointNum, 3);
    for j = 1:SelectPointNum
        IterationImpactPosData(j, 1:3) = solverData.ImpactPos{SelectColliPoint(j)}(1:3, i);
    end
    
    % CRI 추출
    IterationCRI = zeros(1, SelectPointNum);
    for j = 1:SelectPointNum
        IterationCRI(1, j) = solverData.CRI(i, SelectColliPoint(j));
    end
    
    % ColliJoint 추출
    IterationColliJoint = zeros(1, SelectPointNum);
    for j = 1:SelectPointNum
        IterationColliJoint(1, j) = RobotInfo.ColliJoint(1, SelectColliPoint(j));
    end
    
    % PointType 추출
    IterationPointType = zeros(1, SelectPointNum);
    for j = 1:SelectPointNum
        IterationPointType(1, j) = RobotInfo.PointType(1, SelectColliPoint(j));
    end
    
    LinkMat{i} = calculate_ColorGrid(IterationImpactPosData, IterationCRI, IterationColliJoint, LinkMat{i});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Force 추출
%     IterationForce = zeros(1, SelectPointNum);
%     for j = 1:SelectPointNum
%         IterationForce(1, j) = solverData.Force(i, SelectColliPoint(j));
%     end
%     LinkMat{i} = calculate_ColorGrid(IterationImpactPosData, IterationForce, LinkMat{i}, RobotInfo.ColliJoint);

    % Pressure 추출
%     IterationPressure = zeros(1, SelectPointNum);
%     for j = 1:SelectPointNum
%         IterationPressure(1, j) = solverData.Pressure(i, SelectColliPoint(j));
%     end
%     LinkMat{i} = calculate_ColorGrid(IterationImpactPosData, IterationPressure, LinkMat{i}, RobotInfo.ColliJoint);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
end