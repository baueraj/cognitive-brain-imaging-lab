function [Ss, masks, commonMask] = loadIDM(subjects, data_path, offset);

Ss = cell(length(subjects), 1);
commonMask = ones(51,61,23);

for s = 1:length(subjects),
	subject = subjects{s};

	if nargin >= 3,

	Ss{s} = load( sprintf('%s/normalMpsc.%d/%s/detrend.MPSC_wraf336_ALL.mat', ...
				data_path, offset, subject) );

	else,

	Ss{s} = load( sprintf('%s/normalMpsc/%s/detrend.MPSC_wraf336_ALL.mat', ...
				data_path, subject) );

	end

	Ss{s}.subject = subject;

	% ------------------------------------------------
	% Some masks

	masks{s}.hemisphereMask = zeros(1, Ss{s}.meta.nvoxels);

	global HEMISPHERES;

	for i = 1:length(HEMISPHERES),
		region = HEMISPHERES{i};
		load(sprintf('../software/ccbi/templates/mask336/mask%s.mat', region));

		mask = ismember(Ss{s}.meta.colToCoord, maskXYZ, 'rows');

		eval(sprintf('masks{s}.%sMask = mask\'';', region));

		I = find(mask);
		masks{s}.hemisphereMask(I) = i;
	end

	masks{s}.lobeMask = zeros(1, Ss{s}.meta.nvoxels);

	global LOBES;

	for i = 1:length(LOBES),
		region = LOBES{i};
		load(sprintf('../software/ccbi/templates/mask336/mask%s.mat', region));

		mask = ismember(Ss{s}.meta.colToCoord, maskXYZ, 'rows');

		eval(sprintf('masks{s}.%sMask = mask\'';', region));

		I = find(mask);
		masks{s}.lobeMask(I) = i;
	end

	masks{s}.TemporalFusiformHippocampusMask = masks{s}.TemporalMask + masks{s}.FusiformMask + masks{s}.HippocampusMask;
	masks{s}.NonOccipitalMask = 1 - masks{s}.OccipitalMask;

	masks{s}.roiMask = zeros(1, Ss{s}.meta.nvoxels);

	global ROIS;

        %	for i = 1:length(ROIS),
	%	region = ROIS{i};
 	%	load(sprintf('../software/ccbi/neurosemantics/zeroShotLearn/data/aalRoisMask336/mask%s.mat', region));
        % 
 	%	mask = ismember(Ss{s}.meta.colToCoord, maskXYZ, 'rows');
        % 
 	%	eval(sprintf('masks{s}.%sMask = mask\'';', region));
        % 
 	%	I = find(mask);
 	%	masks{s}.roiMask(I) = i;
 	%end
 
 	masks{s}.allMask = ones(1, Ss{s}.meta.nvoxels);
 
% % % 	% ------------------------------------------------
% % % %% Common mask
%commonMask = commonMask .* (Ss{s}.meta.coordToCol > 0);
end

%for s = 1:length(subjects),
%masks{s}.commonCols = Ss{s}.meta.coordToCol( commonMask == 1 )';

% 	mask = zeros(1, Ss{s}.meta.nvoxels);
% 	mask(Ss{s}.meta.coordToCol( commonMask == 1 )') = 1;
% 	masks{s}.commonMask = mask;
%end

%commonMask = [];
