function [responseTimes, utilizations,functionColdStartProbabilities]=ModelSolver(openArrivalRate, functionProbabilities, functionServiceTimes, functionColdStartTimes, functionInactivityDurations, cpuNumber)

functionColdStartProbabilities(:)=ColdStartProbabilityGenerator(functionServiceTimes,functionColdStartTimes,functionInactivityDurations,openArrivalRate,functionProbabilities);

model=ModelGeneratorCompactSeparatePool(openArrivalRate, functionProbabilities, functionServiceTimes, functionColdStartTimes, functionColdStartProbabilities, cpuNumber);

try
    avgTable = SolverLQNS(model).getAvgTable;
    rows=~cellfun('isempty',regexp(avgTable.Node, 'f[0123456789]+Entry(?!\S)'));
    responseTimes=table2array(avgTable(rows,{'RespT'}));
    
    rows=~cellfun('isempty',regexp(avgTable.Node, 'f[0123456789]+ColdJobEntry(?!\S)'));
    coldUtil=table2array(avgTable(rows,{'Util'}));
    
    rows=~cellfun('isempty',regexp(avgTable.Node, 'f[0123456789]+WarmJobEntry(?!\S)'));
    warmUtil=table2array(avgTable(rows,{'Util'}));
  
    utilizations=coldUtil+warmUtil;
catch e
    e.message
    if(isa(e,'matlab.exception.JavaException'))
        ex = e.ExceptionObject;
        assert(isjava(ex));
        ex.printStackTrace;
    end
    
    responseTimes=ones(max(size(functionProbabilities)),1).*Inf;
    utilizations=ones(max(size(functionProbabilities)),1).*Inf;
end



% avgTable = SolverLQNS(model).getAvgTable;
% rows=~cellfun('isempty',regexp(avgTable.Node, 'f[0123456789]+Entry(?!\S)'));
% responseTimes=table2array(avgTable(rows,{'RespT'}));


end