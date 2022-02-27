%数据转换为时间序列函数
%沈阳建筑大学-牟天蔚
%% TimeSeriesConvert 时间序列转换
%   input:输入序列，格式为 vectors
%   seriesCol：输入延时序列数，格式为Int
%   errorCode:错误代码,格式为 int
%   result:输出结果
%% 
function [result,errorCode]=TimeSeriesConvert(input,seriesCol)
% seriesRow=size(input,1)/seriesCol;
% c=mod(size(input,1),seriesCol);
% if c~=0
%     disp('error of non-integer rows'); 
%     errorCode=1;
%     return;
% end
% result=reshape(input,seriesCol,seriesRow)';
try
    seriesRow=size(input,1);
    result=zeros(0,0);
    for i=1:seriesRow-seriesCol+1
        result=[result,input(i:i+seriesCol-1)];
    end
    result=result';
    errorCode=0;
catch
    errorCode=1;
    disp('Error of timeseries');
end