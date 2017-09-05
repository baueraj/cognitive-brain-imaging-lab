%Andrew Bauer
%brainImagingLabSpring2014

clear all

warning off MATLAB:MKDIR:DirectoryExists;

%classify
[outfConfusion_saved, noVoxels, voxelsID] = WSA_main;

%display
load(outfConfusion_saved);
avgAcc = mean(transpose(reshape(rankAccWords(:,2),5,12)),2);
avgAcc = 100*[mean(avgAcc); avgAcc];

catLabel_forDisp = 'all animals bodyparts buildings buildprts clothing frniture insects kitchen manmade tools vegetbles vehicles';

maskLabel_forDisp = {'frontal';
'temporal';
'parietal';
'occipital';
'no occipital'};

disp('======================');
printmat_local_2SigFigs(avgAcc,'MVPA report',catLabel_forDisp,'accuracy(%)');
disp(['no. of voxels:   ' num2str(noVoxels)]);
disp(['voxels are from: ' maskLabel_forDisp{voxelsID}])
disp('======================');