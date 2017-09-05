%warning off MATLAB:nearlySingularMatrix;
%warning off MATLAB:singularMatrix;
%warning off;

% load the spm_defaults so that we use appropriate flip setting to read the image.
%global defaults;
%if(isempty(defaults))
	%spm_defaults;
%end

clear all

%% MODIFY THIS
%addpath(genpath('/usr/cluster/projects2/mjclass2013/lab_85_429_2014'))
%addpath /usr/cluster/software/ccbi/neurosemantics/kkchang/src;
init_mod;

% ------------------------------------------------
% Experiment

expt.name = './voxelwiseModel';

% Words and Pictures

expt.description = 'wp';

pwd_dir = pwd;
expt.data_path = sprintf('%s/..', pwd_dir);
expt.subjects = {'04124B'};

expt.rows = [1 2 3 4 5 11 12 13 14 18 19 21 22 23 24 25 26 27 28 29 30 31 33 34 36 37 39 40 42 44 46 47 48 50 51 52 53 54 55 56 58 59 60];

% ------------------------------------------------
% Model

expt.num_voxels = 120;

expt.evaluation_set = {'acc_58_2_within'};

expt.model_set =          {'br'};
expt.regression_set =     {'lsreg'};
expt.regression_opt_set = {'feature_norms_br'};
expt.classifier_set =     {'knn'};
expt.classifier_opt_set = {{1,'cosine'}};

expt.normalization = 'toUnitLength';
expt.lambda = 0.5;

%expt.corpus_feature = 'inanimatePlusSensoryVerbsMult5plus';

expt.plot_activation = 0;
expt.step_wise = 0;
expt.feature = 0;

expt.result_dir = sprintf('%s_results', expt.name);

%if exist(expt.result_dir)
    %    rmdir(expt.result_dir, 's');
    %end

%mkdir(expt.result_dir);

if ~exist(expt.result_dir)
    mkdir(expt.result_dir);
end

expt

% ------------------------------------------------
% Run

run_expt_WSA58_2_only;