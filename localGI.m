function localGI

% Created on Oct 2015 by S Tummala

addpath 'E:\FreeSurfer\matlab' % Matlab files from FreeSurfer
datapath = 'E:\FreeSurfer\test';

% Do it on Left Hemisphere, Reading the freesurfer file formats
[vertices, faces] = freesurfer_read_surf([datapath, '\', 'lh.pial']);
[vertices1, faces1] = freesurfer_read_surf([datapath, '\', 'lh.pial-outer-smoothed']);

FV.faces = faces; FV.vertices = vertices; FV1.faces = faces1; FV1.vertices = vertices1;
N = patchnormals(FV); 
N1 = patchnormals(FV1);
fprintf('Normals computed at each vertex\n');
C = patchcurvature(FV);
C1 = patchcurvature(FV1);
frptintf('Curvatures computed at each vertex\n');