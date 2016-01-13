using DataStructures

module RingArrays

import Base.size
export RingArray, size

type RingArrayOld{T, N} <: AbstractArray{T, N}
    data_type::Type
    data_dimensions::Int
    buffer_dim::Int
    block_size::Int
    max_blocks::Int
    blocks::Array
end

type RingArray{T, N} <: AbstractArray{T, N}
    next_write::Int
    max_blocks::Int
    blocks::Array{AbstractArray{T, N}, 1}
    num_users::Array{Int, 1}
    start_index::Int

    function RingArray(max_blocks::Int)
        return new(1, max_blocks, Array{AbstractArray{T, N}, 1}(), zeros(Int, max_blocks), 1)
    end
    function RingArray()
        max_blocks = 16
        return new(1, max_blocks, Array{AbstractArray{T, N}, 1}(), zeros(Int, max_blocks), 1)
    end
end

function size{T, N}(ring::RingArray{T, N})
    return tuple(0)
end

function data_fetch(ring::RingArray)
end

function enqueue!(ring::RingArray, block::AbstractArray)

end

function is_full(ring::RingArray)
    return ring.max_blocks <= length(ring.blocks)
end

end

