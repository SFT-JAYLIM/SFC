function Plot_CRI(UserPath, AppDataPath)

global AutoReportGen;
% AutoReportGen = true;
AutoReportGen = false;

if (AutoReportGen)
   addpath('../AutoReportGen'); 
end

try
    %% 경로 설정
    set(0,'DefaultFigureVisible', 'on');
    mkdir(UserPath + "\output");
    
    fileID = fopen(strcat(UserPath, '\', 'PlotCRI.txt'), 'w');
    fprintf(fileID, '%s', '0'); % 시작
    fclose(fileID);
    
    %% Robot Info 세팅
    if exist(UserPath + "\ST_RobotInfo.json", 'file')
        RobotInfo = Set_JsonRobotInfo(UserPath);
        
    elseif exist(UserPath + "\ST_RobotInfo.txt", 'file')
        RobotInfo = Set_TextRobotInfo(UserPath);
    end
    
    %% STL파일 로드
    STLData = STL2MAT(RobotInfo, AppDataPath);
    
    %% 도면 파일 로드
    DrawingPos = Set_DrawingImage(UserPath);
    
    %% ToolBox_robot 및 DHparam 생성
    if ~isempty(RobotInfo.RobotModel)
        DHparam = Set_RobotModel(AppDataPath, RobotInfo.RobotModel);
    else
        DHparam.a = [];
        DHparam.d = [];
        DHparam.alpha = [];
        DHparam.Theta = [];
        DHparam.STL_Pose = [];
    end
    if ~isempty(RobotInfo.BaseModel)
        BaseDHparam = Set_BaseModel(AppDataPath, RobotInfo.BaseModel);
        DHparam.a = [BaseDHparam.a DHparam.a];
        DHparam.d = [BaseDHparam.d DHparam.d];
        DHparam.alpha = [BaseDHparam.alpha DHparam.alpha];
        DHparam.Theta = [BaseDHparam.Theta DHparam.Theta];
        DHparam.STL_Pose = [BaseDHparam.STL_Pose DHparam.STL_Pose];
        DHparam.STL_Position = BaseDHparam.STL_Position;
    end
    
    %% Base 위치 계산
    StartPosition = Set_StartPosition(RobotInfo);
    
    %% Link 생성
    LinksOrigin = Set_RobotLink(DHparam, STLData, RobotInfo, StartPosition);
    
    %% CSV데이터 로드
    [ISOData, ISOFlag, KHUData, KHUFlag] = CSVDataLoad(UserPath);
    SolverData = {ISOData, KHUData};
    SolverFlag = [ISOFlag, KHUFlag];
    
    %% ColliPosOnRobot
    ColliPosView(UserPath, LinksOrigin, DHparam, RobotInfo)
    
    %% 영상 생성 시작
    DataNum = size(SolverData, 2);
    for i = 1:DataNum
        if (SolverFlag(i))
            % 링크 Vertices 및 Color 연산
            LinkMat = calLinkMatrix(LinksOrigin, DHparam, SolverData{i}, RobotInfo, StartPosition);

            % 최대 ISO figure 크기 계산
            ISOMaxFigureSize = calWindowSize(LinkMat, [], SolverData{i}.q_series);
            
            % ISO Veiw 영상 생성
            ISOVeiw(UserPath, SolverData{i}, RobotInfo, LinkMat, ISOMaxFigureSize, SolverData{i}.DataType);
            
%             tic
            % RiskSpace 영상 생성
            if RobotInfo.SaveVideo
                % 최대 Risk figure 크기 계산
                RiskMaxFigureSize = calWindowSize(LinkMat, RobotInfo.Hspace, SolverData{i}.q_series);
                
                if DrawingPos.DrawingFlag
                    % 필요한 사이즈 만큼 도면 Crop
                    DrawingPos = CropImage(DrawingPos, RiskMaxFigureSize, RobotInfo);
                end
                
                % RiskSpace Image for Consolting
                if (AutoReportGen)
                    if ~isempty(RobotInfo.Hspace) && sum(RobotInfo.Hspace) ~= 0
                        RiskSpaceImage(UserPath, RobotInfo, LinkMat, RiskMaxFigureSize, DrawingPos);
                    end
                end
                
                RiskSpaceVeiw(UserPath, SolverData{i}, RobotInfo, LinkMat, RiskMaxFigureSize, DrawingPos, SolverData{i}.DataType);
            end
%             toc
        end
    end
    
catch exception
    
    fileID = fopen(strcat(UserPath, '\', 'MatlabErrorCode.txt'), 'w');
    fprintf(fileID, 'Function name: %s\n', exception.stack.name);
    fprintf(fileID, 'Line: %d\n', exception.stack.line);
    fprintf(fileID, 'Error message: %s', exception.message);
    fclose(fileID);
    
    close all
    clear
    
end
end