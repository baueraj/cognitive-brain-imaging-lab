function Z = mynormalize(X, mode);

if nargin < 2,
	mode = 'rows';
end

[m n] = size(X);

if strcmp(mode, 'rows');
	Z = ( X - repmat(mean(X,2), 1, n) ) ./ ...
		repmat(std(X,0,2), 1, n);

elseif strcmp(mode, 'cols'),
	Z = ( X - repmat(mean(X), m, 1)   ) ./ ...
		repmat(std(X), m, 1);

elseif strcmp(mode, 'mat'),
	Z = ( X - mean( reshape(X,1,[]) ) ) /  ...
		std( reshape(X,1,[]) );

elseif strcmp(mode, 'subtractMean'),
	Z = X - repmat(mean(X,2), 1, n);

elseif strcmp(mode, 'between01'),
	Z = (X - repmat(min(X,[],2), 1, n)) ./ repmat(range(X,2), 1, n);

elseif strcmp(mode, 'toProb'),
	Z = X ./ repmat(sum(X,2), 1, n);

elseif strcmp(mode, 'toUnitLength'),
	for w = 1:size(X,1),
		data = X(w, :);
		%data = sqrt(data);
		if sum(data) == 0,
			Z(w,:) = data;
		else,
			Z(w,:) = data ./ sqrt(dot(data,data));
		end
	end

else
	Z = X;

end
