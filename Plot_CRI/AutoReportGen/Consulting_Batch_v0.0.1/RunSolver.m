function gSeqData = RunSolver(gSeqData)
    
    gSeqData.CalculationStart=false;     
    gSeqData.CalculationSuccess=false;
    gSeqData.FolderInfo.SolverLogPath=[gSeqData.FolderInfo.UserPath,'\SolverLog.txt'];
 
    cd(gSeqData.FolderInfo.CurrentPath);
    BatchRunPath=cd;
    
    cd(gSeqData.FolderInfo.AppDataPath)
    AppDataPath=cd;
    
    cd(gSeqData.FolderInfo.CurrentPath);
    BatchRunPath=cd;
    
    cd(gSeqData.FolderInfo.AppDataPath)
    AppDataPath=cd;
    
    cd(gSeqData.FolderInfo.CurrentPath);
    cd(gSeqData.FolderInfo.CorePath);
    CorePath=cd;
    
    FolderInfo=dir(CorePath);
    CorePath=[CorePath,'\',FolderInfo(size(FolderInfo,1)).name];
%     CoreFileName=['SafetyCore_',FolderInfo(size(FolderInfo,1)).name,'.exe'];
    CoreFileName='D:\JayLim\OneDrive\SAFETICS\03_consulting\SFT_DEV\JAYLIM_DEV\Consulting_package\SafetyCore\v1.2.3\SafetyCoreTest.exe';
    CMDPath='C:\Windows\System32\cmd.exe - ';
    ExeSwIdx=[CMDPath,CoreFileName];

    RobotInfoCheck=isfile([gSeqData.FolderInfo.UserPath,'\ST_RobotInfo.Json']);
    MotionInfoCheck=isfile([gSeqData.FolderInfo.UserPath,'\ST_MotionInfo.txt']);

    if RobotInfoCheck&MotionInfoCheck

        fid=fopen(gSeqData.FolderInfo.SolverLogPath,'w+');
        fclose(fid);
      
        % Wscript object creat
        wsh = actxserver('WScript.Shell');
        CMD='cmd.exe';
    
        wsh.AppActivate(ExeSwIdx); 
        wsh.Run('cmd.exe');
        pause(1)
        
        % Goto solverpath
        wsh.AppActivate(ExeSwIdx);  
        pause(0.2)
        wsh.SendKeys('cd\~');
        pause(0.2)
        DriveName=CorePath(1:2);
        wsh.SendKeys([DriveName,'~']);
        pause(0.2)
        clipboard('copy',['cd ',CorePath]);
        wsh.SendKeys('^v');
        pause(0.5)
        wsh.SendKeys('~');
    
        % cmd 1 : running the solver
        MyCMD=[CoreFileName,' > ', gSeqData.FolderInfo.SolverLogPath];
        clipboard('copy', MyCMD)
        wsh.AppActivate(ExeSwIdx); 
        pause(0.5)
        wsh.SendKeys('^v');
        pause(0.5)
        wsh.SendKeys('~');
    
        WhileIdx=1;
        
        ClockHandler=tic;
    
        fid=fopen(gSeqData.FolderInfo.SolverLogPath);
        ProcIdx=1;
        while WhileIdx
            strTemp=fgetl(fid);
            if ischar(strTemp)
                disp(strTemp)
                switch ProcIdx
                    case 1
                        if contains(strTemp,'Press ST_RobotInfo and ST_RobotMotion path')
                            clipboard('copy', gSeqData.FolderInfo.UserPath);
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.SendKeys('^v');
                            pause(0.5)
        
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.SendKeys('~');
                            ProcIdx=ProcIdx+1;
                        else
                
                        end
        
                    case 2
                        if contains(strTemp,'Press InputData path')
                            clipboard('copy', AppDataPath);
        
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.SendKeys('^v');
                            pause(0.5)
        
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.AppActivate(ExeSwIdx); 
                            wsh.SendKeys('~');
                            ProcIdx=ProcIdx+1;
                        else
                
                        end
    
                    case 3
                        if contains(strTemp,'Start')
                            gSeqData.CalculationStart=true;                        
                            ProcIdx=ProcIdx+1;
                        else
    %                         gSeqData.CalculationStart=false;                        
    %                         ProcIdx=ProcIdx+1;            
                        end
    
        
                    case 4
                        if contains(strTemp,'exit')
                            wsh.AppActivate(ExeSwIdx);
                            wsh.SendKeys('~');
                            wsh.AppActivate(ExeSwIdx);
                            wsh.SendKeys('~');
                            wsh.AppActivate(ExeSwIdx);
                            wsh.SendKeys('~');
                            wsh.AppActivate(ExeSwIdx);    
                            wsh.SendKeys('exit~'); 
                            WhileIdx=0;
                            
                        else
                
                        end
    
                    otherwise
        
                end
    
            else
                ElapsesTime=toc(ClockHandler);
                if ElapsesTime>gSeqData.SolverTimeOut % -> timeout check
                    WhileIdx=0;
                    wsh.AppActivate(ExeSwIdx)
                    pause(0.3);                            
                    wsh.AppActivate(ExeSwIdx)
                    pause(0.5);
                    wsh.SendKeys('^c'); 
                    wsh.SendKeys('^c'); 
                    wsh.SendKeys('^c'); 
                    pause(0.5);
                    wsh.SendKeys('exit~'); 
                    gSeqData.ErrCode=1;
                    gSeqData.ErrMsg='ERR::Solver Time Out';
                end
            end
        end
    
        fclose(fid);
    else
        
    end

    clc

    if RobotInfoCheck~=true
        msg='ERR::ST_RobotInfo.Json File Missing';
        gSeqData.ErrCode=2;
        gSeqData.ErrMsg=msg;
    end
        
    if MotionInfoCheck~=true
        msg='ERR::ST_MotionInfo.txt File Missing';
        gSeqData.ErrCode=3;
        gSeqData.ErrMsg=msg;
    end

    if gSeqData.CalculationStart
        gSeqData.CalculationSuccess=true;
        disp("Simulation Success")
    else
        gSeqData.CalculationSuccess=false;
        disp("Simulation Failed")    
    end

    if gSeqData.TaskIdx~=1
        pause(1.5)
        clc
    else
        disp("Please press Any Key!!")
        pause
    end   

    cd(gSeqData.FolderInfo.CurrentPath);
    
end

