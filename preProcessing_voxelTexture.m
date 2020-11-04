function preProcessing

tic
addpath 'C:\Matlab\spm12';

spm('defaults', 'fmri');
spm_jobman('initcfg');

datapath = 'E:\Analysis-Sudhakar\T1byT2Mapping\TimTrio\2006WholeOSA';
images = dir(datapath);


for i = 3:length(images)
   
   % Normalization Write
   subjectfiles = dir([datapath, '/', images(i).name]);
   fprintf('Processing on subject %d/%d\n\n', i-2, length(images)-2);
   
   for k1 = 1:length(subjectfiles)
           
         if strfind(subjectfiles(k1).name, 'y_') % Find indices for the TrackDensity file in subjectfiles
             break
         end
   end
       
   for k2 = 1:length(subjectfiles)
           
       if strfind(subjectfiles(k2).name, 'TextureMap') % Find indices for the TrackDensity file in subjectfiles
          break
       end
   end
       
       
   matlabbatch{1}.spm.spatial.normalise.write.subj.def = {[datapath, '\', images(i).name, '\', subjectfiles(k1).name]};
   matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {[datapath, '\', images(i).name, '\', subjectfiles(k2).name]};
   matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -90
                                                          78 76 85];
   matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1.5 1.5 1.5];
   matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 7;
    
   spm_jobman('run', matlabbatch);
   clear matlabbatch
    
   % Smoothing 
   matlabbatch{1}.spm.spatial.smooth.data = {[datapath, '\', images(i).name, '\w', subjectfiles(k2).name]};
   matlabbatch{1}.spm.spatial.smooth.fwhm = [10 10 10];
   matlabbatch{1}.spm.spatial.smooth.dtype = 0;
   matlabbatch{1}.spm.spatial.smooth.im = 0;
   matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                 
   spm_jobman('run', matlabbatch);
   clear matlabbatch

end