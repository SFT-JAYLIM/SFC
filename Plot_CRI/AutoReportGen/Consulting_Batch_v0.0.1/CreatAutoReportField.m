function CreatAutoReportField(gSeqData, TaskIdx)
     gSeqData.FolderInfo.AnalysisInfoFile=[gSeqData.FolderInfo.UserPath,'\ST_RobotInfo.json'];
     
     if isfile(gSeqData.FolderInfo.AnalysisInfoFile)
         fileID = fopen(gSeqData.FolderInfo.AnalysisInfoFile, 'r');
         rawdata = fread(fileID, inf);
         str = char(rawdata');
         fclose(fileID);

         JsonRobotInfo = jsondecode(str);
         Jsonfieldname = fieldnames(JsonRobotInfo.RobotInfo);
                    
         if find(contains(Jsonfieldname,'BasicInfo'))
             temp.RobotInfo.BasicInfo = JsonRobotInfo.RobotInfo.BasicInfo;
         end

         if TaskIdx==1
             temp.RobotInfo.AutoReport.DocNo = "Null";
             temp.RobotInfo.AutoReport.RobotUserName  = "Null"
             temp.RobotInfo.AutoReport.InstallationSite  = "Null";
             temp.RobotInfo.AutoReport.ProcessName  = "Null";
             temp.RobotInfo.AutoReport.IssuingCompany  = "SAFETICS. INC.";
             temp.RobotInfo.AutoReport.Issuer  = "Technical Value Team / Jung. H. Lim";
             temp.RobotInfo.AutoReport.Purpose  = "Apply for certification or submit to other agencies";
             temp.RobotInfo.AutoReport.Standard  = "Null";         
             temp.RobotInfo.AutoReport.Manufacturer  = FindRobotManufacturer (JsonRobotInfo.RobotInfo.BasicInfo.RobotModel);
             temp.RobotInfo.AutoReport.Language  = "Null";
         else
             temp.RobotInfo.AutoReport.DocNo = "Null";
             temp.RobotInfo.AutoReport.RobotUserName  = "The whom may it concerned";
             temp.RobotInfo.AutoReport.InstallationSite  = "Adresss";
             temp.RobotInfo.AutoReport.ProcessName  = "Process Name";
             temp.RobotInfo.AutoReport.IssuingCompany  = "SAFETICS. INC.";
             temp.RobotInfo.AutoReport.Issuer  = "Technical Value Team / Jung. H. Lim";
             temp.RobotInfo.AutoReport.Purpose  = "Apply for certification or submit to other agencies";
             temp.RobotInfo.AutoReport.Standard  = "Null";         
             temp.RobotInfo.AutoReport.Manufacturer  = FindRobotManufacturer (JsonRobotInfo.RobotInfo.BasicInfo.RobotModel);
             temp.RobotInfo.AutoReport.Language  = "Null";
         end
        
         if find(contains(Jsonfieldname,'CustomEE'))
             temp.RobotInfo.CustomEE=JsonRobotInfo.RobotInfo.CustomEE;
         end
        
         if find(contains(Jsonfieldname,'RobotLink'))
             temp.RobotInfo.RobotLink = JsonRobotInfo.RobotInfo.RobotLink;
         end
        
         if find(contains(Jsonfieldname,'RobotEndEffector'))
             temp.RobotInfo.RobotEndEffector = JsonRobotInfo.RobotInfo.RobotEndEffector;
         end
        
         if find(contains(Jsonfieldname,'RiskSpace'))
             temp.RobotInfo.RiskSpace = JsonRobotInfo.RobotInfo.RiskSpace;
         end
        
         if find(contains(Jsonfieldname,'MotionDivision'))
             temp.RobotInfo.MotionDivision=JsonRobotInfo.RobotInfo.MotionDivision;
         end
        
         JsonRobotInfo=[];
         JsonRobotInfo=temp;

         msg=jsonencode(JsonRobotInfo,PrettyPrint=true);

         fileID = fopen(gSeqData.FolderInfo.AnalysisInfoFile,'w');
         fprintf(fileID, msg);
         fclose(fileID);
     end
end





