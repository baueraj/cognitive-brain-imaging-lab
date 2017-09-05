function [H, C1, C2, Tpermute, Ttrue] = btest(X, a, varargin)

B = 1000;
alpha = 0.05;
displayTpermute = 0;
compareCI = 0;
nbin = 1000;

args = varargin;
for i = 1:2:length(args),
	eval(sprintf('%s = args{i+1};', args{i}));
end

X = reshape(X, 1, []);
n = length(X);

% ------------------------------------------------

Ttrue = mean(X);

Xpermute = reshape(X(randsample(n, B * n, true)), B, []);
Tpermute = mean(Xpermute,2);

% ------------------------------------------------

% Bootstrap percentile CI

%hist(Tpermute, nbin);
Tpermute2 = sort(Tpermute);
bootp.C1 = Tpermute2(alpha / 2 * B + 1);
bootp.C2 = Tpermute2((1 - alpha / 2) * B);

C1 = bootp.C1;
C2 = bootp.C2;
H = ~and(C1 < a, a < C2);

% ------------------------------------------------

if displayTpermute,
	h = clf;
	hist(Tpermute, nbin);
	hold on;

	plot(Ttrue, 0, 'o', ...
			'LineWidth',2,...
			'MarkerEdgeColor','r',...
			'MarkerSize',10)
	hold on;

	plot(C1, 0, 'x', ...
			'LineWidth',2,...
			'MarkerEdgeColor','g',...
			'MarkerSize',10)
	hold on;

	plot(C2, 0, 'x', ...
			'LineWidth',2,...
			'MarkerEdgeColor','g',...
			'MarkerSize',10)
 
	title(sprintf('H = %d, CI = [%.4f, .4f]', H, C1, C2));
end

if compareCI,

	% Bootstrap percentile CI

	x = linspace(min(Tpermute), max(Tpermute), nbin);
	h = histc(Tpermute', x) / B;
	c = cumsum(h);
	I1 = find(c >=     alpha / 2, 1, 'first' );
	I2 = find(c <= 1 - alpha / 2, 1, 'last');
	bootp2.C1 = x(I1);
	bootp2.C2 = x(I2);

	% Bootstrap t CI

	df = n - 1;
	t = tinv(1 - alpha / 2, df);

	SEboot = std(Tpermute);
	boott.C1 = Ttrue - t * SEboot;
	boott.C2 = Ttrue + t * SEboot;

	% CLT t CI

	SEclt = std(X) / sqrt(n);
	cltt.C1 = Ttrue - t * SEclt;
	cltt.C2 = Ttrue + t * SEclt;

	% summary

	[bootp.C1 bootp.C2;
	 bootp2.C1 bootp2.C2;
	 boott.C1 boott.C2;
	 cltt.C1 cltt.C2]
end
