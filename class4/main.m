%% 水泵调度
setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
clc
clear
addpath(genpath(pwd));
disp('EPANET-MATLAB Toolkit Paths Loaded.');    
d=epanet('pump.inp');
%全功率计算
u=d.getPattern();
u=u(2,:);
C_full=pumpfull(u,d);
c=sum(C_full)
%优化调度
EPS_time=12;
[bestnest,fmin]=pump(EPS_time,d,c*0.2);%干掉80%的费用
rate=bestnest;
cost=fmin;