function Status=AutoReport_SFD(UserPath, InputDataPath)
        
    % ---------------------------------------------- main function -------------------------------------------------------------------
    try
        ProcessID=[];
        objExcel = actxserver('Excel.Application');
        ProcessID=getExcelPid;
    
        gSeqData=[];
        gSeqData.ErrCodeTotal=[];
        gSeqData.nNextStep=1;
        gSeqData.ErrCodeTotal=[];
        gSeqData.ErrMsgTotal={};
        
        %Default Path
        gSeqData.FolderInfo.UserPath=UserPath;
        gSeqData.FolderInfo.InputDataPath=InputDataPath;
        whileidx=1;
        
        formatSpec = '%.3f';

        ClockHandler=tic;
        RetryCount=0;
        clc
        FileLoadStatus=[];
        while whileidx
            ElapsesTime=toc(ClockHandler); % scale -> sec
            RetryCount=RetryCount+1;
            if ElapsesTime>1200 % -> 1,200 sec (20 min)
                gSeqData.nNextStep=99;
                gSeqData.ErrCode=20060;
                gSeqData.ErrMsg='Time Out Error';
                gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
            elseif RetryCount>100
                gSeqData.nNextStep=99;
                gSeqData.ErrCode=20050;
                gSeqData.ErrMsg='Retry Count Error';
                gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
            end

            switch gSeqData.nNextStep
                case 1 % idle
                    gSeqData.ErrCode=20000;
                    gSeqData.nNextStep=gSeqData.nNextStep+1;

                case 2
                    % Folder Infomation load
                    gSeqData=PathInfo(gSeqData, UserPath, InputDataPath);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;

                case 3
                    if isfile(gSeqData.FolderInfo.AnalysisInfoFile)
                        SimInfo=AnalysisInfoLoad(gSeqData);
                        gSeqData.SimInfo=SimInfo;
                        gSeqData.nNextStep=gSeqData.nNextStep+1;

                    else % RobotInfo File Missing
                        gSeqData.nNextStep=99;
                        gSeqData.ErrCode=20001;
                        gSeqData.ErrMsg='RobotInfo.Json File Do not Exist';
                        gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                        gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                    end

                case 4

                    gSeqData.nNextStep=gSeqData.nNextStep+1; 

                case 5
                    FileLoadStatus=[FileLoadStatus,~isfile(gSeqData.FolderInfo.AnalysisResultFile)];
    
                    if sum(FileLoadStatus)==false
                        % % Analysis Result data load % graph generation
                        AnalysisResult=importdata(gSeqData.FolderInfo.AnalysisResultFile);
                        gSeqData.nNextStep=gSeqData.nNextStep+1;    
                    else
                        gSeqData.nNextStep=99;    
                        if FileLoadStatus(1)
                            gSeqData.ErrCode=20002;
                            gSeqData.ErrMsg='Analysis Result File (CSV File) do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                        end
                    end
        
                case 6
%                     FileLoadStatus=[FileLoadStatus,~isfile(gSeqData.FolderInfo.ColliPosEE),...
%                         ~isfile(gSeqData.FolderInfo.ColliPosRobot),...
%                         ~isfile(gSeqData.FolderInfo.RiskSpaceMovie),...
%                         ~isfile(gSeqData.FolderInfo.HspaceLastImg)];

                    FileLoadStatus=[FileLoadStatus, 0,...
                        ~isfile(gSeqData.FolderInfo.ColliPosRobot),...
                        ~isfile(gSeqData.FolderInfo.RiskSpaceMovie),...
                        ~isfile(gSeqData.FolderInfo.HspaceLastImg)];
    
                    if sum(FileLoadStatus)==false
                        % % Analysis Result data load % graph generation
                        AnalysisResult=importdata(gSeqData.FolderInfo.AnalysisResultFile);
                        gSeqData.nNextStep=gSeqData.nNextStep+1;    
                    else
                        gSeqData.nNextStep=99;
           
                        if FileLoadStatus(2)
                            gSeqData.ErrCode=20003;
                            gSeqData.ErrMsg='ColliPosEE Image File do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal, gSeqData.ErrMsg];
                        end
        
                        if FileLoadStatus(3)
                            gSeqData.ErrCode=20004;
                            gSeqData.ErrMsg='ColliPosRobot Image File do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                        end
    
                        if FileLoadStatus(4)
                            gSeqData.ErrCode=20005;
                            gSeqData.ErrMsg='Riskspace Analysis Movie Clip do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                        end  
    
                        if FileLoadStatus(5)
                            gSeqData.ErrCode=20006;
                            gSeqData.ErrMsg='RiskSpace Snap Shot Image do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                        end

                    end
                    
                case 7
                    [ColliPosInfoR, ColliPosInfoEE]=ColliPosAnalysis(SimInfo, AnalysisResult);
                    gSeqData=BasicInfoLoad(gSeqData, SimInfo, AnalysisResult, formatSpec);
                    gSeqData.HspaceInfo=HSpaceAnalysis(SimInfo,AnalysisResult);
                    SaveVideoSplitImg(gSeqData.FolderInfo.RiskSpaceMovie,gSeqData.FolderInfo.RiskSpaceSnap);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 8
                    gSeqData=ResultGraphGeneration(AnalysisResult, SimInfo, gSeqData);                
                    gSeqData.nNextStep=gSeqData.nNextStep+1;                   
        
                case 9
                    tempStatus=[~isfile(gSeqData.FolderInfo.GraphPathInfo.fig_name1),...
                        ~isfile(gSeqData.FolderInfo.GraphPathInfo.fig_name1),...
                        ~isfile(gSeqData.FolderInfo.GraphPathInfo.fig_name1)];
    
                    FileLoadStatus=[FileLoadStatus,tempStatus];
    
                    if sum(FileLoadStatus)==false
                        gSeqData.nNextStep=gSeqData.nNextStep+1;
                    else
                        gSeqData.nNextStep=99;
    
                        if FileLoadStatus(6)
                            gSeqData.ErrCode=20007;
                            gSeqData.ErrMsg='Result Graph (Robot Link Speed) do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                        end
    
                        if FileLoadStatus(7)
                            gSeqData.ErrCode=20008;
                            gSeqData.ErrMsg='Result Graph (ColliPos Speed) do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                        end
    
                        if FileLoadStatus(8)
                            gSeqData.ErrCode=20009;
                            gSeqData.ErrMsg='Result Graph (CRI) do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                        end
                    end
        
                case 10
                    if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
                        ReportFormat=gSeqData.FolderInfo.ReportOriginKR;
                    elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
                        ReportFormat=gSeqData.FolderInfo.ReportOriginEN;
                    end
                    
                    if isfile(ReportFormat)
%                         system('taskkill /F /IM EXCEL.EXE');
%                         system('taskkill /F /IM Acrobat.exe');
                        clc
                        gSeqData.Count=0;
                        copyidx=1;
                        while copyidx
                            status=copyfile(ReportFormat,gSeqData.FolderInfo.Report,'f');
                            if status==true
                                copyidx=0;
                                gSeqData.nNextStep=gSeqData.nNextStep+1;
                            else
                                gSeqData.Count=gSeqData.Count+1;
                                if gSeqData.Count>100
                                    copyidx=0;
                                    gSeqData.ErrCode=20010;
                                    gSeqData.ErrMsg='Origin Format Load Time out Error'
                                    gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                                    gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];
                                    gSeqData.nNextStep=99;
                                end
                            end
                        end
                    else
                        FileLoadStatus(1)=~isfile(ReportFormat);
                        if FileLoadStatus(1)
                            gSeqData.nNextStep=99;
                            gSeqData.ErrCode=20011;
                            gSeqData.ErrMsg='Report Origin Format do not exist';
                            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
                            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal,gSeqData.ErrMsg];                        
                        else
                            gSeqData.nNextStep=gSeqData.nNextStep+1;
                        end
                    end               
        
                case 11
                    % Report Making
%                     objExcel = actxserver('Excel.Application');
%                     ProcessID=getExcelPid;
                    h=objExcel.Workbooks.Open(gSeqData.FolderInfo.Report); % Open Excel file. Full path is necessary!                
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 12
                    gSeqData=TitlePage(objExcel, gSeqData);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 13
                    gSeqData=SummaryPage(objExcel, gSeqData);    
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 14
                    if gSeqData.ErrCode~=20000
                        gSeqData.nNextStep=99;
                    else
                        gSeqData=ReferencePage(objExcel,SimInfo, gSeqData);
                        gSeqData.nNextStep=gSeqData.nNextStep+1;
                    end
        
                case 15
                    gSeqData=ColliPosInfoPage(objExcel, ColliPosInfoR, ColliPosInfoEE, gSeqData);

                    if (size(ColliPosInfoEE,2)==1)&(str2num(ColliPosInfoEE.ColliPosX)==0)&...
                            (str2num(ColliPosInfoEE.ColliPosY)==0)&(str2num(ColliPosInfoEE.ColliPosZ)==0)
                        SheetName='ColliPosInfoEE1';
                        objExcel.Visible = false;
                        objExcel.DisplayAlerts = false;
                        h.Sheets.Item(SheetName).Delete;
                        gSeqData.nPage.ColliPos=1;
                        gSeqData.ErrCode=20000;
                    end
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
                            
                case 16
                    gSeqData=HspaceInfoPage(objExcel, gSeqData);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 17
                    if gSeqData.ErrCode~=20000
                        gSeqData.nNextStep=99;
                    else
                        gSeqData=VelocityInfoPage(objExcel, gSeqData);
                        gSeqData.nNextStep=gSeqData.nNextStep+1;
                    end                    
        
                case 18
                    gSeqData=RiskSpaceImgPage(objExcel, gSeqData);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 19
                    gSeqData=MotionInfoPage(objExcel, gSeqData);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 20
                    gSeqData=BasicInfoPage(objExcel, SimInfo, gSeqData);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 21
                    gSeqData=MotionDetailInfoPage(objExcel, SimInfo, gSeqData);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;
        
                case 22
                    gSeqData=ColliPosDetailPage(objExcel, ColliPosInfoR, ColliPosInfoEE, gSeqData);
                    if (size(ColliPosInfoEE,2)==1)&(str2num(ColliPosInfoEE.ColliPosX)==0)&...
                            (str2num(ColliPosInfoEE.ColliPosY)==0)&(str2num(ColliPosInfoEE.ColliPosX)==0)
                        SheetName='ColliPosDetail1';
                        objExcel.Visible = false;
                        objExcel.DisplayAlerts = false;
                        h.Sheets.Item(SheetName).Delete;
                        gSeqData.nPage.ColliPosDetail=1;
                        gSeqData.ErrCode=20000;
                    end
                    gSeqData.nNextStep=gSeqData.nNextStep+1;

                case 23
                    gSeqData=HspaceDetailPage(objExcel, gSeqData);
                    gSeqData.nNextStep=gSeqData.nNextStep+1;

                case 24
                    gSeqData.nPage.Total=gSeqData.nPage.SLIP+gSeqData.nPage.Title+gSeqData.nPage.Summary+...
                        gSeqData.nPage.Reference+gSeqData.nPage.ColliPos+gSeqData.nPage.Hspace+gSeqData.nPage.Velocity+...
                        gSeqData.nPage.RiskSpace+gSeqData.nPage.MotionInfo+gSeqData.nPage.BasicInfo+...
                        gSeqData.nPage.MotionDetail+gSeqData.nPage.ColliPosDetail+gSeqData.nPage.HspaceDetail;

                    for idx=1:gSeqData.nPage.Total
%                         objExcel.WorkSheets.Item(idx).PageSetup.CenterFooter = [num2str(idx),' / ', num2str(gSeqData.nPage.Total)];
%                         if contains(gSeqData.BasicDocInfo.DocNumber,'TEST')
%                             objExcel.WorkSheets.Item(idx).PageSetup.CenterHeader = '본 보고서는 정식 리포트가 아닌 임시 해석 보고서이므로 결과는 참고 용도로만 활용 부탁드립니다';
%                         end
                    end

                    gSeqData.nNextStep=gSeqData.nNextStep+1;
            
                case 25
                    SheetName='Title';
                    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
                    objExcel.ActiveWorkbook.Save;

                    %PDF file Path that generated by Excel Type Report ->
                    %23.06.15 PDF 이름 수정
                    ReportFileName=['(',gSeqData.BasicDocInfo.DocNumber,')ColliSion_Analysis_Report.pdf'];
                    gSeqData.FolderInfo.ReportPDF=[gSeqData.FolderInfo.UserPath,'\output\Report\PDF\',ReportFileName];
%                     h.save;
                    h.ExportAsFixedFormat(0,gSeqData.FolderInfo.ReportPDF,0,'True','False',1,gSeqData.nPage.Total,'False');
                    objExcel.ActiveWorkbook.Close;
                    objExcel.Quit;
                    objExcel.delete;
                    clc
                    system(['taskkill /F /pid ',ProcessID]);
                    clear objExcel;
                    gSeqData.nNextStep=99;
    
                case 99
                    whileidx=0;
                    clc

                otherwise
        
            end
        end

        Status=gSeqData.ErrCode;
        ProcessID

        fid=fopen([gSeqData.FolderInfo.UserPath,'\output\ReportErrCode.txt'],"w");
        ErrCnt=length(gSeqData.ErrCodeTotal);
        if ErrCnt~=0
            for idx=1:ErrCnt
                disp(['ERR :: ' ,char(gSeqData.ErrMsgTotal(idx)), '(CODE : ', num2str(gSeqData.ErrCodeTotal(idx)), ')']);
                fprintf(fid, ['ERR :: ' ,char(gSeqData.ErrMsgTotal(idx)), '(CODE : ', num2str(gSeqData.ErrCodeTotal(idx)), ')']);
                fprintf(fid, '\r\n');
            end
        else
            fprintf(fid, 'Report Generated successfully!!');
            fprintf(fid, '\r\n');
            fprintf(fid, ['ProcessID :: ' , ProcessID]);
        end
        fclose(fid);


    catch exception
        clc
        system(['taskkill /F /pid ',ProcessID]);
        fid=fopen([gSeqData.FolderInfo.UserPath,'\output\ReportErrCode.txt'],"w");
        
        gSeqData.ErrCode=20100;
        gSeqData.ErrMsg='Unknown Error (Mainly caused by FIFO of Excel File)';
        gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
        gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal, gSeqData.ErrMsg];
        
        for idx=1:length(gSeqData.ErrCodeTotal)
            if gSeqData.ErrCodeTotal(idx)==20000

            else
                fprintf(fid, ['ERR :: ' ,char(gSeqData.ErrMsgTotal(idx)), '(CODE : ', num2str(gSeqData.ErrCodeTotal(idx)), ')']);
                fprintf(fid, '\r\n');
                disp(['ERR :: ' ,char(gSeqData.ErrMsgTotal(idx)), '(CODE : ', num2str(gSeqData.ErrCodeTotal(idx)), ')']);
            end
        end

        fprintf(fid,'------------------- Detail Error Message : ------------------- ');
        fprintf(fid, '\r\n');

        [m n]=size(exception.stack);
        
        for i=1:m
            fprintf(fid,['[Status] = Function name : ', exception.stack(i).name]);
            fprintf(fid, '\r\n');
            fprintf(fid,['[Status] = Line : ', num2str(exception.stack(i).line)]);
            fprintf(fid, '\r\n');

            msg=exception.message;
            Idx=find(msg=='\');
            for i=1:length(Idx)
                msg(Idx(i))=char(47);
            end
            fprintf(fid,['[Status] = Error message: ', msg]);
            fprintf(fid, '\r\n');
            fprintf(fid, '\r\n');

%             disp(['[Status] = Function name : ', exception.stack(i).name]);
%             disp(['[Status] = Line : ', num2str(exception.stack(i).line)]);
%             disp(['[Status] = Error message: ', msg]);
        end
      
        fclose(fid);
        
%         system('taskkill /F /IM EXCEL.EXE');
%         system('taskkill /F /IM Acrobat.exe');
        clc
        
        Status=gSeqData.ErrCode;
        ProcessID

    end
end
% ---------------------------------------------- sub function --------------------------------------------------------------------
%%
function gSeqData=BasicInfoLoad(gSeqData, SimInfo, AnalysisResult, formatSpec)

%     23.06.15 주석처리 
%     gSeqData.BasicDocInfo.DocNumber=SimInfo.AutoReport.DocNo;
%     gSeqData.BasicDocInfo.RobotUser=SimInfo.AutoReport.RobotUserName;
%     gSeqData.BasicDocInfo.Manufacturer=SimInfo.AutoReport.Manufacturer;
%     gSeqData.BasicDocInfo.Model=SimInfo.BasicInfo.RobotModel;
%     gSeqData.BasicDocInfo.Serial=SimInfo.BasicInfo.RobotSerialNumber;
%     gSeqData.BasicDocInfo.InstallPlace=SimInfo.AutoReport.InstallationSite;
%     gSeqData.BasicDocInfo.RequestingOrg=SimInfo.AutoReport.IssuingCompany;
%     gSeqData.BasicDocInfo.Requester=SimInfo.AutoReport.Issuer;
%     gSeqData.BasicDocInfo.Process=SimInfo.AutoReport.ProcessName;

%     Json 파일 내부 한글 깨짐 현상 방지 debug code
    gSeqData.BasicDocInfo.DocNumber=ExtractPattern(SimInfo.TextRobotInfo, 'DocNo');
    gSeqData.BasicDocInfo.RobotUser=ExtractPattern(SimInfo.TextRobotInfo, 'RobotUserName');
    gSeqData.BasicDocInfo.Manufacturer=ExtractPattern(SimInfo.TextRobotInfo, 'Manufacturer');
    gSeqData.BasicDocInfo.Model=ExtractPattern(SimInfo.TextRobotInfo, 'RobotModel');
    gSeqData.BasicDocInfo.Serial=ExtractPattern(SimInfo.TextRobotInfo, 'RobotSerialNumber');
    gSeqData.BasicDocInfo.InstallPlace=ExtractPattern(SimInfo.TextRobotInfo, 'InstallationSite');
    gSeqData.BasicDocInfo.RequestingOrg=ExtractPattern(SimInfo.TextRobotInfo, 'IssuingCompany');
    gSeqData.BasicDocInfo.Requester=ExtractPattern(SimInfo.TextRobotInfo, 'Issuer');
    gSeqData.BasicDocInfo.Process=ExtractPattern(SimInfo.TextRobotInfo, 'ProcessName');


    gSeqData.BasicDocInfo.Lang=SimInfo.AutoReport.Language;
    formatOut ='yyyy-mm-dd';
    gSeqData.BasicDocInfo.IssueDate=datestr(datetime('now'),formatOut);     
    gSeqData.BasicDocInfo.InputMotionLength=num2str(max(AnalysisResult.data(:,5)),formatSpec);
    gSeqData.BasicDocInfo.Red='000255';
    gSeqData.BasicDocInfo.Blue='16711680';
    gSeqData.nPage.SLIP=4;
    gSeqData.ErrCode=20000;
        
    % Re-scale factor
    gSeqData.Scale.ImgHeightCoeff = 3.7793;
    gSeqData.Scale.ImgWidthCoeff = 3.7967;
    gSeqData.Scale.ExcelHeightCoeff = 0.3465;
    gSeqData.Scale.ExcelWidthCoeff = 2.6867;
    gSeqData.Scale.CompensationCoeff=0.69;


end

function gSeqData=TitlePage(objExcel, gSeqData)
        
    SheetName='Title';
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;

    if exist('NumberofSheet','var')
        gSeqData.nPage.Title=NumberofSheet;
    else
        gSeqData.nPage.Title=1;
    end

    msg={gSeqData.BasicDocInfo.DocNumber, gSeqData.BasicDocInfo.IssueDate, gSeqData.BasicDocInfo.RobotUser, gSeqData.BasicDocInfo.Manufacturer,...
        [char(gSeqData.BasicDocInfo.Model),' / ', char(gSeqData.BasicDocInfo.Serial)],gSeqData.BasicDocInfo.InstallPlace};
    eActivesheetRange = get(objExcel.Activesheet,'Range','E12:E17');
    eActivesheetRange.Value=msg';

    msg={gSeqData.BasicDocInfo.RequestingOrg, gSeqData.BasicDocInfo.Requester};
    eActivesheetRange = get(objExcel.Activesheet,'Range','E20:E21');
    eActivesheetRange.Value=msg';
        
    % Process Name
    eActivesheetRange = get(objExcel.Activesheet,'Range','C26');
    eActivesheetRange.Value=gSeqData.BasicDocInfo.Process;
       
    % Analysis Result
    for idx=1:size(gSeqData.HspaceInfo,2)
        tempRes(idx)=str2num(gSeqData.HspaceInfo(idx).CRI);
    end

    eActivesheetRange = get(objExcel.Activesheet,'Range','C27');
    
    if ~isempty(find(tempRes>1))
        eActivesheetRange.Value=['FAIL (Max. CRI: ',num2str(max(tempRes)),')'];
        eActivesheetRange.font.Color=gSeqData.BasicDocInfo.Red;
    else
        eActivesheetRange.Value=['PASS (Max. CRI: ',num2str(max(tempRes)),')'];
        eActivesheetRange.font.Color='000000';
    end
    
    prefix=[65:90];
    for idx=1:size(gSeqData.HspaceInfo,2)
        cellidx=[char(prefix(idx)),num2str(29),':',char(prefix(idx)),num2str(30)];
        eActivesheetRange = get(objExcel.Activesheet,'Range',cellidx);
        msg={gSeqData.HspaceInfo(idx).ColliBody,gSeqData.HspaceInfo(idx).CRI};
        eActivesheetRange.Value=msg';
        
        if str2num(gSeqData.HspaceInfo(idx).CRI)>1
            eActivesheetRange.font.Color=gSeqData.BasicDocInfo.Red;
        else
            eActivesheetRange.font.Color='000000';
        end
        
    end
    gSeqData.ErrCode=20000;
end

%%
function gSeqData=SummaryPage(objExcel, gSeqData)
    DataPerpage=6;
    NumberofSheet=ceil(size(gSeqData.HspaceInfo,2)/DataPerpage);
    
    if exist('NumberofSheet','var')
        gSeqData.nPage.Summary=NumberofSheet;
    else
        gSeqData.nPage.Summary=1;
    end  
        
    for idx=1:NumberofSheet-1
        OldSheet=['Summary',num2str(idx)];
        objExcel.ActiveWorkbook.Worksheets.Item(OldSheet).Activate;
        TempObj=objExcel.Activesheet;
        invoke(TempObj,'Copy',[],TempObj);
        objExcel.Activesheet.Name=['Summary',num2str(idx+1)];
    end
        
    for idx=1:size(gSeqData.HspaceInfo,2)
    
        pageIdx=ceil(idx/DataPerpage);
        
        if pageIdx>1
            cellIdx=(idx-(pageIdx-1)*DataPerpage)*5;
        else
            cellIdx=idx*5;
        end
        SheetName=['Summary',num2str(pageIdx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
        
        if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
            msg={'■ 협동작업공간 번호 : ','■ 충돌신체부위 : ','■ 피복 등 기타조건 : ','■ 해당 영역 최대 CRI : '};
        elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
            msg={'■ Collaborative Workspace No. :  ','■ Collision Body Part :  ','■ Other Conditions (e.g. Cover) : ','■ Corresponding Area Max CRI : '};
        end
        eActivesheetRange = get(objExcel.Activesheet,'Range',['B',num2str(cellIdx),':','B',num2str(cellIdx+3)]);
        eActivesheetRange.Value=msg';

        if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
        elseif strcmpi(gSeqData.BasicDocInfo.Lang,'EN-us')
        end
        
        if gSeqData.HspaceInfo(idx).ColliBodyCloth==0;
            if strcmpi(gSeqData.BasicDocInfo.Lang,'Ko-kr')
                Tempmsg='해당사항없음';
            elseif strcmpi(gSeqData.BasicDocInfo.Lang,'EN-us')
                Tempmsg=[];
            end            
        else
            if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-KR')
                Tempmsg=['피복 ', num2str(gSeqData.HspaceInfo(idx).ColliBodyCloth), 'mm 적용'];
            elseif strcmpi(gSeqData.BasicDocInfo.Lang,'EN-us')
                Tempmsg=['Applied ', num2str(gSeqData.HspaceInfo(idx).ColliBodyCloth), 'mm Cover'];
            end            
        end
    
        msg={gSeqData.HspaceInfo(idx).Index, gSeqData.HspaceInfo(idx).ColliBody, Tempmsg, gSeqData.HspaceInfo(idx).CRI};
        eActivesheetRange = get(objExcel.Activesheet,'Range',['E',num2str(cellIdx),':','E',num2str(cellIdx+3)]);
        eActivesheetRange.Value=msg';
    
        eActivesheetRange = get(objExcel.Activesheet,'Range',['H',num2str(cellIdx)]);

        if gSeqData.HspaceInfo(idx).ColliBodyCloth==0;
            eActivesheetRange.Value=['협동작업공간',newline,'위치정보(',num2str(gSeqData.HspaceInfo(idx).Index),')'];
        else
            eActivesheetRange.Value=['Collaborative',newline,'Workspace',newline,'Position ',num2str(gSeqData.HspaceInfo(idx).Index)];
        end        
    
        HSPACEIMGPath=[gSeqData.FolderInfo.UserPath,'\output\HumanSpace_',num2str(idx),'.jpg'];

        if isfile(HSPACEIMGPath)            
            imInfo = imfinfo(HSPACEIMGPath);
            
            ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
            ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
                
            CellRealHeight=101*gSeqData.Scale.ExcelHeightCoeff; % mm
            CellRealWidth=15*gSeqData.Scale.ExcelWidthCoeff; % mm
        
            Hr=CellRealHeight/ImgRealHeight;
            Wr=CellRealWidth/ImgRealWidth;
        
            ReductionRatio=min(Hr,Wr);
                        
            imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
            imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
                
            CellHeightRealPoint=CellRealHeight*2.8478;
            CellWidthRealPoint=CellRealWidth*2.7681;
        
            margin=round(1.2*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
        
            topLeftCorner = ['J',num2str(cellIdx)];
                
            LinkToFile = 0;
            SaveWithDocument = 1;
            left = objExcel.ActiveSheet.Range(topLeftCorner).Left+margin(1);
            top = objExcel.ActiveSheet.Range(topLeftCorner).Top+margin(2);
            objExcel.ActiveSheet.Shapes.AddPicture(HSPACEIMGPath,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
        else
            gSeqData.ErrCode=20012;
            gSeqData.ErrMsg=['Colored HumanSpace Snapshot image(HumanSpace_',num2str(idx),'.jpg)',' do not exist'];
            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal, gSeqData.ErrMsg];
        end

        k=mod(idx,DataPerpage);
        
        if k==0
            k=DataPerpage;
        end
        
        %Step 1: Inner Horizontal line
        CellRange=['B',num2str(k*5),':E',num2str(k*5+3)];
        borders = get(objExcel.ActiveSheet.Range(CellRange), 'Borders');
        theBorder = get(borders, 'Item', 12);
        set(theBorder, 'LineStyle', 1);
        set(theBorder, 'Weight', 1);
        set(theBorder, 'ColorIndex',15);
                
        %Step 2: Outer Top line
        CellRange=['A',num2str(k*5),':P',num2str(k*5+3)];
        borders = get(objExcel.ActiveSheet.Range(CellRange), 'Borders');
        theBorder = get(borders, 'Item', 8);
        set(theBorder, 'LineStyle', 1);
        set(theBorder, 'Weight', 3);
        set(theBorder, 'ColorIndex',1);
                
        %Step 3: Outer Bottom line
        CellRange=['A',num2str(k*5),':P',num2str(k*5+3)];
        borders = get(objExcel.ActiveSheet.Range(CellRange), 'Borders');
        theBorder = get(borders, 'Item', 9);
        set(theBorder, 'LineStyle', 1);
        set(theBorder, 'Weight', 3);
        set(theBorder, 'ColorIndex',1);

        eActivesheetRange = get(objExcel.Activesheet,'Range',['B5',num2str(cellIdx),':','E',num2str(cellIdx+3)]);
        eActivesheetRange.font.Color='000000';

        if str2num(gSeqData.HspaceInfo(idx).CRI)>1
%             eActivesheetRange = get(objExcel.Activesheet,'Range',['B',num2str(cellIdx),':','E',num2str(cellIdx+3)]);
            eActivesheetRange = get(objExcel.Activesheet,'Range',['E',num2str(cellIdx),':','E',num2str(cellIdx+3)]);
            eActivesheetRange.font.Color=gSeqData.BasicDocInfo.Red;
        end
    end
end

%%
function gSeqData=ReferencePage(objExcel, SimInfo, gSeqData)
    SheetName='Reference';
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;

    KOROS=[410,410,2.9,2.9;250,500,1.8,3.6;...
        310,620,3.9,7.8;510,1020,3.7,7.4;...
        320,740,3.6,7.2;260,520,2.7,5.4];
    ISO=[130,130,1.3,1.3;140,280,1.2,2.4;...
        150,300,1.9,3.8;140,280,3,6;...
        160,320,1.9,3.8;220,440,2.5,5];

    if strcmpi(SimInfo.AutoReport.Standard,'KHU')
        eActivesheetRange = get(objExcel.Activesheet,'Range','E7:H12');
        eActivesheetRange.Value=KOROS;
        eActivesheetRange = get(objExcel.Activesheet,'Range','C4');
        eActivesheetRange.Value='KOROS 1162-1:2021';
    elseif strcmpi(SimInfo.AutoReport.Standard,'ISO')
        eActivesheetRange = get(objExcel.Activesheet,'Range','E7:H12');
        eActivesheetRange.Value=ISO;
        eActivesheetRange = get(objExcel.Activesheet,'Range','C4');
        eActivesheetRange.Value='ISO/TS EN 15066:2016 (En)';
    end
    
    eActivesheetRange = get(objExcel.Activesheet,'Range','A13');
    if strcmpi(SimInfo.AutoReport.Standard,'KHU')
        if strcmpi(SimInfo.AutoReport.Language,'ko-kr')
            eActivesheetRange.Value='* KOROS 1162-1:2021의 표 2에 기재된 접촉 신체영역을 의미';
        elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
            eActivesheetRange.Value='* indicates the body parts listed in Table 2 of KOROS 1162-1:2021';
        end
    elseif strcmpi(SimInfo.AutoReport.Standard,'ISO')
        if strcmpi(SimInfo.AutoReport.Language,'ko-kr')
            eActivesheetRange.Value='* ISO/TS 15066:2016(En) Annex.A의 표 A.2에 기재된 접촉 신체영역을 의미';
        elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
            eActivesheetRange.Value='* indicates the body parts listed in Table A.2 of ISO/TS 15066:2016(En) Annex.A'; 
        end
    end

    if exist('NumberofSheet','var')
        gSeqData.nPage.Reference=NumberofSheet;
    else
        gSeqData.nPage.Reference=1;
    end  

    for idx=1:size(gSeqData.HspaceInfo,2)
        ColliBodyTemp=SimInfo.RiskSpaceInfo(idx).ColliBody;

        if strcmpi(char(ColliBodyTemp),'SkullandForehead')
            RefActivateCell='I7';
            PropertiesActivateCell='I18';
            ColorRange='C7:I7';
            ColorRange2='C18:I18';
        elseif strcmpi(char(ColliBodyTemp),'Chest')
            RefActivateCell='I8';
            PropertiesActivateCell='I19';
            ColorRange='C8:I8';
            ColorRange2='C19:I19';
        elseif strcmpi(char(ColliBodyTemp),'Upperarmandelbow')
            RefActivateCell='I9';
            PropertiesActivateCell='I20';
            ColorRange='C9:I9';
            ColorRange2='C20:I20';
        elseif strcmpi(char(ColliBodyTemp),'HandandFinger')
            RefActivateCell='I10';
            PropertiesActivateCell='I21';
            ColorRange='C10:I10';
            ColorRange2='C21:I21';
        elseif strcmpi(char(ColliBodyTemp),'Lowerarmandwrist')
            RefActivateCell='I11';
            PropertiesActivateCell='I22';
            ColorRange='C11:I11';
            ColorRange2='C22:I22';
        elseif strcmpi(char(ColliBodyTemp),'thighsandknees')
            RefActivateCell='I12';
            PropertiesActivateCell='I23';
            ColorRange='C12:I12';
            ColorRange2='C23:I23';
        end

        % Check the Note section
        eActivesheetRange = get(objExcel.Activesheet,'Range',PropertiesActivateCell);
        eActivesheetRange.Value='V';

        % Check the Note section
        eActivesheetRange = get(objExcel.Activesheet,'Range',RefActivateCell);
        eActivesheetRange.Value='V';

        % FontColor
        eActivesheetRange = get(objExcel.Activesheet,'Range',ColorRange);
        eActivesheetRange.font.Color='000000';
        eActivesheetRange = get(objExcel.Activesheet,'Range',ColorRange2);   
        eActivesheetRange.font.Color='000000';
    end
    gSeqData.ErrCode=20000;
end

%%
function gSeqData=ColliPosInfoPage(objExcel, ColliPosInfoR, ColliPosInfoEE, gSeqData)
   
    Cell.ColliPosImgOnRobot = 'A5';
    SheetName='ColliPosInfoR1';
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
    eActivesheetRange = get(objExcel.Activesheet,'Range','A3');

    if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
        eActivesheetRange.Value=['■ RobotLink에 설정한 충돌 예상 부위 형상 정보'];
    elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
        eActivesheetRange.Value=['■ Configuration Details for Expected Collision Points of RobotLink'];
    end

    % Colli. Pos. on robot
    ColliPosImgOnRobot=ReportImgResize(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.ColliPosRobot);
    imInfo = imfinfo(ColliPosImgOnRobot);
       
    ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
    ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
        
    CellRealHeight=108.1;
    CellRealWidth=191.3;

    Hr=CellRealHeight/ImgRealHeight;
    Wr=CellRealWidth/ImgRealWidth;

    ReductionRatio=min(Hr,Wr);
                
    imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
    imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
        
    CellHeightRealPoint=CellRealHeight*2.8478;
    CellWidthRealPoint=CellRealWidth*2.7681;

    margin=round(1.2*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
       
    LinkToFile = 0;
    SaveWithDocument = 1;
    left = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnRobot).Left+margin(1);
    top = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnRobot).Top+margin(2);
    objExcel.ActiveSheet.Shapes.AddPicture(ColliPosImgOnRobot,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

    for idx=1:size(ColliPosInfoR,2)
        pageIdx=1;
        SheetName=['ColliPosInfoR',num2str(pageIdx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
    
        cellIdx=mod(idx,10)+14;
        if cellIdx==14
            cellIdx=24;
        end        
        
        msg={num2str(idx),ColliPosInfoR(idx).RIndex,'RobotLink',ColliPosInfoR(idx).CoverInfo};

        eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(cellIdx),':','D',num2str(cellIdx)]);
        eActivesheetRange.Value=msg;

        if ColliPosInfoR(idx).Danger>1
            eActivesheetRange.font.Color=gSeqData.BasicDocInfo.Red;
        end
    end

        cellidxmax=24;

    if cellIdx<cellidxmax
        borders = get(objExcel.ActiveSheet.Range(['A',num2str(cellIdx+1),':','E',num2str(cellidxmax)]), 'Borders');
        theBorder = get(borders, 'Item', 9);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 11);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 12);
        set(theBorder, 'LineStyle', 0);
    end

    %-----------------------------------------------------------------------%
    %-----------------------------------------------------------------------%

    DataPerpage=10;
    NumberofSheet=ceil(size(ColliPosInfoEE,2)/DataPerpage);
        
    if exist('NumberofSheet','var')
        gSeqData.nPage.ColliPos=NumberofSheet+1;
    else
        gSeqData.nPage.ColliPos=2;
    end 
        
    Cell.ColliPosImgOnEE = 'A5';
    
    for idx=1:NumberofSheet
        if idx~=1
            OldSheet=['ColliPosInfoEE',num2str(idx-1)];
            objExcel.ActiveWorkbook.Worksheets.Item(OldSheet).Activate;
            TempObj=objExcel.Activesheet;
            invoke(TempObj,'Copy',[],TempObj);
            objExcel.Activesheet.Name=['ColliPosInfoEE',num2str(idx)];
        end
    
        SheetName=['ColliPosInfoEE',num2str(idx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
        eActivesheetRange = get(objExcel.Activesheet,'Range','A3');

        if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
            eActivesheetRange.Value=['■ End-Effector에 설정한 충돌 예상 부위 형상 정보 (',num2str(idx),' / ',num2str(NumberofSheet),')'];
        elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
            eActivesheetRange.Value=['■ Configuration Details for Expected Collision Points of End-effector (',num2str(idx),' / ',num2str(NumberofSheet),')'];
        end
            
    end
    
    for idx=1:NumberofSheet
        SheetName=['ColliPosInfoEE',num2str(idx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
    
        % Colli. Pos. on EE
        tempImg=[gSeqData.FolderInfo.ColliPosEE_detail,num2str(idx),'.jpg'];
        if isfile(tempImg)
            ColliPosImgOnEE=ReportImgResize(gSeqData.FolderInfo.UserPath, tempImg);
        else
            ColliPosImgOnEE=ReportImgResize(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.ColliPosEE);
        end
        
        imInfo = imfinfo(ColliPosImgOnEE);
    
        ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
        ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
            
        CellRealHeight=108.1;
        CellRealWidth=191.3;
    
        Hr=CellRealHeight/ImgRealHeight;
        Wr=CellRealWidth/ImgRealWidth;
    
        ReductionRatio=min(Hr,Wr);
                    
        imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
        imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
            
        CellHeightRealPoint=CellRealHeight*2.8478;
        CellWidthRealPoint=CellRealWidth*2.7681;
    
        margin=round([1.6*(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);   
           
        LinkToFile = 0;
        SaveWithDocument = 1;
        left = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnEE).Left+margin(1);
        top = objExcel.ActiveSheet.Range(Cell.ColliPosImgOnEE).Top+margin(2);
        objExcel.ActiveSheet.Shapes.AddPicture(ColliPosImgOnEE,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
    end
    
    for idx=1:size(ColliPosInfoEE,2)
        pageIdx=ceil(idx/DataPerpage);
        SheetName=['ColliPosInfoEE',num2str(pageIdx)];
        
        cellIdx=mod(idx,10)+14;
        if cellIdx==14
            cellIdx=24;
        end
    
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
            
        if str2num(ColliPosInfoEE(idx).ColliRadi)==0
            ColliPosInfoEE(idx).ColliRadi='-';
        end
            
        if str2num(ColliPosInfoEE(idx).ColliFillet)==0
            ColliPosInfoEE(idx).ColliFillet='-';
        end
            
        msg={num2str(idx),ColliPosInfoEE(idx).EEIndex,'End-Effector',ColliPosInfoEE(idx).ColliShape,...
                ColliPosInfoEE(idx).ColliRadi,ColliPosInfoEE(idx).ColliFillet,ColliPosInfoEE(idx).CoverInfo};
    
        eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(cellIdx),':','G',num2str(cellIdx)]);
        eActivesheetRange.Value=msg;
        if ColliPosInfoEE(idx).Danger>1
            eActivesheetRange.font.Color=gSeqData.BasicDocInfo.Red;
        end
    end
    
    cellidxmax=24;
    
    if cellIdx<cellidxmax
        borders = get(objExcel.ActiveSheet.Range(['A',num2str(cellIdx+1),':','G',num2str(cellidxmax)]), 'Borders');
        theBorder = get(borders, 'Item', 9);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 11);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 12);
        set(theBorder, 'LineStyle', 0);
    end

%     if (size(ColliPosInfoEE,2)==1)&(str2num(ColliPosInfoEE.ColliPosX)==0)&(str2num(ColliPosInfoEE.ColliPosY)==0)&...
%             (str2num(ColliPosInfoEE.ColliPosX)==0)
%         SheetName='ColliPosInfoEE1';
%         objExcel.Visible = true;
%         objExcel.DisplayAlerts = false;
%         h.Sheets.Item(SheetName).Delete;
%         gSeqData.nPage.ColliPos=1;
%         gSeqData.ErrCode=20000;
%     end

    gSeqData.ErrCode=20000;


end

%%
function gSeqData=HspaceInfoPage(objExcel, gSeqData)
    DataPerpage=10;
    NumberofSheet=ceil(size(gSeqData.HspaceInfo,2)/DataPerpage);
    gSeqData.ErrCode=20000;

    if exist('NumberofSheet','var')
        gSeqData.nPage.Hspace=NumberofSheet;
    else
        gSeqData.nPage.Hspace=1;
    end    

    for idx=1:size(gSeqData.HspaceInfo,2)
        pageIdx=ceil(idx/DataPerpage);
        SheetName=['HspaceInfo',num2str(pageIdx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;

        cellIdx=idx+28;

        if strcmpi(gSeqData.SimInfo.AutoReport.Language,'ko-kr')
            if gSeqData.HspaceInfo(idx).ColliBodyCloth==0;
                Tempmsg='해당사항없음';
            else
                Tempmsg=['피복 ', num2str(gSeqData.HspaceInfo(idx).ColliBodyCloth), 'mm 적용'];
            end
        elseif strcmpi(gSeqData.SimInfo.AutoReport.Language,'en-us')
            if gSeqData.HspaceInfo(idx).ColliBodyCloth==0;
                Tempmsg=' ';
            else
                Tempmsg=['Applied ', num2str(gSeqData.HspaceInfo(idx).ColliBodyCloth), 'mm Cover'];
            end
        end
        
        msg={num2str(idx), gSeqData.HspaceInfo(idx).ColliBody, gSeqData.HspaceInfo(idx).Status,...
            gSeqData.HspaceInfo(idx).BackMotionX, gSeqData.HspaceInfo(idx).BackMotionY, Tempmsg};
        eActivesheetRange = get(objExcel.Activesheet,'Range',['B',num2str(cellIdx),':','G',num2str(cellIdx)]);
        eActivesheetRange.Value=msg;
        eActivesheetRange.font.Color='000000';

        Cell.HSPACESETIMG='B5';

        if isfile(gSeqData.FolderInfo.LayOut)
	        HSPACESETIMGPATH=ReportImgResize(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.LayOut);
	        imInfo = imfinfo(HSPACESETIMGPATH);
            ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
            ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
            
            CellRealHeight=111.5;
            CellRealWidth=184.5;
    
            Hr=CellRealHeight/ImgRealHeight;
            Wr=CellRealWidth/ImgRealWidth;
    
            ReductionRatio=min(Hr,Wr);
                    
            imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
            imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
            
            CellHeightRealPoint=CellRealHeight*2.8478;
            CellWidthRealPoint=CellRealWidth*2.7681;
    
            margin=round(1.2*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
        
	        LinkToFile = 0;
	        SaveWithDocument = 1;
	        left = objExcel.ActiveSheet.Range(Cell.HSPACESETIMG).Left+margin(1);
	        top = objExcel.ActiveSheet.Range(Cell.HSPACESETIMG).Top+margin(2);
	        objExcel.ActiveSheet.Shapes.AddPicture(HSPACESETIMGPATH,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
        else
            gSeqData.ErrCode=20013;
            gSeqData.ErrMsg='HumanSpace Snapshot image(Full Scale) do not exist';
            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal, gSeqData.ErrMsg];
        end

    end

    cellidxmax=38;

    if cellIdx<cellidxmax
	    borders = get(objExcel.ActiveSheet.Range(['B',num2str(cellIdx+1),':','G',num2str(cellidxmax)]), 'Borders');
	    theBorder = get(borders, 'Item', 9);
	    set(theBorder, 'LineStyle', 0);
	    theBorder = get(borders, 'Item', 11);
	    set(theBorder, 'LineStyle', 0);
	    theBorder = get(borders, 'Item', 12);
	    set(theBorder, 'LineStyle', 0);

        eActivesheetRange = get(objExcel.Activesheet,'Range',['B',num2str(cellIdx+1),':','G',num2str(cellidxmax)]);
        eActivesheetRange.Value="";
    end
end
%%
function gSeqData=VelocityInfoPage(objExcel, gSeqData)
    SheetName='VelocityInfo';
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate; % set active sheet

    if exist('NumberofSheet','var')
        gSeqData.nPage.Velocity=NumberofSheet;
    else
        gSeqData.nPage.Velocity=1;
    end

    Cell.First='A6';
    Cell.Second='A21';

    % Cobot Velocity
    G1=gSeqData.FolderInfo.GraphPathInfo.fig_name1;
%     RobotVelocityGraph=G1;
    RobotVelocityGraph=ReportImgResize(gSeqData.FolderInfo.UserPath,G1);
    imInfo = imfinfo(RobotVelocityGraph);
    
    ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
    ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
                
    CellRealHeight=103.9;%
    CellRealWidth=191.3;%
        
    Hr=CellRealHeight/ImgRealHeight;
    Wr=CellRealWidth/ImgRealWidth;
        
    ReductionRatio=min(Hr,Wr);
                        
    imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
    imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
                
    CellHeightRealPoint=CellRealHeight*2.8478;
    CellWidthRealPoint=CellRealWidth*2.7681;
        
    margin=round(1.2*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
    
    LinkToFile = 0;
    SaveWithDocument = 1;
    left = objExcel.ActiveSheet.Range(Cell.First).Left+margin(1);
    top = objExcel.ActiveSheet.Range(Cell.First).Top+margin(2);
    objExcel.ActiveSheet.Shapes.AddPicture(RobotVelocityGraph,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

    % EE Velocity
    G2=gSeqData.FolderInfo.GraphPathInfo.fig_name2;
%     EEvelocityGraph=G2;
    EEvelocityGraph=ReportImgResize(gSeqData.FolderInfo.UserPath,G2);
    imInfo = imfinfo(EEvelocityGraph);
    
    ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
    ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
                
    CellRealHeight=103.9;
    CellRealWidth=191.3;
        
    Hr=CellRealHeight/ImgRealHeight;
    Wr=CellRealWidth/ImgRealWidth;
        
    ReductionRatio=min(Hr,Wr);
                        
    imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
    imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
                
    CellHeightRealPoint=CellRealHeight*2.8478;
    CellWidthRealPoint=CellRealWidth*2.7681;
        
    margin=round(1.5*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
    
    LinkToFile = 0;
    SaveWithDocument = 1;
    left = objExcel.ActiveSheet.Range(Cell.Second).Left+margin(1);
    top = objExcel.ActiveSheet.Range(Cell.Second).Top+margin(2);
    objExcel.ActiveSheet.Shapes.AddPicture(EEvelocityGraph,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

    gSeqData.ErrCode=20000;
end
%%
function gSeqData=RiskSpaceImgPage(objExcel, gSeqData)
    SheetName='RiskSpaceImg';
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate; % set active sheet

    if exist('NumberofSheet','var')
        gSeqData.nPage.RiskSpace=NumberofSheet;
    else
        gSeqData.nPage.RiskSpace=1;
    end

    %Cell Define
    Cell.CRIImg='B10';
    Cell.RiskSpaceImg='B21';

    for idx=1:size(gSeqData.HspaceInfo,2)
        tempRes(idx)=str2num(gSeqData.HspaceInfo(idx).CRI);
    end

    % Summary Msg
    tempMsg=[];
    for idx=1:size(gSeqData.HspaceInfo,2)
        tempMsg=[tempMsg,char(gSeqData.HspaceInfo(idx).ColliBody)];
        if idx~=size(gSeqData.HspaceInfo,2);
            tempMsg=[tempMsg, ' '];
        end
    end
    msg=[];
    AllColliBody=unique(split(tempMsg," "));
    for idx=1:size(AllColliBody,1)
        msg=[msg,char(AllColliBody(idx)),' '];
        if idx~=size(AllColliBody,1)
            msg=[msg,', '];
        end
    end    

    eActivesheetRange = get(objExcel.Activesheet,'Range','E4');
    eActivesheetRange.Value= msg;

    eActivesheetRange = get(objExcel.Activesheet,'Range','E5');

    if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
        eActivesheetRange.Value=['하단 그림의 검은색 박스 영역'];
    elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
        eActivesheetRange.Value=['The Indicated area (Black Box) in the bottom figure'];
    end

    for idx=1:size(gSeqData.HspaceInfo,2)
        tempRes(idx)=str2num(gSeqData.HspaceInfo(idx).CRI);
    end
    
    eActivesheetRange = get(objExcel.Activesheet,'Range','B9');
    if ~isempty(find(tempRes>1))
        msg=['FAIL (Max. CRI: ',num2str(max(tempRes)),')'];
        eActivesheetRange.font.Color=gSeqData.BasicDocInfo.Red; 
    else
        msg=['PASS (Max. CRI: ',num2str(max(tempRes)),')'];
    end    
    eActivesheetRange.Value=msg;
    
    % CRI Img insert
    CRIImg=ReportImgResize(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.GraphPathInfo.fig_name3);
    imInfo = imfinfo(CRIImg);
    
    ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
    ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
                
    CellRealHeight=95.6;
    CellRealWidth=173.5;
        
    Hr=CellRealHeight/ImgRealHeight;
    Wr=CellRealWidth/ImgRealWidth;
        
    ReductionRatio=min(Hr,Wr);
                        
    imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
    imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
                
    CellHeightRealPoint=CellRealHeight*2.8478;
    CellWidthRealPoint=CellRealWidth*2.7681;
        
    margin=round(1.2*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
    
    LinkToFile = 0;
    SaveWithDocument = 1;
    left = objExcel.ActiveSheet.Range(Cell.CRIImg).Left+margin(1);
    top = objExcel.ActiveSheet.Range(Cell.CRIImg).Top+margin(2);
    objExcel.ActiveSheet.Shapes.AddPicture(CRIImg,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
    
    % RiskSpace Img Insert
    RiskSpaceLastScene=ReportImgResize(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.HspaceLastImg);
    imInfo = imfinfo(RiskSpaceLastScene);
    
    ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
    ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
                
    CellRealHeight=94.9;
    CellRealWidth=154.2;
        
    Hr=CellRealHeight/ImgRealHeight;
    Wr=CellRealWidth/ImgRealWidth;
        
    ReductionRatio=min(Hr,Wr);
                        
    imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
    imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
                
    CellHeightRealPoint=CellRealHeight*2.8478;
    CellWidthRealPoint=CellRealWidth*2.7681;
        
    margin=round(1.2*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
    
    LinkToFile = 0;
    SaveWithDocument = 1;
    left = objExcel.ActiveSheet.Range(Cell.RiskSpaceImg).Left+margin(1);
    top = objExcel.ActiveSheet.Range(Cell.RiskSpaceImg).Top+margin(2);
    objExcel.ActiveSheet.Shapes.AddPicture(RiskSpaceLastScene,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);

    gSeqData.ErrCode=20000;
end
%%
function gSeqData=MotionInfoPage(objExcel, gSeqData)
    gSeqData.ErrCode=20000;

    ImFolderInfo=dir(gSeqData.FolderInfo.RiskSpaceSnap);
    ImgFileInfo={ImFolderInfo.name};
    ImgFileName=char(ImgFileInfo(3:size(ImgFileInfo,2)));

    DataPerpage=28;
    NumberofSheet=ceil(size(ImgFileName,1)/DataPerpage);

    if exist('NumberofSheet','var')
        gSeqData.nPage.MotionInfo=NumberofSheet;
    else
        gSeqData.nPage.MotionInfo=1;
    end

    for idx=1:NumberofSheet
        if idx~=1
            OldSheet=['MotionInfo',num2str(idx-1)];
            objExcel.ActiveWorkbook.Worksheets.Item(OldSheet).Activate;
            TempObj=objExcel.Activesheet;
            invoke(TempObj,'Copy',[],TempObj);
            objExcel.Activesheet.Name=['MotionInfo',num2str(idx)];
        end

        SheetName=['MotionInfo',num2str(idx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
        eActivesheetRange = get(objExcel.Activesheet,'Range','A3');
        
        if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
            eActivesheetRange.Value=['■ 시간별 위험도 분석결과 이미지 (',num2str(idx),'/',num2str(NumberofSheet),')'];
        elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
            eActivesheetRange.Value=['■ The change of Risk Analysis Results by Time elapses (',num2str(idx),'/',num2str(NumberofSheet),')'];
        end

    end

    RowIdx=1;
    ColIdx=1;
    cidx=0;
    CellCol=[65,69,73,77];
    CellRow=[6,12,18,24,30,36,42];

    Row=length(CellRow); Column=length(CellCol);

    for idx=1:size(ImgFileName,1)
        pageIdx=ceil(idx/DataPerpage);
        cidx=cidx+1;

        SheetName=['MotionInfo',num2str(pageIdx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate; % set active sheet

        CellNo=[char(CellCol(ColIdx)),num2str(CellRow(RowIdx))];

        ImgPath=[gSeqData.FolderInfo.RiskSpaceSnap,'\',char(ImgFileInfo(idx+2))];
        
        if isfile(ImgPath)
            imInfo = imfinfo(ImgPath);
    
            ImgHeightCoeff = 0.264567;
            ImgWidthCoeff = 0.2646;
    
            ExcelHeightCoeff = 0.36;
            ExcelWidthCoeff = 2.352941;
    
            CompensationCoeff=0.72;
    
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
            objExcel.ActiveSheet.Shapes.AddPicture(ImgPath,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
        else
            gSeqData.ErrCode=20013;
            gSeqData.ErrMsg=['RiskSpace SpliImage(',ImgFileName,') do not exist'];
            gSeqData.ErrCodeTotal=[gSeqData.ErrCodeTotal, gSeqData.ErrCode];
            gSeqData.ErrMsgTotal=[gSeqData.ErrMsgTotal, gSeqData.ErrMsg];
        end

        ColIdx=ColIdx+1;
        if ColIdx>Column
            ColIdx=1;
            RowIdx=RowIdx+1;
            if RowIdx==(Row+1)
                RowIdx=1;
            end
        end
    end 
end
%%
function gSeqData=BasicInfoPage(objExcel, SimInfo, gSeqData)
    SheetName='BasicInfo';
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;

    if exist('NumberofSheet','var')
        gSeqData.nPage.BasicInfo=NumberofSheet;
    else
        gSeqData.nPage.BasicInfo=1;
    end

    msg={gSeqData.BasicDocInfo.Manufacturer, gSeqData.BasicDocInfo.Model, gSeqData.BasicDocInfo.Serial};
    eActivesheetRange = get(objExcel.Activesheet,'Range','D5:D7');
    eActivesheetRange.Value=msg';

    if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
        Tempmsg1=['총 ',[num2str(size(SimInfo.RobotLinkInfo,1)+size(SimInfo.RobotEndEffectorInfo,1))],...
        '개 (',['로봇링크 : ',num2str(size(SimInfo.RobotLinkInfo,1)),'개, '],...
        ['엔드이팩터 : ',num2str(size(SimInfo.RobotEndEffectorInfo,1)),'개'],')'];
        
        Tempmsg2=['총 ',num2str(size(gSeqData.HspaceInfo,2)),'개'];

    elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
        Tempmsg1=['Total ',[num2str(size(SimInfo.RobotLinkInfo,1)+size(SimInfo.RobotEndEffectorInfo,1))],...
            ' points (',['RobotLink : ',num2str(size(SimInfo.RobotLinkInfo,1))],...
            [', End-Effector : ',num2str(size(SimInfo.RobotEndEffectorInfo,1)),')']];
        
        Tempmsg2=['Total ',num2str(size(gSeqData.HspaceInfo,2)),'ea'];
    end

    if strcmpi(SimInfo.AutoReport.Standard,'KHU')
        Tempmsg3='KOROS 1162-1:2021';
    elseif strcmpi(SimInfo.AutoReport.Standard,'ISO')
        Tempmsg3='ISO/TS 15066:2016(En)';
    end

    msg={[num2str(SimInfo.BasicInfo.StepTime), ' sec'], Tempmsg1, Tempmsg2,...
        [num2str(SimInfo.BasicInfo.EndEffectorMass),' kg'], Tempmsg3};
    eActivesheetRange = get(objExcel.Activesheet,'Range','D11:D15');
    eActivesheetRange.Value=msg';

    RobotPosInfo=split(SimInfo.BasicInfo.RobotBasePosition," ");
    RobotRotInfo=split(SimInfo.BasicInfo.RobotBaseRotation," ");

    EEPosInfo=split(SimInfo.CustomEEInfo.CustomEEPosition," ");
    EERotInfo=split(SimInfo.CustomEEInfo.CustomEERotation," ");

    prefix=[69:71]; % E to G
    for idx=1:length(prefix)
        eActivesheetRange = get(objExcel.Activesheet,'Range',[char(prefix(idx)),num2str(21)]);
        eActivesheetRange.Value=RobotPosInfo(idx);

        eActivesheetRange = get(objExcel.Activesheet,'Range',[char(prefix(idx)),num2str(22)]);
        eActivesheetRange.Value=EEPosInfo(idx);
    end

    prefix=[72:74]; % H to J
    for idx=1:length(prefix)
        eActivesheetRange = get(objExcel.Activesheet,'Range',[char(prefix(idx)),num2str(21)]);
        eActivesheetRange.Value=RobotRotInfo(idx);

        eActivesheetRange = get(objExcel.Activesheet,'Range',[char(prefix(idx)),num2str(22)]);
        eActivesheetRange.Value=EERotInfo(idx);
    end

    Cell.HSPACESETIMG='B26';

    if isfile(gSeqData.FolderInfo.LayOut)
        HSPACESETIMGPATH=ReportImgResize(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.LayOut);
        imInfo = imfinfo(HSPACESETIMGPATH);

        ImgRealHeight = imInfo.Height/gSeqData.Scale.ImgHeightCoeff; % mm
        ImgRealWidth = imInfo.Width/gSeqData.Scale.ImgWidthCoeff; % mm
                    
        CellRealHeight=96;
        CellRealWidth=153.8;
            
        Hr=CellRealHeight/ImgRealHeight;
        Wr=CellRealWidth/ImgRealWidth;
            
        ReductionRatio=min(Hr,Wr);
                            
        imHeight = imInfo.Height*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
        imWidth = imInfo.Width*ReductionRatio*gSeqData.Scale.CompensationCoeff; % points
                    
        CellHeightRealPoint=CellRealHeight*2.8478;
        CellWidthRealPoint=CellRealWidth*2.7681;
            
        margin=round(1.2*[(CellWidthRealPoint-imWidth)/2, (CellHeightRealPoint-imHeight)/2]);
                
        LinkToFile = 0;
        SaveWithDocument = 1;
        left = objExcel.ActiveSheet.Range(Cell.HSPACESETIMG).Left+margin(1);
        top = objExcel.ActiveSheet.Range(Cell.HSPACESETIMG).Top+margin(2);

        objExcel.ActiveSheet.Shapes.AddPicture(HSPACESETIMGPATH,LinkToFile,SaveWithDocument,left,top,imWidth,imHeight);
    end

    gSeqData.ErrCode=20000;
    
end
%%
function gSeqData=MotionDetailInfoPage(objExcel, SimInfo, gSeqData)
    SheetName='MotionInfoDetail1';

    if exist('NumberofSheet','var')
        gSeqData.nPage.MotionDetail=NumberofSheet;
    else
        gSeqData.nPage.MotionDetail=1;
    end
    
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
    eActivesheetRange = get(objExcel.Activesheet,'Range','B5');
    eActivesheetRange.Value=[gSeqData.BasicDocInfo.InputMotionLength,' sec'];

    if SimInfo.MotionDivisionApp
        eActivesheetRange = get(objExcel.Activesheet,'Range','B6');

        if strcmpi(SimInfo.AutoReport.Language,'ko-kr')
            eActivesheetRange.Value='적용';
        elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
            eActivesheetRange.Value='Applied';
        end

        for idx=1:size(SimInfo.MotionDivisionInfo,1)
            cellIdx=num2str(idx+8);
            if isempty(SimInfo.MotionDivisionInfo(idx).Name)
                if strcmpi(SimInfo.AutoReport.Language,'ko-kr')
                    Tempmsg=['모션 블럭 ',num2str(idx)];
                elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
                    Tempmsg=['Motion Block ',num2str(idx)];
                end
            else
                Tempmsg=SimInfo.MotionDivisionInfo(idx).Name;
            end

            tempmsg=[];
            RobotLink=split(SimInfo.MotionDivisionInfo(idx).RobotLinkNum,' ');
            for j=1:size(RobotLink,1)
                if j~=1
                    tempmsg=[tempmsg,', ',char(RobotLink(j))];
                else
                    tempmsg=[tempmsg,char(RobotLink(j))];
                end
            end

            SimInfo.MotionDivisionInfo(idx).RobotLinkNum=tempmsg;

            tempmsg=[];
            RobotEE=split(SimInfo.MotionDivisionInfo(idx).EENum,' ');
            for j=1:size(RobotEE,1)
                if j~=1
                    tempmsg=[tempmsg,', ',char(RobotEE(j))];
                else
                    tempmsg=[tempmsg,char(RobotEE(j))];
                end
            end

            SimInfo.MotionDivisionInfo(idx).EENum=tempmsg;

            msg={Tempmsg, SimInfo.MotionDivisionInfo(idx).StartTime, SimInfo.MotionDivisionInfo(idx).EndTime,...
                SimInfo.MotionDivisionInfo(idx).RobotLinkNum, SimInfo.MotionDivisionInfo(idx).EENum};

            eActivesheetRange = get(objExcel.Activesheet,'Range',['A',cellIdx,':','E',cellIdx]);
            eActivesheetRange.Value=msg;
        end

        eActivesheetRange = get(objExcel.Activesheet,'Range',['A7:','E',cellIdx]);
        eActivesheetRange.font.Color='000000';

        cellidxmax=18;
        cellIdx=str2num(cellIdx);

        if cellIdx<cellidxmax
	        borders = get(objExcel.ActiveSheet.Range(['A',num2str(cellIdx+1),':','E',num2str(cellidxmax)]), 'Borders');
	        theBorder = get(borders, 'Item', 9);
	        set(theBorder, 'LineStyle', 0);
            theBorder = get(borders, 'Item', 10);
	        set(theBorder, 'LineStyle', 0);
	        theBorder = get(borders, 'Item', 11);
	        set(theBorder, 'LineStyle', 0);
	        theBorder = get(borders, 'Item', 12);
	        set(theBorder, 'LineStyle', 0);
    
            eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(cellIdx+1),':','E',num2str(cellidxmax)]);
            eActivesheetRange.Value="";
        end
    else
        eActivesheetRange = get(objExcel.Activesheet,'Range','A7:E18');
        eActivesheetRange.Value=' ';

        eActivesheetRange = get(objExcel.Activesheet,'Range','B6');
        if strcmpi(SimInfo.AutoReport.Language,'ko-kr')
            eActivesheetRange.Value='미적용';
        elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
            eActivesheetRange.Value='Not Applied';
        end

        borders = get(objExcel.ActiveSheet.Range('A7:E18'), 'Borders');
        theBorder = get(borders, 'Item', 9);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 10);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 11);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 12);
        set(theBorder, 'LineStyle', 0);

    end

    gSeqData.ErrCode=20000;
        
end
%%
function gSeqData=ColliPosDetailPage(objExcel, ColliPosInfoR, ColliPosInfoEE, gSeqData)
    
    SheetName='ColliPosDetailRobot';
    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
    eActivesheetRange = get(objExcel.Activesheet,'Range','A3');

    if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
        eActivesheetRange.Value='■ RobotLink에 설정한 충돌 예상 부위 형상 정보';
    elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
        eActivesheetRange.Value='■ Configuration Details for Collision Expected Points of Robot';
    end
    

    for idx=1:size(ColliPosInfoR,2)
        cellIdx=idx+5;
        msg={num2str(idx),ColliPosInfoR(idx).RIndex,'RobotLink',ColliPosInfoR(idx).CoverInfo};
        eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(cellIdx),':','D',num2str(cellIdx)]);
        eActivesheetRange.Value=msg;
    end
    
    cellidxmax=27;
    
    if cellIdx<cellidxmax
        borders = get(objExcel.ActiveSheet.Range(['A',num2str(cellIdx+1),':','E',num2str(cellidxmax)]), 'Borders');
        theBorder = get(borders, 'Item', 9);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 11);
        set(theBorder, 'LineStyle', 0);
        theBorder = get(borders, 'Item', 12);
        set(theBorder, 'LineStyle', 0);
    end

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
    DataPerpage=20;
    NumberofSheet=ceil(size(ColliPosInfoEE,2)/DataPerpage);

    if exist('NumberofSheet','var')
        gSeqData.nPage.ColliPosDetail=NumberofSheet+1;
    else
        gSeqData.nPage.ColliPosDetail=2;
    end

    for idx=1:NumberofSheet
        if idx~=1
            OldSheet=['ColliPosDetail',num2str(idx-1)];
            objExcel.ActiveWorkbook.Worksheets.Item(OldSheet).Activate;
            TempObj=objExcel.Activesheet;
            invoke(TempObj,'Copy',[],TempObj);
            objExcel.Activesheet.Name=['ColliPosDetail',num2str(idx)];
        end

        SheetName=['ColliPosDetail',num2str(idx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;
        eActivesheetRange = get(objExcel.Activesheet,'Range','A3');
        
        if strcmpi(gSeqData.BasicDocInfo.Lang,'ko-kr')
            eActivesheetRange.Value=['■ End-Effector에 설정한 충돌 예상 부위 정보 상세 (',num2str(idx),'/',num2str(NumberofSheet),')'];
        elseif strcmpi(gSeqData.BasicDocInfo.Lang,'en-us')
            eActivesheetRange.Value=['■ Configuration Details for Collision Expected Points of End-effectors (',num2str(idx),'/',num2str(NumberofSheet),')'];
        end
    end

    for idx=1:size(ColliPosInfoEE,2)
        pageIdx=ceil(idx/DataPerpage);
        SheetName=['ColliPosDetail',num2str(pageIdx)];
        objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;

        if pageIdx>1
            cellIdx=idx-(pageIdx-1)*20+6;
        else
            cellIdx=idx+6;
        end

        msg={num2str(idx),ColliPosInfoEE(idx).Name,ColliPosInfoEE(idx).ColliShape,ColliPosInfoEE(idx).ColliRadi,...
            ColliPosInfoEE(idx).ColliFillet,ColliPosInfoEE(idx).ColliPosX,ColliPosInfoEE(idx).ColliPosY,ColliPosInfoEE(idx).ColliPosZ,...
            ColliPosInfoEE(idx).ColliRotationX,ColliPosInfoEE(idx).ColliRotationY,ColliPosInfoEE(idx).ColliRotationZ,...
            ColliPosInfoEE(idx).CoverInfo};

        eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(cellIdx),':','L',num2str(cellIdx)]);
        eActivesheetRange.Value=msg;
    end

    cellidxmax=26;

    if cellIdx<cellidxmax
	    borders = get(objExcel.ActiveSheet.Range(['A',num2str(cellIdx+1),':','L',num2str(cellidxmax)]), 'Borders');
	    theBorder = get(borders, 'Item', 9);
	    set(theBorder, 'LineStyle', 0);
	    theBorder = get(borders, 'Item', 11);
	    set(theBorder, 'LineStyle', 0);
	    theBorder = get(borders, 'Item', 12);
	    set(theBorder, 'LineStyle', 0);

        eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(cellIdx+1),':','L',num2str(cellidxmax)]);
        eActivesheetRange.Value="";
    end

    gSeqData.ErrCode=20000;
end
%%
function gSeqData=HspaceDetailPage(objExcel, gSeqData)
    SheetName='HspaceDetail1';
    
    if exist('NumberofSheet','var')
        gSeqData.nPage.HspaceDetail=NumberofSheet;
    else
        gSeqData.nPage.HspaceDetail=1;
    end

    objExcel.ActiveWorkbook.Worksheets.Item(SheetName).Activate;

    for idx=1:size(gSeqData.HspaceInfo,2)
        msg={gSeqData.HspaceInfo(idx).Index,gSeqData.HspaceInfo(idx).Name,gSeqData.HspaceInfo(idx).PosX,gSeqData.HspaceInfo(idx).PosY,...
            gSeqData.HspaceInfo(idx).Width,gSeqData.HspaceInfo(idx).Height,gSeqData.HspaceInfo(idx).ColliBody,gSeqData.HspaceInfo(idx).Status,...
            gSeqData.HspaceInfo(idx).BackMotionX,gSeqData.HspaceInfo(idx).BackMotionY};

        eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(idx+6),':J',num2str(idx+6)]);
        eActivesheetRange.Value=msg;
        eActivesheetRange.font.Color='000000';
    end

    cellidxmax=16;
    cellIdx=idx+6;

    if cellIdx<cellidxmax
	    borders = get(objExcel.ActiveSheet.Range(['A',num2str(cellIdx+1),':','J',num2str(cellidxmax)]), 'Borders');
	    theBorder = get(borders, 'Item', 9);
	    set(theBorder, 'LineStyle', 0);
	    theBorder = get(borders, 'Item', 11);
	    set(theBorder, 'LineStyle', 0);
	    theBorder = get(borders, 'Item', 12);
	    set(theBorder, 'LineStyle', 0);

        eActivesheetRange = get(objExcel.Activesheet,'Range',['A',num2str(cellIdx+1),':','J',num2str(cellidxmax)]);
        eActivesheetRange.Value="";
    end

    gSeqData.ErrCode=20000;

end
%%
function gSeqData=PathInfo(gSeqData, UserPath, InputDataPath)

    gSeqData.ErrCode=20000;
%     %Default Path
%     gSeqData.FolderInfo.UserPath=UserPath;
%     gSeqData.FolderInfo.InputDataPath=InputDataPath;

    %Origin Report Format file Path : KR. ver.
    gSeqData.FolderInfo.ReportOriginKR=[gSeqData.FolderInfo.InputDataPath,'\AutoReport\ReportKR.xlsx'];

    %Origin Report Format file Path : En. Ver.
    gSeqData.FolderInfo.ReportOriginEN=[gSeqData.FolderInfo.InputDataPath,'\AutoReport\ReportEN.xlsx'];

    %Json FilePath Info
    gSeqData.FolderInfo.AnalysisInfoFile=[gSeqData.FolderInfo.UserPath,'\ST_RobotInfo.json'];

    if isfile(gSeqData.FolderInfo.AnalysisInfoFile)
        SimInfo=AnalysisInfoLoad(gSeqData);

        if strcmpi(SimInfo.AutoReport.Standard,'KHU')
            %CSV FilePath Info
            gSeqData.FolderInfo.AnalysisResultFile=[gSeqData.FolderInfo.UserPath,'\KHU_Collision_Risk_Analyze_Result.csv'];
            %RiskSpace Analysis MovieClip Path Info
            gSeqData.FolderInfo.RiskSpaceMovie=[gSeqData.FolderInfo.UserPath,'\output\KHU_RiskSpace.mp4'];
            %Last Scene of Riskspace
            gSeqData.FolderInfo.HspaceLastImg=[gSeqData.FolderInfo.UserPath,'\output\KHU_RiskSpace.jpg'];
        elseif strcmpi(SimInfo.AutoReport.Standard,'ISO')
            %CSV FilePath Info
            gSeqData.FolderInfo.AnalysisResultFile=[gSeqData.FolderInfo.UserPath,'\ISO_Collision_Risk_Analyze_Result.csv'];
            %RiskSpace Analysis MovieClip Path Info
            gSeqData.FolderInfo.RiskSpaceMovie=[gSeqData.FolderInfo.UserPath,'\output\ISO_RiskSpace.mp4'];
            %Last Scene of Riskspace
            gSeqData.FolderInfo.HspaceLastImg=[gSeqData.FolderInfo.UserPath,'\output\ISO_RiskSpace.jpg'];
        end
    else
        gSeqData.ErrCode=20001;
    end
        
    %Graph SavePath Info
    gSeqData.FolderInfo.GraphSaveFolder=[gSeqData.FolderInfo.UserPath,'\output\graph'];
    
    %Report Generation Path
    addno=num2str(randi([10000 99999],1,1));
    gSeqData.FolderInfo.Report=[gSeqData.FolderInfo.UserPath,'\output\Report\Excel\PFLReport',addno,'.xlsx'];
    
%     %PDF file Path that generated by Excel Type Report
%     gSeqData.FolderInfo.ReportPDF=[gSeqData.FolderInfo.UserPath,'\output\Report\PDF\PFLReport.pdf'];

    if ~isfolder([gSeqData.FolderInfo.UserPath,'\output\Report\Excel'])
        mkdir([gSeqData.FolderInfo.UserPath,'\output\Report\Excel'])
    end
    if ~isfolder([gSeqData.FolderInfo.UserPath,'\output\Report\PDF'])
        mkdir([gSeqData.FolderInfo.UserPath,'\output\Report\PDF'])
    end
        
    %RiskSpace Analysis snap image save path
    gSeqData.FolderInfo.RiskSpaceSnap=[gSeqData.FolderInfo.UserPath,'\output\RiskSpaceSnapShot'];

    %ColliPosOnEE_Dot
    gSeqData.FolderInfo.ColliPosEE=[gSeqData.FolderInfo.UserPath,'\output\ColliPosOnEE_dot.jpg'];
    gSeqData.FolderInfo.ColliPosEE_detail=[gSeqData.FolderInfo.UserPath,'\output\ColliPosOnEE_dot_'];

    %ColliPosOnRobot_Dot
    gSeqData.FolderInfo.ColliPosRobot=[gSeqData.FolderInfo.UserPath,'\output\ColliPosOnRobot_dot.jpg'];

    %LayOut Image
    gSeqData.FolderInfo.LayOut=[gSeqData.FolderInfo.UserPath,'\output\NumberingHumanSpace.jpg'];

    %HumanSpace Img. Path. Default
    gSeqData.FolderInfo.HspaceImg=[gSeqData.FolderInfo.UserPath,'\output'];
end

%%
function gSeqData=ResultGraphGeneration(AnalysisResult, AnlysisInfo, gSeqData)

    if ~isfolder(gSeqData.FolderInfo.GraphSaveFolder)
        mkdir(gSeqData.FolderInfo.GraphSaveFolder)
    end
    
    ResData=AnalysisResult;
    SimInfo=AnlysisInfo;
    savefolder=gSeqData.FolderInfo.GraphSaveFolder;
    
    newcolor = {
        '#3530d1';'#3beb26';'#d03a0a';'#156465';'#ebe58f';'#f277c1';'#10efb7';
        '#300e50';'#c0d5ea';'#eaf506';'#4b7890';'#519448';'#6107d2';'#816a54';
        '#3d1627';'#9232d3';'#6dfae9';'#736f9d';'#9c5a24';'#7d4fcf';'#caa6d3';
        '#4c71b5';'#a232c6';'#d494cf';'#81f391';'#db7caf';'#ed37d4';'#68bc0c';
        '#dcc841';'#a8aed9';'#416859';'#f0f061';'#5fc3a6';'#bc21bf';'#f9af17';
        '#659663';'#837016';'#77fe53';'#652c7a';'#304e08';'#6fd397';'#d66aed';
        '#52ba0a';'#9a6f4a';'#d70dc8';'#d3dabf';'#d0f8bc';'#c9b8d9';'#a942e3';
        '#a22249';'#339371';'#2c166f';'#6cf085';'#8dd797';'#1fc864';'#3a9978';
        '#f5edbe';'#856c3b' ;'#899383';'#045730';'#305001';'#ac89b0';'#707e53';
        '#2a701e';'#da7a4b';'#5e4218';'#096984';'#8f58c4';'#319501';'#1edcde';
        '#2d4fc8';'#b753a0';'#e362b9';'#7057a9';'#9edd71';'#13e86d';'#8fcecd';};
    
%     [~, NumofColliPos]=AnalysisDataLoad(ResData,'Time');
       
    for i=1:size(SimInfo.RobotLinkInfo,1)
        CobotLegend{i}=['R',num2str(i)];
    end
        
    for i=1:size(SimInfo.RobotEndEffectorInfo,1)
        EELegend{i}=['EE',num2str(i)];
    end
    
    [t, ~]=AnalysisDataLoad(ResData,'Time');
    [MaxModiCRI, ~]=AnalysisDataLoad(ResData,'MaxModiCRI');
    [ImpactVelNorm, ~]=AnalysisDataLoad(ResData,'ImpactVelNorm');
    [Force, ~]=AnalysisDataLoad(ResData,'Force');
    [Pressure, ~]=AnalysisDataLoad(ResData,'Pressure');
    [ModiCRI, ~]=AnalysisDataLoad(ResData,'ModiCRI');
    
    criref(1:size(t))=1;
    [row, col]=find(ModiCRI==max(MaxModiCRI)); %% find the maximum CRI points (row = time/(1/125), col = collision joint)
    
    h1=figure('visible','off');
    colororder(h1,newcolor);
%     set(gcf,'color','w','Position',[522,268,913,642]); hold on, box on, axis on;
    set(gcf,'color','w','Position',[522,268,1170,642]); hold on, box on, axis on;
    set(gca,'FontSize',12,'FontWeight','Bold');
    RobotVel=ImpactVelNorm(:,1:size(AnlysisInfo.RobotLinkInfo,1));
    plot(t,RobotVel,'linewidth',1.5)
    xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Speed of Collision Pts on Cobot [mm/s]','FontSize',12,'FontWeight','bold');
    ylim([0 round(max(max(RobotVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
    legend(CobotLegend,'Location','southoutside','NumColumns',10,'fontsize',12,'fontweight','bold','Orientation','horizontal')
    gSeqData.FolderInfo.GraphPathInfo.fig_name1=[savefolder '\Cobot_Speed.jpg'];
    saveas(h1,gSeqData.FolderInfo.GraphPathInfo.fig_name1);
            
    h2=figure('visible','off');
    colororder(h2,newcolor);
%     set(gcf,'color','w','Position',[522,268,913,642]); hold on, box on, axis on;
    set(gcf,'color','w','Position',[522,268,1170,642]); hold on, box on, axis on;
    set(gca,'FontSize',12,'FontWeight','Bold');
%     EEVel=ImpactVelNorm(:,1:size(AnlysisInfo.RobotEndEffectorInfo,1));
    RobotLinkNo=size(gSeqData.SimInfo.RobotLinkInfo,1);
    EENo=size(gSeqData.SimInfo.RobotEndEffectorInfo,1);
    EEVel=ImpactVelNorm(:,(RobotLinkNo+1):(RobotLinkNo+EENo));
    plot(t,EEVel,'linewidth',1.5)
    xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Speed of End Effector [mm/s]','FontSize',12,'FontWeight','bold');
    if max(EEVel)>0
        ylim([0 round(max(max(EEVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
    else
        yticks('auto'),xlim([0 ceil(max(t))]);
    end
    legend([EELegend],'Location','southoutside','NumColumns',10,'fontsize',12,'fontweight','bold','Orientation','horizontal')  
    gSeqData.FolderInfo.GraphPathInfo.fig_name2=[savefolder '\EE_Vel.jpg'];
    saveas(h2,gSeqData.FolderInfo.GraphPathInfo.fig_name2);
    
    h3=figure('visible','off');
    legendstring=[CobotLegend,EELegend];
    colororder(h1,newcolor);
%     set(gcf,'color','w','Position',[522,268,913,642]); hold on, box on, axis on;
    set(gcf,'color','w','Position',[522,268,1170,642]); hold on, box on, axis on;
    set(gca,'FontSize',12,'FontWeight','Bold');
    plot(t,ModiCRI,'linewidth',1.5),axis on, box on, xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('CRI','FontSize',12,'FontWeight','bold'),ylim([0 3]),xlim([0 ceil(max(t))]);
    dim1 = [0.15 0.57 0.3 0.3];
    dim2 = [0.15,0.75,0.24,0.06];
    dim3 = [0.151,0.75,0.73,0.12];
    formatSpec = '%.3f';
    str1 = ['Max. CRI value is ',num2str(max(max(MaxModiCRI)),formatSpec),' on the ', char(legendstring(max(col))),'-th Collision points at ', num2str(t(max(row))), ' sec'];
    str2 = ['Est.Max Force : ',num2str(max(max(Force)),formatSpec),'N & Est.Max Pressure : ',num2str(max(max(Pressure))/100,formatSpec),'Mpa'];
    annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','white','fontsize',10.5);
    annotation('textbox',dim2,'String',str2,'FitBoxToText','on','EdgeColor','white','fontsize',10.5);
    annotation('rectangle',dim3,'Color','red','LineWidth',1.5)
    plot(t,MaxModiCRI,'linewidth',1.5),axis on, box on, xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('CRI','FontSize',12,'FontWeight','bold'),ylim([0 3]),xlim([0 ceil(max(t))]);
    plot(t,criref,'r--','linewidth',1.5),axis on, box on, xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('CRI','FontSize',12,'FontWeight','bold'),ylim([0 3]),xlim([0 ceil(max(t))]);
    plot(t(max(row)),max(max(MaxModiCRI)),'ro','Markersize',10)
    if max(MaxModiCRI)<1.5
        ylim([0 3]),xlim([0 ceil(max(t))]);
    else
        ylim([0 round(max(MaxModiCRI)*1.8)]),xlim([0 ceil(max(t))]);
    end
    legend([legendstring,'MaxCRI','CRI Reference','Max. CRI. Point'],'Location','southoutside','NumColumns',8,'fontsize',12,'fontweight','bold','Orientation','horizontal')
    gSeqData.FolderInfo.GraphPathInfo.fig_name3=[savefolder '\All_CRI_Res.jpg'];
    saveas(h3,gSeqData.FolderInfo.GraphPathInfo.fig_name3);

    close all

    gSeqData.ErrCode=20000;

end

%%
function SimInfo=AnalysisInfoLoad(gSeqData)
    try
        if isfile(gSeqData.FolderInfo.AnalysisInfoFile)
            fileID = fopen(gSeqData.FolderInfo.AnalysisInfoFile, 'r');
            rawdata = fread(fileID, inf);
            str = char(rawdata');
            fclose(fileID);
            JsonRobotInfo = jsondecode(str);
            Jsonfieldname = fieldnames(JsonRobotInfo.RobotInfo);

            TextRobotInfo_temp = textscan(fileread(gSeqData.FolderInfo.AnalysisInfoFile), '%q');
            AnlysisInfo.TextRobotInfo = TextRobotInfo_temp{1,1};
    
            if find(contains(Jsonfieldname,'AutoReport'))
                AnlysisInfo.AutoReport=JsonRobotInfo.RobotInfo.AutoReport;
            end
            
            if find(contains(Jsonfieldname,'BasicInfo'))
                AnlysisInfo.BasicInfo = JsonRobotInfo.RobotInfo.BasicInfo;
            end
        
            if find(contains(Jsonfieldname,'CustomEE'))
                AnlysisInfo.CustomEEInfo=JsonRobotInfo.RobotInfo.CustomEE;
            end
        
            if find(contains(Jsonfieldname,'RobotLink'))
                AnlysisInfo.RobotLinkInfo = JsonRobotInfo.RobotInfo.RobotLink;
            end
        
            if find(contains(Jsonfieldname,'RobotEndEffector'))
                AnlysisInfo.RobotEndEffectorInfo = JsonRobotInfo.RobotInfo.RobotEndEffector;
            end
        
            if find(contains(Jsonfieldname,'RiskSpace'))
                AnlysisInfo.RiskSpaceInfo = JsonRobotInfo.RobotInfo.RiskSpace;
            end
        
            if find(contains(Jsonfieldname,'MotionDivision'))
                AnlysisInfo.MotionDivisionInfo=JsonRobotInfo.RobotInfo.MotionDivision;
            end
    
            if length(find(strcmpi(Jsonfieldname,'Motiondivision')==1))~=false
                if size(JsonRobotInfo.RobotInfo.MotionDivision)~=false
                    AnlysisInfo.MotionDivisionApp=true;
                else
                    AnlysisInfo.MotionDivisionApp=false;
                end
            else
                AnlysisInfo.MotionDivisionApp=false;
            end
        end
    
        SimInfo=AnlysisInfo;
        gSeqData.ErrCode=20000;
    catch

    end
end

%%
function Data=getFieldData (varname, cardname)

    fieldname=getFieldName (varname);
    
    if find(contains(fieldname,cardname),1)
        Data=[];
        x=getfield(varname(1),cardname);
        VarableType=class(x);
    
        switch VarableType
            case 'double'
                for i=1:size(varname,2)
                    Data(i,1)=getfield(varname(i),cardname);
                end
    
            case 'char'
                for i=1:size(varname,2)
                    Data{i,1}=getfield(varname(i),cardname);
                end
        
            otherwise
        end
        
    end

end

%%
function fieldname=getFieldName (varname)
    fieldname=fieldnames(varname);
end

%%
function [varData, NumofColliPos]=AnalysisDataLoad(ResData,variableName)

    HeaderGroup=["Unix_Time_Hour";"Unix_Time_Min";"Unix_Time_Sec";"Elapse";
    "Time";"q_";"qd_";"EffectiveMass";"ImpactVelNorm";"ImpactVelDirNorm";"ImpactVelAlphaNorm";
    "Force";"Pressure";"MaxCRI";"CRI";"MaxModiCRI";"ModiCRI";"ImpactPosList";
    "BoxInOutIndex";"AssignBoxIndex";"OverlappedBoxIndex";"MinScale";"Scale";
    "MinModiScale";"ModiScale";"ColliAlpha";"BasePosition";];
    
    org=ResData;
    header=org.colheaders;
    NumofColliPos=sum(contains(org.colheaders,'EffectiveMass'));
    
    idxCnt=0;
    for i=1:length(HeaderGroup)
        % count the # of element
        if HeaderGroup(i)=='Time' %sigle Line Variable
            HeaderGroup(i,2)=1;
        elseif HeaderGroup(i)=='CRI'
            HeaderGroup(i,2)=NumofColliPos;
        elseif HeaderGroup(i)=='ModiCRI'
            HeaderGroup(i,2)=NumofColliPos;
        elseif HeaderGroup(i)=='Scale'
            HeaderGroup(i,2)=NumofColliPos;
        elseif HeaderGroup(i)=='ModiScale'
            HeaderGroup(i,2)=NumofColliPos;
        elseif HeaderGroup(i)=='q_'
            HeaderGroup(i,2)=6;
        elseif HeaderGroup(i)=='qd_'
            HeaderGroup(i,2)=6;
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
    HeaderName=variableName;
    
    if string(HeaderName)~='HeaderGroup'
        Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
        Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
        if Scol==Ecol
            varData=org.data(:,Scol);
        else
            varData=org.data(:,Scol:Ecol);
        end
    else
        varData=HeaderGroup(:,1);
    end
end

%%
function RetValue=HSpaceAnalysis(SimInfo,AnalysisResult)

    [HeaderGroup, NumofColliPos]=AnalysisDataLoad(AnalysisResult,'HeaderGroup');
    
    [t, NumofColliPos]=AnalysisDataLoad(AnalysisResult,'Time');
    [MaxModiCRI, NumofColliPos]=AnalysisDataLoad(AnalysisResult,'MaxModiCRI');
    [ModiCRI, NumofColliPos]=AnalysisDataLoad(AnalysisResult,'ModiCRI');
    [OverlappedBoxIndex, NumofColliPos]=AnalysisDataLoad(AnalysisResult,'OverlappedBoxIndex');

    DangerFiledInfo=[];
    DangerFiledInfo(:,1)=t;
    DangerFiledInfo(:,2)=MaxModiCRI;

    for i=1:length(t)
        A=ModiCRI(i,:);
        if max(A)>1
            B=MaxModiCRI(i,1);
            C=find(A==B);
            [m n]=size(C);
            DangerFiledInfo(i,3)=OverlappedBoxIndex(i,C(1));
        else
            DangerFiledInfo(i,3)=0;
        end
    end

    if size(SimInfo.RiskSpaceInfo,1)~=0
        tempDangerField=unique(DangerFiledInfo(:,3)');
        DangerFieldIdx=tempDangerField(2:length(tempDangerField));
        CRIatHSPACE=[];
        maxtempCRIIdx=[];
        NumofdangerPoints=[];

        for i=1:length(t)
            tempIdx=[];
            tempCRIIdx=[];

            for j=1:size(SimInfo.RiskSpaceInfo,1)
                tempCRIIdx=[];
                tempIdx=find(OverlappedBoxIndex(i,:)==j); %index

                if length(tempIdx)~=0
                    for k=1:length(tempIdx)
                        tempCRIIdx(1,k)=ModiCRI(i,tempIdx(k));%value
                    end
                    maxtempCRIIdx=max(max(tempCRIIdx));
                    CRIatHSPACE(i,j)=maxtempCRIIdx;
                else
                    CRIatHSPACE(i,j)=0;
                end
            end
        end

        for j=1:size(SimInfo.RiskSpaceInfo,1)
            NumofdangerPoints(1,j)=length(find(CRIatHSPACE(:,j)>1));
            NumofdangerPoints(2,j)=max(max(CRIatHSPACE(:,j)));
        end
    end
    
    formatSpec = '%.3f';
    if max(max(MaxModiCRI)) <= 1
        ReportInfo.BasicInfo.Results=['PASS (Max. CRI :',num2str(max(max(MaxModiCRI)),formatSpec),')'];
    else
        ReportInfo.BasicInfo.Results=['FAIL (Max. CRI :',num2str(max(max(MaxModiCRI)),formatSpec),')'];
    end

    %Colli Body Info
    for i=1:size(SimInfo.RiskSpaceInfo,1)
        ColliBodyMsgTemp=SimInfo.RiskSpaceInfo(i).ColliBody;

        if NumofdangerPoints(2,i)>1
            PASSFAILMSG='FAIL';
        else
            PASSFAILMSG='PASS';
        end

        if strcmpi(SimInfo.AutoReport.Language,'ko-kr')
            if strcmpi(char(ColliBodyMsgTemp),'SkullandForehead')
                ColliBody='머리';
            elseif strcmpi(char(ColliBodyMsgTemp),'Chest')
                ColliBody='가슴';
            elseif strcmpi(char(ColliBodyMsgTemp),'Upperarmandelbow')
                ColliBody='상완';
            elseif strcmpi(char(ColliBodyMsgTemp),'HandandFinger')
                ColliBody='손';
            elseif strcmpi(char(ColliBodyMsgTemp),'Lowerarmandwrist')
                ColliBody='하박';
            elseif strcmpi(char(ColliBodyMsgTemp),'thighsandknees')
                ColliBody='대퇴';                            
            end
    
            if isempty(SimInfo.RiskSpaceInfo(i).Name)
                Name=['리스크 스페이스 ',num2str(i)];
            else
                Name=SimInfo.RiskSpaceInfo.Name;
            end
            
            HspacePos=split(SimInfo.RiskSpaceInfo(i).Hspace," ");
            BackMotionPos=split(SimInfo.RiskSpaceInfo(i).BackMotion," ");
            if str2num(string(BackMotionPos(1)))==false && str2num(string(BackMotionPos(2)))==false
                Status='미적용';
            else
                Status='적용';
            end

        elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
            if strcmpi(char(ColliBodyMsgTemp),'SkullandForehead')
                ColliBody='Center of forehead';
            elseif strcmpi(char(ColliBodyMsgTemp),'Chest')
                ColliBody='Sternum';
            elseif strcmpi(char(ColliBodyMsgTemp),'Upperarmandelbow')
                ColliBody='Deltoid muscle';
            elseif strcmpi(char(ColliBodyMsgTemp),'HandandFinger')
                ColliBody='Forefinger pad';
            elseif strcmpi(char(ColliBodyMsgTemp),'Lowerarmandwrist')
                ColliBody='Radial bone';
            elseif strcmpi(char(ColliBodyMsgTemp),'thighsandknees')
                ColliBody='Thigh muscle';                            
            end
    
            if isempty(SimInfo.RiskSpaceInfo(i).Name)
                Name=['RiskSpace ',num2str(i)];
            else
                Name=SimInfo.RiskSpaceInfo.Name;
            end
            
            HspacePos=split(SimInfo.RiskSpaceInfo(i).Hspace," ");
            BackMotionPos=split(SimInfo.RiskSpaceInfo(i).BackMotion," ");
            if str2num(string(BackMotionPos(1)))==false && str2num(string(BackMotionPos(2)))==false
                Status='Not Applied';
            else
                Status='Applied';
            end
        end

        RetValue(i)=struct('Index',i,'Name',Name,...
            'PosX',HspacePos(1),'PosY',HspacePos(2),'Width',HspacePos(3),'Height',HspacePos(4),...
            'ColliBody',ColliBody,'Status',Status,'BackMotionX',BackMotionPos(1),'BackMotionY',BackMotionPos(2),...
            'CRI',num2str(NumofdangerPoints(2,i),formatSpec),...
            'ColliBodyCloth',SimInfo.RiskSpaceInfo(i).ColliBodyCloth,...
            'ZaxisDirection',SimInfo.RiskSpaceInfo(i).ZaxisDirection,'Results',PASSFAILMSG);        
    end
end

%%
function [RetValueR, RetValueEE]=ColliPosAnalysis(SimInfo, AnalysisResult)
    [ModiCRI, ~]=AnalysisDataLoad(AnalysisResult,'ModiCRI');
    DangerPt=max(ModiCRI);

    for i=1:size(SimInfo.RobotLinkInfo,1)
        if strcmpi(class(SimInfo.RobotLinkInfo),'struct')
            PosInfo=split(SimInfo.RobotLinkInfo(i).ColliPos," ");
        elseif strcmpi(class(SimInfo.RobotLinkInfo),'cell')
            PosInfo=split(SimInfo.RobotLinkInfo{i}.ColliPos," ");
        end

        if strcmpi(class(SimInfo.RobotLinkInfo),'struct')
            tempData=SimInfo.RobotLinkInfo(i).ColliShape;
        elseif strcmpi(class(SimInfo.SimInfo.RobotLinkInfo),'cell')
            tempData=SimInfo.RobotLinkInfo{i}.ColliShape;
        end
        
        switch tempData
            case 1
                Shape='Corner';
            case 5
                Shape='Cylinder';
            case 8
                Shape='Sphere';
            otherwise

        end

        if strcmpi(class(SimInfo.RobotLinkInfo),'struct')
            tempData=SimInfo.RobotLinkInfo(i).CoverInfo;
        elseif strcmpi(class(SimInfo.RobotLinkInfo),'cell')
            tempData=SimInfo.RobotLinkInfo{i}.CoverInfo;
        end
        
        if tempData==false
            if strcmpi(SimInfo.AutoReport.Language,'Ko-Kr')
                CoverInfo='미적용';
            elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
                CoverInfo='Not Applied';
            end
        else
            if strcmpi(SimInfo.AutoReport.Language,'Ko-Kr')
                CoverInfo='적용';
            elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
                CoverInfo='Applied';
            end
        end
                
        RetValueR(i)=struct('RIndex',['R',num2str(i)],'Type','RobotLink',...
            'CoverInfo',CoverInfo,'Danger',DangerPt(i));
    end

    for i=1:size(SimInfo.RobotEndEffectorInfo,1)

        if strcmpi(class(SimInfo.RobotEndEffectorInfo),'struct')
            PosInfo=split(SimInfo.RobotEndEffectorInfo(i).ColliPos," ");
            RotationTemp=split(SimInfo.RobotEndEffectorInfo(i).ColliRotation," ");
        elseif strcmpi(class(SimInfo.RobotEndEffectorInfo),'cell')
            PosInfo=split(SimInfo.RobotEndEffectorInfo{i}.ColliPos," ");
            RotationTemp=split(SimInfo.RobotEndEffectorInfo{i}.ColliRotation," ");
        end

        for j=1:3
            Rotation(j)=round(str2num(string(RotationTemp(j)))*180/pi);
        end

        if strcmpi(class(SimInfo.RobotEndEffectorInfo),'struct')
            tempData=SimInfo.RobotEndEffectorInfo(i).ColliShape
        elseif strcmpi(class(SimInfo.RobotEndEffectorInfo),'cell')
            tempData=SimInfo.RobotEndEffectorInfo{i}.ColliShape
        end
        
        switch tempData
            case 1
                Shape='Corner';
            case 5
                Shape='Cylinder';
            case 8
                Shape='Sphere';
            otherwise

        end

        if strcmpi(SimInfo.AutoReport.Language,'ko-kr')
            if strcmpi(class(SimInfo.RobotEndEffectorInfo),'struct')
                if isempty(SimInfo.RobotEndEffectorInfo(i).Name)
                    Name=[Shape, ' ', num2str(i)];
                else
                    Name=SimInfo.RobotEndEffectorInfo(i).Name;
                end
        
                if SimInfo.RobotEndEffectorInfo(i).CoverInfo==false
                    CoverInfo='미적용';
                else
                    CoverInfo='적용';
                end
            elseif strcmpi(class(SimInfo.RobotEndEffectorInfo),'cell')
                if isempty(SimInfo.RobotEndEffectorInfo{i}.Name)
                    Name=[Shape, ' ', num2str(i)];
                else
                    Name=SimInfo.RobotEndEffectorInfo{i}.Name;
                end
        
                if SimInfo.RobotEndEffectorInfo{i}.CoverInfo==false
                    CoverInfo='None';
                else
                    CoverInfo='Applied';
                end
            end
        elseif strcmpi(SimInfo.AutoReport.Language,'en-us')
            if strcmpi(class(SimInfo.RobotEndEffectorInfo),'struct')
                if isempty(SimInfo.RobotEndEffectorInfo(i).Name)
                    Name=[Shape, ' ', num2str(i)];
                else
                    Name=SimInfo.RobotEndEffectorInfo(i).Name;
                end
        
                if SimInfo.RobotEndEffectorInfo(i).CoverInfo==false
                    CoverInfo='Not Applied';
                else
                    CoverInfo='Applied';
                end
            elseif strcmpi(class(SimInfo.RobotEndEffectorInfo),'cell')
                if isempty(SimInfo.RobotEndEffectorInfo{i}.Name)
                    Name=[Shape, ' ', num2str(i)];
                else
                    Name=SimInfo.RobotEndEffectorInfo{i}.Name;
                end
        
                if SimInfo.RobotEndEffectorInfo{i}.CoverInfo==false
                    CoverInfo='None';
                else
                    CoverInfo='Applied';
                end
            end
        end
                
        RetValueEE(i)=struct('EEIndex',['EE',num2str(i)],'Type','End-Effector','ColliShape',Shape,'Name',Name,...
            'ColliRadi',num2str(SimInfo.RobotEndEffectorInfo(i).ColliRadi),...
            'ColliFillet',num2str(SimInfo.RobotEndEffectorInfo(i).ColliFillet),...
            'ColliPosX',PosInfo(1),'ColliPosY',PosInfo(2),'ColliPosZ',PosInfo(3),...
            'ColliRotationX',num2str(Rotation(1)),'ColliRotationY',num2str(Rotation(2)),'ColliRotationZ',num2str(Rotation(3)),...
            'CoverInfo',CoverInfo,'ColliJoint',num2str(SimInfo.RobotEndEffectorInfo(i).ColliJoint),'Danger',DangerPt(size(SimInfo.RobotLinkInfo,1)+i));
    end
end

%%
function SplitDone = SaveVideoSplitImg(RiskSpaceMovie,SnapShotPath)

    SplitDone=0;
    
    try
        clc
        %Default Path Set
        ImgDimension = [1 35];
                    
        if isfolder(SnapShotPath)
            delete([SnapShotPath,'\*.jpg']);
        else
            mkdir(SnapShotPath);            
        end
            
        ORG=VideoReader(RiskSpaceMovie);        
        VideoLength=ORG.Duration;
            
        if ((VideoLength>0) & (VideoLength<=5))
            Interval=0.1;
        elseif ((VideoLength>5) & (VideoLength<=20))
            Interval=0.1;
        elseif ((VideoLength>20) & (VideoLength<=60))
            Interval=0.1;
        elseif ((VideoLength>60) & (VideoLength<=120))
            Interval=1;
        elseif ((VideoLength>120) & (VideoLength<=300))
            Interval=1;
        elseif ((VideoLength>300) & (VideoLength<=500))
            Interval=5;
        elseif VideoLength>500
            Interval=5;
        end
            
        Scale=Interval/(1/ORG.FrameRate);
        TimeStep=Scale*(1/ORG.FrameRate);
        ScaleInput=0.15;
            
        Count=1;
        CRfunc = 1;
            
        for i = 1 : ORG.FrameRate * ORG.Duration
            if i==1
                Video = read(ORG,i);
                grayImage = min(Video, [], 3);
                binaryImage = grayImage < 254;
                [rows, columns] = find(binaryImage);
                    
                row1 = min(rows);
                row2 = max(rows);
                col1 = min(columns);
                col2 = max(columns);
    
                croppedImage = Video(row1:row2, col1:col2, :);
    
                ResizedVideo = imresize(croppedImage,ScaleInput);
                ImgFileName=[SnapShotPath,'\',sprintf('%06.0f',Count),'.jpg'];
                imwrite(ResizedVideo,ImgFileName);
                Count=Count+1;
            else
                if ((rem(i,Scale) == 0) && (i~=(ORG.FrameRate * ORG.Duration))) % time step = 1/v.FrameRate*30
                    Video = read(ORG,i+1);
                    ResizedVideo = imresize(Video,ScaleInput);
                    ImgFileName=[SnapShotPath,'\',sprintf('%06.0f',Count),'.jpg'];
                    imwrite(ResizedVideo,ImgFileName);
                    Count=Count+1;
                end
            end
        end
%         disp('Generate the split image done!!')
        SplitDone=1;
    %     end
        
    
    catch exeception
        SplitDone=0;
        disp('[Status] = Error Occured during the Generate the Slpit Image')
        [m n]=size(exeception.stack);
        for i=1:m
            disp(['[Status] = Function name : ', exeception.stack(i).name])
            disp(['[Status] = Line : ', exeception.stack(i).line])
        end        
        disp(['[Status] = Error message: ', exeception.message])
    end
end

%%
function tempImgPath=ReportImgResize(UserPath, FullPath)   
    imgpath=FullPath;
    rgbImage=imread(imgpath);
    grayImage = min(rgbImage, [], 3);
    binaryImage = grayImage < 254;
    [rows, columns] = find(binaryImage);
    
    row1 = min(rows);
    row2 = max(rows);
    col1 = min(columns);
    col2 = max(columns);
    if contains(FullPath,'_RiskSpace.jpg')
        row2 = max(rows+30);
        col2 = max(columns+20);
    end
    
    % Crop
    tempImgPath=[UserPath, '\output\tempImg.jpg'];
    croppedImage = rgbImage(row1:row2, col1:col2, :);
    imwrite(croppedImage, tempImgPath)
end

function RetValue=ExtractPattern(str, match)
    tempValue=char(str(find(contains(str, match))+1));
    RetValue=tempValue(1:length(tempValue)-1);
end

function retValue=getExcelPid
    taskToLookFor = 'Excel.exe';
    commandLine = sprintf('tasklist /FI "IMAGENAME eq %s"', taskToLookFor);
    [status result] = system(commandLine);
    A=strread(result,'%s','whitespace','\n');
    C=char(A(size(A,1)));
    E=strrep(lower(strrep(C,' ','')),lower('excel.exe'),'');
    tempPid=E(1:5);
    ProcessID=[];
    
    for i=1:5
        if 48<=double(tempPid(i)) & double(tempPid(i))<=57
            ProcessID=[ProcessID, tempPid(i)];
        end
    end

    retValue=ProcessID;
end