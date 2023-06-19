function gSeqData=Plot_CRI_Batch(gSeqData)
    warning('off','all')
    gSeqData=RobotInfoDataLoad(gSeqData);                    
    cd(gSeqData.FolderInfo.PlotCRIPath);
    FolderInfo=dir;
    tempPath=FolderInfo(size(FolderInfo,1)).name;
    cd(tempPath);
    Plot_CRI(gSeqData.FolderInfo.UserPath, '../../InputData');
    
    if gSeqData.TaskIdx~=1
        close all
    else
        disp('Please press the "Any Key" to progress')
        pause;
        close all
    end
end