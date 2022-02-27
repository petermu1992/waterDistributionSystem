%% data detection process
NodeConIndex=wds.getLinkNodesIndex;
fidxmodified=fidx;
% for i=1:length(SCADA_Index)
%     tempConect1=NodeConIndex(NodeConIndex(:,1)==SCADA_Index(i),:); %find the conncted node of node ith
%     tempConect2=NodeConIndex(NodeConIndex(:,2)==SCADA_Index(i),:); %find the conncted node of node ith
%     tempConect=[tempConect1(:,2);tempConect2(:,1)];
%     tempHistc=unique(fidxmodified(tempConect(:,1)))';
%     [max_num, max_index]=max(histc(fidxmodified(tempConect(:,1))',tempHistc));
%     fidxmodified(SCADA_Index(i))=tempHistc(max_index);
% end
tempkNearest=kNearest;
%plotnetwork(fidxmodified,clustering,d);
%plotnetwork(fidxmodified,clustering,d);
for ccc=1:optimizedFactor
for j=1:optimizedFactor
     kNearest=tempkNearest;
    for i=1:NodeCount
    %     if fidxmodified(i)==0
    %         continue;
    %     end
        tempConect1=NodeConIndex(NodeConIndex(:,1)==i,:); %find the conncted node of node ith
        tempConect2=NodeConIndex(NodeConIndex(:,2)==i,:); %find the conncted node of node ith
        if isempty(tempConect1) && isempty(tempConect2)
            continue;
        end
        tempConect=[tempConect1(:,2);tempConect2(:,1)];
        if ~ismember(fidxmodified(i),fidxmodified(tempConect(:,1)))
            tempHistc=unique(fidxmodified(tempConect(:,1)))';
            [max_num, max_index]=min(histc(fidxmodified(tempConect(:,1))',tempHistc));
            fidxmodified(i)=tempHistc(max_index);
        end
    end
    StatiZone=tabulate(fidxmodified);
    if min(StatiZone(:,2))<kNearest
        tempkNearest=kNearest;
        kNearest=min(StatiZone(:,2));
    end
    dEuclidean=cell(1,clustering); %Matrix of xyz distance
    dEuclidean_kNN=cell(1,clustering); %Matrix of xyz distance of KNN
    DistanceAve=cell(1,clustering); 
    DistanceStd=cell(1,clustering); 
    classfiedZones=cell(1,clustering); 
    for i=1:clustering % detect outfiting points using x,y,z
        tempclass=find(fidxmodified==i); 
        classfiedZones{i}=tempclass;
        tempCorrdinate=wds.getNodeCoordinates(tempclass');
        tempElevatiaon=wds.getNodeElevations(tempclass');
        tempxyz=[tempCorrdinate tempElevatiaon'];
        dEuclideanTemp=pdist(tempxyz,'euclidean');
        dEuclidean{i}=squareform(dEuclideanTemp);
        for k=1:size(dEuclidean{i},1)
            DistanceAve{i}(k,1)=mean(dEuclidean{i}(dEuclidean{i}(:,k)>0));
            DistanceStd{i}(k,1)=std(dEuclidean{i}(dEuclidean{i}(:,k)>0));
            tempDistance=sort(dEuclidean{i}(k,:));
            tempDistance1=sum(tempDistance(:,1:kNearest))/kNearest;
            dEuclidean_kNN{i}(k,1)=tempDistance1;
        end
        temp1=mean(dEuclidean_kNN{i})-1*std(dEuclidean_kNN{i});
        temp2=mean(dEuclidean_kNN{i})+1*std(dEuclidean_kNN{i});
        fidxmodified(classfiedZones{i}(dEuclidean_kNN{i}<=temp1 | dEuclidean_kNN{i}>=temp2,:),:)=0;
    end 
    tempClassNone=find(fidxmodified==0);
    while ~isempty(fidxmodified(fidxmodified==0,:))
        for i=1:length(tempClassNone)
            tempConect1=NodeConIndex(NodeConIndex(:,1)==tempClassNone(i),:); %find the conncted node of node ith
            tempConect2=NodeConIndex(NodeConIndex(:,2)==tempClassNone(i),:); %find the conncted node of node ith
            tempConect=[tempConect1(:,2);tempConect2(:,1)];
            tempHistc=unique(fidxmodified(tempConect(:,1)))';
            [max_num, max_index]=max(histc(fidxmodified(tempConect(:,1))',tempHistc));
            if tempHistc(max_index)==0
                if max_index==1 && length(tempHistc)==1
                    fidxmodified(tempClassNone(i))=tempHistc(max_index);
                elseif max_index==1
                     fidxmodified(tempClassNone(i))=tempHistc(max_index+1);    
                else
                    fidxmodified(tempClassNone(i))=tempHistc(max_index-1);
                end
                continue;
            end
            fidxmodified(tempClassNone(i))=tempHistc(max_index);
        end
    end
    tabulate(fidxmodified);
end
StatiZone=tabulate(fidxmodified);
%plotnetworkeveryzone(fidxmodified,1,d);
% plotnetwork(fidxmodified,clustering,d);


for i=1:clustering % detect outfiting points using x,y,z
    tempclass=find(fidxmodified==i); 
    classfiedZones{i}=tempclass;
end
connectVerify=cell(1,clustering); 
kkk=1;
for i=1:clustering 
    connectVerify{i}=eye((length(classfiedZones{i})));
    for j=1:length(classfiedZones{i})
        temp1=find(NodeConIndex==classfiedZones{i}(j));
        for k=1:length(temp1)
            if temp1(k)<=size(NodeConIndex,1)
                temp2=NodeConIndex(temp1(k),:);
                if all(ismember(temp2,classfiedZones{i})==1)
                    temp3=find(classfiedZones{i}==temp2(1));
                    temp4=find(classfiedZones{i}==temp2(2));
                    connectVerify{i}(temp3,temp4)=1;
                    connectVerify{i}(temp4,temp3)=1;
                end
            else
                temp2=NodeConIndex(temp1(k)-size(NodeConIndex,1),:);
                if all(ismember(temp2,classfiedZones{i})==1)
                    temp3=find(classfiedZones{i}==temp2(1));
                    temp4=find(classfiedZones{i}==temp2(2));
                    connectVerify{i}(temp3,temp4)=1;
                    connectVerify{i}(temp4,temp3)=1;
                end                
            end
        end
    end
    [S, Q]=concom(connectVerify{i});
    if length(unique(Q))>1
        temp4=unique(Q);
        [min_num, min_index]=max(histc(Q,temp4));
        temp4(min_index)=[];
        for ll=1:length(temp4)
            fidxmodified(classfiedZones{i}(Q==temp4(ll)))=0;
           % fidxmodified(classfiedZones{i}(Q==temp4(ll)))=clustering+kkk;
           % kkk=kkk+1;
        end
    end
end
for i=1:clustering % detect outfiting points using x,y,z
    tempclass=find(fidxmodified==i); 
    classfiedZones{i}=tempclass;
end
end

 kNearest=tempkNearest;
    for i=1:NodeCount
    %     if fidxmodified(i)==0
    %         continue;
    %     end
        tempConect1=NodeConIndex(NodeConIndex(:,1)==i,:); %find the conncted node of node ith
        tempConect2=NodeConIndex(NodeConIndex(:,2)==i,:); %find the conncted node of node ith
        if isempty(tempConect1) && isempty(tempConect2)
            continue;
        end
        tempConect=[tempConect1(:,2);tempConect2(:,1)];
        if ~ismember(fidxmodified(i),fidxmodified(tempConect(:,1)))
            tempHistc=unique(fidxmodified(tempConect(:,1)))';
            [max_num, max_index]=min(histc(fidxmodified(tempConect(:,1))',tempHistc));
            fidxmodified(i)=tempHistc(max_index);
        end
    end
    StatiZone=tabulate(fidxmodified);
    if min(StatiZone(:,2))<kNearest
        tempkNearest=kNearest;
        kNearest=min(StatiZone(:,2));
    end
    dEuclidean=cell(1,clustering); %Matrix of xyz distance
    dEuclidean_kNN=cell(1,clustering); %Matrix of xyz distance of KNN
    DistanceAve=cell(1,clustering); 
    DistanceStd=cell(1,clustering); 
    classfiedZones=cell(1,clustering); 
    for i=1:clustering % detect outfiting points using x,y,z
        tempclass=find(fidxmodified==i); 
        classfiedZones{i}=tempclass;
        tempCorrdinate=wds.getNodeCoordinates(tempclass');
        tempElevatiaon=wds.getNodeElevations(tempclass');
        tempxyz=[tempCorrdinate tempElevatiaon'];
        dEuclideanTemp=pdist(tempxyz,'euclidean');
        dEuclidean{i}=squareform(dEuclideanTemp);
        for k=1:size(dEuclidean{i},1)
            DistanceAve{i}(k,1)=mean(dEuclidean{i}(dEuclidean{i}(:,k)>0));
            DistanceStd{i}(k,1)=std(dEuclidean{i}(dEuclidean{i}(:,k)>0));
            tempDistance=sort(dEuclidean{i}(k,:));
            tempDistance1=sum(tempDistance(:,1:kNearest))/kNearest;
            dEuclidean_kNN{i}(k,1)=tempDistance1;
        end
        temp1=mean(dEuclidean_kNN{i})-1*std(dEuclidean_kNN{i});
        temp2=mean(dEuclidean_kNN{i})+1*std(dEuclidean_kNN{i});
        fidxmodified(classfiedZones{i}(dEuclidean_kNN{i}<=temp1 | dEuclidean_kNN{i}>=temp2,:),:)=0;
    end 
    tempClassNone=find(fidxmodified==0);
    while ~isempty(fidxmodified(fidxmodified==0,:))
        for i=1:length(tempClassNone)
            tempConect1=NodeConIndex(NodeConIndex(:,1)==tempClassNone(i),:); %find the conncted node of node ith
            tempConect2=NodeConIndex(NodeConIndex(:,2)==tempClassNone(i),:); %find the conncted node of node ith
            tempConect=[tempConect1(:,2);tempConect2(:,1)];
            tempHistc=unique(fidxmodified(tempConect(:,1)))';
            [max_num, max_index]=max(histc(fidxmodified(tempConect(:,1))',tempHistc));
            if tempHistc(max_index)==0
                if max_index==1 && length(tempHistc)==1
                    fidxmodified(tempClassNone(i))=tempHistc(max_index);
                elseif max_index==1
                     fidxmodified(tempClassNone(i))=tempHistc(max_index+1);    
                else
                    fidxmodified(tempClassNone(i))=tempHistc(max_index-1);
                end
                continue;
            end
            fidxmodified(tempClassNone(i))=tempHistc(max_index);
        end
    end
    tabulate(fidxmodified)
StatiZone=tabulate(fidxmodified);
%plotnetworkeveryzone(fidxmodified,1,d);

% 
% fidxmodified(fidxmodified==0)=[];
% tabulate(fidxmodified)
temp5=unique(fidxmodified);
%  for i=1:length(temp5)
%     plotnetworkeveryzone(fidxmodified,temp5(i),d);
%  end
plotnetwork(fidxmodified,clustering,wds);