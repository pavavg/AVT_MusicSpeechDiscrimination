%Sort features by weight
ranks = relieff(DATASET_GTZAN(:,1:end-1),DATASET_GTZAN(:,end),300);

features = 23;

DATASET = DATASET_GTZAN(:,ranks(1) );  
for k =2:features
    DATASET = [ DATASET DATASET_GTZAN(:,ranks(k) ) ];
end

%FINAL DATASET
DATASET = [ DATASET DATASET_GTZAN(:,end ) ];