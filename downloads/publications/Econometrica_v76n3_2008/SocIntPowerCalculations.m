% -------------------------------------------------------------------------------------------------- %
% Identifying social interactions through conditional variance restrictions, supplementary material: %
% MATLAB m file 2 of 2 used for power calculations (supplemental file 6 of 8)                        %
% -------------------------------------------------------------------------------------------------- %

% -------------------------------------------------------------------------------------------------- %
% ABSTRACT: This is the second of two MATLAB files used to produce the Tables and Figures associated %
% with the power comparisions reported in the supplemental appendix.                                 %
% -------------------------------------------------------------------------------------------------- %

function [PowerResults] = SocIntPowerCalculations(M, W, DGP, alpha);

% This function was used for the power calculations reported in
% "Identifying Social Interactions through Conditional Variance
% Restrictions" (Bryan S. Graham, UC - Berkeley). Notation more or less
% follows conventions established in the paper.

% M         : N x 1 vector of actual group size
% W         : N x 1 vector with L "set" assignment for each group as elements (i.e., instrument definition)
% DGP       : 5 x 1 vector with (sigma2, sigma2a, gamma2, nSrrn, and K as elements) 
% alpha     : Significance level of test / confidence interval

% ---------------------------------------------------------%
% - STEP 1 : normalize and define various data structures -%
% ---------------------------------------------------------%

options     = optimset('LargeScale','off','GradObj','off','Hessian','off',...
                       'Display','off','TolFun',1e-8,'TolX',1e-8,'MaxFunEvals',1000,'MaxIter',1000);

N           = length(M);                % number of social groups
W_uv        = unique(W);                % unique sets defined by W
L           = length(W_uv);             % number of sets of social groups
prw         = zeros(L,1);               % fraction of groups belong to each set

sigma2      = DGP(1);                   % variance of homoscedastic individual heterogeneity term
sigma2a     = DGP(2);                   % sigma2_alpha (measure of group-level heterogeneity)
gamma2      = DGP(3);                   % social interactions parameter under assumed DGP
nSrrn       = DGP(4);                   % variance of observed individual-level heterogeneity
K           = DGP(5);                   % number of individual-level covariates

gamma       = sqrt(gamma2);             % Social multiplier under assumed DGP
rho         = sigma2a/sigma2;
sigma2_star = sigma2+nSrrn;
rho_star    = sigma2a/(sigma2_star);

gamma2pw    = 1;                        % Evaluate asymptotic variances at the
gammapw     = 1;                        % null

% form main building blocks of the asymptotic variance of the excess
% variance estimator
ev_p1       = zeros(L,1);
ev_p2       = zeros(L,1);
ev_p3       = zeros(L,1);

ev_p1_c      = (M.^2 .* (M - 1)).^-1; 
ev_p2_c      = rho_star + gamma2pw*M.^-1;
ev_p3_c      = M.^-1; 

% take average of each of the above for each set defined by L
for l=1:L
    c         = find(W==W_uv(l));
    prw(l)    = length(c)/N;           
    ev_p1(l)  = mean(ev_p1_c(c));    
    ev_p2(l)  = mean(ev_p2_c(c));
    ev_p3(l)  = mean(ev_p3_c(c));
end

% ---------------------------------------------------------%
% - STEP 2 : Asymptotic power of excess variance test     -%
% ---------------------------------------------------------%

% a : 1-alpha critcal value
crit_valEV   =  chi2inv(1-alpha,1);

% b : large sample variance-covariance matrix for theta = (sigma2a, gamma2);
G0           =  -[prw prw .* sigma2_star .* ev_p3];       % Jacobian matrix (L x 2)
L0           =  diag(prw .* (2*sigma2_star^2*(ev_p2.^2 + gamma2pw^2*ev_p1)));   % Moment variance-covariance matrix (L x L)
AVar_theta   =  inv(G0'*inv(L0)*G0);                      % Asymptotic variance-covariance matrix for optimal GMM estimator

% c: non centrality parameter and power for Wald test   
lambdaEV       = N*((gamma2 - 1)^2)*(1/AVar_theta(2,2));                                    
powerEV        = 1 - ncx2cdf(crit_valEV,1,lambdaEV);

% d : calculate Andrews (1989) inner and outer inverse power envelopes
InvPowerFun = inline('(P-ncx2cdf(cv,1,x)).^2','x','P','cv');
lambda_p50  = fmincon(InvPowerFun,1,[],[],[],[],0,Inf,[],options,0.5,crit_valEV);  
lambda_p95  = fmincon(InvPowerFun,1,[],[],[],[],0,Inf,[],options,0.05,crit_valEV);     
   
InnerEnvEV = sqrt(1 + sqrt(lambda_p50*AVar_theta(2,2)/N));   % put EV envelope results in social multiplier terms
OuterEnvEV = sqrt(1 + sqrt(lambda_p95*AVar_theta(2,2)/N));   

% ---------------------------------------------------------%
% - STEP 3 : Asymptotic power of excess sensitivity test  -%
% ---------------------------------------------------------%
  
% a : construct asymptotic variance
mu_M        = mean(M);
V           = sigma2*(gammapw^2 + mu_M*rho + (mu_M - 1)^-1)/nSrrn;
   
% b : construct non-centrality parameter and compute power of the test
lambdaES   = N*((gamma-1)^2)/V;
crit_valES = chi2inv(1-alpha,K);         
powerES    = 1 - ncx2cdf(crit_valES,K,lambdaES);    
   
% c : calculate Andrews (1989) inner and outer inverse power envelopes
InvPowerFun = inline('(P-ncx2cdf(cv,K,x)).^2','x','P','cv','K');
lambda_p50 = fmincon(InvPowerFun,K,[],[],[],[],0,Inf,[],options,0.5,crit_valES,K);  
lambda_p95 = fmincon(InvPowerFun,K,[],[],[],[],0,Inf,[],options,0.05,crit_valES,K);     
   
InnerEnvES = 1 + sqrt(lambda_p50*V/N);
OuterEnvES = 1 + sqrt(lambda_p95*V/N);   

PowerResults = [gamma powerEV InnerEnvEV OuterEnvEV powerES InnerEnvES OuterEnvES];

% ---------------------------------------------------------%
% - STEP 4 : Display Results                              -%
% ---------------------------------------------------------%

disp('');
disp('_________________________________________________________________________');
disp('- POWER APPROXIMATIONS                                                  -');
disp('_________________________________________________________________________');       
disp(['Number of social groups                       : ' int2str(sum(N))]);        
disp(' ');
disp('_________________________________________________________________________');
disp(['sigma2                            (ind. het.) : ' num2str(DGP(1))]);
disp(['sigma2_a                (group heterogeneity) : ' num2str(DGP(2))]);
disp(['gamma2                  (social interactions) : ' num2str(DGP(3))]);
disp(['nSrrn                        (obs. ind. het.) : ' num2str(DGP(4))]);
disp(' ');
disp('EXCESS VARIANCE POWER APPROXIMATION');
disp(['Power                                         : ' num2str(powerEV)]); 
disp(['Inner power envelope (p=0.50)                 : ' num2str([InnerEnvEV])]); 
disp(['Outer power envelope (p=0.95)                 : ' num2str([OuterEnvEV])]); 
disp(' ');
disp('EXCESS SENSITIVITY POWER APPROXIMATION');
disp(['Power                                         : ' num2str(powerES)]); 
disp(['Inner power envelope (p=0.50)                 : ' num2str([InnerEnvES])]); 
disp(['Outer power envelope (p=0.95)                 : ' num2str([OuterEnvES])]); 
disp(['Degrees of freedom (K)                        : ' num2str(K)]); 