function RiskSpaceVeiw(UserPath, CSVData, RobotInfo, Link, MaxWindowSize, DrawingPos, DataType)

global AutoReportGen;

endNum = size(CSVData.CRI,1);

RiskSpace = VideoWriter(strcat(UserPath, "/output/" + DataType + "_RiskSpace"), 'MPEG-4');
RiskSpace.FrameRate = 1/RobotInfo.StepTime;
open(RiskSpace);

fig_RiskSpace = SetFigureWindows();
axis(MaxWindowSize)
view(0, 90);

WaterMarkImage = LoadWaterMarkImage();
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


for i = 1:endNum

    % 중단버튼 활성화 확인
    CheckStopSign(UserPath);
    
    if (i == 1)
        if ~isempty(RobotInfo.Hspace) && sum(RobotInfo.Hspace) ~= 0
            Humanspace = creatCollaborativeBox(RobotInfo);
            uistack(Humanspace, 'top');
        end
        initialized_index = true;
        RiskValue = [];
        PS = [];
    else
        delete(LinkPatch);
        initialized_index = false;
    end
    
    LinkPatch = animating_realtime(Link{i});
    [RiskValue, PS] = SpaceAnalysis(Link{i}, initialized_index, RiskValue, PS);
    if (AutoReportGen)
        timedisplay = annotation('textbox', [0.42, 0.85, 0.2, 0.1], 'Edgecolor','none','FitBoxToText','on', 'String', [num2str(CSVData.Time(i,1),'%100.2f'),' sec'], 'Fontsize', 30);
        FF = getframe(gcf);
        FF.cdata = WriteWaterMark(FF.cdata, WaterMarkImage);
        writeVideo(RiskSpace, FF);
        delete(timedisplay);
    else
        FF = getframe(gcf);
        FF.cdata = WriteWaterMark(FF.cdata, WaterMarkImage);
        writeVideo(RiskSpace, FF);
    end
end

if (AutoReportGen)
    saveas(fig_RiskSpace, strcat(UserPath, "/output/" + DataType + "_RiskSpace.jpg"));
end
close(RiskSpace);
close(fig_RiskSpace);

fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
fprintf(fileID, '%s', '4'); % Risk_Space 영상 생성 완료
fclose(fileID);
end