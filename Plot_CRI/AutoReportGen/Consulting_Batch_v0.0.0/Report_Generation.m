function IsReportDone=Report_Generation(UserPath, AppDataPath, FormPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% information for Title page making
% -> when it is published, this information should be insert by user on UI
DocInfo.DocumentNo = 'SMBU20032TBU';
DocInfo.DateInfo=string(datetime('now'));
DocInfo.CustomerInfo='Safetics';
DocInfo.UserName='임정호';
DocInfo.RobotManufacturer = 'Doosan Robotics';
DocInfo.RobotModel = 'M0609';
DocInfo.RobotSerial = 'Serial Number';
DocInfo.InstallPlace='Daegu, Exco';
DocInfo.TestItem = 'Contact Force / Contact Pressure';
DocInfo.Writer = 'Heonsub, Shin';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

New='w';
Append='a';

% Report Generation Log file location
ReportFolder=[UserPath,'\Report'];
ReportFile='\RptGenLog.txt'
ReportGenLogPath=[ReportFolder,ReportFile];

if isfolder(ReportFolder)~=1
    mkdir(ReportFolder)
end

% Lang : Select the language
% When Lang 'K' : Written by KOREAN
% When Lang 'E' : Written by English

Lang='K';

% UserInput -> Select the target folder
UserPath=uigetfolder;
ReportGenStartFlag=0;

if UserPath==0
    % User didn't Select the folder 
    ReportGenStartFlag=0;
else % User didn't Select the folder
    ReportGenStartFlag=1;
end

%Pre-Process : Graph and Movie renewal -> decide by user!!
DataRenewal=0; 

if DataRenewal==0
    
else
    
end

%Process 1 : Generate the Title Page

%Process 2 : Generate the Info page

%Process 3 : Generate the Contents1 page

%Process 4 : Generate the Contents2 page

%Process 5 : Generate the MotionInfo page

end