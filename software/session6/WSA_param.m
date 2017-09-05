% verbs within subject analyses ( WSA_main.m V6) works with any number of cat and exemplar
% Template parameter setup
% Parameters for running experiment. 
% Change ONLY this file to modify experiment parameters. 

mFile='detrend.MPSC_wraf336_ALL.mat'

% comment out the following variable to use original C map.
%newCMatFile = '/usr/cluster/projects2/verbs/ClassificationResults/CposNegReceiversOnly.txt' 
% This text file has 3colums corresponding to 'C' matrix [N X 3] double array ; [ catid, exempalrID, presID] Catid should be continuous starting from 2 and should have equal number of Exemplars. see ccbiMaskAndMapMpsc function for details. use catId = -1 for the exemplars to be excluded.

% To do classification with a limited sets of items, 
% provide the subset of items using their aplicable wordlables from C matrix
% ( WL would be different if C matrix is applied)
%  not applicabel to the category signature classification
% rank and predicted probabilities should not be used if this subset is used.
% subsetTrainAndTestTrialsByWLs = [1:10];

% this line reflects the directory your data is in 
%experiment= 'lab_85_429_2014' REMOVED THIS
mDir='normalMpsc'

% name of the subject group (actually, the set of common parameters
% corresponding to a specific param file) 
groupName ='WSA_main_results' 

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
% results are saved in WithinSubject/groupname/All for 'All',
% in WithinSubject/groupname for '' (for backward compatibility)
% and in WithinSubject/groupname/Fusiform for 'Fusiform' etc.
%
%maskList = {'Occipital'}; % 'No_Occipital' 'Frontal' 'Temporal' 'Parietal' 'Fusiform' ...
           % 'Occipital'}

% List of all subjects to classify

%subjects={}; 
subjects = {'04647B'}; 

% for within subject analysis, report only averages across folds

% New in V2.0:
% folds are defined as {{'LeaveFew', N}}
% only one setting is allowed! (no cycling through the foldOptions)
% N specifies how many presentations should be left for testing
% N=1 is equivalent to the old "leave one out" style
foldOptions = {{'LeaveFew',2}}
%foldOptions = {{'LeaveFew',1}}%,...
%               {'LeaveFew',2} ...
%             }

% filtering parameters - applied sequentially
% First filter - either 'Replica' or none
% Second filter - either 'LR' or none

%filterOptions = {{'Replica', 50, 'none', 0},...
%                 {'Replica', 80, 'none', 0},...
%                 {'Replica', 90, 'none', 0},...
%                 {'Replica', 100, 'none', 0},...
%                  {'Replica', 120, 'none', 0},...
%                  {'Replica', 150, 'none', 0},...
%                   {'Replica', 200, 'none', 0},... 
%                    {'Replica', 300, 'none', 0},...
%                     {'Replica', 400, 'none', 0},...
%                     {'Replica', 500, 'none', 0}}

%filterOptions = {{'Replica', 120, 'none', 0}}

% clusterOptions:
% - 1: 'Yes' (i.e. "cluster") or 'none'
% - 2: Number of clusters to create
% - 3: 'saveCluster' (to save the locations of all voxels and clusters) or 'none'
% NOTE - here clustering corresponds to "kmeanSpatial"
%      - we are taking the mean of all voxels in a cluster as output
clusterOptions = {{'none', 0}};
%clusterOptions = {{'Yes', 35, 'saveCluster'}}
%clusterOptions = {{'Yes', 35, 'no'}}
%clusterOptions = {{'none', 0}...
%		  {'Yes', 35, 'no'}}

% parameters for classifiers.  
classifierStrings={'nbayesPooled'}
%parameters - {'svmlight','logisticRegression','BagBoost','knn','nbayes','nbayesPooled','svmlight'}

% known to work -- nbayes, nbayesPooled, logisticRegression



% we can either try to predict the word people are looking at, the category
% of this word, or the category of an "averaged category signature"
classifyTaskList={'Words'}
%classifyTaskList={'Words', 'Categories'}
%classifyTaskList={'Words', 'Categories','CategorySignatures' }
%classifyTaskList={'CategorySignatures'}
%classifyTaskList={'Categories'}

% New in V3.0: special cases
% average all words within a category/presentation everywhere
% NOTE: that changes the feature selection
catSignatureEverywhere = 0;        

% Specify a single set of parameters for the options below:
classifyTaskList_selected = 1; 
filterOptions_selected = 1;
clusterOptions_selected = 1;
classifierStrings_selected = 1;
foldOptions_selected = 1;
% Save the sum of selected voxels as an image:
saveSumImage = 0;                  % 1 - save, 0 - do not save

% Save the averaged log-probabiliies of all predictions:
savePredictedProbabilities = 1;    % 1 - save, 0 - do not save

% new in V3.2 - saving rank accuracies per item and confusion matrix
% confusion matrix can be computed only for words, if selected
% rank accuracies are saved for all specified items
% (word,cat, catSig) REGARDLESS of classifyTaskList_selected value
saveRankAndConfusion = 1;          % 1 - save, 0 - do not save
