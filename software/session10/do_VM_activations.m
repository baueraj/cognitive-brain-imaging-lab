clear all

expt.name = './voxelwiseModel';
expt.result_dir = sprintf('%s_results', expt.name);
expt.subjects = '04124B';

if exist(sprintf('%s/workspace_%s.mat', expt.result_dir,expt.subjects));
    load(sprintf('%s/workspace_%s.mat', expt.result_dir,expt.subjects));
else    
    disp('You must run "do_VM_accuracy.m" script again before running this script')
end

promptStudent = ['Please type, all lower-case, one object concept whose observed and predicted activation patterns will be generated; then press Enter/Return:' '   '];
studentInput = input(promptStudent,'s');
word_list = find(strcmp(expt.words, studentInput));

if isempty(word_list)
    disp('Object concept not found; check your spelling')
    return;
end

if strcmp(expt.model_set{m}, 'svm'),
	R2s(m,s) = NaN;
	return;
end

%load(sprintf('%s/ReplicableVoxels/%s/self.mat', expt.data_path, Ss{s}.subject));
load(sprintf('../normalMpsc/%s/ReplicableVoxels/self.mat', Ss{s}.subject));
masks{s}.selfR = R;

[M0 H0] = transformIDMtoM({Ss{s}}, {masks{s}}, ...
		'cluster_str', 'masks{s}.allMask', 'score', R, ...
		'cutoff', expt.num_voxels);

[M H] = transformM(M0, H0, ...
		'row_type', '[W]', ...
		'expt_rows', expt.rows, ...
		'feature_matrix', eval(expt.regression_opt_set{m}));
		eval_header;

% ------------------------------------------------

K = M(:, K_feature);
	if exist('L', 'var'), K = K(:,L); end
	K = mynormalize(K, expt.normalization);
A = mynormalize(M(:,X_mask), 'cols');

[W eA R2 RESULT] = regression_model(K, A, 'mode', expt.regression_set{m}, 'lambda', expt.lambda);

% ------------------------------------------------

%R = correlate(eA, A, 'cols');

R2 = RESULT.R2; 

N = size(A,1);
P = size(A,2);
R2_adjusted = 1 - (1 - R2) * (N - 1) / (N - P - 1);

k = size(K,2);
RSS = mean((A - eA).^ 2);
AIC  = 2 * k + N * (log(2 * pi * RSS / N) + 1);
AIC2 = 2 * k + N * log(RSS / N);

% ------------------------------------------------

%Rs(m,s) = fisherr(mean(fisherz(R)));
R2s(m,s) = mean(R2);
R2s_adjusted(m,s) = mean(R2_adjusted);
AICs(m,s) = mean(AIC);
AIC2s(m,s) = mean(AIC2);

%if ~expt.plot_activation,
%	return;
%end

% ------------------------------------------------
% 2. Voxels

[M H] = transformIDMtoM({Ss{s}}, {masks{s}});

cluster = ones(1, Ss{s}.meta.nvoxels);
score = R;
[M H XLabels] = transformM(M, H, ...
		'clusters', cluster, 'score', score, ...
		'cutoff', expt.num_voxels);
		eval_header;

[M H] = transformM(M0, H0, ...
		'row_type', '[W]', ...
		'expt_rows', expt.rows, ...
		'feature_matrix', eval(expt.regression_opt_set{m}));
		eval_header;

fprintfile(log_file, 1, '\n');
for k = keys(XLabels),
	%[i1 i2 extents matches tokens] = regexp(k{:}, 'C([0-9]+)_V([0-9]+)');
	%v = eval(tokens{:}{2});
	%x = XLabels(k{:});

	[s f tokens] = regexp(k{:}, 'C([0-9]+)_V([0-9]+)');
	v = eval(k{:}(tokens{:}(2,1):tokens{:}(2,2)));
	x = XLabels(k{:});

	coord = Ss{s}.meta.colToCoord(v,:);

	l = masks{s}.lobeMask(v);
	if l == 0, lobe = 'N/A';
	else,      lobe = LOBES{l};
	end

	r = masks{s}.roiMask(v);
	if r == 0, roi = 'N/A';    func = 'N/A';
	else,      roi = ROIS{r}; func = FUNCTIONS{find(ROI_FUNC(r,:))};
	end

	rois{x} = roi;
	voxel_order(x) = r;
	
	voxels{x} = sprintf('V%d (%s)', v, roi);
	masks{s}.voxels(x) = v;

	%fprintfile(log_file, 1, 'subject %s, voxel %3d, score %.2f, coord %2d %2d %2d, lobe %s, roi %s, func %s\n', ...
	%	Ss{s}.subject, x, score(v), ...
	%	coord(1), coord(2), coord(3), ...
	%	strresize(lobe,13), strresize(roi, 10), func);
end

% ------------------------------------------------
% 3. Activation

K = M(:,K_feature);
A = M(:,X_mask);

[W eA R2 RESULT] = regression_model(K, A, 'mode', expt.regression_set{m}, 'lambda', expt.lambda);

%word_list = [HOUSE COW];
%word_list = expt.rows;

img_list = {'A', 'eA'};
img_list_nameAppend = {'observed', 'predicted'};

for w = word_list,
	for i = img_list,

		img = eval(i{:});
		img = mynormalize(img, 'cols');

		activationMask = zeros(1, Ss{s}.meta.nvoxels);
		activationMask(masks{s}.voxels) = img(find(expt.rows == w), :);

		cluster = zeros(1, Ss{s}.meta.nvoxels);
		cluster(masks{s}.voxels) = 1;

                nameAppendInd = char(img_list_nameAppend(find(strcmp(img_list,i{:}))));
		plot_mask(Ss{s}, masks{s}, 'value', activationMask, ...
				'mode', 'xjview', ...
				'img', sprintf('%s/%s.%s.%s.img', expt.result_dir, Ss{s}.subject, expt.words{w}, nameAppendInd), ...
				'writeOnly', 1);

		%plot_mask(Ss{s}, masks{s}, 'value', activationMask, 'cluster', cluster, 'planes', 7);
	end
end

disp(['Done generating observed and predicted for ' studentInput])