function probabilities=ColdStartProbabilityGenerator(serviceTimes, coldStartTimes, inactivityDurations, arrivalRate, zipfProbablities)

    probabilities=zeros(1,length(serviceTimes));
    arrivalRates=zipfProbablities*arrivalRate;

    for i=1:length(serviceTimes)

        %tmpProb=CTMCErlang(serviceTimes(i), coldStartTimes(i), inactivityDurations(i), arrivalRates(i));
        tmpProb=MG1ETAQASolverErlang(serviceTimes(i), coldStartTimes(i), inactivityDurations(i), arrivalRates(i));
        %check for alternate
        if tmpProb<0.000001
            tmpProb=0.000001;
        end
        probabilities(i)=tmpProb;
    end

end