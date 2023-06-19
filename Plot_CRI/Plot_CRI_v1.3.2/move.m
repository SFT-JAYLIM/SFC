function Link = move(Link, DHparam, RobotInfo, q, BasePosition, StartPosition)

Iteration = size(DHparam.alpha, 2);
if ~isempty(RobotInfo.BaseModel) && ~isempty(RobotInfo.RobotModel)
    % Mobile Base
    DHparam.d(2) = BasePosition(1, 1);
    DHparam.d(4) = BasePosition(1, 2);
    q = horzcat(DHparam.Theta(1, 1:9), q);
    q(1, 7) = BasePosition(:, 3);
    
    TMat = cell(1, Iteration);
    for i = 1:Iteration
        TMat{i} = tmat(DHparam.alpha(i), DHparam.a(i), DHparam.d(i), q(i));
    end
    T_B0 = StartPosition * TMat{1} * TMat{2} * TMat{3} * TMat{4} * TMat{5} * TMat{6} * TMat{7} * TMat{8} * TMat{9};
    TList = {T_B0, TMat{10}, TMat{11}, TMat{12}, TMat{13}, TMat{14}, TMat{15}};
    
elseif isempty(RobotInfo.BaseModel) && ~isempty(RobotInfo.RobotModel)
    % Fixed Base
    TMat = cell(1, Iteration);
    for i = 1:Iteration
        TMat{i} = tmat(DHparam.alpha(i), DHparam.a(i), DHparam.d(i), q(i));
    end
    T_B0 = StartPosition;
    TList = {T_B0, TMat{1}, TMat{2}, TMat{3}, TMat{4}, TMat{5}, TMat{6}};
    
else
    % Mobile Base Only
    Modi_d = DHparam.d;
    Modi_d(2) = Modi_d(2) + BasePosition(1, 1);
    Modi_d(4) = Modi_d(4) + BasePosition(1, 2);

    q = DHparam.Theta;
    q(1, 7) = BasePosition(:, 3);
    
    TMat = cell(1, Iteration);
    for i = 1:Iteration
        TMat{i} = tmat(DHparam.alpha(i), DHparam.a(i), Modi_d(i), q(i));
    end
    
    T_B0 = StartPosition * TMat{1};
    for i = 2:Iteration
        T_B0 = T_B0 * TMat{i};
    end
    
    TList = {T_B0};
end

for i = 1:size(TList, 2)
    if i == 1
       Link{i}.TBList = TList{i};
       
    else
       Link{i}.TBList = Link{i - 1}.TBList * TList{i};
       
    end
    Link{i}.Vertice = (Link{i}.TBList * Link{i}.OriVertice')';
    
end
end