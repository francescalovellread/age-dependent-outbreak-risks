%% Code for Fig 3: calculating age-dependent local outbreak probabilities
% Francesca Lovell-Read (francesca.lovell-read@merton.ox.ac.uk)
% Version of: Monday 26th April 2021

% This code uses the UK 'all contacts' matrix and population demographic
% data to compute the probability of a local outbreak starting from a
% single infected individual in each of 16 possible age classes, for each of
% the three scenarios A,B and C. It numerically solves the system of simultaneous
% equations governing the x_k, y_k, z_k for a given R0, infectivity and
% susceptibility parameters and removal rate. It also calculates the weighted
% average P. It then plots a bar graph of the age dependent risk profile, along
% with a line overlaid at the position of the weighted average P.
clear
fprintf('\n\t***RUNNING***\n');

%% READ IN DATA FROM FILE 'All_UK_data.xslx' ------------------------------
fprintf('\n\tReading in data...\n');
% Contact matrix (all contacts)
C = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_all','Range','B4:Q19');
% Age demographic
pop = readmatrix('All_UK_data.xlsx','Sheet','UK_total_pop_by_age','Range','I10:X10');

%% SET MODEL PARAMETERS ---------------------------------------------------
% Basic reproductive number (in the absence of control)
R0 = 3;
% Infectivity vector (the 'taus'): one entry per age group
J = zeros(1,16)+1;
% Symptomatic recovery rate ('mu')
mu = 1/8;
% Presymptomatic progression rate ('lambda')
lambda = 1/2;
% Asymptomatic recovery rate ('nu')
nu = 1/10;

% Select model: A (constant susceptibility and clinical fraction), B (variable
% susceptibility and constant clinical fraction) or C (variable susceptibility and
% clinical fraction). Comment in/out as appropriate

% % MODEL A
% % Susceptibility vector (the 'omegas'): one entry per age group
% K = zeros(1,16)+1;
% % Asymptomatic proportion ('xi')
% xi = zeros(1,16)+0.5839;
% 
% % MODEL B
% % Susceptibility vector (the 'omegas'): one entry per age group
% K = [0.4 0.4 0.38 0.38 0.79 0.79 0.86 0.86 0.8 0.8 0.82 0.82 0.88 0.88 0.74 0.74];
% % Asymptomatic proportion ('xi')
% xi = zeros(1,16)+0.5839;

% MODEL C
% Susceptibility vector (the 'omegas'): one entry per age group
K = [0.4 0.4 0.38 0.38 0.79 0.79 0.86 0.86 0.8 0.8 0.82 0.82 0.88 0.88 0.74 0.74];
% Asymptomatic proportion ('xi')
clinical_fraction = [0.29 0.29 0.21 0.21 0.27 0.27 0.33 0.33 0.4 0.4 0.49 0.49 0.63 0.63 0.69 0.69];
xi = 1-clinical_fraction; 

% Proportion of infections coming from presymptomatic hosts
Kp = 0.489;
% Proportion of infections coming from asymptomatic hosts
Ka = 0.106;

% Isolation rate of symptomatic hosts ('rho')
rho = zeros(1,16);
% Isolation rate of nonsymptomatic hosts ('sigma')
sigma = zeros(1,16);

%% END USER INPUT ---------------------------------------------------------

%% PRELIMINARY CALCULATIONS -----------------------------------------------
% Define sub-population sizes:
N = 1000*pop;
% Calculate total population size:
N_tot = sum(N);
% Calculate sub-population proportions:
N_prop = N/N_tot;

% Compute scaling factor B to ensure model gives specified R0
R = bsxfun(@times,C,K); % Scales each column in the contact matrix by the relevant susceptibility
R_row_sums = sum(R,2)';  % Computes the row sums of the scaled matrix R
multiplier = J.*N_prop; % Scales sub-population sizes by their relative infectivity

% Compute relative contributions of asymptomatic, presymptomatic and symptomatic hosts
A_cont = sum(N.*J.*xi./(nu+sigma).*R_row_sums);
P_cont = sum(N.*J.*(1-xi)./(lambda+sigma).*R_row_sums);
S_cont = sum(N.*J.*(1-xi)./(lambda+sigma).*lambda./(mu+rho).*R_row_sums);

% Compute transmission rate scaling factors eta, theta
eta = (S_cont/P_cont)*Kp/(1-Ka-Kp);
theta = (S_cont/A_cont)*Ka/(1-Ka-Kp);

multiplier_2 = ((theta*xi)./(nu+sigma))+((1-xi)./(lambda+sigma)).*(eta+lambda./(mu+rho));
multiplier_3 = sum(multiplier.*R_row_sums.*multiplier_2);
B = R0/multiplier_3;
S = (B)*(J.*R_row_sums);

%% SOLVE SYSTEM OF SIMULTANEOUS EQUATIONS ---------------------------------
fprintf('\tComputing baseline local outbreak probability...\n');
% Create n symbolic 'r' variables (r1, r2, ... , rn)
syms 'r' [1 48]
% Solve the system of simultaneous equations (defined in function at end of script)
fun = @(r)myfunc(r,B,mu,rho,eta,lambda,theta,nu,xi,sigma,J,R,S);
r0 = zeros(1,48); % Initial conditions

options = optimset('Display','off'); % Suppresses fsolve output in command window
r=fsolve(fun,r0,options);
% Compute vector of PLOs
p_all = 1-r;
p_symp = p_all(1:16);
p_presymp = p_all(17:32);
p_asymp = p_all(33:48);
p = xi.*p_asymp+(1-xi).*p_presymp;
% Compute weighted average PLO
PLO = sum(p.*N_prop);

%% PLOT -------------------------------------------------------------------
fprintf('\tPlotting...\n');
figure(); hold on;

myplot(1) = bar(p,'Facecolor',[0.7 0.7 0.7],'Edgecolor',[0 0 0],'Linewidth',1);
myplot(2) = plot([0 17],[PLO PLO],'color',[0 0 0],'linewidth',3);

leg = legend(myplot(2),'Average outbreak probability (P)');
leg.Box = 'on'; leg.FontSize = 20;

xlabel('Age group of index case'); xlim([0.5 16.5]);
xticklabels = ({'0'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'});
xticks = linspace(0.5, 16.5, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);

ylabel('Probability of local outbreak (p_k)'); ylim([0 1]);

box off; set(gca,'Fontsize',20,'Linewidth',2);
fprintf('\n\t***DONE!***\n\n');

%% FUNCTION DEFINING SYSTEM OF SIMULTANEOUS EQUATIONS, FOR USE WITH FSOLVE 
function F = myfunc(r,B,mu,rho,eta,lambda,theta,nu,xi,sigma,J,R,S)
F = zeros(1,48);
    for k = 1:16
        F(k) = -(1+(1/(mu+rho(k)))*S(k))*r(k) + 1 + r(k)*(B/(mu+rho(k)))*J(k)*( R(k,1)*((1-xi(1))*r(17)+xi(1)*r(33)) + R(k,2)*((1-xi(2))*r(18)+xi(2)*r(34)) + R(k,3)*((1-xi(3))*r(19)+xi(3)*r(35)) + R(k,4)*((1-xi(4))*r(20)+xi(4)*r(36)) + R(k,5)*((1-xi(5))*r(21)+xi(5)*r(37)) + R(k,6)*((1-xi(6))*r(22)+xi(6)*r(38)) + R(k,7)*((1-xi(7))*r(23)+xi(7)*r(39)) + R(k,8)*((1-xi(8))*r(24)+xi(8)*r(40)) + R(k,9)*((1-xi(9))*r(25)+xi(9)*r(41)) + R(k,10)*((1-xi(10))*r(26)+xi(10)*r(42)) + R(k,11)*((1-xi(11))*r(27)+xi(11)*r(43)) + R(k,12)*((1-xi(12))*r(28)+xi(12)*r(44)) + R(k,13)*((1-xi(13))*r(29)+xi(13)*r(45)) + R(k,14)*((1-xi(14))*r(30)+xi(14)*r(46)) + R(k,15)*((1-xi(15))*r(31)+xi(15)*r(47)) + R(k,16)*((1-xi(16))*r(32)+xi(16)*r(48)));
    end
    for k = 17:32
        F(k) = -(1+(eta/(lambda+sigma(k-16)))*S(k-16))*r(k) + (lambda*r(k-16)+sigma(k-16))/(lambda+sigma(k-16)) + r(k)*B*(eta/(lambda+sigma(k-16)))*J(k-16)*( R(k-16,1)*((1-xi(1))*r(17)+xi(1)*r(33)) + R(k-16,2)*((1-xi(2))*r(18)+xi(2)*r(34)) + R(k-16,3)*((1-xi(3))*r(19)+xi(3)*r(35)) + R(k-16,4)*((1-xi(4))*r(20)+xi(4)*r(36)) + R(k-16,5)*((1-xi(5))*r(21)+xi(5)*r(37)) + R(k-16,6)*((1-xi(6))*r(22)+xi(6)*r(38)) + R(k-16,7)*((1-xi(7))*r(23)+xi(7)*r(39)) + R(k-16,8)*((1-xi(8))*r(24)+xi(8)*r(40)) + R(k-16,9)*((1-xi(9))*r(25)+xi(9)*r(41)) + R(k-16,10)*((1-xi(10))*r(26)+xi(10)*r(42)) + R(k-16,11)*((1-xi(11))*r(27)+xi(11)*r(43)) + R(k-16,12)*((1-xi(12))*r(28)+xi(12)*r(44)) + R(k-16,13)*((1-xi(13))*r(29)+xi(13)*r(45)) + R(k-16,14)*((1-xi(14))*r(30)+xi(14)*r(46)) + R(k-16,15)*((1-xi(15))*r(31)+xi(15)*r(47)) + R(k-16,16)*((1-xi(16))*r(32)+xi(16)*r(48)));
    end
    for k = 33:48
        F(k) = -(1+(theta/(nu+sigma(k-32)))*S(k-32))*r(k) + 1 + r(k)*B*(theta/(nu+sigma(k-32)))*J(k-32)*( R(k-32,1)*((1-xi(1))*r(17)+xi(1)*r(33)) + R(k-32,2)*((1-xi(2))*r(18)+xi(2)*r(34)) + R(k-32,3)*((1-xi(3))*r(19)+xi(3)*r(35)) + R(k-32,4)*((1-xi(4))*r(20)+xi(4)*r(36)) + R(k-32,5)*((1-xi(5))*r(21)+xi(5)*r(37)) + R(k-32,6)*((1-xi(6))*r(22)+xi(6)*r(38)) + R(k-32,7)*((1-xi(7))*r(23)+xi(7)*r(39)) + R(k-32,8)*((1-xi(8))*r(24)+xi(8)*r(40)) + R(k-32,9)*((1-xi(9))*r(25)+xi(9)*r(41)) + R(k-32,10)*((1-xi(10))*r(26)+xi(10)*r(42)) + R(k-32,11)*((1-xi(11))*r(27)+xi(11)*r(43)) + R(k-32,12)*((1-xi(12))*r(28)+xi(12)*r(44)) + R(k-32,13)*((1-xi(13))*r(29)+xi(13)*r(45)) + R(k-32,14)*((1-xi(14))*r(30)+xi(14)*r(46)) + R(k-32,15)*((1-xi(15))*r(31)+xi(15)*r(47)) + R(k-32,16)*((1-xi(16))*r(32)+xi(16)*r(48)));
    end
end
