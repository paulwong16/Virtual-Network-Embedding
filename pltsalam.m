[NodeS,LinkS]=SalamNet_NetCreate(1000,100,100000000,20,1,[2,5],[50,100],[50,100],1e-4*[5,20],1e-4*[3,8],1e-4*[0,500]);
%N=randi([2,10]);
%VituralNodeList=SalamNet_RequestNetCreate(1000,N,1,2000000,1,[2,5],[0,50],[0,50],1e-4*[5,20],1e-4*[3,8],1e-4*[0,500]);
NodeMappingList=[];
lambda = 5;
random_sample = poissrnd(lambda,1,500);
Rate = [];
countN = 0;
countS = 0;
for ri = 1:500
    NodeMappingListSizeN=size(NodeMappingList,1);
    for cleari = 1:NodeMappingListSizeN
        if (((NodeMappingList(3*NodeMappingListSizeN+cleari))+(NodeMappingList(4*NodeMappingListSizeN+cleari))) == ri)
            if ((NodeMappingList(5*NodeMappingListSizeN+cleari)) ~= 0)
                num = NodeMappingList(5*NodeMappingListSizeN+cleari);
                NodeMappingList(cleari,:)=[0,0,0,0,0,0,0,0];
                NodeS(600+num) = 1;
                %disp('release!');
            end
        end
    end
    requestnumber = random_sample(ri);
    livetime = exprnd(10,1,requestnumber);
    for ei = 1:requestnumber
        live = livetime(ei);
        live = ceil(live);
        clear N;
        clear VituralNodeList;
        N=randi([2,10]);
        VituralNodeList=SalamNet_RequestNetCreate(1000,N,1,2000000,1,[2,5],[0,50],[0,50],1e-4*[5,20],1e-4*[3,8],1e-4*[0,500]);
        for i = 1:N
            Can = [];
            for j = 1:100;
                if(NodeS(600+j) ~= 0)
                    distance = CalculateDistance(VituralNodeList(2*N+i),VituralNodeList(3*N+i),NodeS(100+j),NodeS(200+j));
                    if distance < 500
                        Can=[Can;j,NodeS(100+j),NodeS(200+j),NodeS(300+j),NodeS(400+j),NodeS(500+j),NodeS(600+j),0];
                    end
                end    
            end
            CanSize=size(Can,1);
            for j = 1:CanSize;
                LS=0;
                if ~isempty(NodeMappingList)
                    NodeMappingListSize=size(NodeMappingList,1);
                    for k = 1:NodeMappingListSize
                        LS=LS+CalculateDistance(Can(CanSize+j),Can(2*CanSize+j),NodeMappingList(4*NodeMappingListSize+k),NodeMappingList(5*NodeMappingListSize+k));
                    end
                    SIR=((Can(3*CanSize+j)+Can(5*CanSize+j))/LS)*Can(4*CanSize+j);
                else
                    SIR=(Can(3*CanSize+j)+Can(5*CanSize+j))*Can(4*CanSize+j);
                end
                Can(7*CanSize+j)=SIR;       
            end
            if ~isempty(Can)
                CanSort=sortrows(Can,-8);
                for l = 1:100
                    if l == CanSort(1)
                        NodeS(600+l)=0;
                    end
                end
                NodeMappingList=[NodeMappingList;i,VituralNodeList(2*N+i),VituralNodeList(3*N+i),live,ri,CanSort(1),CanSort(CanSize+1),CanSort(2*CanSize+1)];
                countS = countS + 1;
            else NodeMappingList=[NodeMappingList;i,VituralNodeList(2*N+i),VituralNodeList(3*N+i),live,ri,0,0,0];
            end
        end
        countN = countN + N;
    end
    srate = countS/countN;
    Rate=[Rate,srate];
end
