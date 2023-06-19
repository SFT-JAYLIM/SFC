function ColliPosView(UserPath, LinksOrigin, DHparam, RobotInfo)
global AutoReportGen;

% 중단버튼 활성화 확인
CheckStopSign(UserPath);

HomePos = [0 0 0 0 0 0];
HomeBasePosition = [0 0 0];
HomeStartPosition = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
HomePosLinks = move(LinksOrigin, DHparam, RobotInfo, HomePos, HomeBasePosition, HomeStartPosition);

% 구버전 호환
if (isempty(RobotInfo.EEColor))
    setEEColorData;
    RobotInfo.EEColor = EEColor;
end
if (isempty(RobotInfo.LinkColor))
    setLinkColorData;
    RobotInfo.LinkColor = LinkColor;
end

%% 전체 사진 저장
ColliPosOnRobot = figure('Position', [0,0,1280,1080], 'Name', '3DAni', 'NumberTitle', 'off','Color', [1 1 1], 'visible', 'on');
set(gca,'XColor', 'none','YColor', 'none','ZColor','none')
xlabel('X');
ylabel('Y');
zlabel('Z');

ax = gca;
ax.Toolbar.Visible = 'off';
daspect([1 1 1]);
light('Position',[1 0.5 0.5]);
material('dull');
view(45, 30);

animating_figure(HomePosLinks, RobotInfo);

if (AutoReportGen)
    ColliPosOnRobot.CurrentAxes.XLim = ColliPosOnRobot.CurrentAxes.XLim + [-300 300];
    ColliPosOnRobot.CurrentAxes.YLim = ColliPosOnRobot.CurrentAxes.YLim + [-300 300];
end

% 중단버튼 활성화 확인
CheckStopSign(UserPath);

saveas(ColliPosOnRobot,strcat(UserPath, '/output/ColliPosOnRobot.jpg'));
fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
fprintf(fileID, '%s', '5'); % 이미지 파일 생성 완료
fclose(fileID);

%% 전체 사진 저장 - 점
if (AutoReportGen)
    ColliPosOnRobot = figure('Position', [0,0,1280,1080], 'Name', '3DAni', 'NumberTitle', 'off','Color', [1 1 1], 'visible', 'on');
    set(gca,'XColor', 'none','YColor', 'none','ZColor','none')
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    ax = gca;
    ax.Toolbar.Visible = 'off';
    daspect([1 1 1]);
    light('Position',[1 0.5 0.5]);
    material('dull');
    view(45, 30);
    
    animating_figure_dot(HomePosLinks, RobotInfo);
    
    % 중단버튼 활성화 확인
    CheckStopSign(UserPath);
    
    saveas(ColliPosOnRobot,strcat(UserPath, '/output/ColliPosOnRobot_dot.jpg'));
    fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
    fprintf(fileID, '%s', '5'); % 이미지 파일 생성 완료
    fclose(fileID);
end
%% End-Effector 확대 사진 저장
ColliPosOnEE = figure('Position', [0,0,1280,1080], 'Name', '3DAni', 'NumberTitle', 'off','Color', [1 1 1], 'visible', 'on');
set(gca,'XColor', 'none','YColor', 'none','ZColor','none')
xlabel('X');
ylabel('Y');
zlabel('Z');
ax = gca;
ax.Toolbar.Visible = 'off';
daspect([1 1 1]);
light('Position',[1 0.5 0.5]);
material('dull');
view(45, 30);

animating_figure_EE(HomePosLinks, RobotInfo);

% 중단버튼 활성화 확인
CheckStopSign(UserPath);

saveas(ColliPosOnEE, strcat(UserPath, '/output/ColliPosOnEE.jpg'));
fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
fprintf(fileID, '%s', '5'); % 이미지 파일 생성 완료
fclose(fileID);

%% End-Effector 확대 사진 저장 - 점
if (AutoReportGen)
    ColliPosOnEE = figure('Position', [0,0,1280,1080], 'Name', '3DAni', 'NumberTitle', 'off','Color', [1 1 1], 'visible', 'on');
    set(gca,'XColor', 'none','YColor', 'none','ZColor','none')
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    ax = gca;
    ax.Toolbar.Visible = 'off';
    daspect([1 1 1]);
    light('Position',[1 0.5 0.5]);
    material('dull');
    view(45, 30);
    
    animating_figure_EE_dot(HomePosLinks, RobotInfo);
    
    % 중단버튼 활성화 확인
    CheckStopSign(UserPath);
    
    saveas(ColliPosOnEE, strcat(UserPath, '/output/ColliPosOnEE_dot.jpg'));
    fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
    fprintf(fileID, '%s', '5'); % 이미지 파일 생성 완료
    fclose(fileID);
end
close all
end