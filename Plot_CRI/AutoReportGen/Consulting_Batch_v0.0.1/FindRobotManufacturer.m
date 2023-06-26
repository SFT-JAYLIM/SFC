function RetValue=FindRobotManufacturer (RobotModel)

    UR={'UR3', 'UR5', 'UR10', 'UR3e', 'UR5e', 'UR10e', 'UR16e', 'UR20'};
    DooSan={'A0509', 'A0509s', 'A0912', 'A0912s', 'H2017', 'H2515', 'M0609', 'M0617', 'M1013', 'M1509'};
    HyunDai={'YL012'};
    NM={'Indy7', 'Indy7-Pro', 'Indy12', 'Indy7-RP2', 'Indy3', 'Indy5', 'Indy10', 'IndyCB'};
    RB={'RB3', 'RB5', 'RB10'};
    WIA={'HW1513'};
    HanHwa={'HCR-5A ', 'HCR-12A '};
    TM={'TM5-700', 'TM5-900', 'TM12', 'TM14', 'TM16', 'TM20'};
   
    for i=1:size(UR, 2)
        if strcmpi(UR{i}, RobotModel)
            RetValue={'UNIVERSAL ROBOTS', '유니버설로봇'};
        end
    end
    
    for i=1:size(DooSan, 2)
        if strcmpi(DooSan{i}, RobotModel)
            RetValue={'DOOSAN ROBOTICS', '두산로보틱스'};
        end
    end
    
    for i=1:size(HyunDai, 2)
        if strcmpi(HyunDai{i}, RobotModel)
            RetValue={'HYUNDAI ROBOTICS', '현대로보틱스'};
        end
    end
    
    for i=1:size(NM, 2)
        if strcmpi(NM{i}, RobotModel)
            RetValue={'NEUROMEKA', '뉴로메카'};
        end
    end
    
    for i=1:size(RB, 2)
        if strcmpi(RB{i}, RobotModel)
            RetValue={'RAINBOW ROBOTICS', '레인보우로보틱스'};
        end
    end
    
    for i=1:size(WIA, 2)
        if strcmpi(WIA{i}, RobotModel)
            RetValue={'HYUNDAI WIA', '현대위아'};
        end
    end
    
    for i=1:size(HanHwa, 2)
        if strcmpi(HanHwa{i}, RobotModel)
            RetValue={['HANWHA CORPORATION/MOMENTUM','''','S'], '한화/모멘텀'};
        end
    end
    
    for i=1:size(TM, 2)
        if strcmpi(TM{i}, RobotModel)
            RetValue={'TECHMAN ROBOT', 'TM 로봇'};
        end
    end

end