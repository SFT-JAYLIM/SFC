% function ResReArrange

UserPath='D:\OneDrive\SAFETICS\03_consulting\2022\18_현진제업\02_해석결과\1_Type_A_Head_nocover';
fn='\KHU_Collision_Risk_Analyze_Result.csv';

%Header group -> First Row of Solver Results data
HeaderGroup=["Unix_Time_Hour";"Unix_Time_Min";"Unix_Time_Sec";"Elapse";
"Time";"q";"EffectiveMass";"ImpactVelNorm";"ImpactVelDirNorm";"ImpactVelAlphaNorm";
"Force";"Pressure";"MaxCRI";"CRI";"MaxModiCRI";"ModiCRI";"ImpactPosList";
"BoxInOutIndex";"AssignBoxIndex";"OverlappedBoxIndex";"MinScale";"Scale";
"MinModiScale";"ModiScale";"ColliAlpha";"BasePosition";];

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
    '#2d4fc8';'#b753a0';'#e362b9';'#7057a9';'#9edd71';'#13e86d';'#8fcecd';
    '#e3ad54';'#f86430';'#edd8f7'};

ResDataPath=[UserPath fn];
org=importdata(ResDataPath);
% RobotInfo = Set_RobotInfo(UserPath);
% robotmodel=RobotInfo.RobotModel;
pathfilename = [UserPath,'\ST_RobotInfo.txt'];
fileID = fopen(pathfilename,'r');
in_data_cell = textscan(fileID,'%s');
in_data = (in_data_cell{1,1});

% 로봇 이름
RobotModelidx=find(contains(in_data, '#RobotModel'));
if isempty(RobotModelidx)
    RobotInfo.RobotModel = strings(0);
else
    RobotInfo.RobotModel = cell2mat(in_data(RobotModelidx(1)+1));
end

% BaseModel
BaseModelidx=find(contains(in_data, '#BaseModel'));
if isempty(BaseModelidx)
    RobotInfo.BaseModel = strings(0);
else
    RobotInfo.BaseModel = cell2mat(in_data(BaseModelidx(1)+1));
end

% 협동공간
CLBidx_mat = strfind(in_data,['#ColliBody']);
CLBCLOidx_mat = strfind(in_data,['Cloth']);
CLBidx = find(not(cellfun('isempty',CLBidx_mat)));
CLBCLOidx = find(not(cellfun('isempty',CLBCLOidx_mat)));
RobotInfo.numColliBody = size(CLBidx,1)-size(CLBCLOidx,1);

for loop = 1:RobotInfo.numColliBody
    switch loop
        case loop == 1
            RobotInfo.ColliBody = cell2mat(in_data(CLBidx(loop)+1));
            ColliBody=RobotInfo.ColliBody;
        otherwise
%             RobotInfo.ColliBody = [RobotInfo.ColliBody '%' cell2mat(in_data(CLBidx(loop)+1))];
    end
end

header=org.colheaders;
NumofColliPos=sum(contains(org.colheaders,'EffectiveMass'));

LegendIndex=strings(1,NumofColliPos);
for i=1:NumofColliPos
        LegendIndex(i)=['Point#',num2str(i)];
end

pathfilename = [UserPath,'\ST_RobotInfo.txt'];
fileID = fopen(pathfilename,'r');
in_data_cell = textscan(fileID,'%s');
in_data = (in_data_cell{1,1});

% mobile or not
isMobileRobot=in_data(find(strcmp(in_data,'#MobileBase') == true)+1);

% Get target robot name
TargetRobot=char(in_data(find(strcmp(in_data,'#RobotModel') == true)+1));

% select the analysis criterion
if cell2mat(in_data(find(strcmp(in_data,'#BodyProperty'))))
    BodyProperties=in_data(find(strcmp(in_data,'#BodyProperty') == true)+1);
else
    BodyProperties={'BOTH'};
end

SolverResFileName1='\ISO_Collision_Risk_Analyze_Result.csv';
SolverResFileName2='\KHU_Collision_Risk_Analyze_Result.csv';

if fn==SolverResFileName1
    if isfolder([UserPath,'\graph\ISO'])~=1
        mkdir([UserPath,'\graph\ISO']);
        savefolder=[UserPath,'\graph\ISO\'];
    else
        savefolder=[UserPath,'\graph\ISO\'];
    end
else
    if isfolder([UserPath,'\graph\KHU'])~=1
        mkdir([UserPath,'\graph\KHU']);
        savefolder=[UserPath,'\graph\KHU\'];
    else
        savefolder=[UserPath,'\graph\KHU\'];
    end
end

%% calculate the collision points on robot
if cell2mat(isMobileRobot)=='1'
    PTsOnRobot=0;
elseif contains(TargetRobot,'UR')
    PTsOnRobot=7;
else
    PTsOnRobot=6;    
end

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

HeaderName='CRI';
HeaderRow=find(strcmp(HeaderGroup,HeaderName) == true);
%% single column variable
HeaderName='Time';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
t=org.data(:,Scol);

HeaderName='MaxCRI';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
MaxCRI=org.data(:,Scol);

HeaderName='MaxModiCRI';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
MaxModiCRI=org.data(:,Scol);

HeaderName='MinScale';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
MinScale=org.data(:,Scol);

HeaderName='MinModiScale';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
MinModiScale=org.data(:,Scol);

%% multi column variable
HeaderName='EffectiveMass';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
EffectiveMass=org.data(:,Scol:Ecol);

HeaderName='CRI';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
CRI=org.data(:,Scol:Ecol);

HeaderName='ImpactVelNorm';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
ImpactVelNorm=org.data(:,Scol:Ecol);

HeaderName='Force';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
Force=org.data(:,Scol:Ecol);

HeaderName='Pressure';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
Pressure=org.data(:,Scol:Ecol);

HeaderName='ModiCRI';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
ModiCRI=org.data(:,Scol:Ecol);

HeaderName='AssignBoxIndex';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
AssignBoxIndex=org.data(:,Scol:Ecol);

HeaderName='ModiScale';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
ModiScale=org.data(:,Scol:Ecol);
% end

DangerFiledInfo=[];
DangerPoints=[];

for i=1:NumofColliPos
    A=ModiCRI(:,i);
    B=find(A>1); % find the index of Data Points that has CRI-value larger than 1
    if isempty(B)~=1 % if matrix B is not empty
        for j=1:length(B)
            DangerPoints(j,1)=t(B(j)); %time
            DangerPoints(j,2)=i; % ColliPos Number
            DangerPoints(j,3)=AssignBoxIndex(B(j),i); % Hspace No.
            DangerPoints(j,4)=CRI(B(j),i); % CRI Value
            DangerPoints(j,5)=ModiScale(B(j),i); % Scale Value           
        end
        
        DangerFiledInfo=[DangerFiledInfo;DangerPoints];
        
    else
        
    end
        
end
