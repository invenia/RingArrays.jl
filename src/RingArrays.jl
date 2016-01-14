module RingArrays

import Base.size, Base.getindex
export RingArray, size

type RingArrayOld{T, N} <: AbstractArray{T, N}
    data_type::Type
    data_dimensions::Int
    buffer_dim::Int
    block_size::Tuple
    max_blocks::Int
    blocks::Array
end

type RingArray{T, N} <: AbstractArray{T, N}
    next_write::Int
    max_blocks::Int
    blocks::Array{AbstractArray{T, N}, 1}
    num_users::Array{Int, 1}
    block_size::Tuple
    range::UnitRange{Int}

    function RingArray(max_blocks::Int, block_size::Tuple)
        return new(1, max_blocks,
            Array{AbstractArray{T, N}, 1}(max_blocks),
            zeros(Int, max_blocks), block_size, 1:0)
    end
    function RingArray(max_blocks::Int)
        block_size = (10,)
        return new(1, max_blocks,
            Array{AbstractArray{T, N}, 1}(max_blocks),
            zeros(Int, max_blocks), block_size, 1:0)
    end
    function RingArray()
        max_blocks = 10
        block_size = (10,)
        return new(1, max_blocks,
            Array{AbstractArray{T, N}, 1}(max_blocks),
            zeros(Int, max_blocks), block_size, 1:0)
    end
end

function size{T, N}(ring::RingArray{T, N})
    if N <= 1
        return tuple(ring.block_size[1] * ring.max_blocks,)
    else
        return tuple(ring.block_size[1] * ring.max_blocks, ring.block_size[2:end])
    end
end

function getindex(ring::RingArray, i::Int...)
    result = 0

    while ring.range.stop < i[1]
        load_block(ring)
    end

    return ring.blocks[divide(i[1],ring.block_size[1])][fix_zero_index(i[1],ring.block_size[1])]
end

function data_fetch{T}(ring::RingArray{T})
    return rand(T, ring.block_size...)
end

function load_block(ring::RingArray)
    ring.blocks[ring.next_write] = data_fetch(ring)
    ring.range = ring.range.start:ring.range.stop + ring.block_size[1]
    ring.next_write += 1
end

# Util functions

function fix_zero_index(value::Int, s::Int)
    value = value % s
    if value == 0
        return s
    else
        return value
    end
end

function divide(value::Int, s::Int)
    if value % s == 0
        return div(value, s)
    else
        return div(value, s) + 1
    end
end

end

