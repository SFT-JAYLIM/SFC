function gSeqData=RobotInfoDataLoad(gSeqData)
    try
        gSeqData.FolderInfo.AnalysisInfoFile=[gSeqData.FolderInfo.UserPath,'\ST_RobotInfo.json'];
        if isfile(gSeqData.FolderInfo.AnalysisInfoFile)
            fileID = fopen(gSeqData.FolderInfo.AnalysisInfoFile, 'r');
            rawdata = fread(fileID, inf);
            str = char(rawdata');
            fclose(fileID);
            JsonRobotInfo = jsondecode(str);
            
            Jsonfieldname = fieldnames(JsonRobotInfo.RobotInfo);

            if find(contains(Jsonfieldname,'AutoReport'))
                gSeqData.SimInfo.AutoReport=JsonRobotInfo.RobotInfo.AutoReport;
            end
            
            if find(contains(Jsonfieldname,'BasicInfo'))
                gSeqData.SimInfo.BasicInfo = JsonRobotInfo.RobotInfo.BasicInfo;
            end
        
            if find(contains(Jsonfieldname,'CustomEE'))
                gSeqData.SimInfo.CustomEEInfo=JsonRobotInfo.RobotInfo.CustomEE;
            end
        
            if find(contains(Jsonfieldname,'RobotLink'))
                gSeqData.SimInfo.RobotLinkInfo = JsonRobotInfo.RobotInfo.RobotLink;
            end
        
            if find(contains(Jsonfieldname,'RobotEndEffector'))
                gSeqData.SimInfo.RobotEndEffectorInfo = JsonRobotInfo.RobotInfo.RobotEndEffector;
            end
        
            if find(contains(Jsonfieldname,'RiskSpace'))
                gSeqData.SimInfo.RiskSpaceInfo = JsonRobotInfo.RobotInfo.RiskSpace;
            end
        
            if find(contains(Jsonfieldname,'MotionDivision'))
                gSeqData.SimInfo.MotionDivisionInfo=JsonRobotInfo.RobotInfo.MotionDivision;
            end

            if length(find(strcmpi(Jsonfieldname,'Motiondivision')==1))~=false
                if size(JsonRobotInfo.RobotInfo.MotionDivision)~=false
                    gSeqData.SimInfo.MotionDivisionApp=true;
                else
                    gSeqData.SimInfo.MotionDivisionApp=false;
                end
            else
                gSeqData.SimInfo.MotionDivisionApp=false;
            end

        else
            
        end

    catch

    end

end