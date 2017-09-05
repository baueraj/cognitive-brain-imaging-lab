if strcmp(expt.model_set{m}, 'svm'),
	acc_58_2_within(m,s) = NaN;
	acc_58_2_within2(m,s,:,:) = NaN;
	return;
end

[M H] = transformIDMtoM({Ss{s}}, {masks{s}});

[M0 H0] = transformM(M, H, ...
		'row_type', '[W]', ...
		'expt_rows', expt.rows);

% ------------------------------------------------

Y = zeros(num_word);
eY = zeros(num_word);

for w1 = 1:num_word,
	for w2 = w1+1:num_word,
		test = [w1; w2];
		train = setdiff(1:num_word, test);

		% ------------------------------------------------

		load(sprintf('%s/normalMpsc/%s/ReplicableVoxels/LV2_%d_%d.mat', expt.data_path, Ss{s}.subject, w1, w2));
		[temp I] = sort(R * -1, 2);
		[M H] = transformM(M0, H0, ...
				'col_cases', I(1:expt.num_voxels), ...
				'feature_matrix', eval(expt.regression_opt_set{m}));
				eval_header;

		% ------------------------------------------------

		F = M(:, K_feature);
			if exist('L', 'var'), F = F(:,L); end
			F = mynormalize(F, expt.normalization);
		X = M(:,X_mask) - repmat(mean(M(:,X_mask)), size(M(:,X_mask),1), 1);

		K = F(train, :);
		A = X(train, :);

		K2 = F(test, :);
		A2 = X(test, :);

		% ------------------------------------------------
		% Classification

		[W eA2] = regression_model(K, A, 'mode', expt.regression_set{m}, 'lambda', expt.lambda, ...
				'X2', K2, 'normalizeX', 0);

		Y(w1,w2) = w1;
		Y(w2,w1) = w2;

		% Kai-min's

		%S = 1 - squareform(pdist([eA2; A2], 'cosine'));
		%eY(w1,w2) = test( (S(1,3) < S(2,3)) + 1 );
		%eY(w2,w1) = test( (S(1,4) < S(2,4)) + 1 );
		
		% Tom's

		S13 = cosineSimilarity(eA2(1,:), A2(1,:));
		S23 = cosineSimilarity(eA2(2,:), A2(1,:));
		S14 = cosineSimilarity(eA2(1,:), A2(2,:));
		S24 = cosineSimilarity(eA2(2,:), A2(2,:));

		if S13 + S24 > S23 + S14,
			eY(w1,w2) = w1;
			eY(w2,w1) = w2;
		elseif S13 + S24 == S23 + S14,
			eY(w1,w2) = w1;
			eY(w2,w1) = w1;
		else
			eY(w1,w2) = w2;
			eY(w2,w1) = w1;
		end
	end
end

acc_58_2_within2(m,s,:,:) = double(Y == eY);

acc_58_2_within(m,s) = mean(Y(find(Y)) == eY(find(eY)));
