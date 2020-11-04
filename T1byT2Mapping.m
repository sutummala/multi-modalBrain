function T1byT2Mapping


folderpath = 'E:\Analysis-Sudhakar\T1byT2Mapping\TimTrio\2006Whole';

files = dir(folderpath);

for d = 3:length(files)
    
    fprintf('Computing for %d/%d\n\n', d-2, length(files)-2);
    
    datapath = [folderpath, '\', files(d).name];
    
    datafiles = dir(datapath);
    
    for e = 3:length(datafiles)
        
        if strfind(datafiles(e).name, 'ms') & strfind(datafiles(e).name, '176');
            fprintf('Reading T1 Image %s from subject %s\n\n', datafiles(e).name, files(d).name);  
            V1 = spm_vol([datapath, '\', datafiles(e).name]);
            T1 = spm_read_vols(V1);
        elseif strfind(datafiles(e).name, 'mrs') & strfind(datafiles(e).name, '01');
            fprintf('Reading T2 Image %s from subject %s\n\n', datafiles(e).name, files(d).name);  
            V2 = spm_vol([datapath, '\', datafiles(e).name]);
            T2 = spm_read_vols(V2);
        end
    end

[x, y, z] =  size(T1);
T1byT2 = 0 * T1;

for i = 1:x
    for j = 1:y
        for k = 1:z
            if T1(i, j, k) < 20 | T2(i, j, k) < 20 | T1(i, j, k) == 0 | T2(i, j, k) == 0
                continue
            else
                T1byT2(i, j, k) = T1(i, j, k)./T2(i, j, k);
            end
            if T1byT2(i, j, k) < 0 
                T1byT2(i, j, k) = 0;
            end
        end
    end
end

fprintf('Calculated T1byT2 map for %s\n\n', files(d).name);

% t1byt2 = reshape(T1byT2, x, y, 1, z);
% figure, montage(t1byt2/100);
% T1byT2vec = T1byT2(:);
% figure, hist(T1byT2vec(T1byT2vec > 0.1));

Vi = spm_vol(V1);
filename = [datapath, '\', ['m', files(d).name, 'T1byT2', '.nii']];

Vo = struct(	'fname',	filename,...
		'dim',		Vi(1).dim(1:3),...
        'dt',        [spm_type('float32'), 0],... % 0 for littleend and 1 for bigend 
		'mat',		Vi(1).mat,...
		'pinfo',	[1.0,0,0]',...
		'descrip',	'T1byT2map');
    
Vo = spm_create_vol(Vo);
Vo = spm_write_vol(Vo, T1byT2);

fprintf('T1byT2 map for %s saved\n\n', files(d).name);
fprintf('===================================================================================================\n\n\n');
end
                

