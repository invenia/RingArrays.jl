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
        test = RingArray{Int, 1}(s)

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
        test = RingArray{Int, 1}(s)

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
        @fact_throws test = RingArray{Int, 1}(s)
    end
    context("having a multi dimensional array") do
        s = 10
        b_s = (10,10)
        test = RingArray{Int, 2}(s, b_s)

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
    context("Getting the first value") do
        s = rand(1:10)
        b_s = (rand(1:10),)
        test = RingArray{Int, 1}(s, b_s)

        @fact typeof(test[1]) --> Int
        @fact test[1] --> test.blocks[1][1]
        @fact test[1] --> test[1]
    end
    context("Getting a value in the first block") do
        s = rand(1:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        index = rand(2:b_s[1])

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[1][index]
        @fact test[index] --> test[index]
    end
    context("Getting a value in the second block after getting a value in the first block") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        index = b_s[1] + 1

        test[1] # Need to get a value in the first block first
        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[2][1]
        @fact test[index] --> test[index]
    end
    context("Getting a value in the second block first") do
        s = rand(2:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        index = b_s[1] + 1

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[2][1]
        @fact test[index] --> test[index]
    end
    context("Getting a value in any block first") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        test = RingArray{Int, 1}(s, b_s)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end

    context("Getting value from 2 d array") do
        s = rand(3:10)
        b_s = (rand(1:10),rand(1:10))
        block_picked = rand(3:s)
        index_in_block = (rand(1:b_s[1]), rand(1:b_s[2]))
        index = (index_in_block[1] + (block_picked - 1) * b_s[1], index_in_block[2])

        test = RingArray{Int, 2}(s, b_s)

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
    end
end

facts("Getting values over the length of the RingArray") do
    context("Getting the first value after overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = 1
        index_in_block = 1
        overflow = s * b_s[1]
        index = overflow + 1

        test = RingArray{Int, 1}(s, b_s)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end
    context("Getting any value after overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end
    context("Getting any value after any number of overflows") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        num_overflows = rand(1:10)
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow * num_overflows

        test = RingArray{Int, 1}(s, b_s)

        @fact typeof(test[index]) --> Int
        @fact test[index] --> test.blocks[block_picked][index_in_block]
        @fact test[index] --> test[index]
    end
    context("Getting value from 2 d array after overflowing") do
        s = rand(3:10)
        b_s = (rand(1:10),rand(1:10))
        block_picked = rand(3:s)
        index_in_block = (rand(1:b_s[1]), rand(1:b_s[2]))
        overflow = s * b_s[1]
        index = (index_in_block[1] + (block_picked - 1) * b_s[1] + overflow, index_in_block[2])

        test = RingArray{Int, 2}(s, b_s)

        @fact typeof(test[index...]) --> Int
        @fact test[index...] --> test.blocks[block_picked][index_in_block...]
        @fact test[index...] --> test[index...]
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

        test = RingArray{Int, 1}(s, b_s)

        test[range.stop] # load values

        @fact typeof(test[range]) --> SubArray{Int64,1,RingArrays.RingArray{Int64,1},Tuple{UnitRange{Int64}},0}
        @fact test[range] --> test.blocks[block_picked][range]
        @fact test[range] --> test[range]
    end
    context("looking at a the whole portion of the first block") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        block_picked = 1
        start = 1
        last = b_l
        range = start:last

        test = RingArray{Int, 1}(s, b_s)

        test[range.stop] # load values

        @fact typeof(test[range]) --> SubArray{Int64,1,RingArrays.RingArray{Int64,1},Tuple{UnitRange{Int64}},0}
        @fact test[range] --> test.blocks[block_picked][range]
        @fact test[range] --> test[range]
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

        test = RingArray{Int, 1}(s, b_s)

        test[ring_range.stop] # load values

        @fact typeof(test[ring_range]) --> SubArray{Int64,1,RingArrays.RingArray{Int64,1},Tuple{UnitRange{Int64}},0}
        @fact test[ring_range] --> test.blocks[block_picked][range]
        @fact test[ring_range] --> test[ring_range]
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

        test = RingArray{Int, 1}(s, b_s)

        test[ring_range.stop] # load values
        test[ring_range]

        @fact typeof(test[ring_range]) --> SubArray{Int64,1,RingArrays.RingArray{Int64,1},Tuple{UnitRange{Int64}},0}
        @fact test[ring_range] --> [test.blocks[block_picked][range.start:end]...,
                                    test.blocks[block_picked + 1][1:range.stop - b_l]...]
        @fact test[ring_range] --> test[ring_range]
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

        test = RingArray{Int, 1}(s, b_s)

        test[ring_range.stop] # load values

        @fact typeof(test[ring_range]) --> SubArray{Int64,1,RingArrays.RingArray{Int64,1},Tuple{UnitRange{Int64}},0}
        @fact test[ring_range] --> [test.blocks[block_picked][range.start:end]...,
                                    test.blocks[block_picked + 1][1:range.stop - b_l]...]
        @fact test[ring_range] --> test[ring_range]
    end
end

facts("Using checkbounds)") do
    context("checking bounds before overflow without overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        index = index_in_block + (block_picked - 1) * b_s[1]

        test = RingArray{Int, 1}(s, b_s)

        @fact checkbounds(test, index) --> true
    end
    context("checking bounds after overflow without overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        @fact checkbounds(test, index) --> true
    end
    context("checking bounds after overflow with overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]
        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        test[index] # overflowing

        @fact checkbounds(test, index) --> true
    end
    context("checking bounds before overflow with overflowing") do
        s = rand(3:10)
        b_s = (rand(2:10),)
        block_picked = rand(3:s)
        index_in_block = rand(1:b_s[1])
        overflow = s * b_s[1]

        index = index_in_block + (block_picked - 1) * b_s[1] + overflow

        test = RingArray{Int, 1}(s, b_s)

        test[index] # overflowing

        @fact_throws BoundsError checkbounds(test, 1)
    end
    context("checking unit range bounds before overflow without overflowing") do
        s = rand(3:10)
        b_l = rand(1:10)
        b_s = (b_l,)
        start = rand(1:b_l)
        last = rand(start:b_l) + b_l
        range = start:last

        test = RingArray{Int, 1}(s, b_s)

        @fact checkbounds(test, range) --> true
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

        test = RingArray{Int, 1}(s, b_s)

        @fact checkbounds(test, ring_range) --> true
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

        test = RingArray{Int, 1}(s, b_s)

        test[ring_range.stop] # overflowing

        @fact checkbounds(test, ring_range) --> true
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

        test = RingArray{Int, 1}(s, b_s)

        test[ring_range.stop] # overflowing

        @fact_throws BoundsError checkbounds(test, 1:overflow)
    end
end