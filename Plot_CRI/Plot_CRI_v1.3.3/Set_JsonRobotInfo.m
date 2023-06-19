function RobotInfo = Set_JsonRobotInfo(Path)
pathfilename = [Path, '\ST_RobotInfo.json'];
fileID = fopen(pathfilename, 'r');
rawdata = fread(fileID, inf);
str = char(rawdata');
fclose(fileID);
JsonRobotInfo = jsondecode(str);

Jsonfieldname = fieldnames(JsonRobotInfo.RobotInfo);

%% BasicInfo
BasicInfo = JsonRobotInfo.RobotInfo.BasicInfo;
BasicInfoFieldName = fieldnames(BasicInfo);

RobotModelidx = find(contains(BasicInfoFieldName, 'RobotModel'), 1);
if isempty(RobotModelidx)
    RobotInfo.RobotModel = strings(0);
else
    RobotInfo.RobotModel = BasicInfo.RobotModel;
end

% BaseModel
BaseModelidx = find(contains(BasicInfoFieldName, 'BaseModel'), 1);
if isempty(BaseModelidx)
    RobotInfo.BaseModel = strings(0);
else
    RobotInfo.BaseModel = BasicInfo.BaseModel;
end

% StepTime
StepTimeidx = find(contains(BasicInfoFieldName, 'StepTime'), 1);
if isempty(StepTimeidx)
    RobotInfo.StepTime = 0.1;
else
    RobotInfo.StepTime = BasicInfo.StepTime;
end

% 비디오 저장 여부
SaveVideoidx = find(contains(BasicInfoFieldName, 'SaveVideo'), 1);
if isempty(SaveVideoidx)
    RobotInfo.SaveVideo = 0;
else
    RobotInfo.SaveVideo = BasicInfo.SaveVideo;
end

% 도면 축척
DrawingScaleidx = find(contains(BasicInfoFieldName, 'DrawingScale'), 1);
if isempty(DrawingScaleidx)
    RobotInfo.DrawingScale = 1;
else
    RobotInfo.DrawingScale = BasicInfo.DrawingScale;
end

% ColliPointImageDivision
ColliPointImageDivisionidx = find(contains(BasicInfoFieldName, 'ColliPointImageDivision'), 1);
if isempty(ColliPointImageDivisionidx)
    RobotInfo.ColliPointImageDivision = 10;
else
    RobotInfo.ColliPointImageDivision = BasicInfo.ColliPointImageDivision;
end

% 도면 위치
DrawingPositionidx = find(contains(BasicInfoFieldName, 'DrawingPosition'), 1);
if isempty(DrawingPositionidx)
    RobotInfo.DrawingPosition(1) = 0;
    RobotInfo.DrawingPosition(2) = 0;
else
    SplitDrawingPosition = split(BasicInfo.DrawingPosition, ' ');
    RobotInfo.DrawingPosition(1) = str2double(SplitDrawingPosition{1});
    RobotInfo.DrawingPosition(2) = str2double(SplitDrawingPosition{2});
end

% 로봇 베이스 평행이동 계수
RobotBasePositionidx = find(contains(BasicInfoFieldName, 'RobotBasePosition'), 1);
if isempty(RobotBasePositionidx)
    RobotInfo.BasePlanePosition(1) = 0;
    RobotInfo.BasePlanePosition(2) = 0;
    RobotInfo.BasePlanePosition(3) = 0;
else
    SplitBasePlanePosition = split(BasicInfo.RobotBasePosition, ' ');
    RobotInfo.BasePlanePosition(1) = str2double(SplitBasePlanePosition{1});
    RobotInfo.BasePlanePosition(2) = str2double(SplitBasePlanePosition{2});
    RobotInfo.BasePlanePosition(3) = str2double(SplitBasePlanePosition{3});
end

% 로봇 베이스 회전이동 계수
RobotBaseRotationidx = find(contains(BasicInfoFieldName, 'RobotBaseRotation'), 1);
if isempty(RobotBaseRotationidx)
    RobotInfo.RobotBaseRotation(1) = 0;
    RobotInfo.RobotBaseRotation(2) = 0;
    RobotInfo.RobotBaseRotation(3) = 0;
else
    RobotBaseRotation = split(BasicInfo.RobotBaseRotation, ' ');
    RobotInfo.BaseRotation(1) = str2double(RobotBaseRotation{1});
    RobotInfo.BaseRotation(2) = str2double(RobotBaseRotation{2});
    RobotInfo.BaseRotation(3) = str2double(RobotBaseRotation{3});
end

EERotationidx = find(contains(BasicInfoFieldName, 'EERotate'), 1);
if isempty(EERotationidx)
    RobotInfo.EERotate = double.empty;
else
    RobotInfo.EERotate = BasicInfo.EERotate;
end

%% CustomEE
CustomEE = JsonRobotInfo.RobotInfo.CustomEE;
CustomEEFieldName = fieldnames(CustomEE);

% 사용자 STL 평행 이동 계수
CustomEEPositionidx = find(contains(CustomEEFieldName, 'CustomEEPosition'), 1);
if isempty(CustomEEPositionidx) || isempty(CustomEE.CustomEEPosition)
    RobotInfo.CustumEEPosition(1) = 0;
    RobotInfo.CustumEEPosition(2) = 0;
    RobotInfo.CustumEEPosition(3) = 0;
else
    CustomEEPosition = split(CustomEE.CustomEEPosition, ' ');
    RobotInfo.CustomEEPosition(1) = str2double(CustomEEPosition{1});
    RobotInfo.CustomEEPosition(2) = str2double(CustomEEPosition{2});
    RobotInfo.CustomEEPosition(3) = str2double(CustomEEPosition{3});
end

% 사용자 STL 회전이동 계수
CustomEERotationidx = find(contains(CustomEEFieldName, 'CustomEERotation'), 1);
if isempty(CustomEERotationidx) || isempty(CustomEE.CustomEERotation)
    RobotInfo.CustomEERotation(1) = 0;
    RobotInfo.CustomEERotation(2) = 0;
    RobotInfo.CustomEERotation(3) = 0;
else
    CustomEERotation = split(CustomEE.CustomEERotation, ' ');
    RobotInfo.CustomEERotation(1) = str2double(CustomEERotation{1});
    RobotInfo.CustomEERotation(2) = str2double(CustomEERotation{2});
    RobotInfo.CustomEERotation(3) = str2double(CustomEERotation{3});
end

%% RobotLink
RobotLink = JsonRobotInfo.RobotInfo.RobotLink;

LinkColliJoint = [];
LinkColliJointIdx = [];
LinkColliPos = [];
LinkColliRadi = [];
LinkCheckBox = [];
LinkColor = strings(0, 0);

for Iterator = 1:size(RobotLink, 1)
    LinkColliJointIdx(end+1) = RobotLink(Iterator).LinkIndex;
    LinkColliJoint(end+1) = RobotLink(Iterator).ColliJoint;
    
    SplitColliPos = split(RobotLink(Iterator).ColliPos, ' ');
    LinkColliPos(end+1, 1) = str2double(SplitColliPos{1});
    LinkColliPos(end, 2) = str2double(SplitColliPos{2});
    LinkColliPos(end, 3) = str2double(SplitColliPos{3});
    
    LinkColliRadi(end+1) = RobotLink(Iterator).ColliRadi;
    LinkCheckBox(end+1) = RobotLink(Iterator).SetCheckBox;
    if (isfield(RobotLink, 'Color'))
        LinkColor(end+1) = RobotLink(Iterator).Color;
    end
end

%% RobotEndEffector
RobotEndEffector = JsonRobotInfo.RobotInfo.RobotEndEffector;

EEColliJoint = [];
EEColliJointIdx = [];
EEColliPos = [];
EEColliRadi = [];
EECheckBox = [];
EEColor = strings(0, 0);

for Iterator = 1:size(RobotEndEffector, 1)
    EEColliJointIdx(end+1) = RobotEndEffector(Iterator).EEIndex;
    EEColliJoint(end+1) = RobotEndEffector(Iterator).ColliJoint;
    
    SplitColliPos = split(RobotEndEffector(Iterator).ColliPos, ' ');
    EEColliPos(end+1, 1) = str2double(SplitColliPos{1});
    EEColliPos(end, 2) = str2double(SplitColliPos{2});
    EEColliPos(end, 3) = str2double(SplitColliPos{3});
    
    EEColliRadi(end+1) = RobotEndEffector(Iterator).ColliRadi;
    EECheckBox(end+1) = true;
    if (isfield(RobotEndEffector, 'Color'))
        EEColor(end+1) = RobotEndEffector(Iterator).Color;
    end
end

%% RiskSpace
RiskSpace = JsonRobotInfo.RobotInfo.RiskSpace;

RobotInfo.ColliBody = strings(0, 0);
RobotInfo.Hspace = [];
for i = 1:size(RiskSpace, 1)
    IterateFieldName = fieldnames(RiskSpace(i))';
    for j = IterateFieldName
        if j{1} == "ColliBody"
            RobotInfo.ColliBody(end+1) = RiskSpace(i).(j{1});
        elseif j{1} == "Hspace"
            Hspace = split(RiskSpace(i).(j{1}), ' ');
            RobotInfo.Hspace(end+1) = str2double(Hspace{1});
            RobotInfo.Hspace(end+1) = str2double(Hspace{2});
            RobotInfo.Hspace(end+1) = str2double(Hspace{3});
            RobotInfo.Hspace(end+1) = str2double(Hspace{4});
        end
    end
end

RobotInfo.numColliBody = size(RobotInfo.ColliBody, 2);

%% MotionDivision
if find(Jsonfieldname=="MotionDivision")
    MotionDivision = JsonRobotInfo.RobotInfo.MotionDivision;
    if ~isempty(MotionDivision)
        RobotInfo.StartTime = [];
        RobotInfo.EndTime = [];
        RobotInfo.EENum = {};
        RobotInfo.RobotLinkNum = {};
        for i = 1:size(MotionDivision, 1)
            RobotInfo.StartTime(end+1) = MotionDivision(i).StartTime;
            RobotInfo.EndTime(end+1) = MotionDivision(i).EndTime;
            EENum = str2double(split(MotionDivision(i).EENum, ' '))';
            RobotInfo.EENum{end+1} = EENum;
            RobotLinkNum = str2double(split(MotionDivision(i).RobotLinkNum, ' '))';
            RobotInfo.RobotLinkNum{end+1} = RobotLinkNum;
        end
    else
        RobotInfo.EENum = {};
        RobotInfo.RobotLinkNum = {};
        RobotLinkNum = [];
        EENum = [];
        for i = 1:size(LinkColliJoint, 2)
            RobotLinkNum(end+1) = i;
        end
        RobotInfo.RobotLinkNum{end+1} = RobotLinkNum;
        for i = 1:size(EEColliJoint, 2)
            EENum(end+1) = i;
        end
        RobotInfo.EENum{end+1} = EENum;
    end
else
    RobotInfo.EENum = {};
    RobotInfo.RobotLinkNum = {};
    RobotLinkNum = [];
    EENum = [];
    for i = 1:size(LinkColliJoint, 2)
        RobotLinkNum(end+1) = i;
    end
    RobotInfo.RobotLinkNum{end+1} = RobotLinkNum;
    for i = 1:size(EEColliJoint, 2)
        EENum(end+1) = i;
    end
    RobotInfo.EENum{end+1} = EENum;
end

%% End-Effector STL 입력 확인
stllist = dir([Path, '/*.stl']);
if size(stllist, 1) > 1
    RobotInfo.EEstlpath = [Path, '/CustomEEAnalysis.stl'];
elseif size(stllist, 1) > 0
    RobotInfo.EEstlpath = [Path, '/', stllist.name];
else
    RobotInfo.EEstlpath = char.empty;
end

%% 최종 RobotInfo
RobotInfo.PointType = [zeros(size(LinkColliJoint)), ones(size(EEColliJoint))];
RobotInfo.ColliJoint = [LinkColliJoint, EEColliJoint];
RobotInfo.ColliJointIdx = [LinkColliJointIdx, EEColliJointIdx];
RobotInfo.ColliPos = [LinkColliPos; EEColliPos];
RobotInfo.ColliRadi = [LinkColliRadi, EEColliRadi];
RobotInfo.CheckBox = [LinkCheckBox, EECheckBox];
% RobotInfo.Color = [LinkColor, EEColor];
RobotInfo.LinkColor = LinkColor;
RobotInfo.EEColor = EEColor;

end