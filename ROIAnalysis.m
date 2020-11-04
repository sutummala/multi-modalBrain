function ROIAnalysis

% Created by Tummala on 03/20/2015

% ROIs path
roipath = 'E:\Analysis-Sudhakar\OSAMT\ROIs';
roifiles = dir(roipath);
% 
% whiteMask = spm_read_vols(spm_vol('E:\Analysis-Sudhakar\OSAMT\TimTrio\brainmask\whitemattermask.nii'));
% grayMask = spm_read_vols(spm_vol('E:\Analysis-Sudhakar\OSAMT\TimTrio\brainmask\graymattermask.nii'));

% Smoothed Maps Path
filepath = 'E:\Analysis-Sudhakar\voxelTexture\Analysis-all';
files = dir(filepath);

prompt={'Enter the number of Controls', 'Enter number of Cases', 'Enter number of ROIs'};
name='Input for ROI Analysis';
numlines=1;
defaultanswer={'26','22', '210'};
 
options.Resize = 'on';
options.WindowStyle = 'modal';
answer = inputdlg(prompt, name, numlines, defaultanswer, options);

nControls = str2double(answer{1});
nOSA = str2double(answer{2});
nROIs = str2double(answer{3});

fprintf('Found %d ROIs\n\n', nROIs);
      
xlsMatrix = cell(nControls+nOSA+5, nROIs+5); % Matrix that will be saved as a XL
xlsMatrix{1,1} = 'SubjectID'; whiteMTR = []; 
grayMTR = whiteMTR;

% regional labels
nary = spm_vol('E:\Analysis-Sudhakar\OSA and Control Kurtosis\OSA and Controls-AK\binaryAK.nii');
naryD = spm_read_vols(nary);
Rois = 1;

% labels NeuroMorphometrics

nMor = spm_read_vols(spm_vol('C:\Matlab\spm12\tpm\labels_Neuromorphometrics.nii'));

for d = 3:length(files)
    
    fprintf('Computing ROI values for %d/%d\n\n', d-2, length(files)-2);
    h = waitbar(d/length(files));
    xlsMatrix{d-1, 1} = files(d).name(7:13); % Need to change the length rage in name, if necessary
                    
    if strfind(files(d).name, 'sw')
        fprintf('Reading MTR map %s from subject %s\n\n', files(d).name, files(d).name(7:13));  
        MTR = spm_vol([filepath, '\', files(d).name]);
        MTmap = spm_read_vols(MTR);
        %whiteMTR(end+1) = sum(MTmap(:).*whiteMask(:))/numel(find(whiteMask(:))); % White matter mean value
        %grayMTR(end+1) = sum(MTmap(:).*grayMask(:))/numel(find(grayMask(:))); % Gray matter mean value
    end
        
     [x,y,z] = size(MTmap);
     MTRmap = zeros(x, y-1, z-1);
     
     for i = 1:x
         for j = 1:y-1
             for k = 1:z-1
                 MTRmap(i, j, k) = MTmap(i, j, k);
             end
         end
     end
 
% % This is needed to correct dimension mismatch in the normalized images
% % between SPM8 and SPM12
nMor1 = zeros(size(MTmap)); 
    for i = 1:x
        for j = 1:y
            for k = 1:z
                if nMor(i, j, k) > 0
                    nMor1(i, j, k) = nMor(i, j, k);
                end
            end
        end
    end
nMor2 = nMor1(1:size(MTmap, 1), 1:size(MTmap, 2), 1:size(MTmap, 3));

if Rois

    for r = 4:2:length(roifiles)
        
            fprintf('Computing for prediefined ROI %s \n\n', roifiles(r).name);
            xlsMatrix{1, r/2} = roifiles(r).name(1:end-4);
            roi = spm_vol([roipath, '\', roifiles(r).name]);
            roimap = spm_read_vols(roi);
            roivalue = mean(MTRmap(roimap > 0));
            xlsMatrix{d-1, r/2} = roivalue;
            fprintf('ROI value for %s is %0.6f\n\n', roifiles(r).name, roivalue);
            fprintf('====================================================\n\n');
    end
else


rois = max(nMor(:)); % zero should be ignored

    for r = 1:rois
        xlsMatrix{1, r+1} = num2str(r);
        roivalues = [];
        for a = 1:size(naryD, 1)
            for b = 1:size(naryD, 2)
                for c = 1:size(naryD, 3)
                    if naryD(a, b, c) > 0 & nMor(a, b, c) == r      
                            roivalues(end + 1) =  MTmap(a, b, c);
                    end
                end
            end
        end
            xlsMatrix{2, r+1} = numel(roivalues);
            xlsMatrix{d, r+1} = mean(roivalues);
            fprintf('ROI value for %d is %0.6f\n\n', r, mean(roivalues))
            fprintf('====================================================\n\n');
            clear roivalues
    end
end
end
close(h);
xlswrite('ROITex.xlsx', xlsMatrix); % Saves an XL for all regions
%save('xlsMatrix');

% Statistical Analysis

data = xlsread('ROITex.xlsx');
statMatrix = cell(nROIs + 5, 8);
statMatrix{1, 1} = 'ROI'; statMatrix{1, 2} = 'Control Mean'; statMatrix{1,3} = 'Control STD'; statMatrix{1,4} = 'OSA Mean'; statMatrix{1,5} = 'OSA STD';
statMatrix{1, 6} = 'p-value';
t = 2;

for a = 1:size(data, 2)
    statMatrix{a+1, 1} = xlsMatrix{1, a+1};
    [h, p, ci, stats] = ttest2(data(t:nControls+1, a), data(nControls+t:nControls+nOSA, a));
    fprintf('Region is %s and p-value is %0.8f\n', xlsMatrix{1, a+1}, p);
    fprintf('Mean and STD for Control is %0.5f/%0.5f and for OSA is %0.5f/%0.5f\n\n\n', mean(data(t:nControls+1, a)), std(data(t:nControls+1, a)),...
        mean(data(nControls+t:nControls+nOSA, a)), std(data(nControls+t:nControls+nOSA, a)));
    statMatrix{a+1, 2} = mean(data(t:nControls+1, a));
    statMatrix{a+1, 3} = std(data(t:nControls+1, a));
    statMatrix{a+1, 4} = mean(data(nControls+t:nControls+nOSA, a));
    statMatrix{a+1, 5} = std(data(nControls+t:nControls+nOSA, a));
    statMatrix{a+1, 6} = p;
    statMatrix{a+1, 7} = abs(stats.tstat);
end

xlswrite('ROITexstats.xlsx', statMatrix);  % Saves statistics for all regions with p-values     
