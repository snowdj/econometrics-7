% -------------------------------------------------------------------------------------------------- %
% Identifying social interactions through conditional variance restrictions, supplementary material: %
% MATLAB m file 1 of 2 used for power calculations (supplemental file 5 of 8)                        %
% -------------------------------------------------------------------------------------------------- %

% -------------------------------------------------------------------------------------------------- %
% ABSTRACT: This is the first of two MATLAB files used to produce the Tables and Figures associated  %
% with the power comparisions reported in the supplemental appendix.                                 %
% -------------------------------------------------------------------------------------------------- %

clear;
format short;

% -------------------------------------------------------------------------------------------------- %
% Excess Variance and Excess Sensitivity Power Comparisons
% Bryan S. Graham, UC - Berkeley
% Summer 2006      
% -------------------------------------------------------------------------------------------------- %

% This M-file replicates the power calculations reported in Table 4 and
% Figure 1 of the Supplemental Web Appendix to "Identifying Social Interactions 
% through Conditional Variance Restrictions," by Bryan S. Graham.

% switch directory to
cd('Research/EV_Paper');
diary('STAR_POWER_RESULTS.log')
diary on;

% -------------------------------------------------------------------------------------------------- %
% - PART A : MATH KINDERGARTEN TEST SCORES                                                         - % 
% -------------------------------------------------------------------------------------------------- %

% load data
load STARCLEANDATA;

% -------------------------------------------------------------------------- %
% - STEP 1 : ORGANIZE DATA                                                 - %
% -------------------------------------------------------------------------- %

% organize data                                              
G        = yxrzdata(:,2);                               % find student classroom assignments
y        = yxrzdata(:,3);                               % outcome variable (math test score data)
r        = yxrzdata(:,5:7);                             % individual characteristics (race, gender, freelunch)
t        = [yxrzdata(:,17) yxrzdata(:,38:end)];         % t-matrix (group-level variables, incls. school dummies & linear class_size term) 
q        = yxrzdata(:,11);                              % dummy for small class type

clear yxrzdata yxrzlabels;

% sort the data by classroom assignment
R   = sortrows([G y r t q],1);  
G   = R(:,1);
y   = R(:,1+1);
r   = R(:,1+1+1:1+1+3);
t   = R(:,1+1+3+1:end-1);
q   = R(:,end);
clear R;

% find those students with missing outcome data
i = find(~isnan(y));                % indices for students with valid outcome data
G_y = G(i);                         % group assignments for those with valid outcome data
NG_y = CountGroupMembers(G_y);      % number of individuals in each group w/ valid outcome data
NG_xrt = CountGroupMembers(G);      % number of individuals in each group
N = length(NG_y);                   % total number of groups
n_y = sum(NG_y);                    % total number of individuals with valid outcome data
n_xrt = sum(NG_xrt);                % total number of individuals
L = length(t(1,:));                 % number of group-level controls
clear G G_y;

% -------------------------------------------------------------------------- %
% - STEP 2 : ESTIMATE/ESTABLISH PRIMITIVES FOR POWER CALCULATIONS          - %
% -------------------------------------------------------------------------- %

ETA = [-0.3752; 0.1187; -0.4109];   % From Web Appendix Table 3, Panel A, Column 2

% residualize individual characteristics with respect to 
% school dummies and class-size to compute Srr

PI   = t(i,:) \ r(i,:);   
r_ev = r - t*PI;
Srr  = cov(r_ev)*(n_xrt-1)/(n_xrt-L);  % NOTE: degrees of freedom correction 
n_Srr_n = ETA'*Srr*ETA

clear PI r_ev Srr;

% form N x 1 class type assignment vector
q_bgt   = zeros(N,1);
for c = 1:N
      n1      = (sum(NG_xrt(1:c)) - NG_xrt(c)) + 1;            % find set of observations corresponding...
      n2      = (sum(NG_xrt(1:c)) - NG_xrt(c)) + NG_xrt(c);    % to the c-th group f/ *sampled* individuals      
      q_bgt(c)= mean(q(n1:n2));
end

q = q_bgt;
clear q_bgt;

% -------------------------------------------------------------------------- %
% - STEP 3 : POWER CALCULATIONS                                            - %
% -------------------------------------------------------------------------- %

% Replication of Web Appendix Table 4 
DGP = [0.75; 0.0035; 3.5; 0.05; 3]; % Specification of Calibrated Population
PowerTable = SocIntPowerCalculations(NG_xrt, q, DGP, 0.05);

% Replication of Web Appendix Figure 1
Power = []

for gamma2=1:0.1:11
    DGP = [0.75; 0.0035; gamma2; 0.05; 3]; 
    Power = [Power; SocIntPowerCalculations(NG_xrt, q, DGP, 0.05)];
end

figure;
plot(Power(:,1),Power(:,2),'b-',Power(:,1),Power(:,5),'r--');
title('Asymptotic Power of Excess Variance and Excess Sensitivity Tests');
xlabel('Social multiplier \gamma');
ylabel('Power');
legend('Excess Variance','Excess Sensitivity');
line(Power(:,3),0:0.01:1,'Color','b','LineStyle',':');
line(Power(:,4),0:0.01:1,'Color','b','LineStyle',':');
line(Power(:,6),0:0.01:1,'Color','r','LineStyle','-.');
line(Power(:,7),0:0.01:1,'Color','r','LineStyle','-.');

