function scalingFactor

% Created by Tummala on Aug 2015

% This function calculates the scaling factors for across subjects
% comparision. it takes ratio of ths specific tissue volume to the
% intracarnial volume (graymatter + whitematter + csf)

% Calculate global volume for tissue of interest

addpath 'C:\Matlab\spm12';

datapath = 'E:\Analysis-Sudhakar\Matlab\dataOSA\putamen'; % tissue of interest

datapath1 = 'E:\Analysis-Sudhakar\DATA\OSA2006T1'; % whole brain 

subs = dir(datapath);
subs1 = dir(datapath1);
category = struct([]); sFactor = [];

for i = 3:length(subs)
    
    subid = subs(i).name(5:7);
        
    if strfind(subs(i).name, 'Left')
        fprintf('Computing scaling factor for subject %d/%d\n\n', i-2, length(subs)-2);      
        load([datapath, '\', subs(i).name]);
        vol = length(find(Puta(:))) * prod(voxelSize);
    
    for j = 3:length(subs1)
        
        sub = strfind(subs1(j).name(1:10), subid);
        if find(sub)
            grayMa = strfind(subs1(j).name, 'c1');
            whiteMa = strfind(subs1(j).name, 'c2');
            csf = strfind(subs1(j).name, 'c3');
            
            if grayMa % Gray Matter
                grayM = spm_read_vols(spm_vol([datapath1, '\', subs1(j).name])); 
                grayM = length(find(grayM(:) > 0.5)) * prod(voxelSize);
            elseif whiteMa % White Matter
                whiteM = spm_read_vols(spm_vol([datapath1, '\', subs1(j).name])); 
                whiteM = length(find(whiteM(:) > 0.5)) * prod(voxelSize);
            elseif csf % CSF
                Csf = spm_read_vols(spm_vol([datapath1, '\', subs1(j).name])); 
                Csf = length(find(Csf(:) > 0.5)) * prod(voxelSize);
            end
        else
            continue
        end
        
        if strfind(subs1(j).name, 'OSA') & find(sub)
            category{floor(i/2), 1} = 'OSA';
        else
            category{floor(i/2), 1} = 'Healthy';
        end
    end
    else
        continue
    end
   
    ICV = grayM + whiteM + Csf; % Intracarnial Volume 
    sFactor(end + 1) = vol/ICV; % scaling factor for correction
end
xlswrite('scaleFactors.xlsx', sFactor');
    