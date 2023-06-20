function gSeqData=Graph_Batch(gSeqData)
    warning('off','all')
    
    % RobotInfo Load
    gSeqData=RobotInfoDataLoad(gSeqData);
    tickString={};
    
    RobotLinkNum=size(gSeqData.SimInfo.RobotLinkInfo,1);
    RobotEndEffectorNum=size(gSeqData.SimInfo.RobotLinkInfo,1);

    prefix=gSeqData.SimInfo.BasicInfo.BodyProperty;

    % CSV file Load
    gSeqData.FolderInfo.AnalysisResultFile=[gSeqData.FolderInfo.UserPath,'\',prefix,'_Collision_Risk_Analyze_Result.csv'];
    ResData=importdata(gSeqData.FolderInfo.AnalysisResultFile);

    % Graph save folder set
    gSeqData.FolderInfo.GraphSaveFolder=[gSeqData.FolderInfo.UserPath,'\output\graph\',prefix];
    if ~isfolder(gSeqData.FolderInfo.GraphSaveFolder)
        mkdir(gSeqData.FolderInfo.GraphSaveFolder)
    end
    savefolder=gSeqData.FolderInfo.GraphSaveFolder;

    if RobotLinkNum~=0
        for i=1:size(gSeqData.SimInfo.RobotLinkInfo,1)
            tickString{i}=['R',num2str(i)];
        end
    end

    if RobotEndEffectorNum~=0
        for i=1:size(gSeqData.SimInfo.RobotEndEffectorInfo,1)
            tickString{RobotLinkNum+i}=['EE',num2str(i)];
        end
    end
    
%     CobotColor={};
%     EEColor={};
% 
%     fieldname=fieldnames(gSeqData.SimInfo);
% 
%     for i=1:length(fieldname)
%         if strcmpi(fieldname{i},'RobotLinkInfo')
%             for j=1:size(gSeqData.SimInfo.RobotLinkInfo,1)
%                 CobotColor=[CobotColor, gSeqData.SimInfo.RobotLinkInfo(j).Color ];
%             end
%         end
%     end
% 
%     for i=1:length(fieldname)
%         if strcmpi(fieldname{i},'RobotEndEffectorInfo')
%             for j=1:size(gSeqData.SimInfo.RobotEndEffectorInfo,1)
%                 EEColor=[EEColor, gSeqData.SimInfo.RobotEndEffectorInfo(j).Color ];
%             end
%         end
%     end
% 
%     CobotColor=CobotColor';
%     EEColor=EEColor';
%     AllColor=[CobotColor;EEColor];

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
    
    [~, NumofColliPos]=AnalysisDataLoad(ResData,'Time');
       
    for i=1:size(gSeqData.SimInfo.RobotLinkInfo,1)
        CobotLegend{i}=['R',num2str(i)];
    end
        
    for i=1:size(gSeqData.SimInfo.RobotEndEffectorInfo,1)
        EELegend{i}=['EE',num2str(i)];
    end
    
    [t, ~]=AnalysisDataLoad(ResData,'Time');
    [MaxModiCRI, ~]=AnalysisDataLoad(ResData,'MaxModiCRI');
    [ImpactVelNorm, ~]=AnalysisDataLoad(ResData,'ImpactVelNorm');
    [Force, ~]=AnalysisDataLoad(ResData,'Force');
    [Pressure, ~]=AnalysisDataLoad(ResData,'Pressure');
    [ModiCRI, ~]=AnalysisDataLoad(ResData,'ModiCRI');
    [OverlappedBoxIndex, ~]=AnalysisDataLoad(ResData,'OverlappedBoxIndex');
    [ImpactVelNorm, ~]=AnalysisDataLoad(ResData,'ImpactVelNorm');
    
    criref(1:size(t))=1;
    [row, col]=find(ModiCRI==max(MaxModiCRI)); %% find the maximum CRI points (row = time/(1/125), col = collision joint)
    
    if gSeqData.Visible
        h1=figure;
    else
        h1=figure('visible','off');
    end

    colororder(h1,newcolor);
    set(gcf,'color','w','Position',[522,268,1170,642]); hold on, box on, axis on;
    set(gca,'FontSize',12,'FontWeight','Bold');

    RobotVel=ImpactVelNorm(:,1:size(gSeqData.SimInfo.RobotLinkInfo,1));
    plot(t,RobotVel,'linewidth',1.5)
    xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('Speed of Collision Pts on Cobot [mm/s]','FontSize',12,'FontWeight','bold');
    if max(RobotVel)>0
        ylim([0 round(max(max(RobotVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
    else
        yticks('auto'),xlim([0 ceil(max(t))]);
    end
%     ylim([0 round(max(max(RobotVel*1.3)),-1)]); yticks('auto'),xlim([0 ceil(max(t))]);
    legend(CobotLegend,'Location','southoutside','NumColumns',10,'fontsize',12,'fontweight','bold','Orientation','horizontal')
    gSeqData.FolderInfo.GraphPathInfo.fig_name1=[savefolder '\Cobot_Speed.jpg'];
    saveas(h1,gSeqData.FolderInfo.GraphPathInfo.fig_name1);
    
    if gSeqData.Visible
        h2=figure;
    else
        h2=figure('visible','off');
    end
    
    colororder(h2,newcolor);
    set(gcf,'color','w','Position',[522,268,1170,642]); hold on, box on, axis on;
    set(gca,'FontSize',12,'FontWeight','Bold');
%     EEVel=ImpactVelNorm(:,1:size(gSeqData.SimInfo.RobotEndEffectorInfo,1));
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
    
    if gSeqData.Visible
        h3=figure;
    else
        h3=figure('visible','off');
    end
    
    legendstring=[CobotLegend,EELegend];
    colororder(h1,newcolor);
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
    elseif max(MaxModiCRI)==0
        yticks('auto'),xlim([0 ceil(max(t))]);
    else
        ylim([0 round(max(MaxModiCRI)*1.8)]),xlim([0 ceil(max(t))]);
    end
    legend([legendstring,'MaxCRI','CRI Reference','Max. CRI. Point'],'Location','southoutside','NumColumns',8,'fontsize',12,'fontweight','bold','Orientation','horizontal')
    gSeqData.FolderInfo.GraphPathInfo.fig_name3=[savefolder '\All_CRI_Res.jpg'];
    saveas(h3,gSeqData.FolderInfo.GraphPathInfo.fig_name3);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DangerFieldInfo=[];
    DangerFieldInfo(:,1)=t;
    DangerFieldInfo(:,2)=MaxModiCRI;
    
    for i=1:length(t)
        A=ModiCRI(i,:);
        if max(A)>1
            B=MaxModiCRI(i,1);
            C=find(A==B);
            [m n]=size(C);
            DangerFieldInfo(i,3)=OverlappedBoxIndex(i,C(1));
        else
            DangerFieldInfo(i,3)=0;
        end
    end
    
    if size(gSeqData.SimInfo.RiskSpaceInfo, 1)~=0 
        tempDangerField=unique(DangerFieldInfo(:,3)');
        DangerFieldIdx=tempDangerField(2:length(tempDangerField));
        CRIatHSPACE=[];
        maxtempCRIIdx=[];
        NumofdangerPoints=[];
        for i=1:length(t)
            tempIdx=[];
            tempCRIIdx=[];
            for j=1:size(gSeqData.SimInfo.RiskSpaceInfo, 1)
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
        
        for j=1:size(gSeqData.SimInfo.RiskSpaceInfo, 1)
            NumofdangerPoints(1,j)=length(find(CRIatHSPACE(:,j)>1));
        end
    end

    [m n]=size(ModiCRI);
    CRIRES=[]; FORCERES=[]; PRESSURERES=[]; VELRES=[];
    nofAxis=[1:n];
    
    for i=1:n
        CRIRES(i)=max(max(ModiCRI(:,i)));
        FORCERES(i)=max(max(Force(:,i)));
        PRESSURERES(i)=max(max(Pressure(:,i)));
        VELRES(i)=max(max(ImpactVelNorm(:,i)));
    end
        
    h4=figure;
    set(gcf,'color','w','Position',[108,93,1737,500]); hold on, box on, axis on;
    bCRI=bar(nofAxis,CRIRES);
    if max(CRIRES)<=2
        ylim([0 2]);
    else
        ylim([0 max(CRIRES)*1.5])
    end
    
    set(gca,'XTick',(1:1:n));hold on
    set(gca,'xticklabel',tickString,'fontsize',8,'fontweight','bold')
    xtips1 = bCRI(1).XEndPoints;
    ytips1 = bCRI(1).YEndPoints;
    labels1 = string(bCRI(1).YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom')
    plot(nofAxis,ones(1,length(nofAxis)),'r--','linewidth',1.5),axis on, box on, ylabel('CRI','FontSize',12,'FontWeight','bold');
    ylabel('ModiCRI','FontSize',12,'FontWeight','bold');
    title([gSeqData.FolderInfo.UserPath,'\',prefix,'_Collision_Risk_Analyze_Result'],'FontSize',12,'FontWeight','bold');
     
    fig_name=[savefolder '\Simulation_summary.jpg'];
    saveas(h4,fig_name);
    fig_name=[savefolder '\Simulation_summary'];
    saveas(h4,fig_name,'fig');

    if size(gSeqData.SimInfo.RiskSpaceInfo, 1)~=0       
        for j=1:size(gSeqData.SimInfo.RiskSpaceInfo, 1)
            h5=figure;set(gcf,'color','w','Position',[38,63,1540,876])
            [m n]=size(ModiCRI);
            tempCRIfield=zeros(m,n);
            tempForcefield=zeros(m,n);
            tempPressurefield=zeros(m,n);

            ColliBody=string(gSeqData.SimInfo.RiskSpaceInfo(1).ColliBody);
            [bodymsg, FDen, PDen]=Reference_CR(ColliBody, prefix);
    
            for timeidx=1:m
                tempIdx=find(OverlappedBoxIndex(timeidx,:)==j);
                if isempty(tempIdx)~=1
                    for HspaceIdx=1:length(tempIdx)
                        tempCRIfield(timeidx,tempIdx(HspaceIdx))=ModiCRI(timeidx,tempIdx(HspaceIdx));
                        tempForcefield(timeidx,tempIdx(HspaceIdx))=(Force(timeidx,tempIdx(HspaceIdx))./FDen)*100;
                        tempPressurefield(timeidx,tempIdx(HspaceIdx))=(Pressure(timeidx,tempIdx(HspaceIdx))./100./PDen)*100;
                    end
                end
            end
    
            tempForce=max(tempForcefield./100);
            tempPressure=max(tempPressurefield./100);
            tempCRIbyPoints=[tempForce;tempPressure];
            CRIbyPoints=max(tempCRIbyPoints);
    
            subplot(4,1,1),plot(t,CRIatHSPACE(:,j),'linewidth',1.5);hold on;
            plot(t,ones(1,length(t)),'r--','linewidth',1.5),axis on, box on
            xlabel('Time[sec]','FontSize',12,'FontWeight','bold'),ylabel('CRI','FontSize',12,'FontWeight','bold'),ylim([0 3]),xlim([0 ceil(max(t))]);
            title([gSeqData.FolderInfo.UserPath,' HSPACE at #',num2str(j),' Colli. Pos :',bodymsg],'FontSize',12,'FontWeight','bold');
    
            subplot(4,1,2),bForce=bar(nofAxis,CRIbyPoints);hold on
            plot(nofAxis,ones(1,length(nofAxis)),'r--','linewidth',1.5),axis on, box on
            
            if max(tempForce)<1
                ylim([0 2])
            else
                ylim([0 max(tempForce).*1.5])
            end
            set(gca,'XTick',(1:1:n));hold on
            set(gca,'xticklabel',tickString,'fontsize',8,'fontweight','bold')
            xtips1 = bForce(1).XEndPoints;
            ytips1 = bForce(1).YEndPoints;
            labels1 = string(round(bForce(1).YData,2));
            text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',10)
            ylabel('CRI at each Pos.','FontSize',12,'FontWeight','bold');
            xlabel('Colli. Pos. Number.','FontSize',12,'FontWeight','bold');
    
            subplot(4,1,3),bForce=bar(nofAxis,tempForce);hold on
            plot(nofAxis,ones(1,length(nofAxis)),'r--','linewidth',1.5),axis on, box on
            
            if max(tempForce)<1
                ylim([0 2])
            else
                ylim([0 max(tempForce).*1.5])
            end
            set(gca,'XTick',(1:1:n));hold on
            set(gca,'xticklabel',tickString,'fontsize',8,'fontweight','bold')
            xtips1 = bForce(1).XEndPoints;
            ytips1 = bForce(1).YEndPoints;
            labels1 = string(round(bForce(1).YData,2));
            text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',10)
            ylabel('CRI by Force','FontSize',12,'FontWeight','bold');
            xlabel('Colli. Pos. Number.','FontSize',12,'FontWeight','bold');
            
            subplot(4,1,4),bPressure=bar(nofAxis,tempPressure);hold on
            plot(nofAxis,ones(1,length(nofAxis)),'r--','linewidth',1.5),axis on, box on
            if max(tempPressure)<1
                ylim([0 2])
            else
                ylim([0 max(tempPressure).*1.5]);
            end
            
            set(gca,'XTick',(1:1:n));hold on
            set(gca,'xticklabel',tickString,'fontsize',8,'fontweight','bold')
            xtips1 = bPressure(1).XEndPoints;
            ytips1 = bPressure(1).YEndPoints;
            labels1 = string(round(bPressure(1).YData,2));
            text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',10)
            ylabel('CRI by Pressure','FontSize',12,'FontWeight','bold');
            xlabel('Colli. Pos. Number.','FontSize',12,'FontWeight','bold');
    
            clear tempCRIfield;
            clear tempForcefield;
            clear tempPressurefield;
            clear tempForce;
            clear tempPressure;
    
            filename=['\CRI_at_HSPACE',num2str(j),'.jpg'];
            fig_name=[savefolder,filename];
            saveas(h5,fig_name);
        
            filename=['\CRI_at_HSPACE',num2str(j)];
            fig_name=[savefolder,filename,'fig'];
            saveas(h5,fig_name);
    
        end
    end

    if gSeqData.TaskIdx~=2
        close all
    else
        disp('Please press the "Any Key" to progress')
        pause;
        close all
    end
end