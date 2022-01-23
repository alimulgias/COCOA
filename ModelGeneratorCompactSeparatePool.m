function model = ModelGeneratorCompactSeparatePool(openArrivalRate, functionProbabilities, functionServiceTimes, functionColdStartTimes,functionColdStartProbabilities, cpuNumber)

    if ~exist('cpuNumber','var')
        cpuNumber = 1;
    end

    defaultTaskMultiplicity=10;
    defaultProcessorMultiplicity=1;
    defaultServiceTime=0.00000005;

    numberOfClients=1000000;
    thinkTime=numberOfClients/openArrivalRate;

    model = LayeredNetwork('FaasModel');

    %Client processor and task
    clientProcessor = Processor(model, 'clientProcessor', defaultProcessorMultiplicity, SchedStrategy.INF);
    client = Task(model, 'client', numberOfClients, SchedStrategy.REF, thinkTime).on(clientProcessor);
    clientEntry = Entry(model, 'clientEntry').on(client);

    %Dispatcher processor and task
    dispatcherProcessor = Processor(model, 'dispatcherProcessor', defaultProcessorMultiplicity, SchedStrategy.PS);
    dispatcher = Task(model, 'dispatcher', defaultTaskMultiplicity, SchedStrategy.FCFS).on(dispatcherProcessor);
    for i=1:length(functionProbabilities)
        entryName=strcat('f',int2str(i),'Entry');
        dispatcherFunctionEntries(i)=Entry(model, entryName).on(dispatcher);
    end

    %Function processor and functions as tasks
    functionProcessor = Processor(model, 'functionProcessor', cpuNumber, SchedStrategy.PS);
    coldFunctionPool=Task(model, 'coldFunctionPool', defaultTaskMultiplicity, SchedStrategy.FCFS).on(functionProcessor);
    warmFunctionPool=Task(model, 'warmFunctionPool', defaultTaskMultiplicity, SchedStrategy.FCFS).on(functionProcessor);
    
    for i=1:length(functionProbabilities)
        
        functionEntryName=strcat('f',int2str(i),'ColdJobEntry');
        functionColdJobEntries(i)=Entry(model, functionEntryName).on(coldFunctionPool);

        functionEntryName=strcat('f',int2str(i),'WarmJobEntry');
        functionWarmJobEntries(i)=Entry(model, functionEntryName).on(warmFunctionPool);

    end
    
    %Client Task Activities
    clientEntryActivity = Activity(model, 'clientEntryActivity', Exp(1/defaultServiceTime)).on(client).boundTo(clientEntry);
    clientCallActivity = Activity(model, 'clientCallActivity', Exp(1/defaultServiceTime)).on(client);
    for i=1:length(functionProbabilities)
        clientCallActivity.synchCall(dispatcherFunctionEntries(i),functionProbabilities(i));
    end
    client.addPrecedence(ActivityPrecedence.Serial(clientEntryActivity,clientCallActivity));

    %Dispatcher Task Activities
    for i=1:length(dispatcherFunctionEntries)
        currentActivityName=strcat('f',int2str(i),'EntryActivity');
        dispatcherEntryActivities(i) = Activity(model, currentActivityName, Exp(1/defaultServiceTime)).on(dispatcher).boundTo(dispatcherFunctionEntries(i));
        currentActivityName=strcat('f',int2str(i),'CallActivity');
        dispatcherCallActivities(i) = Activity(model, currentActivityName, Exp(1/defaultServiceTime)).on(dispatcher).repliesTo(dispatcherFunctionEntries(i));

        dispatcherCallActivities(i).synchCall(functionColdJobEntries(i),functionColdStartProbabilities(i));
        dispatcherCallActivities(i).synchCall(functionWarmJobEntries(i),1-functionColdStartProbabilities(i));

        dispatcher.addPrecedence(ActivityPrecedence.Serial(dispatcherEntryActivities(i),dispatcherCallActivities(i)));

    end
    
    %Function cold job activities
    for i=1:length(functionColdJobEntries)
        currentActivityName=strcat('f',int2str(i),'ColdEntryActivity');
        functionsColdEntryActivities(i) = Activity(model, currentActivityName, Exp(1/defaultServiceTime)).on(coldFunctionPool).boundTo(functionColdJobEntries(i));
        currentActivityName=strcat('f',int2str(i),'ColdCallActivity');
        functionsColdCallActivities(i) = Activity(model, currentActivityName, Exp(1/functionColdStartTimes(i))).on(coldFunctionPool).repliesTo(functionColdJobEntries(i));

        functionsColdCallActivities(i).synchCall(functionWarmJobEntries(i),1.0);

        coldFunctionPool.addPrecedence(ActivityPrecedence.Serial(functionsColdEntryActivities(i),functionsColdCallActivities(i)));

    end
    
    %Function warm job activities
    for i=1:length(functionWarmJobEntries)
        currentActivityName=strcat('f',int2str(i),'WarmEntryActivity');
        functionsWarmEntryActivities(i) = Activity(model, currentActivityName, Exp(1/defaultServiceTime)).on(warmFunctionPool).boundTo(functionWarmJobEntries(i));
        currentActivityName=strcat('f',int2str(i),'WarmCallActivity');
        functionsWarmCallActivities(i) = Activity(model, currentActivityName, Exp(1/functionServiceTimes(i))).on(warmFunctionPool).repliesTo(functionWarmJobEntries(i));

        warmFunctionPool.addPrecedence(ActivityPrecedence.Serial(functionsWarmEntryActivities(i),functionsWarmCallActivities(i)));

    end

end