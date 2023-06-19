function [varData, NumofColliPos]=AnalysisDataLoad(ResData,variableName)

    HeaderGroup=["Unix_Time_Hour";"Unix_Time_Min";"Unix_Time_Sec";"Elapse";
    "Time";"q_";"qd_";"EffectiveMass";"ImpactVelNorm";"ImpactVelDirNorm";"ImpactVelAlphaNorm";
    "Force";"Pressure";"MaxCRI";"CRI";"MaxModiCRI";"ModiCRI";"ImpactPosList";
    "BoxInOutIndex";"AssignBoxIndex";"OverlappedBoxIndex";"MinScale";"Scale";
    "MinModiScale";"ModiScale";"ColliAlpha";"BasePosition";];
    
    org=ResData;
    header=org.colheaders;
    NumofColliPos=sum(contains(org.colheaders,'EffectiveMass'));
    
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
    HeaderName=variableName;
    
    if string(HeaderName)~='HeaderGroup'
        Scol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),3));
        Ecol=str2num(HeaderGroup(find(strcmp(HeaderGroup(:,1),HeaderName) == true),4));
        if Scol==Ecol
            varData=org.data(:,Scol);
        else
            varData=org.data(:,Scol:Ecol);
        end
    else
        varData=HeaderGroup(:,1);
    end
end