function ScoreCalculate(functionLambdas,responseTimes,currentInactivityDurations,utilizations, coldStartProbabilities,cpuNumbers, baseFolderParam,baseFolderResult)

slaViolationLimit=0;
reponseTimeSLA=2.0;
%slaThreshold=0.05;

markovCoefficient=20;

mkdir(baseFolderResult);


[row ,col]=size(responseTimes);

memory(:)=csvread(strcat(baseFolderParam,'memory.dat'));
idleMemory(:)=csvread(strcat(baseFolderParam,'idleMemory.dat'));

inactivityFolder=strcat(baseFolderParam,'inactivityDuration/cocoa/');
mkdir(inactivityFolder);


scores=ones(row,1)*100;

mems=zeros(row,3);
cpus=zeros(row,3);
avgMems=zeros(row,1);
for i=1:row
    
    slaViolation=0;
    memoryUsage=0;
    avgMem=0;
    for j=1:col
        if round(responseTimes(i,j),1) > reponseTimeSLA
            slaViolation=slaViolation+1;
        end
        fmemory=markovCoefficient*utilizations(i,j)*memory(j)+(1-utilizations(i,j))*idleMemory(j);
        memoryUsage=memoryUsage+(1-exp(-(functionLambdas(j)*currentInactivityDurations(i,j))))*fmemory;
        
        fAvgMemory=utilizations(i,j)*memory(j)+(1-utilizations(i,j))*idleMemory(j);
        avgMem=avgMem+(1-exp(-(functionLambdas(j)*currentInactivityDurations(i,j))))*fAvgMemory;
        
        
    end
    
    mems(i,1)=memoryUsage;
    cpus(i,1)=cpuNumbers(i);
    avgMems(i,1)= avgMem;
    
    memMax=sum(memory);
    cpuMax=max(cpuNumbers);
    
    mems(i,2)=memMax;
    cpus(i,2)=cpuMax;
    
    memNorm=memoryUsage/memMax;
    cpuNorm=cpuNumbers(i)/cpuMax;
    
    mems(i,3)=memNorm;
    cpus(i,3)=cpuNorm;
    
    csvwrite(strcat(baseFolderResult,'responseTimes_',int2str(cpuNumbers(i)),'.csv'),responseTimes(i,:)');
    csvwrite(strcat(baseFolderResult,'utilizations_',int2str(cpuNumbers(i)),'.csv'),utilizations(i,:)');
    csvwrite(strcat(baseFolderResult,'coldStartProbabilities_',int2str(cpuNumbers(i)),'.dat'),coldStartProbabilities(i,:)');
    csvwrite(strcat(inactivityFolder,'inactivityDuration_',int2str(cpuNumbers(i)),'.dat'),currentInactivityDurations(i,:)');

    if slaViolation<=slaViolationLimit
        
        weightMem=0.5;
        weightCpu=0.5;
        
        scores(i)=(memNorm*weightMem)+(cpuNorm*weightCpu);
        
    end
end

[~,index]=min(scores);

csvwrite(strcat(baseFolderResult,'scores.csv'),[avgMems mems cpus scores]);
csvwrite(strcat(baseFolderResult,'responseTimes.csv'),responseTimes(index,:)');
csvwrite(strcat(baseFolderResult,'utilizations.csv'),utilizations(index,:)');
csvwrite(strcat(baseFolderResult,'coldStartProbabilities.csv'),coldStartProbabilities(index,:)');
csvwrite(strcat(inactivityFolder,'inactivityDuration.dat'),currentInactivityDurations(index,:)');


end