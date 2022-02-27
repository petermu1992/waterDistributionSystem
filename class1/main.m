ori=xlsread('shuju.xlsx');
ori=ori(1:108,:);
tim=TimeSeriesConvert(ori,8);
x=tim(1:100,1:7);
y=tim(1:100,8);
x_test=tim(101,1:7);
y_test=tim(101,8);
sjwl(x,y,x_test,y_test);