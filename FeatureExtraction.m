 clear all;
f = dir('C:\Matlab_WorkSpace\AVT\music_speech\music_wav\');
tic
DATASET1 = [];
parfor i=3:length(f)
    path = strcat('C:\Matlab_WorkSpace\AVT\music_speech\music_wav\',f(i).name);
    
a = miraudio(path, 'Normal');
x = mirframe(a, 'Length', 22050,'sp');
s = mirspectrum(x);

p1 = mirgetdata(mirzerocross(x))';
%p2 = mirgetdata(mirrms(x))';
peaks = mirgetdata(mirpeaks(x))';
p3 = sum(~isnan(peaks),2);

p4 = mirgetdata(mircentroid(s))';
p5 = mirgetdata(mirflatness(s))';  
p6 = mirgetdata(mirroughness(s))';
p7 = mirgetdata(mirkurtosis(s))';
p8 = mirgetdata(mirrolloff(s))';
p9 = [mirgetdata(mirflux(s))' ; mean(mirgetdata(mirflux(s)))];
p10 = mirgetdata(mirmfcc(s))';
p11 = mirgetdata(mirbrightness(s))';
p12 = obw(mirgetdata(x),22050)';
table= [p1  p3 p4 p5 p6 p7 p8 p9 p10 p11 p12];

DATASET1 = [DATASET1 ;table];

end

%Remove rows with NaN values
DATASET1 = DATASET1(~any(isnan(DATASET1),2),:);


DATASET1(:,end+1)= 0; % 0 is music

%speech

f = dir('C:\Matlab_WorkSpace\AVT\music_speech\speech_wav\');
tic
DATASET2 = [];
parfor i=3:length(f)
    path = strcat('C:\Matlab_WorkSpace\AVT\music_speech\speech_wav\',f(i).name);
    
a = miraudio(path,'Normal');
x = mirframe(a, 'Length', 22050,'sp');
s = mirspectrum(x);

p1 = mirgetdata(mirzerocross(x))';
%p2 = mirgetdata(mirrms(x))';
peaks = mirgetdata(mirpeaks(x))';
p3 = sum(~isnan(peaks),2);

p4 = mirgetdata(mircentroid(s))';
p5 = mirgetdata(mirflatness(s))';  
p6 = mirgetdata(mirroughness(s))';
p7 = mirgetdata(mirkurtosis(s))';
p8 = mirgetdata(mirrolloff(s))';
p9 = [mirgetdata(mirflux(s))' ; mean(mirgetdata(mirflux(s)))];
p10 = mirgetdata(mirmfcc(s))';
p11 = mirgetdata(mirbrightness(s))';
p12 = obw(mirgetdata(x),22050)';
table= [p1  p3 p4 p5 p6 p7 p8 p9 p10 p11 p12];

DATASET2 = [DATASET2 ;table];

end

DATASET2 = DATASET2(~any(isnan(DATASET2),2),:);


DATASET2(:,end+1)= 1; % 1 is speech

New_table=[ DATASET1 ; DATASET2 ];

DATASET_GTZAN = zeros(size(New_table) );

parfor k=1:size(New_table, 2)
    
    DATASET_GTZAN(:,k) = (New_table(:,k) - min(New_table(:,k)) ) ./( max(New_table(:,k))-min(New_table(:,k)) )  ;
end

New_table = DATASET_GTZAN;
dataSize = size(New_table,1);
idx = randperm( dataSize );

%FINAL DATASET
DATASET_GTZAN = New_table(idx,:);

toc