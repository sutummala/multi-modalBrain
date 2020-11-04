function RegionalCBF

datapath = 'E:\Analysis-Sudhakar\OSA CBF-BBB Data\CBFmaps\OSA';
graydata = 'E:\Analysis-Sudhakar\OSA CBF-BBB Data\graymatter';
whitedata = 'E:\Analysis-Sudhakar\OSA CBF-BBB Data\whitematter';

files = dir(datapath);
grayfiles = dir(graydata);
whitefiles = dir(whitedata);

for i = 3:length(files);
    
    file = files(i).name
    V1 = spm_vol([datapath, '\', file]);
    T1 = spm_read_vols(V1); 
    
    computeCBF(T1, file, grayfiles, graydata, 'graymatter');
    computeCBF(T1, file, whitefiles, whitedata, 'whitematter');
    fprintf('Subject %s calculated===================\n\n', file(10:13));
end

function computeCBF(T1, file, folder, bindata, tag)

for f = 3:20
    
    if strfind(folder(f).name, file(10:13))
        binfile = folder(f).name 
        V2 = spm_vol([bindata, '\', binfile]); 
        T2 = spm_read_vols(V2); 
    
        n = numel(T2(T2 > 0)); 
    
        value = sum(T1(:).*T2(:))/n;
    
        fprintf('The CBF value for subject %s %s is %0.4f\n\n', file(10:13), tag, value);
    end
end
