
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import dipy.reconst.dki as dki
import dipy.reconst.dti as dti
from dipy.core.gradients import gradient_table
from dipy.io.gradients import read_bvals_bvecs
from dipy.io.image import load_nifti, save_nifti
from dipy.segment.mask import median_otsu
from scipy.ndimage.filters import gaussian_filter
import dti_combo as dc

data_path = 'D:/Tummala/Parkinson-Data/NITRC_PD_DATA'
demographic_file = 'D:/Tummala/Parkinson-Data/PDClinicalData.csv'

demo_data = pd.read_csv(demographic_file)

subject_id = demo_data['Subject']
Age = demo_data['Age']
Sex = demo_data['Sex']
Intra_volume = demo_data['IntracranialVolume']
handedness = demo_data['Handedness']
group = demo_data['Group']

healthy_fa = []
healthy_md = []
healthy_ad = []
healthy_rd = []

pd_fa = []
pd_md = []
pd_ad = []
pd_rd = []

subjects = os.listdir(data_path)

nifti_tag = '2500.nii.gz'
b_val_tag = 'bval_2500'
b_vec_tag = 'grad_2500'

for index, subject in enumerate(subjects):
    print(f"computing diffusion metrics for {subject}\n")
    sub_files = os.listdir(os.path.join(data_path, subject))
    
    for sub_file in sub_files:
        if sub_file.endswith(nifti_tag):
            data, affine = load_nifti(os.path.join(data_path, subject, sub_file))
        if sub_file.endswith(b_val_tag):
            fbval = os.path.join(data_path, subject, sub_file)
        if sub_file.endswith(b_vec_tag):
            fbvec = os.path.join(data_path, subject, sub_file)
        
    
    bvals, bvecs = read_bvals_bvecs(fbval, fbvec)
    gtab = gradient_table(bvals, bvecs)
        
    maskdata, mask = median_otsu(data, vol_idx=[0, 1], median_radius=4, numpass=2,
                                         autocrop=False, dilate=1)
            
    fwhm = 1.25
    gauss_std = fwhm / np.sqrt(8 * np.log(2))  # converting fwhm to Gaussian std
    data_smooth = np.zeros(data.shape)
    for v in range(data.shape[-1]):
        data_smooth[..., v] = gaussian_filter(data[..., v], sigma=gauss_std)
                
            
    # dkimodel = dki.DiffusionKurtosisModel(gtab)
    # dkifit = dkimodel.fit(data_smooth, mask=mask)
            
    # FA = dkifit.fa
    # MD = dkifit.md
    # AD = dkifit.ad
    # RD = dkifit.rd
            
    tenmodel = dti.TensorModel(gtab)
    tenfit = tenmodel.fit(data_smooth, mask=mask)
            
    dti_FA = tenfit.fa
    file_dti_fa = os.path.join(data_path, subject, '2500.FA.nii.gz')
    if os.path.exists(file_dti_fa):
        print(f'map already computed as {file_dti_fa}\n')
        if group[index] == 'PD':
            pd_fa.append(np.average(dti_FA[dti_FA != 0]))
        elif group[index] == 'Control':
            healthy_fa.append(np.average(dti_FA[dti_FA != 0]))
    else:
        save_nifti(file_dti_fa, dti_FA, affine)
        
    dti_MD = tenfit.md
    file_dti_md = os.path.join(data_path, subject, '2500.MD.nii.gz')
    if os.path.exists(file_dti_md):
        print(f'map already computed as {file_dti_md}\n')
        if group[index] == 'PD':
            pd_md.append(np.average(dti_MD[dti_MD != 0]))
        elif group[index] == 'Control':
            healthy_md.append(np.average(dti_MD[dti_MD != 0]))
    else:
        save_nifti(file_dti_md, dti_MD, affine)
        
    dti_AD = tenfit.ad
    file_dti_ad = os.path.join(data_path, subject, '2500.AD.nii.gz')
    if os.path.exists(file_dti_ad):
        print(f'map already computed as {file_dti_ad}\n')
        if group[index] == 'PD':
            pd_ad.append(np.average(dti_AD[dti_AD != 0]))
        elif group[index] == 'Control':
            healthy_ad.append(np.average(dti_AD[dti_AD != 0]))
    else:
        save_nifti(file_dti_ad, dti_AD, affine)
        
    dti_RD = tenfit.rd
    file_dti_rd = os.path.join(data_path, subject, '2500.RD.nii.gz')
    if os.path.exists(file_dti_rd):
        print(f'map already computed as {file_dti_rd}\n')
        if group[index] == 'PD':
            pd_rd.append(np.average(dti_RD[dti_RD != 0]))
        elif group[index] == 'Control':
            healthy_rd.append(np.average(dti_RD[dti_RD != 0]))
    else:
        save_nifti(file_dti_rd, dti_RD, affine)
        
data1 = np.row_stack((np.array(healthy_fa), np.array(healthy_md), np.array(healthy_ad), np.array(healthy_rd)))
data2 = np.row_stack((np.array(pd_fa), np.array(pd_md), np.array(pd_ad), np.array(pd_rd)))

# checking different classifier performance by combining FA, MD, AD and RD
dc.combinational_cost(data1, data2, 2)

# axial_slice = 9

# fig1, ax = plt.subplots(2, 4, figsize=(12, 6),
#                         subplot_kw={'xticks': [], 'yticks': []})

# fig1.subplots_adjust(hspace=0.3, wspace=0.05)

# ax.flat[0].imshow(FA[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=0.7, origin='lower')
# ax.flat[0].set_title('FA (DKI)')
# ax.flat[1].imshow(MD[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=2.0e-3, origin='lower')
# ax.flat[1].set_title('MD (DKI)')
# ax.flat[2].imshow(AD[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=2.0e-3, origin='lower')
# ax.flat[2].set_title('AD (DKI)')
# ax.flat[3].imshow(RD[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=2.0e-3, origin='lower')
# ax.flat[3].set_title('RD (DKI)')

# ax.flat[4].imshow(dti_FA[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=0.7, origin='lower')
# ax.flat[4].set_title('FA (DTI)')
# ax.flat[5].imshow(dti_MD[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=2.0e-3, origin='lower')
# ax.flat[5].set_title('MD (DTI)')
# ax.flat[6].imshow(dti_AD[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=2.0e-3, origin='lower')
# ax.flat[6].set_title('AD (DTI)')
# ax.flat[7].imshow(dti_RD[:, :, axial_slice].T, cmap='gray',
#                   vmin=0, vmax=2.0e-3, origin='lower')
# ax.flat[7].set_title('RD (DTI)')

# plt.show()
# fig1.savefig('Diffusion_tensor_measures_from_DTI_and_DKI.png')


    # MK = dkifit.mk(0, 3)
    # AK = dkifit.ak(0, 3)
    # RK = dkifit.rk(0, 3)

# fig2, ax = plt.subplots(1, 3, figsize=(12, 6),
#                         subplot_kw={'xticks': [], 'yticks': []})

# fig2.subplots_adjust(hspace=0.3, wspace=0.05)

# ax.flat[0].imshow(MK[:, :, axial_slice].T, cmap='gray', vmin=0, vmax=1.5,
#                   origin='lower')
# ax.flat[0].set_title('MK')
# ax.flat[0].annotate('', fontsize=12, xy=(57, 30),
#                     color='red',
#                     xycoords='data', xytext=(30, 0),
#                     textcoords='offset points',
#                     arrowprops=dict(arrowstyle="->",
#                                     color='red'))
# ax.flat[1].imshow(AK[:, :, axial_slice].T, cmap='gray', vmin=0, vmax=1.5,
#                   origin='lower')
# ax.flat[1].set_title('AK')
# ax.flat[2].imshow(RK[:, :, axial_slice].T, cmap='gray', vmin=0, vmax=1.5,
#                   origin='lower')
# ax.flat[2].set_title('RK')
# ax.flat[2].annotate('', fontsize=12, xy=(57, 30),
#                     color='red',
#                     xycoords='data', xytext=(30, 0),
#                     textcoords='offset points',
#                     arrowprops=dict(arrowstyle="->",
#                                     color='red'))

# plt.show()
# fig2.savefig('Kurtosis_tensor_standard_measures.png')

    # MKT = dkifit.mkt(0, 3)
    # KFA = dkifit.kfa

# fig3, ax = plt.subplots(1, 2, figsize=(10, 6),
#                         subplot_kw={'xticks': [], 'yticks': []})

# fig3.subplots_adjust(hspace=0.3, wspace=0.05)

# ax.flat[0].imshow(MKT[:, :, axial_slice].T, cmap='gray', vmin=0, vmax=1.5,
#                   origin='lower')
# ax.flat[0].set_title('MKT')
# ax.flat[1].imshow(KFA[:, :, axial_slice].T, cmap='gray', vmin=0, vmax=1,
#                   origin='lower')
# ax.flat[1].set_title('KFA')

# plt.show()
# fig3.savefig('Measures_from_kurtosis_tensor_only.png')
