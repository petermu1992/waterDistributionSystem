setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
clc
clear
addpath(genpath(pwd));
disp('EPANET-MATLAB Toolkit Paths Loaded.');    
wds = epanet('xiaomu.inp'); %input the WDS into matlab
%% Variables defination
t_tot=12; %totoal of EPS time.
LDD=241.16; %Leakage Discharge Demand
LDD_rate=0.03;
qrand=LDD_rate*LDD;
tankindex=8;
resindex=7;
%% run
linkIndex=wds.getLinkIndex;
junctionIndex=wds.getNodeJunctionIndex;
wds.openHydraulicAnalysis;
wds.initializeHydraulicAnalysis;
tstep=1;T_H=[];np_origin=[];LinkHead=[];LinkFlow=[];nodeDemand=[];
iii=1;
while (iii<=t_tot)
    t=wds.runHydraulicAnalysis;
    nodePressure1=wds.getNodePressure;
    nodeDemand1=wds.getNodeActualDemand;
    nodeDemand=[nodeDemand;nodeDemand1];
    np_origin=[np_origin;nodePressure1];
    linkflow1=wds.getLinkFlows;
    LinkFlow=[LinkFlow;linkflow1];
    tstep=wds.nextHydraulicAnalysisStep;
    iii=iii+1;
end
wds.closeHydraulicAnalysis();
% sensitivity matrix build
senMartix=zeros(length(junctionIndex),length(linkflow1));
for i=1:length(junctionIndex)
%     qrand = LDD_min+(LDD_max-LDD_min).*rand();
    wds.setNodeBaseDemands(junctionIndex(i),nodeDemand(junctionIndex(i))+qrand);
    wds.openHydraulicAnalysis;
    wds.initializeHydraulicAnalysis;
    iii=1;np_leak=[];LinkFlow_leak=[];
    while (iii<=t_tot)
        t=wds.runHydraulicAnalysis;
        nodePressure1=wds.getNodePressure;
        np_leak=[np_leak;nodePressure1];
        linkflow1_leak=wds.getLinkFlows;
        LinkFlow_leak=[LinkFlow_leak;linkflow1_leak];
        tstep=wds.nextHydraulicAnalysisStep;
        iii=iii+1;
    end
    wds.closeHydraulicAnalysis();
    wds.setNodeBaseDemands(junctionIndex(i),nodeDemand(junctionIndex(i)));
    for j=1:length(linkflow1)
        senMartix(i,j)=mean(abs(np_origin(:,junctionIndex(i))-np_leak(:,junctionIndex(i)))./...
            abs(LinkFlow(:,linkIndex(j))-LinkFlow_leak(:,linkIndex(j))));
    end
end
senMartix(isnan(senMartix))=0;
senMartix1=sqrt(sum(senMartix.^2));
[B,I] = sort(senMartix1,'descend');
plotnetwork(I(1:3),wds);
