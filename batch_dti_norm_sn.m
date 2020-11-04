


% control case
mpath='E:\Analysis-Sudhakar\DTI-CHD\CHD and DTI\Data\Control\';
subjects={'CON101','CON102','CON104','CON106','CON109','CON111' ...
         ,'CON113','CON114','CON115','CON116','CON117','CON118' ...
         ,'CON120','CON123','CON124','CON125','CON126','CON127'};

% CHD case
mpath1='E:\Analysis-Sudhakar\DTI-CHD\CHD and DTI\Data\CHD\';
subjects1={'CHD103','CHD105','CHD107','CHD108','CHD110','CHD112','CHD119', ...
           'CHD121','CHD122'};      
      
for ss=1:length(subjects),
    tic;
    subj=subjects{ss};
    disp([subj ' is running...']);
    spm('defaults','FMRI');
    spm_jobman('initcfg');
    clear matlabbatch;

    name=subj(4:6);
    %a1=[mpath '\B0\meandti_b0 ' name '.nii'];
    a2=[mpath subj '\AD\meandti_' name '_s4_e1.nii'];
    a3=[mpath subj '\MD\meandti_' name '_s4_e1.nii'];
    a4=[mpath subj '\RD\meandti_' name '_s4_e2.nii'];
%     a5=[mpath '\B0\c1meandti_b0 ' name '.nii'];
%     a6=[mpath '\B0\c2meandti_b0 ' name '.nii'];
    
    
    img=cellstr(strvcat(a2,a3,a4));

    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {[mpath subj '\B0\meandti_' name '_s4_b0.nii'];};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = img;                                                          
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
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    toc;
end

clear ss;


for ss=1:length(subjects1),
    tic;
    subj=subjects1{ss};
    disp([subj ' is running...']);
    spm('defaults','FMRI');
    spm_jobman('initcfg');
    clear matlabbatch;

    name=subj(4:6);
    %a1=[mpath '\B0\meandti_b0 ' name '.nii'];
    a2=[mpath1 subj '\AD\meandti_' name '_s4_e1.nii'];
    a3=[mpath1 subj '\MD\meandti_' name '_s4_e1.nii'];
    a4=[mpath1 subj '\RD\meandti_' name '_s4_e2.nii'];
%     a5=[mpath '\B0\c1meandti_b0 ' name '.nii'];
%     a6=[mpath '\B0\c2meandti_b0 ' name '.nii'];
    
    
    img=cellstr(strvcat(a2,a3,a4));

    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {[mpath1 subj '\B0\meandti_' name '_s4_b0.nii'];};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = img;                                                          
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
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    toc;
end




