function probability=MG1ETAQASolverErlang(serviceTime, coldStartTime, inactivityDuration, arrivalRate)

mu=1/serviceTime;
alpha=1/coldStartTime;
beta=1/inactivityDuration;
lambda=arrivalRate;

erlangTransitions=100;

erlangStates=erlangTransitions-1;

environmentalStates=2;

numberOfFirstLevelStates=environmentalStates+erlangStates;

B0=zeros(numberOfFirstLevelStates,numberOfFirstLevelStates);
B0(1,1)=-lambda;
for i=2:numberOfFirstLevelStates
    B0(i,i)=-(lambda+(erlangTransitions*beta));
    B0(i,i-1)=erlangTransitions*beta;
end

B1=zeros(numberOfFirstLevelStates,environmentalStates);
B1(1,1)=lambda;
for i=2:numberOfFirstLevelStates
    B1(i,environmentalStates)=lambda;
end


A0=zeros(environmentalStates,environmentalStates);
A0(environmentalStates,environmentalStates)=mu;

A1=zeros(environmentalStates,environmentalStates);
A1(1,1)=-(lambda+alpha);
A1(1,environmentalStates)=alpha;
A1(environmentalStates,environmentalStates)=-(lambda+mu);


A2=zeros(environmentalStates,environmentalStates);
A2(1,1)=lambda;
A2(environmentalStates,environmentalStates)=lambda;

C0=zeros(environmentalStates,numberOfFirstLevelStates);
C0(environmentalStates,numberOfFirstLevelStates)=mu;


An=[A0 A1 A2];

Bn=[B0 B1];

G = MG1_G_ETAQA(An);
pi=MG1_pi_ETAQA(Bn,An,G,'Boundary',C0);

%pi=[pi0,pi1,pi2+pi3+...] pi0 for numberOfFirstLevelStates (101), pi1 for
%environmental states (2), pi2+pi3+... for environmental states (2), total 105
probability=pi(1)+pi(numberOfFirstLevelStates+1)+pi(length(pi)-1);

end
