function [outfConfusion_stub, noVoxels, voxelsID, subjects] = BSA_main()
%[]= BSA_main(param_file)

% V5 11/11/08 modified to use any number of words ( used to work only with 12 categories and 5 per cat)
% 60 words - btw subjects - main function
% V4 10/25/07 VC - adds masking by area 
% V3.0 adds:
% - for ONE set of parameters (specified as <parameter>_selected)
% - Visualization of selected voxels saveSumImage (Sum_of_folds.img)
%             The name is deceptive here - there are no folds
% - Save a zscore(~log(p)) prediction table savePredictedProbabilities 
%   (zpTable.txt)
% - Save rank-accuracies separately for each word,cat, and catSig
%  catSig.)
%  -Save confusion matrix for word classification
% V 2.0 (8/21/07) - added "CategorySignatures" classification
% V.1.1 (8/10/07) - Fixed "voxel size bug" (clustering)
% -Pre-classifcation normalization (within voxels) for test and train sets
% template parameter file: Semantic_Space_btwSubj_param.m

%addpath /usr/cluster/software/opt/spm2;   %BAD IDEA!!!
%spm_defaults; REMOVED THIS AND ABOVE (I.E. COMMENTED...)


transformToXYZmm = [ -3.1250, 0, 0, 81.2500
                    0, 3.1250, 0, -115.6250
                    0, 0, 6.0000, -54.0000
                    0, 0, 0, 1.0000];
 
curr_dir = pwd;

param_file = 'BSA_param';
modifyMeOnly_param_file = 'modifyMeOnly';

eval(param_file);
eval(modifyMeOnly_param_file);

%mask
chooseMaskList = {{'Frontal'},{'Temporal'},{'Parietal'},{'Occipital'},{'Subcortical'},{'No_Occipital'}};
maskList = chooseMaskList{voxelsID};

%noVoxels
filterOptions = {{'Replica', noVoxels, 'none', 0}};

if(exist('./BetweenSubjects') ~= 7)
 mkdir ('./BetweenSubjects');
end
if(exist(['./BetweenSubjects/' groupName]) ~= 7)
 mkdir (['./BetweenSubjects'], groupName);
end
%save paramfiles in the results directory
copyfile(which(param_file),['./BetweenSubjects/' groupName]);

% check if the data were "pre-treated" earlier
inpf = sprintf('./BetweenSubjects/%s/%s_pretreat.mat', ...
	      groupName, groupName);
if exist(inpf) ~= 2
% there is no input file - need to create it
 BetweenSubjectsAnalysis_pretreat(param_file);
end
% load pre-treated data
load (inpf);

% should have 'C','Mpsc','common','allsubjects_saved' variables loaded
% check that allsubjects_saved and allsubjects are the same
if sum(strcmp(allsubjects, allsubjects_saved)) ~= size(allsubjects,2)
 disp(['ERROR - the saved subjects list:\n' allsubjects_saved ...
      '\n does not match the parameter file list:\n' allsubjects]);
 return
end

n_categories= length(unique(C(:,1)));
n_words= length(unique(C(:,2)))*n_categories;

allsubjects = allsubjects_saved;

% Do we have a "selected" set of parameters?
if (exist('classifyTaskList_selected','var') && ...
    exist('filterOptions_selected','var') && ...
    exist('clusterOptions_selected','var') && ...
    exist('classifierStrings_selected','var'))
  selection_set = 1;
else
  selection_set = 0;
end

% cycle through the subjects in subjects list (s)

for s=1:size(subjects,2)
 disp(['------Working on subject ' char(subjects(s))]);

% Masking (new in V4.0)
 if ~exist('maskList','var')
  maskList = {''}; 
 end

 
  % cycle through the maskList
  for mo = 1:size(maskList,2)
   disp(['--Subject ' char(subjects(s)) ' Mask ' char(maskList(mo))]);
 % replace groupName_mask, Mpsc_mask, common_mask
   maskOut = 0;
   maskName = char(maskList(mo));
   if strcmp(maskName(1:3),'No_')
     maskName = maskName(4:length(maskName));
     maskOut = 1;
   end
   if strcmp(char(maskList(mo)),'') 
     groupName_mask = groupName;
   else
     groupName_mask = [groupName '/' char(maskList(mo))];
   end
   if ~((strcmp(char(maskList(mo)),'') || strcmp(char(maskList(mo)),'All')))
     if maskOut
      ind_masked = ccbiMaskXYZ(common, maskName, maskOut);       
     else
      ind_masked = ccbiMaskXYZ(common, maskName);
     end
     Mpsc_mask = Mpsc(:,ind_masked);
     common_mask = common(ind_masked,:);
   else
     Mpsc_mask = Mpsc;
     common_mask = common;
   end
   if(exist(['./BetweenSubjects/' groupName_mask]) ~= 7)
     mkdir(['./BetweenSubjects/' groupName], char(maskList(mo)));
   end
% from here, I should use Mpsc_mask instead of Mpsc,
%                         groupName_mask instead of groupName,
%                         common_mask instead of common


%%% RANKLIST ___ extract list of sixty words for confusion matrix
% Load info from the "semantic_space" template
 load(templateWordLabelsMatFile);
 sortedSixtyWords=templateWordLabels;

 truelabelsConfusion =[];
 predictedLabelsConfusion =[];
 rankAccWords= [];
 rankAccCat =[];
 rankAccCatSig =[];
 outfConfusion = sprintf('./BetweenSubjects/%s/%s_RankList.mat', ...
	       groupName_mask, char(subjects(s)));
 outfConfusion_stub = sprintf('./BetweenSubjects/%s/', ...
	       groupName_mask);
 rankPredictionList=[];
 trueLabels=rankPredictionList ;
 trueLabels_Cat=rankPredictionList ;
 trueLabels_CatSig=rankPredictionList ;
 MeasureEx = rankPredictionList;
 MeasureEx_Cat =MeasureEx;
 MeasureEx_CatSig =MeasureEx;            

%%% RANKLIST ___

% print a header (per subject)
 fid = fopen(sprintf('./BetweenSubjects/%s/%s_%s.txt',...
	    groupName_mask, char(subjects(s)),datestr(now,'yyyy-mm-dd')),'w');
 fprintf(fid,'Included subjects: ');
 fprintf(fid,'%s ', allsubjects{:});
 fprintf(fid,'\nResults for the subject %s', char(subjects(s)));
 fprintf(fid,'\nDate: %s',date);
 fprintf(fid,'\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s','Subject', ...
	      'Cassifier','F1_type', 'F1_voxels', ...
              'F2_type', 'F2_voxels','Clusters', 'Nclusters', 'Classifying',...
              'accuracy','rankAccuracy');
% find the index of the corresponding (test) subject in allsubjects
  test_subject_n = find(strcmp(subjects(s), allsubjects));

  for ct = 1:size(classifyTaskList,2)    % task list cycle
   classifyTask = classifyTaskList(ct);
   
% matix to hold the predicted labels (NB: 12 & 60 hard-coded here!)
% this would be wrong if I have more than one exemplar (of the same kind) in the test set...
  if (selection_set && savePredictedProbabilities && classifyTaskList_selected ...
      == ct)
   if strcmp(char(classifyTaskList{ct}),'Words')
    plogPred = zeros(n_words,n_words); % predictions matrices for each fold -words
   else
    plogPred = zeros(n_categories,n_categories); % predictions matrices for each fold
                             % - categories
   end
  end

% prepare an array to hold the selected voxels data
  if (selection_set && saveSumImage && classifyTaskList_selected == ct)
    XYZmm_sum = [];
  end 

% find training and test sets (note that subjects are represented as presentations here)

   [testExamples,trainExamples,testLabels,trainLabels,trainFeatureLabels, ...
    testFeatureLabels, trainPresentations] = ...
    my_findLabels(Mpsc_mask,C,'presentations', test_subject_n, classifyTask);

 % Compute the replicability scores - in any case 
   [decI,R2]=computeReplicability(trainFeatureLabels, trainPresentations, ...
            trainExamples, 'Replica', 'Mean');
% R2 - scores (order as in "common_mask")
% decI - decreasing score index to R2
% if we take the last N (indexed) voxels - that is our subset
% decN1 is its (decreasing) index  
% -----------FILTERING------

   for fo = 1:size(filterOptions,2)
    disp(['----Filtering subject ' char(subjects(s)) ' option ' int2str(fo)]);
% first filter is always "replica" (or none)
    if strcmp(filterOptions{fo}{1},'Replica')
     decN1 = decI(size(decI,2)-filterOptions{fo}{2}+1: size(decI,2));
    else
     decN1 = decI;
    end

% second filter may be LR (Logistic Regression) or none
    if strcmp(filterOptions{fo}{3},'LR')
% some logistic regression implementation (with a "strange" trainClassifier function)
     Mpsc_red =trainExamples(:,decN1);
     [classifierFS]=trainClassifier(Mpsc_red, trainFeatureLabels , ...
                                    'logisticRegression',...
		                    {0.01 0.00001 100});
     [tmpa, tmpb, tmp_I] = transformExample_selectVoxelsLR(Mpsc_red, ...
                              filterOptions{fo}{4}, classifierFS,3);

% tmp_I is a decN1*1 vector containing betas for ALL input voxels (same order as in decN1)
     x = [tmp_I decN1']; 
     y = sortrows(x,1);
     decN2 = y(size(y,1)-filterOptions{fo}{4}+1: size(y,1),2)';
     clear Mpsc_red classifierFS tmpa tmpb tmp_I x y;
%  decN2 = decN1(1:filterOptions{fo}{4});   %FAKE!!! -Later
    else
     decN2 = decN1;
    end

% -----------CLUSTERING------

    for co=1:length(clusterOptions) % cycle for nvoxels/clusteroptions options
     disp(['----Clustering subject ' char(subjects(s)) ' option ' int2str(co)]);
     if(strcmp(clusterOptions{co}{1}, 'Yes')) 
      Nclust = clusterOptions{co}{2};
% V1.1 - bug fix
      voxel_dim=[3.125 3.125 6]';
      mm_coord = common_mask(decN2,:).*repmat(voxel_dim,1,size(decN2,2))';
      cl_ind=kmeans(mm_coord, Nclust,'EmptyAction','singleton','replicates',5);
      clear mm_coord;

% Indx' is a vector assigning cluster number to each voxel in decN2 '
% create clustExamples - reduced x*Nclust matrices, mean of all voxels in a cluster
      clustertrainExamples=zeros(size(trainExamples,1), Nclust);
      clustertestExamples=zeros(size(testExamples,1), Nclust);

      x = trainExamples(:, decN2)';
      y = testExamples(:, decN2)';

      for i=1:Nclust
       tmp_ind = find(cl_ind==i);
% handle the case when there is one voxel in the cluster
       if (size(tmp_ind,1) > 1)
        clustertrainExamples(:,i) = mean(x(tmp_ind,:))';
        clustertestExamples(:,i) = mean(y(tmp_ind,:))';
       else
        clustertrainExamples(:,i) = x(tmp_ind,:)';
        clustertestExamples(:,i) = y(tmp_ind,:)';
       end
      end
      clear x y;
      
% save a list of coordinates of voxels in clusters, if requested
      if(strcmp(clusterOptions{co}{3}, 'saveCluster')) 
       tmp_colToCluster = zeros(1,size(Mpsc_mask,2));
       tmp_colToCluster(decN2) = cl_ind;

% Generate a name for the variable that includes indeces of all options:
% e.g. colToCluster1_1_2_2_2  
% Here we actually do not have foldOptions and fold#, bat this is
% done for the compatibility with within-subject clusters
% The meanings of indeces in the variable name are:
% 1_classifyTask_filterOption_clusterOption_1
       tmp_str = ['colToCluster1_' num2str(ct) '_' num2str(fo) '_' ...
                   num2str(co) '_1'];
       eval([tmp_str ' = tmp_colToCluster;']); 
       outf = sprintf('./BetweenSubjects/%s/%s.mat', ...
		      groupName_mask, char(subjects(s)));
       if exist(outf) == 2
        save(outf,tmp_str, '-APPEND');
       else
        save(outf,tmp_str);
       end
      end % save cluster

% form the output variables
      reducedtrainExamples = clustertrainExamples;
      reducedtestExamples = clustertestExamples;
      clear clustertrainExamples clustertestExamples;
     else
      reducedtrainExamples = trainExamples(:,decN2);
      reducedtestExamples = testExamples(:,decN2);
     end % request for clustering

% combine the testExamples and testLabels for categorySignatures...
% doing it on the reduced sets speeds it up, but also requires 
% usage of reducedtestExamples...
   if(strcmp(classifyTask,'CategorySignatures'))
    disp('Averaging test exemplars for categories...');
    ncategories=max(unique(testLabels));
    tmp_testExamples=zeros(ncategories,size(reducedtestExamples,2));
    tmp_testLabels = zeros(ncategories,1);
    for ii = 1:ncategories
     tmp_testExamples(ii,:) = mean(reducedtestExamples(find(testLabels==ii),:));
     tmp_testLabels(ii) = ii;
    end  
    reducedtestExamples = tmp_testExamples;
    reducedtestLabels = tmp_testLabels;
    clear tmp_testExamples tmp_testLabels;
   else
    reducedtestLabels =  testLabels;
   end
 

% ------RE-NORMALIZATION------
% re-normalizing the data before the classification (standardize voxels)
% separately for test and train
% ----Large improvement both in rank acc and especially in abs accuracy!
     reducedtrainExamples = reducedtrainExamples - ...
         repmat(mean(reducedtrainExamples),size(reducedtrainExamples,1),1);
     reducedtrainExamples = reducedtrainExamples./ ...
         repmat(std(reducedtrainExamples),size(reducedtrainExamples,1),1);
     reducedtestExamples = reducedtestExamples - ...
         repmat(mean(reducedtestExamples),size(reducedtestExamples,1),1);
     reducedtestExamples = reducedtestExamples./ ...
         repmat(std(reducedtestExamples),size(reducedtestExamples,1),1);

% -----------CLASSIFICATION------ 

     for c=1:length(classifierStrings)
      disp(['----Classifying subject ' char(subjects(s))]);
      classifierString=classifierStrings{c};
      [classifier]=trainClassifier(reducedtrainExamples, trainLabels, classifierString);
      [predictions]=applyClassifier(reducedtestExamples, classifier);
      [results,predictedLabels,trace]=summarizePredictions(predictions, ...
				  classifier,'averageRank', reducedtestLabels);

% if needed, save the predicted and actual labels here
      %disp('Correctly predicted words or categories (ignore 0):')
      %disp(sprintf('%d ',char(unique((predictedLabels==reducedtestLabels) .* reducedtestLabels))));
      racc=1-results{1};
      acc=sum(predictedLabels==reducedtestLabels)/length(reducedtestLabels);
      disp(sprintf('Subject''s rank accuracy was %4.3f\n', racc));

%%% RANKLIST ___ fill in the data
if (selection_set && saveRankAndConfusion && ...
    fo == filterOptions_selected && ...
    co == clusterOptions_selected   && c == classifierStrings_selected)
 if strcmp(classifyTask,'Categories')
  MeasureEx_Cat=[MeasureEx_Cat; results{2}];
  trueLabels_Cat=[trueLabels_Cat; reducedtestLabels];   
 end
 if strcmp(classifyTask,'Words')
  rankPredictionList=[rankPredictionList;trace{1}];
  trueLabels=[trueLabels;testLabels];
  MeasureEx=[MeasureEx ;results{2}];         
 end  
 if strcmp(classifyTask,'CategorySignatures')
  MeasureEx_CatSig=[MeasureEx_CatSig; results{2}];
  trueLabels_CatSig=[trueLabels_CatSig; reducedtestLabels]; 
 end
end
%%% RANKLIST ___
      
% new in V3.0
% if requestsd and appropriate, keep voxel coords for a Sum_of_folds file
% Actually, for BSA, there is just one fold...
% Are we in the "selected" set of parameters?
     if (selection_set && ...
         ct == classifyTaskList_selected && fo == filterOptions_selected && ...
         co == clusterOptions_selected   && c == classifierStrings_selected)
%keyboard 
      if saveSumImage  % add info for the Sum_of_folds.img       
       XYZ =  common_mask(decN2,:); % grid coords
% MNI coords for the fold
       XYZmm_fold = [transformToXYZmm(1:3,:)*[XYZ ones(size(XYZ,1),1)]']'; 
% MNI coords for the sum of all folds
       XYZmm_sum = [XYZmm_sum; XYZmm_fold];
      end      
%      ----
      if savePredictedProbabilities      
% to obtain probabilities for each category:
% exp(predictions(1,:))./sum(exp(predictions(1,:)))
% average multiple exemplar predictions (if any) here
% this can happen only for Categories
       if size(predictions,1) > size(plogPred,1)
%keyboard
         for m=1:n_categories
         z =  mean(predictions(find(testLabels == m),:),1);
         plogPred(m,:) = (zscore(z'))';
%         plogPred(m,:) = mean(predictions(find(testLabels == m),:),1);
        end
       else  
%        plogPred(:,:) = predictions;
        plogPred(:,:) = (zscore(predictions'))';
       end
      end
     end      
      
      fprintf(fid,'\n%s\t%s\t%s\t%d\t%s\t%d\t%s\t%d\t%s\t%4.3f\t%4.3f', ...
           char(subjects(s)), classifierString,filterOptions{fo}{1},filterOptions{fo}{2},...
          filterOptions{fo}{3},filterOptions{fo}{4}, clusterOptions{co}{1}, ...
          clusterOptions{co}{2}, classifyTaskList{ct}, acc,racc);

      clear reducedtrainExamples reducedtestExamples reducedtestLabels;
     end % classify
    end % clusterOptions
   end % filterOptions
  end % classifyTaskList
  fprintf(fid,'\n');
  fclose(fid);
  
 %REMOVED THIS
% compute and save a "sum" of selected images for all folds
% if selection_set && saveSumImage
%  tmp_str = [char(subjects(s)) '_Sum_of_Folds'];
%  outf = sprintf('/scratch/%s/BetweenSubjects/%s/%s.img', ...
%		       experiment, groupName_mask,tmp_str);
%  ccbi_mm2img(XYZmm_sum, ['/usr/cluster/projects2/semantic_space/04008B/' ...
%                    'results_wraf336/mask.img'], outf);   
%
% end
 if selection_set && savePredictedProbabilities
% generate an averaged table of each "exemplar" probability
% the table should be read BY ROWS only - 
% save an averaged table of predictions - from predictions
%  prTable = mean(plogPred,3);
  prTable = plogPred;
  fid = fopen(sprintf('./BetweenSubjects/%s/%s_zpTable.txt', ...
		       groupName_mask,char(subjects(s))),'w');

% Words or categories?
  if strcmp(char(classifyTaskList{classifyTaskList_selected}),'Words')
% Note: word "labels" here are: wordLabels=((C(:,1)-2)*numwords)+C(:,2)
% 1...5    - 1-5 for cat 1
% 6...10   - 1-5 for cat 2
% 56...60  - 1-5 for cat 12
   for i=1:n_words
    for j = 1:n_words-1
     fprintf(fid,'%6.2f\t',prTable(i,j));
    end
     fprintf(fid,'%6.2f\n',prTable(i,n_words));
   end
  else
   for i=1:n_categories
    fprintf(fid,'%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\n',prTable(i,:));
   end
  end
  fclose(fid);
 end

%%% RANKLIST ___ print header for confusion matrix    
if selection_set && saveRankAndConfusion && ...
   strcmp(char(classifyTaskList{classifyTaskList_selected}),'Words')   
  fid_con = fopen(sprintf('./BetweenSubjects/%s/%s_Confusion_%s.txt', ...
            groupName_mask, char(subjects(s)),datestr(now,'yyyy-mm-dd')),'w');    
end
%%% RANKLIST ___   

%%% RANKLIST ___ Save confusion matrix and compute accuracies (for all tasks)
if selection_set && saveRankAndConfusion 
  for ct = 1:size(classifyTaskList,2)
   if strcmp(char(classifyTaskList{ct}),'Categories')
%save rank Acc for individual category     
    uniqCatLabels_conf = unique(trueLabels_Cat); 
    rankACcCat_temp =uniqCatLabels_conf ; % dummy assignment
    for i_con =1:length(uniqCatLabels_conf)
      MeasureEx_Cat_i_con = MeasureEx_Cat(find(trueLabels_Cat ==uniqCatLabels_conf(i_con)));
      rankACcCat_temp(uniqCatLabels_conf(i_con)) =1 - (sum(MeasureEx_Cat_i_con)/length(MeasureEx_Cat_i_con)-1)/(length(uniqCatLabels_conf)-1);
    end
    rankAccCat = [uniqCatLabels_conf , rankACcCat_temp];
  end
   if strcmp(char(classifyTaskList{ct}),'Words')
% print for words only 
    truelabelsConfusion =trueLabels;
    predictedLabelsConfusion =rankPredictionList;
    uniqwordLabels_conf = unique(trueLabels); 
    rankACcWords_temp =uniqwordLabels_conf ; % dummy assignment
    for i_con =1:length(uniqwordLabels_conf)
      MeasureEx_i_con = MeasureEx(find(truelabelsConfusion==uniqwordLabels_conf(i_con)));
      rankACcWords_temp(uniqwordLabels_conf(i_con)) =1 - (sum(MeasureEx_i_con)/length(MeasureEx_i_con)-1)/(length(uniqwordLabels_conf)-1);
    end
    rankAccWords = [uniqwordLabels_conf , rankACcWords_temp];
    fid_con = fopen(sprintf('./BetweenSubjects/%s/%s_Confusion_%s.txt', ...
            groupName_mask, char(subjects(s)),datestr(now,'yyyy-mm-dd')),'w');    
    fprintf(fid_con,'\nTrue Label\t');
    fprintf(fid_con,'%d\t',1:n_words);
    for fp=1:length(trueLabels)
      fprintf(fid_con,'\n');
      fprintf(fid_con,'%s\t',sortedSixtyWords{trueLabels(fp)});
      fprintf(fid_con,'%s\t',sortedSixtyWords{rankPredictionList(fp,:)});
    end
    fprintf(fid_con,'\n');
    fclose(fid_con);
   end
   if strcmp(char(classifyTaskList{ct}),'CategorySignatures')
%save rank Acc for individual category (CatSig)    
    uniqCatLabels_confSig = unique(trueLabels_CatSig); 
    rankACcCat_tempSig =uniqCatLabels_confSig ; % dummy assignment
    for i_con =1:length(uniqCatLabels_confSig)
      MeasureEx_Cat_i_conSig = MeasureEx_CatSig(find(trueLabels_CatSig ==uniqCatLabels_confSig(i_con)));
      rankACcCat_tempSig(uniqCatLabels_confSig(i_con)) =1 - (sum(MeasureEx_Cat_i_conSig)/length(MeasureEx_Cat_i_conSig)-1)/(length(uniqCatLabels_confSig)-1);
    end
    rankAccCatSig = [uniqCatLabels_confSig , rankACcCat_tempSig];
   end
  end

%% Save confusion Matrix and rank accuracy of the words.
  if (selection_set && saveRankAndConfusion)
    save(outfConfusion,'truelabelsConfusion','predictedLabelsConfusion', ...
         'rankAccWords','rankAccCat','rankAccCatSig'); 
%   save(outfConfusion,'plogPred', '-APPEND');
%   save(outfConfusion,'pPred', '-APPEND');
  end
end
%%% RANKLIST ___   

end % mask loop 
end % subject loop

fclose all;
close all;
