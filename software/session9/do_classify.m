%Andrew Bauer
%brainImagingLabSpring2014

clear all

warning off MATLAB:MKDIR:DirectoryExists;

%classify
[outfConfusion_stub_saved, noVoxels, voxelsID, subjects] = BSA_main;

%display
storeSubjResults_b4Ranked = [];
catSubjLabel_forDisp = [];
for subj_i = 1:numel(subjects)
    outfConfusion_full_saved = sprintf([outfConfusion_stub_saved '%s_RankList.mat'], ...
	       char(subjects(subj_i)));
    load(outfConfusion_full_saved);
    avgAcc = mean(transpose(reshape(rankAccWords(:,2),5,12)),2);
    avgAcc = 100*[mean(avgAcc); avgAcc];
    storeSubjResults_b4Ranked = [storeSubjResults_b4Ranked avgAcc];    
end

[~,I] = sort(storeSubjResults_b4Ranked(1,:),2,'descend');
storeSubjResults = storeSubjResults_b4Ranked(:,I);
for subj_ID = I
    catSubjLabel_forDisp = [catSubjLabel_forDisp strcat('subject_',num2str(subj_ID)) ' '];
end

storeSubjResults = [storeSubjResults mean(storeSubjResults,2)];
catSubjLabel_forDisp = [catSubjLabel_forDisp 'MEAN_subj'];

catLabel_forDisp = 'MEAN_categry animals bodyparts buildings buildprts clothing frniture insects kitchen manmade tools vegetbles vehicles';

maskLabel_forDisp = {'only frontal';
                     'only temporal';
                     'only parietal';
                     'only occipital';
                     'only subcortical';
                     'anywhere EXCEPT occipital'};

disp('============================================');
printmat_local_2SigFigs(storeSubjResults,'MVPA report: Object category BY subject accuracy (%)',catLabel_forDisp,catSubjLabel_forDisp);
disp(['no. of voxels:   ' num2str(noVoxels)]);
disp(['voxels are from: ' maskLabel_forDisp{voxelsID}])
disp('============================================');