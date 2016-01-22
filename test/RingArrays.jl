facts("About creating RingArray") do
    context("bad curly braces") do
        @fact_throws MethodError test = RingArray{Any}()
    end
    context("without curly braces") do
        @fact_throws MethodError RingArray()
    end

    context("passing a size") do
        s = rand(1:10)
        b_s = (10,)
        test = RingArray{Int, 1}(max_blocks=s)

        @fact isdefined(test.blocks, 1:s...) --> false
        @pending test.blocks --> Array{AbstractArray{Int64,1},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s,)
    end
    context("passing a block size") do
        s = 10
        b_s = (10,)
        test = RingArray{Int, 1}(block_size=b_s)

        @fact isdefined(test.blocks, 1:s...) --> false
        @pending test.blocks --> Array{AbstractArray{Int64,1},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s,)
    end
    context("passing nothing") do
        s = 10
        b_s = (10,)
        test = RingArray{Int, 1}()

        @pending test.blocks --> Array{AbstractArray{Int64,1},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s,)
    end
    context("passing 0 for size") do
        s = 0
        b_s = (10,)
        test = RingArray{Int, 1}(max_blocks=s)

        @pending test.blocks --> Array{AbstractArray{Int64,1},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s,)
    end
    context("passing a negative for size") do
        s = -1
        @fact_throws test = RingArray{Int, 1}(max_blocks=s)
    end
    context("having a multi dimensional array") do
        s = 10
        b_s = (10,10)
        test = RingArray{Int, 2}(max_blocks=s, block_size=b_s)

        @pending test.blocks --> Array{AbstractArray{Int64,2},1}()
        @fact test.max_blocks --> s
        @fact test.next_write --> 1
        @fact test.num_users --> zeros(Int, s)
        @fact test.block_size --> b_s
        @fact test.range --> 1:0
        @fact size(test) --> tuple(b_s[1]*s, b_s[2:end]...)
    end
end

facts("Getting values from RingArray") do
    context("getting the first value") do
        s = rand(1:10)
        b_s = (rand(1:10),)
        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[1]) --> Int
        @fact test[1] --> test.blocks[1][1]
        @fact test[1] --> test[1]
        @fact test[] --> nothing
        @fact test[test.range] --> expected[test.range]
    end
    context("getting the first value without loading") do
        s = rand(1:10)
        b_s = (rand(1:10),)
        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        @fact_throws BoundsError test[1]
    end
    context("getting a value in the first block") do
        s = rand(1:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)
        index = rand(2:b_s[1])

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[1][index]
        @fact test[index] --> test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting a value in the second block after getting a value in the first block") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)
        index = b_s[1] + 1

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        test[1] # Need to get a value in the first block first
        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[2][1]
        @fact test[index] --> test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting a value in the second block first") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)
        index = b_s[1] + 1

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[2][1]
        @fact test[index] --> test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting a value in the second block first while only loading the first block") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)
        index = b_s[1] + 1

        expected = []
        for i in 1:1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact_throws BoundsError test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting a value in any block first") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting value from 2 d array") do
        s = rand(3:10)
        b_s = (rand(1:10),rand(1:10))
        block_picked = rand(3:s)
        index_in_block = (rand(1:b_s[1]), rand(1:b_s[2]))
        index = (index_in_block[1] + (block_picked - 1) * b_s[1], index_in_block[2])

        test = RingArray{Int, 2}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
        @fact test[test.range, 1:b_s[2]] --> expected[test.range, 1:b_s[2]]
    end
    context("getting value from 2 d array like a 1 d array") do
        s = rand(3:10)
        b_s = (rand(1:10),rand(1:10))
        block_picked = rand(3:s)
        index_in_block = (rand(1:b_s[1]))
        index = (index_in_block[1] + (block_picked - 1) * b_s[1])

        test = RingArray{Int, 2}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact_throws ErrorException test[index...]
    end
    context("getting value from N d array") do
        s = rand(3:10)
        num_dimensions = rand(3:6)
        b_s = []
        for i in 1:num_dimensions
            push!(b_s, rand(1:10))
        end
        b_s = tuple(b_s...)
        block_picked = rand(3:s)
        index_in_block = []
        for i in 1:num_dimensions
            push!(index_in_block, rand(1:b_s[i]))
        end
        index = (index_in_block[1] + (block_picked - 1) * b_s[1], index_in_block[2:end]...)

        test = RingArray{Int, num_dimensions}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        ranges = []
        for i in 2:num_dimensions
            push!(ranges, 1:b_s[i])
        end

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
        @fact test[test.range, ranges...] --> expected[test.range, ranges...]
    end
end

facts("Getting values over the length (overflow) of the RingArray") do
    context("getting the first value after overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = 1
        index_in_block = 1
        overflow = s * b_s[1]
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting the first value after overflowing with only before overflow") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = 1
        index_in_block = 1
        overflow = s * b_s[1]
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1]
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact_throws BoundsError test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting any value after overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting any value after any number of overflows") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow * num_overflows

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
        @fact test[test.range] --> expected[test.range]
    end
    context("getting value from 2 d array after overflowing") do
        s = rand(3:10)
        b_s = (rand(1:10),rand(1:10))
        block_picked = rand(3:s)
        index_in_block = (rand(1:b_s[1]), rand(1:b_s[2]))
        overflow = s * b_s[1]
        index = (index_in_block[1] + (block_picked - 1) * b_s[1] + overflow, index_in_block[2])

        test = RingArray{Int, 2}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index[1] ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
        @fact test[test.range, 1:b_s[2]] --> expected[test.range, 1:b_s[2]]
    end
    context("getting value from N d array after any number of overflows") do
        s = rand(3:10)
        num_dimensions = rand(3:6)
        b_s = []
        for i in 1:num_dimensions
            push!(b_s, rand(1:10))
        end
        b_s = tuple(b_s...)
        block_picked = rand(3:s)
        index_in_block = []
        for i in 1:num_dimensions
            push!(index_in_block, rand(1:b_s[i]))
        end
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        index = (index_in_block[1] + (block_picked - 1) * b_s[1] + overflow * num_overflows, index_in_block[2:end]...)

        test = RingArray{Int, num_dimensions}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index[1] ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        ranges = []
        for i in 2:num_dimensions
            push!(ranges, 1:b_s[i])
        end

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
        @fact test[test.range, ranges...] --> expected[test.range, ranges...]
    end
end

facts("Getting data views") do
    context("looking at a small portion of the first block") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = 1
        start = rand(1:b_l)
        last = rand(start:b_l)
        range = start:last

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[range] --> test.blocks[block_picked][range]
        @fact test[range] --> test[range]
        @fact test[test.range] --> expected[test.range]
    end
    context("looking at a small portion of the first block without loading") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = 1
        start = rand(1:b_l)
        last = rand(start:b_l)
        range = start:last

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        @fact_throws BoundsError test[range]
    end
    context("looking at a the whole portion of the first block") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = 1
        start = 1
        last = b_l
        range = start:last

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[range] --> test.blocks[block_picked][range]
        @fact test[range] --> test[range]
        @fact test[test.range] --> expected[test.range]
    end
    context("looking at a small portion of any block") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s)
        start = rand(1:b_l)
        last = rand(start:b_l)
        range = start:last
        ring_range = range + (block_picked - 1) * b_l

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[ring_range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[ring_range] --> test.blocks[block_picked][range]
        @fact test[ring_range] --> test[ring_range]
        @fact test[test.range] --> expected[test.range]
    end
    context("looking at a small portion of two blocks") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        ring_range = range + (block_picked - 1) * b_l

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[ring_range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[ring_range] --> [test.blocks[block_picked][range.start:end]...,
                                    test.blocks[block_picked + 1][1:range.stop - b_l]...]
        @fact test[ring_range] --> test[ring_range]
        @fact test[test.range] --> expected[test.range]
    end
    context("looking at a portion of two blocks at overflow") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = range + (block_picked - 1) * b_l

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[ring_range]) --> VirtualArrays.VirtualArray{Int64,1}
        @fact test[ring_range] --> [test.blocks[block_picked][range.start:end]...,
                                    test.blocks[block_picked + 1][1:range.stop - b_l]...]
        @fact test[ring_range] --> test[ring_range]
        @fact test[test.range] --> expected[test.range]
    end
    context("looking at a portion of two blocks at overflow of a 2d ring array") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_w = rand(1:10)
        b_s = (b_l,b_w)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = (start:last,1:b_w)
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = (range[1] + (block_picked - 1) * b_l, 1:b_w)

        test = RingArray{Int, 2}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range[1].stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[ring_range...]) --> VirtualArrays.VirtualArray{Int64,2}
        @fact test[ring_range...] --> [test.blocks[block_picked][range[1].start:end, range[2]];
                                    test.blocks[block_picked + 1][1:range[1].stop - b_l, range[2]]]
        @fact test[ring_range...] --> test[ring_range...]
        @fact test[test.range, 1:b_w] --> expected[test.range, 1:b_w]
    end
    context("looking at a portion from one block from N d array after any number of overflows") do
        s = rand(3:10)
        num_dimensions = rand(3:6)
        b_s = []
        for i in 1:num_dimensions
            push!(b_s, rand(1:10))
        end
        b_s = tuple(b_s...)
        block_picked = rand(3:s)
        index_in_block = []
        for i in 1:num_dimensions
            push!(index_in_block, rand(1:b_s[i]))
        end
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ranges = []
        for i in 1:num_dimensions
            start = rand(1:b_s[i])
            last = rand(start:b_s[i])
            push!(ranges, start:last)
        end
        ring_range = (ranges[1] + (block_picked - 1) * b_s[1] + overflow * num_overflows, ranges[2:end]...)

        test = RingArray{Int, num_dimensions}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range[1].stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact typeof(test[ring_range...]) --> VirtualArrays.VirtualArray{Int64, num_dimensions}
        @fact test[ring_range...] --> test.blocks[block_picked][ranges...]
        @fact test[ring_range...] --> test[ring_range...]

        ranges = []
        for i in 2:num_dimensions
            push!(ranges, 1:b_s[i])
        end

        @fact test[test.range, ranges...] --> expected[test.range, ranges...]
    end
end

facts("Using checkbounds") do
    context("checking bounds before overflow without overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact checkbounds(test, index) --> true
        @fact checkbounds(test) --> true
        @fact test[test.range] --> expected[test.range]
    end
    context("checking bounds after overflow without overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact checkbounds(test, index) --> true
        @fact test[test.range] --> expected[test.range]
    end
    context("checking bounds after overflow with overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact checkbounds(test, index) --> true
        @fact test[test.range] --> expected[test.range]
    end
    context("checking bounds before overflow with overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]

        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact_throws BoundsError checkbounds(test, 1)
        @fact test[test.range] --> expected[test.range]
    end
    context("checking unit range bounds before overflow without overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact checkbounds(test, range) --> true
        @fact test[test.range] --> expected[test.range]
    end
    context("checking unit range bounds after overflow without overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        ring_range = range + (block_picked - 1) * b_l + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact checkbounds(test, ring_range) --> true
        @fact test[test.range] --> expected[test.range]
    end
    context("checking unit range bounds after overflow with overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = range + (block_picked - 1) * b_l + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact checkbounds(test, ring_range) --> true
        @fact test[test.range] --> expected[test.range]
    end
    context("checking unit range bounds before overflow with overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = rand(2:s-1)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        ring_range = range + (block_picked - 1) * b_l + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:ring_range.stop ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact_throws BoundsError checkbounds(test, 1:overflow)
        @fact test[test.range] --> expected[test.range]
    end
    context("checking unit range bounds that exceed the length of the ring") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        overflow = s * b_s[1]

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:s
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end

        @fact_throws BoundsError checkbounds(test, 1:overflow + 1)

        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])
        expected = cat(1, expected...)

        @fact_throws BoundsError checkbounds(test, 1:overflow + 1)
        @fact test[test.range] --> expected[test.range]
    end
end

facts("Using display") do
    context("trying display on a typical RingArray") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        @fact display(test) --> nothing
    end
end

facts("Using views") do
    context("having the RingArray overflow when no views in use") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[test.range] --> expected[test.range]
    end
    context("having the RingArray overflow when first block is in use") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])

        view = test[1:1]

        for i in 2:overflow ÷ b_s[1]
            push!(expected, rand(Int, test.block_size))
            @fact load_block(test, expected[end]) --> nothing
        end
        expected = cat(1, expected...)

        @fact_throws OverwriteError load_block(test, rand(Int, test.block_size))
        @fact view --> test[1:1]
        @fact test[test.range] --> expected[test.range]
    end
    context("having the RingArray overflow to the first block when second block is in use") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        for i in 1:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            load_block(test, expected[end])
        end
        expected = cat(1, expected...)

        view = test[b_l + 1:b_l + 1]

        @fact test[index] --> test.blocks[1][1]
        @fact test[test.range] --> expected[test.range]
    end
    context("having a view that goes out of scope and run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])

        let
            local view = test[1:1]
        end

        gc()

        for i in 2:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            @fact load_block(test, expected[end]) --> nothing
        end
        expected = cat(1, expected...)

        @fact test[index] --> test.blocks[1][1]
        @fact test[test.range] --> expected[test.range]
    end
    context("having a view that goes out of scope don't run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])

        let
            local view = test[1:1]
        end

        for i in 2:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            @fact load_block(test, expected[end]) --> nothing
        end
        expected = cat(1, expected...)

        @fact test[index] --> test.blocks[1][1]
        @fact test[test.range] --> expected[test.range]
    end
    context("having many views that goes out of scope don't run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])

        let
            for i in 1:rand(100:200)
                local view = test[1:1]
            end
        end

        for i in 2:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            @fact load_block(test, expected[end]) --> nothing
        end
        expected = cat(1, expected...)

        @fact test[index] --> test.blocks[1][1]
        @fact test[test.range] --> expected[test.range]
    end
    context("having a view that stays and many views that goes out of scope don't run gc") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])

        view = test[1:1]
        let
            for i in 1:rand(100:200)
                local view = test[1:1]
            end
        end

        for i in 2:index ÷ b_s[1]
            push!(expected, rand(Int, test.block_size))
            @fact load_block(test, expected[end]) --> nothing
        end
        expected = cat(1, expected...)

        @fact_throws OverwriteError load_block(test, rand(Int, test.block_size))
        @fact view --> test[1:1]
        @fact test[test.range] --> expected[test.range]
    end
    context("having the RingArray overflow to the first block when second block is in use") do
        s = rand(3:10)
        b_l = rand(2:10)
        b_s = (b_l,)
        overflow = s * b_l
        index = overflow + 1

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        expected = []
        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])
        push!(expected, rand(Int, test.block_size))
        load_block(test, expected[end])

        view = test[b_l + 1:b_l + 1]

        for i in 3:index ÷ b_s[1] + 1
            push!(expected, rand(Int, test.block_size))
            @fact load_block(test, expected[end]) --> nothing
        end
        expected = cat(1, expected...)

        @fact test[index] --> test.blocks[1][1]
        @fact test[test.range] --> expected[test.range]
    end
end

############################################################################################
# LOADING BLOCKS
############################################################################################

facts("Loading blocks in RingArray") do
    context("loading the first block") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        @fact load_block(test, rand(Int, test.block_size)) --> nothing
    end
    context("loading lots of blocks") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        for i in 1:100
            @fact load_block(test, rand(Int, test.block_size)) --> nothing
        end
    end
    context("loading a block of different size") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        wrong_size = (test.block_size[1] + 1,)

        @fact_throws DimensionMismatch load_block(test, rand(Int, wrong_size))

        test_error = 1
        try
            load_block(test, rand(Int, wrong_size))
        catch e
            test_error = e
        end

        @fact test_error.msg --> "block size $(wrong_size) does not match what RingArray expects $(b_s)"
    end
    context("loading a block of different dimensions") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(max_blocks=s, block_size=b_s)

        wrong_size = (test.block_size[1], test.block_size[1])

        @fact_throws MethodError load_block(test, rand(Int, wrong_size))
    end
end
