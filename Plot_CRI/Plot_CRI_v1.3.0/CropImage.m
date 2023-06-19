function DrawingPos = CropImage(DrawingPos, MaxFigureSize, RobotInfo)

[Image_Row, Image_Col, ~] = size(DrawingPos.Image) ;
if RobotInfo.DrawingScale > max(MaxFigureSize(2) - MaxFigureSize(1), MaxFigureSize(4) - MaxFigureSize(3))
    
    % Plot 하는 Figure 사이즈보다 크게 확대하면 도면의 1픽셀만 사용하기 때문에 도면연산 필요없음.
    DrawingPos.DrawingFlag = 0;
    
else
    DrawingXmin = RobotInfo.DrawingPosition(1);
    DrawingYmax = RobotInfo.DrawingPosition(2);
    
    % 글로벌 기준 Figure의 범위를 도면 기준으로 변경
    Figure_Xmin = ceil((MaxFigureSize(1) - DrawingXmin) / RobotInfo.DrawingScale) + 1;
    Figure_Xmax = ceil((MaxFigureSize(2) - DrawingXmin) / RobotInfo.DrawingScale) + 1;
    Figure_Ymin = ceil((MaxFigureSize(3) - DrawingYmax) / RobotInfo.DrawingScale) - 1;
    Figure_Ymax = ceil((MaxFigureSize(4) - DrawingYmax) / RobotInfo.DrawingScale) - 1;
    
    % 도면의 X축 범위 선정
    if Figure_Xmax <= 1 || Figure_Xmin >= Image_Col
        % 겹치지 않음
        ImageXmin = 1;
        ImageXmax = 1;
        DrawingPos.ModiDrawingPosition(1) = RobotInfo.DrawingPosition(1);
        
    elseif Figure_Xmin >= 1 && Figure_Xmax <= Image_Col
        % Figure보다 도면이 크거나 같다.
        ImageXmin = Figure_Xmin;
        ImageXmax = Figure_Xmax;
        DrawingPos.ModiDrawingPosition(1) = MaxFigureSize(1);
        
    elseif Figure_Xmin > 1 && Figure_Xmax > Image_Col
        % 도면의 좌측만 Figure 밖으로 나옴
        ImageXmin = Figure_Xmin;
        ImageXmax = Image_Col;
        DrawingPos.ModiDrawingPosition(1) = MaxFigureSize(1);
        
    elseif Figure_Xmin < 1 && Figure_Xmax < Image_Col
        % 도면의 우측만 Figure 밖으로 나옴
        ImageXmin = 1;
        ImageXmax = Figure_Xmax;
        DrawingPos.ModiDrawingPosition(1) = RobotInfo.DrawingPosition(1);
        
    else
        % 도면보다 Figure가 더 큼
        ImageXmin = 1;
        ImageXmax = Image_Col;
        DrawingPos.ModiDrawingPosition(1) = RobotInfo.DrawingPosition(1);
        
    end
    
    % 도면의 Y축 범위 선정
    if Figure_Ymax <= -Image_Row || Figure_Ymin >= -1
        % 겹치지 않음
        ImageYmin = -1;
        ImageYmax = -1;
        DrawingPos.ModiDrawingPosition(2) = RobotInfo.DrawingPosition(2);
        
    elseif Figure_Ymax < 0 && Figure_Ymin >= -Image_Row
        % Figure보다 도면이 크거나 같다
        ImageYmin = Figure_Ymin;
        ImageYmax = Figure_Ymax;
        DrawingPos.ModiDrawingPosition(2) = MaxFigureSize(4);
        
    elseif Figure_Ymax < -1 && Figure_Ymin < -Image_Row
        % 도면의 윗부분이 Figure 밖으로 나옴
        ImageYmin = -Image_Row;
        ImageYmax = Figure_Ymax;
        DrawingPos.ModiDrawingPosition(2) = MaxFigureSize(4);
        
    elseif Figure_Ymax > -1 && Figure_Ymin > -Image_Row
        % 도면의 아래부분이 Figure 밖으로 나옴
        ImageYmin = Figure_Ymin;
        ImageYmax = -1;
        DrawingPos.ModiDrawingPosition(2) = RobotInfo.DrawingPosition(2);
        
    else
        % 도면보다 Figure가 더 큼
        ImageYmin = -Image_Row;
        ImageYmax = -1;
        DrawingPos.ModiDrawingPosition(2) = RobotInfo.DrawingPosition(2);
        
    end
    
    % Image Crop
    CropedImage = DrawingPos.Image(-(ImageYmax):-ImageYmin, ImageXmin:ImageXmax, :);
    
    if isempty(CropedImage)
        % 예외처리
        DrawingPos.DrawingFlag = 0;
    else
        % Image Resize
        if (size(CropedImage, 3) == 3)
            ResizeImage = rgb2gray(imresize(CropedImage, RobotInfo.DrawingScale));
        elseif (size(CropedImage, 3) == 1)
            ResizeImage = imresize(CropedImage, RobotInfo.DrawingScale);
        else
            disp('도면 Size error 흑백 또는 컬러 데이터가 아닙니다.');
        end

        % 필터 적용
        MH = [-1 -2 -1; 0 0 0; 1 2 1]; % Horizontal Sobel Kernel
        MV = MH'; % Vertical Sobel Kernel
        
        GH = conv2 (ResizeImage, MH);
        GV = conv2 (ResizeImage, MV);
        
        Edge_img = sqrt(GH.*GH + GV.*GV);
        
        % Normalize
        Edge_img = Edge_img / 255;
        
        % 필터 적용후 Threhold 적용
        [Row, Col] = size(Edge_img);
        for i = 1:Row
            for j = 1:Col
                if Edge_img(i, j) > 0.2  % Threshold
                    Edge_img(i, j) = 0;
                else
                    Edge_img(i, j) = 1;
                end
            end
        end
        
        % Gray to RGB -> [0, 0, 0] = Black, [1, 1, 1] = White
        Result_img(:, :, 1) = Edge_img;
        Result_img(:, :, 2) = Edge_img;
        Result_img(:, :, 3) = Edge_img;
        
        % Set Image Color
        Result_img(Result_img==0) = 0.8;
        DrawingPos.CropImage = Result_img;
    end
end
end