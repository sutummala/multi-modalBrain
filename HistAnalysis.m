function HistAnalysis

% Created by Tummala on 04/03/2015

% ROIs Path
roipath = uigetdir('E:\Analysis-Sudhakar', 'Pick the location of the folder that contain the ROIs');
roifiles = dir(roipath);

% DataPath
filepath = uigetdir('E:\Analysis-Sudhakar', 'Pick the location of the folder that contain Smoothed Maps');
files = dir(filepath);

prompt={'Enter the number of Controls', 'Enter number of OSA', 'Enter number of ROIs'};
name='Input for ROI Analysis';
numlines=1;
defaultanswer={'28','19', '69'};
 
options.Resize = 'on';
options.WindowStyle = 'modal';
answer = inputdlg(prompt, name, numlines, defaultanswer, options);

nControls = str2double(answer{1});
nOSA = str2double(answer{2});
nROIs = str2double(answer{3});
wholebrain = 1;

fprintf('Found %d ROIs\n\n', nROIs);
    
    if wholebrain % Whole Brian 
        brainmask = 'E:\Analysis-Sudhakar\OSAMT\TimTrio\brainmask\brainmask.nii';
        file = spm_vol(brainmask);
        roimap = spm_read_vols(file);
        MTRmat = roiHist(files, filepath, roimap, nControls);
        plotHist(MTRmat, roimap, nControls, nOSA);
    else
        for r = 4:2:length(roifiles) % Predefined ROIs
            fprintf('Computing for prediefined ROI %s \n\n', roifiles(r).name);
            roi = spm_vol([roipath, '\', roifiles(r).name]);
            roimap = spm_read_vols(roi);
            MTRmat = roiHist(files, filepath, roimap, nControls);
            plotHist(MTRmat, roimap, nControls, nOSA);
        end
    end
    
function plotHist(MTRmat, roimap, nControls, nOSA)
    
   Healthy = mean(MTRmat(:, 1:nControls), 1); OSA = mean(MTRmat(:, nControls+1:nControls+nOSA), 1);
   [p, ~] = ranksum(Healthy, OSA);
   fprintf('Global Analysis: p-value is %0.4f\n\n', p);
   
   % Healthy
   factor = 0.01; % Weighting factor for StD
   nBins = 100; % Number of bins for HIST
   mHel = mean(MTRmat(:, 1:nControls), 2); sHel = factor*std(mHel); 
   [n1, x1] = hist(mHel, nBins);
   [n2, x2] = hist(mHel - sHel, nBins);
   [n3, x3] = hist(mHel + sHel, nBins);
   figure, h1 = plot(x1, n1./(length(find(roimap(:)))), 'LineWidth', 2); 
   hold on, h2 = plot(x2, n2./(length(find(roimap(:)))), '--', 'LineWidth', 2);
   hold on, h3 = plot(x3, n3./(length(find(roimap(:)))), '-.', 'LineWidth', 2);
   xlabel('% MTR', 'FontSize', 18); ylabel('Normalized Pixel Count', 'FontSize', 18);
   
   % OSA
   mOSA = mean(MTRmat(:, nControls+1:nControls+nOSA), 2); sOSA = factor*std(mOSA);
   [n1, x1] = hist(mOSA, nBins);
   [n2, x2] = hist(mOSA - sOSA, nBins);
   [n3, x3] = hist(mOSA + sOSA, nBins);
   hold on, h4 = plot(x1, n1./(length(find(roimap(:)))), 'r', 'LineWidth', 2); 
   hold on, h5 = plot(x2, n2./(length(find(roimap(:)))), '--r', 'LineWidth', 2);
   hold on, h6 = plot(x3, n3./(length(find(roimap(:)))), '-.r', 'LineWidth', 2);
   if factor > 0.05
        legend([h1, h2, h3, h4 h5 h6], 'ControlMean', 'ControlMean-STD', 'ControlMean+STD', 'OSAMean', 'OSAMean-STD', 'OSAMean+STD', 'Location', 'West');
   else
        legend([h1, h4], 'ControlMean', 'OSAMean', 'West');
   end
      
    
function MTRmat = roiHist(files, filepath, roimap, ~)
        
    MTRmat = zeros(length(find(roimap(:))), length(files)-2);
    
    for d = 3:length(files)
        
        fprintf('Extracting MTR values for %d/%d-------------------------------------------\n\n', d-2, length(files)-2);
        fprintf('Computing for subject %s\n\n', files(d).name(4:10));
        MTR = spm_vol([filepath, '\', files(d).name]);
        MTmap = spm_read_vols(MTR);
        
        % This is needed to correct dimension mismatch in the normalized images
        % between SPM8 and SPM12
        [x,y,z] = size(MTmap);
        MTRmap = 0 * ones(x, y-1, z-1);
        for i = 1:x
            for j = 1:y-1
                for k = 1:z-1
                    MTRmap(i, j, k) = MTmap(i, j, k);
                end
            end
        end
        MTRmat(:, d-2) = MTRmap(roimap > 0);
    end
    



