clear all;

tic
%Load data from file
load DataSet4096.mat



%DATASET_GTZAN=DATASET_GTZAN(1:min(10000,size(DATASET_GTZAN,1)),:);

%Split the data, based on the class
x1 = DATASET_GTZAN(DATASET_GTZAN(:,end)== 0 , :);
x2 = DATASET_GTZAN(DATASET_GTZAN(:,end)== 1 , :);




%Randomize every class data and put them all together in Dtrn,Dval,Dchk
%This happens in order to achieve similarity in subsets 


dataSize = size(x1,1);
idx = randperm( dataSize );
indexDtrn = (idx <= floor(0.8*dataSize));
Dtrn_Initial = x1(indexDtrn,:);
indexDchk = (idx > floor(0.8*dataSize));
Dchk_Initial = x1(indexDchk,:);

dataSize = size(x2,1);
idx = randperm( dataSize );
indexDtrn = (idx <= floor(0.8*dataSize));
Dtrn_Initial = [Dtrn_Initial ; x2(indexDtrn,:) ] ;
indexDchk = (idx > floor(0.8*dataSize));
Dchk_Initial = [Dchk_Initial; x2(indexDchk,:) ];


%Sort features by weight
ranks = relieff(DATASET_GTZAN(:,1:end-1),DATASET_GTZAN(:,end),300);

Accuracy = [];
%Optimum features & rules
for features=5:23
rules = features;
features
% Create new dataset for every class with features determined before
Dtrnval = Dtrn_Initial(:,ranks(1) );
Dchk = Dchk_Initial(:,ranks(1) ) ;    
for k =2:features
    Dtrnval = [ Dtrnval Dtrn_Initial(:,ranks(k) ) ];
    Dchk = [ Dchk Dchk_Initial(:,ranks(k) ) ];
    
end

Dtrnval = [Dtrnval Dtrn_Initial(:,end) ];
Dchk = [ Dchk Dchk_Initial(:,end ) ];
opt = NaN(4,1);
opt(4) = 0;

%Initialize model
fismat = genfis3(Dtrnval(:, 1:end-1),Dtrnval(:,end),'sugeno',rules,opt);
cv = cvpartition(size(Dtrnval,1), 'kfold', 5);
MeanError = 0;
OA=0;
%Change output MFs type from linear to constant and change parameters to
%constant value
for i = 1:size(fismat.output(1).mf,2)
    fismat.output(1).mf(i).type = 'constant' ;
    fismat.output(1).mf(i).params= 1;
    
end

parfor k = 1:5
    Dtrn = Dtrnval( training(cv, k),: ) ;

    Dval = Dtrnval( test(cv, k),: ) ; 


    [FIS,ERROR,STEPSIZE,FINALFIS,CHKERROR] = anfis(Dtrn,fismat,100,[0 0 0 0],Dval);

    MeanError = MeanError + min( CHKERROR )/5 ;

    predOutput = (evalfis( Dchk(:, 1:end-1) , FINALFIS )) ;
    predOutput  = max( min(round(predOutput ), 1 ) , 0);

    confMatrix = zeros(2,2);

    for i =1:2
        for j =1:2
            confMatrix(i,j) = sum((predOutput==i-1) .* (Dchk(:,end) ==j-1));
        end
    end


    %Compute the Perfomance indexes OA, PA, UA, k
    N = size(Dchk,1) ;

    OA = OA + ( 1/N ) * (trace(confMatrix) )/5;

    %{
    Xir = sum(confMatrix, 2) 
    Xjc = sum(confMatrix) 
    PA = zeros(2,1);
    UA = zeros(2,1);
    for i=1:2
        PA(i) = confMatrix(i,i) / Xjc(i);
        UA(i) = confMatrix(i,i) / Xir(i);
    end
    PA
    UA

    k = ( N* trace(confMatrix) -sum( Xir .* Xjc') ) / ( N^2 - sum( Xir .* Xjc') )
    %}

end
% Train FIS with Dtrn, Dval




%Compute the values of error matrix

%Plot learning curve
%figure
%x = [1:100];
%plot(x,ERROR,'.b',x,CHKERROR,'*r')
%title('Learning Curve')
%xlabel('iterations') 
%ylabel('RMSE') 

%Plot Prediction and real values
%figure
%plot(predOutput,'*')
%hold on
%plot(Dchk(:,end),'LineWidth',2);
%title('Prediction and Real Values')
%legend('Predicted Value', 'Real Value')


%Plot sample initial and final fuzzy set.
%figure
%[xout,yout] = plotmf(fismat, 'input', 2);
%plot(xout(:,5),yout(:,5))
%hold on
%[xout,yout] = plotmf(FINALFIS, 'input', 2);
%plot(xout(:,5),yout(:,5))
%legend('Initial', 'Final')
%title('Input 2, MF 5')

Accuracy = [Accuracy OA];
end
toc