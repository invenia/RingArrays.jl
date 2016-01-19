module RingArrays

import Base.size, Base.getindex, Base.checkbounds, Base.display
export RingArray, size, checkbounds, display

type RingArrayOld{T, N} <: AbstractArray{T, N}
    data_type::Type
    data_dimensions::Int
    buffer_dim::Int
    block_size::Tuple
    block_length::Int
    max_blocks::Int
    blocks::Array
end

type RingArray{T, N} <: AbstractArray{T, N}
    next_write::Int
    max_blocks::Int
    blocks::Array{AbstractArray{T, N}, 1}
    num_users::Array{Int, 1}
    block_size::Tuple
    block_length::Int
    range::UnitRange{Int}

    function RingArray(max_blocks::Int, block_size::Tuple)
        return new(1, max_blocks,
            Array{AbstractArray{T, N}, 1}(max_blocks),
            zeros(Int, max_blocks), block_size,
            block_size[1], 1:0)
    end
    function RingArray(max_blocks::Int)
        block_size = (10,)
        return new(1, max_blocks,
            Array{AbstractArray{T, N}, 1}(max_blocks),
            zeros(Int, max_blocks), block_size,
            block_size[1], 1:0)
    end
    function RingArray()
        max_blocks = 10
        block_size = (10,)
        return new(1, max_blocks,
            Array{AbstractArray{T, N}, 1}(max_blocks),
            zeros(Int, max_blocks), block_size,
            block_size[1], 1:0)
    end
end

function display(ring::RingArray)
    display(ring.blocks)
end

function size{T, N}(ring::RingArray{T, N})
    if N <= 1
        return tuple(ring.block_length * ring.max_blocks,)
    else
        return tuple(ring.block_length * ring.max_blocks, ring.block_size[2:end]...)
    end
end

checkbounds(ring::RingArray) = true # because of warnings

function checkbounds(ring::RingArray, indexes::UnitRange{Int64}...)

    if ring.range.start > indexes[1].start
        throw(BoundsError(ring, indexes))
    end
    return true
end

function checkbounds(ring::RingArray, indexes::Int...)

    if ring.range.start > indexes[1]
        throw(BoundsError(ring, indexes))
    end
    return true
end

getindex(ring::RingArray) = nothing # Warnings told me to make this

function getindex(ring::RingArray, i::Int...)
    result = 0

    while ring.range.stop < i[1]
        load_block(ring)
    end

    block_index = fix_zero_index(divide(i[1], ring.block_length), ring.max_blocks)
    index = collect([fix_zero_index(i[1], ring.block_length), i[2:end]...])

    return ring.blocks[block_index][index...]
end

function getindex(ring::RingArray, i::UnitRange...)
    return sub(ring, i...)
end

function data_fetch{T}(ring::RingArray{T})
    return rand(T, ring.block_size...)
end

function load_block(ring::RingArray)
    ring.blocks[ring.next_write] = data_fetch(ring)
    ring.next_write = fix_zero_index(ring.next_write + 1, ring.max_blocks)

    if ring.range.stop < ring.max_blocks * ring.block_length
        ring.range = ring.range.start:ring.range.stop + ring.block_length
    else
        ring.range = ring.range.start + ring.block_length:ring.range.stop + ring.block_length
    end
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

