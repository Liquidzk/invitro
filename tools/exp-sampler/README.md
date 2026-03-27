# Experimental Sampler

## Files


## Single Reduction

Run RR with (2, 20):

```console
python3 tools/exp-sampler/cli.py reduce \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/400_rr_2of20 \
  -real 2 \
  -max 20 \
  --seed 0 \
  --policy round-robin
```

Run CA with (2, 20):

```console
python3 tools/exp-sampler/cli.py reduce \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/400_ca_2of20 \
  -real 2 \
  -max 20 \
  --seed 0 \
  --policy cache-aware \
  --ca-trace-csv "/home/liquid/invitro-related/simulate_result/cpu_400(in).csv" \
  --ca-span-stat max \
  --ca-unobserved-policy zero-span
```

Useful parameter patterns:

- `-real 8 -max 1000`: the nodes parameter
- `--ca-span-stat max`: use full-timeline max from the external `cpu` trace
- `--ca-span-stat p99`: use full-timeline p99 instead
- `--ca-unobserved-policy zero-span`: functions missing from the external trace are dropped
- `--ca-unobserved-policy min-one`: functions missing from the external trace are forced to `node_span=1`

## Seed Sweeps

Run both RR and CA for 300 seeds:

```console
python3 tools/exp-sampler/cli.py sweep \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/seed_sweeps \
  --name 400_rr_ca_2of20_seed_0_299 \
  -real 2 \
  -max 20 \
  --seed-start 0 \
  --seed-count 300 \
  --policy both \
  --ca-trace-csv "/home/liquid/invitro-related/simulate_result/cpu_400(in).csv" \
  --ca-span-stat max \
  --ca-unobserved-policy zero-span
```

Each sweep writes:

- `<name>_results.csv`: one row per policy/seed
- `<name>_summary.csv`: aggregate statistics such as mean, std, median, p05, and p95


400-function RR, `8/1000`:

```console
python3 tools/exp-sampler/cli.py reduce \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/400_rr_8of1000 \
  -real 8 \
  -max 1000 \
  --seed 0 \
  --policy round-robin
```

400-function CA, `8/1000`:

```console
python3 tools/exp-sampler/cli.py reduce \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/400_ca_8of1000 \
  -real 8 \
  -max 1000 \
  --seed 0 \
  --policy cache-aware \
  --ca-trace-csv "/home/liquid/invitro-related/simulate_result/cpu_400(in).csv" \
  --ca-span-stat max \
  --ca-unobserved-policy zero-span
```

The old "keep unobserved functions alive with span 1" behavior is still available:

```console
python3 tools/exp-sampler/cli.py reduce \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/400_ca_8of1000_min_one \
  -real 8 \
  -max 1000 \
  --seed 0 \
  --policy cache-aware \
  --ca-trace-csv "/home/liquid/invitro-related/simulate_result/cpu_400(in).csv" \
  --ca-span-stat max \
  --ca-unobserved-policy min-one
```
Now the scale-ratio expection will be the same as RR