# setup paths -
const _ROOT = pwd();
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");

# load external packages -
using VLQuantitativeFinancePackage
using DataFrames
using CSV
using Dates
using LinearAlgebra
using Statistics
using Plots
using Colors
using StatsPlots

# load my codes -
include(joinpath(_PATH_TO_SRC, "Files.jl"));
include(joinpath(_PATH_TO_SRC, "Computes.jl"));

