function FrameData = WriteWaterMark(FrameData, WaterMarkImage)
[X, Y, ~] = size(WaterMarkImage);

RMax = max(max(WaterMarkImage(:, :, 1)));
GMax = max(max(WaterMarkImage(:, :, 2)));
BMax = max(max(WaterMarkImage(:, :, 3)));
for Row = 1:X
    for Col = 1:Y
        DataSum = WaterMarkImage(Row, Col, 1) + WaterMarkImage(Row, Col, 2) + WaterMarkImage(Row, Col, 3);
        if (DataSum ~= 765)
            FrameData(Row + 40, Col + 48, :) = WaterMarkImage(Row, Col, :);
        end
    end
end
end