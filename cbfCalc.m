function [] = perf_resconstruct(Filename, FieldStrength, ASLType, SubtractionType, SubtractionOrder, Threshold, T1B);

% close all;
spm('ver',[],1);

try Filename;
   ;
catch
  if strcmp(spm('ver',[],1),'SPM8')
     Filename=spm_select(Inf,'any','Select source imgs', [],pwd,'.*img');
  else
    Filename = spm_get(Inf,'*.img','Select source imgs');
  end;
  
if isempty(Filename), fprintf('No images selected!\n');return;end;
paranum = 1;
pos=1;
end;

% CASLmask = spm_select(1,'image','Select mask image'); 

FieldStrength = spm_input('Scanner Strength: 1:3T; 2:1.5T', '+1', 'e', 1);
 paranum = paranum + 1;
 
ASLType = spm_input('ASLType: 2:pCASL; 1:CASL; 0:PASL', '+1', 'e', 2);
  paranum = paranum + 1;

 if ASLType == 0;
  if strcmp(spm('ver',[],1),'SPM8')
    PASLMo =spm_select(1,'any','Select Mo imgs', [],pwd,'.*img');
  else
     PASLMo = spm_get(1,'*.img','Select PASL Mo image'); 
     paranum = paranum + 1;
   end;
  if isempty(PASLMo) fprintf('No PASL Mo images selected!\n');return;end;
 end;

 %FirstimageType = spm_input('Select 1st Image type? 0:control; 1:labeled', '+1', 'e', 1);
 %paranum = paranum + 1;
  FirstimageType=1;

SubtractionOrder = spm_input('Select SubtractionOrder', '+1', 'm',  ['*Even-Odd(Img2-Img1)|Odd-Even(Img1-Img2)'], [0 1], 0);
   paranum = paranum + 1;
%SubtractionOrder=1;

SubtractionType = spm_input('Selct SubtractionType', '+1', 'm',  ['*Simple |Surround|Sinc'], [0 1 2], 0);
 paranum = paranum + 1;
%  SubtractionType=0;

if SubtractionType==2, 			
  Timeshift = spm_input('Time shift of sinc interpolation', '+1', 'e', 0.5);
  paranum = paranum + 1;
end;

 %CBFFlag = spm_input('Produce quanperf_resconstructtified CBF images? 0:no; 1:yes', '+1', 'e', 1);
 %paranum = paranum + 1;
  CBFFlag=1;


 %ThreshFlag = spm_input('Threshold EPI images? 0:no; 1:yes', '+1', 'e', 1);
 %paranum = paranum + 1;
  ThreshFlag=1;

if ThreshFlag==1,
  threshold =  spm_input('Input EPI Threshold value', '+1', 'e', 0.8);
  paranum = paranum + 1;
end;
% absthreshold=200;

 %MeanFlag = spm_input('Produce mean images? 0:no; 1:yes', '+1', 'e', 1);
 %paranum = paranum + 1;
  MeanFlag=1;
  
if CBFFlag==1,
  if ASLType ==2 %pCASL
   Labeltime = spm_input('Enter Label time:sec', '+1', 'e', 1.5);
   Delaytime = spm_input('Enter Delay time:sec', '+1', 'e', 1.2);
   Slicetime = spm_input('Enter Slice acquisition time:msec', '+1', 'e', 38);
   alp = 0.85;   %pCasl tagging efficiency
   if FieldStrength == 1, R = 0.606; else R = 0.83; end;  %longitudinal relaxation rate of blood
    paranum = paranum + 5;
  elseif   ASLType ==1 %CASL
   Labeltime = spm_input('Enter Label time:sec', '+1', 'e', 1.6);
   Delaytime = spm_input('Enter Delay time:sec', '+1', 'e', 1.2);
   Slicetime = spm_input('Enter slice acquisition time:msec', '+1', 'e', 40);
   if FieldStrength == 1, alp = 0.68; else alp = 0.71; end;   %Casl tagging efficiency
   if FieldStrength == 1, R = 0.606; else R = 0.83; end;  %longitudinal relaxation rate of blood
    paranum = paranum + 5;
  else  %PASL
    Labeltime = spm_input('Enter Post IR Delay time:sec', '+1', 'e', 0.7); % TI1
    Delaytime = spm_input('Enter Post Inf Sat Delay time:sec', '+1', 'e', 1.2);
    Slicetime = spm_input('Enter slice acquisition time:msec', '+1', 'e', 42);
    alp = 0.95;   %PASL tagging efficiency
    if FieldStrength == 1, R = 0.606; else R = 0.83; end;  %longitudinal relaxation rate of blood
    paranum = paranum + 5;
   end;
 end;
 
 T1b = spm_input('Enter blood T1 : msec', '+1', 'e', 1650);  %you can input the updated blood T1
   R = 1000/T1b;

 if ASLType ==2 %pCASL
  alp =  spm_input('Enter label efficiency', '+1', 'e', 0.85);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the main program
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Perf Reconstruct',0);
spm('FigName','Perf Reconstruct: working',Finter,CmdLine);
spm('Pointer','Watch')


% Map images
V=spm_vol(deblank(Filename));

if ASLType==0, 
  VMo = spm_vol(deblank(PASLMo)); 
  PASLModat = zeros([VMo.dim(1:2) 1]);
end;
 
 if length(V)==0, fprintf('no raw img files was selected'); return; end;
 if rem(length(V),2)==1, warning('the number of raw img files is not even, last img is ignored'); end;
 perfnum=fix(length(V)/2);
 
% Create output images...
VO = V(1:perfnum);
VB = V(1:perfnum);
VCBF=V(1:perfnum);
VMP = V(1);
VMCBF = V(1);
VMC = V(1);

  for k=1:length(V),
        [pth,nm,xt] = fileparts(deblank(V(k).fname));
        if SubtractionType==0, 
         VO(k).fname = fullfile(pth,['Perf_0' nm xt]);
         if CBFFlag==1, VCBF(k).fname = fullfile(pth,['CBF_0_' nm xt]);end;
        end;
        if SubtractionType==1, 
         VO(k).fname = fullfile(pth,['Perf_1' nm xt]);
         if CBFFlag==1, VCBF(k).fname = fullfile(pth,['CBF_1_' nm xt]);end;
        end;
        if SubtractionType==2, 
         VO(k).fname = fullfile(pth,['Perf_2' nm xt]);
         if CBFFlag==1, VCBF(k).fname = fullfile(pth,['CBF_2_' nm xt]);end;
        end;
        VB(k).fname    = fullfile(pth,['Bold_' nm xt]);
  end;

  for k=1:perfnum,
           VO(k)  = spm_create_vol(VO(k));
           VB(k)  = spm_create_vol(VB(k));
           VCBF(k)  = spm_create_vol(VCBF(k));
          if strcmp(spm('ver',[],1),'SPM8')   
            VO(k).dt=[16,0]; VB(k).dt=[16,0]; VCBF(k).dt =[16,0];  %'float' type
         else
           VO(k).dim(4) = 16; VB(k).dim(4) = 16; VCBF(k).dim(4) = 16; %'float' type
          end;
  end;
  
cdat = zeros([VO(1).dim(1:3) perfnum]);
ldat = zeros([VO(1).dim(1:3) perfnum]);
pdat = zeros([VO(1).dim(1:3) perfnum]);
bdat = zeros([VB(1).dim(1:3) perfnum]);

linear_cdat=zeros([VB(1).dim(1:3) 2*perfnum]);
linear_ldat=zeros([VB(1).dim(1:3) 2*perfnum]);
sinc_ldat=zeros([VB(1).dim(1:3) 2*perfnum]);
sinc_cdat=zeros([VB(1).dim(1:3) 2*perfnum]);


%-Start progress plot
%-----------------------------------------------------------------------
spm_progress_bar('Init',perfnum,'Perf Reconstruct','Images completed');

% read raw data
dat = spm_read_vols(V);
threshvalue = zeros(1,length(V));

% threshold the EPI images 
  Mask=ones(V(1).dim(1:3));
  
% read the Mo data for PASL
  if ASLType==0;
    PASLModat = spm_read_vols(VMo); 
    Mask = Mask.*(PASLModat>threshold*mean(mean(mean(PASLModat))));
  end;
  
  if ThreshFlag ==1,
   for k=1:length(V),
     Mask = Mask.*(dat(:,:,:,k)>threshold*mean(mean(mean(dat(:,:,:,k)))));
     threshvalue(1, k) = max(100, threshold*mean(mean(mean(dat(:,:,:,k)))));
%     Mask = Mask.*(dat(:,:,:,k)>absthreshold);
   end;
  end;


 for k=1:length(V),
%    datamk= spm_read_vols(V(k));
%   datamk = datamk.*Mask;
    dat(:,:,:,k) = dat(:,:,:,k).*Mask; 
 end;

% define the control and label images...
 for k=1:length(V),
  if SubtractionOrder==0, 
      if rem(k,2)== 1, ldat(:,:,:,(k+1)/2) = dat(:,:,:,k); end;
      if rem(k,2)== 0, cdat(:,:,:,k/2) = dat(:,:,:,k); end;
  end;
  if SubtractionOrder==1, 
      if rem(k,2)== 1, cdat(:,:,:,(k+1)/2) = dat(:,:,:,k); end;
      if rem(k,2)== 0, ldat(:,:,:,k/2) = dat(:,:,:,k); end;
  end;
 end;
 
 
 % obtained BOLD data
 for k=1:perfnum,
  bdat(:,:,:,k) = (dat(:,:,:,2*k-1) + dat(:,:,:,2*k))/2;
 end;
 
 % do the simple subtraction...
if SubtractionType==0,
  for k=1:perfnum,
    pdat(:,:,:,k) = cdat(:,:,:,k) - ldat(:,:,:,k);
  end;
 spm_progress_bar('Set',k);
end;
 
  % do the linear interpolation...
  if SubtractionType==1,
     pnum=1:perfnum;
     lnum=1:0.5:perfnum;
     for x=1:V(1).dim(1),
      for y=1:V(1).dim(2),
       for z=1:V(1).dim(3),
        cdata = zeros(1,perfnum);
        ldata = zeros(1,perfnum);
        linear_cdata = zeros(1,length(V));
        linear_ldata = zeros(1,length(V));
         for k=1:perfnum, 
          cdata(k) = cdat(x,y,z,k);
          ldata(k) = ldat(x,y,z,k);
         end;
         linear_cdata=interp1(pnum,cdata,lnum);
         linear_ldata=interp1(pnum,ldata,lnum);
         for k=1:2*perfnum-1, 
          linear_cdat(x,y,z,k)= linear_cdata(k);
          linear_ldat(x,y,z,k)= linear_ldata(k);
         end;
        end; 
       end; 
      end; 

   
     % do the surround subtraction....
     if FirstimageType ==1; 
          pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
          spm_progress_bar('Set',1);
        for k=2:perfnum, 
          pdat(:,:,:,k) = linear_cdat(:,:,:,2*(k-1)) - ldat(:,:,:,k);
          spm_progress_bar('Set',k);
        end;
     end;
     if FirstimageType ==0; 
          pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
          spm_progress_bar('Set',1);
       for k=2:perfnum, 
          pdat(:,:,:,k) = cdat(:,:,:,k) - linear_ldat(:,:,:,2*(k-1));
          spm_progress_bar('Set',k);
        end;
     end;
end;


 % do the sinc interpolation...
  if SubtractionType==2,
     for x=1:V(1).dim(1),
       for y=1:V(1).dim(2),
         for z=1:V(1).dim(3),
           cdata = zeros(1,perfnum);
           ldata = zeros(1,perfnum);
           sinc_cdata = zeros(1,length(V));
           sinc_ldata = zeros(1,length(V));
           for k=1:perfnum, 
             cdata(k) = cdat(x,y,z,k);
             ldata(k) = ldat(x,y,z,k);
           end;
           sincnum = fix(perfnum/Timeshift);
           sinc_cdata=interpft(cdata,sincnum);
           sinc_ldata=interpft(ldata,sincnum);
           for k=1:2*perfnum, 
            sinc_cdat(x,y,z,k)= sinc_cdata(k);
            sinc_ldat(x,y,z,k)= sinc_ldata(k);
           end;
         end;  
       end;
     end;
 
      % do the sinc subtraction....
         if FirstimageType ==1; 
          pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
             for k=2:perfnum, 
               pdat(:,:,:,k) = sinc_cdat(:,:,:,2*(k-1)) - ldat(:,:,:,k);
               spm_progress_bar('Set',k);
             end;
          end;
         if FirstimageType ==0; 
           pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
             for k=2:perfnum, 
               pdat(:,:,:,k) = cdat(:,:,:,k) - sinc_ldat(:,:,:,2*(k-1));
               spm_progress_bar('Set',k);
           end;
         end;
  end;      
       

 % Write Bold and perfusion image...
   for k=1:perfnum,
      VO(k) = spm_write_vol(VO(k),pdat(:,:,:,k));
      VB(k) = spm_write_vol(VB(k),bdat(:,:,:,k));
   end;


 % calculated the mean image...
  if MeanFlag ==1,
    Mean_dat=zeros([V(1).dim(1:3)]);
    VMP.fname = fullfile(pth,['Mean_Perf' nm(1:5) xt]);
    VMP = spm_create_vol(VMP);
    if strcmp(spm('ver',[],1),'SPM8')   
       VMP.dt=[16,0];   %'float' type
      else
      VMP.dim(4) = 16; %'float' type
    end;
    
    for x=1:V(1).dim(1),
       for y=1:V(1).dim(2),
         for z=1:V(1).dim(3),
          Mean_dat(x,y,z) = mean(pdat(x,y,z,:));
         end;
       end;
    end;
    
    % Write mean perfusion image...
        VMP = spm_write_vol(VMP,Mean_dat);
  end;


  % calculated the CBF image...
  if CBFFlag ==1,
     
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   spm_progress_bar('Clear')

  [Finter,Fgraph,CmdLine] = spm('FnUIsetup','Perf Reconstruct',0);
  spm('FigName','CBF Reconstruct: working',Finter,CmdLine);
  spm('Pointer','Watch')
  %-----------------------------------------------------------------------
  spm_progress_bar('Init',perfnum,'CBF Reconstruct','Images completed');

     cbfdat = zeros([VO(1).dim(1:3), perfnum]);
     cmean_dat = zeros([VO(1).dim(1:3)]);

     for x=1:V(1).dim(1),
       for y=1:V(1).dim(2),
         for z=1:V(1).dim(3),
          cmean_dat(x,y,z) = mean(cdat(x,y,z,:));
         end;
       end;
     end;
   
     % Write mean BOLD/Control image...
   if MeanFlag ==1,
     VMC.fname = fullfile(pth,['Mean_BOLD' nm(1:5) xt]);
     VMC = spm_create_vol(VMC);
     if strcmp(spm('ver',[],1),'SPM8')   
            VMC.dt=[16,0];   %'float' type
      else
        VMC.dim(4) = 16; %'float' type
       end;
       
     VMC = spm_write_vol(VMC,cmean_dat);
   end;
   
     for k=1:perfnum, 
       for x=1:V(1).dim(1),
       for y=1:V(1).dim(2),
       for z=1:V(1).dim(3),
        Dtime = Delaytime + Slicetime*z/1000;

        if ASLType ==2   % pCASL
         if cmean_dat(x,y,z)<mean(threshvalue)
          cbfdat(x,y,z,k)=0;
         else
          cbfdat(x,y,z,k) = 2700*pdat(x,y,z,k)*R/alp/((exp(-Dtime*R)-exp(-(Dtime+Labeltime)*R))*cmean_dat(x,y,z));
         end;
        end;

        if ASLType ==1   % CASL
         if cmean_dat(x,y,z)<mean(threshvalue)
          cbfdat(x,y,z,k)=0;
         else
          cbfdat(x,y,z,k) = 2700*pdat(x,y,z,k)*R/alp/((exp(-Dtime*R)-exp(-(Dtime+Labeltime)*R))*cmean_dat(x,y,z));
         end;
        end;

        if ASLType ==0  %PASL
         if (PASLModat(x,y,z)<mean(threshvalue) | cmean_dat(x,y,z)<mean(threshvalue))
          cbfdat(x,y,z,k)=0;
         else
          cbfdat(x,y,z,k) = 2700*pdat(x,y,z,k)/Labeltime/alp/(exp(-(Dtime+Labeltime)*R)*PASLModat(x,y,z));
         end;
        end;
        
       end;
       end;
       end;
  
      % Write CBF images...
      VCBF(k) = spm_write_vol(VCBF(k),cbfdat(:,:,:,k));
      spm_progress_bar('Set',k);

     end;

  
    if MeanFlag ==1,
     Mean_cbfdat=zeros([VO(1).dim(1:3)]);
     VMCBF.fname = fullfile(pth,['Mean_CBF' nm(1:5) xt]);
     VMCBF = spm_create_vol(VMCBF);
      if strcmp(spm('ver',[],1),'SPM8')   
        VMCBF.dt=[16,0];   %'float' type
      else
        VMCBF.dim(4) = 16; %'float' type
       end;

    voxelnum=0;
    zeronum=0;
    globalCBF=0;
    meancontrol=0;
    
     for x=1:V(1).dim(1),
       for y=1:V(1).dim(2),
         for z=1:V(1).dim(3),
            Mean_cbfdat(x,y,z) = mean(cbfdat(x,y,z,:));
            if Mean_cbfdat(x,y,z) ==0,  
              zeronum = zeronum+1;
            else
              voxelnum = voxelnum+1;
              globalCBF = globalCBF+Mean_cbfdat(x,y,z);
              meancontrol = meancontrol+cmean_dat(x,y,z); 
            end;
         end;
       end;
     end;
 
   globalCBF = globalCBF/voxelnum;
   meancontrol = meancontrol/voxelnum;

     % Write mean CBf image...
     VMCBF = spm_write_vol(VMCBF, Mean_cbfdat);
    end;
    
end;

 gcbf = spm_global(VMCBF);
 gbold = spm_global(VMC);

save globalCBF globalCBF %EDIT(H)
 
  fprintf('\n\t Perfusion images written to: ''%s'' to \n',VO(1).fname)
  fprintf('\t  ''%s''. \n',VO(perfnum).fname)
  if MeanFlag ==1, 
    fprintf('\t Mean_perf image written to: ''%s''.\n\n',VMP.fname)
  end;  

  fprintf('\t BOLD images written to: ''%s''  to \n',VB(1).fname)
  fprintf('\t ''%s'' . \n',VB(perfnum).fname)
  if MeanFlag ==1, 
   fprintf('\t Mean_BOLD image written to: ''%s''.\n\n',VMC.fname)
  end;  

  if CBFFlag ==1, 
     fprintf('\t Quantified CBF images written to: ''%s'' to \n',VCBF(1).fname)
     fprintf('\t ''%s'' .\n',VCBF(fix(length(VCBF)/2)).fname)
     fprintf('\t Mean Quantified CBF image written to: ''%s'' \n\n',VMCBF.fname)

     fprintf('\t the spm global mean BOLD control signal is:')
     fprintf('\t %6.2f \n',gbold)
     fprintf('\t the spm global mean CBF signal is:')
     fprintf('\t %6.3f \n',gcbf)
     fprintf('\t ml/100g/min \n\n')
     
     fprintf('\t the calculated voxel number is:')
     fprintf('\t %8.1f\n',voxelnum)
     fprintf('\t the zero number is:')
     fprintf('\t %8.1f\n',zeronum)
     fprintf('\t the global mean BOLD control signal is:')
     fprintf('\t %6.2f \n',meancontrol)
     fprintf('\t the global mean CBF signal is:')
     fprintf('\t %6.3f',globalCBF)
     fprintf('\t ml/100g/min \n\n')
  end;  

 spm_progress_bar('Clear')
  
 fprintf('......computing done.\n\n')

 spm('Pointer');
 spm('FigName','CBFReconstruct done',Finter,CmdLine);

% 
