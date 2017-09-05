%$Header: /usr/cluster/projects2/cat_scripts/CVS/CCBI2.0/findLabels.m,v 1.22.2.8 2007/06/29 15:23:04 vlm Exp $
%
% VC - changed this into a simple parser   8/21/07
% added testFeatureLabels output (needed for leave2out averaging - cat)
% given an Mpsc, this function correctly labels it with the appropriate
% experiment information  and subsets 
% if you give it all the presetations, it will make labels for using the
% whole thing as the training data (appropriate for Bilingual)
% and with no presentations, it will make everything the test set (again
% useful). 
function [testExamples,trainExamples,testLabels,trainLabels, ...
	  trainFeatureLabels,testFeatureLabels,trainPresentations]=findLabels(Mpsc,C,CVtype,testP,classifyTask);
%unique(C(:,1))
%whos
%hack : remove instructions
%C=C(~(C(:,1)==5),:);
%Mpsc=Mpsc(~(C(:,1)==5),:);


% -------------- SET UP Parameters for Labeling --------

numwords=length(unique(C(:,2)));
wordLabels=((C(:,1)-2)*numwords)+C(:,2);
presentations=C(:,3);
trials=1:length(presentations);

% labelIndices is a mask of 0s (test set) and 1s (training set) for each example
% presentation - leave-one-block-out
% trial - leave-one-example-out
% all - same data for trainign and test
% language, modality - these are overwritten; both are defined in
% runCrossExperiment.  CVindex should be set to 1.
% meanModality - mean of each word for cross-modal
% subjects - leave-one-subject-out

if strcmp(CVtype,'presentations')
  labelIndices=~ismember(presentations,testP);
elseif strcmp(CVtype,'3+3')
   labelIndices=~ismember(presentations,testP);
elseif strcmp(CVtype,'trials')
  labelIndices=~ismember(trials,testP);
end

catLabels=C(:,1)-1;                                 % 2Categories or 4Categories

% ---------------------------------------- STEP 2: Assign Labels ---------------
% here you assign the proper labels depending on the classification task:
% for example if you want to do category classification you only want
% labels of which category the data belong to. After this, training and
% test sets are assigned according to cross-validation regime.
%
% featureLabels are used in replicability calculation: they correspond to
% the individual stimuli shown: so if we are still classifying categories,
% the featureLables retain information about the individual word which was
% presented on the screen. Because replicability is based on lining up
% images corresping to the same stimulus and then computing a measure, it
% would not make sense to throw away this information. 
% ------------------------------------------------------------------------------

if strcmp(classifyTask,'Categories') | strcmp(classifyTask,'CategorySignatures')| strcmp(classifyTask,'CategoriesPermutationTest')
  
  trainFeatureLabels=wordLabels(labelIndices);
  testFeatureLabels=wordLabels(~labelIndices);
  trainLabels=catLabels(labelIndices);
  testLabels=catLabels(~labelIndices);
elseif strcmp(classifyTask,'Words')    %???? check!
  trainFeatureLabels=wordLabels(labelIndices);
  testFeatureLabels=wordLabels(~labelIndices);
  trainLabels=wordLabels(labelIndices);
  testLabels=wordLabels(~labelIndices);
else
  error('Invalid Classification Task');
end

%% ----------- Step 3 : Split examples into train/test --------------------------------
trainExamples=Mpsc(labelIndices,:);
trainPresentations=presentations(labelIndices);
testExamples=Mpsc(~labelIndices,:);


