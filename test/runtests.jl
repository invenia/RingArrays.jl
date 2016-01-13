using RingArrays
using Base.Test
using FactCheck

include("TestHelper.jl")
include("RingArrays.jl")

run_test()


FactCheck.exitstatus()