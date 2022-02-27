setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
clc
clear
addpath(genpath(pwd));
disp('EPANET-MATLAB Toolkit Paths Loaded.');    
wds = epanet('EXA7.inp'); %input the WDS into matlab
%% Variables defination
LDD=66; %Leakage Discharge Demand
LDD_rate=0.03;
qrand=LDD_rate*LDD;
t_tot=24; %totoal of EPS time
clustering=10;
%% sensitivity analysis %%%%
r_distance; %solve the average of distance R
clusterMarix=senMartix_p';
%%
% [centres,U] = kmeans(clusterMarix,clustering,'Distance','cityblock');
% [~, fidx] = max(U);
% fidx = fidx';
% tabulate(fidx)
%%%% FCM %%%%
options = nan(4,1);
options(2) = 100;
options(4) = 0;
[centres,U] = fcm(clusterMarix,clustering, options);
[~, fidx] = max(U);
fidx = fidx';
tabulate(fidx)
%%%% end %%%%
plotnetwork(fidx,clustering,wds);
%% Outliers
kNearest=10;%k-nearest neighbor
optimizedFactor=10;
chushu=10; %a variable number of 1 or 0
nodeDemand=wds.getNodeBaseDemands;
NodeCount=wds.getNodeCount;
fidx(end+1:NodeCount)=clustering;
datadect