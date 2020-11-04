% List of open inputs

datapath = uigetdir('E:\Analysis-Sudhakar', 'Pick the location of the folder that contain the ROIs');
datafiles = dir(datapath);

spm('defaults', 'fmri');
spm_jobman('initcfg');

for i = 3:length(datafiles)
    
    fprintf('Segmentation going on for %s subject\n\n',datafiles(i).name);
    subjectfiles = dir([datapath, '/', datafiles(i).name]);
    flip2path = ([datapath, '\', datafiles(i).name, '\', subjectfiles(5).name, '\', 'Nifti']);
    flip2file = dir(flip2path);
    fprintf('Flip2 Image is %s\n', flip2path);
    T1mapPath = ([datapath, '\', datafiles(i).name, '\', subjectfiles(6).name, '\', 'Nifti']);
    T1mapfile = dir(T1mapPath);
    fprintf('T1map is %s\n\n', T1mapPath);
% Segmentation
    matlabbatch{1}.spm.spatial.preproc.channel(1).vols = {[flip2path, '\', flip2file(3).name]};
    matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel(1).write = [0 1];

    matlabbatch{1}.spm.spatial.preproc.channel(2).vols = {[T1mapPath, '\', T1mapfile(3).name]};
    matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel(2).write = [0 1];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'C:\Matlab\spm12\tpm\TPM.nii,1'};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'C:\Matlab\spm12\tpm\TPM.nii,2'};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'C:\Matlab\spm12\tpm\TPM.nii,3'};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'C:\Matlab\spm12\tpm\TPM.nii,4'};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'C:\Matlab\spm12\tpm\TPM.nii,5'};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'C:\Matlab\spm12\tpm\TPM.nii,6'};
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
end