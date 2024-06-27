using Revise
using Dates
using ElectroPhysiology 
using PhysiologyAnalysis
using Pkg; Pkg.activate("test")

#%% When we get to the dataframe creation we can fill in details here
using XLSX, DataFrames, Query
using FileIO, Images, ImageView, ImageMagick

#%% Open all dates for the imaging files
img_dir = raw"D:\Data\Calcium Imaging"
patch_dir = raw"D:\Data\Patching"
filename = raw"D:\Data\Analysis\data_analysis.xlsx"

#Don't often need to do this (eventually we need to add an update button)
dataset = create2PDataSheet(img_dir, patch_dir; verbose = true)
dataset = IV_analysis!(dataset)
dataset = pair_experiments!(dataset)
save2PDataSheet(filename, dataset)

#You can use this to open the datasheet after it has been saved
dataset = open2PDataSheet(filename)
all_datasheet = dataset["All Files"]
img_datasheet = dataset["TIF Files"]
patch_datasheet = dataset["ABF Files"] 