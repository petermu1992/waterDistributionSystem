clc
clear
global d e_num
%% Data Input
setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
addpath(genpath(pwd));
disp('EPANET-MATLAB Toolkit Paths Loaded.');    
d=epanet('Exa7.inp');
e_num=24;
SCADA_ID=dlmread('exa_scada monitor Id.txt'); %SCADA monitor ID
%% Variables define
SCADA_Index=zeros(1,length(SCADA_ID));  %SCADA monitor Index
LDD=66; %LeakageDischargeDemand= 69 gpm
LDD_rate=0.03;
qrand=LDD_rate*LDD;
clusterMarix=zeros(d.getNodeCount-length(SCADA_ID),length(SCADA_ID));
nodeDemand=d.getNodeBaseDemands;
NodeCount=d.getNodeCount;
clustering=5; % divide network into 10 areas
optimizedFactor=10;
hoursum=24;
kNearest=10;%k-nearest neighbor
chushu=10; %a variable number of 1 or 0
%% data partitioning process
%%%% convert SCADA monitor ID to Index %%%%
for i=1:length(SCADA_ID)
    SCADA_Index(i)=d.getNodeIndex(num2str(SCADA_ID(i))); 
end
%%%% end %%%%
%%%% Hydraulic Analysis of normal %%%%
junctionIndex=d.getNodeJunctionIndex;
clusterMarix=zeros(d.getNodeJunctionCount,length(SCADA_ID));
% hydraulic analysis
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1;T_H=[];np_origin=[];LinkHead=[];LinkFlow=[];nodeDemand=[];
iii=1;
while (iii<=hoursum)
    t=d.runHydraulicAnalysis;
    nodeDemand1=d.getNodeActualDemand;
    nodeDemand=[nodeDemand;nodeDemand1];
    nodePressure1=d.getNodePressure(SCADA_Index);
    np_origin=[np_origin;nodePressure1];
    tstep=d.nextHydraulicAnalysisStep;
    iii=iii+1;
end
d.closeHydraulicAnalysis();
demands=d.getNodeBaseDemands;
for i=1:length(junctionIndex)
    d.setNodeBaseDemands(junctionIndex(i),demands{1}(junctionIndex(i))+qrand);
    d.openHydraulicAnalysis;
    d.initializeHydraulicAnalysis;
    iii=1;np_leak=[];
    while (iii<=hoursum)
        t=d.runHydraulicAnalysis;
        nodePressure1=d.getNodePressure(SCADA_Index);
        np_leak=[np_leak;nodePressure1];
        tstep=d.nextHydraulicAnalysisStep;
        iii=iii+1;
    end
    d.closeHydraulicAnalysis();
    d.setNodeBaseDemands(junctionIndex(i),demands{1}(junctionIndex(i)));
    for j=1:length(SCADA_ID)
        clusterMarix(i,j)=mean((np_origin(:,j)-np_leak(:,j)));
    end
end
senMartix_p=clusterMarix;
%%%% end %%%%
%%%% FCM %%%%
options = nan(4,1);
options(2) = 100;
options(4) = 0;
[centres,U] = fcm(senMartix_p,clustering, options);
[~, fidx] = max(U);
fidx = fidx';
tabulate(fidx)
%%%% end %%%%
fidx_scada=zeros(length(fidx),1);
fidx_scada(SCADA_Index)=1;
plotnetwork(fidx_scada,1,d);
plotnetwork(fidx,clustering,d);
%% BP network
[res,trainedNet]=sjwl(senMartix_p,fidx);
res1=round(res);
acc=0;
for i=1:length(res1) 
    if res1(i)==fidx(i) 
        acc=acc+1; 
    end 
end 
acc=acc/length(res1)
%% test model
%%%% Hydraulic Analysis of normal %%%%
testNode=[1 80 86 89 92];
clusterMarix1=cell(length(testNode),1);
senMartix_s1=cell(length(testNode),1);
senMartix_p1=cell(length(testNode),1);
res2=cell(length(testNode),1);
k=1;
for i=[1 85 88 90 93]
    d.setNodeBaseDemands(junctionIndex(i),demands{1}(junctionIndex(i))+qrand);
    d.openHydraulicAnalysis;
    d.initializeHydraulicAnalysis;
    iii=1;np_leak=[];
    while (iii<=hoursum)
        t=d.runHydraulicAnalysis;
        nodePressure1=d.getNodePressure(SCADA_Index);
        np_leak=[np_leak;nodePressure1];
        tstep=d.nextHydraulicAnalysisStep;
        iii=iii+1;
    end
    d.closeHydraulicAnalysis();
    d.setNodeBaseDemands(junctionIndex(i),demands{1}(junctionIndex(i)));
    for j=1:length(SCADA_ID)
        clusterMarix(i,j)=mean((np_origin(:,j)-np_leak(:,j)));
    end
    clusterMarix1{k,1}=np_origin-np_leak;
    k=k+1;
end
% standardization
senMartix1=clusterMarix1;
[pn,minp,maxp,tn,mint,maxt]=premnmx(senMartix_p',fidx');
for i=1:length(testNode)
    for j=1:24
        if(j>=2)
            pnewn=tramnmx(mean(senMartix1{i,1}(1:j,:))',minp,maxp); %利用原始输入数据的归一化参数对新数据进行归一化；
            anewn=sim(trainedNet,pnewn);            %利用归一化后的数据进行仿真；
            anew=postmnmx(anewn,mint,maxt);  %把仿真得到的数据还原为原始的数量级；
            res2{i,1}(j,1)=round(anew);
        else
            pnewn=tramnmx(senMartix1{i,1}(1:j,:)',minp,maxp); %利用原始输入数据的归一化参数对新数据进行归一化；
            anewn=sim(trainedNet,pnewn);            %利用归一化后的数据进行仿真；
            anew=postmnmx(anewn,mint,maxt);  %把仿真得到的数据还原为原始的数量级；
            res2{i,1}(j,1)=round(anew); 
        end
    end
end
fidx([1 85 88 90 93])
%%%% end %%%%