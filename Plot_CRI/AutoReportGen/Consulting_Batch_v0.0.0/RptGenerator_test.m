function RptGenerator_test (UserPath)

clc

try
    system('taskkill /F /IM EXCEL.EXE');
    system('taskkill /F /IM Acrobat.exe');
%     fclose(LogfileID);
%     clear LogfileID;
catch

end

disp('[Status] = Report Generation Start');
tic 
    UserInfoPath=[UserPath,'\UserInfo.xlsx'];
    
    if isfile(UserInfoPath)
        UserInfo=readtable(UserInfoPath);    
        DocInfo.DocumentNo = char(table2cell(UserInfo(1,2)));
        formatOut ='yyyy-mm-dd';
        DocInfo.DateInfo=datestr(datetime('now'),formatOut);
        DocInfo.CustomerInfo=char(table2cell(UserInfo(2,2)));
        DocInfo.UserName=char(table2cell(UserInfo(3,2)));
        DocInfo.RobotManufacturer = char(table2cell(UserInfo(4,2)));
        DocInfo.RobotModel = char(table2cell(UserInfo(5,2)));
        DocInfo.RobotSerial = char(table2cell(UserInfo(6,2)));
        DocInfo.InstallPlace=char(table2cell(UserInfo(7,2)));
        DocInfo.Writer = char(table2cell(UserInfo(8,2)));
        DocInfo.Process = char(table2cell(UserInfo(9,2))); 
    else
        DocInfo.DocumentNo = 'N/A';
        formatOut ='yyyy-mm-dd';
        DocInfo.DateInfo=datestr(datetime('now'),formatOut);
        DocInfo.CustomerInfo='N/A';
        DocInfo.UserName='N/A';
        DocInfo.RobotManufacturer='N/A';
        DocInfo.RobotModel='N/A';
        DocInfo.RobotSerial='N/A';
        DocInfo.InstallPlace='N/A';
        DocInfo.Writer='N/A';
        DocInfo.Process='N/A';
    end

try
%% Define the Common Variable
    % Header Define
    HeaderGroup=["Unix_Time_Hour";"Unix_Time_Min";"Unix_Time_Sec";"Elapse";
    "Time";"q";"EffectiveMass";"ImpactVelNorm";"ImpactVelDirNorm";"ImpactVelAlphaNorm";
    "Force";"Pressure";"MaxCRI";"CRI";"MaxModiCRI";"ModiCRI";"ImpactPosList";
    "BoxInOutIndex";"AssignBoxIndex";"OverlappedBoxIndex";"MinScale";"Scale";
    "MinModiScale";"ModiScale";"ColliAlpha";"BasePosition";];

     % Criterion
    KHU=[410,410,2.9,2.9;250,500,1.8,3.6;310,620,3.9,7.8;510,1020,3.7,7.4];
    ISO=[130,130,1.3,1.3;140,280,1.2,1.2;150,300,1.9,3.8;140,280,3.0,6.0];

    % Properties ->> Body (refer to KOROS 1141)
    DocInfo.Properties=[4.4,70,150,7;40,70,25,7;40,30,30,14;0.6,70,75,7];
    
    % Sim Condition Check
    [IsSimOk SimCondIdx ColliBody BoundaryC]=ChkSimCondition(UserPath);
    
    %Default Path Set
     
    % Report Generation Folder Set or Make
    disp('[Status] = Folder Info Generate');
    ReportFolder=[UserPath,'\Report'];
    ReportFile='\RptGenLog.txt';
    ReportGenLogPath=[ReportFolder,ReportFile];
        
    whileIdx=1;
    disp('[Status] = Folder create start');
    while whileIdx
        if isfolder(ReportFolder)~=1
            mkdir(ReportFolder)
        else
        end
        whileIdx=~isfolder(ReportFolder);
    end

    disp('[Status] = Log File Create start');
    LogfileID=-1;
    whileIdx=1;
    while whileIdx

        FileOption='w';
        LogfileID = fopen(ReportGenLogPath, FileOption);
        pause(1);
        if LogfileID>=1
            whileIdx=0;
            disp('[Status] = Report Generation Log File Created');
        elseif LogfileID==-1
            whileIdx=1;
            disp('[Status] = Report Generation Log File Create Failed');
        end
    end

    % Specific file path set
    FormPath='D:\OneDrive\SAFETICS\03_consulting\Report_gen\format\';
    isReportFormatExist=isfile(FormPath);

%% RobotInfo Loading
    RobotInfoPath=[UserPath,'\ST_RobotInfo.txt'];
    isRobotInfoFileExist=isfile(RobotInfoPath);
    if isRobotInfoFileExist
        disp('[Status] = Loading the Robot Information');
         % initial data set & making
        fileID = fopen(RobotInfoPath,'r');
        in_data_cell = textscan(fileID,'%s');
        in_data = (in_data_cell{1,1});
        fclose(fileID);

        % Robotmodel
        RobotModelidx=find(strcmp(in_data,'#RobotModel') == true);
        RobotInfo.RobotModel = cell2mat(in_data(RobotModelidx(1)+1));
        
        if strcmpi(ColliBody,'SkullandForehead')
            DocInfo.ColliBody='머리';
            DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
        elseif strcmpi(ColliBody,'Chest')
            DocInfo.ColliBody='가슴';
            DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
        elseif strcmpi(ColliBody,'Upperarm')
            DocInfo.ColliBody='상완(삼각근)';
            DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
        elseif strcmpi(ColliBody,'HandandFinger')
            DocInfo.ColliBody='손';
            DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
        end

        % mobile or not
        isMobileRobot=in_data(find(strcmp(in_data,'#MobileBase') == true)+1);
        
        % Colli. fillet
        CLFidx = find(contains(in_data, '#ColliFillet'));
        
        for loop = 1:size(CLFidx)
            switch loop
                case loop == 1
                    RobotInfo.ColliFillet = cell2mat(in_data(CLFidx(loop)+1));
                otherwise
                    RobotInfo.ColliFillet = [RobotInfo.ColliFillet '%' cell2mat(in_data(CLFidx(loop)+1))];
            end
        end
        
        ColliFillet=[];
        ColliFillet_temp=split(RobotInfo.ColliFillet,'%');
        
        for loop = 1:size(CLFidx)
            ColliFillet(loop)=str2num(char(ColliFillet_temp(loop)));
        end

        % Colli. Body
        CLBidx = find(contains(in_data, '#ColliBody'));
        CLBCidx = find(contains(in_data, '#ColliBodyCloth'));
        CLBidx = setdiff(CLBidx, CLBCidx);
        RobotInfo.numColliBody = size(CLBidx,1);
        RobotInfo.numColliBodyCloth = size(CLBCidx,1);

        for loop = 1:RobotInfo.numColliBody
            switch loop
                case loop == 1
                    RobotInfo.ColliBody = cell2mat(in_data(CLBidx(loop)+1));
                    RobotInfo.ColliBodyCloth = cell2mat(in_data(CLBCidx(loop)+1));
                otherwise
                    RobotInfo.ColliBody = [RobotInfo.ColliBody '%' cell2mat(in_data(CLBidx(loop)+1))];
                    RobotInfo.ColliBodyCloth = [RobotInfo.ColliBodyCloth '%' cell2mat(in_data(CLBCidx(loop)+1))];
            end
        end
               
        ColliBody=split(RobotInfo.ColliBody,'%');
        ColliBody=char(ColliBody(1));
        
        ColliBodyCloth_temp=split(RobotInfo.ColliBodyCloth,'%');
        ColliBodyCloth=[];
        
        for loop = 1:RobotInfo.numColliBodyCloth
            ColliBodyCloth(loop)=str2num(char(ColliBodyCloth_temp(loop)));
        end
        
        CLHsidx = find(contains(in_data, '#Hspace'));
        if isempty(CLHsidx) || strcmp(in_data{CLHsidx(1) + 1}(1), '#')
            RobotInfo.Hspace = 'none';
        else
            for loop = 1:RobotInfo.numColliBody
                RobotInfo.Hspace(4*(loop-1)+1) = str2double(cell2mat(in_data(CLHsidx(loop)+1)));
                RobotInfo.Hspace(4*(loop-1)+2) = str2double(cell2mat(in_data(CLHsidx(loop)+2)));
                RobotInfo.Hspace(4*(loop-1)+3) = str2double(cell2mat(in_data(CLHsidx(loop)+3)));
                RobotInfo.Hspace(4*(loop-1)+4) = str2double(cell2mat(in_data(CLHsidx(loop)+4)));
            end
        end

        % Get target robot name
        TargetRobot=char(in_data(find(strcmp(in_data,'#RobotModel') == true)+1));

        % Calculate the collision points on robot
        if cell2mat(isMobileRobot)=='1'
            PTsOnRobot=0;
        elseif contains(TargetRobot,'UR')
            PTsOnRobot=7;
        else
            PTsOnRobot=6;    
        end

        % Joint seperation
        ColliJointidxMat=strfind(in_data,['#ColliJoint']);
        ColliJointidx = find(not(cellfun('isempty',ColliJointidxMat)));
        numColliJoint = size(ColliJointidx, 1);
        for loop=1:numColliJoint
            RobotInfo.ColliJoint(1*(loop-1)+1)=str2double(cell2mat(in_data(ColliJointidx(loop)+1)));
        end
        
        J=RobotInfo.ColliJoint;
        [m n]=size(J);
        NJ=[0 0 0];

        if cell2mat(isMobileRobot)=='1'
            J1=find(J==0); J2=find(J>=1 & J<6); J3=find(J==6);
            [m1 n1]=size(J1); TempJ1=J1(1:n1-1);TempJ2=[max(J1),J2];
            clear J1, clear J2
            J1=TempJ1; J2=TempJ2;
            clear TempJ1, clear TempJ2
        else
            J1=find(J==0); J2=find(J>=1 & J<6); J3=find(J==6);
            TempJ2=[J1 J2]; clear J1, clear J2
            J1=[]; J2=TempJ2; clear TempJ2;
        end

        [m1 n1]=size(J1); [m2 n2]=size(J2); [m3 n3]=size(J3);

        for i=1:n    
            if J(i)==0
                NJ(1,1)=NJ(1,1)+1; %% # of collipos on mobile robot
            elseif J(i)==6
                NJ(1,3)=NJ(1,3)+1; %% #of collipos on End Effector
            else
                NJ(1,2)=NJ(1,2)+1; %% # of collipos on robot
            end
        end

        Joint.MobileLow=num2str(min(J1));
        Joint.MobileHi=num2str(max(J1));
        Joint.CobotLow=num2str(min(J2));
        Joint.CobotHi=num2str(max(J2));
        Joint.EELow=num2str(min(J3));
        Joint.EEHi=num2str(max(J3));

        VelGraphIdx=0;

        if (NJ(1,1)==0)&(NJ(1,2)==0)&(NJ(1,3)==0)
            % 0: 모든관절이 0 개
            VelGraphIdx=0;
        elseif (NJ(1,1)~=0)&(NJ(1,2)==0)&(NJ(1,3)==0)
            % 1: 모바일 베이스만 있을 때
            VelGraphIdx=1;
        elseif (NJ(1,1)==0)&(NJ(1,2)~=0)&(NJ(1,3)==0)
            % 2: 협동로봇만 있을 때
            VelGraphIdx=2;
        elseif (NJ(1,1)==0)&(NJ(1,2)==0)&(NJ(1,3)~=0)
            % 3: EE만 있을 때
            VelGraphIdx=3;
        elseif (NJ(1,1)~=0)&(NJ(1,2)~=0)&(NJ(1,3)==0)
            % 4: 모바일, 협동로봇만 있을 때
            VelGraphIdx=4;
        elseif (NJ(1,1)~=0)&(NJ(1,2)==0)&(NJ(1,3)~=0)
            % 5: 모바일과 EE만 있을 때
            VelGraphIdx=5;
        elseif (NJ(1,1)==0)&(NJ(1,2)~=0)&(NJ(1,3)~=0)
            % 6: 협동로봇과 EE만 있을 때
            VelGraphIdx=6;
        else
            % 7: 모바일, 협동로봇, EE 다 있을 때
            VelGraphIdx=7;
        end
        
        disp('[Status] = Success the loading the Robot Information');

        % Body Properties
        % select the analysis criterion
        if cell2mat(in_data(find(strcmp(in_data,'#BodyProperty'))))
            BodyProperties=in_data(find(strcmp(in_data,'#BodyProperty') == true)+1);
        else
            BodyProperties={'BOTH'};
        end
        
        BodyPPIdx=length(char(BodyProperties));
        BothFlag=0;
        
        whileIdx=1;
        
        while whileIdx
        
            switch BodyPPIdx

                case 0

                case 3

                    if char(BodyProperties)=='KHU'
                        disp(' ');
                        disp('======== PFL REPORT 1 / 1 GENERATE START ========')
                        disp(' ');
                        DocInfo.pn='\KHU';
                        DocInfo.fn='\KHU_Collision_Risk_Analyze_Result.csv';
                        DocInfo.Riskfn=DocInfo.fn;
                        DocInfo.ReferenceName='KOROS 1162-1:2021';
                        DocInfo.RefereceValue=KHU;
                        RiskSpaceInfoImg=[UserPath,'\output\KHU_RiskSpace.jpg'];
                        BodyPPIdx=6;
                        TerminateFlag=1;
                        DocInfo.RefIdx='KHU';
                        whileIdx=1;
                    else
                        disp(' ');
                        disp('======== PFL REPORT 1 / 1 GENERATE START ========')
                        disp(' ');
                        DocInfo.pn='\ISO';
                        DocInfo.fn='\ISO_Collision_Risk_Analyze_Result.csv';
                        DocInfo.Riskfn=DocInfo.fn;
                        DocInfo.ReferenceName='ISO/TS 15066:2016';
                        DocInfo.RefereceValue=ISO;
                        RiskSpaceInfoImg=[UserPath,'\output\ISO_RiskSpace.jpg'];
                        DocInfo.RefIdx='ISO';
                        BodyPPIdx=6;
                        TerminateFlag=1;
                        whileIdx=1;
                    end

                case 4 % when both
                    disp(' ');
                    disp('======== PFL REPORT 1 / 2 GENERATE START ========')
                    disp(' ');
                    BothFlag=1;
                    DocInfo.pn='\KHU';
                    DocInfo.fn='\KHU_Collision_Risk_Analyze_Result.csv';
                    DocInfo.Riskfn=DocInfo.fn;
                    DocInfo.ReferenceName='KOROS 1162-1:2021';
                    DocInfo.RefereceValue=KHU;
                    RiskSpaceInfoImg=[UserPath,'\output\KHU_RiskSpace.jpg'];
                    DocInfo.RefIdx='KHU';
                    BodyPPIdx=6;
                    TerminateFlag=0;
                    whileIdx=1;

                case 5
                    disp(' ');
                    disp('======== PFL REPORT 2 / 2 GENERATE START ========')
                    disp(' ');
                    BothFlag=2;
                    DocInfo.pn='\ISO';
                    DocInfo.fn='\ISO_Collision_Risk_Analyze_Result.csv';
                    DocInfo.Riskfn=DocInfo.fn;
                    DocInfo.ReferenceName='ISO/TS 15066:2016';
                    DocInfo.RefereceValue=ISO;
                    DocInfo.RefIdx='ISO';
                    RiskSpaceInfoImg=[UserPath,'\output\ISO_RiskSpace.jpg'];
                    BodyPPIdx=6;
                    TerminateFlag=1;
                    whileIdx=1;

                case 6
                    % Report Format generating
                    if isfile([FormPath,'Report_Format.xlsx'])
                        disp('[Status] = Generate the Report Format to publish')
                        Status=copyfile([FormPath,'Report_Format.xlsx'],[UserPath,'\Report\PFL_REPORT_',DocInfo.RefIdx,'.xlsx']);
                        if Status==1
                            disp('[Status] = Report Format Generated is Succesee')
                        else
                            disp('[Status] = Report Format Generated is Failed')
                        end
                    else
                        disp('[Status] = Generate the Report Format to publish is failed. Please check your Database')
                    end
                    
                 %% Solver Result Loading
                    disp('[Status] = Loading the Reuslt and Analysis');

                    ResDataPath=[UserPath DocInfo.fn];
                    org=importdata(ResDataPath);
                    header=org.colheaders;
                    NumofColliPos=sum(contains(org.colheaders,'EffectiveMass'));

                    idxCnt=0;
                    for i=1:length(HeaderGroup)
                        % count the # of element
                        if HeaderGroup(i)=='Time'
                            HeaderGroup(i,2)=1;
                        elseif HeaderGroup(i)=='CRI'
                            HeaderGroup(i,2)=NumofColliPos;
                        elseif HeaderGroup(i)=='ModiCRI'
                            HeaderGroup(i,2)=NumofColliPos;
                        elseif HeaderGroup(i)=='Scale'
                            HeaderGroup(i,2)=NumofColliPos;
                        elseif HeaderGroup(i)=='ModiScale'
                            HeaderGroup(i,2)=NumofColliPos;
                        else
                            HeaderGroup(i,2)=sum(contains(header,char(HeaderGroup(i))));
                        end

                        if i==1
                            HeaderGroup(i,3)=HeaderGroup(i,2);
                            HeaderGroup(i,4)=num2str(str2num(HeaderGroup(i,2))+str2num(HeaderGroup(i,3))-1);
                        else
                            if str2num(HeaderGroup(i,2))==0
                                HeaderGroup(i,3)=HeaderGroup(i-1,4);
                                HeaderGroup(i,4)=HeaderGroup(i,3);       
                            elseif str2num(HeaderGroup(i,2))==1
                                HeaderGroup(i,3)=num2str(str2num(HeaderGroup(i-1,4))+1);
                                HeaderGroup(i,4)=HeaderGroup(i,3);
                            else
                                HeaderGroup(i,3)=num2str(str2num(HeaderGroup(i-1,4))+1);
                                HeaderGroup(i,4)=num2str(str2num(HeaderGroup(i,2))+str2num(HeaderGroup(i,3))-1);
                            end
                        end

                        idxCnt=idxCnt+str2num(HeaderGroup(i,2));
                    end

                    trimedData=[];
                    [m n]=size(trimedData);

                    HeaderName='MaxModiCRI';
                    Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
                    Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
                    MaxModiCRI=org.data(:,Scol);

                    formatSpec = '%.3f';

                    if max(MaxModiCRI) <= 1
                        DocInfo.MaxCriMsg='PASS';
                    else
                        DocInfo.MaxCriMsg='FAIL';
                    end

                %% Image Information Exist Check
                    disp('[Status] = Loading the Image Data');
                    % Colli Pos on Robot   
                    ColliPosImgOnRobot=[UserPath, '\output\ColliPosOnRobot_dot.jpg'];
                    isAllColliPosImgExist=isfile(ColliPosImgOnRobot);
                    % Colli Pos on EE
                    ColliPosImgOnEE=[UserPath,'\output\ColliPosOnEE_dot.jpg']; 
                    isColliPosOnEEImgExist=isfile(ColliPosImgOnEE);
                    % Velocity Info
                    VelocityImg=[UserPath,'\graph',DocInfo.pn,'\All_pos_velocity.jpg'];
                    isVelocityImgExist=isfile(VelocityImg);
                    % Mobile Robot Velocity Info
                    MobileVelocityImg=[UserPath,'\graph',DocInfo.pn,'\Mobile_base_velocity.jpg'];
                    isMobileVelocityImgExist=isfile(MobileVelocityImg);
                    % Cobot Velocity Info
                    CobotVelocityImg=[UserPath, '\graph',DocInfo.pn,'\Cobot_velocity.jpg'];
                    isCobotVelocityImgImgExist=isfile(CobotVelocityImg);
                    %EE Velocity Info
                    EEVelocityImg=[UserPath, '\graph',DocInfo.pn,'\EE_Vel.jpg'];
                    isEEVelVelocityImgImgExist=isfile(CobotVelocityImg);
                    % CRI IMG
                    CRIinfoImg=[UserPath,'\graph',DocInfo.pn,'\All_CRI_Res.jpg'];
                    isCRIInfoImgExist=isfile(CRIinfoImg);
                    % Motion Split Image
                    MotionImg=[UserPath,'\output',DocInfo.pn,'_RiskSpace\000001.jpg'];
                    isMotionImgExist=isfile(MotionImg);

                    if isAllColliPosImgExist
                        disp('    - Loading the Image Data 1 / 5 Success');
                    else
                        disp('    - Loading the Image Data 1 / 5 Failed');
                    end

                    if isColliPosOnEEImgExist
                        disp('    - Loading the Image Data 2 / 5 Success');
                    else
                        disp('    - Loading the Image Data 2 / 5 Failed');
                    end

                    if isVelocityImgExist
                        disp('    - Loading the Image Data 3 / 5 Success');
                    else
                        disp('    - Loading the Image Data 3 / 5 Failed');
                    end

                    if isCRIInfoImgExist
                        disp('    - Loading the Image Data 4 / 5 Success');
                    else
                        disp('    - Loading the Image Data 4 / 5 Failed');
                    end

                    if isMotionImgExist
                        disp('    - Loading the Image Data 5 / 5 Success');
                    else
                        disp('    - Loading the Image Data 5 / 5 Failed');
                    end

                    % Report file save Path Set
                    excelFileName=[UserPath,'\Report\PFL_REPORT_',DocInfo.RefIdx,'.xlsx'];

                    % Signature
                    if ((contains(DocInfo.Writer,'Shin')) || (contains(DocInfo.Writer,'shin')) || (contains(DocInfo.Writer,'신')))
                        SinatureImg=[FormPath,'signature__SHS.jpg'];
                    elseif ((contains(DocInfo.Writer,'Lim')) || (contains(DocInfo.Writer,'lim')) || (contains(DocInfo.Writer,'임')))
                        SinatureImg=[FormPath,'signature__LJH.jpg'];
                    else
                        SinatureImg=[FormPath,'Safetics_CI.png'];
                    end

                   %% Title Page Generation
                    SimStartCnt=string(datetime('now'));

                    isTitlePageDone=0;

                    fprintf(LogfileID, '============== Title Page Generation Start ==============');
                    disp('[Status] = Title Page Generation Start')
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '[Status] = Title Page Generation Start : %s\n', SimStartCnt);

                    % Excel Open by activX server
                    objExcel = actxserver('Excel.Application');
                    h=objExcel.Workbooks.Open(excelFileName); % Open Excel file. Full path is necessary!

                    % Re-scale factor
                    ImgHeightCoeff = 0.264567;
                    ImgWidthCoeff = 0.2646;

                    ExcelHeightCoeff = 0.36;
                    ExcelWidthCoeff = 2.352941;

                    CompensationCoeff=0.72;

                    % Cell Define
                    Cell.DocumentNoCell='E14';
                    Cell.DateInfoCell='E15';
                    Cell.CustomerInfoCell='E16';
                    Cell.RobotManufacturerCell='E17';
                    Cell.RobotModeCell='E18';
                    Cell.InstallPlaceCell='E19';
                    Cell.TestItem = 'E20';
                    Cell.WriterCell='E21';
                    Cell.Signature='H22';
                    Cell.Process='A30';
                    Cell.AnalysisCondtion='D30';
                    Cell.Results='H30';

                    % Define the Sheet
                    SheetName='Title';
                    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;

                    % DocumentNo
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.DocumentNoCell);
                    eActivesheetRange.Value=DocInfo.DocumentNo;

                    % DateInfo
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.DateInfoCell);
                    eActivesheetRange.Value=DocInfo.DateInfo;

                    % CustomerInfo
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.CustomerInfoCell);
                    eActivesheetRange.Value=[DocInfo.CustomerInfo, ' / ',DocInfo.UserName];

                    % RobotManufacturer
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotManufacturerCell);
                    eActivesheetRange.Value=DocInfo.RobotManufacturer;

                    % RobotModel
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotModeCell);
                    eActivesheetRange.Value=[DocInfo.RobotModel, ' / ', DocInfo.RobotSerial];

                    % InstallPlace
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.InstallPlaceCell);
                    eActivesheetRange.Value=DocInfo.InstallPlace;

                    % TestItem
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.TestItem);
                    eActivesheetRange.Value=DocInfo.TestItem;

                    % Writer
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.WriterCell);
                    eActivesheetRange.Value=DocInfo.Writer;

                    % Process
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.Process);
                    eActivesheetRange.Value=DocInfo.Process;

                    % Analysis Condition
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.AnalysisCondtion);
                    eActivesheetRange.Value=[DocInfo.ColliBody,' / 동적'];

                    % CRI Res
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.Results);
                    eActivesheetRange.Value=DocInfo.MaxCriMsg;

                    % Colli. Pos. on robot
                    if isfile(SinatureImg)
                        imInfo = imfinfo(SinatureImg);

                        ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                        ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                        CellRealHeight=(25+16.5)*ExcelHeightCoeff;
                        CellRealWidth=8.5*3*ExcelWidthCoeff;

                        imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                        imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                        topLeftCorner = Cell.Signature;

                        LinkToFile = 0;
                        SaveWithDocument = 1;
                        left = objExcel.ActiveSheet.Range(topLeftCorner).Left;
                        top = objExcel.ActiveSheet.Range(topLeftCorner).Top;
                        objExcel.ActiveSheet.Shapes.AddPicture(SinatureImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                        DoneMsg='Title Page Generation Sucess';
                        disp(['[Status] = ',DoneMsg]);
                    else
                        fprintf(LogfileID, '[Status] = Writers Signature file missing!!');
                        fprintf(LogfileID, '\r\n');
                        msg='Writers Sigature File Missing !!';
                        disp(['[Warnning] = ',msg])
                        DoneMsg='Title Page Generate Success (without Signature)';
                        disp(['[Status] = ',DoneMsg])
                    end

                    SimEndCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Title Page Generation End : %s\n', SimEndCnt);
                    fprintf(LogfileID, ['[Status] = ',DoneMsg]);
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');

                    isTitlePageDone=1;

                 %% Info Page Generation
                    isInfoPageDone=0;

                    %Start Time Cnt
                    SimStartCnt=string(datetime('now'));
                    fprintf(LogfileID, '============== Info Page Generation Start ==============');
                    disp('[Status] = Info Page Generation Start')
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '[Status] = Info Page Generation Start : %s\n', SimStartCnt);

                    Cell.RefereceName='C4';
                    Cell.RefValueStartIdx='E7';
                    Cell.RefValueEndIdx='H10';
                    Cell.PropertyRefName='C14';
                    Cell.PropertyStartIdx='E16';
                    Cell.PropertyEndIdx='H19';

                    if strcmpi(ColliBody,'SkullandForehead')
                        DocInfo.ColliBody='머리';
                        Cell.RefActivateCell='I7';
                        Cell.PropertiesActivateCell='I16';
                        Cell.ColorRange='C7:I7';
                        Cell.ColorRange2='C16:I16';
                    elseif strcmpi(ColliBody,'Chest')
                        DocInfo.ColliBody='가슴';
                        Cell.RefActivateCell='I8';
                        Cell.PropertiesActivateCell='I17';
                        Cell.ColorRange='C8:I8';
                        Cell.ColorRange2='C17:I17';
                    elseif strcmpi(ColliBody,'Upperarm')
                        DocInfo.ColliBody='상완(삼각근)';
                        Cell.RefActivateCell='I9';
                        Cell.PropertiesActivateCell='I18';
                        Cell.ColorRange='C9:I9';
                        Cell.ColorRange2='C18:I18';
                    elseif strcmpi(ColliBody,'HandandFinger')
                        DocInfo.ColliBody='손';
                        Cell.RefActivateCell='I10';
                        Cell.PropertiesActivateCell='I19';
                        Cell.ColorRange='C10:I10';
                        Cell.ColorRange2='C19:I19';

                    end

                    SheetName='Info';
                    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate

                    % Refered Reference Name (for safety)) ==> KOROS or ISO
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RefereceName);
                    eActivesheetRange.Value=DocInfo.ReferenceName;
                    % eActivesheetRange.Value='ISO TS 15066 : 2016';

                    % Criterion value ==> KOROS or ISO
                    eActivesheetRange = get(objExcel.Activesheet,'Range',[Cell.RefValueStartIdx,':',Cell.RefValueEndIdx]);
                    eActivesheetRange.Value=DocInfo.RefereceValue;

                    % Check the Note section
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RefActivateCell);
                    eActivesheetRange.Value='V';

                    % Properties
                    eActivesheetRange = get(objExcel.Activesheet,'Range',[Cell.PropertyStartIdx,':',Cell.PropertyEndIdx]);
                    eActivesheetRange.Value=DocInfo.Properties;

                    % Check the Note section
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.PropertiesActivateCell);
                    eActivesheetRange.Value='V';

                    % FontColor
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ColorRange);
                    eActivesheetRange.font.Color='000000';
                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ColorRange2);   
                    eActivesheetRange.font.Color='000000';

                    SimEndCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Info Page Generation End : %s\n', SimEndCnt);
                    fprintf(LogfileID, '[Status] = Info Page Generation Sucess');
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');
                    isInfoPageDone=1;
                    disp('[Status] = Info Page Generate Success')

                 %% Contents1 Page Generation    
                    isRptContents1PageDone=0;
                    VcaptionMsg=[];

                    fprintf(LogfileID, '============== Contents1 Generation Start ===============');
                    disp('[Status] = Contents1 Generation Start')
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '[Status] = Title Page Generation Start : %s\n', SimStartCnt);

                    % Cell Define
                    Cell.Caption='A12';
                    
                    Cell.ListOfIdx1='A15';
                    Cell.ListOfIdx2='A16';
                    Cell.ListOfIdx3='A17';

                    Cell.RobotType1='D15';
                    Cell.RobotType2='D16';
                    Cell.RobotType3='D17';

                    Cell.ShapeInfo1='F15';
                    Cell.ShapeInfo2='F16';
                    Cell.ShapeInfo3='F17';

                    Cell.Note1='L15';
                    Cell.Note2='L16';
                    Cell.Note3='L17';
                    
                    Cell.EndLine = 'A18';

                    Cell.ColliPosImgOnRobot = 'A5';
                    Cell.ColliPosImgOnEE = 'H5';
%                     Cell.VelocityImg = 'B21';
%                     Cell.CaptionForVelocity='A30';

                    % Contents 1 sheet activate
                    SheetName='Contents1';
                    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate; % set active sheet

                    % Colli. Pos. on robot
                    imInfo = imfinfo(ColliPosImgOnRobot);

                    ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                    ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                    CellRealHeight=175*ExcelHeightCoeff;
                    CellRealWidth=42.5*ExcelWidthCoeff;

                    imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                    imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                    LinkToFile = 0;
                    SaveWithDocument = 1;
                    left = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnRobot).Left;
                    top = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnRobot).Top;
                    objExcel.ActiveSheet.Shapes.AddPicture(ColliPosImgOnRobot,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

                    % Colli. Pos. on EE
                    imInfo = imfinfo(ColliPosImgOnEE);

                    ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                    ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                    CellRealHeight=175*ExcelHeightCoeff;
                    CellRealWidth=42.5*ExcelWidthCoeff;

                    imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                    imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                    LinkToFile = 0;
                    SaveWithDocument = 1;
                    left = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnEE).Left;
                    top = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnEE).Top;
                    objExcel.ActiveSheet.Shapes.AddPicture(ColliPosImgOnEE,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

                    % make the table
                    RowHeightTotal=435;
                    RowHeightPerLine=35;
                    RowHeightAverage=55;
                    RowEndLine=25;
                    RowMargin=20;              
                    
                    if RobotInfo.numColliBodyCloth==0
                        ClothFillet=0;
                    else
                        ClothFillet=ColliBodyCloth(1);
                    end
                    
                    [JN JM]=size(J3);
                    
                    switch VelGraphIdx

                        case 0
                            % 0: 모든관절이 0 개
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value='None';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value='None';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx3);
                            eActivesheetRange.Value='None';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo1);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            eActivesheetRange.Value=' ';
                            
                            objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=RowHeightAverage;
                            objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=RowHeightAverage;
                            objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=RowHeightAverage;
                            EndLineHeight=RowHeightTotal-(RowHeightAverage*3);
                            objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;

                        case 1 % 1: 모바일 베이스만 있을 때
                            % 충돌지점 번호
                            if str2num(Joint.MobileLow)~=str2num(Joint.MobileHi);
                                msg1=[Joint.MobileLow,' ~ ',Joint.MobileHi];
                            elseif str2num(Joint.MobileLow)==str2num(Joint.MobileHi)
                                msg1=[Joint.MobileLow];
                            else
                            end
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value=msg1;

                            msg2='- 이하여백 - ';
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value=msg2;

                            % 충돌대상
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value='모바일로봇'; 

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType2);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType3);
                            eActivesheetRange.Value=' ';

                            % 형상정보
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo1);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            eActivesheetRange.Value=' ';
                            
                            objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=RowHeightAverage;
                            objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=RowHeightAverage;
                            objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=RowHeightAverage;
                            EndLineHeight=RowHeightTotal-(RowHeightAverage*3);
                            objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;

                        case 2 % 2: 협동로봇만 있을 때
                            % 충돌지점 번호
                            if str2num(Joint.CobotLow)~=str2num(Joint.CobotHi)
                                msg1=[Joint.CobotLow,' ~ ',Joint.CobotHi];
                            elseif str2num(Joint.CobotLow)==str2num(Joint.CobotHi)
                                msg1=[Joint.CobotLow];
                            else
                            end
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value=msg1;

                            msg2='- 이하여백 - ';
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value=msg2;

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx3);
                            eActivesheetRange.Value=' ';

                            % 충돌대상
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value='협동로봇'; 

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType2);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType3);
                            eActivesheetRange.Value=' ';

                            % 형상정보
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo1);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            eActivesheetRange.Value=' ';
                            
                            objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=RowHeightAverage;
                            objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=RowHeightAverage;
                            objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=RowHeightAverage;
                            EndLineHeight=RowHeightTotal-(RowHeightAverage*3);
                            objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;

                        case 3 % 3: EE만 있을 때
                            % 충돌지점 번호
                            if str2num(Joint.EELow)~=str2num(Joint.EEHi)
                                 msg1=[Joint.EELow,' ~ ',Joint.EEHi];
                            elseif str2num(Joint.EELow)==str2num(Joint.EEHi)
                                 msg1=[Joint.EELow];
                            else
                            end
                           
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value=msg1;

                            msg2='- 이하여백 - ';
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value=msg2;   

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx3);
                            eActivesheetRange.Value=' ';

                            % 충돌대상
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value='끝단'; 

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType2);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType3);
                            eActivesheetRange.Value=' ';

                            % 형상정보
                            msg='';
                            idx=0;
                            if isempty(J3)~=1
                                for i=1:length(J3)
                                    if J3(i)~=0
                                        idx=idx+1;

                                        if strcmpi(ColliBody,'SkullandForehead')

                                        elseif strcmpi(ColliBody,'Chest')

                                        elseif strcmpi(ColliBody,'Upperarm')

                                        elseif strcmpi(ColliBody,'HandandFinger')

                                        end

                                        CoverFillet=SimCondIdx(J3(i),9);
                                        OwnFillet=SimCondIdx(J3(i),8);

                                        %default msg
                                        msg=[msg,num2str(idx),') ',num2str(J3(i)),'번 지점 필렛 ',num2str(SimCondIdx(J3(i),8)),' mm 적용'];
                                        msg=[msg,char(13),char(10)];

                                        %Additional msg
                                        if CoverFillet==0
                                            if OwnFillet==0 % -> Cover : 0, Own : 0, Add~=0
                                                msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                msg=[msg,char(13),char(10)];
                                            else % -> Cover : 0, Own ~=0, Add~=0
                                                msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), 'mm, 피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                msg=[msg,char(13),char(10)];                            
                                            end

                                        else % Cover~=0
                                            if OwnFillet==0 % -> Cover ~=0 0, Own : 0, Add~=0
                                                msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용) '];
                                                msg=[msg,char(13),char(10)];
                                            else % -> Cover ~=0, Own ~=0, Add~=0
                                                msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), ' mm, 피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용)'];
                                                msg=[msg,char(13),char(10)];
                                            end
                                        end                
                                    end
                                    
                                    if i==length(J3)
                                        msg=msg(1:(length(msg)-2));
                                    end
                                    
                                end
                                
                                if size(J3)==1
                                    CaptionLineHeight=RowHeightAverage;
                                else
                                    CaptionLineHeight=RowHeightPerLine*length(J3);
                                end
                                
                                if CaptionLineHeight>(RowHeightTotal-(RowHeightAverage*2))
                                    CaptionLineHeight=(RowHeightTotal-(RowHeightAverage*2));
                                    EndLineHeight=25;
                                else
                                    EndLineHeight=RowHeightTotal-(RowHeightAverage*2+CaptionLineHeight);
                                end
                                
                                objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=CaptionLineHeight;
                                objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=RowHeightAverage;
                                objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=RowHeightAverage;
                                objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;
                            end
                            eActivesheetRange.Value=msg;

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);
                            eActivesheetRange.Value=' ';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            eActivesheetRange.Value=' ';
                            
                            

                        case 4 % 4: 모바일, 협동로봇만 있을 때
                            % 충돌지점 번호
                            if str2num(Joint.MobileLow)~=str2num(Joint.MobileHi);
                                msg1=[Joint.MobileLow,' ~ ',Joint.MobileHi];
                            elseif str2num(Joint.MobileLow)==str2num(Joint.MobileHi)
                                msg1=[Joint.MobileLow];
                            else
                            end
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value=msg1;

                            if str2num(Joint.CobotLow)~=str2num(Joint.CobotHi)
                                msg2=[Joint.CobotLow,' ~ ',Joint.CobotHi];
                            elseif str2num(Joint.CobotLow)==str2num(Joint.CobotHi)
                                msg2=[Joint.CobotLow];
                            else
                            end
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value=msg2;  

                            msg3='- 이하여백 - ';
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx3);
                            eActivesheetRange.Value=msg3;

                            % 충돌대상
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value='모바일로봇'; 

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType2);
                            eActivesheetRange.Value='협동로봇';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType3);
                            eActivesheetRange.Value=' ';

                            % 형상정보
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo1);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            eActivesheetRange.Value=' ';

                        case 5 % 5: 모바일과 EE만 있을 때
                            % 충돌지점 번호
                            if str2num(Joint.MobileLow)~=str2num(Joint.MobileHi);
                                msg1=[Joint.MobileLow,' ~ ',Joint.MobileHi];
                            elseif str2num(Joint.MobileLow)==str2num(Joint.MobileHi)
                                msg1=[Joint.MobileLow];
                            else
                            end

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value=msg1;

                            if str2num(Joint.EELow)~=str2num(Joint.EEHi)
                                 msg2=[Joint.EELow,' ~ ',Joint.EEHi];
                            elseif str2num(Joint.EELow)==str2num(Joint.EEHi)
                                 msg2=[Joint.EELow];
                            else
                            end
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value=msg2;  

                            msg3='- 이하여백 - ';
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx3);
                            eActivesheetRange.Value=msg3;

                            % 충돌대상
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value='모바일로봇'; 

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType2);
                            eActivesheetRange.Value='끝단';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType3);
                            eActivesheetRange.Value=' ';

                            % 형상정보
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo1);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);
                            msg='';
                            idx=0;
                            if isempty(J3)~=1
                                for i=1:length(J3)
                                    if J3(i)~=0
                                        idx=idx+1;
                                        
                                        if strcmpi(ColliBody,'SkullandForehead')

                                        elseif strcmpi(ColliBody,'Chest')

                                        elseif strcmpi(ColliBody,'Upperarm')

                                        elseif strcmpi(ColliBody,'HandandFinger')

                                        end

                                        CoverFillet=SimCondIdx(J3(i),9);
                                        OwnFillet=SimCondIdx(J3(i),8);

                                        %default msg
                                        msg=[msg,num2str(idx),') ',num2str(J3(i)),'번 지점 필렛 ',num2str(SimCondIdx(J3(i),8)),' mm 적용'];
                                        msg=[msg,char(13),char(10)];

                                        %Additional msg
                                        if CoverFillet==0
                                            if OwnFillet==0 % -> Cover : 0, Own : 0, Add~=0
                                                msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                msg=[msg,char(13),char(10)];
                                            else % -> Cover : 0, Own ~=0, Add~=0
                                                msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), 'mm, 피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                msg=[msg,char(13),char(10)];                            
                                            end

                                        else % Cover~=0
                                            if OwnFillet==0 % -> Cover ~=0 0, Own : 0, Add~=0
                                                msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용) '];
                                                msg=[msg,char(13),char(10)];
                                            else % -> Cover ~=0, Own ~=0, Add~=0
                                                msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), ' mm, 피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용)'];
                                                msg=[msg,char(13),char(10)];
                                            end
                                        end                
                                    end
                                    
                                    if i==length(J3)
                                        msg=msg(1:(length(msg)-2));
                                    end
                                    
                                end
                                
                                if size(J3)==1
                                    CaptionLineHeight=RowHeightAverage;
                                else
                                    CaptionLineHeight=RowHeightPerLine*length(J3);
                                end
                                
                                if CaptionLineHeight>(RowHeightTotal-(RowHeightAverage*2))
                                    CaptionLineHeight=(RowHeightTotal-(RowHeightAverage*2));
                                    EndLineHeight=25;
                                else
                                    EndLineHeight=RowHeightTotal-(RowHeightAverage*2+CaptionLineHeight);
                                end
                                
                                objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=RowHeightAverage;
                                objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=CaptionLineHeight;
                                objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=RowHeightAverage;
                                objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;
                                
                            end
                            eActivesheetRange.Value=msg;

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            eActivesheetRange.Value=' ';


                        case 6  % 6: 협동로봇과 EE만 있을 때
                            % 충돌지점 번호
                            if str2num(Joint.CobotLow)~=str2num(Joint.CobotHi)
                                msg1=[Joint.CobotLow,' ~ ',Joint.CobotHi];
                            elseif str2num(Joint.CobotLow)==str2num(Joint.CobotHi)
                                msg1=[Joint.CobotLow];
                            else
                            end
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value=msg1;

                            if str2num(Joint.EELow)~=str2num(Joint.EEHi)
                                 msg2=[Joint.EELow,' ~ ',Joint.EEHi];
                            elseif str2num(Joint.EELow)==str2num(Joint.EEHi)
                                 msg2=[Joint.EELow];
                            else
                            end
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value=msg2;  

                            msg3='- 이하여백 - ';
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx3);
                            eActivesheetRange.Value=msg3;

                            % 충돌대상
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value='협동로봇'; 

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType2);
                            eActivesheetRange.Value='끝단';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType3);
                            eActivesheetRange.Value=' ';

                            % 형상정보
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo1);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);

                            msg='';
                            idx=0;
                            if isempty(J3)~=1
                                for i=1:length(J3)
                                    if J3(i)~=0
                                        idx=idx+1;
%                                         TotalFillet=SimCondIdx(J3(i),8);

                                        if strcmpi(ColliBody,'SkullandForehead')

                                        elseif strcmpi(ColliBody,'Chest')

                                        elseif strcmpi(ColliBody,'Upperarm')

                                        elseif strcmpi(ColliBody,'HandandFinger')

                                        end

                                        CoverFillet=SimCondIdx(J3(i),9);
                                        OwnFillet=SimCondIdx(J3(i),8);

                                        %default msg
                                        msgFormat=1;
                                        switch msgFormat
                                            case 0
                                                msg=[msg,num2str(idx),') ',num2str(J3(i)),'번 지점 필렛 ',num2str(SimCondIdx(J3(i),8)),' mm 적용'];
                                                msg=[msg,char(13),char(10)];

                                                %Additional msg
                                                if CoverFillet==0
                                                    if OwnFillet==0 % -> Cover : 0, Own : 0, Add~=0
                                                        msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover : 0, Own ~=0, Add~=0
                                                        msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), 'mm, 피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                        msg=[msg,char(13),char(10)];                            
                                                    end

                                                else % Cover~=0
                                                    if OwnFillet==0 % -> Cover ~=0 0, Own : 0, Add~=0
                                                        msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용) '];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover ~=0, Own ~=0, Add~=0
                                                        msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), ' mm, 피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용)'];
                                                        msg=[msg,char(13),char(10)];
                                                    end
                                                end
                                                
                                            case 1
                                                
                                                RowHeightTotal=435;
                                                RowHeightPerLine=17;
                                                RowHeightAverage=30;
                                                RowEndLine=25;
                                                RowMargin=10;
                                                msg=[msg,num2str(idx),') ',num2str(J3(i)),'번 : '];
                                                
                                                %Additional msg
                                                if CoverFillet==0
                                                    if OwnFillet==0 % -> Cover : 0, Own : 0, Add~=0
                                                        msg=[msg,'피복 : ',num2str(ClothFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover : 0, Own ~=0, Add~=0
                                                        msg=[msg,'자체필렛 : ',num2str(OwnFillet), ', 피복 : ',num2str(ClothFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];                            
                                                    end

                                                else % Cover~=0
                                                    if OwnFillet==0 % -> Cover ~=0 0, Own : 0, Add~=0
                                                        msg=[msg,'피복 : ',num2str(ClothFillet),', 커버 : ',num2str(CoverFillet),' mm 적용 '];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover ~=0, Own ~=0, Add~=0
                                                        msg=[msg,'자체필렛 : ',num2str(OwnFillet), ', 피복 : ',num2str(ClothFillet),', 커버 : ',num2str(CoverFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];
                                                    end
                                                end
                                                
                                            case 2
                                                
                                            otherwise
                                                
                                        end                
                                    end
                                    
                                    if i==length(J3)
                                        msg=msg(1:(length(msg)-2));
                                    end
                                end
                                
                                if size(J3)==1
                                    CaptionLineHeight=RowHeightAverage;
                                else
                                    CaptionLineHeight=RowHeightPerLine*length(J3);
                                end
                                
                                if CaptionLineHeight>(RowHeightTotal-(RowHeightAverage+RowMargin*2))
                                    CaptionLineHeight=(RowHeightTotal-(RowHeightAverage+RowMargin*2));
                                    EndLineHeight=RowEndLine-RowMargin;
                                    objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=RowHeightAverage-RowMargin;
                                    objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=CaptionLineHeight;
                                    objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=RowHeightAverage-RowMargin;
                                    objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;
                                else
                                    EndLineHeight=RowHeightTotal-(RowHeightAverage*2+CaptionLineHeight);
                                    objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=RowHeightAverage;
                                    objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=CaptionLineHeight;
                                    objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=RowHeightAverage;
                                    objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;
                                end
                                
                            end

                            if size(J3)==1
                                CaptionLineHeight=RowHeightAverage;
                            else
%                                 CaptionLineHeight=RowHeightPerLine*length(J3);
                            end
                            eActivesheetRange.Value=msg;

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            eActivesheetRange.Value=' ';
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.Note2);
                            eActivesheetRange.Value=['주) ','`','피복','`','은 작업자가 착용중인 작업복 또는 장갑 등을 의미함']; 


                        case 7  % 7: 모바일, 협동로봇, EE 다 있을 때
                            % 충돌지점 번호
                            if str2num(Joint.MobileLow)~=str2num(Joint.MobileHi);
                                msg1=[Joint.MobileLow,' ~ ',Joint.MobileHi];
                            elseif Joint.MobileLow==Joint.MobileHi
                                msg1=[Joint.MobileLow];
                            else
                            end
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx1);
                            eActivesheetRange.Value=msg1;

                            if str2num(Joint.CobotLow)~=str2num(Joint.CobotHi)
                                msg2=[Joint.CobotLow,' ~ ',Joint.CobotHi];
                            elseif str2num(Joint.CobotLow)==str2num(Joint.CobotHi)
                                msg2=[Joint.CobotLow];
                            else
                            end
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx2);
                            eActivesheetRange.Value=msg2;  

                            if str2num(Joint.EELow)~=str2num(Joint.EEHi)
                                 msg3=[Joint.EELow,' ~ ',Joint.EEHi];
                            elseif str2num(Joint.EELow)==str2num(Joint.EEHi)
                                 msg3=[Joint.EELow];
                            else
                            end
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ListOfIdx3);
                            eActivesheetRange.Value=msg3;

                            % 충돌대상
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType1);
                            eActivesheetRange.Value='모바일로봇'; 

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType2);
                            eActivesheetRange.Value='협동로봇';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.RobotType3);
                            eActivesheetRange.Value='끝단';

                            % 형상정보
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo1);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo2);
                            eActivesheetRange.Value='평가로봇의 형상 적용';

                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ShapeInfo3);
                            msg='';
                            idx=0;
                            if isempty(J3)~=1
                                for i=1:length(J3)
                                    if J3(i)~=0
                                        idx=idx+1;
                                        TotalFillet=SimCondIdx(J3(i),8);

                                        if strcmpi(ColliBody,'SkullandForehead')

                                        elseif strcmpi(ColliBody,'Chest')
%                                             ClothFillet=ColliBodyCloth;

                                        elseif strcmpi(ColliBody,'Upperarm')

                                        elseif strcmpi(ColliBody,'HandandFinger')
%                                             ClothFillet=ColliBodyCloth;

                                        end
                                        
                                        CoverFillet=SimCondIdx(J3(i),9);
                                        OwnFillet=SimCondIdx(J3(i),8);

                                        CoverFillet=SimCondIdx(J3(i),9);
                                        if TotalFillet==CoverFillet
%                                             OwnFillet=0;
%                                             ClothFillet=0;
                                        else
%                                             OwnFillet=TotalFillet-(ClothFillet+CoverFillet);
                                        end

                                        %default msg
                                        if SimCondIdx(J3(i),8)~=0
                                             msgFormat=1;
                                        switch msgFormat
                                            case 0
                                                msg=[msg,num2str(idx),') ',num2str(J3(i)),'번 지점 필렛 ',num2str(SimCondIdx(J3(i),8)),' mm 적용'];
                                                msg=[msg,char(13),char(10)];

                                                %Additional msg
                                                if CoverFillet==0
                                                    if OwnFillet==0 % -> Cover : 0, Own : 0, Add~=0
                                                        msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover : 0, Own ~=0, Add~=0
                                                        msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), 'mm, 피복 : ',num2str(ClothFillet),' mm 적용)'];
                                                        msg=[msg,char(13),char(10)];                            
                                                    end

                                                else % Cover~=0
                                                    if OwnFillet==0 % -> Cover ~=0 0, Own : 0, Add~=0
                                                        msg=[msg,'  (피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용) '];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover ~=0, Own ~=0, Add~=0
                                                        msg=[msg,'  (자체필렛 : ',num2str(OwnFillet), ' mm, 피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용)'];
                                                        msg=[msg,char(13),char(10)];
                                                    end
                                                end
                                                
                                            case 1
                                                
                                                RowHeightTotal=435;
                                                RowHeightPerLine=17;
                                                RowHeightAverage=30;
                                                RowEndLine=25;
                                                RowMargin=10;
                                                msg=[msg,num2str(idx),') ',num2str(J3(i)),'번 : '];
                                                
                                                %Additional msg
                                                if CoverFillet==0
                                                    if OwnFillet==0 % -> Cover : 0, Own : 0, Add~=0
                                                        msg=[msg,'피복 : ',num2str(ClothFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover : 0, Own ~=0, Add~=0
                                                        msg=[msg,'자체필렛 : ',num2str(OwnFillet), ', 피복 : ',num2str(ClothFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];                            
                                                    end

                                                else % Cover~=0
                                                    if OwnFillet==0 % -> Cover ~=0 0, Own : 0, Add~=0
                                                        msg=[msg,'피복 : ',num2str(ClothFillet),', 커버 : ',num2str(CoverFillet),' mm 적용 '];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover ~=0, Own ~=0, Add~=0
                                                        msg=[msg,'자체필렛 : ',num2str(OwnFillet), ', 피복 : ',num2str(ClothFillet),', 커버 : ',num2str(CoverFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];
                                                    end
                                                end
                                                
                                            case 2
                                                
                                            otherwise
                                                
                                        end
                                        else
                                            if SimCondIdx(J3(i),6)==1 % sphere
                                                msg=[msg,num2str(idx),') ',num2str(J3(i)),'번 : 평가 대상의 형상(sphere),'];
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                 %Additional msg
                                                if CoverFillet==0
                                                    if OwnFillet==0 % -> Cover : 0, Own : 0, Add~=0
                                                        msg=[msg,' 피복 : ',num2str(ClothFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover : 0, Own ~=0, Add~=0
                                                        msg=[msg,' 피복 : ',num2str(ClothFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];                            
                                                    end

                                                else % Cover~=0
                                                    if OwnFillet==0 % -> Cover ~=0 0, Own : 0, Add~=0
                                                        msg=[msg,' 피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];
                                                    else % -> Cover ~=0, Own ~=0, Add~=0
                                                        msg=[msg,' 피복 : ',num2str(ClothFillet),' mm, 커버 : ',num2str(CoverFillet),' mm 적용'];
                                                        msg=[msg,char(13),char(10)];
                                                    end
                                                end                                               
                                                
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                            
                                            else
                                                
                                            end
                                        end
                                    end %if j3~=0
                                end
                                
                                if size(J3)==1
                                    CaptionLineHeight=RowHeightAverage;
                                else
                                    CaptionLineHeight=RowHeightPerLine*length(J3);
                                end
                                
                                if CaptionLineHeight>(RowHeightTotal-(RowHeightAverage*2))
                                    CaptionLineHeight=(RowHeightTotal-(RowHeightAverage*2));
                                    EndLineHeight=25;
                                else
                                    EndLineHeight=RowHeightTotal-(RowHeightAverage*2+CaptionLineHeight);
                                end
                                
                                objExcel.Activesheet.Range(Cell.ListOfIdx1).RowHeight=RowHeightAverage;
                                objExcel.Activesheet.Range(Cell.ListOfIdx2).RowHeight=RowHeightAverage;
                                objExcel.Activesheet.Range(Cell.ListOfIdx3).RowHeight=CaptionLineHeight;
                                objExcel.Activesheet.Range(Cell.EndLine).RowHeight=EndLineHeight;
                                
                            end
                            if i==length(J3)
                                msg=msg(1:(length(msg)-2));
                            end
                            eActivesheetRange.Value=msg;
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.Note3);
                            eActivesheetRange.Value=['주) ','`','피복','`','은 작업자가 착용중인 작업복 또는 장갑 등을 의미함']; 

                        otherwise

                    end

                    VcaptionMsg=' ';

                    if cell2mat(isMobileRobot)=='1'
                        VcaptionMsg='모바일 로봇의 이동 전 구간에서의 모든 충돌지점 ';
                    else
                        VcaptionMsg='협동로봇 및 끝단에 포함된 모든 충돌지점 ';
                    end
                                      
                    

%                     eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.CaptionForVelocity);
%                     eActivesheetRange.Value=VcaptionMsg;

                    SimEndCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Contents1 Page Generation End : %s\n', SimEndCnt);
                    fprintf(LogfileID, '[Status] = Contents1 Page Generation Sucess');
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');
                    isRptContents1PageDone=1;
                    disp('[Status] = Contents1 Page Generate Success')

                  %% Velocity1 Page Generation 
                    isRptContents2PageDone=0;
                    fprintf(LogfileID, '============== Velocity Info Page Generation Start ===============');
                    disp('[Status] = Velocity Info Generation Start')
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');
                    
                    %Start Time Cnt
                    SimStartCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Velocity Info page Generate Start Time : %s\n', SimStartCnt);

                    %Cell Define
                    Cell.First='A6';
                    Cell.Second='A21';
                    Cell.VelocityMsgFirst='A4';
                    Cell.VelocityMsgSecond='A19';
                    
                    % Velocity1 sheet
                    SheetName='Velocity1';
                    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate; % set active sheet
                                        
                    switch VelGraphIdx

                        case 0
                            
                        case 1 % 1: 모바일 베이스만 있을 때
                            % Mobile Velocity
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgFirst);
                            eActivesheetRange.Value='  2.1 모바일 로봇에 위치한 충돌지점 속도'; 
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgSecond);
                            eActivesheetRange.Value='  - 이하여백 -';
                            
                            imInfo = imfinfo(MobileVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.First).Left;
                            top = objExcel.ActiveSheet.Range(Cell.First).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(MobileVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                            
                        case 2 % 2: 협동로봇만 있을 때
                            % Cobot Velocity
                            
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgFirst);
                            eActivesheetRange.Value='  2.1 협동로봇에 로봇에 위치한 충돌지점 속도';
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgSecond);
                            eActivesheetRange.Value='  - 이하여백 -';
                            
                            imInfo = imfinfo(CobotVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.First).Left;
                            top = objExcel.ActiveSheet.Range(Cell.First).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(CobotVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                          
                        case 3 % 3: EE만 있을 때
                            % EE Velocity
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgFirst);
                            eActivesheetRange.Value='  2.1 끝단부에 위치한 충돌지점 속도'; 
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgSecond);
                            eActivesheetRange.Value='  - 이하여백 -';
                            
                            
                            imInfo = imfinfo(EEVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.First).Left;
                            top = objExcel.ActiveSheet.Range(Cell.First).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(CobotVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                           
                        case 4 % 4: 모바일, 협동로봇만 있을 때
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgFirst);
                            eActivesheetRange.Value='  2.1 모바일 로봇에 위치한 충돌지점 속도'; 
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgSecond);
                            eActivesheetRange.Value='  2.2 협동로봇에 위치한 충돌지점 속도'; 
                            
                            % Mobile Velocity
                            imInfo = imfinfo(MobileVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.First).Left;
                            top = objExcel.ActiveSheet.Range(Cell.First).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(MobileVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                            
                            % Cobot Velocity
                            imInfo = imfinfo(CobotVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.Second).Left;
                            top = objExcel.ActiveSheet.Range(Cell.Second).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(CobotVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                       
                        case 5 % 5: 모바일과 EE만 있을 때
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgFirst);
                            eActivesheetRange.Value='  2.1 모바일 로봇에 위치한 충돌지점 속도'; 
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgSecond);
                            eActivesheetRange.Value='  2.2 끝단부에 위치한 충돌지점 속도'; 
                            
                            % Mobile Velocity
                            imInfo = imfinfo(MobileVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.First).Left;
                            top = objExcel.ActiveSheet.Range(Cell.First).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(MobileVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                            
                            % EE Velocity
                            imInfo = imfinfo(EEVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.Second).Left;
                            top = objExcel.ActiveSheet.Range(Cell.Second).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(EEVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                      
                        case 6  % 6: 협동로봇과 EE만 있을 때
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgFirst);
                            eActivesheetRange.Value='  2.1 협동로봇에 위치한 충돌지점 속도'; 
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgSecond);
                            eActivesheetRange.Value='  2.2 끝단부에 위치한 충돌지점 속도'; 
                            
                            % Cobot Velocity
                            imInfo = imfinfo(CobotVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.First).Left;
                            top = objExcel.ActiveSheet.Range(Cell.First).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(CobotVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                            
                            % EE Velocity
                            imInfo = imfinfo(EEVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.Second).Left;
                            top = objExcel.ActiveSheet.Range(Cell.Second).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(EEVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                      
                        case 7  % 7: 모바일, 협동로봇, EE 다 있을 때
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgFirst);
                            eActivesheetRange.Value='  2.1 전체 충돌지점 속도'; 
                            eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.VelocityMsgSecond);
                            eActivesheetRange.Value='  2.2 끝단부에 위치한 충돌지점 속도'; 
                            
                            % All Velocity
                            imInfo = imfinfo(VelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.First).Left;
                            top = objExcel.ActiveSheet.Range(Cell.First).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(VelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                            
                            % EE Velocity
                            imInfo = imfinfo(EEVelocityImg);

                            ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                            ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                            CellRealHeight=300*ExcelHeightCoeff;
                            CellRealWidth=85*ExcelWidthCoeff;

                            imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                            imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                            LinkToFile = 0;
                            SaveWithDocument = 1;
                            left = objExcel.ActiveSheet.Range(Cell.Second).Left;
                            top = objExcel.ActiveSheet.Range(Cell.Second).Top;
                            objExcel.ActiveSheet.Shapes.AddPicture(EEVelocityImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
                      
                        otherwise

                    end                    
                  %% Contents2 Page Generation
                    isRptContents2PageDone=0;
                    fprintf(LogfileID, '============== Contents2 Generation Start ===============');
                    disp('[Status] = Contents2 Generation Start')
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');

                    %Start Time Cnt
                    SimStartCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Contents2 page Generate Start Time : %s\n', SimStartCnt);

                    %Cell Define
                    Cell.ColliBody='E4';
                    Cell.Hspace='E5';
                    Cell.CRIMsg='A8';
                    Cell.CRIImg='B10';
                    Cell.RiskSpaceImg='B21';

                    ResDataPath=[UserPath DocInfo.Riskfn];
                    org=importdata(ResDataPath);
                    header=org.colheaders;
                    NumofColliPos=sum(contains(org.colheaders,'EffectiveMass'));

                    % Contents 2 sheet
                    SheetName='Contents2';
                    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate; % set active sheet
                    
                    DocInfo.MaxCriValue=num2str(max(max(MaxModiCRI)),formatSpec);

                    % Summary Msg
                    if strcmpi(ColliBody,'SkullandForehead')
                        DocInfo.ColliBody='머리';
                        eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ColliBody);
                        eActivesheetRange.Value=DocInfo.ColliBody;

                    elseif strcmpi(ColliBody,'Chest')
                        DocInfo.ColliBody='가슴';
                        eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ColliBody);
                        eActivesheetRange.Value=DocInfo.ColliBody;

                    elseif strcmpi(ColliBody,'Upperarm')
                        DocInfo.ColliBody='상완(삼각근)';
                        eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ColliBody);
                        eActivesheetRange.Value=DocInfo.ColliBody;

                    elseif strcmpi(ColliBody,'HandandFinger')
                        DocInfo.ColliBody='손';
                        eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.ColliBody);
                        eActivesheetRange.Value=DocInfo.ColliBody;
                    end

                    if cell2mat(isMobileRobot)=='1'
                        eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.Hspace);
                        eActivesheetRange.Value='모바일로봇의 이동 전 구간';    
                    else
                        eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.Hspace);
                        eActivesheetRange.Value=['하단 그림의 검은색 박스 영역(',DocInfo.ColliBody,')'];    
                    end

                    eActivesheetRange = get(objExcel.Activesheet,'Range',Cell.CRIMsg);

                    if max(MaxModiCRI) <= 1
                        CRIres='PASS';
                        eActivesheetRange.Value=['Max. CRI : ',DocInfo.MaxCriValue, ' (',CRIres,')'];
                    else
                        CRIres='FAIL';
                        eActivesheetRange.Value=['Max. CRI : ',DocInfo.MaxCriValue, ' (',CRIres,')'];
                    end

                    % CRI Img insert
                    imInfo = imfinfo(CRIinfoImg);

                    ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                    ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                    CellRealHeight=25*11*ExcelHeightCoeff;
                    CellRealWidth=8.5*8*ExcelWidthCoeff;

                    imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                    imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                    LinkToFile = 0;
                    SaveWithDocument = 1;
                    left = objExcel.ActiveSheet.Range(Cell.CRIImg).Left;
                    top = objExcel.ActiveSheet.Range(Cell.CRIImg).Top;
                    objExcel.ActiveSheet.Shapes.AddPicture(CRIinfoImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

                    % RiskSpace Img Insert
                    imInfo = imfinfo(RiskSpaceInfoImg);

                    ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                    ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                    CellRealHeight=25*11*ExcelHeightCoeff;
                    CellRealWidth=8.5*8*ExcelWidthCoeff;

                    imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                    imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                    LinkToFile = 0;
                    SaveWithDocument = 1;
                    left = objExcel.ActiveSheet.Range(Cell.RiskSpaceImg).Left;
                    top = objExcel.ActiveSheet.Range(Cell.RiskSpaceImg).Top;
                    objExcel.ActiveSheet.Shapes.AddPicture(RiskSpaceInfoImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

                    SimEndCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Contents2 Page Generation End : %s\n', SimEndCnt);
                    fprintf(LogfileID, '[Status] = Contents2 Page Generation Sucess');
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');
                    isRptContents2PageDone=1;
                    disp('[Status] = Contents2 Page Generate Success')

                  %% Motion Page Generation
                    isRptMotionInfoPageDone=0;
                    fprintf(LogfileID, '=========== Motion Info Page Generation Start ===========');
                    disp('[Status] = Motion Info Page Generation Start')
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');

                    % Start Time Cnt
                    SimStartCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Title Page Generation Start : %s\n', SimStartCnt);

                    % Get # of Split Img File
                    FolderInfo=dir([UserPath,'\output\KHU_RiskSpace']);
                    ImgFileInfo={FolderInfo.name};
                    [m n]=size(ImgFileInfo);
                    ImgFileName=char(ImgFileInfo(3:n));

                    RowIdx=1;
                    ColIdx=1;
                    idx=0;
                    CellCol=[65,69,73,77];
                    CellRow=[5,11,17,23,29,35,40];
                    CellCaption='A2';

                    Row=length(CellRow); Column=length(CellCol);
                    [m n]=size(ImgFileName);
                    SheetNum=0;
                    TotalSheet=ceil(m/(Row*Column));
                    for i=1:m
                        idx=idx+1;
                        if rem(i,(Row*Column))~=0
                            SheetNum=fix(idx/(Row*Column))+1;
                        else
                            SheetNum=i/(Row*Column);
                        end

                        SheetIdx=['MotionInfo',num2str(SheetNum)]; % O.K
                        MotionImg=[UserPath,'\output\KHU_RiskSpace\',ImgFileName(idx,1:10)]; %O.k
                        CellNo=[char(CellCol(ColIdx)),num2str(CellRow(RowIdx))];

                        SheetName=SheetIdx;
                        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate; % set active sheet

                        imInfo = imfinfo(MotionImg);

                        ImgRealHeight = imInfo.Height*ImgHeightCoeff;
                        ImgRealWidth = imInfo.Width*ImgWidthCoeff;

                        CellRealHeight=82.5*ExcelHeightCoeff;
                        CellRealWidth=19.5*ExcelWidthCoeff;

                        imWidth = imInfo.Width*(CellRealWidth/ImgRealWidth)*CompensationCoeff;
                        imHeight = imInfo.Height*(CellRealHeight/ImgRealHeight)*CompensationCoeff;

                        LinkToFile = 0;
                        SaveWithDocument = 1;
                        left = objExcel.ActiveSheet.Range(CellNo).Left;
                        top = objExcel.ActiveSheet.Range(CellNo).Top;
                        objExcel.ActiveSheet.Shapes.AddPicture(MotionImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

                        eActivesheetRange = get(objExcel.Activesheet,'Range',CellCaption);
                        eActivesheetRange.Value=['부록 : 로봇모션정보 (',num2str(SheetNum), '/', num2str(TotalSheet),')'];   
                        
                        ColIdx=ColIdx+1;

                        if ColIdx>Column
                            ColIdx=1;
                            RowIdx=RowIdx+1;
                            if RowIdx==(Row+1)
                                RowIdx=1;
                            end
                        end
                    end

                    SimEndCnt=string(datetime('now'));
                    fprintf(LogfileID, '[Status] = Motion Info Page Generation End : %s\n', SimEndCnt);
                    fprintf(LogfileID, '[Status] = Motion Info Page Generation Sucess');
                    fprintf(LogfileID, '\r\n');
                    fprintf(LogfileID, '\r\n');

                    isRptMotionInfoPageDone=1;
                    disp('[Status] = MotionInfo Page Generate Success')

                %% footer -> Page Numbering

                    NumberOfTotalPage=5+SheetNum;

                    for i=1:NumberOfTotalPage
                        objExcel.WorkSheets.Item(i).PageSetup.CenterFooter = [num2str(i),' / ', num2str(NumberOfTotalPage)];
                    end

                    disp('[Status] = Page Numbering Success')

                %% Terminate
                    SheetName='Title';
                    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
                    objExcel.ActiveWorkbook.Save;
                    objExcel.ActiveWorkbook.Close;
                    objExcel.Quit;
                    objExcel.delete;

                    % Publish
                    objExcel = actxserver('Excel.Application');
                    h=objExcel.Workbooks.Open(excelFileName); % Open Excel file. Full path is necessary!
                    disp('[Status] = Transforming and Publishing the Report as a PDF Format')
                    if isfile(UserInfoPath)
                        filename='\충돌안전계산서(';
                        if contains(DocInfo.DocumentNo,'ST') ==1
                            filename=[filename,DocInfo.DocumentNo,'_'];
                        end
                        
                        if contains(DocInfo.CustomerInfo,'N/A') ~= 1
                            filename=[filename,DocInfo.CustomerInfo,').pdf'];
                        end

                    else
                        filename=['\PFL_Analysis_Report_test_',DocInfo.RefIdx,'.pdf']
                    end
                    h.ExportAsFixedFormat(0,[ReportFolder,filename],0,'True','False',1,NumberOfTotalPage,'False');
%                     h.ExportAsFixedFormat(0,[ReportFolder,'\PFL_Analysis_Report_',DocInfo.RefIdx,'.pdf'],0,'True','False',1,NumberOfTotalPage,'False');

                    objExcel.Quit;
                    objExcel.delete;
                    
                    if TerminateFlag==1
                        whileIdx=0;
                    end
                    
                    if BothFlag==1
                        BodyPPIdx=5;
                    end
                        

                otherwise

            end
        end
    else
        disp('[Status] = Failed to loading Robot Information');
    end
    fclose(LogfileID);
    try
%         system('taskkill /F /IM Notepad.exe');
    catch
    end
toc;
catch exception
    SimEndCnt=string(datetime('now'));
    disp('[Status] = Error Occured during the Report Generation');
    fprintf(LogfileID, '[Status] = Function name : %s\n', exception.stack.name);
    fprintf(LogfileID, '[Status] = Line : %d\n', exception.stack.line);
    fprintf(LogfileID, '[Status] = Error message: %s', exception.message);
    disp(['[Status] = Function name : ', exception.stack.name]);
    disp(['[Status] = Line : ', exception.stack.line]);
    disp(['[Status] = Error message: ', exception.message]);
    fprintf(LogfileID, '\r\n');
    fprintf(LogfileID, '\r\n');
    fclose(LogfileID);
    disp(['Failed at ',UserPath]);
    pause
    try
%         system('taskkill /F /IM Notepad.exe');
    catch
    end
end
end