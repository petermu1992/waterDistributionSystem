%����ת��Ϊʱ�����к���
%����������ѧ-Ĳ��ε
%% TimeSeriesConvert ʱ������ת��
%   input:�������У���ʽΪ vectors
%   seriesCol��������ʱ����������ʽΪInt
%   errorCode:�������,��ʽΪ int
%   result:������
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