function [bodymsg,FDen,PDen]=Reference_CR(ColliBody, BodyProperty)

    % Criterion
    KOROS=[410,410,2.9,2.9;250,500,1.8,3.6;310,620,3.9,7.8;...
        510,1020,3.7,7.4;320,740,3.6,7.2;260,520,2.7,5.4];
    ISO=[130,130,1.3,1.3;140,280,1.2,2.4;150,300,1.9,3.8;
        140,280,3,6;160,320,1.9,3.8;220,440,2.5,5];
    
    if strcmpi(ColliBody,'SkullandForehead')
        DocInfo.ColliBody=1;
        bodymsg='머리(이마중앙)';
    elseif strcmpi(ColliBody,'Chest')
        bodymsg='가슴(흉골)';
        DocInfo.ColliBody=2;
    elseif strcmpi(ColliBody,'Upperarmandelbow')
        DocInfo.ColliBody=3;
        bodymsg='상완(삼각근)';
    elseif strcmpi(ColliBody,'HandandFinger')
        bodymsg='손(검지안쪽)';
        DocInfo.ColliBody=4;
    elseif strcmpi(ColliBody,'HandandFinger')
        bodymsg='전완(요골)';
        DocInfo.ColliBody=5;
    elseif strcmpi(ColliBody,'HandandFinger')
        bodymsg='대퇴(대퇴근)';
        DocInfo.ColliBody=6;
    end
    
    if contains(BodyProperty,'KHU')
        if DocInfo.ColliBody==1
            FDen=KOROS(1,2);
            PDen=KOROS(1,4);
        elseif DocInfo.ColliBody==2
            FDen=KOROS(2,2);
            PDen=KOROS(2,4);
        elseif DocInfo.ColliBody==3
            FDen=KOROS(3,2);
            PDen=KOROS(3,4);
        elseif DocInfo.ColliBody==4
            FDen=KOROS(4,2);
            PDen=KOROS(4,4);
        elseif DocInfo.ColliBody==5
            FDen=KOROS(5,2);
            PDen=KOROS(5,4);
        elseif DocInfo.ColliBody==6
            FDen=KOROS(6,2);
            PDen=KOROS(6,4);
        else
        end
           
    elseif contains(BodyProperty,'ISO')
        if DocInfo.ColliBody==1
            FDen=ISO(1,2);
            PDen=ISO(1,4);
        elseif DocInfo.ColliBody==2
            FDen=ISO(2,2);
            PDen=ISO(2,4);
        elseif DocInfo.ColliBody==3
            FDen=ISO(3,2);
            PDen=ISO(3,4);
        elseif DocInfo.ColliBody==4
            FDen=ISO(4,2);
            PDen=ISO(4,4);
        elseif DocInfo.ColliBody==5
            FDen=ISO(5,2);
            PDen=ISO(5,4);
        elseif DocInfo.ColliBody==6
            FDen=ISO(6,2);
            PDen=ISO(6,4);
        else
        end
    else
    end

end