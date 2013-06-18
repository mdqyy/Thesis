function [ Xlbp ] = ExtractLBP( dirname )
%Extract LBP
%http://www.ee.oulu.fi/mvg/page/lbp_matlab

files=dir([dirname filesep '*.jpg']);
n = size(files,1);

Xlbp=zeros(256,n);

%mapping=getmapping(16,'riu2');
tic

for I=1:n

    disp([dirname filesep files(I).name])
    img=imread([dirname filesep files(I).name]);
    Xlbp(:,I) = lbp(img);

    toc

end

end