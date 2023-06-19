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

for i = 1:size(Humanspace, 2)
    Humanspace(i).FaceColor = [1 0.6 0.6 0.5];
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

saveas(NumberingRiskSpace, strcat(UserPath, '/output/NumberingHumanSpace', '.jpg'));

close(NumberingRiskSpace);
end