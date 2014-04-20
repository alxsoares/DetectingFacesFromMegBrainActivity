PROJECT_DIR = $(DataPath)/DetectingFacesFromMegBrainActivity
RAW_ZIP_DIR = $(PROJECT_DIR)/Raw
WORKING_DIR = $(PROJECT_DIR)/Working
RAW_MAT_DIR = $(WORKING_DIR)/RawMat

TRAIN1_ZIP = $(RAW_ZIP_DIR)/train_01_06.zip
TRAIN2_ZIP = $(RAW_ZIP_DIR)/train_07_12.zip
TRAIN3_ZIP = $(RAW_ZIP_DIR)/train_13_16.zip
TEST_ZIP   = $(RAW_ZIP_DIR)/test_17_23.zip

$(RAW_MAT_DIR)/.sentinel: $(TRAIN1_ZIP) $(TRAIN2_ZIP) $(TRAIN3_ZIP) $(TEST_ZIP)
	mkdir $(RAW_MAT_DIR)
	unzip $(TRAIN1_ZIP) -d $(RAW_MAT_DIR)
	unzip $(TRAIN2_ZIP) -d $(RAW_MAT_DIR)
	unzip $(TRAIN3_ZIP) -d $(RAW_MAT_DIR)
	unzip $(TEST_ZIP)   -d $(RAW_MAT_DIR)
	touch $(RAW_MAT_DIR)/.sentinel

unzip-files: $(RAW_MAT_DIR)/.sentinel

summary: 
	julia src/data_summary.jl $(RAW_MAT_DIR)/data

all:
	echo "$(TRAIN1_ZIP)"