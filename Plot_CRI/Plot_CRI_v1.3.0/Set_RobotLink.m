function Link = Set_RobotLink(DHparam, STLData, RobotInfo, StartPosition)
% STL 데이터들을 모두 원점으로 되돌려서 저장

% Forward Kinematics for Robot
Iteration = size(DHparam.alpha, 2);
TMat = cell(1, Iteration);
for i = 1:Iteration
    TMat{i} = tmat(DHparam.alpha(i), DHparam.a(i), DHparam.d(i), DHparam.STL_Pose(i));
end

if isempty(RobotInfo.RobotModel)
    % Base Only
    STLCentorToDHCentor = [1 0 0 DHparam.STL_Position(1); 0 1 0 DHparam.STL_Position(2); 0 0 1 DHparam.STL_Position(3); 0 0 0 1];
    T_Base = TMat{1} * TMat{2} * TMat{3} * TMat{4} * TMat{5} * TMat{6} * TMat{7} * TMat{8} * TMat{9} * STLCentorToDHCentor;
    TList = {};
    
    % Base STL 이동
    Link{1}.OriVertice = (T_Base \ STLData.Base.V')';
    Link{1}.Face = STLData.Base.F;
    
elseif isempty(RobotInfo.BaseModel)
    % Fixed Base
    T_01 = TMat{1};
    T_12 = TMat{2};
    T_23 = TMat{3};
    T_34 = TMat{4};
    T_45 = TMat{5};
    T_56 = TMat{6};
    TList = {T_01, T_12, T_23, T_34, T_45, T_56};
    
    Link{1}.OriVertice = STLData.Link{1}.V;
    Link{1}.Face = STLData.Link{1}.F;
    
else
    % MobileBase
    STLCentorToDHCentor = [1 0 0 DHparam.STL_Position(1); 0 1 0 DHparam.STL_Position(2); 0 0 1 DHparam.STL_Position(3); 0 0 0 1];
    T_Base = TMat{1} * TMat{2} * TMat{3} * TMat{4} * TMat{5} * TMat{6} * TMat{7} * TMat{8} * TMat{9} * STLCentorToDHCentor;
    T_01 = TMat{10};
    T_12 = TMat{11};
    T_23 = TMat{12};
    T_34 = TMat{13};
    T_45 = TMat{14};
    T_56 = TMat{15};
    TList = {T_01, T_12, T_23, T_34, T_45, T_56};
    
    % Base STL 이동
    Link{1}.OriVertice = [(T_Base \ STLData.Base.V')'; (STLData.Link{1}.V')'];
    Link{1}.Face = [STLData.Base.F; STLData.Link{1}.F + max(max(STLData.Base.F))];
end

% Link STL 이동
for i = 1:size(TList, 2)
    if i == 1
        T0List{i} = TList{i};
    else
        T0List{i} = T0List{i - 1} * TList{i};
    end
    
    if i == size(TList, 2)
        % 마지막 링크
        if ~isempty(RobotInfo.EEstlpath)
            
            % Each link fram to base frame transformation for End Effector
            if ~isnan(RobotInfo.EERotate)
                % 컨설팅용 코드
                T_EE = tmat(0, 0, 0, RobotInfo.EERotate);
                Link{i + 1}.OriVertice = [(T0List{i} \ STLData.Link{i + 1}.V')'; (T_EE * STLData.EndEffector.V')'];
            else
                % Web용 코드
                Link{i + 1}.OriVertice = [(T0List{i} \ STLData.Link{i + 1}.V')'; ((StartPosition * T0List{i}) \ STLData.EndEffector.V')'];
            end
            
            Link{i + 1}.Face = [STLData.Link{i + 1}.F; STLData.EndEffector.F + max(max(STLData.Link{i + 1}.F))];
        else
            % 엔드이펙터가 없는경우
            Link{i + 1}.OriVertice = (T0List{i} \ STLData.Link{i + 1}.V')';
            Link{i + 1}.Face = STLData.Link{i + 1}.F;
        end
    else
        % 나머지 링크
        Link{i + 1}.OriVertice = (T0List{i} \ STLData.Link{i + 1}.V')';
        Link{i + 1}.Face = STLData.Link{i + 1}.F;
    end
end
end