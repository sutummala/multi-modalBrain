function preProcessing

% Created on April 2015 by Tummala (compatible for SPM12)

datapath = uigetdir('E:\Analysis-Sudhakar', 'Pick the location of the folder that contain the Data'); % Keep Control and OSA in one folder w.r.t subject ID (For example, CON5001, OSA5013, etc...)
datafiles = dir(datapath);

spm('defaults', 'fmri');
spm_jobman('initcfg');

for i = 31:length(datafiles)
    
    subjectfiles = dir([datapath, '/', datafiles(i).name]);
    
    T1dicompath = ([datapath, '\', datafiles(i).name, '\', subjectfiles(end-1).name, '\', 'DICOM']);
    fprintf('T1w Image is %s\n', T1dicompath);
    T1dicom = dir(T1dicompath);
    
    T2dicompath = ([datapath, '\', datafiles(i).name, '\', subjectfiles(end).name, '\', 'DICOM']);
    fprintf('T2w Image is %s\n\n', T2dicompath);
    T2dicom = dir(T2dicompath);
    
    Nifti = ([datapath, '\', datafiles(i).name]);
    files = dir(Nifti);
 
    %% DICOM CONVERTION
    
%     % Covert DICOM to NIFTI for T1
%     T1dicomfiles = cell(length(T1dicom)-2, 1);
%     
%     for j = 3:length(T1dicom)
%         T1dicomfiles{j-2} = [T1dicompath, '\', T1dicom(j).name];
%     end
%             
%     matlabbatch{1}.spm.util.import.dicom.data = T1dicomfiles;
%     matlabbatch{1}.spm.util.import.dicom.root = 'flat';
%     matlabbatch{1}.spm.util.import.dicom.outdir = {Nifti};
%     matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
%     matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
%     matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
%     spm_jobman('run', matlabbatch);
%     clear matlabbatch
%     
%     % Covert DICOM to NIFTI for T2
%     T2dicomfiles = cell(length(T2dicom)-2, 1);
%     
%     for k = 3:length(T2dicom)
%         T2dicomfiles{k-2} = [T2dicompath, '\', T2dicom(k).name];
%     end
%           
%     matlabbatch{1}.spm.util.import.dicom.data = T2dicomfiles;
%     matlabbatch{1}.spm.util.import.dicom.root = 'flat';
%     matlabbatch{1}.spm.util.import.dicom.outdir = {Nifti};
%     matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
%     matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
%     matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
%     spm_jobman('run', matlabbatch);
%     clear matlabbatch
    
% %% Co-Registration
%     
%     matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[Nifti, '\', files(end-4).name]};
%     fprintf('Reference Image is %s\n\n', [Nifti, '\', files(end-4).name]);
%     matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[Nifti, '\', files(end-2).name]};
%     fprintf('Image to register to reference is %s\n\n', [Nifti, '\', files(end-2).name]);
%     matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
%     matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'mi';
%     matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
%     matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
%     matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
%     matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 7;
%     matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
%     matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
%     matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
%     spm_jobman('run', matlabbatch);
%     clear matlabbatch
    
% %% Segmentation

%     fprintf('Segmentation going on for %s subject\n\n',datafiles(i).name);
%     
%     matlabbatch{1}.spm.spatial.preproc.channel(1).vols = {[Nifti, '\', files(end-4).name]};
%     fprintf('T1w Image is %s\n\n', [Nifti, '\', files(end-4).name]);
%     matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0.001;
%     matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 60;
%     matlabbatch{1}.spm.spatial.preproc.channel(1).write = [0 1];
% 
%     matlabbatch{1}.spm.spatial.preproc.channel(2).vols = {[Nifti, '\', files(end-5).name]};
%     fprintf('T2w Image is %s\n\n', [Nifti, '\', files(end-5).name]);
%     matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0.001;
%     matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 60;
%     matlabbatch{1}.spm.spatial.preproc.channel(2).write = [0 1];
%     
%     matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm('dir') '/tpm/TPM.nii']};
%     matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
%     matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
%     matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
%     
%     matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm('dir') '/tpm/TPM.nii']};
%     matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
%     matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
%     matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
%     
%     matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm('dir') '/tpm/TPM.nii']};
%     matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
%     matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
%     matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
%     
%     matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm('dir') '/tpm/TPM.nii']};
%     matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
%     matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
%     matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
%     
%     matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm('dir') '/tpm/TPM.nii']};
%     matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
%     matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
%     matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
%     
%     matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm('dir') '/tpm/TPM.nii']};
%     matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
%     matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
%     matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
%     
%     matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
%     matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 2;
%     matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
%     matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
%     matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
%     matlabbatch{1}.spm.spatial.preproc.warp.samp = 2;
%     matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
%     
%     spm_jobman('run', matlabbatch);
%     clear matlabbatch
     
% %% Normalization (Estimate and Write)
    
%     fprintf('Normalization going on for %s subject\n\n',datafiles(i).name);
%     
%     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {[Nifti, '\m', files(end-5).name]};
%     fprintf('T1w Image is %s\n\n', [Nifti, '\m', files(end-5).name]);
%     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[Nifti, '\c1', files(end-5).name]
%                                                                       [Nifti, '\c2', files(end-5).name]
%                                                                       [Nifti, '\', files(end-9).name]};
%     fprintf('T1byT2 map is %s\n\n', [Nifti, '\', files(end-9).name]);                                                              
%     matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
%     matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
%     matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {[spm('dir') '/tpm/TPM.nii']};
%     matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
%     matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
%     matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
%     matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 2;
%     matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -90; 78 76 85];
%     matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [1.5 1.5 1.5];
%     matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
%     
%     spm_jobman('run', matlabbatch);
%     clear matlabbatch
    
% %% Smoothing
%     
    fprintf('Smoothing going on for %s subject\n\n',datafiles(i).name);
    
    matlabbatch{1}.spm.spatial.smooth.data = {[Nifti, '\w', files(end-13).name]};
    fprintf('Smoothing map is %s\n\n', [Nifti, '\', files(end-13).name]);
    matlabbatch{1}.spm.spatial.smooth.fwhm = [10 10 10];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                 
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end