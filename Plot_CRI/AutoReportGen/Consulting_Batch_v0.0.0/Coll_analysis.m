try
    % initiallizing
    clear all
    close all
    clc

    defaultPath='D:\OneDrive\SAFETICS\03_consulting\2022\';
    defaultPath2='C:\Users\shatt\OneDrive\SAFETICS\03_consulting\2022\';
    RootPath='c:\';

    SolverRunDoneFlag=[];
    SolverRunPath=[];
    StepNumber=0;
    Timeout=10;

    AppDataPath=('../inputdata/');      
    RptDataPath=('../Report_gen\format/');

    Temp=dir([AppDataPath,'\STL']);
    RobotModel={Temp.name};
    [m n]=size(RobotModel);
    RobotList=RobotModel(3:n);

    clear Temp, clear RobotModel, clear m, clear n

    SolverResFileName1='ISO_Collision_Risk_Analyze_Result.csv';
    SolverResFileName2='KHU_Collision_Risk_Analyze_Result.csv';  

    OriginPath=cd;

    % Text UI setup

    TaskIdx = 0;
    whileidx=1;

    while whileidx
        switch TaskIdx
            case 0
                cd(OriginPath);
                clc
                close all
                disp(' ')
                disp('Welcome the Safetics Consulting solver package!! Select the task Do you want!!')
                disp(' ')
                disp('    01. RUNNING THE SAFETYCORE SOLVER')
                disp(' ')
                disp('    02. FIND THE COLLISION POINTS')
                disp(' ')
                disp('    03. RESULTS GRAPH GENERATION')
                disp(' ')
                disp('    04. PLOT_CRI')
                disp(' ')
                disp('    05. BATCH PROCESS 1 - (ONE CYCLE OF SOLVER, GRAPH, PLOT CRI EACH)')
                disp(' ')
                disp('    06. BATCH PROCESS 2 - (SOLVER MULTI RUN)')
                disp(' ')
                disp('    07. BATCH PROCESS 3 - (GRAPH GENERATING MULTI RUN)')
                disp(' ')
                disp('    08. BATCH PROCESS 4 - (PLOT CRI MULTI RUN)')
                disp(' ')
                disp('    09. BATCH PROCESS 5 - ("SOLVER - GRAPH SET" MULTI RUN)')
                disp(' ')
                disp('    10. BATCH PROCESS 6 - ("SOLVER - GRAPH - PLOT CRI SET" MULTI RUN)')
                disp(' ')
                disp('    20. GENERATE THE SPLIT IMAGE')
                disp(' ')
                disp('    30. REPORT GENERATION')
                disp(' ')
                disp('    31. REPORT GENERATION MULTI')
                disp(' ')
                disp('    40. ONE STEP PROCESS (SOLVER TO REPORT)')
                disp(' ')
                disp('    50. ONE STEP PROCESS MULTI (SOLVER TO REPORT MULTI)')
                disp(' ')
                disp('    99. EXIT')
                disp(' ')

                TaskIdx=input('which Task? = ');

                if isnumeric(TaskIdx)~=1
                    TaskIdx=999;
                else

                end

                clc

            case 1 %Running the Safety Core
                disp('You Choose the "running the SafetyCore"')
                disp(' ')
                disp('Please press the "Any Key" to progress')
                pause;

                if isfolder(defaultPath)
                    UserPath=uigetdir(defaultPath);   
                else
                    if isfolder(defaultPath2)
                        UserPath=uigetdir(defaultPath2); 
                    else
                        UserPath=uigetdir('c:\');
                    end
                end

                if UserPath==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else

                    clc
                    SolverRunDoneFlag=0;
                    % Running the solver
                    temp=dir('../');
                    SolverIdx=find(not(cellfun('isempty',strfind({temp.name},'SafetyCore_v'))));
                    MatlabVerIdx=find(not(cellfun('isempty',strfind({temp.name},'Matlab'))));

                    SolverFilePath=['../' char(temp(SolverIdx).name)];

                    % solver and matlab version check
                    SolverVer=char(temp(SolverIdx).name);
                    MatlabCodeVer=char(temp(MatlabVerIdx).name);

                    disp('----- simulation condition summary -----')
                    disp(['1. SafetyCore Version : ', SolverVer])
                    disp(' ')
                    disp(['2. MatlabCodeVersion : ', MatlabCodeVer])
                    disp(' ')
                    disp(['3. Robot and Motion Information Folder :', UserPath])
                    disp(' ')
                    disp(['Please press the "Any Key" to running the solver'])
                    disp(' ')
                    pause

                    clc

                    if isfile(SolverFilePath)
                       [SolverRunPath SolverRunDoneFlag IsSimOk SimCondIdx] = RunSolver(UserPath,SolverVer,MatlabCodeVer,Timeout);
    %                    [SolverRunPath SolverRunDoneFlag IsSimOk SimCondIdx] = RunSolver(UserPath,SolverVer,MatlabCodeVer,Timeout)
                    end

                    if SolverRunDoneFlag==0
                        disp('Simulation Failed!!')
                        disp('Press the Any key, Please!!')
                        pause
                    else
                        disp('Simulation Done')
                        disp(' ')
                        disp('Please, press the "Any Key"')
                        pause
                    end
                end

                TaskIdx=0;
                cd(OriginPath);

            case 2 %Find the Collision Points
                disp('You Choose the "Find the Collision Points"')
                disp(' ')
                disp('Please press the "Any Key" to progress')
                pause;
                clc

                if SolverRunDoneFlag
                    clc
                    disp('Select the menu')
                    disp(' ')
                    disp('   1. Open the folder that saved just before ')
                    disp(' ')
                    disp('   2. Select the specific folder ')
                    disp(' ')
                    ColliPosIdx=input('Which Task ? = ');
                else
                    disp('Select the specific folder')
                    ColliPosIdx=2;
                    clc
                end

                switch ColliPosIdx
                    case 1
                        UserPath=SolverRunPath;
                        SolverResFileName1='ISO_Collision_Risk_Analyze_Result.csv';
                        SolverResFileName2='KHU_Collision_Risk_Analyze_Result.csv';  
                        fn=SolverResFileName2;
                    case 2
                        SolverRunDoneFlag=[];
                        SolverRunPath=[];
                        if isfolder(defaultPath)
                            UserPath=uigetdir(defaultPath);   
                        else
                            if isfolder(defaultPath2)
                                UserPath=uigetdir(defaultPath2); 
                            else
                                UserPath=uigetdir('c:\');
                            end
                        end

                    otherwise
                        break;
                end

                if UserPath==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else
                    AppDataPath=('../inputdata/');          
                    Find_ColliPos(UserPath, AppDataPath)
                    clc, disp('Please press the "Any Key" to progress')
                    pause;
                    clc; close all

                end

                TaskIdx=0;
                cd(OriginPath);

            case 3 %Result Graph Generation
                clc
                disp('You Choose the "Result Graph Generation"')
                disp(' ')
                disp('Please press the "Any Key" to progress')
                pause;
                clc

                if SolverRunDoneFlag
                    clc
                    disp('Select the menu')
                    disp(' ')
                    disp('   1. Open the folder that saved just before ')
                    disp(' ')
                    disp('   2. Select the specific folder ')
                    disp(' ')
                    ColliPosIdx=input('Which Task ? = ')
                else
                    disp('Select the specific folder')
                    ColliPosIdx=2;
                    clc
                end

                switch ColliPosIdx
                    case 1
                        UserPath=SolverRunPath;
                        SolverResFileName1='ISO_Collision_Risk_Analyze_Result.csv';
                        SolverResFileName2='KHU_Collision_Risk_Analyze_Result.csv';  

                        if isfile([UserPath,'\',SolverResFileName1])
                            fn=['\',SolverResFileName1];
                        else
                            fn=['\',SolverResFileName2];
                        end

                    case 2
                        SolverRunDoneFlag=[];
                        SolverRunPath=[];
                        if isfolder(defaultPath)
                            [fn UserPath]=uigetfile([defaultPath,'\selectfile.csv']);
                            fn=['\',fn];
                        else
                            if isfolder(defaultPath2)
                                [fn UserPath]=uigetfile([defaultPath2,'\selectfile.csv']);
                                fn=['\',fn];
                            else
                                [fn UserPath]=uigetfile('C:\selectfile.csv');
                                fn=['\',fn];
                            end
                        end

                    otherwise
                        break;
                end

       % essential information load
                if UserPath==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else
                    Temp=dir([AppDataPath,'\STL']);
                    RobotModel={Temp.name};
                    [m n]=size(RobotModel);
                    RobotList=RobotModel(3:n);

                    clear Temp, clear RobotModel, clear m, clear n
   
                    AppDataPath=('../inputdata/');

                    Makeallgraph(UserPath, fn);

                    disp('Please press the "Any Key" to progress')
                    pause;
                end

                TaskIdx=0;
                cd(OriginPath);

            case 4 %Collision Analysis result movie Generation : PLOT_CRI
                disp('You Choose the PLOT_CRI(Collision Analysis result movie Generation)')
                disp(' ')
                disp('Please press the "Any Key" to progress')
                pause;
                clc

                if SolverRunDoneFlag
                    clc
                    disp('Select the menu')
                    disp(' ')
                    disp('   1. Open the folder that saved just before ')
                    disp(' ')
                    disp('   2. Select the specific folder ')
                    disp(' ')
                    ColliPosIdx=input('Which Task ? = ')
                else
                    disp('Select the specific folder')
                    ColliPosIdx=2;
                    clc
                end

                switch ColliPosIdx
                   case 1
                       UserPath=SolverRunPath;
                       SolverResFileName1='ISO_Collision_Risk_Analyze_Result.csv';
                       SolverResFileName2='KHU_Collision_Risk_Analyze_Result.csv';  
                        fn=SolverResFileName2;
                   case 2
                       if isfolder(defaultPath)
                           UserPath=uigetdir(defaultPath);
                       else
                           if isfolder(defaultPath2)
                               UserPath=uigetdir(defaultPath2);
                           else
                               UserPath=uigetdir('c:\');
                           end
                       end

                   otherwise
                       break;
                end

                if UserPath==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else

                    AppDataPath=('../inputdata/');           
                    Plot_CRI(UserPath, AppDataPath)
                    clc
                    disp('Please press the "Any Key" to progress')
                    pause;
                    clc; close all
                end

                TaskIdx=0;
                cd(OriginPath);

            case 5 %BATCH PROCESS 1 - (ONE CYCLE OF SOLVER, GRAPH, PLOT CRI EACH)
                if isfolder(defaultPath)
                    UserPath=uigetdir(defaultPath);   
                else
                    if isfolder(defaultPath2)
                        UserPath=uigetdir(defaultPath2); 
                    else
                        UserPath=uigetdir('c:\');
                    end
                end

                if UserPath==0
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                else
                    Batch_proc1(UserPath,AppDataPath,Timeout);
                end
                TaskIdx=0;
                cd(OriginPath);

            case 6 %BATCH PROCESS 2 - (SOLVER MULTI RUN)

                cd(OriginPath);

                if isfolder(defaultPath)
                    [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                else
                    if isfolder(defaultPath2)
                        [fn pn]=uigetfile([defaultPath2,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile('c:\selectfile.txt');
                    end
                end

                if pn==0
                    % true statement!!
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause
                else

                    org=importdata([pn fn]);
                    [m n]=size(org);

                    for i=1:m
                        UserPathTemp=org(i,1);
                        UserPath=cell2mat(UserPathTemp);
                        Batch_proc2(UserPath,AppDataPath,Timeout);
                    end
                end

                cd(OriginPath);
                TaskIdx=0;

            case 7 %BATCH PROCESS 3 - (GRAPH GENERATING MULTI RUN)
                cd(OriginPath);

                if isfolder(defaultPath)
                    [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                else
                    if isfolder(defaultPath2)
                        [fn pn]=uigetfile([defaultPath2,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile('c:\selectfile.csv');
                    end
                end

                if pn==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause
                    cd(OriginPath);

                else

                    org=importdata([pn fn]);
                    [m n]=size(org);

                    for i=1:m
                        UserPathTemp=org(i,1);
                        UserPath=cell2mat(UserPathTemp);
                        Batch_proc3(UserPath,AppDataPath,Timeout);
                    end
                end

                cd(OriginPath);
                TaskIdx=0;

            case 8 %BATCH PROCESS 4 - (PLOT CRI MULTI RUN)
                cd(OriginPath);

                if isfolder(defaultPath)
                    [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                else
                    if isfolder(defaultPath2)
                        [fn pn]=uigetfile([defaultPath2,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile('c:\selectfile.txt');
                    end
                end

                if pn==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else
                    org=importdata([pn fn]);
                    [m n]=size(org);

                    for i=1:m
                        UserPathTemp=org(i,1);
                        UserPath=cell2mat(UserPathTemp);
                        Batch_proc4(UserPath,AppDataPath,Timeout);
                    end
                end

                cd(OriginPath);
                TaskIdx=0;

            case 9 %BATCH PROCESS 5 - "SOLVER - GRAPH SET" MULTI RUN
                cd(OriginPath);

                if isfolder(defaultPath)
                    [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                else
                    if isfolder(defaultPath2)
                        [fn pn]=uigetfile([defaultPath2,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile('c:\selectfile.txt');
                    end
                end

                if pn==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else

                    org=importdata([pn fn]);
                    [m n]=size(org);

                    for i=1:m
                        UserPathTemp=org(i,1);
                        UserPath=cell2mat(UserPathTemp);
                        Batch_proc5(UserPath,AppDataPath,Timeout);
                        close all
                    end
                end

                cd(OriginPath);
                TaskIdx=0;

            case 10 %BATCH PROCESS 6 - (SOLVER-GRAPH-PLOTCRI SET MULTI RUN)

                cd(OriginPath);

                if isfolder(defaultPath)
                    [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                else
                    if isfolder(defaultPath2)
                        [fn pn]=uigetfile([defaultPath2,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile('c:\selectfile.txt');
                    end
                end

                if pn==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else

                    org=importdata([pn fn]);
                    [m n]=size(org);

                    for i=1:m
                        UserPathTemp=org(i,1);
                        UserPath=cell2mat(UserPathTemp);
                        Batch_proc1(UserPath,AppDataPath,Timeout);
                    end
                end

                TaskIdx=0;
                cd(OriginPath);

            case 20
                
                if isfolder(defaultPath)
                    UserPath=uigetdir(defaultPath);   
                else
                    if isfolder(defaultPath2)
                        UserPath=uigetdir(defaultPath2); 
                    else
                        UserPath=uigetdir('c:\');
                    end
                end

                if UserPath==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                else
                    SaveVideoSplitImg(UserPath);
                    disp('Please press the "Any Key" to progress')
                    pause;
                    clc; close all
                end
                TaskIdx=0;
                cd(OriginPath);

            case 30

                UserPath=uigetdir(defaultPath);   

                if UserPath==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else
                    SaveVideoSplitImg(UserPath);
                    RptGenerator(UserPath, RptDataPath);
                    clc, disp('Please press the "Any Key" to progress')
                    pause;
                    clc; close all

                end

                TaskIdx=0;
                cd(OriginPath);
                
            case 31
                 cd(OriginPath);
                 SplitDone=0;
                 RunIdx=0;

                if isfolder(defaultPath)
                    [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                else
                    if isfolder(defaultPath2)
                        [fn pn]=uigetfile([defaultPath2,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile('c:\selectfile.txt');
                    end
                end

                if pn==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause
                else
                    org=importdata([pn fn]);
                    [m n]=size(org);
                    
                    for i=1:m
                        UserPathTemp=org(i,1);
                        UserPath=cell2mat(UserPathTemp)
                        SaveVideoSplitImg(UserPath);
                        RptGenerator(UserPath,RptDataPath);
                    end

                end

                TaskIdx=0;
                cd(OriginPath);
                
            case 40
                if isfolder(defaultPath)
                    UserPath=uigetdir(defaultPath);   
                else
                    if isfolder(defaultPath2)
                        UserPath=uigetdir(defaultPath2); 
                    else
                        UserPath=uigetdir('c:\');
                    end
                end

                if UserPath==0
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                else
                    isBatchDone=Batch_proc1(UserPath,AppDataPath,Timeout);
                    if isBatchDone
                        SaveVideoSplitImg(UserPath);
                        RptGenerator(UserPath,RptDataPath);
                    else
                        disp('Batch Process failed!!');
                        disp('Please, press the any key!!');
                        pause
                        clc
                        
                    end
                end
                TaskIdx=0;
                cd(OriginPath);
                
            case 50
                
                 cd(OriginPath);
                 SplitDone=0;
                 RunIdx=0;

                if isfolder(defaultPath)
                    [fn pn]=uigetfile([defaultPath,'\selectfile.txt']);
                else
                    if isfolder(defaultPath2)
                        [fn pn]=uigetfile([defaultPath2,'\selectfile.txt']);
                    else
                        [fn pn]=uigetfile('c:\selectfile.txt');
                    end
                end

                if pn==0
                    clc
                    disp('Folder or file were not selected!! Go back to the main menu')
                    disp('Please, press any key!!')
                    pause

                else

                    org=importdata([pn fn]);
                    [m n]=size(org);
                    
                    for i=1:m
                        UserPathTemp=org(i,1);
                        UserPath=cell2mat(UserPathTemp);
                        RunIdx=Batch_proc1(UserPath,AppDataPath,Timeout);
                        
                        if RunIdx
                            SplitDone=SaveVideoSplitImg(UserPath);
                        end
                        
                        if SplitDone
                            RptGenerator(UserPath,RptDataPath);
                        end
                    end
                    
%                       for i=1:m
%                          UserPathTemp=org(i,1);
%                          UserPath=cell2mat(UserPathTemp);
%                          RptGenerator(UserPath);
%                      end
                end

                TaskIdx=0;
                cd(OriginPath);               

            case 99
%                 disp('~~~~  Thank you ~~~~~')

                close all
                clear all
                clc

                TaskIdx=0;
                whileidx=0;

            otherwise
                disp('Wrong input, Please press any key to go back to the main')
                pause;
                TaskIdx=0;
                whileidx=1;

        end
    end

    clear all
    clc

    disp('~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~')
    disp('~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~')
    disp('~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~')
    disp('~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~  THANK YOU FOR USE ~~~~~')

catch exception
    
    cd(OriginPath);
    disp(['Failed at ',UserPath]);
    disp(['[Status] = Function name : ', exception.stack.name]);
    disp(['[Status] = Line : ', exception.stack.line]);
    disp(['[Status] = Error message: ', exception.message]);
    
end