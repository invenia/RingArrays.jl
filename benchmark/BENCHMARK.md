## Benchmarking VirtualArray

Checking the performance of VirtualArray

### To run these BenchMarks

You need `Benchmark.jl`, which you can get [here](https://github.com/johnmyleswhite/Benchmark.jl).

In the `RingArray` directory, run `julia benchmark/benchmark.jl`. 

The results of that tests are stored in [benchmark_result](benchmark_result).

### Test Ran

The code I used to benchmark can be found [here](benchmark.jl).

### Results

The results of the test are [here](benchmark_result) and below.

```
################################################################################
# constructor
################################################################################

1x12 DataFrames.DataFrame
| Row | Category      | Benchmark                                                            | Iterations | TotalWall | AverageWall |
|-----|---------------|----------------------------------------------------------------------|------------|-----------|-------------|
| 1   | "constructor" | "RingArray{Int, 1}(max_blocks=m_b, block_size=b_s, data_length=d_l)" | 100        | 6.7164e-5 | 6.7164e-7   |

| Row | MaxWall  | MinWall | Timestamp             | JuliaHash                                  |
|-----|----------|---------|-----------------------|--------------------------------------------|
| 1   | 6.966e-6 | 4.65e-7 | "2016-01-28 15:19:33" | "d4749d2ca168413f3db659950a1855530b58686d" |

| Row | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|----------|----------|
| 1   | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |


################################################################################
# load_block
################################################################################

1x12 DataFrames.DataFrame
| Row | Category             | Benchmark    | Iterations | TotalWall | AverageWall | MaxWall  | MinWall   | Timestamp             |
|-----|----------------------|--------------|------------|-----------|-------------|----------|-----------|-----------------------|
| 1   | "loading with no gc" | "load_block" | 100        | 7.21724   | 0.0721724   | 0.142635 | 0.0420736 | "2016-01-28 15:19:41" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category          | Benchmark    | Iterations | TotalWall | AverageWall | MaxWall  | MinWall  | Timestamp             |
|-----|-------------------|--------------|------------|-----------|-------------|----------|----------|-----------------------|
| 1   | "loading with gc" | "load_block" | 100        | 11.3918   | 0.113918    | 0.125475 | 0.107264 | "2016-01-28 15:19:53" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |

2x4 DataFrames.DataFrame
| Row | Function          | Average   | Relative | Replications |
|-----|-------------------|-----------|----------|--------------|
| 1   | "loading_no_gc"   | 0.0710352 | 1.0      | 100          |
| 2   | "loading_with_gc" | 0.111946  | 1.57593  | 100          |


################################################################################
# size
################################################################################

1x12 DataFrames.DataFrame
| Row | Category          | Benchmark          | Iterations | TotalWall | AverageWall | MaxWall | MinWall | Timestamp             |
|-----|-------------------|--------------------|------------|-----------|-------------|---------|---------|-----------------------|
| 1   | "size empty ring" | "size(empty_ring)" | 100        | 2.8738e-5 | 2.8738e-7   | 9.19e-7 | 2.75e-7 | "2016-01-28 15:20:12" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category         | Benchmark         | Iterations | TotalWall | AverageWall | MaxWall  | MinWall | Timestamp             |
|-----|------------------|-------------------|------------|-----------|-------------|----------|---------|-----------------------|
| 1   | "size full ring" | "size(full_ring)" | 100        | 3.0147e-5 | 3.0147e-7   | 2.392e-6 | 2.48e-7 | "2016-01-28 15:20:12" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category        | Benchmark        | Iterations | TotalWall | AverageWall | MaxWall | MinWall | Timestamp             |
|-----|-----------------|------------------|------------|-----------|-------------|---------|---------|-----------------------|
| 1   | "size end ring" | "size(end_ring)" | 100        | 2.6197e-5 | 2.6197e-7   | 6.78e-7 | 2.53e-7 | "2016-01-28 15:20:12" |

| Row | JuliaHash                                  | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|--------------------------------------------|----------|----------|
| 1   | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |

3x4 DataFrames.DataFrame
| Row | Function           | Average   | Relative | Replications |
|-----|--------------------|-----------|----------|--------------|
| 1   | "size_empty_bench" | 2.7462e-7 | 1.04506  | 100          |
| 2   | "size_full_bench"  | 2.6345e-7 | 1.00255  | 100          |
| 3   | "size_end_bench"   | 2.6278e-7 | 1.0      | 100          |


################################################################################
# checkbounds
################################################################################

1x12 DataFrames.DataFrame
| Row | Category                | Benchmark                                      | Iterations | TotalWall | AverageWall | MaxWall  |
|-----|-------------------------|------------------------------------------------|------------|-----------|-------------|----------|
| 1   | "checkbounds full ring" | "checkbounds(full_ring, full_ring.range.stop)" | 100        | 7.7897e-5 | 7.7897e-7   | 4.412e-6 |

| Row | MinWall | Timestamp             | JuliaHash                                  | CodeHash                                   |
|-----|---------|-----------------------|--------------------------------------------|--------------------------------------------|
| 1   | 6.35e-7 | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" |

| Row | OS       | CPUCores |
|-----|----------|----------|
| 1   | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category               | Benchmark                                    | Iterations | TotalWall | AverageWall | MaxWall |
|-----|------------------------|----------------------------------------------|------------|-----------|-------------|---------|
| 1   | "checkbounds end ring" | "checkbounds(end_ring, end_ring.range.stop)" | 100        | 6.9562e-5 | 6.9562e-7   | 2.2e-6  |

| Row | MinWall | Timestamp             | JuliaHash                                  | CodeHash                                   |
|-----|---------|-----------------------|--------------------------------------------|--------------------------------------------|
| 1   | 6.44e-7 | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" |

| Row | OS       | CPUCores |
|-----|----------|----------|
| 1   | "Darwin" | 4        |

2x4 DataFrames.DataFrame
| Row | Function                 | Average   | Relative | Replications |
|-----|--------------------------|-----------|----------|--------------|
| 1   | "checkbounds_full_bench" | 7.1057e-7 | 1.01951  | 100          |
| 2   | "checkbounds_end_bench"  | 6.9697e-7 | 1.0      | 100          |


################################################################################
# getindex
################################################################################

1x12 DataFrames.DataFrame
| Row | Category                   | Benchmark                          | Iterations | TotalWall   | AverageWall | MaxWall   | MinWall |
|-----|----------------------------|------------------------------------|------------|-------------|-------------|-----------|---------|
| 1   | "getindex full start ring" | "full_ring[full_ring.range.start]" | 100        | 0.000427423 | 4.27423e-6  | 3.8783e-5 | 3.28e-6 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

1x12 DataFrames.DataFrame
| Row | Category                  | Benchmark                         | Iterations | TotalWall   | AverageWall | MaxWall   | MinWall  |
|-----|---------------------------|-----------------------------------|------------|-------------|-------------|-----------|----------|
| 1   | "getindex full stop ring" | "full_ring[full_ring.range.stop]" | 100        | 0.000394303 | 3.94303e-6  | 1.2161e-5 | 3.307e-6 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

1x12 DataFrames.DataFrame
| Row | Category                  | Benchmark                        | Iterations | TotalWall   | AverageWall | MaxWall  | MinWall  |
|-----|---------------------------|----------------------------------|------------|-------------|-------------|----------|----------|
| 1   | "getindex end start ring" | "end_ring[end_ring.range.start]" | 100        | 0.000374736 | 3.74736e-6  | 7.281e-6 | 3.262e-6 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

1x12 DataFrames.DataFrame
| Row | Category                 | Benchmark                       | Iterations | TotalWall   | AverageWall | MaxWall  | MinWall  |
|-----|--------------------------|---------------------------------|------------|-------------|-------------|----------|----------|
| 1   | "getindex end stop ring" | "end_ring[end_ring.range.stop]" | 100        | 0.000393454 | 3.93454e-6  | 9.205e-6 | 3.295e-6 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

4x4 DataFrames.DataFrame
| Row | Function                    | Average    | Relative | Replications |
|-----|-----------------------------|------------|----------|--------------|
| 1   | "getindex_full_start_bench" | 3.90207e-6 | 1.01897  | 100          |
| 2   | "getindex_full_stop_bench"  | 3.82943e-6 | 1.0      | 100          |
| 3   | "getindex_end_start_bench"  | 4.586e-6   | 1.19757  | 100          |
| 4   | "getindex_end_stop_bench"   | 3.95185e-6 | 1.03197  | 100          |


################################################################################
# getindex range
################################################################################

1x12 DataFrames.DataFrame
| Row | Category                       | Benchmark                    | Iterations | TotalWall | AverageWall | MaxWall   | MinWall     |
|-----|--------------------------------|------------------------------|------------|-----------|-------------|-----------|-------------|
| 1   | "getindex range full all ring" | "full_ring[full_ring.range]" | 100        | 0.0305535 | 0.000305535 | 0.0004867 | 0.000272477 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

1x12 DataFrames.DataFrame
| Row | Category                         | Benchmark                                              | Iterations | TotalWall   |
|-----|----------------------------------|--------------------------------------------------------|------------|-------------|
| 1   | "getindex range full small ring" | "full_ring[full_ring.range.stop:full_ring.range.stop]" | 100        | 0.000934145 |

| Row | AverageWall | MaxWall   | MinWall  | Timestamp             | JuliaHash                                  |
|-----|-------------|-----------|----------|-----------------------|--------------------------------------------|
| 1   | 9.34145e-6  | 1.3448e-5 | 7.977e-6 | "2016-01-28 15:20:12" | "d4749d2ca168413f3db659950a1855530b58686d" |

| Row | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|----------|----------|
| 1   | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |

1x12 DataFrames.DataFrame
| Row | Category                      | Benchmark                  | Iterations | TotalWall | AverageWall | MaxWall     | MinWall     |
|-----|-------------------------------|----------------------------|------------|-----------|-------------|-------------|-------------|
| 1   | "getindex range end all ring" | "end_ring[end_ring.range]" | 100        | 0.0314237 | 0.000314237 | 0.000625633 | 0.000296412 |

| Row | Timestamp             | JuliaHash                                  | CodeHash                                   | OS       |
|-----|-----------------------|--------------------------------------------|--------------------------------------------|----------|
| 1   | "2016-01-28 15:20:13" | "d4749d2ca168413f3db659950a1855530b58686d" | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" |

| Row | CPUCores |
|-----|----------|
| 1   | 4        |

1x12 DataFrames.DataFrame
| Row | Category                        | Benchmark                                      | Iterations | TotalWall   | AverageWall |
|-----|---------------------------------|------------------------------------------------|------------|-------------|-------------|
| 1   | "getindex range end small ring" | "end_ring[end_ring.range:end_ring.range.stop]" | 100        | 0.000909918 | 9.09918e-6  |

| Row | MaxWall   | MinWall  | Timestamp             | JuliaHash                                  |
|-----|-----------|----------|-----------------------|--------------------------------------------|
| 1   | 1.3783e-5 | 8.017e-6 | "2016-01-28 15:20:13" | "d4749d2ca168413f3db659950a1855530b58686d" |

| Row | CodeHash                                   | OS       | CPUCores |
|-----|--------------------------------------------|----------|----------|
| 1   | "27d731430227c905f6f83198ad4c533d0aba4c43" | "Darwin" | 4        |

4x4 DataFrames.DataFrame
| Row | Function                          | Average     | Relative | Replications |
|-----|-----------------------------------|-------------|----------|--------------|
| 1   | "getindex_range_full_all_bench"   | 0.000435494 | 53.1101  | 100          |
| 2   | "getindex_range_full_small_bench" | 8.19982e-6  | 1.0      | 100          |
| 3   | "getindex_range_end_all_bench"    | 0.000338306 | 41.2578  | 100          |
| 4   | "getindex_range_end_small_bench"  | 8.68784e-6  | 1.05952  | 100          |


################################################################################
# overall
################################################################################

16x4 DataFrames.DataFrame
| Row | Function                          | Average     | Relative  | Replications |
|-----|-----------------------------------|-------------|-----------|--------------|
| 1   | "standard"                        | 2.3698e-7   | 1.0       | 100          |
| 2   | "loading_no_gc"                   | 0.0757297   | 3.19561e5 | 100          |
| 3   | "loading_with_gc"                 | 0.135563    | 5.72044e5 | 100          |
| 4   | "size_empty_bench"                | 2.7107e-7   | 1.14385   | 100          |
| 5   | "size_full_bench"                 | 2.8729e-7   | 1.2123    | 100          |
| 6   | "size_end_bench"                  | 2.7106e-7   | 1.14381   | 100          |
| 7   | "checkbounds_full_bench"          | 6.914e-7    | 2.91755   | 100          |
| 8   | "checkbounds_end_bench"           | 7.1105e-7   | 3.00046   | 100          |
| 9   | "getindex_full_start_bench"       | 3.73032e-6  | 15.7411   | 100          |
| 10  | "getindex_full_stop_bench"        | 3.68608e-6  | 15.5544   | 100          |
| 11  | "getindex_end_start_bench"        | 3.64562e-6  | 15.3837   | 100          |
| 12  | "getindex_end_stop_bench"         | 3.66353e-6  | 15.4592   | 100          |
| 13  | "getindex_range_full_all_bench"   | 0.000612193 | 2583.31   | 100          |
| 14  | "getindex_range_full_small_bench" | 8.40161e-6  | 35.4528   | 100          |
| 15  | "getindex_range_end_all_bench"    | 0.000330267 | 1393.65   | 100          |
| 16  | "getindex_range_end_small_bench"  | 8.52693e-6  | 35.9816   | 100          |
```