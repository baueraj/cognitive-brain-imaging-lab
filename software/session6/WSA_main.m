function [outfConfusion, noVoxels, voxelsID] = WSA_main()
% main function to run within-subject analysis (60 words - images
% experiment)
% V6.0 02/15/10 SA - allows train and testing on selected word labels only from applicable C matrix if subsetTrainAndTestTrialsByWLs is defined.
% V5.0 11/19/08 SA - parameterized new set of C Matrix is defined in param file.
% V4.1 6/12/08 VC - parametrize # of words, cats, and pres
% V4 10/25/07 VC - adds masking by area
% V3.2 10/10/07 VC - zpTable (averaging z-scores of log-probabilities
%  between folds; saves rank-accuracies separately for each word,cat, and
%  catSig.)
% V3.1 9/24/07 VC - fixed bug in saveSumImage
% V3.0 9/06/07 VC
% Additons:
% for ONE set of parameters (specified as <parameter>_selected)
% - Visualization of selected voxels saveSumImage (Sum_of_folds.img)
% - Save a ~log(p) prediction table savePredictedProbabilities (averaged across folds) (prTable.txt)
% - catSignatureEverywhere:
%    Replicability based on categories, not words (special case)
%
% V2.0   8/21/07 VC
% Changes:
% -LeaveFew style folds for everything (valid: 1,2,3,4,5)
% -Classification Tasks: Words, Categories, CategorySignatures
% -Pre-classifcation normalization (within voxels) for test and train sets
% -new names for the saveCluster variables, like
% colToCluster[foldOption_classifyTaskOption_filterOption_clusterOption_fold#]
% -uses new function my_findLabels
% Template parameter file: WithinSubjectAnalysis_main_param.m

% within subjects - main function
% note: cycle s is through subjects
% cycle p is  through folds
%cycle order:
% $$$ for s=1:size(subjects,2)                 % subjects
% $$$  for mo = 1:size(maskList,2)             % masks
% $$$   for ct = 1:size(classifyTaskList,2)    % task list cycle  
% $$$    for p = 1:npres                       % folds  
% $$$     for fo = 1:size(filterOptions,2)     % filter list
% $$$      for co=1:length(clusterOptions)     % cluster list
% $$$       for c=1:length(classifierStrings)  % classifier list
% $$$  
% $$$       end
% $$$      end
% $$$     end
% $$$    end
% $$$   end  
% $$$  end
% $$$ end


%spm_defaults; REMOVED THIS
transformToXYZmm = [ -3.1250, 0, 0, 81.2500
                    0, 3.1250, 0, -115.6250
                    0, 0, 6.0000, -54.0000
                    0, 0, 0, 1.0000];

curr_dir = pwd;

param_file = 'WSA_param';
modifyMeOnly_param_file = 'modifyMeOnly';

eval(param_file);
eval(modifyMeOnly_param_file);

%mask
chooseMaskList = {{'Frontal'},{'Temporal'},{'Parietal'},{'Occipital'},{'No_Occipital'}};
maskList = chooseMaskList{voxelsID};

%noVoxels
filterOptions = {{'Replica', noVoxels, 'none', 0}};

%RELATIVE PATHS

if(exist('./WithinSubject') ~= 7)
 mkdir ('./WithinSubject');
end
if(exist(['./WithinSubject' groupName]) ~= 7)
 mkdir (['./WithinSubject'], groupName);
end
%save paramfiles in the results directory
%
copyfile(which(param_file),['./WithinSubject/' groupName]);
copyfile(which(modifyMeOnly_param_file),['./WithinSubject/' groupName]);

% Do we have a "selected" set of parameters?
if (exist('classifyTaskList_selected','var') && ...
    exist('filterOptions_selected','var') && ...
    exist('foldOptions_selected','var') && ...
    exist('clusterOptions_selected','var') && ...
    exist('classifierStrings_selected','var'))
  selection_set = 1;
else
  selection_set = 0;
end

% cycle through the subjects in subjects list (s)

for s=1:size(subjects,2)
 disp(['------Working on subject ' char(subjects(s))]);
% Load and pre-treat the data
 inpf = sprintf('../%s/%s/%s',mDir,char(subjects(s)),mFile);
 S = load(inpf);
 [C,Mpsc]=transformIDMtoMPSC(S);
 mm=mean(Mpsc,1);
 if any(isnan(mm)); 
   error('NAN in mpsc (quitting)')
 end


 % standardize the data - averaging across voxels

 Mpsc=Mpsc-(repmat(mean(Mpsc')',1,size(Mpsc,2)));
 Mpsc=Mpsc./(repmat(std(Mpsc')',1,size(Mpsc,2)));
 common=S.meta.colToCoord;

%%% RANKLIST ___ extract list of sixty words for confusion matrix
 words={S.info.word};  % 1x240 cell word labels
 clear S;



% Now Map to the new C matrix if provided.
 if ( exist ('newCMatFile' , 'var'))
 newC = load( newCMatFile, 'ascii');   %
 [Mpsc, C, ind_slctdtrls] = ccbiMaskAndMapMpscForClsfcn(Mpsc, C, newC);
 words = words(ind_slctdtrls);
 end
 
 cond=C(:,1); %1x240 (2:9, in order of presentation)
 word=C(:,2); %1x240 (1:5, in order of presentation)
 numwords=length(unique(word)); % 5
 wordLabels=((cond-2)*numwords)+word; % (unique numbers 1:40)

 
 % total number of unique words = length(unique(wordLabels)) (40)
 exp_word_number = length(unique(wordLabels));
 exp_category_number = length(unique(cond));
 exp_pres_number = length(word)/exp_word_number;
 [dummy, wordIndices,dummy] = unique(wordLabels); % index to unique wordLabels
 sortedSixtyWords=words(wordIndices); % lets leave the sixtyWords name...
 % [1:40] - unique word numbers
 % sortedSixtyWords - matching word labels ('apple')
 


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
   if ~((strcmp(char(maskList(mo)),'') || strcmp(char(maskList(mo)), ...
                                                 'All')))
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
   if(exist(['./WithinSubject/' groupName_mask]) ~= 7)
     mkdir(['./WithinSubject/' groupName], char(maskList(mo)));
   end
 
% from here, I should use Mpsc_mask instead of Mpsc,
%                         groupName_mask instead of groupName,
%                         common_mask instead of common
 
    %save traces

    AlltestLabels =[];
    AllTrace =[];



   truelabelsConfusion =[];
   predictedLabelsConfusion =[];
   rankAccWords= [];
   rankAccCat =[];
   rankAccCatSig =[];
   outfConfusion = sprintf('./WithinSubject/%s/%s_RankList.mat', ...
	       groupName_mask, char(subjects(s)));

   rankPredictionList=[];
   trueLabels=rankPredictionList ;
   trueLabels_Cat=rankPredictionList ;
   trueLabels_CatSig=rankPredictionList ;
   MeasureEx = rankPredictionList;
   MeasureEx_Cat =MeasureEx;
   MeasureEx_CatSig =MeasureEx;            

%%% RANKLIST ___

%   clear S;

   if (exist('catSignatureEverywhere','var') && catSignatureEverywhere)
% Special case: catSignatureEverywhere
% 
% QND method for averaging all words witihin presentation/category
% good only for category prediction
% This way, replicability will be computed on cat signatures, not words
    tmp_maxP = max(C(:,3));
    tmp_maxV = max(C(:,2));
    tmp_maxC = max(C(:,1));   % note: cats are from 2 to maxcat
    tmp_Mpsc = zeros(tmp_maxP*(tmp_maxC-1), size(Mpsc_mask,2));
    tmp_C = zeros(tmp_maxP*(tmp_maxC-1), 3);
    k=1;
    for i = 1:tmp_maxP
      for j = 2:tmp_maxC
        ind = find(C(:,3)==i & C(:,1)==j); 
        tmp_Mpsc(k,:) = mean(Mpsc_mask(ind,:),1);
        tmp_C(k,:) = [j 1 i];
        k = k+1;
      end 
    end 

    Mpsc_mask = tmp_Mpsc;
    C = tmp_C;
    clear tmp_Mpsc tmp_C tmp_maxP tmp_maxV tmp_maxC;

   end 

% print a header (per subject)
   fid = fopen(sprintf('./WithinSubject/%s/%s_%s_%s.txt', ...
            groupName_mask, char(subjects(s)),char(foldOptions{1}{1}),datestr(now,'yyyy-mm-dd')),'w');

   fprintf(fid,'\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s','Subject', 'Folding',...
           'Cassifier','F1_type', 'F1_voxels', ...
           'F2_type', 'F2_voxels','Clusters', 'Nclusters', 'Classifying',...
           'accuracy','rankAccuracy');
 
   for ct = 1:size(classifyTaskList,2)    % task list cycle
     classifyTask = classifyTaskList(ct);

% eventually, I want to cycle through the foldOptions here...
     for foldc = 1:size(foldOptions,2)   
       if strcmp(char(foldOptions{foldc}{1}),'LeaveFew')
% I want to use all possible combinations of n presentations
% Train presentations will be used "as is";
% test presentation will be averaged separately for each word
% NOT for category
       vpres = [1:exp_pres_number];
        mpres = combnk(vpres,foldOptions{foldc}{2}); % matrix of all combinations
                                                     % of n elements (treated as
                                                     % test sets)
        nfolds = size(mpres,1);
       else
% standard folding by presentation - lets not use this for now
        nfolds = size(foldOptions{foldc}{2},2);
       end

% matix to hold the predicted labels (NB: 12 & 60 hard-coded here!)
%replacing with exp_category_number and  exp_word_number
% this would be wrong if I have more than one exemplar (of the same kind) in the test set...
       if (selection_set && savePredictedProbabilities && classifyTaskList_selected ...
           == ct)
         if strcmp(char(classifyTaskList{ct}),'Words')
           plogPred = zeros(exp_word_number,exp_word_number,nfolds); % predictions matrices for each fold -words
         else
           plogPred = zeros(exp_category_number,exp_category_number,nfolds); % predictions matrices for each fold
                                           % - categories
         end
       end
  
% prepare an array to hold the selected voxels data
       if (selection_set && saveSumImage && classifyTaskList_selected == ct)
         XYZmm_sum = [];
       end
% Form a matrix to hold the calssification results for a subject, as the
% order of cycles is not optimal for this:
% Columns: folds filter cluster classifier abs_acc rank_acc
       acc_matrix = zeros(nfolds*size(filterOptions,2)*size(clusterOptions,2)*size(classifierStrings,2),6);   
       acc_matrix_ind = 1;   
  
  % cycle through the folds here  
  for p = 1:nfolds
   if strcmp(char(foldOptions{foldc}{1}),'LeaveFew') & foldOptions{foldc}{2} > 1
    test_pres = mpres(p,:);
%    train_pres = mpres(p,:);
%   test_pres = setdiff(vpres,train_pres);
   else
    test_pres = p;
   end
% find training and test sets 
   [testExamples,trainExamples,testLabels,trainLabels,trainFeatureLabels, ...
    testFeatureLabels, trainPresentations] = ...
    my_findLabels(Mpsc_mask,C,'presentations', test_pres, classifyTask);

% handle LeaveFew averaging here - once for a fold
% NB - testEverything is modified here
   if strcmp(char(foldOptions{foldc}{1}),'LeaveFew') & foldOptions{foldc}{2}>1
% average the exemplars of words in the test set - for ANY classification task
% NB: For Categories/CategorySignatures, we want to average only the same
% words
% Pro me: this should actually not depend on the classification task...
    if (strcmp(classifyTask,'Categories') | strcmp(classifyTask,'CategorySignatures'))
%keyboard
     nwords = length(unique(testFeatureLabels));  
     tmp_testExamples=zeros(nwords,size(testExamples,2));
     tmp_testLabels = zeros(nwords,1); 
     for jj=1:nwords
      x = find(testFeatureLabels==jj);
      tmp_testExamples(jj,:) = mean(testExamples(x,:),1);
      tmp_testLabels(jj) = testLabels(x(1));
     end 
     testExamples = tmp_testExamples;
     testLabels = tmp_testLabels;
     clear tmp_testExamples tmp_testLabels;
    else  % Words
     nwords = length(unique(testLabels));  
     tmp_testExamples=zeros(nwords,size(testExamples,2));
     for jj=1:nwords
      tmp_testExamples(jj,:) = ...
      mean(testExamples(find(testLabels==jj),:),1);
     end
%keyboard
     testExamples = tmp_testExamples;
     clear tmp_testExamples;
     testLabels = linspace(1,nwords,nwords)';  %'
     end
   end

% combine the testExamples and testLabels for categorySignatures...
   if(strcmp(classifyTask,'CategorySignatures'))
    disp('Averaging test exemplars for categories...');
    ncategories=max(unique(testLabels));
    tmp_testExamples=zeros(ncategories,size(testExamples,2));
    tmp_testLabels = zeros(ncategories,1);
    for ii = 1:ncategories
     tmp_testExamples(ii,:) = mean(testExamples(find(testLabels==ii),:),1);
     tmp_testLabels(ii) = ii;
    end  
    testExamples = tmp_testExamples;
    testLabels = tmp_testLabels;
    clear tmp_testExamples tmp_testLabels;
   end

   
   
% Compute the replicability scores - in any case 
   [decI,R2]=computeReplicability(trainFeatureLabels, trainPresentations, ...
                                  trainExamples, 'Replica', 'Mean');
% R2 - scores (order as in "common_mask")
% decI - decreasing score index to R2
% if we take the last N (indexed) voxels - that is our subset
% decN1 is its (decreasing) index  
% -----------FILTERING------

   for fo = 1:size(filterOptions,2)   % Cycle through the filter options
    disp(['----Filtering subject ' char(subjects(s)) ' fold ' int2str(p)  ...
          ' option  ' int2str(fo)]);

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
     [classifierFS]=trainClassifier(Mpsc_red, trainFeatureLabels ,'logisticRegression',...
		                    {0.01 0.00001 100});
     [tmpa, tmpb, tmp_I] = transformExample_selectVoxelsLR(Mpsc_red,filterOptions{fo}{4}, ...
						           classifierFS,3);
% tmp_I is a decN1*1 vector containing betas for ALL input voxels (same order as in decN1)
     x = [tmp_I decN1']; 
     y = sortrows(x,1);
     decN2 = y(size(y,1)-filterOptions{fo}{4}+1: size(y,1),2)';
     clear Mpsc_red classifierFS tmpa tmpb tmp_I x y;
    else
     decN2 = decN1;
    end

% -----------generating tal file and image
% decN2 is an index to selected voxels

% -----------CLUSTERING------

    for co=1:length(clusterOptions) % cycle for nvoxels/clusteroptions options
     disp(['----Clustering subject ' char(subjects(s)) ' option ' ...
           int2str(co)]);
     if(strcmp(clusterOptions{co}{1}, 'Yes')) % perform clustering
       disp('Performing clustering');
       Nclust = clusterOptions{co}{2};
 % modify the matrix indeces to reflect the voxel size
      voxel_dim=[3.125 3.125 6]';
      mm_coord = common_mask(decN2,:).*repmat(voxel_dim,1,size(decN2,2))';
      cl_ind=kmeans(mm_coord, Nclust,'EmptyAction','singleton','replicates',5);
      clear mm_coord;
% keyboard
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
       elseif (size(tmp_ind,1) == 1)
        clustertrainExamples(:,i) = x(tmp_ind,:)';
        clustertestExamples(:,i) = y(tmp_ind,:)';
       else   %empty cluster - just drop - not so fast...
         disp(['Empty cluster ' int2str(i)]);
       end
      end
      clear x y;

% Possibly, normalize the values again (across clusters) - not now
% save a list of coordinates of voxels in clusters, if requested
      if(strcmp(clusterOptions{co}{3}, 'saveCluster')) 
       tmp_colToCluster = zeros(1,size(Mpsc_mask,2));
       tmp_colToCluster(decN2) = cl_ind;
% Generate a name for the variable that includes indeces of all options:
% e.g. colToCluster1_1_2_2_2  - last digit will be presentation (fold)
% The meanings of indeces in the variable name are:
% foldOption_classifyTask_filterOption_clusterOption_fold#
       tmp_str = ['colToCluster' num2str(foldc) '_' num2str(ct) '_' num2str(fo) '_' ...
             num2str(co) '_' num2str(p)];
       eval([tmp_str ' = tmp_colToCluster;']);
       outf = sprintf('./WithinSubject/%s/%s.mat', ...
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

% ------RE-NORMALIZATION------
% re-normalizing the data before the classification (standardize voxels)
% separately for test and train

     reducedtrainExamples = reducedtrainExamples - ...
         repmat(mean(reducedtrainExamples),size(reducedtrainExamples,1),1);
     reducedtrainExamples = reducedtrainExamples./ ...
         repmat(std(reducedtrainExamples),size(reducedtrainExamples,1),1);
     reducedtestExamples = reducedtestExamples - ...
         repmat(mean(reducedtestExamples),size(reducedtestExamples,1),1);
     reducedtestExamples = reducedtestExamples./ ...
         repmat(std(reducedtestExamples),size(reducedtestExamples,1),1);
%keyboard
% -----------CLASSIFICATION------ 


     for c=1:length(classifierStrings)  % cycle through classifiers
      disp(['----Classifying subject ' char(subjects(s))]);
      classifierString=classifierStrings{c};
      [classifier]=trainClassifier(reducedtrainExamples, trainLabels, classifierString);
      [predictions]=applyClassifier(reducedtestExamples, classifier);
      [results,predictedLabels,trace]=summarizePredictions(predictions, ...
				  classifier,'averageRank', testLabels);

% if needed, save the predicted and actual labels here
      %disp('Correctly predicted words or categories (ignore 0):')
      %disp(sprintf('%d ',char(unique((predictedLabels==testLabels) .* ...
      %                               testLabels))));

%%% RANKLIST ___ fill in the data
if (selection_set && saveRankAndConfusion && ...
    fo == filterOptions_selected && ...
    co == clusterOptions_selected   && c == classifierStrings_selected && ...
    foldc == foldOptions_selected )
 

 if strcmp(classifyTask,'Categories')
  MeasureEx_Cat=[MeasureEx_Cat; results{2}];
  trueLabels_Cat=[trueLabels_Cat; testLabels];   
 end
 if strcmp(classifyTask,'Words')
  rankPredictionList=[rankPredictionList;trace{1}];
  trueLabels=[trueLabels;testLabels];
  MeasureEx=[MeasureEx ;results{2}];         
 end  
 if strcmp(classifyTask,'CategorySignatures')
  MeasureEx_CatSig=[MeasureEx_CatSig; results{2}];
  trueLabels_CatSig=[trueLabels_CatSig; testLabels]; 
 end
end
%%% RANKLIST ___

      
      
% new in V3.0
% if requestsd and appropriate, keep voxel coords for a Sum_of_folds file
% Are we in the "selected" set of parameters?
     if (selection_set && ...
         ct == classifyTaskList_selected && fo == filterOptions_selected && ...
         co == clusterOptions_selected   && c == classifierStrings_selected ...
         && foldc == foldOptions_selected )
%keyboard 
  AlltestLabels = [AlltestLabels;testLabels];
  AllTrace = [AllTrace; trace{1}];	

      if saveSumImage  % add info for the Sum_of_folds.img       
       XYZ =  common_mask(decN2,:); % grid coords
% MNI coords for the fold
       XYZmm_fold = [transformToXYZmm(1:3,:)*[XYZ ones(size(XYZ,1),1)]']'; 
% MNI coords for the sum of all folds
       XYZmm_sum = [XYZmm_sum; XYZmm_fold];
      end
      if savePredictedProbabilities      
% to obtain probabilities for each category:
% exp(predictions(1,:))./sum(exp(predictions(1,:)))
% average multiple exemplar predictions (if any) here
% this can happen only for Categories
% convert each distribution into a z-score
       if size(predictions,1) > size(plogPred,1)
         for m=1:exp_category_number
           z = mean(predictions(find(testLabels == m),:), 1);
           plogPred(m,:,p) = (zscore(z'))';
        end
       else  
         plogPred(:,:,p) = (zscore(predictions'))';
       end
      end
     end
     
% fill in the accuracy matrix
      racc=1-results{1};
      acc=sum(predictedLabels==testLabels)/length(testLabels);
      acc_matrix(acc_matrix_ind,:) = [p fo co c acc racc];
      acc_matrix_ind = acc_matrix_ind + 1;
      clear reducedtrainExamples reducedtestExamples;     
      disp(sprintf('Fold Rank Accuracy was %4.3f', racc));
      disp(' ');
%      keyboard
     end % classify+
    end % clusterOptions+
   end % filterOptions+
  end % cycle through folds+
% compute and save average accuracies
% save matr acc_matrix;
  for fo = 1:size(filterOptions,2)     % filter list
   for co=1:length(clusterOptions)     % cluster list
    for c=1:length(classifierStrings)  % classifier list
     x1=acc_matrix(find(acc_matrix(:,2)==fo),:);
     x2=x1(find(x1(:,3)==co),:);
     x3=x2(find(x2(:,4)==c),:);

     acc_m = mean(x3(:,5)); 
     racc_m = mean(x3(:,6));
     fprintf(fid,'\n%s\t%s\t%s\t%s\t%d\t%s\t%d\t%s\t%d\t%s\t%4.3f\t%4.3f',char(subjects(s)), ...
          [char(foldOptions{foldc}{1}) '_' int2str(foldOptions{foldc}{2})],...
          classifierString,filterOptions{fo}{1},filterOptions{fo}{2},...
          filterOptions{fo}{3},filterOptions{fo}{4}, clusterOptions{co}{1}, ...
          clusterOptions{co}{2}, classifyTaskList{ct}, acc_m,racc_m);         
    end
   end
  end
clear  acc_matrix x1 x2 x3  acc_m  racc_m
 end % fold options list loop+
 end % task list loop+
 fprintf(fid,'\n');
 fclose(fid);

% compute and save a "sum" of selected images for all folds
% REMOVED THIS

 if selection_set && savePredictedProbabilities
% generate an averaged table of each "exemplar" probability
% the table should be read BY ROWS only - 
% save an averaged table of predictions - from predictions
  prTable = mean(plogPred,3);
  fid = fopen(sprintf('./WithinSubject/%s/%s_zpTable.txt', ...
		       groupName_mask,char(subjects(s))),'w');

% Words or categories?
  if strcmp(char(classifyTaskList{classifyTaskList_selected}),'Words')
% Note: word "labels" here are: wordLabels=((C(:,1)-2)*numwords)+C(:,2)
% 1...5    - 1-5 for cat 1
% 6...10   - 1-5 for cat 2
% 56...60  - 1-5 for cat 12
   for i=1:exp_word_number
    for j = 1:exp_word_number-1
      fprintf(fid,'%6.2f\t',prTable(i,j));
    end
     fprintf(fid,'%6.2f\n',prTable(i,exp_word_number));
   end
  else
   for i=1:exp_category_number
     for ii=1:exp_category_number-1
      fprintf(fid,'%6.2f\t', prTable(i,ii));
     end
     fprintf(fid,'%6.2f\n', prTable(i,exp_category_number));   
   end
  end
  fclose(fid);
 end

 %%% RANKLIST ___ print header for confusion matrix    

if selection_set && saveRankAndConfusion && ...
   strcmp(char(classifyTaskList{classifyTaskList_selected}),'Words')   
  fid_con = fopen(sprintf('./WithinSubject/%s/%s_Confusion_%s.txt', ...
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
    fid_con = fopen(sprintf('./WithinSubject/%s/%s_Confusion_%s.txt', ...
            groupName_mask, char(subjects(s)),datestr(now,'yyyy-mm-dd')),'w');    
    fprintf(fid_con,'\nTrue Label\t');
    fprintf(fid_con,'%d\t',1:exp_word_number);
    for fp=1:length(trueLabels)
      fprintf(fid_con,'\n');
      fprintf(fid_con,'%s\t',sortedSixtyWords{trueLabels(fp)});
      fprintf(fid_con,'%s\t',sortedSixtyWords{rankPredictionList(fp,:)});
    end
    fprintf(fid_con,'\n');
    fclose(fid_con);
   end
   if strcmp(char(classifyTaskList{ct}),'CategorySignatures')
    %?????
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
         'rankAccWords','rankAccCat','rankAccCatSig','AlltestLabels','AllTrace'); 
%   save(outfConfusion,'plogPred', '-APPEND');
%   save(outfConfusion,'pPred', '-APPEND');
  end
end
%%% RANKLIST ___   

 end % mask loop
end % subject loop+

fclose all;
close all;
