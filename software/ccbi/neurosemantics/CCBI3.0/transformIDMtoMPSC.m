function [C,Mpsc]=transformIDMtoMPSC(S)

cLen=length(S.info);
C=zeros(cLen,3);
S.dataLen=length(S.data{1});
%Mpsc=zeros(cLen,S.dataLen);
C(:,1)=[S.info.cond]';
C(:,2)=[S.info.word_number]';
try
C(:,3)=[S.info.epoch]';
catch
C(:,3)=[S.info.repeats]'
end
bigM=[S.data{:}];
[exampleNumber,xx]=size(S.data);
Mpsc=reshape(bigM,length(S.data{1}),exampleNumber);
Mpsc=Mpsc';
