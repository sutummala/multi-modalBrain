function preProcessing

% Created on April 2015 by Tummala (compatible for SPM12)
% Processing for calculation of T1 Maps

datapath = 'E:\Analysis-Sudhakar\T1Mapping\Data\Control'; % Keep Control and OSA in one folder w.r.t subject ID (For example, CON5001, OSA5013, etc...)
datafiles = dir(datapath);

addpath 'C:\Matlab\spm12';
spm('defaults', 'fmri');
spm_jobman('initcfg');

for i = 3:length(datafiles)
    
    subjectfiles = dir([datapath, '/', datafiles(i).name]);
    
    flip1path = ([datapath, '\', datafiles(i).name, '\', subjectfiles(end-4).name, '\', 'Nifti']);
    flip1file = dir(flip1path); % Flip2 image was used for segmentation
    fprintf('Flip1 Image is %s\n', [flip1path, '\', flip1file(end).name]);
    
    flip2path = ([datapath, '\', datafiles(i).name, '\', subjectfiles(end-3).name, '\', 'Nifti']);
    flip2file = dir(flip2path); % Flip2 image was used for segmentation
    fprintf('Flip2 Image is %s\n', [flip2path, '\', flip2file(9).name]);
    
    T1mapPath = ([datapath, '\', datafiles(i).name, '\', subjectfiles(end-2).name, '\', 'Nifti']);
    T1mapfile = dir(T1mapPath); % T1 map 
    fprintf('T1map is %s\n\n', [T1mapPath, '\', T1mapfile(end).name]);
    
    computeT1map(flip1path, flip2path, T1mapPath);
    
%% Segmentation
    fprintf('Segmentation going on for %s subject\n\n',datafiles(i).name);
    
    matlabbatch{1}.spm.spatial.preproc.channel(1).vols = {[flip2path, '\', flip2file(end).name]};
    matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel(1).write = [0 1];

    matlabbatch{1}.spm.spatial.preproc.channel(2).vols = {[T1mapPath, '\', T1mapfile(end).name]};
    matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel(2).write = [0 1];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm('dir') '/tpm/TPM.nii']};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm('dir') '/tpm/TPM.nii']};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm('dir') '/tpm/TPM.nii']};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm('dir') '/tpm/TPM.nii']};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm('dir') '/tpm/TPM.nii']};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm('dir') '/tpm/TPM.nii']};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 2;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 2;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    
%% Normalization (Estimate and Write)
    
    fprintf('Normalization going on for %s subject\n\n',datafiles(i).name);
    
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {[flip2path, '\m', flip2file(end).name]};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[flip2path, '\c1', flip2file(end).name]
                                                                      [flip2path, '\c2', flip2file(end).name]
                                                                      [T1mapPath, '\m', T1mapfile(end).name]};                                                          
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {[spm('dir') '/tpm/TPM.nii']};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 2;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -90; 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [1.5 1.5 1.5];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    
%% Smoothing
    
    fprintf('Smoothing going on for %s subject\n\n',datafiles(i).name);
    
    matlabbatch{1}.spm.spatial.smooth.data = {[T1mapPath, '\wm', T1mapfile(end).name]};
    matlabbatch{1}.spm.spatial.smooth.fwhm = [10 10 10];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                 
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end


function T1map = computeT1map(flip1path, flip2path, T1mapPath)

flip1file = dir(flip1path);
flip2file = dir(flip2path);

flip1Image = spm_read_vols(spm_vol([flip1path, '\', flip1file(end).name]));
flip2Image = spm_read_vols(spm_vol([flip2path, '\', flip2file(9).name]));

T1map = zeros(size(flip1Image));
a1 = 5; a2 = 26; TR = 15;

c2 = sind(a1)/sind(a2);

for a = 1:size(T1map, 1)
    h = waitbar(a/size(T1map, 1));
    for b = 1:size(T1map, 2)
        for c = 1:size(T1map, 3)
            if flip1Image(a, b, c) > 20 & flip2Image(a, b, c) > 20
            c1 = flip1Image(a, b, c)/flip2Image(a, b, c);
            C = c2/c1;
            T1map(a, b, c) = floor(-TR/(log((1-C)/(cosd(a1)-(C*cosd(a2))))));
            fprintf('T1 Value at %d %d %d is %4.1f\n', a, b, c, T1map(a, b, c));
            end
        end
    end
end
close(h);
            
Vi = spm_vol([flip1path, '\', flip1file(end).name]);
filename = [T1mapPath, '\', ['mCON', flip1file(end).name(2:5), 'T1map.nii']];
Vo = struct('fname', filename,'dim',Vi(1).dim(1:3),'dt',[spm_type('float32'), 0],'mat', Vi(1).mat,'pinfo',[1.0,0,0]','descrip',	'T1Map');
Vo = spm_create_vol(Vo);
spm_write_vol(Vo, T1map)




























