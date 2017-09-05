function [M, H] = MakeMH(varargin);

M = [];
H = hashtable;

args = varargin;
for i = 1:2:length(args),
	H(args{i}) = size(M,2)+1:size(M,2)+size(args{i+1},2);
	M = [M args{i+1}];
end
