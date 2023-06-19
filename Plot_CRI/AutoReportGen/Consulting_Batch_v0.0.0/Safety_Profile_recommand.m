function [modMotion]=Safety_Profile_recommand(UserPath, codeNo)

codeNo=3;

Masksize=1; %% do not change the value!!!!!

% CRITH=0.0017;
CRITH=0.015;
ScaleMargin=1;
UserPath='D:\JayLim\OneDrive\SAFETICS\03_consulting\2023\01_STS_Robotech\99_긴급해석\03_2차_STS2공장_긴급해석건\2_해석결과\007호기';
fn='\KHU_Collision_Risk_Analyze_Result.csv';
RobotInfo = Set_TextRobotInfo(UserPath);
robotmodel=RobotInfo.RobotModel;
RobotThetafn=['../inputdata/Robot_Model/',robotmodel,'.txt'];
fileID = fopen(RobotThetafn,'r');
in_data_cell = textscan(fileID,'%s');
in_data = (in_data_cell{1,1});
ThetaStart=find(strcmp(in_data,'#Theta') == true)+1;
ThetaEnd=ThetaStart+5;
RobotTheta=[];

for i=1:6
    RobotTheta(i)=str2num(in_data_cell{1}{22+i});
end

Motionfn='\ST_MotionInfo.txt';

HeaderGroup=["Unix_Time_Hour";"Unix_Time_Min";"Unix_Time_Sec";"Elapse";
"Time";"q_";"qd_";"EffectiveMass";"ImpactVelNorm";"ImpactVelDirNorm";"ImpactVelAlphaNorm";
"Force";"Pressure";"MaxCRI";"CRI";"MaxModiCRI";"ModiCRI";"ImpactPosList";
"BoxInOutIndex";"AssignBoxIndex";"OverlappedBoxIndex";"MinScale";"Scale";
"MinModiScale";"ModiScale";"ColliAlpha";"BasePosition";];

ResDataPath=[UserPath fn];
MotionDataPath=[UserPath,Motionfn];

org=importdata(ResDataPath);
header=org.colheaders;
NumofColliPos=sum(contains(org.colheaders,'EffectiveMass'));
LegendIndex=strings(1,NumofColliPos);

for i=1:NumofColliPos
        LegendIndex(i)=['Point#',num2str(i)];
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
trimedData=[];
[m n]=size(trimedData);

%% single column variable
HeaderName='Time';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
Time=org.data(:,Scol);

HeaderName='MaxModiCRI';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
MaxModiCRI=org.data(:,Scol);

HeaderName='MinModiScale';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
MinModiScale=org.data(:,Scol);

HeaderName='ImpactVelNorm';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
EffectiveMass=org.data(:,Scol:Ecol);

HeaderName='q_';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
qMATtemp=org.data(:,Scol:Ecol);
for i=1:6
    qMAT(:,i)=qMATtemp(:,i)-RobotTheta(i);
end

HeaderName='qd_';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
qdMAT=org.data(:,Scol:Ecol);

tempIdx=0;
tempIdxOld=0;
tempBlock=[];
MaskMat=[];
ScaleMat=[];

figure,plot(Time, MaxModiCRI), hold on

switch codeNo
    
    case 1 %% original code : 22.12.29
        
        iterNo=ceil(length(MaxModiCRI)/Masksize);

        if iterNo*Masksize>length(MaxModiCRI)
            adjCoeff = length(MaxModiCRI)-iterNo*Masksize;
        elseif iterNo*Masksize<length(MaxModiCRI)
            adjCoeff=length(MaxModiCRI)-iterNo*Masksize;
        else
            adjCoeff=0;
        end
        
        for i=1:iterNo
            tempIdxOld=tempIdx;
            if iterNo>i
                tempIdx=i*Masksize;
                tempBlock=MaxModiCRI(tempIdx-(Masksize-1):tempIdx);
            else
                tempIdx=i*Masksize+adjCoeff;
                BlockSize=tempIdx-tempIdxOld;
                if BlockSize==1
                    tempBlock=MaxModiCRI(tempIdx);
                elseif BlockSize==0
                else
                    tempBlock=MaxModiCRI(tempIdxOld+1:tempIdx);
                end

            end

            BlockSize=length(tempBlock);

            if max(tempBlock)>1
                MaskMat=[MaskMat ones(1,BlockSize)];
            else
                MaskMat=[MaskMat zeros(1,BlockSize)];
            end

        end

        for i=1:6
            qdMod(:,i)=qdMAT(:,i).*MinModiScale;
        end
        MaskMat=MaskMat';
        ModInterval=[0;diff(Time)]./MinModiScale;
        
        plot(Time, MaskMat,'r')
        
    case 2 %% modified code : 23.01.02
        Masksize=10;
        iterNo=ceil(length(MaxModiCRI)/Masksize);

        if iterNo*Masksize>length(MaxModiCRI)
            adjCoeff = length(MaxModiCRI)-iterNo*Masksize;
        elseif iterNo*Masksize<length(MaxModiCRI)
            adjCoeff=length(MaxModiCRI)-iterNo*Masksize;
        else
            adjCoeff=0;
        end
        
        for i=1:iterNo
            tempIdxOld=tempIdx;
            if iterNo>i
                tempIdx=i*Masksize;
                tempBlock=MaxModiCRI(tempIdx-(Masksize-1):tempIdx);
            else
                tempIdx=i*Masksize+adjCoeff;
                BlockSize=tempIdx-tempIdxOld;
                if BlockSize==1
                    tempBlock=MaxModiCRI(tempIdx);
                elseif BlockSize==0
                else
                    tempBlock=MaxModiCRI(tempIdxOld+1:tempIdx);
                end

            end

            BlockSize=length(tempBlock);

            if CRITH>max(tempBlock) && max(tempBlock)>=0 % NO ACC / DCC Condition --> Hold section
                ScaleMat(i,1)=1;
            elseif 1>=max(tempBlock) && max(tempBlock)>CRITH % ACC Condition --> ACC section
                ScaleMat(i,1)=MinModiScale(i,1);
            else
                ScaleMat(i,1)=ScaleMargin.*MinModiScale(i,1);
            end

        end
        
        for i=1:6
            qdMod(:,i)=qdMAT(:,i).*ScaleMat;
        end

        ModInterval=[0;diff(Time)]./ScaleMat;

        plot(Time, ScaleMat,'r')
        

    case 3 %% modified code : 23.01.03 -> mask size adjustable + acc/dcc/hold section
        Masksize=1;
        iterNo=ceil(length(MaxModiCRI)/Masksize);

        if iterNo*Masksize>length(MaxModiCRI)
            adjCoeff = length(MaxModiCRI)-iterNo*Masksize;
        elseif iterNo*Masksize<length(MaxModiCRI)
            adjCoeff=length(MaxModiCRI)-iterNo*Masksize;
        else
            adjCoeff=0;
        end
        
        for i=1:iterNo
            tempIdxOld=tempIdx;
            if iterNo>i
                tempIdx=i*Masksize;
                tempBlock=MaxModiCRI(tempIdx-(Masksize-1):tempIdx);
            else
                tempIdx=i*Masksize+adjCoeff;
                BlockSize=tempIdx-tempIdxOld;
                if BlockSize==1
                    tempBlock=MaxModiCRI(tempIdx);
                elseif BlockSize==0
                else
                    tempBlock=MaxModiCRI(tempIdxOld+1:tempIdx);
                end

            end

            BlockSize=length(tempBlock);

            if CRITH>max(tempBlock) && max(tempBlock)>=0 % NO ACC / DCC Condition --> Hold section
                ScaleMat(i,1)=1;
            elseif 1>=max(tempBlock) && max(tempBlock)>CRITH % ACC Condition --> ACC section
                ScaleMat(i,1)=MinModiScale(i,1);
            else
                ScaleMat(i,1)=ScaleMargin.*MinModiScale(i,1);
%                 ScaleMat(i,1)=MinModiScale(i,1);
            end

        end
     
        Masksize=7;
        tempIdx=0;
        tempIdxOld=0;
        tempBlock=[];
        
        iterNo=ceil(length(ScaleMat)/Masksize);

        if iterNo*Masksize>length(ScaleMat)
            adjCoeff = length(ScaleMat)-iterNo*Masksize;
        elseif iterNo*Masksize<length(ScaleMat)
            adjCoeff=length(ScaleMat)-iterNo*Masksize;
        else
            adjCoeff=0;
        end
        
        for i=1:iterNo
            tempIdxOld=tempIdx;
            if iterNo>i
                tempIdx=i*Masksize;
                tempBlock=ScaleMat(tempIdx-(Masksize-1):tempIdx);
            else
                tempIdx=i*Masksize+adjCoeff;
                BlockSize=tempIdx-tempIdxOld;
                if BlockSize==1
                    tempBlock=ScaleMat(tempIdx);
                elseif BlockSize==0
                else
                    tempBlock=ScaleMat(tempIdxOld+1:tempIdx);
                end

            end
            
            BlockSize=length(tempBlock);
            i;
            tempBlock;

            if max(tempBlock)>1 %% acc section
                ScaleIdx=min(tempBlock);%min(MinModiScale(tempIdx-(Masksize-1):tempIdx));
                MaskMat=[MaskMat ScaleIdx.*ones(1,BlockSize)];
            elseif max(tempBlock)<1 %% dcc section
                ScaleIdx=min(MinModiScale(tempIdx-(Masksize-1):tempIdx)).*ScaleMargin;
                MaskMat=[MaskMat ScaleIdx.*ones(1,BlockSize)];
            else % MinModiScale == 1 -> optimal vel. or stop state
                if max(MaxModiCRI(tempIdx-(Masksize-1):tempIdx)) < CRITH %% stop state -> hold
                    ScaleIdx=1;
                    MaskMat=[MaskMat ScaleIdx.*ones(1,BlockSize)];
                elseif min(MinModiScale(tempIdx-(Masksize-1):tempIdx))==1 %% optimal vel.
                    ScaleIdx=1;
                    MaskMat=[MaskMat ScaleIdx.*ones(1,BlockSize)];
                else %% dcc when velocity multiple = 1
%                     ScaleIdx=min(MinModiScale(tempIdx-(Masksize-1):tempIdx));
                    ScaleIdx=min(tempBlock);
                    MaskMat=[MaskMat ScaleIdx.*ones(1,BlockSize)];
                end
            end
            clc
            tempBlock
            max(tempBlock)
            ScaleIdx

        end
        close all
        figure, bar(Time, ScaleMat,'r'), hold on, plot(Time, MaskMat,'k')
        
        for i=1:6
            qdMod(:,i)=qdMAT(:,i).*MaskMat';
        end

        ModInterval=[0;diff(Time)]./MaskMat';
        
    case 4 %% modified code
        
    case 5
               
    otherwise
        
end

for i=1:length(ModInterval)
    if i==1
        modTime(i,1)=ModInterval(i,1);
    else
        modTime(i,1)=modTime(i-1,1)+ModInterval(i,1);
    end
end
        
modMotion(:,1)=modTime;
modMotion(:,2:7)=qMAT;
modMotion(:,8:13)=qdMod;

end
