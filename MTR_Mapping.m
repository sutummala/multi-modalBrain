function MTR_Mapping


folderpath = 'E:\Analysis-Sudhakar\OSAMT\TimTrio\OSA';

files = dir(folderpath);

for d = 3:length(files)
    
    fprintf('Computing for %d/%d\n\n', d-2, length(files)-2);
    
    datapath = [folderpath, '\', files(d).name];
    
    datafiles = dir(datapath);
    
    for e = 3:length(datafiles)
        
        if strfind(datafiles(e).name, 'm2') & strfind(datafiles(e).name, 'MTOFF');
            fprintf('Reading MToff Image %s from subject %s\n\n', datafiles(e).name, files(d).name);  
            V1 = spm_vol([datapath, '\', datafiles(e).name]);
            MToff = spm_read_vols(V1);
        elseif strfind(datafiles(e).name, 'm2') & strfind(datafiles(e).name, 'MTON');
            fprintf('Reading MTon Image %s from subject %s\n\n', datafiles(e).name, files(d).name);  
            V2 = spm_vol([datapath, '\', datafiles(e).name]);
            MTon = spm_read_vols(V2);
        end
    end
    


[x, y, z] =  size(MTon);
MTR = 0 * MTon;

for i = 1:x
    for j = 1:y
        for k = 1:z
            if MToff(i, j, k) < 100 | MTon(i, j, k) < 100 | MToff(i, j, k) == 0 | MTon(i, j, k) == 0
                continue
            else
                MTR(i, j, k) = (1-(MTon(i, j, k)./MToff(i, j, k))) * 100;
            end
            if MTR(i, j, k) < 0 
                MTR(i, j, k) = 0;
            end
        end
    end
end

fprintf('Calculated MTR map for %s\n\n', files(d).name);
% mtr =reshape(MTR, x, y, 1, z);
% figure, montage(mtr/100);
% MTRvec = MTR(:);
% figure, hist(MTRvec(MTRvec > 5));

Vi = spm_vol(V1);
filename = [datapath, '\', ['m', files(d).name, '-MTR', '.nii']];

Vo = struct(	'fname',	filename,...
		'dim',		Vi(1).dim(1:3),...
        'dt',        [spm_type('float32'), 0],... % 0 for littleend and 1 for bigend% 
		'mat',		Vi(1).mat,...
		'pinfo',	[1.0,0,0]',...
		'descrip',	'spm - MTonmap image');
    
Vo = spm_create_vol(Vo);
Vo = spm_write_vol(Vo, MTR);

fprintf('MTR map for %s saved\n\n', files(d).name);
fprintf('===================================================================================================\n\n\n');
end
                


