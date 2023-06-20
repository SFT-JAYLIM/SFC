% try

    gSeqData=[];
    gSeqData.ErrCode=[];
    gSeqData.ErrMsg=[];
    gSeqData.SolverTimeOut=10;
    ScripRunPathTemp = matlab.desktop.editor.getActiveFilename;
    TempIdx=find(ScripRunPathTemp=='\');
    gSeqData.FolderInfo.CurrentPath=ScripRunPathTemp(1:max(TempIdx)-1);
    gSeqData.FolderInfo.AppDataPath='..\..\..\InputData';
    gSeqData.FolderInfo.CorePath='..\..\..\SafetyCore';
    gSeqData.FolderInfo.PlotCRIPath='..\..\';
    gSeqData.Visible=true;
    
    
    defaultPath='D:\JayLim\OneDrive\SAFETICS\03_consulting\2023';
    RootPath='c:';

    % Text UI setup

    gSeqData.TaskIdx = 0;
    whileidx=1;

    while whileidx
        switch gSeqData.TaskIdx
            case 0 
                gSeqData.CalculationSuccess=false;
                gSeqData.PlotCRIDone=false;

                cd(gSeqData.FolderInfo.CurrentPath);
                clc
                close all
                disp('Welcome the Safetics Consulting Batch!! Select the task Do you want!!')
                disp(' ')
                disp('    01. RUNNING THE SOLVER')
                disp(' ')
                disp('    02. RESULTS GRAPH GENERATION')
                disp(' ')
                disp('    03. PLOT_CRI')
                disp(' ')
                disp('    04. REPORT GENERATION')
                disp(' ')
                disp('    05. ONE STEP PROCESS FOR SOLVER TO REPORT')
                disp(' ')
                disp('    06. ONE CYCLE OF SOLVER, GRAPH, PLOT CRI')
                disp(' ')
                disp('    11. SOLVER MULTI RUN')
                disp(' ')
                disp('    22. GRAPH GENERATING MULTI RUN')
                disp(' ')
                disp('    33. PLOT CRI MULTI RUN')
                disp(' ')
                disp('    44. REPORT GENERATION MULTI RUN')
                disp(' ')
                disp('    55. ONE STEP PROCESS FOR SOLVER TO REPORT MULTI')
                disp(' ')
                disp('    66. SOLVER - GRAPH - PLOT CRI SET MULTI RUN')
                disp(' ')          
                disp('    70. SOLVER - GRAPH SET" MULTI RUN')
                disp(' ')
                disp('    80. ONE STEP PROCESS (SOLVER TO REPORT with SAFETY_VELOCITY)')
                disp(' ')
                disp('    99. EXIT')
                disp(' ')
                gSeqData.TaskIdx=input('which Task? = ');

                if isnumeric(gSeqData.TaskIdx)~=1
                    gSeqData.TaskIdx=999;
                else

                end

                clc

            case 1 % RUNNING THE SOLVER
                try
                    if isfolder(defaultPath)
                        gSeqData.FolderInfo.UserPath=uigetdir(defaultPath);   
                    else
                        gSeqData.FolderInfo.UserPath=uigetdir([RootPath,'\']);
                    end
    
                    if gSeqData.FolderInfo.UserPath==0
                        gSeqData.TaskIdx=100;
                    else
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData=RunSolver(gSeqData);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end
                

            case 2 % RESULTS GRAPH GENERATION
                try
                    if isfolder(defaultPath)
                        gSeqData.FolderInfo.UserPath=uigetdir(defaultPath);   
                    else
                        gSeqData.FolderInfo.UserPath=uigetdir([RootPath,'\']);
                    end
    
                    if gSeqData.FolderInfo.UserPath==0
                        gSeqData.TaskIdx=100;
                    else
                        % Statement
                        cd(gSeqData.FolderInfo.CurrentPath);
                        setBodyProperty(gSeqData, 'KHU')
                        gSeqData=Graph_Batch(gSeqData);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end
                

            case 3 % PLOT_CRI
                try
                    if isfolder(defaultPath)
                        gSeqData.FolderInfo.UserPath=uigetdir(defaultPath);   
                    else
                        gSeqData.FolderInfo.UserPath=uigetdir([RootPath,'\']);
                    end
    
                    if gSeqData.FolderInfo.UserPath==0
                        gSeqData.TaskIdx=100;
                    else
                        % Statement
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData=Plot_CRI_Batch(gSeqData);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

            case 4 % REPORT GENERATION
                try
                     if isfolder(defaultPath)
                        gSeqData.FolderInfo.UserPath=uigetdir(defaultPath);   
                    else
                        gSeqData.FolderInfo.UserPath=uigetdir([RootPath,'\']);
                    end
    
                    if gSeqData.FolderInfo.UserPath==0
                        gSeqData.TaskIdx=100;
                    else
                        cd(gSeqData.FolderInfo.CurrentPath);
                        Status=AutoReport_SFD(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.AppDataPath);
                        gSeqData.TaskIdx=0;       
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

            case 5 % ONE STEP PROCESS (SOLVER TO REPORT)
                try
                    if isfolder(defaultPath)
                        gSeqData.FolderInfo.UserPath=uigetdir(defaultPath);   
                    else
                        gSeqData.FolderInfo.UserPath=uigetdir([RootPath,'\']);
                    end
    
                    if gSeqData.FolderInfo.UserPath==0
                        gSeqData.TaskIdx=100;
                    else
                        %statement
                        cd(gSeqData.FolderInfo.CurrentPath);
                        try
                            gSeqData=RunSolver(gSeqData);
                        catch
                            gSeqData.TaskIdx=0;
                        end

                        if gSeqData.CalculationSuccess
                            cd(gSeqData.FolderInfo.CurrentPath);
                            gSeqData=Plot_CRI_Batch(gSeqData);
                        end

                        if gSeqData.PlotCRIDone
                            cd(gSeqData.FolderInfo.CurrentPath);
                            Status=AutoReport_SFD(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.AppDataPath);
                        end

                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

            case 6 % ONE CYCLE OF SOLVER, GRAPH, PLOT CRI EACH
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            % statement
                            cd(gSeqData.FolderInfo.CurrentPath);
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end
                

            case 11 % SOLVER MULTI RUN
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            gSeqData=RunSolver(gSeqData);
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end


            case 22 % GRAPH GENERATING MULTI RUN
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            %statement -> function for graph generating
                            cd(gSeqData.FolderInfo.CurrentPath);
                            setBodyProperty(gSeqData, 'KHU')
                            gSeqData=Graph_Batch(gSeqData);
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

                

            case 33 % PLOT CRI MULTI RUN
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            gSeqData=Plot_CRI_Batch(gSeqData);
                            cd(gSeqData.FolderInfo.CurrentPath);
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

            case 44 % REPORT GENERATION MULTI
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            % statement
                            cd(gSeqData.FolderInfo.CurrentPath);
                            Status=AutoReport_SFD(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.AppDataPath);
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

            case 55 % ONE STEP PROCESS MULTI (SOLVER TO REPORT MULTI)
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            %statement
                            cd(gSeqData.FolderInfo.CurrentPath);
                            try
                                gSeqData=RunSolver(gSeqData);
                            catch
                                gSeqData.TaskIdx=0;
                            end
    
                            if gSeqData.CalculationSuccess
                                cd(gSeqData.FolderInfo.CurrentPath);
                                gSeqData=Plot_CRI_Batch(gSeqData);
                            end
    
                            if gSeqData.PlotCRIDone
                                cd(gSeqData.FolderInfo.CurrentPath);
                                Status=AutoReport_SFD(gSeqData.FolderInfo.UserPath, gSeqData.FolderInfo.AppDataPath);
                            end
    
                            gSeqData.TaskIdx=0;
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

            case 66 % BATCH PROCESS 6 - ("SOLVER - GRAPH - PLOT CRI SET" MULTI RUN)
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            % statement
                            cd(gSeqData.FolderInfo.CurrentPath);
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end


            case 70 % SOLVER - GRAPH SET" MULTI RUN
                try
                    if isfolder(defaultPath)
                        [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile([RootPath,'\selectfile.txt']);
                    end
    
                    if pn==0
                        gSeqData.TaskIdx=100;
                    else
                        org=importdata([pn fn]);
                        [m n]=size(org);
    
                        for i=1:m
                            UserPathTemp=org(i,1);
                            gSeqData.FolderInfo.UserPath=cell2mat(UserPathTemp);
                            % statement
                            cd(gSeqData.FolderInfo.CurrentPath);
                            clc
                        end
                        cd(gSeqData.FolderInfo.CurrentPath);
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end


            case 80 % ONE STEP PROCESS (SOLVER TO REPORT with SAFETY_VELOCITY)')
                try
                    if isfolder(defaultPath)
                        gSeqData.FolderInfo.UserPath=uigetdir(defaultPath);   
                    else
                        gSeqData.FolderInfo.UserPath=uigetdir([RootPath,'\']);
                    end
    
                    if gSeqData.FolderInfo.UserPath==0
                        gSeqData.TaskIdx=100;
                    else
                        % statement
                        gSeqData.TaskIdx=0;
                    end
                catch
                    gSeqData.TaskIdx=0;
                end

            case 99 % EXIT
                close all
                clear all
                clc
                gSeqData.TaskIdx=0;
                whileidx=0;

            case 100 %not select the folder
                clc
                disp('Folder or file was not selected!! Go back to the main menu')
                disp('Please, press any key!!')
                pause
                gSeqData.TaskIdx=0;

            otherwise                
                disp('Wrong input, Please press any key to go back to the main')
                pause;
                gSeqData.TaskIdx=0;
                whileidx=1;
        end
    end
    
    clear all
    clc


% catch exception

%     cd(OriginPath);
%     disp(['Failed at ',UserPath]);
%     Idx=find(UserPath=='\');
%     for i=1:length(Idx)
%         UserPath(Idx(i))=char(47);
%     end
%     
%     [m n]=size(exception.stack);
%     for i=1:m
%          disp(['[Status] = Function name : ', exception.stack(i).name]);
%          disp(['[Status] = Line : ', num2str(exception.stack(i).line)]);
%     end
%         disp(['[Status] = Error message: ', exception.message]);
    

% end
