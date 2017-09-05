% ------------------------------------------------
% Data

fprintf('Load Data\n');

expt = init_expt(expt);
[Ss masks] = loadIDM(expt.subjects, expt.data_path);

if isfield(expt, 'rows'),
	num_word = length(expt.rows);
else,
	num_word = length(expt.words);
end

num_trial = length(unique([Ss{1}.info.epoch]));

%[masks] = filter_col(Ss, masks, 'command', 'replicable_all');
%[masks] = filter_col(Ss, masks, 'command', 'replicable_between');
%[masks] = filter_col(Ss, masks, 'command', 'replicable_self');
%[masks masks_replicable_within] = filter_col(Ss, masks, 'command', 'replicable_within');
%[masks masks_replicable_lv2]   = filter_col(Ss, masks, 'command', 'replicable_lv2');

% ------------------------------------------------
% Feature

fprintf('Process Features\n');

[feature_norms_br concepts_br features_br] = setup_cree_mcrae_mod('br', expt.words); %keyboard %%%%%%%%%%%%%%%%%%%%%
%[feature_norms_wb concepts_wb features_wb] = setup_cree_mcrae('wb', expt.words);
%[feature_corpus_co concepts_co features_co] = setup_corpus(expt.corpus_feature, expt.words);

% ------------------------------------------------
% Experiment

log_file = sprintf('%s/log.txt', expt.result_dir);

fprintf('Start Experiment\n');

%for m = 1:length(expt.model_set),
for m = 1:1, %just BR

	for s = 1:length(expt.subjects),

			fprintfile(log_file, 1, 'feature %s, subject %s', upper(expt.model_set{m}), Ss{s}.subject);
			
			run_58_2_mod;         fprintfile(log_file, 1, ', acc_58_2_within %.4f', acc_58_2_within(m,s));
			
			fprintfile(log_file, 1, '\n');
                        
            acc_58_2_WSA = acc_58_2_within(m,s);
            save(sprintf('%s/result_%s.mat', expt.result_dir,Ss{s}.subject), 'acc_58_2_WSA');
            save(sprintf('%s/workspace_%s.mat', expt.result_dir,Ss{s}.subject), '*');

	end % s

end % m