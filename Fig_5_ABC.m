%% Code for Figs 5A-C: the effects of combining contact-reducing NPIs
% Francesca Lovell-Read (francesca.lovell-read@merton.ox.ac.uk)
% Version of: Monday 26th April 2021

% This code simultaneously varies the reduction in 'school' and 'work' contacts
% between 0% and 100% for a specified reduction in 'other' contacts, and computes
% the local outbreak probability over that space. It plots a heat map of the
% outbreak probabilities, overlaid with contours along which the outbreak
% probability is constant. Contains data for each of the three scenarios A,B,C.
clear
fprintf('\n\t***RUNNING***\n');

%% READ IN DATA FROM FILE 'All_UK_data.xlsx' ------------------------------
fprintf('\tReading in data...\n');
% Contact matrix: all contacts
C = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_all','Range','B4:Q19');
% Contact matrices: individual components
C_school = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_school','Range','B4:Q19');
C_work = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_work','Range','B4:Q19');
C_home = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_home','Range','B4:Q19');
C_other = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_other','Range','B4:Q19');
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

% Isolation rate of symptomatic hosts ('rho'): one entry per age group
rho = zeros(1,16);
% Isolation rate of nonsymptomatic hosts ('sigma'): one entry per age group
sigma = zeros(1,16);

% Reduction in 'other' contacts (0 = no reduction, 1 = 100% reduction)
o_s = 0.75;
% Vectors for varying strength of 'school' and 'work' controls (0 = no reduction, 1 = 100% reduction)
school_strength_vec = 0:0.2:1;
work_strength_vec = 0:0.2:1;

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

%% CALCULATE MATRIX OF LOCAL OUTBREAK PROBABILITIES -----------------------
fprintf('\tComputing local outbreak probabilities...\n');

M_control = zeros(length(school_strength_vec),length(work_strength_vec)); % For storing values

for i=1:length(school_strength_vec)
    s_s = school_strength_vec(i);
    for j=1:length(work_strength_vec)
        w_s = work_strength_vec(j);

        % Compute contact matrix under specified controls
        C_controls = C-s_s*C_school-w_s*C_work-o_s*C_other;

        R = bsxfun(@times,C_controls,K); % Scales each column in the contact matrix by the relevant susceptibility
        R_row_sums = sum(R,2)';  % Computes the row sums of the scaled matrix R
        multiplier = J.*N_prop;
        S = (B)*(J.*R_row_sums);

        % SOLVE SYSTEM OF SIMULTANEOUS EQUATIONS
        % Create n symbolic 'r' variables (r1, r2, ... , rn)
        syms 'r' [1 48]
        % Solve the system of simultaneous equations (defined in function at end of script)
        fun = @(r)myfunc(r,B,mu,rho,eta,lambda,theta,nu,xi,sigma,J,R,S);
        r0 = zeros(1,48)+0.5; % Initial conditions
        options = optimset('Display','off'); % Suppresses fsolve output in command window
        r=fsolve(fun,r0,options);
        % Compute vector of local outbreak probabilities
        p_all = 1-r;
        p_symp = p_all(1:16); % Starting from a symptomatic host
        p_presymp = p_all(17:32); % Starting from a presymptomatic host
        p_asymp = p_all(33:48); % Starting from an asymptomatic host
        p = xi.*p_asymp+(1-xi).*p_presymp; % Starting from a nonsymptomatic host

        % Compute weighted average outbreak probability across age groups, starting from a
        % nonsymptomatic host and store
        M_control(i,j) = sum(p.*N_prop);
        
    end
end

%% PLOT -------------------------------------------------------------------
fprintf('\tPlotting...\n');
figure(); 

% Contour plot of local outbreak probabilities
levels = [0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45]; % Specify contours to plot
[C,h]=contourf(M_control',levels);
h.LineColor = [1 0 0]; h.LineStyle = ':'; h.LineWidth = 2;
mylabels = clabel(C,h,'manual','color','k','FontSize',18,'FontWeight','bold');
for i=1:length(mylabels); mylabels(i).Color = [1 1 1]; end

% Colorbar
colbar = colorbar;
ylabel(colbar, 'Average outbreak probability (P)');
set(colbar,'linewidth',2,'fontsize',20);
caxis([0 0.44]); % Set colorbar limits

xlabel('Reduction in school contacts (%)');
xticklabels = ({'0'; '20'; '40'; '60'; '80'; '100'});
xticks = linspace(1, length(school_strength_vec), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'Fontsize', 18);

ylabel('Reduction in work contacts (%)');
yticklabels = ({'0'; '20'; '40'; '60'; '80'; '100'});
yticks = linspace(1, length(work_strength_vec), numel(xticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'Fontsize', 18);

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
