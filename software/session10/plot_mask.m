function h = plot_mask(S, masks, varargin)

% ------------------------------------------------
% Options

mode = 'matlab';

img = sprintf('./%s/clusterMask.img', S.subject);
writeOnly = 0;

dim = 'z';
planes = 1:eval(sprintf('S.meta.dim%s', dim));
clim = [-1 1];
value = mean(cell2mat(S.data));
cluster = ones(1, S.meta.nvoxels);
score = ones(1, S.meta.nvoxels);
cutoff = 0.9999;

saveFig = 0;
printFig = 0;

args = varargin;
for i = 1:2:length(args),
	eval(sprintf('%s = args{i+1};', args{i}));
end

if strcmp(dim, 'x') || strcmp(dim, 'y'),
	error('not supported yet');
end

if strcmp(clim, 'off'),
	clear clim;
end

% ------------------------------------------------
% Prepare data

value2 = -0.9 * ones(size(value));
for j = setdiff(unique(cluster), 0),
	I2 = find(cluster == j);

	[temp I] = sort(score(I2) * -1, 2);
	if cutoff < 1, cutoff = floor(length(I) * cutoff); end;
	I2 = I2( I(1:cutoff) );

	value2(I2) = value(I2);
end

coord = col2coord(S, value2);

% ------------------------------------------------
% xjview

if strcmp(mode, 'xjview'), 
	tempV = spm_vol(sprintf('./masks/%s/mask.img', S.subject));
	tempV.fname = img;
	spm_write_vol(tempV, coord);

	if ~writeOnly,
		xjview(img);
	end

	return;
end

% ------------------------------------------------
% Plot

%h = figure;
%h = clf;
h = gcf;
%datacursormode on;
%subplot_dim = find((1:10).^2 >= length(planes), 1);
I = find((1:10).^2 >= length(planes)); subplot_dim = I(1);

c = 0;
for plane = planes,
	c = c + 1;
	subplot(subplot_dim,subplot_dim, c);
	M = coord(:,:,plane);

	if exist('clim', 'var'),
		h2 = imagesc(M, clim);
	else,
		h2 = imagesc(M);
		colorbar;
	end

	set(gca, 'XTickLabel', {});
	set(gca, 'YTickLabel', {});
	set(h2, 'UserData', plane);
end

if exist('clim', 'var'),
	colorbar;
end

if exist('Title', 'var'),
	%title(Title);
	suplabel(Title, 't');
end

if saveFig,
	saveas(h, sprintf('%s.fig', Title));
end

if printFig,
	print_ccbi(h);
end

% ------------------------------------------------
% Events

dcm_obj = datacursormode(h);
set(dcm_obj, 'UpdateFcn', {@figure1_UpdateFcn, S, masks, value, score});

function txt = figure1_UpdateFcn(source, event, S, masks, value, score)
	pos = get(event, 'Position');
	x = pos(2);
	y = pos(1);
	z = get(get(event, 'Target'), 'UserData');
	voxel = S.meta.coordToCol(x, y, z);
	M = get(get(event, 'Target'), 'CData');

	global ROIS LOBES FUNCTIONS ROI_FUNC;
	roi = masks.roiMask(voxel);
	lobe = masks.lobeMask(voxel);
	func = find(ROI_FUNC(roi,:));

	txt = sprintf('voxel %d (%d, %d, %d) = %.4f\n%s (%s)\n%s\nscore = %.4f', ...
			voxel, x, y, z, M(x,y), ...
			ROIS{roi}, FUNCTIONS{func}, LOBES{lobe}, ...
			score(voxel));
