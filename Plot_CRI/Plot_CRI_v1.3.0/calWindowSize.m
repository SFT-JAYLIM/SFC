function MaxWindowSize = calWindowSize(LinkMat, Hspace, q_series)

LinkWindowSize = [0, 0, 0, 0, 0, 0];

Iteration = size(q_series, 1);
for i = 1:Iteration
    LinkWindowSize = calLinkWindowSize(LinkMat{i}, LinkWindowSize);
end

if ~isempty(Hspace)
    HumanSpacePosition = zeros(4,2);
    numColliBody = size(Hspace, 2) / 4;
    for loop = 1:numColliBody
        x1=Hspace(4*(loop-1)+1);
        y1=Hspace(4*(loop-1)+2);
        xlength=Hspace(4*(loop-1)+3);
        ylength=Hspace(4*(loop-1)+4);
        x2=x1+xlength;
        y2=y1;
        x3=x1+xlength;
        y3=y1-ylength;
        x4=x1;
        y4=y1-ylength;
        HumanSpacePosition(4*(loop-1)+1:4*(loop-1)+4,1:2) = [x1 y1;x2 y2; x3 y3; x4 y4];
        
        Xmin = min([LinkWindowSize(1), HumanSpacePosition(:,1)']);
        Xmax = max([LinkWindowSize(2), HumanSpacePosition(:,1)']);
        Ymin = min([LinkWindowSize(3), HumanSpacePosition(:,2)']);
        Ymax = max([LinkWindowSize(4), HumanSpacePosition(:,2)']);
        Zmin = min(LinkWindowSize(5));
        Zmax = max(LinkWindowSize(6));
    end
else
    Xmin = min(LinkWindowSize(1));
    Xmax = max(LinkWindowSize(2));
    Ymin = min(LinkWindowSize(3));
    Ymax = max(LinkWindowSize(4));
    Zmin = min(LinkWindowSize(5));
    Zmax = max(LinkWindowSize(6));
    
end

AxisLen = [Xmax - Xmin Ymax - Ymin Zmax - Zmin];
maxValue = max(AxisLen);

MidPoint = [(Xmax + Xmin) / 2 (Ymax + Ymin) / 2 (Zmax + Zmin) / 2];

NullSpace = 300;
MaxWindowSize = [MidPoint(1) - maxValue/2 - NullSpace
                MidPoint(1) + maxValue/2 + NullSpace
                MidPoint(2) - maxValue/2 - NullSpace
                MidPoint(2) + maxValue/2 + NullSpace
                MidPoint(3) - maxValue/2 - NullSpace
                MidPoint(3) + maxValue/2 + NullSpace];

end