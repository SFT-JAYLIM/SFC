function [SolverRunPath SolverRunDoneFlag IsSimOk SimCondIdx] = RunSolver(UserPath,SolverVer,MatlabCodeVer,Timeout)

SimStartCnt=string(datetime('now'));
[IsSimOk SimCondIdx ColliBody BoundaryC]=ChkSimCondition(UserPath); 

SolverStartFailFlag=1;
SimStartCnt=string(datetime('now'));
OrgFolder=cd;
cd ../
NewFolder=cd;
LogPath= [UserPath,'\log.txt'];
CMDPath='C:\Windows\System32\cmd.exe - ';
ExeSwIdx=[CMDPath,SolverVer];
NotConvergedPT=0;

% if isfile(LogPath)~=1
    fid=fopen(LogPath,'w+');
%     pause(0.5);
%     fprintf(fileID,'Logrecorder');
    fclose(fid);
% end
IsSimOk=1;
if IsSimOk
    
    ForReading = 1;
    TemporaryFolder = 2;
    WshHide = 0;

    % Wscript object creat
    wsh = actxserver('WScript.Shell');
    fs = actxserver('Scripting.FileSystemObject');
    strTempFile = fs.BuildPath(fs.GetSpecialFolder(TemporaryFolder).Path, fs.GetTempName);
    strFile = fs.BuildPath(fs.GetSpecialFolder(TemporaryFolder).Path, "result.txt");

    CMD='cmd.exe';
    wsh.AppActivate(ExeSwIdx); 
    wsh.AppActivate(ExeSwIdx); 
    wsh.Run('cmd.exe');
    pause(1)
    frames = java.awt.Frame.getFrames();
    frames(end).setAlwaysOnTop(1); 

    % goto solverpath
    wsh.AppActivate(ExeSwIdx);  
    pause(0.5)
    wsh.SendKeys('cd\~');
    pause(0.5)
    DriveName=NewFolder(1:2);
    wsh.SendKeys([DriveName,'~']);
    pause(0.5)
    RootPath=NewFolder;
    wsh.SendKeys(['cd ',RootPath, '~']);
    pause(0.5)

    % cmd 1 : running the solver
    MyCMD=[SolverVer,' > ', LogPath];
    clipboard('copy',MyCMD)
    wsh.AppActivate(ExeSwIdx); 
    pause(0.5)
    wsh.SendKeys('^v~');
    pause(0.5)
    % wsh.SendKeys('~');
    % wsh.SendKeys([MyCMD]);
    clc
    fid=fopen(LogPath);
    % first input -> UserPaTh Set
    if UserPath~=0
        WhileIdx=1;
        tic
        while WhileIdx
            strTemp=fgetl(fid);
            if ischar(strTemp) % if any log or character read, then
                disp(strTemp)
                pat='Press ST_RobotMotion.txt and ST_RobotInfo.txt path';
                pat2='Press ST_RobotInfo.txt and ST_RobotMotion.txt path: ';
                if string(strTemp)==string(pat) || string(strTemp)==string(pat2) %when log matched to pattern
                    WhileIdx=0;
                    SolverStartFailFlag=0;
                    pause(0.5);
                    cd;
                    clipboard('copy',UserPath);
                    wsh.AppActivate(ExeSwIdx); 
                    wsh.AppActivate(ExeSwIdx); 
                    wsh.AppActivate(ExeSwIdx); 
                    pause(1.0)
                    wsh.SendKeys('^v~');
                    pause(3)
                end
                
            else
                TimeCNT=toc;
                if TimeCNT>Timeout % -> timeout check
                    WhileIdx=0;
                    wsh.AppActivate(ExeSwIdx)
                    pause(0.3);                            
                    wsh.AppActivate(ExeSwIdx)
                    pause(0.5);
                    wsh.SendKeys('^c'); 
                    pause(0.5);
                    wsh.SendKeys('exit~'); 
                    SolverRunDoneFlag=0;
                    SolverRunPath=UserPath;
                    SolverStartFailFlag=1;
                    fclose(fid);
                end
            end
        end
    else
        SolverStartFailFlag=1;
        SolverRunDoneFlag=0;
        SolverRunPath=UserPath;
        fclose(fid);
    end
    
    % Solver Run Check
    if SolverStartFailFlag==0
        WhileIdx=1;
        tic
        while WhileIdx
            strTemp=fgetl(fid);
            if ischar(strTemp)
                disp(strTemp)
                pat='CalculateLoop Start';
                if string(strTemp)==string(pat)
                WhileIdx=0;
                SolverStartFailFlag=0;
                end
            else
                TimeCnt=toc;
                if TimeCnt>Timeout
                    WhileIdx=0;
                    SolverStartFailFlag=1;
                    wsh.AppActivate(ExeSwIdx)
                    pause(0.3);
                    wsh.SendKeys('^c~');
                    pause(0.3);
                    wsh.SendKeys('^c~');
                    pause(0.3);
                    wsh.AppActivate(ExeSwIdx)
                    pause(1);
                    wsh.SendKeys('exit~'); 
                    SolverRunDoneFlag=0;
                    SolverRunPath=UserPath;
                    SolverStartFailFlag=1;
                    fclose(fid);
                end
            end
        end
    end
    
    if SolverStartFailFlag==0
        WhileIdx=1;
        while WhileIdx
            strTemp=fgetl(fid);
            if ischar(strTemp)
%                 pat='Calculate Success';
                pat='Calculate finish. Press enter.';
                pat2='Not Converged';
                pat3='NewtonRaphsonMethod';
                pat4='Press any key to exit.';
                
                if contains(strTemp,pat3)~=1
                    disp(strTemp)  
                end
                
                if contains(strTemp,pat2)
                    NotConvergedPT=NotConvergedPT+1;
                end
                
                if string(strTemp)==string(pat) || string(strTemp)==string(pat4)
                    WhileIdx=0;
                    wsh.AppActivate(ExeSwIdx); 
                    wsh.AppActivate(ExeSwIdx); 
                    wsh.AppActivate(ExeSwIdx);     
                    pause(0.5)
                    wsh.SendKeys('~');
                    pause(0.5)
                    wsh.AppActivate(ExeSwIdx);
                    wsh.AppActivate(ExeSwIdx);
                    wsh.AppActivate(ExeSwIdx);
                    pause(2)
                    wsh.SendKeys('exit~');
                    cd(OrgFolder)
                    SolverRunDoneFlag=1;
                    SolverRunPath=UserPath;
                    clc
                end
            end
        end
    end
    
    
else
    
    % simulation condition not safisfy -> do not run !!
    SimEndCnt=string(datetime('now'));
    cd(OrgFolder)
    SolverRunDoneFlag=0;
    SolverRunPath=UserPath;
    
    clc

    SolverRunDoneFlag=0;
    SolverRunPath=UserPath;
    clc
    cd(OrgFolder)
    disp('Please Check the STRobotInfo.txt File') 
      
end

if IsSimOk~=1
    SimRes='Failed!! (Check the RobotInfo.txt File)';
elseif SolverRunDoneFlag==0
    SimRes='Failed!!';
elseif NotConvergedPT>1
    SimRes='Failed!! (Solver not Converged)';
elseif SolverRunDoneFlag==1
    SimRes='Success!!';
end
    
SimEndCnt=string(datetime('now'));

ColliPosCnt=max(SimCondIdx(:,1));

UserName = char(java.lang.System.getProperty('user.name'));
HostName = char(java.net.InetAddress.getLocalHost.getHostName);

fileID = fopen(strcat(UserPath, '\', 'Simulation Summary.txt'), 'w');
fprintf(fileID, '============== Simulation Results ==============');
fprintf(fileID, '\r\n');
fprintf(fileID, '\r\n');
fprintf(fileID, '1. Simulation Start Time : %s\n', SimStartCnt);
fprintf(fileID, '\r\n');
fprintf(fileID, '2. Simulation End Time : %s\n ', SimEndCnt);
fprintf(fileID, '\r\n');
fprintf(fileID, '3. Safety Core Ver. : %s\n', SolverVer);
fprintf(fileID, '\r\n');
fprintf(fileID, '4. Matlab Code Ver. : %s\n', MatlabCodeVer);
fprintf(fileID, '\r\n');
fprintf(fileID, '5. Used Computer Name : %s\n', HostName);
fprintf(fileID, '\r\n');
fprintf(fileID, '6. Analysis by : %s\n', UserName);
fprintf(fileID, '\r\n');
fprintf(fileID, '7. Colli. Body : %s\n',ColliBody);
fprintf(fileID, '\r\n');
% fprintf(fileID, '8. Colli.B.Cloth : %s\n',ColliBodyCloth);
% fprintf(fileID, '\r\n');
fprintf(fileID, '9. # of Non-Converged Points : %s\n',num2str(NotConvergedPT));
fprintf(fileID, '\r\n');
fprintf(fileID, '10. Condition Verifying Results : %s\n',SimRes);
        
if ColliPosCnt>0
    for i=1:ColliPosCnt
        fprintf(fileID, '\r\n');
        fprintf(fileID, ['  ', num2str(SimCondIdx(i,1)),') Colli Pos. # ',num2str(SimCondIdx(i,1)),'\r\n']);
        
        % Overall
        if SimCondIdx(i,5)==1
            msg=['      - The condition for Colli. Pos ', num2str(i), ' OK'];
            fprintf(fileID, [msg,'\r\n']);
        else
            msg=['      - The condition for Colli. Pos ', num2str(i), ' Error'];
            fprintf(fileID, [msg,'\r\n']);
        end
        
        if ((SimCondIdx(i,6)==1) | (SimCondIdx(i,6)==5) | (SimCondIdx(i,6)==8))
            fprintf(fileID, ['      - Shape  : ', num2str(SimCondIdx(i,6)),' (OK)','\r\n']);
        else
            fprintf(fileID, ['      - Shape  : ', num2str(SimCondIdx(i,6)),' (Error)','\r\n']); 
        end
        
        % radius
        if SimCondIdx(i,2)==1
            msg=['      - Radius : ', num2str(SimCondIdx(i,7)),' (OK)'];
            fprintf(fileID, [msg,'\r\n']);
        else
            shapeInfo = SimCondIdx(i,6);
             switch shapeInfo
                case 1
                    msg=['      - Radius : ', num2str(SimCondIdx(i,7)),' (Exceed the range) --> ', num2str(BoundaryC(1,1)), ' < Radius < ',num2str(BoundaryC(1,2))];
                case 5
                    msg=['      - Radius : ', num2str(SimCondIdx(i,7)),' (Exceed the range) --> ', num2str(BoundaryC(1,5)), ' < Radius < ',num2str(BoundaryC(1,6))];
                case 8 %corner edge
                    msg=['      - Radius : ', num2str(SimCondIdx(i,7)),' (Exceed the range) --> Radius must be set as a zero when shape ',num2str(shapeInfo)];
                 otherwise
                    msg=['      - Radius : ', num2str(SimCondIdx(i,7)),' (Exceed the range) --> Not Avaialable or Not defined'];
             end
             fprintf(fileID, [msg,'\r\n']);
        end
        
        % Fillet
        if SimCondIdx(i,3)==1
            msg=['      - Fillet : ', num2str(SimCondIdx(i,8)),' (OK)'];
            fprintf(fileID, [msg,'\r\n']);
        else
             shapeInfo = SimCondIdx(i,6);
             switch shapeInfo
                case 1
                    msg=['      - Fillet : ', num2str(SimCondIdx(i,8)),' (Exceed the range) --> Fillet must be set as a zero when shape ',num2str(shapeInfo)];
                case 5
                    msg=['      - Fillet : ', num2str(SimCondIdx(i,8)),' (Exceed the range) --> ', num2str(BoundaryC(1,7)), ' < Fillet < ',num2str(BoundaryC(1,8))];
                case 8 %corner edge
                    msg=['      - Fillet : ', num2str(SimCondIdx(i,8)),' (Exceed the range) --> ', num2str(BoundaryC(1,11)), ' < Fillet < ',num2str(BoundaryC(1,12))];
                 otherwise
                    msg=['      - Fillet : ', num2str(SimCondIdx(i,8)),' (Exceed the range) --> Not Avaialable or Not defined'];
             end
            fprintf(fileID, [msg,'\r\n']);
        end
        
        if (SimCondIdx(i,7)-SimCondIdx(i,8))>0
            % state -> OK
        else
            msg=['      - Warnning!! : Fillet must be less than Radius',' (Radius : ',num2str(SimCondIdx(i,7)),' < ','Fillet : ',num2str(SimCondIdx(i,8))];
            fprintf(fileID, [msg,'\r\n']);
        end
        % Cover
        if SimCondIdx(i,4)==1
            msg=['      - Cover  : ', num2str(SimCondIdx(i,9)),' (OK)'];
        else
            msg=['      - Cover  : ', num2str(SimCondIdx(i,9)),' (Exceed the range) --> ', num2str(BoundaryC(1,13)), '< Cover < ',num2str(BoundaryC(1,14))];
        end
        fprintf(fileID, [msg,'\r\n']);
        
        % else
    end
    cd(OrgFolder)
    fclose(fileID);
end

fileID  = fopen(strcat(UserPath, '\', 'Simulation Summary.txt'));
disp(' ')
disp(' ')
while ~feof(fileID)
    tline = fgetl(fileID);
    disp(tline)
end
fclose(fileID);

disp(' ')
disp(' ')

try
    system('taskkill /F /IM cmd.exe');
catch
    
end

beepbeep([0.2 0.2])
end

