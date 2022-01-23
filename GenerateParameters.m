function GenerateParameters(numberOfFunctions, baseFolderParam)

    %rng(123);
    serviceTimeRange=[0.5 1.0];
    serviceTimes=(serviceTimeRange(2)-serviceTimeRange(1)).*rand(numberOfFunctions,1) + serviceTimeRange(1);
    
    %rng(456);
    coldStartTimeRange=[2  27];
    coldStartTimes=(coldStartTimeRange(2)-coldStartTimeRange(1)).*rand(numberOfFunctions,1) + coldStartTimeRange(1);
    
    %rng(245);
    memoryValues=128:64:3008;
    memory=ones(numberOfFunctions,1);
    
    for i=1:numberOfFunctions
        pos=randi(length(memoryValues),1);
        memory(i)=memoryValues(pos);
    end

    idleMean=20;
    idleVar=(0.5*idleMean);
    
    mu = log((idleMean^2)/sqrt(idleVar+idleMean^2)) ;   
    sigma=sqrt(log(idleVar/(idleMean^2)+1));

    pcts=(lognrnd(mu,sigma,[numberOfFunctions 1]))/100;      
    idleMemory=ceil(memory.*pcts);
    
    
    csvwrite(strcat(baseFolderParam,'service.dat'),serviceTimes);
    csvwrite(strcat(baseFolderParam,'coldStart.dat'),coldStartTimes);
    csvwrite(strcat(baseFolderParam,'memory.dat'),memory);
    csvwrite(strcat(baseFolderParam,'idleMemory.dat'),idleMemory);

end
