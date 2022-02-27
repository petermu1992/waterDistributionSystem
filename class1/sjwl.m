function sjwl(x,y,x_test,y_test)
p=x';  %输入数据矩阵
t=y';         %目标数据矩阵
%利用premnmx函数对数据进行归一化
[pn,minp,maxp,tn,mint,maxt]=premnmx(p,t); % 对于输入矩阵p和输出矩阵t进行归一化处理
dx=[-1,1;-1,1;-1,1;-1,1;-1,1;-1,1;-1,1];     %归一化处理后最小值为-1，最大值为1
%BP网络训练
net=newff(dx,[7,6,1],{'tansig','tansig','purelin'},'traingdx'); %建立模型，并用梯度下降法训练．
net.trainParam.show=1000;               %1000轮回显示一次结果
net.trainParam.Lr=0.05;                 %学习速度为0.05
net.trainParam.epochs=50000;           %最大训练轮回为50000次
net.trainParam.goal=0.65*10^(-3);     %均方误差
net=train(net,pn,tn);                   %开始训练，其中pn,tn分别为输入输出样本
%利用原始数据对BP网络仿真
an=sim(net,pn);           %用训练好的模型进行仿真
a=postmnmx(an,mint,maxt); % 把仿真得到的数据还原为原始的数量级；
xx=1:100;
figure (2);
plot(xx,a,'r-o',xx,y,'b-+')   
xlabel('时间 /t');ylabel('用水量 /万m3');
%利用训练好的网络进行预测
% 当用训练好的网络对新数据pnew进行预测时，也应作相应的处理：
pnew=x_test';          %2010年和2011年的相关数据；
pnewn=tramnmx(pnew,minp,maxp); %利用原始输入数据的归一化参数对新数据进行归一化；
anewn=sim(net,pnewn);            %利用归一化后的数据进行仿真；
anew=postmnmx(anewn,mint,maxt)  %把仿真得到的数据还原为原始的数量级；
err=abs(anew-y_test)/y_test
