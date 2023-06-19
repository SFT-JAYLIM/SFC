# Consulting_Solver_Package

1. 함께 포함되어있는 Python 3.8.0버전 설치
2. 설치하면서 환경변수 포함 체크박스 체크
3. cmd 실행해서 python --version 입력했을때 python 3.8.0 출력되는거 확인
4. pip install --upgrade pip 실행해서 pip 최신화
5. pip install tensorflow==2.4 실행
6. 설정완료
7. Matlab/Find_ColliPos 폴더에서 Find_ColliPos 실행
8. Find_ColliPos('ST_MotionInfo.txt 및 ST_RobotInfo.txt 파일이 위치하고 있는 경로', 'InputData 폴더 경로')
9. ST_RobotInfo.txt의 EERotate값을 수정하여 ColliPos 위치 추출
10. Safetics.SolverTest.exe 실행
11. ST_MotionInfo.txt 및 ST_RobotInfo.txt 파일이 위치하고 있는 경로 입력
12. 해석완료
13. Matlab 폴더에서 Plot_CRI 실행
14. Plot_CRI('ST_MotionInfo.txt 및 ST_RobotInfo.txt 파일이 위치하고 있는 경로', 'InputData 폴더 경로')
15. 영상생성 완료

- Radius와 Fillet의 사용 범위<br/>
Shape1:
5 < Radius < 1000, 
Fillet = 0<br/>
Shape5:
5 < Radius < 100, 
1 < Fillet < 18<br/>
Shape8:
Radius = 0, 
1 < Fillet  < 14
