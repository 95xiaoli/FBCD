

function  [C,E] = run_back(X, K, lambda_1, lambda_2, lambda_3,lambda_4)

maxIters = 100;

nView = length(X);
nSample = size(X{1},2);
mu1 = 1;
mu2 = 1;
knn = 5;
Y1 = zeros(nSample);
Y2 = zeros(nSample);
S = zeros(nSample);
max_mu = 10^6;
rho = 1.5;
Obj = [];

%% Initialization
[L,G] = constructG(X, knn, nView, nSample);
[C,M,E,XX,sumXX,sumL]  = Initialization(X,L,G,nView, nSample);

%temp_inv = (XX{v} + beta*eye(n))\eye(n)
temp_inv = cell(1,nView);
for v = 1:nView
    temp_inv{v} = (XX{v} + lambda_4*eye(nSample))\eye(nSample);
end

%% Alternate minizing strategy
for t = 1:maxIters
    
    S = solveS1(sumXX, sumL, XX, C, M, E, Y1,Y2, mu1,mu2, lambda_3,lambda_2, nView, nSample);   
    
    C = solveC(S, Y1, mu1, lambda_1);    
    
    M = solveM(S, Y2, mu2, lambda_2);    
    
    mu_E = 1;          
    max_iter_E = 10;   
    E = solveE2(XX, S, lambda_4, nView, nSample, mu_E, max_iter_E);

    
    Y1 = Y1 + mu1*(S-C);
    Y2 = Y2 + mu2*(S-M);
    mu1 = min(max_mu,rho*mu1);   
    mu2 = min(max_mu,rho*mu2);
    
    %Compare the current iteration value with the previous iteration value
    Obj(t) = computeObjValue(X,C,M,E,L,lambda_3,lambda_4,lambda_1,lambda_2, nView);
    if (t>1 && abs(Obj(t-1)-Obj(t))<10^-4)
        break;
    end    
end





