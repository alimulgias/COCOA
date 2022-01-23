function [responseTimes,currentInactivityDurations, utilizations,coldStartProbabilities]=BinaryRefine(openArrivalRate, functionProbabilities, functionServiceTimes, functionColdStartTimes, functionInactivityDurations, cpuNumber)

iteration=0;
iterLimit=30;

reponseTimeSLA=2;
slaThreshold=0.05;

currentInactivityDurations=functionInactivityDurations;

startInactivityDurations(:)=ones(length(functionInactivityDurations),1).*0.000001;

midInactivityDurations(:)=startInactivityDurations(:);

endInactivityDurations(:)=startInactivityDurations(:);

isInitIncreasing=ones(length(currentInactivityDurations),1);

[responseTimes,utilizations,coldStartProbabilities]=ModelSolver(openArrivalRate, functionProbabilities, functionServiceTimes, functionColdStartTimes, currentInactivityDurations, cpuNumber);

while iteration<iterLimit
    
    iteration=iteration+1;
    fprintf('Iteration %d\n', iteration);
    
    prevInactivityDurations=currentInactivityDurations;
    
    for i=1:length(currentInactivityDurations)
    
        if responseTimes(i)<(reponseTimeSLA-reponseTimeSLA*slaThreshold) 
            endInactivityDurations(i)=currentInactivityDurations(i);
            midInactivityDurations(i)=(startInactivityDurations(i)+endInactivityDurations(i))/2;
            currentInactivityDurations(i)=midInactivityDurations(i);
            isInitIncreasing(i)=0;
        else
            if ~isinf(responseTimes(i))
                startInactivityDurations(i)=currentInactivityDurations(i);             
            end
            if isInitIncreasing(i) == 1
                currentInactivityDurations(i)=currentInactivityDurations(i)+ functionInactivityDurations(i);
            else
                midInactivityDurations(i)=(startInactivityDurations(i)+endInactivityDurations(i))/2;
                currentInactivityDurations(i)=midInactivityDurations(i);
            end
        end    
    end
    
    [tmpResponseTimes,tmpUtilizations,coldStartProbabilities]=ModelSolver(openArrivalRate, functionProbabilities, functionServiceTimes, functionColdStartTimes, currentInactivityDurations, cpuNumber);

    if isinf(tmpResponseTimes(1))
        currentInactivityDurations=prevInactivityDurations;
        break
    else
        responseTimes=tmpResponseTimes;
        utilizations=tmpUtilizations;
    end
    
end



end