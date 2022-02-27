function CCC=pumpfull(u,d)
junctionIndex=d.getNodeJunctionIndex;
outflowIndex=9;
outpressureIndex=1;
% hydraulic analysis
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1;T_H=[];np_origin=[];LinkHead=[];LinkFlow=[];nodeDemand=[];eff=[];
iii=1;
while (iii<=length(u))
    t=d.runHydraulicAnalysis;
    nodePressure1=d.getNodePressure;
    nodeDemand1=d.getNodeActualDemand;
    nodeDemand=[nodeDemand;nodeDemand1];
    np_origin=[np_origin;nodePressure1];
    linkflow1=d.getLinkFlows;
    LinkFlow=[LinkFlow;linkflow1];
    eff1=d.getLinkEfficiency;
    eff=[eff;eff1(outflowIndex)];
    tstep=d.nextHydraulicAnalysisStep;
    iii=iii+1;
end
d.closeHydraulicAnalysis();
C=0;
CCC=[];
k=0.01019;
for i=1:length(u)
    E(i)=k*1*LinkFlow(i,outflowIndex)*np_origin(i,outpressureIndex)*u(i)/eff(i);
    if(i<=5)
        CCC(i)=E(i)*0.8443;
        C=C+E(i)*0.8443;
    elseif(i>5 && i<=10)
        C=C+E(i)*1.2898;
        CCC(i)=E(i)*1.2898;
    else
        C=C+E(i)*0.4188;
        CCC(i)=E(i)*0.4188;
    end
end