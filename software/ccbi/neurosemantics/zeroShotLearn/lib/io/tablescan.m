function [M, H, C, R] = tablescan(file, header)

	% M is table converted to a numeric matrix
	% H is header of the table
	% C is a column view of the table
	% R is a row view of the table

if nargin < 2,
	header = 1;
end

lc = linecount(file);

fid = fopen(file);

% 1. H

if header,
	header = fgetl(fid);
	headers = tokenizer(header, '	');
else
	header = fgetl(fid);
	tokens = tokenizer(header, '	');
	for i = 1:length(tokens),
		headers{i} = sprintf('%d', i);
	end
	fclose(fid);
	fid = fopen(file);
end

H = hashtable;

for i=1:length(headers),
	H(headers{i}) = i;
end

% 2. M, C, R

M = zeros(lc-1, length(headers));
C = cell(lc-1, length(headers)); 
R = cell(lc-1,1);

i = 0;
while ~feof(fid),
	line = fgetl(fid);
	i = i + 1;

	tokens = tokenizer(line, '	');
	for j=1:length(tokens),
		M(i,j) = str2double(tokens{j});
		C{i,j} = tokens{j};
    end

	R{i} = line;
end

for j=1:length(tokens),
	C2{j} = {C{:,j}}'; 
end
C = C2;

fclose(fid);
