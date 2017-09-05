function [feature_matrix, words, features] = setup_cree_mcrae_mod(encoding, WORDS);

if strcmp(encoding, 'bin'),
	[M H C R] = tablescan('./feature_norming.xls');
	columns = {'concepts', 'bin', 'br', 'wb'};

	k = find(strcmp(columns, encoding));
	words = WORDS;
	features = unique(C{k});
	feature_norms = zeros(length(words), length(features));

	for i = 1:length(M),
		concept = C{H('Concept')}{i};
		feature = C{k}{i};

		[temp IA IB]    = intersect(WORDS, concept);
		[temp2 IA2 IB2] = intersect(features, feature);

		feature_norms(IA, IA2) = feature_norms(IA, IA2) + 1;
	end

	temp = find(sum(feature_norms, 2) == 0);
	feature_norms(temp, :) = ones(length(temp),size(feature_norms,2)) * NaN;

	feature_matrix = feature_norms;

	return;
end

% Cree & McRae Features

[concept feature count] = textread(sprintf('./count.%s', encoding), '%s %s %d', ...
		'headerlines', 1);

concepts = unique(concept)';
features = unique(feature)';

feature_norms = zeros(length(concepts), length(features));
for i = 1:length(concept),
	c = find(strcmp(concepts, concept{i}));
	f = find(strcmp(features, feature{i}));

	feature_norms(c, f) = count(i);
end

% Load ones for WORDS

feature_matrix = NaN * ones(length(WORDS), length(features));
for w = 1:length(WORDS),
	c = find(strcmp(concepts, WORDS{w}));
	if c,
		feature_matrix(w,:) = feature_norms(c, :);
	end
end

words = WORDS';
