% semanic space between subject analyses - parameters
% parameters added so that it can be used with BSA_main_CrossCategory.m as well
% for BSA_main.m V5.0
% Parameters for running experiment. 
% Change ONLY this file to modify experiment parameters. 

mFile='detrend.MPSC_wraf336_ALL.mat'

% this line reflects the directory your data is in 
%experiment= 'lab_85_429_2014' REMOVED THIS
mDir='normalMpsc'

% new in V5.0 - NUmber of words independence from 60words
% new in V4.0 - masking
% the options currently are:
% maskList = {'' 'All' 'Frontal' 'Temporal' 'Parietal' 'Fusiform' ...
% 'Occipital' 'Cingulate' 'AntSingulate' 'PostSingulate' 'Subcortical'}
% expect to use just:
% maskList = {'All' 'Frontal' 'Temporal' 'Parietal' 'Fusiform' 'Occipital'}
%
% 'All' or '' means all voxels, 'Fusiform' - only fusiform voxels etc
% Any mask (except '' and 'All') can be prepended with 'No_'
% e.g. 'No_Fusiform' means "All voxels excluding Fisiform"
% results are saved in BetweenSubjects/groupname/All for 'All',
% in BetweenSubjects/groupname for '' (for backward compatibility)
% and in BetweenSubjects/groupname/Fusiform for 'Fusiform' etc.
%

% comment out the following variable to use original C map.
%newCMatFile = '/usr/cluster/projects2/quantity/ClassificationResults/NewCMatrices/digitWordsCombinationOnly.txt' 
% This text file has 3colums corresponding to 'C' matrix [N X 3] double array ; [ catid, exempalrID, presID] Catid should be continuous starting from 2 and should have equal number of Exemplars. see ccbiMaskAndMapMpsc function for details. use catId = -1 for the exemplars to be excluded.


% this file should have templateWordLabels variable (1X60) cell array of
% words corresponfding to the unique world label 1:NumberofWords
% for the new set of C matrix
templateWordLabelsMatFile='./60wordsExemplars.mat'; 

% To use this param files with Cross category classification function
% create a cross category calssification map (txt file)
% first col - WL as from C Mat,  second col - CategoryID ( new categoryID for the cross category - should start from 1 and should be continuous) third col - classID, label used as class label in clasification

% next two parameters are ignored by BSA_main.m , 
% for Cross Presentation Mode  , Quantity classification map is in /usr/cluster/projects2/quantity2/ClassificationResults/BSA/CrossPresModeQuantClassMap.txt
%CrossCategoryMap = '/usr/cluster/projects2/quantity2/ClassificationResults/CrossPresModeQuantClassMap.txt';
% do signature classification in crosscategory ? doSigClass =1 average the test items with same class and test the class signature
%doSigClass =0; % 0 or 1
% features are computed from all categories in training set.



%maskList = {'Occipital'} ;% 'No_Occipital' 'Frontal' 'Temporal' 'Parietal' 'Fusiform' 'Occipital'}

% List of all subjects to use
allsubjects={'04383B','04408B','04480B','04550B','04564B','04597B','04605B','04617B','04619B','04639B','04647B'};
% List of all subjects to classify
subjects = allsubjects;

% for between subject analyses, treat each subject prediction separately

% name of the subject group and pre-treated data file 
% (in BetweenSubjects/groupName directory)
groupName ='BSA_main_results'; 

% filtering parameters - applied sequentially
% First filter - either 'Replica' or none
    %filterOptions = {{'Replica',120,'none',0}};

% $$$     filterOptions = {{'Replica',500,'LR',300}, ...
% $$$                      {'Replica', 500, 'LR', 150}, ...
% $$$                      {'Replica', 500, 'LR', 100}, ...
% $$$                      {'Replica', 150, 'none', 0}, ...
% $$$                      {'Replica', 100, 'none', 0}, ...
% $$$ 
% $$$     }

% clusterOptions:
% - 1: 'Yes' (i.e. "cluster") or 'none'
% - 2: Number of clusters to create
% - 3: 'saveCluster' (to save the locations of all voxels and clusters) or 'none'
% NOTE - clustering corresponds to "kmeanSpatial"
%      - we are taking the mean of all voxels in a cluster as output
% $$$ clusterOptions = {{'none', 0},...
% $$$ 		  {'Yes', 30, 'saveCluster'},...
% $$$ 		  {'Yes', 35, 'saveCluster'},...
% $$$ }
clusterOptions = {{'none', 0}};


% parameters for classifiers. 
classifierStrings={'nbayesPooled'}

%classifierStrings={'svmlight','logisticRegression'}
%classifierStrings={'BagBoost'}
%classifierStrings={'knn','nbayes','nbayesPooled','logisticRegression','svmlight'}

% we can either try to predict the word people are looking at, the category
% of this word, or we can try to see if the word predicted as most likely
% is at least of the same category as the word they are looking at. 

classifyTaskList={'Words'}
%classifyTaskList={'Words', 'Categories'}
%classifyTaskList={'Words', 'Categories','CategorySignatures' }
%classifyTaskList={'CategorySignatures'}
%classifyTaskList={'Categories'}

% new in V3.0: special cases

% Specify a single set of parameters for the options below:
classifyTaskList_selected = 1; 
filterOptions_selected = 1;
clusterOptions_selected = 1;
classifierStrings_selected = 1;

% Save the sum of selected voxels as an image:
saveSumImage = 0;                  % 1 - save, 0 - do not save

% Save the averaged log-probabiliies of all predictions:
savePredictedProbabilities = 1;    % 1 - save, 0 - do not save

% new in V3.0 - saving rank accuracies per item and confusion matrix
% confusion matrix can be computed only for words, if selected
% rank accuracies are saved for all specified items
% (word,cat, catSig) REGARDLESS of classifyTaskList_selected value
saveRankAndConfusion = 1;          % 1 - save, 0 - do not save

