# RingArrays

[![Build Status](https://travis-ci.org/invenia/RingArrays.jl.svg?branch=develop)](https://travis-ci.org/invenia/RingArrays.jl) [![Build status](https://ci.appveyor.com/api/projects/status/u2yyj9necuobw7o7?svg=true)](https://ci.appveyor.com/project/samuel-massinon-invenia/ringarrays-jl) [![codecov.io](https://codecov.io/github/invenia/RingArrays.jl/coverage.svg?branch=develop)](https://codecov.io/github/invenia/RingArrays.jl?branch=develop)

RingArrays is a way to access a large dataset in incremental chucks to limit the amount of memory you need. You would use a RingArray when you are wanting to work with a massive dataset like an array.

The idea of the RingArray is that is should act like a sliding window on a massive array where the window is the only part of the array you currently care about. The sliding window will move at the pace you tell it too and will contain as much data as you want.

## Read Only

The RingArray is in a read only state. Trying to set a value will throw this error.

```julia
julia> ring[1] = 1
ERROR: indexing not defined for RingArrays.RingArray{Int64,1}
 in setindex! at ./abstractarray.jl:584
 in eval at ./boot.jl:265
```

## Usage

### Creating

Creating a RingArray only needs two values, both of which have default if you pass nothing.

```julia
ring = RingArray{Int, 3}(max_blocks=10, block_size=(10,10,10))
```

`max_block` will determine the most number of blocks the ring array can hold at any time.

`block_size` is the dimension size of the blocks. Each block must have the same size.

### Storing Blocks

RingArrays need there blocks to be loaded manually.

```julia
ring = RingArray{Int, 1}(max_blocks=5, block_size=(2,));
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
```

The output is,

```julia
5-element Array{AbstractArray{Int64,1},1}:
    [3786009800613455090,1882121033597674828]
 #undef                                      
 #undef                                      
 #undef                                      
 #undef                                      
5-element Array{AbstractArray{Int64,1},1}:
    [3786009800613455090,1882121033597674828] 
    [5361907351193705983,-3065296439201106247]
 #undef                                       
 #undef                                       
 #undef  
```
 
As you can see, the first display shows the first block loaded and the second display has the second block loaded too.

#### When loading lots of blocks

When you load more blocks than your RingArray can handle, it will begin to overwrite blocks, starting with the oldest.

```julia
ring = RingArray{Int, 1}(max_blocks=5, block_size=(2,));
for i in 1:4
    data = rand(Int64, ring.block_size);
    load_block(ring, data);
end
display(ring)
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
data = rand(Int64, ring.block_size);
load_block(ring, data);
display(ring)
```

The output is,

```julia
5-element Array{AbstractArray{Int64,1},1}:
    [-5440869056910226509,1048203488083884946]
    [-5465828022146027573,2059040906267543744]
    [-4870925121561723238,7387116789012817270]
    [4235087124507848396,-1752098218431852782]
 #undef                                       
5-element Array{AbstractArray{Int64,1},1}:
 [-5440869056910226509,1048203488083884946] 
 [-5465828022146027573,2059040906267543744] 
 [-4870925121561723238,7387116789012817270] 
 [4235087124507848396,-1752098218431852782] 
 [-7708650732046828053,-5831043268171991420]
5-element Array{AbstractArray{Int64,1},1}:
 [-2394580099307101489,-5939753501841389193]
 [-5465828022146027573,2059040906267543744] 
 [-4870925121561723238,7387116789012817270] 
 [4235087124507848396,-1752098218431852782] 
 [-7708650732046828053,-5831043268171991420]
```

In the last display, we can see that the first row of values have been overwritten by the last load.

### Indexing

A RingArray can be accessed like the array it is 'sliding' over.

```julia
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:6
    load_block(ring, big_array[i:i+1]);
end
display(big_array[3])
display(ring[3])
for i in 7:2:12
    load_block(ring, big_array[i:i+1]);
end
display(big_array[8])
display(ring[8])
for i in 13:2:99
    load_block(ring, big_array[i:i+1]);
end
display(big_array[99])
display(ring[99])
```

The output is,

```julia
8138703126850143818
8138703126850143818
8704347357339359336
8704347357339359336
-1266028625934220613
-1266028625934220613
```

The output shows that the value we get from the RingArray is identical to the value we get from the 'big_array' we are looking at. The difference here is that the RingArray contains a max for `4 * 2 = 8` elements.

#### Range Indexing/Views

You can even use ranges to index into a RingArray, just like the 'big array'.

```julia
ring = RingArray{Int, 1}(max_blocks=4, block_size=(2,));
big_array = rand(Int, 100);
for i in 1:2:6
    load_block(ring, big_array[i:i+1]);
end
display(big_array[3:5])
display(ring[3:5])
for i in 7:2:99
    load_block(ring, big_array[i:i+1]);
end
display(big_array[93:100])
display(ring[93:100])
```

The output is,

```julia
3-element Array{Int64,1}:
  4888954431626633721
  -735569853239964777
 -2209041541700469789
3-element VirtualArrays.VirtualArray{Int64,1}:
  4888954431626633721
  -735569853239964777
 -2209041541700469789
8-element Array{Int64,1}:
 -8890283379952347965
  6099240732283067744
  1774549867342630701
 -7876908337657579670
  -655444807932357004
  6237563287695816159
  9143358181757180448
  5233312637010446397
8-element VirtualArrays.VirtualArray{Int64,1}:
 -8890283379952347965
  6099240732283067744
  1774549867342630701
 -7876908337657579670
  -655444807932357004
  6237563287695816159
  9143358181757180448
  5233312637010446397
```

All the values are the same. One thing to note is that the values returned are stored into a VirtualArray. It should act just like an array you would get from the 'big array' except will save on memory usage.

### Reference Counting

Since views are affected by the sliding window, the RingArray keeps track of the number of views currently exists.

### Expansions

The RingArray expects that the blocks stack on the first dimensions, so that the RingArray will expanded along the first dimension.

## Memory Usage

It is rather difficult to show how little memory a RingArray will take in comparison to its array counterpart. What I was able to show is how much memory a RingArray has in comparison of the array it is sliding along.

```julia
ring = RingArray{Int, 3}(max_blocks=10, block_size=(100,100,100));
big_array = rand(Int, 100000, 100, 100);
for i in 1:100:10000
    load_block(ring, big_array[i:i+99,1:end,1:end]);
end
whos()
for i in 10001:100:100000
    load_block(ring, big_array[i:i+99,1:end,1:end]);
end
whos()
```

The output is, (only showing what's important)

```
.
.
.
                     big_array 7812500 KB     100000x100x100 Array{Int64,3}
                          ring  78125 KB     1000x100x100 RingArrays.RingArray{Int64,3}
.
.
.
                     big_array 7812500 KB     100000x100x100 Array{Int64,3}
                          ring  78125 KB     1000x100x100 RingArrays.RingArray{Int64,3}
.
.
.
```

From the output, we see that in both cases, the RingArray keeps a constant size of `78125 KB` which is much smaller than the 'big array' at `7812500 KB`.