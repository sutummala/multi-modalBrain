function preProcessing

% Created on April 2015 by Tummala (compatible for SPM12)

datapath = 'E:\Analysis-Sudhakar\T2starMapping\Data'; % Keep Control and OSA in one folder w.r.t subject ID (For example, CON5001, OSA5013, etc...)
datafiles = dir(datapath);

addpath 'C:\Matlab\spm12';
spm('defaults', 'fmri');
spm_jobman('initcfg');
TE = [5, 12, 20, 30]; % Echo Times
Echomap = struct([]);

for i = 3:length(datafiles)
    
    subjectfiles = dir([datapath, '/', datafiles(i).name]);
    
%     flip2path = ([datapath, '\', datafiles(i).name, '\', subjectfiles(end-3).name, '\', 'Nifti']);
%     flip2file = dir(flip2path); % Flip2 image was used for segmentation
%     fprintf('Flip2 Image is %s\n', [flip2path, '\', flip2file(end).name]);
    
    T2mapPath = ([datapath, '\', datafiles(i).name, '\', subjectfiles(end-1).name, '\', 'Nifti']);
    T2mapfile = dir(T2mapPath); % T1 map      
   
        for j = 3:2:length(T2mapfile)
            echo = str2double(T2mapfile(j).name(end-4));
            switch echo
                case 1
                 Vi = spm_vol([T2mapPath, '\', T2mapfile(j).name]);
                 Echomap(1).TE = spm_read_vols(Vi);
                 fprintf('TE1 image is %s\n', T2mapfile(j).name);
                case 2
                 Echomap(2).TE = spm_read_vols(spm_vol([T2mapPath, '\', T2mapfile(j).name]));
                 fprintf('TE2 image is %s\n', T2mapfile(j).name);
                case 3
                 Echomap(3).TE = spm_read_vols(spm_vol([T2mapPath, '\', T2mapfile(j).name]));
                 fprintf('TE3 image is %s\n', T2mapfile(j).name);
                case 4
                 Echomap(4).TE = spm_read_vols(spm_vol([T2mapPath, '\', T2mapfile(j).name]));
                 matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {[T2mapPath, '\', T2mapfile(j).name]};
                 fprintf('TE4 image is %s\n', T2mapfile(j).name);
            end
        end
        R2star = zeros(size(Echomap(1).TE)); nume = R2star; denom = 0;
    for m = 2:length(TE)
        nume = nume + (log(Echomap(m).TE./Echomap(1).TE) * (TE(m)-TE(1)));      
        denom = denom + (TE(m)-TE(1))^2;
    end
    
    R2star = -nume/denom;
    
    savepath = [datapath, '\', datafiles(i).name];
    filename = [savepath, '\', ['m', datafiles(i).name, 'T2starMap', '.nii']];

% Write texture map as a nii file
Vo = struct(	'fname',	filename, 'dim', Vi(1).dim(1:3),'dt', [spm_type('float32'), 0],'mat', Vi(1).mat,'pinfo', [1.0,0,0]', 'descrip',	'textureMap');
Vo = spm_create_vol(Vo);
spm_write_vol(Vo, R2star*1000);
fprintf('t2starmap %s saved\n', filename);

    
% Normalization (Estimate and Write)    

matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {filename};
fprintf('Image to Write is %s\n', filename);
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'C:\Matlab\spm12\tpm\TPM.nii'};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 2;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -90
                                                             78 76 85];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [1.5 1.5 1.5];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 7;
spm_jobman('run', matlabbatch);
clear matlabbatch

end