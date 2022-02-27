function [bestnest,fmin]=pump(n,d,c)
if nargin<1,
% Number of nests (or different solutions)
c=1.0e-5;
end

% Discovery rate of alien eggs/solutions
pa=0.25;

%% Change this if you want to get better results
% Tolerance
Tol=c;
%% Simple bounds of the search domain
% Lower bounds
nd=n; 
Lb=0.5*ones(1,nd); 
% Upper bounds
Ub=1*ones(1,nd);

% Random initial solutions
for i=1:n,
nest(i,:)=Lb+(Ub-Lb).*rand(size(Lb));
end

% Get the current best
fitness=10^10*ones(n,1);
[fmin,bestnest,nest,fitness]=get_best_nest(nest,nest,fitness,d);

N_iter=0;
%% Starting iterations
while (fmin>Tol)

    % Generate new solutions (but keep the current best)
     new_nest=get_cuckoos(nest,bestnest,Lb,Ub);   
     [fnew,best,nest,fitness]=get_best_nest(nest,new_nest,fitness,d);
    % Update the counter
      N_iter=N_iter+n; 
    % Discovery and randomization
      new_nest=empty_nests(nest,Lb,Ub,pa) ;
    
    % Evaluate this set of solutions
      [fnew,best,nest,fitness]=get_best_nest(nest,new_nest,fitness,d);
    % Update the counter again
      N_iter=N_iter+n;
    % Find the best objective so far  
    if fnew<fmin,
        fmin=fnew;
        bestnest=best;
    end
end %% End of iterations

%% Post-optimization processing
%% Display all the nests
disp(strcat('Total number of iterations=',num2str(N_iter)));
fmin
bestnest

%% --------------- All subfunctions are list below ------------------
%% Get cuckoos by ramdom walk
function nest=get_cuckoos(nest,best,Lb,Ub)
% Levy flights
n=size(nest,1);
% Levy exponent and coefficient
% For details, see equation (2.21), Page 16 (chapter 2) of the book
% X. S. Yang, Nature-Inspired Metaheuristic Algorithms, 2nd Edition, Luniver Press, (2010).
beta=3/2;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);

for j=1:n,
    s=nest(j,:);
    % This is a simple way of implementing Levy flights
    % For standard random walks, use step=1;
    %% Levy flights by Mantegna's algorithm
    u=randn(size(s))*sigma;
    v=randn(size(s));
    step=u./abs(v).^(1/beta);
  
    % In the next equation, the difference factor (s-best) means that 
    % when the solution is the best solution, it remains unchanged.     
    stepsize=0.01*step.*(s-best);
    % Here the factor 0.01 comes from the fact that L/100 should the typical
    % step size of walks/flights where L is the typical lenghtscale; 
    % otherwise, Levy flights may become too aggresive/efficient, 
    % which makes new solutions (even) jump out side of the design domain 
    % (and thus wasting evaluations).
    % Now the actual random walks or flights
    s=s+stepsize.*randn(size(s));
   % Apply simple bounds/limits
   nest(j,:)=simplebounds(s,Lb,Ub);
   %%%%%%%%%%%%%%%%%new%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   nest(j,1)=round(nest(j,1));
%    if nest(j,1)>=0.5
%        nest(j,1)=1;
%    elseif nest(j,1)<0.5
%        nest(j,1)=0;
%    end
    %%%%%%%%%%%%%%%%%new%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% Find the current best nest
function [fmin,best,nest,fitness]=get_best_nest(nest,newnest,fitness,d)
% Evaluating all new solutions
for j=1:size(nest,1),
    fnew=fobj(newnest(j,:),d);
    if fnew<=fitness(j),
       fitness(j)=fnew;
       nest(j,:)=newnest(j,:);
    end
end
% Find the current best
[fmin,K]=min(fitness) ;
best=nest(K,:);

%% Replace some nests by constructing new solutions/nests
function new_nest=empty_nests(nest,Lb,Ub,pa)
% A fraction of worse nests are discovered with a probability pa
n=size(nest,1);
% Discovered or not -- a status vector
K=rand(size(nest))>pa;

% In the real world, if a cuckoo's egg is very similar to a host's eggs, then 
% this cuckoo's egg is less likely to be discovered, thus the fitness should 
% be related to the difference in solutions.  Therefore, it is a good idea 
% to do a random walk in a biased way with some random step sizes.  
%% New solution by biased/selective random walks
stepsize=rand*(nest(randperm(n),:)-nest(randperm(n),:));
new_nest=nest+stepsize.*K;
for j=1:size(new_nest,1)
    s=new_nest(j,:);
  new_nest(j,:)=simplebounds(s,Lb,Ub);  
end

% Application of simple constraints
function s=simplebounds(s,Lb,Ub)
  % Apply the lower bound
  ns_tmp=s;
  I=ns_tmp<Lb;
  ns_tmp(I)=Lb(I);
  
  % Apply the upper bounds 
  J=ns_tmp>Ub;
  ns_tmp(J)=Ub(J);
  % Update this new move 
  s=ns_tmp;

%% You can replace the following by your own functions
% A d-dimensional objective function
function C=fobj(u,d)
d.setPattern(2,u);
junctionIndex=d.getNodeJunctionIndex;
outflowIndex=9;
outpressureIndex=1;
% hydraulic analysis
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1;T_H=[];np_origin=[];LinkHead=[];LinkFlow=[];nodeDemand=[];eff=[];
iii=1;
while (iii<=length(u))
    t=d.runHydraulicAnalysis;
    nodePressure1=d.getNodePressure;
    nodeDemand1=d.getNodeActualDemand;
    nodeDemand=[nodeDemand;nodeDemand1];
    np_origin=[np_origin;nodePressure1];
    linkflow1=d.getLinkFlows;
    LinkFlow=[LinkFlow;linkflow1];
    eff1=d.getLinkEfficiency;
    eff=[eff;eff1(outflowIndex)];
    tstep=d.nextHydraulicAnalysisStep;
    iii=iii+1;
end
d.closeHydraulicAnalysis();
C=0;
k=0.01019;
for i=1:length(u)
    E(i)=k*1*LinkFlow(i,outflowIndex)*np_origin(i,outpressureIndex)*u(i)/eff(i);
    if(i<=5)
        C=C+E(i)*0.8443;
    elseif(i>5 && i<=10)
        C=C+E(i)*1.2898;
    else
        C=C+E(i)*0.4188;   
    end
    if abs(LinkFlow(i,outflowIndex)<100) || abs(LinkFlow(i,outflowIndex)>300)
    	C=999999;
    end
    if any(np_origin(i,1:end-1)<0) || any(np_origin(i,1:end-1)>60)
        C=999999;
    end
    if any(eff(i,:)<0.2)
        C=999999;
    end
end
if C>=999999
    C=999999;
end
