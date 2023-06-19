function Makeallgraph(UserPath, fn)

% UserPath=[pn fn];

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
RobotInfo = Set_TextRobotInfo(UserPath);

robotmodel=RobotInfo.RobotModel;
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
    if isfolder([UserPath,'\output\graph\ISO'])~=1
        mkdir([UserPath,'\output\graph\ISO']);
        savefolder=[UserPath,'\output\graph\ISO\'];
    else
        savefolder=[UserPath,'\output\graph\ISO\'];
    end
else
    if isfolder([UserPath,'\output\graph\KHU'])~=1
        mkdir([UserPath,'\output\graph\KHU']);
        savefolder=[UserPath,'\output\graph\KHU\'];
    else
        savefolder=[UserPath,'\output\graph\KHU\'];
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

HeaderName='CRI';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
CRI=org.data(:,Scol:Ecol);

HeaderName='OverlappedBoxIndex';
Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
OverlappedBoxIndex=org.data(:,Scol:Ecol);

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
if length(RobotInfo.ColliBody)~=0
    tempDangerField=unique(DangerFiledInfo(:,3)');
    DangerFieldIdx=tempDangerField(2:length(tempDangerField));
    CRIatHSPACE=[];
    maxtempCRIIdx=[];
    NumofdangerPoints=[];
    for i=1:length(t)
        tempIdx=[];
        tempCRIIdx=[];
        for j=1:length(RobotInfo.ColliBody)
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
    
    for j=1:length(RobotInfo.ColliBody)
        NumofdangerPoints(1,j)=length(find(CRIatHSPACE(:,j)>1));
    end
end

%%
criref(1:size(t))=1;
[row col]=find(ModiCRI==max(MaxModiCRI)); %% find the maximum CRI points (row = time/(1/125),  col = collision joint)

% CRI Graph
h1=figure;
colororder(h1,newcolor);
set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
set(gca,'FontSize',12,'FontWeight','Bold');
plot(t,MaxModiCRI,'b',t,criref,'r--','linewidth',1.5),axis on, box on, xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('CRI','FontSize',12,'FontWeight','bold');
plot(t(row),max(MaxModiCRI),'ro','Markersize',10)
dim1 = [0.15 0.57 0.3 0.3];
dim2 = [0.15,0.75,0.24,0.06];
dim3 = [0.151,0.75,0.73,0.12];
if max(MaxModiCRI)<1.5
    ylim([0 3]),xlim([0 ceil(max(t))]);
else
    ylim([0 round(max(MaxModiCRI)*1.8)]),xlim([0 ceil(max(t))]);
end
formatSpec = '%.3f';
str1 = ['Max. CRI value is ',num2str(max(max(MaxModiCRI)),formatSpec),' on the ', num2str(max(col)),'-th Collision points at ', num2str(t(max(row))), ' sec'];
% str2 = ['Est.Max Force : ',num2str(Force(max(row),max(col)),formatSpec),'N & Est.Max Pressure : ',num2str((Pressure(max(row),max(col))/100),formatSpec),'Mpa'];
str2 = ['Est.Max Force : ',num2str(max(max(Force)),formatSpec),'N & Est.Max Pressure : ',num2str(max(max(Pressure))/100,formatSpec),'Mpa'];
annotation('textbox',dim1,'String',str1,'FitBoxToText','on','EdgeColor','white','fontsize',10.5);
annotation('textbox',dim2,'String',str2,'FitBoxToText','on','EdgeColor','white','fontsize',10.5);
annotation('rectangle',dim3,'Color','red','LineWidth',1.5)
fig_name=[savefolder 'CRI_Result.jpg'];
saveas(h1,fig_name);
fig_name=[savefolder 'CRI_Result'];
saveas(h1,fig_name,'fig');

h2=figure;
colororder(h2,newcolor);
set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
set(gca,'FontSize',12,'FontWeight','Bold');
plot(t,ModiCRI,'linewidth',1.5),axis on, box on, xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('CRI','FontSize',12,'FontWeight','bold'),ylim([0 3]),xlim([0 ceil(max(t))]);
dim1 = [0.15 0.57 0.3 0.3];
dim2 = [0.15,0.75,0.24,0.06];
dim3 = [0.151,0.75,0.73,0.12];
formatSpec = '%.3f';
str1 = ['Max. CRI value is ',num2str(max(max(MaxModiCRI)),formatSpec),' on the ', num2str(max(col)),'-th Collision points at ', num2str(t(max(row))), ' sec'];
% str2 = ['Est.Max Force : ',num2str(Force(max(row),max(col)),formatSpec),'N & Est.Max Pressure : ',num2str(Pressure(max(row),max(col))/100,formatSpec),'Mpa'];
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
legend([LegendIndex,'MaxCRI','CRI Reference','Max. CRI. Point'],'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
fig_name=[savefolder 'All_CRI_Res.jpg'];
saveas(h2,fig_name);
fig_name=[savefolder 'All_CRI_Res'];
saveas(h2,fig_name,'fig');


% Velocity Graph
J=RobotInfo.ColliJoint;
[m n]=size(J);
NJ=[0 0 0];

if cell2mat(isMobileRobot)=='1'
    J1=find(J==0); J2=find(J>=1 & J<6); J3=find(J==6);
    [m1 n1]=size(J1); TempJ1=J1(1:n1-1);TempJ2=[max(J1),J2];
    clear J1, clear J2
    J1=TempJ1; J2=TempJ2;
    clear TempJ1, clear TempJ2
%     [m1 n1]=size(J1); TempJ1=J1(1:n1);TempJ2=[max(J1),J2];
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

% NJ(1,1)=NJ(1,1)-1; % cobot 베이스도 0번 사용 -> 모바일에서 하나 빼고
% NJ(1,2)=NJ(1,2)+1; % cobot 베이스도 0번 사용 -> cobot에 하나 더하고
% 
% J1=[1:1:NJ(1,1)];
% J2=[(NJ(1,1)+1):1:(NJ(1,1)+NJ(1,2))];
% J3=[(NJ(1,1)+NJ(1,2))+1:1:(NJ(1,1)+NJ(1,2)+NJ(1,3))];

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

% MbaseVel=ImpactVelNorm(:,min(J1):max(J1));
% RobotVel=ImpactVelNorm(:,min(J2):max(J2));
% EEVel=ImpactVelNorm(:,min(J3):max(J3));
    
switch VelGraphIdx
    case 0
    case 1
        h3=figure;
        colororder(h3,newcolor);
        MbaseVel=ImpactVelNorm(:,min(J1):max(J1));
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        plot(t,MbaseVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Colliosion points on Mobile Base [mm/s]','FontSize',12,'FontWeight','bold');
        ylim([0 round(max(max(MbaseVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        for i=1:max(J1)
            MobileLegend(i)=LegendIndex(i);
        end
        legend(MobileLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal');
        fig_name=[savefolder 'Mobile_base_velocity.jpg'];
        saveas(h3,fig_name);
        fig_name=[savefolder 'Mobile_base_velocity'];
        saveas(h3,fig_name,'fig');
        
    case 2
        h4=figure;
        colororder(h4,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        RobotVel=ImpactVelNorm(:,min(J2):max(J2));
        plot(t,RobotVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Collision Points on Cobot [mm/s]','FontSize',12,'FontWeight','bold');
        idx=0;
        for i=min(J2):max(J2)
            idx=idx+1;
            CobotLegend(idx)=LegendIndex(i);
        end
        ylim([0 round(max(max(RobotVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        legend(CobotLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
        
        fig_name=[savefolder 'Cobot_velocity.jpg'];
        saveas(h4,fig_name);
        fig_name=[savefolder 'Cobot_velocity'];
        saveas(h4,fig_name,'fig');
        
    case 3
        h5=figure;
        colororder(h5,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        EEVel=ImpactVelNorm(:,min(J3):max(J3));
        plot(t,EEVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of End Effector [mm/s]','FontSize',12,'FontWeight','bold');
        idx=0;
        for i=min(J3):max(J3)
            idx=idx+1;
            EELegend(idx)=LegendIndex(i);
        end
        ylim([0 round(max(max(EEVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        legend([EELegend],'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')   
        
        fig_name=[savefolder 'EE_Vel.jpg'];
        saveas(h5,fig_name);
        fig_name=[savefolder 'EE_Vel'];
        saveas(h5,fig_name,'fig');

    case 4
        h3=figure;
        colororder(h3,newcolor);
        MbaseVel=ImpactVelNorm(:,min(J1):max(J1));
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        plot(t,MbaseVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Colliosion points on Mobile Base [mm/s]','FontSize',12,'FontWeight','bold');
        ylim([0 round(max(max(MbaseVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        for i=1:max(J1)
            MobileLegend(i)=LegendIndex(i);
        end

        legend(MobileLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
        
        h4=figure;
        colororder(h4,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        RobotVel=ImpactVelNorm(:,min(J2):max(J2));
        plot(t,RobotVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Collision Points on Cobot [mm/s]','FontSize',12,'FontWeight','bold');
        ylim([0 round(max(max(RobotVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        idx=0;
        for i=min(J2):max(J2)
            idx=idx+1;
            CobotLegend(idx)=LegendIndex(i);
        end
        
        legend(CobotLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
        
        fig_name=[savefolder 'Mobile_base_velocity.jpg'];
        saveas(h3,fig_name);
        fig_name=[savefolder 'Mobile_base_velocity'];
        saveas(h3,fig_name,'fig');

        fig_name=[savefolder 'Cobot_velocity.jpg'];
        saveas(h4,fig_name);
        fig_name=[savefolder 'Cobot_velocity'];
        saveas(h4,fig_name,'fig');
    
    case 5
        h3=figure;
        colororder(h3,newcolor);
        MbaseVel=ImpactVelNorm(:,min(J1):max(J1));
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        plot(t,MbaseVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Colliosion points on Mobile Base [mm/s]','FontSize',12,'FontWeight','bold');
        ylim([0 round(max(max(MbaseVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        for i=1:max(J1)
            MobileLegend(i)=LegendIndex(i);
        end
        legend(MobileLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
 
        h5=figure;
        colororder(h5,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        EEVel=ImpactVelNorm(:,min(J3):max(J3));
        plot(t,EEVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of End Effector [mm/s]','FontSize',12,'FontWeight','bold');
        idx=0;
        for i=min(J3):max(J3)
            idx=idx+1;
            EELegend(idx)=LegendIndex(i);
        end
        ylim([0 round(max(max(EEVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        
        legend([EELegend],'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')   
        
        fig_name=[savefolder 'Mobile_base_velocity.jpg'];
        saveas(h3,fig_name);
        fig_name=[savefolder 'Mobile_base_velocity'];
        saveas(h3,fig_name,'fig');
        
        fig_name=[savefolder 'EE_Vel.jpg'];
        saveas(h5,fig_name);
        fig_name=[savefolder 'EE_Vel'];
        saveas(h5,fig_name,'fig');
    
    case 6
        h4=figure;
        colororder(h4,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        RobotVel=ImpactVelNorm(:,min(J2):max(J2));
        plot(t,RobotVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Collision Points on Cobot [mm/s]','FontSize',12,'FontWeight','bold');
        idx=0;
        for i=min(J2):max(J2)
            idx=idx+1;
            CobotLegend(idx)=LegendIndex(i);
        end
        ylim([0 round(max(max(RobotVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        legend(CobotLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
        
        h5=figure;
        colororder(h5,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        %%%%%% 22.12.14
%         EEVel=ImpactVelNorm(:,min(J3):max(J3));
        EEVel=ImpactVelNorm(:,min(J3):max(J3)-1);
        plot(t,EEVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of End Effector [mm/s]','FontSize',12,'FontWeight','bold');
        idx=0;
%         for i=min(J3):max(J3)
        for i=min(J3):max(J3)-1
            idx=idx+1;
            EELegend(idx)=LegendIndex(i);
        end
        ylim([0 round(max(max(EEVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        legend([EELegend],'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')  
        
        fig_name=[savefolder 'Cobot_velocity.jpg'];
        saveas(h4,fig_name);
        fig_name=[savefolder 'Cobot_velocity'];
        saveas(h4,fig_name,'fig');

        fig_name=[savefolder 'EE_Vel.jpg'];
        saveas(h5,fig_name);
        fig_name=[savefolder 'EE_Vel'];
        saveas(h5,fig_name,'fig');
    
    case 7
        h3=figure;
        colororder(h3,newcolor);
        MbaseVel=ImpactVelNorm(:,min(J1):max(J1));
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        plot(t,MbaseVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Colliosion points on Mobile Base [mm/s]','FontSize',12,'FontWeight','bold');
        ylim([0 round(max(max(MbaseVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        for i=1:max(J1)
            MobileLegend(i)=LegendIndex(i);
        end
        legend(MobileLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
        
        h4=figure;
        colororder(h4,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        RobotVel=ImpactVelNorm(:,min(J2):max(J2));
        plot(t,RobotVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Collision Points on Cobot [mm/s]','FontSize',12,'FontWeight','bold');
        idx=0;
        for i=min(J2):max(J2)
            idx=idx+1;
            CobotLegend(idx)=LegendIndex(i);
        end
        ylim([0 round(max(max(RobotVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        legend(CobotLegend,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')
        
        h5=figure;
        colororder(h5,newcolor);
        set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
        set(gca,'FontSize',12,'FontWeight','Bold');
        EEVel=ImpactVelNorm(:,min(J3):max(J3));
        plot(t,EEVel,'linewidth',1.5)
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of End Effector [mm/s]','FontSize',12,'FontWeight','bold');
        idx=0;
        for i=min(J3):max(J3)
            idx=idx+1;
            EELegend(idx)=LegendIndex(i);
        end
        ylim([0 round(max(max(EEVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
        legend([EELegend],'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal')       
        
        fig_name=[savefolder 'Mobile_base_velocity.jpg'];
        saveas(h3,fig_name);
        fig_name=[savefolder 'Mobile_base_velocity'];
        saveas(h3,fig_name,'fig');

        fig_name=[savefolder 'Cobot_velocity.jpg'];
        saveas(h4,fig_name);
        fig_name=[savefolder 'Cobot_velocity'];
        saveas(h4,fig_name,'fig');

        fig_name=[savefolder 'EE_Vel.jpg'];
        saveas(h5,fig_name);
        fig_name=[savefolder 'EE_Vel'];
        saveas(h5,fig_name,'fig');

    
    otherwise
        
end

h6=figure;
colororder(h6,newcolor);
Vel=ImpactVelNorm;
set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
set(gca,'FontSize',12,'FontWeight','Bold');
plot(t,Vel,'linewidth',1.5)
xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Velocity of Colliosion points [mm/s]','FontSize',12,'FontWeight','bold');
ylim([0 round(max(max(Vel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
legend(LegendIndex,'Location','southoutside','NumColumns',4,'fontsize',12,'fontweight','bold','Orientation','horizontal');
fig_name=[savefolder 'All_pos_velocity.jpg'];
saveas(h6,fig_name);
fig_name=[savefolder 'All_pos_velocity'];
saveas(h6,fig_name,'fig');

h8=figure;set(gcf,'color','w','Position',[570,739,995,239])
if length(RobotInfo.ColliBody)~=0
    for j=1:length(RobotInfo.ColliBody)
        plot(t,CRIatHSPACE(:,j),'linewidth',1.5);
        xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('CRI','FontSize',12,'FontWeight','bold'),ylim([0 3]),xlim([0 ceil(max(t))]);
        filename=['CRI_at_HSPACE',num2str(j),'.jpg'];
        fig_name=[savefolder,filename];
        saveas(h8,fig_name);
    
        filename=['CRI_at_HSPACE',num2str(j)];
        fig_name=[savefolder,filename,'fig'];
        saveas(h8,fig_name);
    end
    close(h8)
    
    h9=figure;set(gcf,'color','w','Position',[455,440,873,555]); hold on, box on, axis on;
    for j=1:length(RobotInfo.ColliBody)
        subplot(length(RobotInfo.ColliBody),1,j),plot(t,CRIatHSPACE(:,j),'linewidth',1.5);
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m n]=size(ModiCRI);
CRIRES=[];FORCERES=[];PRESSURERES=[];VELRES=[];
nofAxis=[1:n];

for i=1:n
    CRIRES(i)=max(max(ModiCRI(:,i)));
    FORCERES(i)=max(max(Force(:,i)));
    PRESSURERES(i)=max(max(Pressure(:,i)));
    VELRES(i)=max(max(Vel(:,i)));
end

% Criterion
KHU=[410,410,2.9,2.9;250,500,1.8,3.6;310,620,3.9,7.8;510,1020,3.7,7.4];
ISO=[130,130,1.3,1.3;140,280,1.2,1.2;150,300,1.9,3.8;140,280,3.0,6.0];

% Sim Condition Check
[IsSimOk SimCondIdx ColliBody BoundaryC AllColliBody]=ChkSimCondition(UserPath);

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

% % % Robotmodel
% %     RobotModelidx=find(strcmp(in_data,'#RobotModel') == true);
% %     RobotInfo.RobotModel = cell2mat(in_data(RobotModelidx(1)+1));
% %         
% %     if strcmpi(ColliBody,'SkullandForehead')
% %         DocInfo.ColliBody='머리';
% %         DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
% %     elseif strcmpi(ColliBody,'Chest')
% %         DocInfo.ColliBody='가슴';
% %         DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
% %     elseif strcmpi(ColliBody,'Upperarm')
% %         DocInfo.ColliBody='상완(삼각근)';
% %         DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
% %     elseif strcmpi(ColliBody,'HandandFinger')
% %          DocInfo.ColliBody='손';
% %          DocInfo.TestItem = ['동적 / ',DocInfo.ColliBody];
% %     end
% %     
% %     if (contains(BodyProperties,'KHU')  || contains(fn,'KHU'))
% %         disp('KHU')
% %         if DocInfo.ColliBody=='머리'
% %             FDen=KHU(1,2);
% %             PDen=KHU(1,4);
% %         elseif DocInfo.ColliBody=='가슴'
% %             FDen=KHU(2,2);
% %             PDen=KHU(2,4);
% %         elseif DocInfo.ColliBody=='상완(삼각근)'
% %             FDen=KHU(3,2);
% %             PDen=KHU(3,4);
% %         elseif DocInfo.ColliBody=='손'
% %             FDen=KHU(4,2);
% %             PDen=KHU(4,4);
% %         else
% %         end
% %     elseif (contains(BodyProperties,'ISO') || contains(fn,'ISO'))
% %         disp('ISO')
% %         if DocInfo.ColliBody=='머리'
% %             FDen=ISO(1,2);
% %             PDen=ISO(1,4);
% %         elseif DocInfo.ColliBody=='가슴'
% %             FDen=ISO(2,2);
% %             PDen=ISO(2,4);
% %         elseif DocInfo.ColliBody=='상완(삼각근)'
% %             FDen=ISO(3,2);
% %             PDen=ISO(3,4);
% %         elseif DocInfo.ColliBody=='손'
% %             FDen=ISO(4,2);
% %             PDen=ISO(4,4);
% %         else
% %         end
% %     else
% %     end
% % end
    
h7=figure;
% set(gcf,'color','w','Position',[108,93,1737,500]); hold on, box on, axis on;
% subplot(4,1,1),bCRI=bar(nofAxis,CRIRES);
% set(gcf,'color','w','Position',[0.13,0.11,0.775,0.815]); hold on, box on, axis on;
set(gcf,'color','w','Position',[108,93,1737,500]); hold on, box on, axis on;
bCRI=bar(nofAxis,CRIRES);
if max(CRIRES)<=2
    ylim([0 2]);
else
    ylim([0 max(CRIRES)*1.5])
end

set(gca,'XTick',(1:1:n));hold on
xtips1 = bCRI(1).XEndPoints;
ytips1 = bCRI(1).YEndPoints;
labels1 = string(bCRI(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom')
plot(nofAxis,ones(1,length(nofAxis)),'r--','linewidth',1.5),axis on, box on, ylabel('CRI','FontSize',12,'FontWeight','bold');
ylabel('ModiCRI','FontSize',12,'FontWeight','bold');
title([UserPath,fn],'FontSize',12,'FontWeight','bold');
% 
% subplot(4,1,2),bForce=bar(nofAxis,(FORCERES./FDen).*100);
% if max(FORCERES./FDen.*100)<100
%     ylim([0 100])
% else
%     ylim([0 max(FORCERES./FDen.*100).*1.5])
% end
% set(gca,'XTick',(1:1:n));hold on
% xtips1 = bForce(1).XEndPoints;
% ytips1 = bForce(1).YEndPoints;
% labels1 = string(bForce(1).YData);
% text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom')
% ylabel('F. Rate[%]','FontSize',12,'FontWeight','bold');
% 
% subplot(4,1,3),bPressure=bar(nofAxis,(PRESSURERES./100./PDen).*100);
% if max((PRESSURERES./100./PDen.*100))<100
%     ylim([0 100])
% else
%     ylim([0 max((PRESSURERES./100./PDen.*100)).*1.5]);
% end
% 
% set(gca,'XTick',(1:1:n));hold on
% xtips1 = bPressure(1).XEndPoints;
% ytips1 = bPressure(1).YEndPoints;
% labels1 = string(bPressure(1).YData);
% text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom')
% ylabel('P. Rate[%]','FontSize',12,'FontWeight','bold');
% 
% subplot(4,1,4),bVel=bar(nofAxis,VELRES),ylim([0 floor(max(VELRES).*1.5)]);
% set(gca,'XTick',(1:1:n));hold on
% xtips1 = bVel(1).XEndPoints;
% ytips1 = bVel(1).YEndPoints;
% labels1 = string(bVel(1).YData);
% text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom')
% xlabel('Number of Axis','FontSize',12,'FontWeight','bold'),ylabel('Max. Vel. [mm/s]','FontSize',12,'FontWeight','bold');
% 
fig_name=[savefolder 'Simulation_summary.jpg'];
saveas(h7,fig_name);
fig_name=[savefolder 'Simulation_summary'];
saveas(h7,fig_name,'fig');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
% beepbeep([0.2 0.2])
end
