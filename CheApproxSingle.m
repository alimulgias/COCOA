function timeouts = CheApproxSingle(lambdas,memory_capacity)

    N=length(lambdas);
    one_vector=ones(N,1);

    syms T;

    eqn=sum(one_vector-exp(-(lambdas.*T)))-memory_capacity;

    result=vpasolve(eqn,T);
    
    timeouts=double(result);

end
