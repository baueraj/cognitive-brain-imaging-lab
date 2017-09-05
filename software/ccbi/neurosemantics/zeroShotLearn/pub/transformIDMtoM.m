function [M, H, XLabels, V] = transformIDMtoM(Ss, masks, varargin);

% ------------------------------------------------
% Options

Ztransform = 1;

cutoff = 120;
averageOverCluster = 0;

args = varargin;
for i = 1:2:length(args),
	eval(sprintf('%s = args{i+1};', args{i}));
end

% ------------------------------------------------
% Load data

Mpsc = [];
C1 = [];
C2 = [];
C3 = [];

XLabels = hashtable;
V = [];

for s = 1:length(Ss),
	S = Ss{s};

	% D

	D = cell2mat(S.data);
	if Ztransform, D = mynormalize(D); end;

	% X, cluster, score

	if exist('cluster_str', 'var'), cluster = eval(cluster_str); end;
	if exist('score_str', 'var'), score = eval(score_str); end;

	if exist('cluster', 'var'),
		X = [];
		x = 0;
		
		for c = setdiff(unique(cluster), 0),
			I2 = find(cluster == c);
		
			if exist('score', 'var'),
				[temp I] = sort(score(I2) * -1, 2);
				if cutoff < 1, cutoff = floor(length(I) * cutoff); end;
				I2 = I2( I(1:cutoff) );
			end
		
			if averageOverCluster,
				X = [X mean( D(:,I2), 2 )];
				x = x + 1;
				XLabels(sprintf('S%d_C%d', s, c)) = x;
			else,
				X = [X D(:,I2)];
				for v = 1:length(I2),
					x = x + 1;
					XLabels(sprintf('S%d_C%d_V%d', s, c, I2(v))) = x;
					V(x) = I2(v);
				end
			end
		end
	else,
		X = D;
		for x = 1:size(X,2),
			XLabels(sprintf('S%d_V%d', s, x)) = x;
		end
	end
	
	[m n] = size(X);

	% Y

	Y1 = ones(m,1) * s; % subjects
	Y2 = (([S.info.cond] - 2) * (length(unique([S.info.word_number]))) + [S.info.word_number])'; % exemplar
	Y3 = [S.info.epoch]'; % trial

	% Mpsc and C

	Mpsc = [Mpsc; X];
	C1 = [C1; Y1];
	C2 = [C2; Y2];
	C3 = [C3; Y3];
end

% ------------------------------------------------
% M, H

[M H] = MakeMH('X_mask', Mpsc, 'Y_subject', C1, 'Y_exemplar', C2, 'Y_trial', C3);
