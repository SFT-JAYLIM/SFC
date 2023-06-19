function CheckStopSign(UserPath)

% 중단버튼 활성화 확인
StopSign = exist(strcat(UserPath, '\StopSign.txt'), 'file');
if StopSign == 2
    delete(strcat(UserPath, '\StopSign.txt'));
    close(StandardMotion);
    delete(strcat(UserPath, '\output\*.avi'));
    fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
    fprintf(fileID, '%s', '6');
    fclose(fileID);
    close all
    clear
    quit;
end
end