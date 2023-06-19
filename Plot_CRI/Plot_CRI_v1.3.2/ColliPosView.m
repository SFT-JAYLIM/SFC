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
close

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
    
    ColliPosOnRobot.CurrentAxes.XLim = ColliPosOnRobot.CurrentAxes.XLim + [-300 300];
    ColliPosOnRobot.CurrentAxes.YLim = ColliPosOnRobot.CurrentAxes.YLim + [-300 300];
    
    % 중단버튼 활성화 확인
    CheckStopSign(UserPath);
    
    saveas(ColliPosOnRobot,strcat(UserPath, '/output/ColliPosOnRobot_dot.jpg'));
    close
    
    fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
    fprintf(fileID, '%s', '5'); % 이미지 파일 생성 완료
    fclose(fileID);
    
    %% 분할 사진 저장
    EEColliPointIndex = find(RobotInfo.ColliJoint == 6);
    EENum = size(EEColliPointIndex, 2);
    
    LinkColliPointIndex = find(RobotInfo.ColliJoint ~= 6);
    LinkNum = size(LinkColliPointIndex, 2);
    ImageNum = ceil(EENum / RobotInfo.ColliPointImageDivision);
    EECount = 0;
    LinkCount = 0;
    for i = 1:ImageNum
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
        
        hold on
        
        % set STL
        for j = 1:size(HomePosLinks, 2)
            patch('faces', HomePosLinks{j}.Face, 'vertices' ,HomePosLinks{j}.Vertice(:,1:3), 'facec', [0.7 0.5 1.0], 'EdgeColor','none', 'facealpha', 0.3);
        end
        
        % set Link ColliPoint
        for j = 1:LinkNum
            Index = LinkColliPointIndex(j);
            ImpactPosVec = HomePosLinks{RobotInfo.ColliJoint(Index) + 1}.TBList * [RobotInfo.ColliPos(Index, :), 1]';
            ImpactPosVec = ImpactPosVec(1:3, :);
            
            MarkerSize = 5;
            
            LinkCount =  LinkCount + 1;
            if RobotInfo.CheckBox(LinkCount)
                P = plot3(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), 'o', 'MarkerSize', MarkerSize, 'LineWidth', 5, 'Color', RobotInfo.LinkColor(LinkCount));
                T = text(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), strcat('     -----------------',num2str(Index)), 'Color', P.Color, 'FontSize', 12, 'FontWeight','bold');
            end
            
            % P를 가장 위로 올리기
            uistack(P, 'top');
        end
        LinkCount = 0;
        
        % set EE ColliPoint
        if i == ImageNum
            IterEECOlliPoint = EEColliPointIndex((RobotInfo.ColliPointImageDivision * (i - 1) + 1):end);
        else
            IterEECOlliPoint = EEColliPointIndex((RobotInfo.ColliPointImageDivision * (i - 1) + 1):(RobotInfo.ColliPointImageDivision * i));
        end
        IterNum = size(IterEECOlliPoint, 2);
        for j = 1:IterNum
            Index = IterEECOlliPoint(j);
            ImpactPosVec = HomePosLinks{RobotInfo.ColliJoint(Index) + 1}.TBList * [RobotInfo.ColliPos(Index, :), 1]';
            ImpactPosVec = ImpactPosVec(1:3, :);
            
            EECount = EECount + 1;
            P = plot3(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), 'o', 'MarkerSize', MarkerSize, 'LineWidth', 5, 'Color', RobotInfo.EEColor(EECount));
            T = text(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), strcat('    -----------------',num2str(Index)), 'Color', P.Color, 'FontSize', 12, 'FontWeight','bold');
        end
        
        ColliPosOnRobot.CurrentAxes.XLim = ColliPosOnRobot.CurrentAxes.XLim + [-300 300];
        ColliPosOnRobot.CurrentAxes.YLim = ColliPosOnRobot.CurrentAxes.YLim + [-300 300];
        
        saveas(ColliPosOnRobot,strcat(UserPath, '/output/ColliPosOnRobot_dot_', num2str(i), '.jpg'));
        close
    end
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
if (AutoReportGen)
    ColliPosOnEE.CurrentAxes.XLim = ColliPosOnEE.CurrentAxes.XLim + [-300 300];
    ColliPosOnEE.CurrentAxes.YLim = ColliPosOnEE.CurrentAxes.YLim + [-300 300];
end

saveas(ColliPosOnEE, strcat(UserPath, '/output/ColliPosOnRobot_EE.jpg'));
close

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
    
    ColliPosOnEE.CurrentAxes.XLim = ColliPosOnEE.CurrentAxes.XLim + [-300 300];
    ColliPosOnEE.CurrentAxes.YLim = ColliPosOnEE.CurrentAxes.YLim + [-300 300];
    
    % 중단버튼 활성화 확인
    CheckStopSign(UserPath);
    
    saveas(ColliPosOnEE, strcat(UserPath, '/output/ColliPosOnRobot_EE_dot.jpg'));
    close
    
    fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
    fprintf(fileID, '%s', '5'); % 이미지 파일 생성 완료
    fclose(fileID);
    
    %% 분할 사진 저장
    EECount = 0;
    for i = 1:ImageNum
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
        
        patch('faces', HomePosLinks{end}.Face, 'vertices' ,HomePosLinks{end}.OriVertice(:,1:3), 'facec', [0.7 0.5 1.0], 'EdgeColor','none', 'facealpha', 0.3);
        hold on
        
        % set EE ColliPoint
        if i == ImageNum
            IterEECOlliPoint = EEColliPointIndex((RobotInfo.ColliPointImageDivision * (i - 1) + 1):end);
        else
            IterEECOlliPoint = EEColliPointIndex((RobotInfo.ColliPointImageDivision * (i - 1) + 1):(RobotInfo.ColliPointImageDivision * i));
        end
        IterNum = size(IterEECOlliPoint, 2);
        for j = 1:IterNum
            Index = IterEECOlliPoint(j);
            
            ImpactPosVec = RobotInfo.ColliPos(Index, :)';
            
            EECount = EECount + 1;
            P = plot3(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), 'o', 'MarkerSize', MarkerSize, 'LineWidth', 5, 'Color', RobotInfo.EEColor(EECount));
            T = text(ImpactPosVec(1), ImpactPosVec(2), ImpactPosVec(3), strcat('    -----------------',num2str(Index)), 'Color', P.Color, 'FontSize', 12, 'FontWeight','bold');
        end
        
        ColliPosOnEE.CurrentAxes.XLim = ColliPosOnEE.CurrentAxes.XLim + [-300 300];
        ColliPosOnEE.CurrentAxes.YLim = ColliPosOnEE.CurrentAxes.YLim + [-300 300];
        
        saveas(ColliPosOnEE,strcat(UserPath, '/output/ColliPosOnRobot_EE_dot_', num2str(i), '.jpg'));
        close
    end
end
end