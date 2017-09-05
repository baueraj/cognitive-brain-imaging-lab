function [W, eY, R2, RESULT] = regression_model(X, Y, varargin)

% ------------------------------------------------
% Options

mode = 'lscov';
lambda = 0.5;
intercept = 1;
normalizeX = 1;
stepwise = 0;
X2 = X;
Y2 = Y;

args = varargin;
for i = 1:2:length(args),
	eval(sprintf('%s = args{i+1};', args{i}));
end

if exist('param', 'var'),
	if isfield(param, 'mode'), mode = param.mode; end
	if isfield(param, 'lambda'), lambda = param.lambda; end
	if isfield(param, 'intercept'), intercept = param.intercept; end
	if isfield(param, 'normalizeX'), normalizeX = param.normalizeX; end
end

if intercept,
	X  = [ones(size(X, 1),1) X ];
	X2 = [ones(size(X2,1),1) X2];
end

if normalizeX,
	X  = zscore(X);
	X2 = zscore(X2);
end

if stepwise > 0,
	all = 1:size(X,2);
	scores = [];

	[score selected] = max(scores');
	pool = setdiff(all, selected);

	j = 0;
	while length(selected) < stepwise,
		j = j + 1;

		scores(:,j) = repmat(NaN, size(scores,1), 1);
		for k = 1:length(pool),
			[W eY RESULT] = regression_model(X(:,[selected pool(k)]), Y, 'mode', mode, 'lambda', lambda, 'normalizeX', normalizeX, 'intercept', 0);
			scores(pool(k), j) = mean(RESULT.R2);
		end

		[score selected(j)] = max(scores(:,j));
		pool = setdiff(all, selected);
	end

	RESULT.SELECTED = selected;
	RESULT.SCORES = scores;
end

% ------------------------------------------------
% Fitting

if strcmp(mode, 'matrix'),

% hack
%cols = sum(X) > 0;
%X = X(:,cols);
%X2 = X2(:,cols);

W = (X' * X) \ (X' * Y);
eY = X2 * W;

elseif strcmp(mode, 'multivariate'),

alpha = 0.05;

for i = 1:size(Y,2),
	[REG.B{i} REG.BINT{i} REG.R{i} REG.RINT{i} REG.STATS{i}] = regress(Y(:,i), X, alpha);
end

W = cell2mat(REG.B);
eY = X2 * W;

elseif strcmp(mode, 'lscov'),

W = lscov(X, Y);
eY = X2 * W;

elseif strcmp(mode, 'lsreg'),

W = lsregularize(X, Y, 'l2', lambda);
eY = X2 * W;

elseif strcmp(mode, 'gp'),

[net eY] = multivariate_gp(Y, X, Y2, X2);

elseif strcmp(mode, 'bayes'),

K = 1; A = 2;
names = {'K', 'A'}

N = length(names)

ncases = size(X, 1);
E = cell(N, ncases);
for j = 1:size(E,2),
	E{K,j} = X(j, 2:end)';
	E{A,j} = Y(j, :)';
end

dnodes = [];
cnodes = setdiff(1:N, dnodes);
onodes = [K A];
hnodes = setdiff(1:N, onodes);

ns = zeros(1,N);
for j = cnodes,
	ns(j) = length([E{j,2}]);
end

dag = zeros(N);
dag(K, A) = 1;

bnet = mk_bnet(dag, ns, ...
		'names', names, ...
		'discrete', dnodes, ...
		'observed', onodes)

bnet.CPD{K} = gaussian_CPD(bnet, K, ...
		'tied_cov', 1, 'cov_type', 'diag');

bnet.CPD{A} = gaussian_CPD(bnet, A, ...
		'tied_cov', 1, 'cov_type', 'diag');

engine = jtree_inf_engine(bnet);
[bnet2, ll] = learn_params_em(engine, E, 20);

else,

fprintf('unrecognized model\n');

end

% ------------------------------------------------
% Result

if nargout > 2,

	% eY is actually eY2
	% Y  is actually Y

	Y = Y2;
	Y_mean = repmat(mean(Y), size(Y, 1), 1);

	SST = sum((  Y - Y_mean ).^2);
	RSS = sum(( eY - Y_mean ).^2);
	SSE = sum((  Y - eY     ).^2);

	%R2 = RSS ./ SST;
	%mean(R2)

	R2 = 1 - SSE ./ SST;
	%mean(R2)

	%R = correlate(Y, eY, 'cols');
	%R2 = R.^2;
	%mean(R2)

	%STATS = cell2mat(REG.STATS');
	%R2 = mean(STATS(:,1));
	%mean(R2)

	RESULT.R2 = R2;

	R2 = mean(R2);
end
