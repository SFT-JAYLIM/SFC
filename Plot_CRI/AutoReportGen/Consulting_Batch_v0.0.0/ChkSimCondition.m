function [IsSimOk SimCondIdx ColliBody BoundaryC]=ChkSimCondition(Path)

clc
IsSimOk=0;
SimCondIdx=zeros(9,9);
ColliBody='None';

% Radius와 Fillet의 사용 범위
% Shape1: 5 < Radius < 1000, Fillet = 0
% Shape5: 5 < Radius < 100, 1 < Fillet < 18
% Shape8: Radius = 0, 1 < Fillet < 14

%Sphere Boundary condition
S1RMIN = 5;
S1RMAX = 1000;
S1FMIN = 0;
S1FMAX = 0;

%Cylinder fillet edge
S5RMIN = 5;
S5RMAX = 100;
S5FMIN = 1;
S5FMAX = 18;

%Corner Edge
S8RMIN= 0;
S8RMAX = 0;
S8FMIN = 1;
S8FMAX = 14;

COVERMIN = 0;
COVERMAX = 5;

BoundaryC=[S1RMIN,S1RMAX,S1FMIN,S1FMAX,S5RMIN,S5RMAX,S5FMIN,S5FMAX,S8RMIN,S8RMAX,S8FMIN,S8FMAX,COVERMIN,COVERMAX];

pathfilename = [Path,'\ST_RobotInfo.txt'];
if isfile(pathfilename)~=1
    
else
SimCondIdx=[]; 
fileID = fopen(pathfilename,'r');
in_data_cell = textscan(fileID,'%s');
in_data = (in_data_cell{1,1});

% 로봇 이름
RobotModelidx=find(strcmp(in_data,'#RobotModel') == true);
RobotInfo.RobotModel = cell2mat(in_data(RobotModelidx(1)+1));

% 충돌 부위
ColliJointidxMat=strfind(in_data,['#ColliJoint']);
ColliJointidx = find(not(cellfun('isempty',ColliJointidxMat)));
numColliJoint = size(ColliJointidx, 1);

for loop=1:numColliJoint
    RobotInfo.ColliJoint(1*(loop-1)+1)=str2double(cell2mat(in_data(ColliJointidx(loop)+1)));
end

% 충돌 부위 반지름
ColliRadiidxMat=strfind(in_data,['#ColliRadi']);
ColliRadiidx = find(not(cellfun('isempty',ColliRadiidxMat)));
numColliRadi = size(ColliRadiidx, 1);
for loop=1:numColliRadi
    RobotInfo.ColliRadi(1*(loop-1)+1)=str2double(cell2mat(in_data(ColliRadiidx(loop)+1)));
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

CLHsidx_mat = strfind(in_data,['#Hspace']);
CLHsidx = find(not(cellfun('isempty',CLHsidx_mat)));
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

% End-Effector STL 입력 확인
stllist = dir([Path, '/*.stl']);
if size(stllist, 1)
    RobotInfo.EEstlpath = [Path, '/', stllist.name];
else
    RobotInfo.EEstlpath = char.empty;
end

% End-Effector 회전량 입력
EERotateidx = [find(strcmp(in_data,'#EERotate') == true) 0];
RobotInfo.EERotate = str2double(cell2mat(in_data(EERotateidx(1) + 1)));

% 추가
% Shape
ColliShapeidxMat = strfind(in_data,['#ColliShape']);
ColliShapeidx = find(not(cellfun('isempty',ColliShapeidxMat)));
for loop = 1:numColliJoint
    RobotInfo.ColliShape(loop, 1) = str2double(cell2mat(in_data(ColliShapeidx(loop)+1)));
end

% Fillet
ColliFilletidxMat = strfind(in_data,['#ColliFillet']);
ColliFilletidx = find(not(cellfun('isempty',ColliFilletidxMat)));
for loop = 1:numColliJoint
    RobotInfo.ColliFillet(loop, 1) = str2double(cell2mat(in_data(ColliFilletidx(loop)+1)));
end

% CoverInfo
ColliCoverInfoidxMat = strfind(in_data,['#CoverInfo']);
ColliCoverInfoidx = find(not(cellfun('isempty',ColliCoverInfoidxMat)));
for loop = 1:numColliJoint
    RobotInfo.CoverInfo(loop, 1) = str2double(cell2mat(in_data(ColliCoverInfoidx(loop)+1)));
end

% sim. cond. check.
% Radius B.C. check
% fillet B.C. check

% Radius와 Fillet의 사용 범위
% Shape1: 5 < Radius < 1000, Fillet = 0
% Shape5: 5 < Radius < 100, 1 < Fillet < 18
% Shape8: Radius = 0, 1 < Fillet < 14

% Motion file Exist or not check
% STL file Exist or not check

TaskIdx = 0;
SimCondIdx=[];


for i=1:numColliJoint
    SimCondIdx(i,1)=i;
    TaskIdx=RobotInfo.ColliShape(i,1);
    Radius=RobotInfo.ColliRadi(1,i);
    Fillet=RobotInfo.ColliFillet(i,1);
    Cover=RobotInfo.CoverInfo(i,1);
    
    switch TaskIdx
        
        case 0 % idle state
            
        case 1 % sphere
            if ((S1RMIN < Radius) &  (Radius < S1RMAX))
                SimCondIdx(i,2)=1;
            else
                SimCondIdx(i,2)=0;
            end
            
            if (Fillet==0)
                SimCondIdx(i,3)=1;
            else
                SimCondIdx(i,3)=0;
            end
            
            if ((COVERMIN<=Cover) & (Cover<=COVERMAX))
                SimCondIdx(i,4)=1;
            else
                SimCondIdx(i,4)=0;
            end
            
            TaskIdx=0;
            
        case 5 % cylinder edge
            if ((S5RMIN < Radius) & (Radius < S5RMAX))
                SimCondIdx(i,2)=1;
            else
                SimCondIdx(i,2)=0;
            end
            
            if ((S5FMIN < Fillet) & (Fillet < S5FMAX))
                SimCondIdx(i,3)=1;
            else
                SimCondIdx(i,3)=0;
            end
            
            if ((COVERMIN<=Cover) & (Cover<=COVERMAX))
                SimCondIdx(i,4)=1;
            else
                SimCondIdx(i,4)=0;
            end
            
            TaskIdx=0;
            
        case 8 % corner edge
            if Radius == 0
                SimCondIdx(i,2)=1;
            else
                SimCondIdx(i,2)=0;
            end
            
            if ((S8FMIN < Fillet) & (Fillet < S8FMAX))
                SimCondIdx(i,3)=1;
            else
                SimCondIdx(i,3)=0;
            end
            
            if ((COVERMIN<=Cover) & (Cover<=COVERMAX))
                SimCondIdx(i,4)=1;
            else
                SimCondIdx(i,4)=0;
            end
            
            TaskIdx=0;
                        
        otherwise
            
    end
    
    if (Radius-Fillet)<0
        BCCheck=0;
    else
        BCCheck=1;
    end
    
    SimCondIdx(i,5)=SimCondIdx(i,2)*SimCondIdx(i,3)*SimCondIdx(i,4)*BCCheck;
    
end

fclose(fileID);

IsSimOk=prod(SimCondIdx(:,5));

SimCondIdx(:,6)=RobotInfo.ColliShape;
SimCondIdx(:,7)=RobotInfo.ColliRadi';
SimCondIdx(:,8)=RobotInfo.ColliFillet;
SimCondIdx(:,9)=RobotInfo.CoverInfo;


% ['ColliPos No. ',num2str(SimCondIdx(i,1)
clc
end

end