function STLData = STL2MAT(RobotInfo, Path)

%% 로봇 STL 로드
if ~isempty(RobotInfo.RobotModel)
    stl_filename = [RobotInfo.RobotModel,'/link'];
    STLlist = dir([Path, '/STL/', RobotInfo.RobotModel, '/*.stl']);
    [Row, ~] = size(STLlist);
    for i = 0:Row - 1
        
        LinkSTLPath = strcat(Path, '/STL/', stl_filename, num2str(i), '.stl');
        
        [v, f, n, ~] = stlRead(LinkSTLPath);
        
        STLData.Link{i+1}.F = f;
        STLData.Link{i+1}.V = v;
        STLData.Link{i+1}.V(:,4) = 1;
        STLData.Link{i+1}.C = n;
        
        clear f v n;
    end
end

%%  End-Effector STL 로드
if ~isempty(RobotInfo.EEstlpath)
    
    % End-effector STL load
    [EEv, EEf, EEn, ~] = stlRead(RobotInfo.EEstlpath);

    STLData.EndEffector.F = EEf;
    STLData.EndEffector.V = EEv;
    STLData.EndEffector.V(:,4) = 1;
    STLData.EndEffector.C = EEn;
end

%% MobileBase STL 로드
if ~isempty(RobotInfo.BaseModel)
    BaseSTLPath = strcat(Path, '/STL/', [RobotInfo.BaseModel,'/link0'], '.stl');
    [Base_v, Base_f, Base_n, ~] = stlRead(BaseSTLPath);

    STLData.Base.F = Base_f;
    STLData.Base.V = Base_v;
    STLData.Base.V(:,4) = 1;
    STLData.Base.C = Base_n;
end

end