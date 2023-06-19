function DHparam = Set_RobotModel(Path, RobotModel)

pathfilename=[Path, '\Robot_Model\', RobotModel,'.txt'];
fileID = fopen(pathfilename,'r');
in_data_cell = textscan(fileID,'%s');
fclose(fileID);

in_data=(in_data_cell{1,1});
in_data_size = size(in_data, 1);

for i = 1:in_data_size
    
    if in_data{i}(1) == '#'
        key = in_data{i}(2:end);
        count = 1;
    else
        if key == "a"
            
            a(count) = str2double(in_data{i});
            count = count + 1;
            
        elseif key == "d"
            
            d(count) = str2double(in_data{i});
            count = count + 1;
            
        elseif key == "Robot_alpha"
            
            alpha(count) = str2double(in_data{i});
            count = count + 1;
            
        elseif key == "STL_Pose"
            STL_Pose(count) = str2double(in_data{i});
            count = count + 1;
            
        elseif key == "Theta"
            Theta(count) = str2double(in_data{i});
            count = count + 1;
        end
    end
end

DHparam.a = a;
DHparam.alpha = alpha;
DHparam.d = d;
DHparam.Theta = Theta;
DHparam.STL_Pose = STL_Pose;
end