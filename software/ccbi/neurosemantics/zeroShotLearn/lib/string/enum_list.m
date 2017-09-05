for i = 1:length(list),
	eval(sprintf('%s = %d;', list{i}, (enum - 1) + i));
end
