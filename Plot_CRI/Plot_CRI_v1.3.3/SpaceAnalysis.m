function [RiskValue, PS]= SpaceAnalysis(Link, initialize_index, RiskValue, PS)

gridsize = 10;
if initialize_index == 1
    
    % 초기값 생성
    h = gca;
    RiskValue.RskSpceGrd_x = h.XLim(1):gridsize:h.XLim(2);
    RiskValue.RskSpceGrd_y = h.YLim(1):gridsize:h.YLim(2);
    
    [X, Y] = meshgrid(RiskValue.RskSpceGrd_x, RiskValue.RskSpceGrd_y);
    
    RiskValue.Grid = NaN(size(X,1),size(X,2));
    RiskValue.RskSpceGrd_Lim = [min(RiskValue.RskSpceGrd_x) max(RiskValue.RskSpceGrd_x) min(RiskValue.RskSpceGrd_y) max(RiskValue.RskSpceGrd_y)]; % 초기 범위
else
    % 기존 바닥에 뿌려진 데이터 삭제(삭제하지 않을 경우 데이터가 계속 쌓여서 느려짐)
    delete(PS);
    
    h = gca;
    DeltaLim =  [h.XLim h.YLim] - RiskValue.RskSpceGrd_Lim;   % 새로운 사이즈 - 기존 사이즈
    DeltaIndex = abs(DeltaLim) > gridsize;
    
    % -X 방향으로 확장한 경우
    if DeltaIndex(1)
        
        % (커진 크기 / 그리드 사이즈)를 올림으로 계산
        DeltaStepSize = ceil(abs(DeltaLim(1)/gridsize));
        
        % RskSpceGrd_x 범위 확장
        for i = 1:DeltaStepSize
            RiskValue.RskSpceGrd_x = [min(RiskValue.RskSpceGrd_x) - gridsize, RiskValue.RskSpceGrd_x];
        end
        RiskValue.RskSpceGrd_Lim(1) = min(RiskValue.RskSpceGrd_x);
        
        % Grid 확장
        [Grid_Row, ~] = size(RiskValue.Grid);
        RiskValue.Grid = [NaN(Grid_Row, DeltaStepSize), RiskValue.Grid];
    end
    
    % X 방향으로 확장한 경우
    if DeltaIndex(2)
        
        % (커진 크기 / 그리드 사이즈)를 올림으로 계산
        DeltaStepSize = ceil(abs(DeltaLim(2)/gridsize));
        
        % RskSpceGrd_x 범위 확장
        for i = 1:DeltaStepSize
            RiskValue.RskSpceGrd_x = [RiskValue.RskSpceGrd_x, max(RiskValue.RskSpceGrd_x) + gridsize];
        end
        RiskValue.RskSpceGrd_Lim(2) = max(RiskValue.RskSpceGrd_x);
        
        % Grid 확장
        [Grid_Row, ~] = size(RiskValue.Grid);
        RiskValue.Grid = [RiskValue.Grid, NaN(Grid_Row, DeltaStepSize)];
    end
    
    % -Y 방향으로 확장한 경우
    if DeltaIndex(3)
        
        % (커진 크기 / 그리드 사이즈)를 올림으로 계산
        DeltaStepSize = ceil(abs(DeltaLim(3)/gridsize));
        
        % RskSpceGrd_y 범위 확장
        for i = 1:DeltaStepSize
            RiskValue.RskSpceGrd_y = [min(RiskValue.RskSpceGrd_y) - gridsize, RiskValue.RskSpceGrd_y];
        end
        RiskValue.RskSpceGrd_Lim(3) = min(RiskValue.RskSpceGrd_y);
        
        % Grid 확장
        [~, Grid_Col] = size(RiskValue.Grid);
        RiskValue.Grid = [NaN(DeltaStepSize, Grid_Col); RiskValue.Grid];
    end
    
    % +Y 방향으로 확장한 경우
    if DeltaIndex(4)
        
        % (커진 크기 / 그리드 사이즈)를 올림으로 계산
        DeltaStepSize = ceil(abs(DeltaLim(4)/gridsize));
        
        % RskSpceGrd_y 범위 확장
        for i = 1:DeltaStepSize
            RiskValue.RskSpceGrd_y = [RiskValue.RskSpceGrd_y max(RiskValue.RskSpceGrd_y) + gridsize];
        end
        RiskValue.RskSpceGrd_Lim(4) = max(RiskValue.RskSpceGrd_y);
        
        % Grid 확장
        [~, Grid_Col] = size(RiskValue.Grid);
        RiskValue.Grid = [RiskValue.Grid; NaN(DeltaStepSize, Grid_Col)];
    end
    
    [X, Y] = meshgrid(RiskValue.RskSpceGrd_x, RiskValue.RskSpceGrd_y);
end


LinkNum = size(Link, 2);
ZList = cell(1, LinkNum);
NaNGrid = NaN(size(X,1),size(X,2));
warning off;
for i = 1:LinkNum
    % i번째 링크 X, Y, Color값 로드
    ith_LinkRisk = [Link{i}.Vertice(:,1:2), Link{i}.color];
    
    % X최대 최소 Index 추출
    Xmin_idx = find(X(1, :) < min(ith_LinkRisk(:,1)), 1, 'last' );
    Xmax_idx = find(X(1, :) > max(ith_LinkRisk(:,1)), 1, 'first' );
    
    % Y최대 최소 Index 추출
    Ymin_idx = find(Y(:, 1) < min(ith_LinkRisk(:,2)), 1, 'last' );
    Ymax_idx = find(Y(:, 1) > max(ith_LinkRisk(:,2)), 1, 'first' );
    
    % 변경되는 범위의 Mesh 계산
    ZList{i} = NaNGrid;
    MiniX = X(1, Xmin_idx):gridsize:X(1, Xmax_idx);
    MiniY = Y(Ymin_idx, 1):gridsize:Y(Ymax_idx, 1);
    [MiniGridX, MiniGridY] = meshgrid(MiniX, MiniY);
    [Row, Col] = size(MiniGridX);
    
    % 변경되는 범위에 대한 Grid 연산 수행
    ZList{i}(Ymin_idx:Ymin_idx + Row - 1, Xmin_idx:Xmin_idx + Col - 1) = griddata(ith_LinkRisk(:,1), ith_LinkRisk(:,2), ith_LinkRisk(:,3), MiniGridX, MiniGridY);  
end
warning on;

% Grid당 가장 높은 값을 가지는 값만 살려둠
Z = ZList{1};
for i = 2:size(ZList, 2)
    Z = max(Z, ZList{i});
end

RiskValue.Grid(isnan(RiskValue.Grid)) = -1;
[row, col] = find((RiskValue.Grid < Z) == 1);
for i = 1:size(row,1)
    RiskValue.Grid(row(i), col(i)) = Z(row(i), col(i));
%     dis_mat = ((LinkRisk(:,1) - RiskValue.RskSpceGrd_x(col(i))).^2 + (LinkRisk(:,2) - RiskValue.RskSpceGrd_y(row(i))).^2).^0.5;
%     if ~isempty(max(dis_mat(dis_mat < 50)))
%         RiskValue.Grid(row(i), col(i)) = Z(row(i), col(i));
%     end
end

RiskValue.Grid(RiskValue.Grid == -1) = NaN;

hold on;
PS = pcolor(X, Y, RiskValue.Grid);
PS.EdgeColor='none';
PS.FaceColor = 'interp';
PS.FaceAlpha = 0.8;

end





