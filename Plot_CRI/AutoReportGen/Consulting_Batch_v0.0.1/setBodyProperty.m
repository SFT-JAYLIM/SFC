function setBodyProperty(gSeqData, var)
    pathfilename = [gSeqData.FolderInfo.UserPath, '\ST_RobotInfo.json'];
    fileID = fopen(pathfilename, 'r');
    rawdata = fread(fileID, inf);
    str = char(rawdata');
    fclose(fileID);
    JsonRobotInfo = jsondecode(str);
    Jsonfieldname = fieldnames(JsonRobotInfo.RobotInfo);

    if find(contains(Jsonfieldname,'AutoReport'))
        JsonRobotInfo.RobotInfo.AutoReport.Standard=var;
    end

    if find(contains(Jsonfieldname,'BasicInfo'))
        JsonRobotInfo.RobotInfo.BasicInfo.BodyProperty=var;
    end

    msg=jsonencode(JsonRobotInfo,PrettyPrint=true);
    fileID = fopen(pathfilename, 'w');
    fprintf(fileID, msg);
    fclose(fileID);
end