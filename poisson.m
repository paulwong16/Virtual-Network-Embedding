clear
lamda=2;Tmax=50;
delta_t=0.01;%时间精度
i=1;a=random('exponential',lamda);
T(1)=round(a*10)/10;
w(1)=T(1);%初始化
%%%%%%%%%%%%%%泊松过程模拟%%%%%%%%%%%%%%%
while(w(i)<Tmax)
T(i)=random('exponential',lamda);%构造服从指数分布的时间间隔序列Tn
   T(i)=round(T(i)*10)/10;
   w(i+1)=w(i)+T(i);%计算等待时间
   i=i+1;
end
w=w';
x=zeros(w(1)/delta_t,1);
for k=1:size(w,1)-1
length=w(k+1)/delta_t-w(k)/delta_t;
x=[x;ones(length,1)*k];%得到泊松分布X(t)序列
shuai=mean(x);
end
%%%%%%%%%%%泊松过程检验%%%%%%%%%%%%%%%%%
alpha=0.05;
lamda1=poissfit(x,alpha);%用MLE算法计算出泊松分布的强度lamda，置信区间为1-lamda
p=poisscdf(x,lamda1);%计算累计分布
[H,s]=kstest(x,[x,p],alpha)%利用Kolmogorov-Smirnov检验，置信区间为1-lamda
if H==1;
disp('该数据源服从泊松分布。') 
else
disp('该数据源不服从泊松分布。') 
end
figure(1)
plot(x,'b')
xlabel('T')
ylabel('X(t)')

figure(2)
a=var(x)
plot(a,'*')
title('方差函数')

ylabel('var(x)')
figure(3)
b=xcorr(x)
plot(b)
title('自相关函数')
xlabel('T')
ylabel('xcorr(x)')
figure(4)
c=mean(x);
plot(c,'+')
title('平均值')
ylabel('mean(x)')



