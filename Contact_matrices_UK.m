%% Code for Figs 2B-F: contact matrix plotter
% Francesca Lovell-Read (francesca.lovell-read@merton.ox.ac.uk)
% Version of: Monday 26th April 2021

% This code reads in the UK contact matrices for all different locations
% (all, home, work, school, other) and plots heat maps for each. It also
% plots heat maps demonstrating the effects of removing different
% categories of contacts
clear

%% READ IN CONTACT MATRIX DATA FROM FILE 'All_UK_data.xlsx' ---------------
C_all = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_all','Range','B4:Q19');
C_school = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_school','Range','B4:Q19');
C_work = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_work','Range','B4:Q19');
C_home = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_home','Range','B4:Q19');
C_other = readmatrix('All_UK_data.xlsx','Sheet','UK_contacts_other','Range','B4:Q19');

%% DEFINE COLORMAP --------------------------------------------------------
cmap = colormap(1-hot); 
cmap(1,:) = [1 1 1]; %Pure white

%% ALL CONTACTS -----------------------------------------------------------
figure(1);
C = C_all; imagesc(flip(C')); colormap(cmap); box off;
h = colorbar; ylabel(h, 'Number of contacts per day', 'Fontsize', 16);

xlabel('Age of individual', 'Fontsize', 16)
xticklabels = ({'0'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'});
xticks = linspace(0.5, size(C, 1)+0.5, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'Fontsize', 16);

ylabel('Age of contact', 'Fontsize', 16)
yticklabels = ({'80'; '70'; '60'; '50'; '40'; '30'; '20'; '10'; '0'});
yticks = linspace(0.5, size(C, 1)+0.5, numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'Fontsize', 16);

set(gca,'fontsize',20,'linewidth',2);
set(h,'fontsize',20,'linewidth',2);

%% HOME CONTACTS ----------------------------------------------------------
figure(2);
C = C_home; imagesc(flip(C')); colormap(cmap); box off;
h = colorbar; ylabel(h, 'Number of contacts per day', 'Fontsize', 16);

xlabel('Age of individual', 'Fontsize', 16)
xticklabels = ({'0'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'});
xticks = linspace(0.5, size(C, 1)+0.5, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'Fontsize', 16);

ylabel('Age of contact', 'Fontsize', 16)
yticklabels = ({'80'; '70'; '60'; '50'; '40'; '30'; '20'; '10'; '0'});
yticks = linspace(0.5, size(C, 1)+0.5, numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'Fontsize', 16);

set(gca,'fontsize',20,'linewidth',2);
set(h,'fontsize',20,'linewidth',2);

%% WORK CONTACTS ----------------------------------------------------------
figure(3); 
C = C_work; imagesc(flip(C')); colormap(cmap); box off;
h = colorbar; ylabel(h, 'Number of contacts per day', 'Fontsize', 16);

xlabel('Age of individual', 'Fontsize', 16)
xticklabels = ({'0'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'});
xticks = linspace(0.5, size(C, 1)+0.5, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'Fontsize', 16);

ylabel('Age of contact', 'Fontsize', 16)
yticklabels = ({'80'; '70'; '60'; '50'; '40'; '30'; '20'; '10'; '0'});
yticks = linspace(0.5, size(C, 1)+0.5, numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'Fontsize', 16);

set(gca,'fontsize',20,'linewidth',2);
set(h,'fontsize',20,'linewidth',2);

%% SCHOOL CONTACTS --------------------------------------------------------
figure(4); 
C = C_school; imagesc(flip(C')); colormap(cmap); box off;
h = colorbar; ylabel(h, 'Number of contacts per day', 'Fontsize', 16);

xlabel('Age of individual', 'Fontsize', 16)
xticklabels = ({'0'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'});
xticks = linspace(0.5, size(C, 1)+0.5, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'Fontsize', 16);

ylabel('Age of contact', 'Fontsize', 16)
yticklabels = ({'80'; '70'; '60'; '50'; '40'; '30'; '20'; '10'; '0'});
yticks = linspace(0.5, size(C, 1)+0.5, numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'Fontsize', 16);

set(gca,'fontsize',20,'linewidth',2);
set(h,'fontsize',20,'linewidth',2);

%% OTHER CONTACTS ---------------------------------------------------------
figure(5); 
C = C_other; imagesc(flip(C')); colormap(cmap); box off;
h = colorbar; ylabel(h, 'Number of contacts per day', 'Fontsize', 16);

xlabel('Age of individual', 'Fontsize', 16)
xticklabels = ({'0'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'});
xticks = linspace(0.5, size(C, 1)+0.5, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'Fontsize', 16);

ylabel('Age of contact', 'Fontsize', 16)
yticklabels = ({'80'; '70'; '60'; '50'; '40'; '30'; '20'; '10'; '0'});
yticks = linspace(0.5, size(C, 1)+0.5, numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'Fontsize', 16);

set(gca,'fontsize',20,'linewidth',2);
set(h,'fontsize',20,'linewidth',2);
