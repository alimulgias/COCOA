function probability=CTMCErlang(serviceTime, coldStartTime, inactivityDuration, arrivalRate)
    mu=1/serviceTime;
    alpha=1/coldStartTime;
    beta=1/inactivityDuration;
    lambda=arrivalRate;

    maxJobNumber=1000;
    erlangTransitions=100;

    functionStates=[0 1];
    jobNumbers=0:maxJobNumber;

    stateSpace=zeros(length(jobNumbers)*2,2);

    currentStateNumber=1;
    for i=1:length(functionStates)
        for j=1:length(jobNumbers)   
            stateSpace(currentStateNumber,:)=[functionStates(i) jobNumbers(j)];
            currentStateNumber=currentStateNumber+1;       
        end
    end

    erlangStates=erlangTransitions-1;
    erlangInitState=1-1/erlangTransitions;
    stateValue=erlangInitState;
    for i=1:erlangTransitions-1
        stateSpace(currentStateNumber,:)=[stateValue 0];
        stateValue=stateValue-1/erlangTransitions;
        currentStateNumber=currentStateNumber+1;   
    end


    totalStates=length(stateSpace);

    Q=zeros(totalStates,totalStates);

    for i=1:totalStates

        currentState=stateSpace(i,:);

        forwardJobState=currentState+[0 1];
        pos=matchrow(stateSpace,forwardJobState) ;
        if pos>0
            Q(i,pos)=lambda;
        end

        forwardServerState=currentState+[1 0];
        pos=matchrow(stateSpace,forwardServerState) ;
        if pos>0 && currentState(2)>0
            Q(i,pos)=alpha;
        end

        backwardJobState=currentState-[0 1];
        pos=matchrow(stateSpace,backwardJobState) ;
        if pos>0 && currentState(1)==1
            Q(i,pos)=mu;
        end

    end

    idleServerState=[1 0];
    erlangStartState=[erlangInitState 0];
    pos1=matchrow(stateSpace,idleServerState) ;
    pos2=matchrow(stateSpace,erlangStartState) ;
    Q(pos1,pos2)=beta*erlangTransitions;

    for i=(totalStates-erlangStates+1):totalStates
        currentState=stateSpace(i,:);
        if i~=totalStates
            nextTimeoutState=currentState-[1/erlangTransitions 0];
        else
            nextTimeoutState=[0 0];
        end
        pos=matchrow(stateSpace,nextTimeoutState); 
        if pos>0
            Q(i,pos)=beta*erlangTransitions;
        end

        nextJobState=[1 1];
        pos=matchrow(stateSpace,nextJobState);
        Q(i,pos)=lambda;

    end


    for i=1:totalStates

        rate=0;

        for j=1:totalStates
            rate=rate-Q(i,j);
        end    
        Q(i,i)=rate;
    end

    [pi,~]=ctmc_solve(Q);

    pi=pi(:);

    jobs=0;
    for i=1:totalStates

        jobs= jobs+stateSpace(i,2)*pi(i);

    end

    coldProb=0;

    for i=1:totalStates
        if stateSpace(i,1)==0
            coldProb= coldProb+pi(i);
        end
    end
    probability=coldProb;
    %fprintf("Response time %f Cold Start Probablity %f\n",jobs/lambda, coldProb);
end