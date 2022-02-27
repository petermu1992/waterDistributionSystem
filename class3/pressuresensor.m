setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
clc
clear
addpath(genpath(pwd));
disp('EPANET-MATLAB Toolkit Paths Loaded.');    
wds = epanet('xiaomu.inp'); %input the WDS into matlab
%% Variables defination
LDD=241.16; %Leakage Discharge Demand
LDD_rate=0.03;
qrand=LDD_rate*LDD;
t_tot=12; %totoal of EPS time
%% sensitivity analysis %%%%
r_distance; %solve the average of distance R
[B,I] = sort(senMartix_d_avg,'descend');
plotnetwork(I(1),wds);