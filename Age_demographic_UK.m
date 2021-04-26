%% Code for Fig 2A: age demographic plotter
% Francesca Lovell-Read (francesca.lovell-read@merton.ox.ac.uk)
% Version of: Monday 26th April 2021

% This code produces a population pyramid for the age demographic in the
% UK using 2020 projected data from the United Nations (available at 
% https://population.un.org/wpp/Download/Standard/Population/)
clear

%% READ IN DATA FROM FILE 'All_UK_data.xlsx' ------------------------------
UK_all = readmatrix('All_UK_data.xlsx','Sheet','UK_total_pop_by_age','Range','I6:AB6');
UK_males = readmatrix('All_UK_data.xlsx','Sheet','UK_male_pop_by_age','Range','I6:AB6');
UK_females = readmatrix('All_UK_data.xlsx','Sheet','UK_female_pop_by_age','Range','I6:AB6');
UK_total_pop = sum(UK_all);

%% PLOT -------------------------------------------------------------------
figure(); hold on; box off; 
males_bar = bar(100*UK_males/UK_total_pop,'hist');
females_bar = bar(-100*UK_females/UK_total_pop,'hist');
set(males_bar,'FaceColor',.8*[0.53 0.81 0.98],'linewidth',1);
set(females_bar,'FaceColor',.8*[1 0.41 0.71],'linewidth',1);

xlabel('Age');
xlim([0.5 20.5]);
xticklabels = ({'0'; '20'; '40'; '60'; '80'; '100'});
xticks = linspace(0.5, 20.5, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'Fontsize', 16);

ylabel('Proportion of population (%)'); 
ylim([-7,7]);
yticklabels = ({'6','4','2','0','2','4','6'});
yticks = linspace(-6, 6, numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'Fontsize', 16);

leg = legend('Men','Women'); leg.FontSize = 16;
view(-90,90);
set(gca,'fontsize',20,'linewidth',2);
