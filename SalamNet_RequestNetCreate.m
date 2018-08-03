function IRQ=SalamNet_RequestNetCreate(BorderLength,NodeAmount, ...,
    Alpha,Beta,PlotIf,EdgeCostDUB,EdgeBandWideDUB,VertexCostDUB,VertexDelayDUB,VertexDelayJitterDUB,VertexPacketLossDUB)

%% 输入参数列表
%BorderLenght————正方形区域的边长，单位：km
%NodeAmount————网络节点的个数
%Alpha————网络特征参数，Alpha越大，短边相对长边的比例越大
%Beta————网络特征参数，Beta越大，边的密度越大
%PlotIf————是否画网络拓扑图，如果为1，则画图，否则不画图
%EdgeCostDUB————链路费用的控制参数，1*2，存储链路费用的下界和上界
%EdgeBandWideDUB————链路带宽的控制参数，1*2，存储下界和上界
%VertexCostDUB————节点费用的控制参数，1*2,存储节点费用的下界和上界
%VertexDelayDUB————节点时延的控制参数，1*2，节储节点时延的下界和上界
%VertexDelayJitterDUB————节点时延抖动的控制参数，1*2，存储节点时延抖动的下界和上界
%VertexPacketLossDUB————节点丢包率的控制参数，1*2,存储节点丢包率的下界
%%输出参数
%Sxy————3*N的矩阵，各列分别用于存储节点的序号，横坐标，纵坐标的矩阵
%AM————0 1存储矩阵，AM(i,j)=1表示存在由i到j的有向边，N*N
%EdgeCost————链路费用矩阵，N*N
%EdgeDelay————链路时延矩阵，N*N
%EdgeBandWide————链路带宽矩阵，N*N
%VertexCost————节点费用向量,1*N
%VertexDelay————节点时延向量，1*N
%VertexDelayJitter————节点时延抖动向量,1*N
%VertexPacketLoss————节点丢包率向量,1*N
%%推荐的输入参数设置 
%BorderLength=1000;NodeAmount=25;Alpha=100000000;Beta=200000000000;
%PlotIf=1;EdgeCostDUB=[2,5];EdgeBandWideDUB=[30,1000];VertexCostDUB=[2,4];
%VertexDelayDUB=1e-4*[5,20];VertexDelayJitterDUB=1e-4*[3,8];
%VertexPacketLossDUB=1e-4*[0,500]
%%
%参数初始化
NN = 10*NodeAmount;
SSxy = zeros(NN,2);
%在正方形区域内随机均匀选取NN个节点
for i = 1:NN
    SSxy(i,1) = BorderLength*rand;
    SSxy(i,2) = BorderLength*rand;
end

[IDX,C] = kmeans(SSxy,NodeAmount);
Sxy = [[1:NodeAmount]',C]';
%按横坐标由小到大的顺序重新为每一个节点编号
temp = Sxy;
Sxy2 = Sxy(2,:);
Sxy2_sort = sort(Sxy2);
for i = 1:NodeAmount
    pos = find(Sxy2==Sxy2_sort(i));
    if length(pos)>1
        error('仿真故障，请重试！');
    end
    temp(1,i) = i;
    temp(2,i) = Sxy(2,pos);
    temp(3,i) = Sxy(3,pos);
end
Sxy = temp;
%输出参数初始化
AM = zeros(NodeAmount,NodeAmount);
EdgeCost = zeros(NodeAmount,NodeAmount);
EdgeDelay = zeros(NodeAmount,NodeAmount);
EdgeBandWide = zeros(NodeAmount,NodeAmount);
VertexCost  = zeros(1,NodeAmount);
VertexDelay = zeros(1,NodeAmount);
VertexDelayJitter = zeros(1,NodeAmount);
VertexPacketLoss  = zeros(1,NodeAmount);
for i = 1:(NodeAmount-1)
    for j = (i+1):NodeAmount
        Distance =( (Sxy(2,i)-Sxy(2,j))^2+(Sxy(3,i)-Sxy(3,j))^2)^0.5;
        P = 0.5;
        if P>rand
            AM(i,j) = 1;
            AM(j,i) = 1;
            EdgeDelay(i,j) = 0.5*Distance/100000;
            EdgeDelay(j,i) = EdgeDelay(i,j);
            EdgeCost(i,j) = EdgeCostDUB(1)+(EdgeCostDUB(2)-EdgeCostDUB(1))*rand;
            EdgeCost(j,i)=EdgeCost(i,j);
            EdgeBandWide(i,j) = EdgeBandWideDUB(1)+(EdgeBandWideDUB(2)-EdgeBandWideDUB(1))*rand;
            EdgeBandWide(j,i)=EdgeBandWide(i,j);
        else
            EdgeDelay(i,j) = inf;
            EdgeDelay(j,i) = inf;
            EdgeCost(i,j) = inf;
            EdgeCost(j,i) = inf;
            EdgeBandWide(i,j) = inf;
            EdgeBandWide(j,i) = inf;
        end
    end
end
for i = 1:NodeAmount
    VertexCost(i) = VertexCostDUB(1)+(VertexCostDUB(2)-VertexCostDUB(1))*rand;
    VertexDelay(i) = VertexDelayDUB(1)+(VertexDelayDUB(2)-VertexDelayDUB(1))*rand;
    VertexDelayJitter(i) = VertexDelayJitterDUB(1)+(VertexDelayJitterDUB(2)-VertexDelayJitterDUB(1))*rand;
    VertexPacketLoss(i) = VertexPacketLossDUB(1)+(VertexPacketLossDUB(2)-VertexPacketLossDUB(1))*rand;
end
IRQ=Net_plot(BorderLength,NodeAmount,Sxy,EdgeCost,EdgeBandWide,VertexCost,PlotIf);
end

%用于绘制网络拓扑的函数
function IRQ=Net_plot(BorderLength,NodeAmount,Sxy,EdgeCost,EdgeBandWide,VertexCost,PlotIf)
%画节点
figure(2);
if PlotIf == 1
    plot(Sxy(2,:),Sxy(3,:),'ko','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',3);
    %设置图形显示范围
    xlim([0,BorderLength]);
    ylim([0,BorderLength]);
    hold on;
    %节点标序号
    for i = 1:NodeAmount
        Str = int2str(i);
        text(Sxy(2,i)+BorderLength/100,Sxy(3,i)+BorderLength/100,Str,'FontName','Times New Roman','FontSize',8);
        hold on;
    end
end
%画边
IR=[];
if PlotIf == 1
    for i = 1:(NodeAmount-1)
        for j = (i+1):NodeAmount
            if isinf(EdgeCost(i,j)) == 0
                plot([Sxy(2,i),Sxy(2,j)],[Sxy(3,i),Sxy(3,j)],'k');
                hold on;
            end
        end
    end
end
if PlotIf == 1
    for i = 1:NodeAmount
        a=0;
        b=0;
        for j = 1:NodeAmount
            if i ~= j
                if isinf(EdgeCost(i,j)) == 0 %连通度
                    a=a+EdgeCost(i,j);
                    b=b+EdgeBandWide(i,j);
                end
                if isinf(EdgeCost(i,j)) == 0
                    plot([Sxy(2,i),Sxy(2,j)],[Sxy(3,i),Sxy(3,j)],'k');
                    hold on;
                end
            end
        end
        CC=1/a;
        DC=b;
        NR=VertexCost(i);
        NodeImportantRate=(NR+DC)*CC;
        NodeX=Sxy(2,i);
        NodeY=Sxy(3,i);
        IR=[IR;i,NodeImportantRate,NodeX,NodeY];
    end
end
IRQ=sortrows(IR,-2);
xlswrite('requestNR.xlsx',IRQ);
if PlotIf == 1
    xlabel('x (km)','FontName','Times New Roman','FontSize',12);
    ylabel('y (km)','FontName','Times New Roman','FontSize',12);
end
end
