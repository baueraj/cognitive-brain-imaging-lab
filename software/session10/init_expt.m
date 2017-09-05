function expt = init_expt(expt)

if ~isempty(strfind(expt.description, 'wp')) || ~isempty(strfind(expt.description, 'wo')), % 60 words

WORDS = { ...
	'bear', 'cat', 'cow', 'dog', 'horse', ...
	'arm', 'eye', 'foot', 'hand', 'leg', ...
	'apartment', 'barn', 'church', 'house', 'igloo', ...
	'arch', 'chimney', 'closet', 'door', 'window', ...
	'coat', 'dress', 'pants', 'shirt', 'skirt', ...
	'bed', 'chair', 'desk', 'dresser', 'table', ...
	'ant', 'bee', 'beetle', 'butterfly', 'fly', ...
	'bottle', 'cup', 'glass', 'knife', 'spoon', ...
	'bell', 'key', 'refrigerator', 'telephone', 'watch', ...
	'chisel', 'hammer', 'pliers', 'saw', 'screwdriver', ...
	'carrot', 'celery', 'corn', 'lettuce', 'tomato', ...
	'airplane', 'bicycle', 'car', 'train', 'truck' ...
};

list = upper(WORDS); enum = 1; enum_list;

FEATURES = { ...
	'exemplar', ...
	'category', ...
	'animal', ...
	'bodypart', ...
	'building', ...
	'buildpart', ...
	'clothing', ...
	'furniture', ...
	'insect', ...
	'kitchen', ...
	'manmade', ...
	'tool', ...
	'vegetable', ...
	'vehicle' ...
	'animacy', ...
	'shelter', ...
	'motor', ...
	'eating', ...
};

list = upper(FEATURES); enum = 1; enum_list;

WORD_FEAT = zeros(length(WORDS), length(FEATURES));

WORD_FEAT(BEAR,         [ANIMAL   ]) = 1;
WORD_FEAT(CAT,          [ANIMAL   ]) = 1;
WORD_FEAT(COW,          [ANIMAL   ]) = 1;
WORD_FEAT(DOG,          [ANIMAL   ]) = 1;
WORD_FEAT(HORSE,        [ANIMAL   ]) = 1;
WORD_FEAT(ARM,          [BODYPART ]) = 1;
WORD_FEAT(EYE,          [BODYPART ]) = 1;
WORD_FEAT(FOOT,         [BODYPART ]) = 1;
WORD_FEAT(HAND,         [BODYPART ]) = 1;
WORD_FEAT(LEG,          [BODYPART ]) = 1;
WORD_FEAT(APARTMENT,    [BUILDING ]) = 1;
WORD_FEAT(BARN,         [BUILDING ]) = 1;
WORD_FEAT(CHURCH,       [BUILDING ]) = 1;
WORD_FEAT(HOUSE,        [BUILDING ]) = 1;
WORD_FEAT(IGLOO,        [BUILDING ]) = 1;
WORD_FEAT(ARCH,         [BUILDPART]) = 1;
WORD_FEAT(CHIMNEY,      [BUILDPART]) = 1;
WORD_FEAT(CLOSET,       [BUILDPART]) = 1;
WORD_FEAT(DOOR,         [BUILDPART]) = 1;
WORD_FEAT(WINDOW,       [BUILDPART]) = 1;
WORD_FEAT(COAT,         [CLOTHING ]) = 1;
WORD_FEAT(DRESS,        [CLOTHING ]) = 1;
WORD_FEAT(PANTS,        [CLOTHING ]) = 1;
WORD_FEAT(SHIRT,        [CLOTHING ]) = 1;
WORD_FEAT(SKIRT,        [CLOTHING ]) = 1;
WORD_FEAT(BED,          [FURNITURE]) = 1;
WORD_FEAT(CHAIR,        [FURNITURE]) = 1;
WORD_FEAT(DESK,         [FURNITURE]) = 1;
WORD_FEAT(DRESSER,      [FURNITURE]) = 1;
WORD_FEAT(TABLE,        [FURNITURE]) = 1;
WORD_FEAT(ANT,          [INSECT   ]) = 1;
WORD_FEAT(BEE,          [INSECT   ]) = 1;
WORD_FEAT(BEETLE,       [INSECT   ]) = 1;
WORD_FEAT(BUTTERFLY,    [INSECT   ]) = 1;
WORD_FEAT(FLY,          [INSECT   ]) = 1;
WORD_FEAT(BOTTLE,       [KITCHEN  ]) = 1;
WORD_FEAT(CUP,          [KITCHEN  ]) = 1;
WORD_FEAT(GLASS,        [KITCHEN  ]) = 1;
WORD_FEAT(KNIFE,        [KITCHEN  ]) = 1;
WORD_FEAT(SPOON,        [KITCHEN  ]) = 1;
WORD_FEAT(BELL,         [MANMADE  ]) = 1;
WORD_FEAT(KEY,          [MANMADE  ]) = 1;
WORD_FEAT(REFRIGERATOR, [MANMADE  ]) = 1;
WORD_FEAT(TELEPHONE,    [MANMADE  ]) = 1;
WORD_FEAT(WATCH,        [MANMADE  ]) = 1;
WORD_FEAT(CHISEL,       [TOOL     ]) = 1;
WORD_FEAT(HAMMER,       [TOOL     ]) = 1;
WORD_FEAT(PLIERS,       [TOOL     ]) = 1;
WORD_FEAT(SAW,          [TOOL     ]) = 1;
WORD_FEAT(SCREWDRIVER,  [TOOL     ]) = 1;
WORD_FEAT(CARROT,       [VEGETABLE]) = 1;
WORD_FEAT(CELERY,       [VEGETABLE]) = 1;
WORD_FEAT(CORN,         [VEGETABLE]) = 1;
WORD_FEAT(LETTUCE,      [VEGETABLE]) = 1;
WORD_FEAT(TOMATO,       [VEGETABLE]) = 1;
WORD_FEAT(AIRPLANE,     [VEHICLE  ]) = 1;
WORD_FEAT(BICYCLE,      [VEHICLE  ]) = 1;
WORD_FEAT(CAR,          [VEHICLE  ]) = 1;
WORD_FEAT(TRAIN,        [VEHICLE  ]) = 1;
WORD_FEAT(TRUCK,        [VEHICLE  ]) = 1;

WORD_FEAT(:, EXEMPLAR) = (1:length(WORDS))';

I = [ANIMAL BODYPART BUILDING BUILDPART CLOTHING FURNITURE INSECT KITCHEN MANMADE TOOL VEGETABLE VEHICLE];
WORD_FEAT(:, CATEGORY) = WORD_FEAT(:, I) * (1:length(I))';

I = [ANIMACY SHELTER MOTOR EATING];
WORD_FEAT(BEAR,         I) = [4 0 2 1];
WORD_FEAT(CAT,          I) = [4 0 2 1];
WORD_FEAT(COW,          I) = [4 0 2 1];
WORD_FEAT(DOG,          I) = [4 0 2 1];
WORD_FEAT(HORSE,        I) = [4 0 2 1];
WORD_FEAT(ARM,          I) = [1 0 1 2];
WORD_FEAT(EYE,          I) = [1 0 1 0];
WORD_FEAT(FOOT,         I) = [1 0 1 0];
WORD_FEAT(HAND,         I) = [1 0 1 2];
WORD_FEAT(LEG,          I) = [1 0 1 0];
WORD_FEAT(APARTMENT,    I) = [0 3 0 0];
WORD_FEAT(BARN,         I) = [0 3 0 0];
WORD_FEAT(CHURCH,       I) = [0 3 0 0];
WORD_FEAT(HOUSE,        I) = [0 3 0 0];
WORD_FEAT(IGLOO,        I) = [0 3 0 0];
WORD_FEAT(ARCH,         I) = [0 2 0 0];
WORD_FEAT(CHIMNEY,      I) = [0 2 0 0];
WORD_FEAT(CLOSET,       I) = [0 2 0 0];
WORD_FEAT(DOOR,         I) = [0 2 0 0];
WORD_FEAT(WINDOW,       I) = [0 2 0 0];
WORD_FEAT(COAT,         I) = [0 0 0 0];
WORD_FEAT(DRESS,        I) = [0 0 0 0];
WORD_FEAT(PANTS,        I) = [0 0 0 0];
WORD_FEAT(SHIRT,        I) = [0 0 0 0];
WORD_FEAT(SKIRT,        I) = [0 0 0 0];
WORD_FEAT(BED,          I) = [0 1 0 0];
WORD_FEAT(CHAIR,        I) = [0 0 0 0];
WORD_FEAT(DESK,         I) = [0 0 0 0];
WORD_FEAT(DRESSER,      I) = [0 1 0 0];
WORD_FEAT(TABLE,        I) = [0 0 0 0];
WORD_FEAT(ANT,          I) = [3 0 2 1];
WORD_FEAT(BEE,          I) = [3 0 2 1];
WORD_FEAT(BEETLE,       I) = [3 0 2 1];
WORD_FEAT(BUTTERFLY,    I) = [3 0 2 1];
WORD_FEAT(FLY,          I) = [3 0 2 1];
WORD_FEAT(BOTTLE,       I) = [0 0 0 2];
WORD_FEAT(CUP,          I) = [0 0 0 2];
WORD_FEAT(GLASS,        I) = [0 0 0 2];
WORD_FEAT(KNIFE,        I) = [0 0 0 2];
WORD_FEAT(SPOON,        I) = [0 0 0 2];
WORD_FEAT(BELL,         I) = [0 0 0 0];
WORD_FEAT(KEY,          I) = [0 0 0 0];
WORD_FEAT(REFRIGERATOR, I) = [0 2 0 2];
WORD_FEAT(TELEPHONE,    I) = [0 0 0 0];
WORD_FEAT(WATCH,        I) = [0 0 0 0];
WORD_FEAT(CHISEL,       I) = [0 0 3 0];
WORD_FEAT(HAMMER,       I) = [0 0 3 0];
WORD_FEAT(PLIERS,       I) = [0 0 3 0];
WORD_FEAT(SAW,          I) = [0 0 3 0];
WORD_FEAT(SCREWDRIVER,  I) = [0 0 3 0];
WORD_FEAT(CARROT,       I) = [2 0 0 3];
WORD_FEAT(CELERY,       I) = [2 0 0 3];
WORD_FEAT(CORN,         I) = [2 0 0 3];
WORD_FEAT(LETTUCE,      I) = [2 0 0 3];
WORD_FEAT(TOMATO,       I) = [2 0 0 3];
WORD_FEAT(AIRPLANE,     I) = [0 2 3 0];
WORD_FEAT(BICYCLE,      I) = [0 0 3 0];
WORD_FEAT(CAR,          I) = [0 2 3 0];
WORD_FEAT(TRAIN,        I) = [0 2 3 0];
WORD_FEAT(TRUCK,        I) = [0 2 3 0];

expt.noun = [58 51 3 47 14 39];
expt.phrase = [];
expt.concepts = WORDS(expt.noun);

elseif ~isempty(strfind(expt.description, 'abs')), % abstract concrete

WORDS = { 'flower', 'grass', 'moss', 'shrub', 'tree', 'forest', 'island', 'lake', 'mountain', 'river', 'athlete', 'cook', 'doctor', 'lawyer', 'teacher', 'fog', 'lightning', 'rain', 'snow', 'wind', 'anxiety', 'depression', 'hate', 'joy', 'love', 'acceleration', 'direction', 'force', 'gravity', 'velocity', 'democracy', 'freedom', 'innocence', 'justice', 'tyranny', 'courage', 'honesty', 'hypocrisy', 'kindness', 'vanity'};

list = upper(WORDS); enum = 1; enum_list;

FEATURES = { ...
	'exemplar', ...
	'category', ...
	'animacy', ...
	'shelter', ...
	'motor', ...
	'motor2', ...
	'eating', ...
};

list = upper(FEATURES); enum = 1; enum_list;

WORD_FEAT = zeros(length(WORDS), length(FEATURES));

WORD_FEAT(:, EXEMPLAR) = (1:length(WORDS))';

I = [ANIMACY SHELTER MOTOR MOTOR2 EATING];
WORD_FEAT(FLOWER,       I) = [2 0 0 0 1];
WORD_FEAT(GRASS,        I) = [2 0 0 0 1];
WORD_FEAT(MOSS,         I) = [2 0 0 0 0];
WORD_FEAT(SHRUB,        I) = [2 0 0 0 0];
WORD_FEAT(TREE,         I) = [2 1 0 0 1];
WORD_FEAT(FOREST,       I) = [2 1 0 0 0];
WORD_FEAT(ISLAND,       I) = [0 1 0 0 0];
WORD_FEAT(LAKE,         I) = [0 1 0 0 0];
WORD_FEAT(MOUNTAIN,     I) = [0 1 0 0 0];
WORD_FEAT(RIVER,        I) = [0 1 0 0 0];
WORD_FEAT(ATHLETE,      I) = [1 0 0 1 0];
WORD_FEAT(COOK,         I) = [1 0 0 1 3];
WORD_FEAT(DOCTOR,       I) = [1 0 0 1 0];
WORD_FEAT(LAWYER,       I) = [1 0 0 1 0];
WORD_FEAT(TEACHER,      I) = [1 0 0 1 0];
WORD_FEAT(FOG,          I) = [0 0 0 0 0];
WORD_FEAT(LIGHTNING,    I) = [0 0 0 0 0];
WORD_FEAT(RAIN,         I) = [0 0 0 0 0];
WORD_FEAT(SNOW,         I) = [0 0 0 0 0];
WORD_FEAT(WIND,         I) = [0 0 0 0 0];
WORD_FEAT(ANXIETY,      I) = [0 0 0 0 0];
WORD_FEAT(DEPRESSION,   I) = [0 0 0 0 0];
WORD_FEAT(HATE,         I) = [0 0 0 0 0];
WORD_FEAT(JOY,          I) = [0 0 0 0 0];
WORD_FEAT(LOVE,         I) = [0 0 0 0 0];
WORD_FEAT(ACCELERATION, I) = [0 0 1 0 0];
WORD_FEAT(DIRECTION,    I) = [0 0 1 0 0];
WORD_FEAT(FORCE,        I) = [0 0 1 0 0];
WORD_FEAT(GRAVITY,      I) = [0 0 1 0 0];
WORD_FEAT(VELOCITY,     I) = [0 0 0 0 0];
WORD_FEAT(DEMOCRACY,    I) = [0 0 0 0 0];
WORD_FEAT(FREEDOM,      I) = [0 0 0 0 0];
WORD_FEAT(INNOCENCE,    I) = [0 0 0 0 0];
WORD_FEAT(JUSTICE,      I) = [0 0 0 0 0];
WORD_FEAT(TYRANNY,      I) = [0 0 0 0 0];
WORD_FEAT(COURAGE,      I) = [0 0 0 0 0];
WORD_FEAT(HONESTY,      I) = [0 0 0 0 0];
WORD_FEAT(HYPOCRISY,    I) = [0 0 0 0 0];
WORD_FEAT(KINDNESS,     I) = [0 0 0 0 0];
WORD_FEAT(VANITY,       I) = [0 0 0 0 0];

elseif ~isempty(strfind(expt.description, 'adj')), % adjective

WORDS = { ...
	'bear', 'cat', 'dog', ...
	'bottle', 'cup', 'knife', ...
	'carrot', 'corn', 'tomato', ...
	'airplane', 'train', 'truck' ...
	'soft_bear', 'large_cat', 'strong_dog', ...
	'plastic_bottle', 'small_cup', 'sharp_knife', ...
	'hard_carrot', 'cut_corn', 'firm_tomato', ...
	'paper_airplane', 'model_train', 'toy_truck', ...
};

list = upper(WORDS); enum = 1; enum_list;

FEATURES = { ...
	'exemplar', ...
	'category', ...
	'pos', ...
	'binary', ...
	'attr_mod', ...
	'all', ...
};

WORD_FEAT = zeros(length(WORDS), length(FEATURES));

WORD_FEAT(BEAR,           1:4) = [ 1 1 1  1];
WORD_FEAT(CAT,            1:4) = [ 2 1 1  2];
WORD_FEAT(DOG,            1:4) = [ 3 1 1  3];
WORD_FEAT(BOTTLE,         1:4) = [ 4 2 1  4];
WORD_FEAT(CUP,            1:4) = [ 5 2 1  5];
WORD_FEAT(KNIFE,          1:4) = [ 6 2 1  6];
WORD_FEAT(CARROT,         1:4) = [ 7 3 1  7];
WORD_FEAT(CORN,           1:4) = [ 8 3 1  8];
WORD_FEAT(TOMATO,         1:4) = [ 9 3 1  9];
WORD_FEAT(AIRPLANE,       1:4) = [10 4 1 10];
WORD_FEAT(TRAIN,          1:4) = [11 4 1 11];
WORD_FEAT(TRUCK,          1:4) = [12 4 1 12];
WORD_FEAT(SOFT_BEAR,      1:4) = [13 1 2  1];
WORD_FEAT(LARGE_CAT,      1:4) = [14 1 2  2];
WORD_FEAT(STRONG_DOG,     1:4) = [15 1 2  3];
WORD_FEAT(PLASTIC_BOTTLE, 1:4) = [16 2 2  4];
WORD_FEAT(SMALL_CUP,      1:4) = [17 2 2  5];
WORD_FEAT(SHARP_KNIFE,    1:4) = [18 2 2  6];
WORD_FEAT(HARD_CARROT,    1:4) = [19 3 2  7];
WORD_FEAT(CUT_CORN,       1:4) = [20 3 2  8];
WORD_FEAT(FIRM_TOMATO,    1:4) = [21 3 2  9];
WORD_FEAT(PAPER_AIRPLANE, 1:4) = [22 4 2 10];
WORD_FEAT(MODEL_TRAIN,    1:4) = [23 4 2 11];
WORD_FEAT(TOY_TRUCK,      1:4) = [24 4 2 12];

WORD_FEAT(13:21, 5) = 1;
WORD_FEAT(22:24, 5) = 2;

WORD_FEAT(13:24, 6) = 1;

expt.noun = [];
expt.phrase = [];
expt.concepts = {};
for w = 1:length(WORDS),
	if ~isempty(find(WORDS{w} == '_')), 
		expt.phrase = [expt.phrase w];

		[adj noun] = sscanp(WORDS{w}, '(.+)_(.+)');
		expt.mods{w} = adj;
		expt.heads{w} = noun;
		expt.concepts = {expt.concepts{:} adj noun};
	else,
		expt.noun = [expt.noun w];
	end
end

expt.concepts = unique(expt.concepts);

elseif ~isempty(strfind(expt.description, 'cc')), % conceptual combination words

WORDS = { ...
	'car', 'carrot', 'cow', 'hammer', 'house', 'knife', ...
	'car_carrot', 'car_cow', 'car_hammer', 'car_house', 'car_knife', ...
	'carrot_car', 'carrot_cow', 'carrot_hammer', 'carrot_house', 'carrot_knife', ...
	'cow_car', 'cow_carrot', 'cow_hammer', 'cow_house', 'cow_knife', ...
	'hammer_car', 'hammer_carrot', 'hammer_cow', 'hammer_house', 'hammer_knife', ...
	'house_car', 'house_carrot', 'house_cow', 'house_hammer', 'house_knife', ...
	'knife_car', 'knife_carrot', 'knife_cow', 'knife_hammer', 'knife_house', ...
};

list = upper(WORDS); enum = 1; enum_list;

FEATURES = { ...
	'exemplar', ...
	'modifier', ...
	'head', ...
	'order', ...
	'artifact_animal', ...
};

list = upper(FEATURES); enum = 1; enum_list;

WORD_FEAT(CAR,           1:4) = [ 1 CAR    CAR     1];
WORD_FEAT(CARROT,        1:4) = [ 2 CARROT CARROT  1];
WORD_FEAT(COW,           1:4) = [ 3 COW    COW     1];
WORD_FEAT(HAMMER,        1:4) = [ 4 HAMMER HAMMER  1];
WORD_FEAT(HOUSE,         1:4) = [ 5 HOUSE  HOUSE   1];
WORD_FEAT(KNIFE,         1:4) = [ 6 KNIFE  KNIFE   1];
WORD_FEAT(CAR_CARROT,    1:4) = [ 7 CAR    CARROT  2];
WORD_FEAT(CAR_COW,       1:4) = [ 8 CAR    COW     3];
WORD_FEAT(CAR_HAMMER,    1:4) = [ 9 CAR    HAMMER  4];
WORD_FEAT(CAR_HOUSE,     1:4) = [10 CAR    HOUSE   5];
WORD_FEAT(CAR_KNIFE,     1:4) = [11 CAR    KNIFE   6];
WORD_FEAT(CARROT_CAR,    1:4) = [12 CARROT CAR     2];
WORD_FEAT(CARROT_COW,    1:4) = [13 CARROT COW     7];
WORD_FEAT(CARROT_HAMMER, 1:4) = [14 CARROT HAMMER  8];
WORD_FEAT(CARROT_HOUSE,  1:4) = [15 CARROT HOUSE   9];
WORD_FEAT(CARROT_KNIFE,  1:4) = [16 CARROT KNIFE  10];
WORD_FEAT(COW_CAR,       1:4) = [17 COW    CAR     3];
WORD_FEAT(COW_CARROT,    1:4) = [18 COW    CARROT  4];
WORD_FEAT(COW_HAMMER,    1:4) = [19 COW    HAMMER 11];
WORD_FEAT(COW_HOUSE,     1:4) = [20 COW    HOUSE  12];
WORD_FEAT(COW_KNIFE,     1:4) = [21 COW    KNIFE  13];
WORD_FEAT(HAMMER_CAR,    1:4) = [22 HAMMER CAR     5];
WORD_FEAT(HAMMER_CARROT, 1:4) = [23 HAMMER CARROT  6];
WORD_FEAT(HAMMER_COW,    1:4) = [24 HAMMER COW     7];
WORD_FEAT(HAMMER_HOUSE,  1:4) = [25 HAMMER HOUSE  14];
WORD_FEAT(HAMMER_KNIFE,  1:4) = [26 HAMMER KNIFE  15];
WORD_FEAT(HOUSE_CAR,     1:4) = [27 HOUSE  CAR     8];
WORD_FEAT(HOUSE_CARROT,  1:4) = [28 HOUSE  CARROT  9];
WORD_FEAT(HOUSE_COW,     1:4) = [29 HOUSE  COW    10];
WORD_FEAT(HOUSE_HAMMER,  1:4) = [30 HOUSE  HAMMER 11];
WORD_FEAT(HOUSE_KNIFE,   1:4) = [31 HOUSE  KNIFE  16];
WORD_FEAT(KNIFE_CAR,     1:4) = [32 KNIFE  CAR    12];
WORD_FEAT(KNIFE_CARROT,  1:4) = [33 KNIFE  CARROT 13];
WORD_FEAT(KNIFE_COW,     1:4) = [34 KNIFE  COW    14];
WORD_FEAT(KNIFE_HAMMER,  1:4) = [35 KNIFE  HAMMER 15];
WORD_FEAT(KNIFE_HOUSE,   1:4) = [36 KNIFE  HOUSE  16];

ANIMAL = [2 3];
ARTIFACT = [1 4 5 6];
I = zeros(length(WORDS),1);
I(find(and(ismember(WORD_FEAT(:,2), ARTIFACT), ismember(WORD_FEAT(:,3), ARTIFACT)))) = 1;
I(find(and(ismember(WORD_FEAT(:,2), ARTIFACT), ismember(WORD_FEAT(:,3), ANIMAL  )))) = 2;
I(find(and(ismember(WORD_FEAT(:,2), ANIMAL  ), ismember(WORD_FEAT(:,3), ARTIFACT)))) = 3;
I(find(and(ismember(WORD_FEAT(:,2), ANIMAL  ), ismember(WORD_FEAT(:,3), ANIMAL  )))) = 4;
WORD_FEAT(:,5) = I;

elseif ~isempty(strfind(expt.description, 'pr')), % conceptual combination V2 words

[M H C R] = tablescan('/usr/cluster/software/ccbi/neurosemantics/kkchang/exp/10.phrase/data/C_ConceptCombination2.xls', 1); 
WORDS = C{1}(2:end);

%for w = 1:length(WORDS),
	%if ~isempty(strfind(WORDS{w}, '_')),
		%[type interpretation mod head] = sscanp(WORDS{w}, '(.*)_(.*)_(.*)_(.*)');
		%WORDS{w} = sprintf('%s_%s_%s', mod, head, interpretation);
	%end
%end % w

%WORDS = { ...
	%'bee', 'bell', 'celery', 'corn', 'cow', 'dog', 'pliers', 'refrigerator', 'tomato', 'window', ...
	%'airplane', 'dress', 'table', 'coat', 'chair', 'beetle', 'hand', 'house', 'ant', 'cup', ...
	%'prim_prop_beeairplane', 'prim_prop_belldress', 'prim_prop_celerytable', 'prim_prop_corncoat', 'prim_prop_cowchair', ...
	%'prim_prop_dogbeetle', 'prim_prop_pliershand', 'prim_prop_refrigeratorhouse', 'prim_prop_tomatoant', 'prim_prop_windowcup', ...
	%'prim_rela_beeairplane', 'prim_rela_belldress', 'prim_rela_celerytable', 'prim_rela_corncoat', 'prim_rela_cowchair', ...
	%'prim_rela_dogbeetle', 'prim_rela_pliershand', 'prim_rela_refrigeratorhouse', 'prim_rela_tomatoant', 'prim_rela_windowcup', ...
	%'stim_prop_beeairplane', 'stim_prop_belldress', 'stim_prop_celerytable', 'stim_prop_corncoat', 'stim_prop_cowchair', ...
	%'stim_prop_dogbeetle', 'stim_prop_pliershand', 'stim_prop_refrigeratorhouse', 'stim_prop_tomatoant', 'stim_prop_windowcup', ...
	%'stim_rela_beeairplane', 'stim_rela_belldress', 'stim_rela_celerytable', 'stim_rela_corncoat', 'stim_rela_cowchair', ...
	%'stim_rela_dogbeetle', 'stim_rela_pliershand', 'stim_rela_refrigeratorhouse', 'stim_rela_tomatoant', 'stim_rela_windowcup', ...
%};

list = upper(WORDS); enum = 1; enum_list;

FEATURES = { ...
	'word', ...
	'adj', ...
	'noun', ...
	'cond', ...
	'exemplar', ...
};

list = upper(FEATURES); enum = 1; enum_list;

WORD_FEAT = zeros(length(WORDS), 5);
WORD_FEAT(:,1) = M(2:end,end);
WORD_FEAT(:,2) = [1:10 11:20 1:10 1:10 1:10 1:10]';
WORD_FEAT(:,3) = [1:10 11:20 11:20 11:20 11:20 11:20]';
WORD_FEAT(:,4) = M(2:end,2) - 1;
WORD_FEAT(:,5) = M(2:end,3);

expt.mod = 1:10;
expt.head = 11:20;
expt.property_prime = 21:30;
expt.relation_prime = 31:40;
expt.property = 41:50;
expt.relation = 51:60;

expt.noun = 1:20;
expt.phrase = 41:60;
expt.concepts = WORDS(expt.noun);

for w = 1:length(WORDS),
	expt.mods{w} = WORDS(WORD_FEAT(w,2));
	expt.heads{w} = WORDS(WORD_FEAT(w,3));
end

else,

[Ss masks] = loadIDM(expt.subjects, expt.data_path);

word_number = [Ss{1}.info.word_number];
word = {Ss{1}.info.word};
cond = [Ss{1}.info.cond];

num_word_per_cond = length(unique(word_number));

WORDS = {};
for i = 1:length(word),
	w = (cond(i) - 2) * num_word_per_cond + word_number(i);
	WORDS{w} = word{i};
end

end

% ************************************************

expt.words = WORDS;

if exist('FEATURES', 'var'),
	expt.features = FEATURES;
	expt.word_feat = WORD_FEAT;
end
