% control case
% mpath='E:\DTI-CHD\Data\Control\';
% subjects={'CON101','CON102','CON104','CON106','CON109','CON111' ...
%           ,'CON113','CON114'};

% CHD case
addpath C:\Matlab\spm8
mpath='E:\Analysis-Sudhakar\DTI-CHD\Data\CHD\';
subjects={'CHD103','CHD105','CHD107','CHD108','CHD110','CHD112'};      
      
for ss=1:length(subjects),
    tic;
    subj=subjects{ss};
    disp([subj ' is running...']);
    spm('defaults','FMRI');
    spm_jobman('initcfg');
    clear matlabbatch;
    
    dum=subj(4:6);
    a1=[mpath subj '\AD\dti_' dum '_s4_e1.nii'];
    a2=[mpath subj '\AD\dti_' dum '_s5_e1.nii'];
    
    b1=[mpath subj '\B0\dti_' dum '_s4_b0.nii'];
    b2=[mpath subj '\B0\dti_' dum '_s5_b0.nii'];
    
    m1=[mpath subj '\MD\dti_' dum '_s4_e1.nii'];
    m2=[mpath subj '\MD\dti_' dum '_s5_e1.nii'];
    m3=[mpath subj '\MD\dti_' dum '_s4_e2.nii'];
    m4=[mpath subj '\MD\dti_' dum '_s5_e2.nii'];
    m5=[mpath subj '\MD\dti_' dum '_s4_e3.nii'];
    m6=[mpath subj '\MD\dti_' dum '_s5_e3.nii'];
    
    r1=[mpath subj '\RD\dti_' dum '_s4_e2.nii'];
    r2=[mpath subj '\RD\dti_' dum '_s5_e2.nii'];
    r3=[mpath subj '\RD\dti_' dum '_s4_e3.nii'];
    r4=[mpath subj '\RD\dti_' dum '_s5_e3.nii'];
    
    ad=cellstr(strvcat(a1,a2));
    b0=cellstr(strvcat(b1,b2));
    
    k1=strvcat(m1,m2);
    k2=strvcat(m3,m4);
    k3=strvcat(m5,m6);
    kk1=strvcat(k1,k2);
    md=cellstr(strvcat(kk1,k3));
    
    u1=strvcat(r1,r2);
    u2=strvcat(r3,r4);
    rd=cellstr(strvcat(u1,u2));
    
    for jj=1:4,
        if jj==1;img=ad;end
        if jj==2;img=b0;end
        if jj==3;img=md;end
        if jj==4;img=rd;end
        
        matlabbatch{1}.spm.spatial.realign.estwrite.data = {img};
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 2;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 3;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 7;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 7;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
        
        spm_jobman('run',matlabbatch);
    end
    toc;
end
