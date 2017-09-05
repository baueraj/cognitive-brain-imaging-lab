function [sim] = cosineSimilarity(v1, v2) 
	v1 = v1 / sqrt(sum(v1.^2));
	v2 = v2 / sqrt(sum(v2.^2));
	sim = dot(v1,v2);

