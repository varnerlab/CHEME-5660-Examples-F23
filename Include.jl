# setup paths -
const _ROOT = pwd();
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");

# make sure all is up to date -
import Pkg; Pkg.activate("."); Pkg.resolve(); Pkg.instantiate(); Pkg.update()

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
include(joinpath(_PATH_TO_SRC, "Compute.jl"));
include(joinpath(_PATH_TO_SRC, "Utility.jl"));

