function plotnetwork(fidx,wds)
nodeSet1 = wds.getNodeNameID(fidx);
colorLinkSet1 = repmat({'y'},1,length(nodeSet1));
% nodeSet2 = d.getNodeNameID([5,6,7,8]);
% colorLinkSet2=repmat({'g'},1,length(nodeSet2));
wds.plot('highlightnode',nodeSet1)