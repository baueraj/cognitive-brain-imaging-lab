function [M, H, XLabels, voxels] = transformM(M, H, varargin);

averageOverCluster = 0;

Mpsc = M(:, H('X_mask'));
C1   = M(:, H('Y_subject'));
C2   = M(:, H('Y_exemplar'));
C3   = M(:, H('Y_trial'));

if ~isempty(H('K_feature')),
	K = M(C2, H('K_feature'));
else,
	K = [];
end

args = varargin;
for i = 1:2:length(args),
	eval(sprintf('%s = args{i+1};', args{i}));
	
	if strcmp(args{i}, 'col_cases'),
		cases = col_cases;
		Mpsc = Mpsc(:, cases);

	elseif strcmp(args{i}, 'row_cases_str'),
		cases = eval(row_cases_str);
		Mpsc = Mpsc(cases, :);
		if ~isempty(C1), C1 = C1(cases); end;
		if ~isempty(C2), C2 = C2(cases); end;
		if ~isempty(C3), C3 = C3(cases); end;

	elseif strcmp(args{i}, 'row_cases'),
		cases = row_cases;
		Mpsc = Mpsc(cases, :);
		if ~isempty(C1), C1 = C1(cases); end;
		if ~isempty(C2), C2 = C2(cases); end;
		if ~isempty(C3), C3 = C3(cases); end;

	elseif strcmp(args{i}, 'row_type'),
		subjects = unique(C1);
		words = unique(C2);

		if strcmp(row_type, '[W]'), % [W] by average over subjects, trials
			X = [];
			Y = [];
			for w = 1:length(words),
				X = [X; mean(Mpsc( C2==words(w), : ), 1)];
				Y = [Y; words(w)];
			end
			Mpsc = X;
			C1 = [];
			C2 = Y;
			C3 = [];

		elseif strcmp(row_type, '[S x W]'), % [S x W] by average over trials
			X = [];
			Y = [];
			for s = 1:length(subjects),
				for w = 1:length(words),
					X = [X; mean(Mpsc(and(C1==subjects(s), C2==words(w)),:), 1)];
					Y = [Y; subjects(s) words(w)];
				end
			end
			Mpsc = X;
			C1 = Y(:,1);
			C2 = Y(:,2);
			C3 = [];
		end

	elseif strcmp(args{i}, 'expt_rows'),
		cases = find(ismember(C2, expt_rows));
		Mpsc = Mpsc(cases,:);
		if ~isempty(C1), C1 = C1(cases); end;
		if ~isempty(C2), C2 = C2(cases); end;
		if ~isempty(C3), C3 = C3(cases); end;

	elseif strcmp(args{i}, 'expt_rows2'),
		cases = expt_rows2;
		Mpsc = Mpsc(cases,:);
		if ~isempty(C1), C1 = C1(cases); end;
		if ~isempty(C2), C2 = C2(cases); end;
		if ~isempty(C3), C3 = C3(cases); end;


	elseif strcmp(args{i}, 'feature_matrix'),
		K = feature_matrix(C2,:);

	end
end

if exist('selected', 'var'),
	Mpsc = Mpsc(:, selected);
end

if exist('clusters', 'var'),
	XLabels = hashtable;

	X = [];
	x = 0;

	for c = setdiff(unique(clusters), 0),
		I2 = find(clusters == c);
	
		if exist('score', 'var'),
			[temp I] = sort(score(I2) * -1, 2);
			if cutoff < 1, cutoff = floor(length(I) * cutoff); end;
			I2 = I2( I(1:cutoff) );
		end
	
		if averageOverCluster,
			X = [X mean( Mpsc(:,I2), 2 )];
			x = x + 1;
			XLabels(sprintf('C%d', c)) = x;
		else,
			X = [X Mpsc(:,I2)];
			for v = 1:length(I2),
				x = x + 1;
				XLabels(sprintf('C%d_V%d', c, I2(v))) = x;
				voxels(x) = I2(v);
			end
		end
	end

	Mpsc = X;
end

% ------------------------------------------------
% M, H

[M H] = MakeMH('X_mask', Mpsc, 'Y_subject', C1, 'Y_exemplar', C2, 'Y_trial', C3, 'K_feature', K);
