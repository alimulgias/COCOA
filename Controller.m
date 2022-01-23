 
numberOfFunctions=64;

arrivalRates=[0.5];
zipfShapes=[0.6];
cpuNumbers=2:2:8;
%cpuNumbers=2;

poolobj = gcp('nocreate');
if isempty(poolobj)
    parpool(4);
end

for openArrivalRate=arrivalRates
    
    for zipfShape=zipfShapes
        
        baseFolderParam=strcat('mg1/params/',int2str(numberOfFunctions),'/',num2str(openArrivalRate),'/',num2str(zipfShape),'/');
        baseFolderResult=strcat('mg1/results/',int2str(numberOfFunctions),'/',num2str(openArrivalRate),'/',num2str(zipfShape),'/');
  
        mkdir(baseFolderParam);
        
        responseTimes=zeros(length(cpuNumbers),numberOfFunctions);
        currentInactivityDurations=zeros(length(cpuNumbers),numberOfFunctions);
        utilizations=zeros(length(cpuNumbers),numberOfFunctions);
        coldStartProbabilities=zeros(length(cpuNumbers),numberOfFunctions);
        %functionLambdas=zeros(length(cpuNumbers),functionNumber);
        
        GenerateParameters(numberOfFunctions,baseFolderParam);
        
        functionProbabilities(:)=ZipfProbability(numberOfFunctions,zipfShape);
        functionServiceTimes(:)=csvread(strcat(baseFolderParam,'service.dat'));
        functionColdStartTimes(:)=csvread(strcat(baseFolderParam,'coldStart.dat'));
        functionInactivityDurations(:)=ones(numberOfFunctions,1).*CheApproxSingle(functionProbabilities(:).*openArrivalRate,numberOfFunctions*0.999999);

        functionLambdas(:)= functionProbabilities(:).*openArrivalRate;

        
        parfor i=1:length(cpuNumbers)

            %[functionLambdas(i,:),responseTimes(i,:),currentInactivityDurations(i,:)]=init(r,functionNumber,s,cpuNumbers(i),baseFolderParam);
            [responseTimes(i,:),currentInactivityDurations(i,:), utilizations(i,:),coldStartProbabilities(i,:)]=BinaryRefine(openArrivalRate, functionProbabilities, functionServiceTimes, functionColdStartTimes, functionInactivityDurations,cpuNumbers(i));
        end
        
        ScoreCalculate(functionLambdas,responseTimes,currentInactivityDurations,utilizations,coldStartProbabilities,cpuNumbers, baseFolderParam,baseFolderResult)
    end
    
end




