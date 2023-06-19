function isBatchDone=Batch_proc1(UserPath,AppDataPath,Timeout)

clc
SolverRunDoneFlag=0;
isBatchDone=0;
% Running the solver
temp=dir('../');
SolverIdx=find(not(cellfun('isempty',strfind({temp.name},'SafetyCore_v'))));
MatlabVerIdx=find(not(cellfun('isempty',strfind({temp.name},'Matlab'))));
SolverFilePath=['../' char(temp(SolverIdx).name)];

% solver and matlab version check
SolverVer=char(temp(SolverIdx).name);
MatlabCodeVer=char(temp(MatlabVerIdx).name);
clc

if isfile(SolverFilePath)
    [SolverRunPath SolverRunDoneFlag IsSimOk SimCondIdx] = RunSolver(UserPath,SolverVer,MatlabCodeVer,Timeout);
end

if SolverRunDoneFlag==1
    pathfilename = [UserPath,'\ST_RobotInfo.txt'];
    fileID = fopen(pathfilename,'r');
    in_data_cell = textscan(fileID,'%s');
    in_data = (in_data_cell{1,1}); 
    % mobile or not
    isMobileRobot=in_data(find(strcmp(in_data,'#MobileBase') == true)+1);
    
    % Get target robot name
    TargetRobot=char(in_data(find(strcmp(in_data,'#RobotModel') == true)+1));
    
    SolverResFileName1='\ISO_Collision_Risk_Analyze_Result.csv';
    SolverResFileName2='\KHU_Collision_Risk_Analyze_Result.csv';  
    
    % select the analysis criterion
    if cell2mat(in_data(find(strcmp(in_data,'#BodyProperty'))))
        BodyProperties=in_data(find(strcmp(in_data,'#BodyProperty') == true)+1);
    else
        BodyProperties={'BOTH'};
    end
    
    if length(cell2mat(BodyProperties))==4 % both
        fn=SolverResFileName1;
        Makeallgraph(UserPath, fn);
        fn=SolverResFileName2;
        Makeallgraph(UserPath, fn);
        
    elseif cell2mat(BodyProperties)=='ISO' % ISO
        fn=SolverResFileName1;
        Makeallgraph(UserPath, fn);
    else
        fn=SolverResFileName2; %KHU
        Makeallgraph(UserPath, fn);
    end
    
%     Makeallgraph(UserPath, fn);
    Plot_CRI(UserPath, AppDataPath);
    
    isBatchDone=1;
else
    isBatchDone=0;
    
end

clc

end