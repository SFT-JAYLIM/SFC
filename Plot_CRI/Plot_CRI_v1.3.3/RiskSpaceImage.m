function RiskSpace = RiskSpaceImage(UserPath, RobotInfo, Link, MaxWindowSize, DrawingPos)
%% Humanspace image
RiskSpace = SetFigureWindows();
colorbar('off');
axis(MaxWindowSize);
view(0, 90);

if DrawingPos.DrawingFlag
    
    % 도면 시작위치
    XstartNum = DrawingPos.ModiDrawingPosition(1);
    YstartNum = DrawingPos.ModiDrawingPosition(2);

    [Row, Col, ~] = size(DrawingPos.CropImage);
    Xrange = [XstartNum, XstartNum + Col];
    Yrange = [YstartNum, YstartNum - Row];
    Background_image = image(Xrange, Yrange, DrawingPos.CropImage);
    uistack(Background_image, 'bottom');
end

Humanspace = creatCollaborativeBox(RobotInfo);
uistack(Humanspace, 'top');

animating_realtime(Link{1});

% 원점 좌표축 만들기
Ori_Pos = [0; 0; 0];

Ori_XPos = [200; 0; 0];
Ori_YPos = [0; 200; 0];

OriText_XPos = [210; 0; 0];
OriText_YPos = [0; 210; 0];

line([Ori_Pos(1) Ori_XPos(1)], [Ori_Pos(2) Ori_XPos(2)], [Ori_Pos(3) Ori_XPos(3)], 'LineWidth', 5, 'Color', [1 0 0]); % x Line
text(OriText_XPos(1), OriText_XPos(2), OriText_XPos(3), 'X','FontSize', 20, 'Color', [1 0 0]);

line([Ori_Pos(1) Ori_YPos(1)], [Ori_Pos(2) Ori_YPos(2)], [Ori_Pos(3) Ori_YPos(3)], 'LineWidth', 5, 'Color', [0 1 0]); % x Line
text(OriText_YPos(1), OriText_YPos(2), OriText_YPos(3), 'Y','FontSize', 20, 'Color', [0 1 0]);

%%% 23.06.26 EDIT
gSeqData.FolderInfo.AnalysisInfoFile=[UserPath,'\ST_RobotInfo.json'];
if isfile(gSeqData.FolderInfo.AnalysisInfoFile)
    fileID = fopen(gSeqData.FolderInfo.AnalysisInfoFile, 'r');
    rawdata = fread(fileID, inf);
    str = char(rawdata');
    fclose(fileID);
    JsonRobotInfo = jsondecode(str);
    Jsonfieldname = fieldnames(JsonRobotInfo.RobotInfo);

    if find(contains(Jsonfieldname,'RiskSpace'))
        RiskSpaceInfo = JsonRobotInfo.RobotInfo.RiskSpace;
    end
end


for i = 1:size(Humanspace, 2)
    if exist('RiskSpaceInfo', 'var')
        R=hex2dec(RiskSpaceInfo(i).Color(2:3))/255;
        G=hex2dec(RiskSpaceInfo(i).Color(4:5))/255;
        B=hex2dec(RiskSpaceInfo(i).Color(6:7))/255;
        Humanspace(i).FaceColor = [R G B 0.5];
    else
        Humanspace(i).FaceColor = [1 0.6 0.6 0.5];
    end
    saveas(RiskSpace, strcat(UserPath, '/output/HumanSpace_', int2str(i), '.jpg'));
    Humanspace(i).FaceColor = 'none';
end

close(RiskSpace);

%% Numbering Humanspace

NumberingRiskSpace = SetFigureWindows();

colorbar('off');
axis(MaxWindowSize);
view(0, 90);

if DrawingPos.DrawingFlag
    
    % 도면 시작위치
    XstartNum = DrawingPos.ModiDrawingPosition(1);
    YstartNum = DrawingPos.ModiDrawingPosition(2);

    [Row, Col, ~] = size(DrawingPos.CropImage);
    Xrange = [XstartNum, XstartNum + Col];
    Yrange = [YstartNum, YstartNum - Row];
    Background_image = image(Xrange, Yrange, DrawingPos.CropImage);
    uistack(Background_image, 'bottom');
end

NumberingHumanspace = creatCollaborativeBox_Numbering(RobotInfo);
uistack(NumberingHumanspace, 'top');

animating_realtime(Link{1});

% 원점 좌표축 만들기
Ori_Pos = [0; 0; 0];

Ori_XPos = [200; 0; 0];
Ori_YPos = [0; 200; 0];

OriText_XPos = [210; 0; 0];
OriText_YPos = [0; 210; 0];

line([Ori_Pos(1) Ori_XPos(1)], [Ori_Pos(2) Ori_XPos(2)], [Ori_Pos(3) Ori_XPos(3)], 'LineWidth', 5, 'Color', [1 0 0]); % x Line
text(OriText_XPos(1), OriText_XPos(2), OriText_XPos(3), 'X','FontSize', 20, 'Color', [1 0 0]);

line([Ori_Pos(1) Ori_YPos(1)], [Ori_Pos(2) Ori_YPos(2)], [Ori_Pos(3) Ori_YPos(3)], 'LineWidth', 5, 'Color', [0 1 0]); % x Line
text(OriText_YPos(1), OriText_YPos(2), OriText_YPos(3), 'Y','FontSize', 20, 'Color', [0 1 0]);

for i = 1:size(Humanspace, 2)
    if exist('RiskSpaceInfo', 'var')
        R=hex2dec(RiskSpaceInfo(i).Color(2:3))/255;
        G=hex2dec(RiskSpaceInfo(i).Color(4:5))/255;
        B=hex2dec(RiskSpaceInfo(i).Color(6:7))/255;
        NumberingHumanspace(i).FaceColor = [R G B 0.5];
    else
        NumberingHumanspace(i).FaceColor = 'None';
    end
end

saveas(NumberingRiskSpace, strcat(UserPath, '/output/NumberingHumanSpace', '.jpg'));

close(NumberingRiskSpace);
end