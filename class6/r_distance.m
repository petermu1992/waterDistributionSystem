junctionIndex=wds.getNodeJunctionIndex;
% hydraulic analysis
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
np_origin_avg=mean(np_origin);
np_origin_avg=np_origin_avg(:,1:end-2);
% sensitivity matrix build
senMartix=zeros(length(junctionIndex),length(junctionIndex));
for i=1:length(junctionIndex)
%     qrand = LDD_min+(LDD_max-LDD_min).*rand();
    wds.setNodeBaseDemands(junctionIndex(i),nodeDemand(junctionIndex(i))+qrand);
    wds.openHydraulicAnalysis;
    wds.initializeHydraulicAnalysis;
    iii=1;np_leak=[];
    while (iii<=t_tot)
        t=wds.runHydraulicAnalysis;
        nodePressure1=wds.getNodePressure;
        np_leak=[np_leak;nodePressure1];
        tstep=wds.nextHydraulicAnalysisStep;
        iii=iii+1;
    end
    wds.closeHydraulicAnalysis();
    wds.setNodeBaseDemands(junctionIndex(i),nodeDemand(junctionIndex(i)));
    for j=1:length(junctionIndex)
        if(np_origin(junctionIndex(i))-np_leak(junctionIndex(i))~=0)
            senMartix(i,j)=mean((np_origin(:,junctionIndex(j))-np_leak(:,junctionIndex(j)))./...
                (np_origin(:,junctionIndex(i))-np_leak(:,junctionIndex(i))));
        else
             senMartix(i,j)=0;
        end
    end
end
% standardization
senMartix_s=abs(senMartix-repmat(mean(senMartix),length(junctionIndex),1))./...
    (repmat(std(senMartix),length(junctionIndex),1));
% polarization
senMartix_p=(senMartix_s-repmat(min(senMartix_s),length(junctionIndex),1))./...
    (repmat(max(senMartix_s),length(junctionIndex),1)-repmat(min(senMartix_s),length(junctionIndex),1));
% distance 

senMartix_d=zeros(length(junctionIndex),length(junctionIndex));
for i=1:length(junctionIndex)
    for j=1:length(junctionIndex)
        senMartix_d(i,j)=1-sqrt(sum((senMartix_p(i,:)-senMartix_p(j,:)).^2)/length(junctionIndex));
    end
end
senMartix_d_avg=(sum(senMartix_d)-1)/(length(junctionIndex)-1);