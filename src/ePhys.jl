module ePhys

#==============================================================================

This packages base functionality is to do these things: 
1) Open neurophysiological data
2) Filter that data
3) Analyze the data

Some other things this package can do:
a) Process the data as an alternative to excel. 
b) Plot the data into graphs
c) Do more complicated machine learning and cancellation

==============================================================================#


#=================== Here are the imports from other files ===================#
using Requires #This will help us load only the things we need
using Dates
using Base: String, println
import RCall as R #This allows us to use some R functionality
using PyCall
import PyCall as py
export R, py

#=======================Import all experiment objects=======================#
include("Experiment/StimulusProtocol.jl")
include("Experiment/experiments.jl") #This file contains the Experiment structure. 

#======================Import all ABF extension imports======================#
include("Readers/ABFReader/ABFReader.jl")
export readABF
export parseABF

#===============================ABF utilities===============================#
include("Utilities/ExperimentUtilities.jl")
include("Utilities/DataUtilities.jl")
#export truncate_data, truncate_data!
#export baseline_adjust
export downsample, downsample!
export split_data
#=Add filtering capability=#
using DSP #Used for lowpass, highpass, EI, and notch filtering
using FFTW
using LsqFit #Used for fitting amplification, Intensity Response, and Resistance Capacitance models
import Polynomials as PN #Import this (there are a few functions that get in the way)

using ContinuousWavelets, Wavelets
include("Filtering/filtering.jl")
#include("Filtering/filteringPipelines.jl") #Not ready to uncomment this one yet
#export filter_data #Don't export this one explicitly
#export baseline_adjust, baseline_adjust!
#export lowpass_filter, lowpass_filter!
#export highpass_filter, highpass_filter!
#export notch_filter, notch_filter!
#export EI_filter, EI_filter!
#export cwt_filter, cwt_filter!
#export dwt_filter
#export average_sweeps, average_sweeps!
#export rolling_mean
#export normalize, normalize!

include("Filtering/filteringPipelines.jl")
export data_filter!, data_filter

include("Fitting/fitting.jl")
export MeanSquaredError


#====================Import all the tools needed to analyze the data====================#
#First import models necessary for the analysis

using Statistics, StatsBase #These functions use R functions as well as StatsBase
include("Analysis/Stats.jl")
export RSQ

using Distributions
include("Analysis/Models.jl")
include("Analysis/ERGAnalysis.jl")
#export calculate_basic_stats
export saturated_response, dim_response
export minima_to_peak, time_to_peak
export percent_recovery_interval #This finds the dominant time constant
export recovery_time_constant #This finds the recovery time constant
export integral #This finds the integration time
export get_response
export amplification
export curve_fit #curve fitting from LsqFit
export IR_curve
export calculate_threshold

using JLD2
include("Analysis/TimescaleAnalysis.jl")
export get_timestamps, extract_interval
export max_interval_algorithim, timeseries_analysis

#========================================Plotting utilities========================================#
include("Plotting/PlottingUtilities.jl") #This imports all the plotting utilites

#Once this is all ready, move this into the __init__ function
#using DataFrames

function __init__()
     @require FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341" begin
          include("Filtering/make_spectrum.jl")
     end

     #This is a good section to try using @Requires
     @require DifferentialEquations = "0c46a032-eb83-5123-abaf-570d42b7fbaa" begin
          println("Differential equation utilities are loaded")
          #using DifferentialEquations #For require, do we actually need to import this? 
          using DiffEqParamEstim, Optim
          include("Filtering/artifactRemoval.jl")
          export RCArtifact
     end
     #===============================Import all Datasheet tools==============================#
     #Only import if DataFrames has been loaded

     @require DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
          println("Dataframe utilities are loaded")
          using Query, XLSX #Load these extra utilites immediately
          import XLSX: readtable, readxlsx #Import XLSX commands
          import Query: @filter #Import query commands
          export readtable, readxlsx, XLSX
          export @filter
          include("Datasheets/RegexFunctions.jl")
          include("Datasheets/DatasheetFunctions.jl")
          include("Datasheets/DatasheetAnalysis.jl")
          export DataPathExtraction, openDatasheet, createDatasheet, updateDatasheet
          export runAnalysis
          # This function will load all of the functions that need a require
     end

     @require PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee" begin
          println("Pyplot utilites are loaded")
          using Colors, StatsPlots
          #import PyPlot as plt #All the base utilities for plotting
          import PyPlot.matplotlib
          import PyCall as py #This allows us to use Python to call somethings 
          import PyCall: @pyimport, PyObject
          @pyimport matplotlib.gridspec as GSPEC #add the gridspec interface
          @pyimport matplotlib.ticker as TICK #add the ticker interface
          MultipleLocator = TICK.MultipleLocator #This is for formatting normal axis
          LogLocator = TICK.LogLocator #This is for formatting the log axis
          include("Plotting/DefaultSettings.jl") #This requires PyPlot
          include("Plotting/PlottingUtilities.jl")
          include("Plotting/PhysPyPlot.jl")
          #export plt #Export plotting utilities
          export plot_experiment
     end

     @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
          using RecipesBase
          include("Plotting/PhysRecipes.jl")
     end
end

end