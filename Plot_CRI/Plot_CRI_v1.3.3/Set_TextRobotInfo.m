function RobotInfo = Set_TextRobotInfo(Path)

pathfilename = [Path,'\ST_RobotInfo.txt'];
fileID = fopen(pathfilename,'r');
in_data_cell = textscan(fileID,'%s');
in_data = (in_data_cell{1,1});
fclose(fileID);

% 로봇 이름
RobotModelidx=find(contains(in_data, '#RobotModel'));
if isempty(RobotModelidx)
    RobotInfo.RobotModel = strings(0);
else
    RobotInfo.RobotModel = cell2mat(in_data(RobotModelidx(1)+1));
end

% BaseModel
BaseModelidx=find(contains(in_data, '#BaseModel'));
if isempty(BaseModelidx)
    RobotInfo.BaseModel = strings(0);
else
    RobotInfo.BaseModel = cell2mat(in_data(BaseModelidx(1)+1));
end

% 비디오 저장 여부
SaveVideoidx=[find(contains(in_data, '#SaveVideo')) 1];
RobotInfo.SaveVideo = cell2mat(in_data(SaveVideoidx(1)+1));

% 도면 축척
DrawingScaleidx=[find(contains(in_data,'#DrawingScale')) 1];
RobotInfo.DrawingScale = str2double(cell2mat(in_data(DrawingScaleidx(1)+1)));

% 도면 위치
DrawingPositionidx = find(contains(in_data, '#DrawingPosition'));
RobotInfo.DrawingPosition(1) = str2double(cell2mat(in_data(DrawingPositionidx + 1)));
RobotInfo.DrawingPosition(2) = str2double(cell2mat(in_data(DrawingPositionidx + 2)));

% 평행이동 계수
PlanePositionidx = find(contains(in_data, '#PlanePosition'));
RobotInfo.BasePlanePosition(1) = str2double(cell2mat(in_data(PlanePositionidx + 1)));
RobotInfo.BasePlanePosition(2) = str2double(cell2mat(in_data(PlanePositionidx + 2)));
RobotInfo.BasePlanePosition(3) = str2double(cell2mat(in_data(PlanePositionidx + 3)));

% 회전이동 계수
Rotationidx = find(contains(in_data, '#Rotation'));
RobotInfo.BaseRotation(1) = str2double(cell2mat(in_data(Rotationidx + 1)));
RobotInfo.BaseRotation(2) = str2double(cell2mat(in_data(Rotationidx + 2)));
RobotInfo.BaseRotation(3) = str2double(cell2mat(in_data(Rotationidx + 3)));

% StepTime
StepTimeidx=find(contains(in_data, '#StepTime'));
RobotInfo.StepTime = str2double(cell2mat(in_data(StepTimeidx(1) + 1)));

% 충돌 부위
ColliJointidx = find(contains(in_data, '#ColliJoint'));
numColliJoint = size(ColliJointidx, 1);
EEColliJoint = [];
LinkColliJoint = [];
for loop=1:numColliJoint
    ColliJoint = str2double(cell2mat(in_data(ColliJointidx(loop)+1)));
    RobotInfo.ColliJoint(1*(loop-1)+1) = ColliJoint;
    if ColliJoint == 6
        EEColliJoint(end+1) = ColliJoint;
    else
        LinkColliJoint(end+1) = ColliJoint;
    end
end
for loop=1:numColliJoint
    ColliJointidxData = cell2mat(in_data(ColliJointidx(loop)));
    ColliJointIdx = extract(ColliJointidxData, digitsPattern);
    RobotInfo.ColliJointIdx(1*(loop-1)+1) = str2double(ColliJointIdx{end});
end


% SafetyDesigner 사용자 선택 여부
CheckBoxidx = find(contains(in_data, '#SetCheckBox'));
numCheckBox = size(CheckBoxidx, 1);
RobotInfo.CheckBox = [];
for loop=1:numCheckBox
    RobotInfo.CheckBox(1*(loop-1)+1) = str2double(cell2mat(in_data(CheckBoxidx(loop)+1)));
end

% 예외처리
LinkNum = sum(RobotInfo.ColliJoint ~= 6);
if size(RobotInfo.CheckBox, 2) ~= LinkNum
    RobotInfo.CheckBox = zeros(1, LinkNum);
    for i = 1:LinkNum
        RobotInfo.CheckBox(i) = 1;
    end
end

ColliRadiidx = find(contains(in_data, '#ColliRadi'));
numColliRadi = size(ColliRadiidx, 1);
for loop=1:numColliRadi
    RobotInfo.ColliRadi(1*(loop-1)+1)=str2double(cell2mat(in_data(ColliRadiidx(loop)+1)));
end

ColliPosidx = find(contains(in_data, '#ColliPos'));
for loop = 1:numColliJoint
    RobotInfo.ColliPos(loop, 1) = str2double(cell2mat(in_data(ColliPosidx(loop)+1)));
    RobotInfo.ColliPos(loop, 2) = str2double(cell2mat(in_data(ColliPosidx(loop)+2)));
    RobotInfo.ColliPos(loop, 3) = str2double(cell2mat(in_data(ColliPosidx(loop)+3)));
end

% 협동공간
CLBidx = find(contains(in_data, '#ColliBody'));
CLBCidx = find(contains(in_data, '#ColliBodyCloth'));
CLBidx = setdiff(CLBidx, CLBCidx);
RobotInfo.numColliBody = size(CLBidx,1);
RobotInfo.ColliBody = strings(0, 0);
for loop = 1:RobotInfo.numColliBody
    RobotInfo.ColliBody(end+1) = cell2mat(in_data(CLBidx(loop)+1));
end

CLHsidx = find(contains(in_data, '#Hspace'));
if isempty(CLHsidx) || strcmp(in_data{CLHsidx(1) + 1}(1), '#')
    RobotInfo.Hspace = '';
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
if size(stllist, 1) > 1
    RobotInfo.EEstlpath = [Path, '/CustomEEAnalysis.stl'];
elseif size(stllist, 1) > 0
    RobotInfo.EEstlpath = [Path, '/', stllist.name];
else
    RobotInfo.EEstlpath = char.empty;
end

% End-Effector 회전량 입력
EERotateidx = [find(contains(in_data, '#EERotate')) 0];
RobotInfo.EERotate = str2double(cell2mat(in_data(EERotateidx(1) + 1)));

% Json의 MotionDivision 대응
RobotInfo.RobotLinkNum = {};
RobotLinkNum = [];
for i = 1:size(LinkColliJoint, 2)
    RobotLinkNum(end+1) = i;
end
RobotInfo.RobotLinkNum{end+1} = RobotLinkNum;

RobotInfo.EENum = {};
EENum = [];
for i = 1:size(EEColliJoint, 2)
    EENum(end+1) = i;
end
RobotInfo.EENum{end+1} = EENum;
RobotInfo.PointType = [zeros(size(LinkColliJoint)), ones(size(EEColliJoint))];
end