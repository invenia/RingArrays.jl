module RingArrays

using VirtualArrays

import Base: size, getindex, checkbounds, display, RefValue, showerror, eachindex
export RingArray, size, checkbounds, display
export OverwriteError, getindex, load_block
export showerror, eachindex, RingArrayBoundsError

type RingArray{T, N} <: AbstractArray{T, N}
    next_write::Int
    max_blocks::Int
    blocks::Array{AbstractArray{T, N}, 1}
    num_users::Array{Int, 1}
    block_size::Tuple
    block_length::Int
    range::UnitRange{Int}
    data_length::Int

    function RingArray(;max_blocks::Int=10, block_size::Tuple=(10,), data_length::Int=100)
        if length(block_size) != N
            throw(DimensionMismatch("block size $(block_size) does not match dimension of RingArray $(N)"))
        end
        return new(1, max_blocks,
            Array{AbstractArray{T, N}, 1}(max_blocks),
            zeros(Int, max_blocks), block_size,
            block_size[1], 1:0, data_length)
    end
end

type OverwriteError <: Exception
    ring::RingArray
end

type RingArrayBoundsError <: Exception
    ring::RingArray
    i
end

function showerror(io::IO, err::OverwriteError)
    next_write = err.ring.next_write
    num_users = err.ring.num_users[err.ring.next_write]
    print(io, "OverwriteError: Cannot overwrite block $(next_write) since it has $(num_users) views")
end

function showerror(io::IO, err::RingArrayBoundsError)
    range = tuple(err.ring.range, err.ring.block_size[2:end]...)
    print(io, "RingArrayBoundsError: Cannot index $(err.i), outside of range $range")
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

function checkbounds{T, N}(ring::RingArray{T, N}, indexes::UnitRange{Int64}...)

    if ring.range.start > indexes[1].start || ring.range.stop < indexes[1].stop
        throw(RingArrayBoundsError(ring, indexes))
    else
        for i in 2:N
            if 1 > indexes[i].start || ring.block_size[i] < indexes[i].stop
                throw(RingArrayBoundsError(ring, indexes))
            end
        end
    end
    return true
end

function checkbounds{T, N}(ring::RingArray{T, N}, indexes::Int...)

    if ring.range.start > indexes[1] || ring.range.stop < indexes[1]
        throw(RingArrayBoundsError(ring, indexes))
    else
        for i in 2:N
            if 1 > indexes[i] || ring.block_size[i] < indexes[i]
                throw(RingArrayBoundsError(ring, indexes))
            end
        end
    end
    return true
end

getindex(ring::RingArray) = nothing # Warnings told me to make this

function getindex(ring::RingArray, i::Int...)
    check_index(ring, i...)
    checkbounds(ring, i...)
    result = 0

    block_index = fix_zero_index(divide(i[1], ring.block_length), ring.max_blocks)
    index = collect([fix_zero_index(i[1], ring.block_length), i[2:end]...])

    return ring.blocks[block_index][index...]
end

function getindex(ring::RingArray, i::UnitRange...)
    check_index(ring, i...)
    checkbounds(ring, i...)
    add_users(ring, i...)
    return get_view(ring, i...)
end

function load_block{T, N}(ring::RingArray{T ,N}, block::AbstractArray{T, N})
    check_dimensions(ring, block)
    if ring.num_users[ring.next_write] > 0
        gc()
        if ring.num_users[ring.next_write] > 0
            throw(OverwriteError(ring))
        end
    end

    ring.blocks[ring.next_write] = block
    ring.next_write = fix_zero_index(ring.next_write + 1, ring.max_blocks)

    if ring.range.stop < ring.max_blocks * ring.block_length
        ring.range = ring.range.start:ring.range.stop + ring.block_length
    else
        ring.range = ring.range.start + ring.block_length:ring.range.stop + ring.block_length
    end
    nothing
end

# Util functions

function check_index{T, N}(ring::RingArray{T, N}, i...)
    if length(i) != N
        throw(ErrorException("$i does not match $N dimensions"))
    end
end

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

function add_users(ring::RingArray, i::UnitRange...)

    first_block = divide(i[1].start, ring.block_length)
    last_block = divide(i[1].stop, ring.block_length)

    for i in first_block:last_block
        block_index = fix_zero_index(i, ring.max_blocks)
        ring.num_users[block_index] += 1
    end

end

function remove_users(ring::RingArray, i::UnitRange...)

    first_block = divide(i[1].start, ring.block_length)
    last_block = divide(i[1].stop, ring.block_length)

    for i in first_block:last_block
        block_index = fix_zero_index(i, ring.max_blocks)
        ring.num_users[block_index] -= 1
    end

end

function get_view(ring::RingArray, i::UnitRange...)

    view = virtual_vcat(sub(ring, i...))

    first_block = divide(i[1].start, ring.block_length)
    last_block = divide(i[1].stop, ring.block_length)

    function when_done(view)
        remove_users(ring, i...)
    end

    finalizer(view, when_done)

    return view
end

function check_dimensions(ring::RingArray, block::AbstractArray)
    if ring.block_size != size(block)
        throw(DimensionMismatch("block size $(size(block)) does not match what RingArray expects $(ring.block_size)"))
    end
end

end

