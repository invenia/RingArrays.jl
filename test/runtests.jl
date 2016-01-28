using RingArrays
using FactCheck
using Mocking

if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

include("RingArrays.jl")

FactCheck.exitstatus()
