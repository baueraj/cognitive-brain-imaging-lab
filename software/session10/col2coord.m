function coord = col2coord(S, col, v)

if nargin < 3,
	v = NaN;
end

coord = v * ones(size(S.meta.coordToCol));
for c = 1:length(col),
	p = S.meta.colToCoord(c,:);
	coord(p(1), p(2), p(3)) = col(c);
end
