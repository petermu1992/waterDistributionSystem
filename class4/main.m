%% ˮ�õ���
setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
clc
clear
addpath(genpath(pwd));
disp('EPANET-MATLAB Toolkit Paths Loaded.');    
d=epanet('pump.inp');
%ȫ���ʼ���
u=d.getPattern();
u=u(2,:);
C_full=pumpfull(u,d);
c=sum(C_full)
%�Ż�����
EPS_time=12;
[bestnest,fmin]=pump(EPS_time,d,c*0.2);%�ɵ�80%�ķ���
rate=bestnest;
cost=fmin;