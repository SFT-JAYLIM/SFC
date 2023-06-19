function SplitDone = SaveVideoSplitImg(gSeqData)

UserPath=gSeqData.FolderInfo.UserPath;
SplitDone=0;

try
    
    clc
    %Default Path Set
    ImgDimension = [1 35];
    
    VideoFileFolder=[UserPath,'\output'];
    FolderList=dir(VideoFileFolder);
    
    VideoIdx=find(not(cellfun('isempty',strfind({FolderList.name},'RiskSpace.mp4'))));
    
    [m n]=size(VideoIdx);
    
    i=1;
    
    for i=1:n
        FileName=char(FolderList(VideoIdx(i)).name);
        FilePath=[VideoFileFolder,'\',FileName];
        if contains(FileName,'ISO')
            SavePath=[VideoFileFolder,'\ISO_RiskSpace'];
            disp('Generate the split image for ISO results Start!!')
        elseif contains(FileName,'KHU')
            SavePath=[VideoFileFolder,'\KHU_RiskSpace'];
            disp('Generate the split image for KOROS results START!!')
        end
        
        if isfolder(SavePath)
            delete([SavePath,'\*.jpg']);
        else
            mkdir(SavePath);            
        end
        
        ORG=VideoReader(FilePath);
        
        VideoLength=ORG.Duration;
        
        if ((VideoLength>0) & (VideoLength<=5))
            Interval=0.1;
        elseif ((VideoLength>5) & (VideoLength<=20))
            Interval=0.1;
        elseif ((VideoLength>20) & (VideoLength<=60))
            Interval=0.5;
        elseif ((VideoLength>60) & (VideoLength<=120))
            Interval=1;
        elseif ((VideoLength>120) & (VideoLength<=300))
            Interval=2;
        elseif ((VideoLength>300) & (VideoLength<=500))
            Interval=5;
        elseif VideoLength>500
            Interval=5;
        end
        
        Scale=Interval/(1/ORG.FrameRate);
        TimeStep=Scale*(1/ORG.FrameRate);
        ScaleInput=0.15;
        
        Count=1;
        CRfunc = 1;
        
        for i = 1 : ORG.FrameRate * ORG.Duration
            if i==1
                Video = read(ORG,i);
                grayImage = min(Video, [], 3);
                binaryImage = grayImage < 254;
                binaryImage = bwareafilt(binaryImage, 1);
                [rows, columns] = find(binaryImage);
                
                row1 = min(rows);
                row2 = max(rows+30);
                col1 = min(columns);
                col2 = max(columns+20);

                croppedImage = Video(row1:row2, col1:col2, :);

                ResizedVideo = imresize(croppedImage,ScaleInput);
                ImgFileName=[SavePath,'\',sprintf('%06.0f',Count),'.jpg'];
                imwrite(ResizedVideo,ImgFileName);
                Count=Count+1;
            else
                if ((rem(i,Scale) == 0) && (i~=(ORG.FrameRate * ORG.Duration))) % time step = 1/v.FrameRate*30
                    Video = read(ORG,i+1);
                    ResizedVideo = imresize(Video,ScaleInput);
                    ImgFileName=[SavePath,'\',sprintf('%06.0f',Count),'.jpg'];
                    imwrite(ResizedVideo,ImgFileName);
                    Count=Count+1;
                end
            end
        end
        disp('Generate the split image done!!')
        SplitDone=1;
    end
    

catch exeception
    SplitDone=0;
    disp('[Status] = Error Occured during the Generate the Slpit Image')
    disp(['[Status] = Function name : ', exception.stack.name])
    disp(['[Status] = Line : ', exception.stack.line])
    disp(['[Status] = Error message: ', exception.message])
    
end

end
