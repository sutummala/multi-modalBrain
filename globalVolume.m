function globalVolume


% Created by Tummala on 07/16-2015

addpath C:\Matlab\spm12

datapath = 'E:\Analysis-Sudhakar\CHD-Caudate\Caudate Right - completed'; % Right
datapath1 = 'E:\Analysis-Sudhakar\CHD-Caudate\Caudate Left -  completed'; % Left

images = dir(datapath); HelR = []; CHDR = []; HelL = []; CHDL = [];
xlsMatrix = cell(length(images), 10);

for i = 3:length(images)
    
% Reading the binary NifTI files
    vr = spm_vol([datapath '\' images(i).name]); % Right 
    vl = spm_vol([datapath1 '\' images(i).name]); % Left
    volR = spm_read_vols(vr); 
    volL = spm_read_vols(vl);
    
% Following lines can help visualizing the segmentation    
    if 0 % change to 1 if you want to visualize the binaries in 3D
        figure
        fv = isosurface(smooth3(volR));
        p = patch(fv);
        set(p, 'FaceColor', 'blue', 'EdgeColor', 'blue', 'LineStyle', 'none');
        hold on
        fv = isosurface(smooth3(volL));
        p = patch(fv);
        set(p, 'FaceColor', 'green', 'EdgeColor', 'green', 'LineStyle', 'none');
        l = light;
        light('Position', -get(l,'Position'))
        lighting gouraud
    end
    
% Calculation of Global Volume     
    volumeR = abs(numel(find(volR(:) > 0)) * vr.mat(1, 1) * vr.mat(2, 2) * vr.mat(3, 3)); 
    volumeL = abs(numel(find(volL(:) > 0)) * vl.mat(1, 1) * vl.mat(2, 2) * vl.mat(3, 3));
    fprintf('Volume for Right %s is %3.2f\n\n', images(i).name, volumeR); 
    fprintf('Volume for Left %s is %3.2f\n\n', images(i).name, volumeL);

% Separating into Healthy and CHD    
    if images(i).name(13) == 'H'
        HelR(end + 1) = volumeR;
        HelL(end + 1) = volumeL;
    else
        CHDR(end + 1) = volumeR;
        CHDL(end + 1) = volumeL;
    end
end

statAnalysis(HelR, CHDR, 'Right') % t-test Right 
statAnalysis(HelL, CHDL, 'Left') % t-test Left 

function statAnalysis(Hel, CHD, tag)

h1 = kstest(Hel); % Checking normality
h2 = kstest(CHD); % Checking normality

if 1
    figure
    boxplot([Hel CHD], [zeros(length(Hel), 1); ones(length(CHD), 1)]') % Box plot between Healthy and CHD
    
    if strcmp(tag, 'Right')
        title('Right', 'FontSize', 18);
    else
        title('Left', 'FontSize', 18);
    end
    xlabel('Subjects (0 is Healthy and 1 is CHD)', 'FontSize', 18);
    ylabel('Volume in mm^3', 'FontSize', 18);
end
    
if h1 + h2 == 2
   [p, h] = ranksum(Hel, CHD); % if data is non-Gaussian
else
   [h, p] = ttest2(Hel, CHD); % if data is Gaussian
end

fprintf('P-value to separate Healthy from CHD based on %s Caudate Volume is %0.6f\n\n', tag, p);
    

