[file path] = uigetfile('*.*');
v = VideoReader([path file]);
foldername=['/',file(1:end-4)];
[status, msg, msgID] = mkdir(path,foldername);

prompt = {'Sampling time [sec]'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'1'};
target_time = str2double(inputdlg(prompt,dlgtitle,dims,definput));

% target_time = 4

scale_num=target_time/(1/v.FrameRate);
time_step =scale_num*(1/v.FrameRate)

count=1;

prompt = {'Image Reduction Scale 0...1'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'0.15'};
scaleinput = str2double(inputdlg(prompt,dlgtitle,dims,definput));

cropinput= questdlg('crop?','Menu', 'Yes','No','No');
switch cropinput
    case 'Yes'
        CRfunc = 1;
    case 'No'
        CRfunc = 0;
end

for i = 1 : v.FrameRate * v.Duration; 
    video = readFrame(v);
    if rem(i,scale_num) ==0  % time step = 1/v.FrameRate*30
        
        video = imresize(video,scaleinput);
        if count==1 && CRfunc==1
            [J,rect] = imcrop(video);    
            video = imcrop(video, rect);
        elseif count>1 && CRfunc==1
            video = imcrop(video, rect);
        end

        imwrite(video,strcat(path,[foldername,'/'],sprintf('%06.0f',count),'.jpg'),'jpg');
        image_data{i}=video;
        count=count+1;
    end
end
