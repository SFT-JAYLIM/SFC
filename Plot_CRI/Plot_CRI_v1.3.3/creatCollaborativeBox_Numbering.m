function Humanspace = creatCollaborativeBox_Numbering(RobotInfo)

bodylist = RobotInfo.ColliBody;
for loop = 1:RobotInfo.numColliBody
    x1 = RobotInfo.Hspace(4*(loop-1)+1);
    y1 = RobotInfo.Hspace(4*(loop-1)+2);
    xlength = RobotInfo.Hspace(4*(loop-1)+3);
    ylength = RobotInfo.Hspace(4*(loop-1)+4);
    x4 = x1;
    y4 = y1-ylength;

    if strcmpi(bodylist(loop), 'Skullandforehead')
        Message = 'Skull and Forehead';
    elseif strcmpi(bodylist(loop), 'LowerarmandWrist')
        Message = 'Lowerarm and Wrist';
    elseif strcmpi(bodylist(loop),'Handandfinger')
        Message = 'Hand and Finger';
    elseif strcmpi(bodylist(loop), 'ThighandKnee')
        Message = 'Thigh and Knee';
    elseif strcmpi(bodylist(loop), 'UpperarmandElbow')
        Message = 'Upperarm and Elbow';
    elseif strcmpi(bodylist(loop), 'Chest')
        Message = 'Chest';
    else
        Message = 'None';
    end

    Humanspace(loop) = rectangle('Position',[x4, y4, xlength, ylength],'LineWidth',7);
%     text(x1, y1+70, 10, regexprep(Message, '_', ''), 'Fontsize', 15, 'FontWeight', 'bold');
    text(x1, y1+100, 10, ['Human Space',num2str(loop), ' : ', newline, Message], 'Fontsize', 15, 'FontWeight', 'bold');
end
end
