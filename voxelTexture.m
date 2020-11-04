function voxelTexture


% Created on Aug by Tummala

% This function quantifies the voxel level Homogeneity from structural
% images. A threshold is set interms of number of voxels to define VOI around each voxel for calculation of
% Entropy.

tic
addpath 'C:\Matlab\spm12';

datapath = 'E:\Analysis-Sudhakar\T1byT2Mapping\TimTrio\Control';
images = dir(datapath); tag = 'MPRAGE';

for s = 3:length(images) % Loop for Subjects
    
    subj = dir([datapath, '\', images(s).name]);
    fprintf('Computing Texture Map for Subject %d/%d\n\n', s-2, length(images) - 2);

for a = 3:length(subj) % Loop for inside subject
    
    if strfind(subj(a).name, 'y'), continue, end
    if strfind(subj(a).name, 'wc1'), continue, end
    if strfind(subj(a).name, 'wc2'), continue, end
    if strfind(subj(a).name, 'c1') & strfind(subj(a).name, tag)
        fprintf('File %s\n', subj(a).name);
        grayM = spm_read_vols(spm_vol([datapath, '\', images(s).name, '\', subj(a).name]));
    end
    if strfind(subj(a).name, 'c2') & strfind(subj(a).name, tag)
        fprintf('File %s\n', subj(a).name);
        whiteM = spm_read_vols(spm_vol([datapath, '\', images(s).name, '\', subj(a).name]));
    end
    if strfind(subj(a).name, 'c3') & strfind(subj(a).name, tag)
        fprintf('File %s\n', subj(a).name);
        csf = spm_read_vols(spm_vol([datapath, '\', images(s).name, '\', subj(a).name]));
    end
    if strfind(subj(a).name, 'c4') & strfind(subj(a).name, tag)
        fprintf('File %s\n', subj(a).name);
        skull = spm_read_vols(spm_vol([datapath, '\', images(s).name, '\', subj(a).name]));
    end
    if strfind(subj(a).name, 'm2') & strfind(subj(a).name, tag)
        fprintf('File %s\n', subj(a).name);
        Vi = spm_vol([datapath, '\', images(s).name, '\', subj(a).name]);
        T1Image = spm_read_vols(Vi);
    end
end

[x, y, z] = size(T1Image);
textureMap = zeros(size(T1Image)); % Texture map initialization
noiseTh = 10; % Threshold to ignore the noise, and also improves the speed
binTh = 0; % Threshold for binary masks (gray, white, csf, skull). Texture is computed only at voxels passes this threshold.

for i = 1:x
    h = waitbar(i/x);
    for j = 1:y
        for k = 1:z
            %thr = grayM(i, j, k) > binTh | whiteM(i, j, k) > binTh |
            %csf(i, j, k) > binTh | skull(i, j, k) > binTh;
            thr = 1;
            if T1Image(i, j, k) > noiseTh & thr
                textureMap(i, j, k) = computeTexture(T1Image, i, j, k, 3);
            else
                continue
            end
        end
    end
end
close(h)

savepath = [datapath, '\', images(s).name];
filename = [savepath, '\', ['m', images(s).name, 'TextureMap', '.nii']];

% Write texture map as a nii file
Vo = struct(	'fname',	filename,...
		'dim',		Vi(1).dim(1:3),...
        'dt',        [spm_type('float32'), 0],... 
		'mat',		Vi(1).mat,...
		'pinfo',	[1.0,0,0]',...
		'descrip',	'textureMap');
Vo = spm_create_vol(Vo);
spm_write_vol(Vo, textureMap);
t= toc;
fprintf('Time taken so far is %1.2fHrs\n\n', t/3600);
end


function [Entropy] = computeTexture(T1Image, x, y, z, th)

% Following lines find the indices for VOI
if x-th <= 0
    xmin = 1;
else
    xmin = x-th;
end
if x+th >= size(T1Image, 1)
    xmax = size(T1Image, 1);
else
    xmax = x+th; 
end
   
if y-th <= 0
    ymin = 1;
else
    ymin = y-th;
end
if y+th >= size(T1Image, 2)
    ymax = size(T1Image, 2);
else
    ymax = y+th;
end

if z-th <= 0
    zmin = 1; 
else
    zmin = z-th;
end
if z+th >= size(T1Image, 3)
    zmax = size(T1Image, 3);
else
    zmax = z+th;
end
   
% Following calculates the texture at a voxel location considering values
% around it, defined by VOI
VOI = T1Image(xmin:xmax, ymin:ymax, zmin:zmax);
VOI = VOI(VOI > 0); % Ignores the zero values
grayValues = ceil(VOI(:));
grayLevels = unique((grayValues(:)));

Entropy = 0;

for l = 1:length(grayLevels)
    grayValue = grayLevels(l);
    pgrayValue = length(grayValues(grayValue == grayValues))/numel(grayValues);
    Entropy = Entropy + (-pgrayValue*log2(pgrayValue));
end

%fprintf('Entropy for voxel location %d, %d, %d is %0.3f\n\n', x, y, z, Entropy);

