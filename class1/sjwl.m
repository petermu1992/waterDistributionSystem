function sjwl(x,y,x_test,y_test)
p=x';  %�������ݾ���
t=y';         %Ŀ�����ݾ���
%����premnmx���������ݽ��й�һ��
[pn,minp,maxp,tn,mint,maxt]=premnmx(p,t); % �����������p���������t���й�һ������
dx=[-1,1;-1,1;-1,1;-1,1;-1,1;-1,1;-1,1];     %��һ���������СֵΪ-1�����ֵΪ1
%BP����ѵ��
net=newff(dx,[7,6,1],{'tansig','tansig','purelin'},'traingdx'); %����ģ�ͣ������ݶ��½���ѵ����
net.trainParam.show=1000;               %1000�ֻ���ʾһ�ν��
net.trainParam.Lr=0.05;                 %ѧϰ�ٶ�Ϊ0.05
net.trainParam.epochs=50000;           %���ѵ���ֻ�Ϊ50000��
net.trainParam.goal=0.65*10^(-3);     %�������
net=train(net,pn,tn);                   %��ʼѵ��������pn,tn�ֱ�Ϊ�����������
%����ԭʼ���ݶ�BP�������
an=sim(net,pn);           %��ѵ���õ�ģ�ͽ��з���
a=postmnmx(an,mint,maxt); % �ѷ���õ������ݻ�ԭΪԭʼ����������
xx=1:100;
figure (2);
plot(xx,a,'r-o',xx,y,'b-+')   
xlabel('ʱ�� /t');ylabel('��ˮ�� /��m3');
%����ѵ���õ��������Ԥ��
% ����ѵ���õ������������pnew����Ԥ��ʱ��ҲӦ����Ӧ�Ĵ���
pnew=x_test';          %2010���2011���������ݣ�
pnewn=tramnmx(pnew,minp,maxp); %����ԭʼ�������ݵĹ�һ�������������ݽ��й�һ����
anewn=sim(net,pnewn);            %���ù�һ��������ݽ��з��棻
anew=postmnmx(anewn,mint,maxt)  %�ѷ���õ������ݻ�ԭΪԭʼ����������
err=abs(anew-y_test)/y_test
