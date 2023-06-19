function DrawingPos = Set_DrawingImage(UserPath)

pnglist = dir([UserPath, '/bluePrint.png']);

if size(pnglist, 1)
    DrawingPos.DrawingFlag = 1;
    if size(pnglist, 1)
        img = imread(UserPath + "/" + pnglist.name);
    end
    
    DrawingPos.Image = img;

else
    DrawingPos.DrawingFlag = 0;
    
end
end