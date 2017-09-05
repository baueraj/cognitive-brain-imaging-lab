function [net, eY] = multivariate_gp(Y, X, Y2, X2)

eY = zeros(size(Y2));

for i = 1:size(Y,2),
	x = X;
	t = Y(:,i);
	xtest = X2;

	m = size(X, 2);
	net{i} = gp(m, 'sqexp');

	prior.pr_mean = 0;
	prior.pr_var = 1;
	net{i} = gpinit(net{i}, x, t, prior);

	options = foptions;
	options(1) = 1;    % Display training error values
	options(14) = 20;

	cn = gpcovar(net{i}, x); 
	cninv = inv(cn);
	[ytest, sigsq] = gpfwd(net{i}, xtest, cninv);

	eY(:,i) = ytest;
end
