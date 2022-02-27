setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
clc
clear
addpath(genpath(pwd));
disp('EPANET-MATLAB Toolkit Paths Loaded.');    
wds = epanet('xiaomu.inp'); %input the WDS into matlab
%% Variables defination
t_tot=12; %totoal of EPS time
tankindex=8;
resindex=7;
cc=0.5;
%% run
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
LinkFlow_avg=mean(LinkFlow);
num_nodes=wds.getNodeCount;
num_junctions=wds.getNodeJunctionCount;
S=wds.getLinkNodesIndex;
S1=S(:,1);
S2=S(:,2);
W = LinkFlow_avg;
sumQMat=zeros(num_nodes,1);
sigQMat=zeros(num_nodes,num_nodes);
for i=1:num_nodes
    for j=1:length(S1)
        if(S1(j)==i && W(j)<=0)
            sumQMat(i)=sumQMat(i)-W(j);
            sigQMat(S1(j),S2(j))=-W(j);
        end
    end
    for j=1:length(S2)
        if(S2(j)==i && W(j)>=0)
            sumQMat(i)=sumQMat(i)+W(j);
            sigQMat(S2(j),S1(j))=W(j);
        end
    end
end
wq=zeros(num_nodes,num_nodes);
for i=1:num_nodes
    wq(i,:)=sigQMat(i,:)./sumQMat(i);
end
wq(isnan(wq))=0;
wq(wq<cc)=0;
wq(wq>=cc)=1;
for i=1:num_nodes
    wq(:,i)=sigQMat(:,i).*sumQMat(i);
end
dc=sum(wq);
[B,I] = sort(dc,'descend');
plotnetwork(I(1:3),wds);
% for i=1:length(S1)
%     if(W(i)>=0)
%         conMat(S1(i),S2(i))=W(i);
%     else
%         conMat(S2(i),S1(i))=-W(i);
%     end
% end