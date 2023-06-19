function ISOVeiw(UserPath, Data, RobotInfo, LinkMat, MaxWindowSize, DataType)

global AutoReportGen;

endNum = size(Data.CRI,1);
StandardMotion = VideoWriter(strcat(UserPath, "/output/" + DataType + "_Motion"), 'MPEG-4');
StandardMotion.FrameRate = 1 / RobotInfo.StepTime;
open(StandardMotion);

Fig_ISOVeiw = SetFigureWindows();   % 3DAni 그래프 생성
axis(MaxWindowSize)
view(20, 30);
WaterMarkImage = LoadWaterMarkImage();
for i = 1:endNum
    
    % 중단버튼 활성화 확인
    CheckStopSign(UserPath);
    
    % 디버그용 코드
%     if (i>1)
%         delete(P);
%         delete(L);
%     end
%     [L, P] = animating_Test(LinkMat{i}, RobotInfo, Data.ImpactPos, i, Data.MotionDivisionIndex);
    
    % 실사용 코드
    if (i > 1)
        delete(LinkPatch);
    end
    LinkPatch = animating_realtime(LinkMat{i});
    
    % 시간축 작성
    if (AutoReportGen)
        timedisplay = annotation('textbox', [0.42, 0.85, 0.2, 0.1], 'Edgecolor','none','FitBoxToText','on', 'String', ['time = ',num2str(Data.Time(i,1),'%100.2f'),' sec'], 'Fontsize', 30);
        FF = getframe(Fig_ISOVeiw);
        FF.cdata = WriteWaterMark(FF.cdata, WaterMarkImage);
        writeVideo(StandardMotion, FF);
        delete(timedisplay);
    else
        FF = getframe(Fig_ISOVeiw);
        FF.cdata = WriteWaterMark(FF.cdata, WaterMarkImage);
        writeVideo(StandardMotion, FF);
    end
end

close(StandardMotion);
close(Fig_ISOVeiw);

fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
fprintf(fileID, '%s', '2'); % ISOVeiw 영상 생성 완료
fclose(fileID);

end