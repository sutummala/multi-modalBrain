function ANCOVA


% Created by Tummala 09/10/2015. The following lines do ANCOVA based Sex
% and Age. Multiple comparision is done using Ramdom Field Threshold


addpath E:\Analysis-Sudhakar\Matlab\SurfStat
addpath E:\Analysis-Sudhakar\CHD-Caudate\SPHARM-MAT
load('E:\Analysis-Sudhakar\Matlab\CovariatesPutamen.mat'); % Demographic Data
load('E:\Analysis-Sudhakar\CHD-Caudate\avgsurfandSurfData'); % Surface measures Data

N = size(Age, 1);
Nvert = size(atlas, 1);

leftsurf = zeros(N, Nvert, 3); % Initializing a 3D matrix

% Creating avg Surf
avsurf.coord = atlas;
avsurf.tri = faces;

% Rearranging the data in 3D matrix
for i=1:N
leftsurf(i,:,:) = defms{i}; % Difference between subject surface to average surface, gives estimate of thickness differences. get defms from extractSignals.m from SPHARM.MAT
end

% Following lines do ANCOVA
slm0 = SurfStatLinMod(leftsurf, Sex + Age + Group, avsurf);
slm = SurfStatT(slm0, double(Group));
figure_trimesh(avsurf, slm.t); % Visualization with out multiple correction applied
axis off

% p-value threshold from random field theory
pvalue = [0.001 0.005 0.01 0.05 0.1];
threshold = randomfield_threshold(slm, pvalue);
figure_trimesh1(avsurf, slm.t, threshold(4)); % Visualization with multiple correction applied
axis off
