function [ISOData, ISOFlag, KHUData, KHUFlag] = CSVDataLoad(UserPath)
%% Load ISO Data

ISOPath = strcat(UserPath,'/ISO_Collision_Risk_Analyze_Result.csv');
if (exist(ISOPath, 'file') == 2)
    ISOTextData = readtable(ISOPath);
    Cell_Label = ISOTextData.Properties.VariableNames;
    Label_list = strings(1, length(Cell_Label));
    for i = 1:length(Cell_Label)
        Label = cell2mat(Cell_Label(i));
        index = strfind(Label, '_');
        if index > 0
            Label = Label(1:index - 1);
        end
        Label_list(1, i) = Label;
    end
    
    Time_index = Label_list == "Time";
    CRI_index = Label_list == "CRI";
    ImpactPos_index = find(Label_list == "ImpactPosList");
    q_series_index = Label_list == "q";
    BasePosition_index = Label_list == "BasePosition";
    MotionDivision_index = Label_list == "MotionDivisionIndex";
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Force_index = Label_list == "Force";
%     ISOData.Force = ISOTextData(:, Force_index).Variables;
%     
%     Pressure_index = Label_list == "Pressure";
%     ISOData.Pressure = ISOTextData(:, Pressure_index).Variables;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ISOData.Time = ISOTextData(:, Time_index).Variables;
    ISOData.CRI = ISOTextData(:, CRI_index).Variables;
    ImpactPos_list = ISOTextData(:,ImpactPos_index).Variables;
    ISOData.ImpactPos = cell(length(ImpactPos_index) / 3, 1);
    for i = 1:length(ImpactPos_index) / 3
        sub_ImpactPos_list = ImpactPos_list(:, 1:3)';
        ImpactPos_list(:, 1:3) = [];
        ISOData.ImpactPos{i, 1} = sub_ImpactPos_list;
    end
    ISOData.q_series = ISOTextData(:, q_series_index).Variables;
    ISOData.BasePosition = ISOTextData(:, BasePosition_index).Variables;
    ISOData.MotionDivisionIndex = ISOTextData(:, MotionDivision_index).Variables;
    [Row, ~] = size(ISOTextData);
    if (isempty(ISOData.BasePosition))
        ISOData.BasePosition = zeros(Row, 3);
    end
    ISOFlag = true;
    ISOData.DataType = 'ISO';
else
    ISOData = 0;
    ISOFlag = false;
end

%% Load KHU Data

KHUPath = strcat(UserPath,'/KHU_Collision_Risk_Analyze_Result.csv');
if (exist(KHUPath, 'file') == 2)
    KHUTextData = readtable(KHUPath);
    Cell_Label = KHUTextData.Properties.VariableNames;
    Label_list = strings(1, length(Cell_Label));
    for i = 1:length(Cell_Label)
        Label = cell2mat(Cell_Label(i));
        index = strfind(Label, '_');
        if index > 0
            Label = Label(1:index - 1);
        end
        Label_list(1, i) = Label;
    end
    
    Time_index = Label_list == "Time";
    CRI_index = Label_list == "CRI";
    ImpactPos_index = find(Label_list == "ImpactPosList");
    q_series_index = Label_list == "q";
    BasePosition_index = Label_list == "BasePosition";
    MotionDivision_index = Label_list == "MotionDivisionIndex";
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Force_index = Label_list == "Force";
%     KHUData.Force = KHUTextData(:, Force_index).Variables;
%     
%     Pressure_index = Label_list == "Pressure";
%     KHUData.Pressure = KHUTextData(:, Pressure_index).Variables;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    KHUData.Time = KHUTextData(:, Time_index).Variables;
    KHUData.CRI = KHUTextData(:, CRI_index).Variables;
    ImpactPos_list = KHUTextData(:,ImpactPos_index).Variables;
    KHUData.ImpactPos = cell(length(ImpactPos_index) / 3, 1);
    for i = 1:length(ImpactPos_index) / 3
        sub_ImpactPos_list = ImpactPos_list(:, 1:3)';
        ImpactPos_list(:, 1:3) = [];
        KHUData.ImpactPos{i, 1} = sub_ImpactPos_list;
    end
    KHUData.q_series = KHUTextData(:, q_series_index).Variables;
    KHUData.BasePosition = KHUTextData(:, BasePosition_index).Variables;
    KHUData.MotionDivisionIndex = KHUTextData(:, MotionDivision_index).Variables;
    
    [Row, ~] = size(KHUTextData);
    if (isempty(KHUData.BasePosition))
        KHUData.BasePosition = zeros(Row, 3);
    end
    KHUFlag = true;
    KHUData.DataType = 'KHU';
else
    KHUData = 0;
    KHUFlag = false;
end

fileID = fopen([UserPath, '\', 'PlotCRI.txt'], 'w');
fprintf(fileID, '%s', '1');  % 데이터 로드 성공
fclose(fileID);

end