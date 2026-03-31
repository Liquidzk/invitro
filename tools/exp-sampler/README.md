# Experimental Sampler

## Single Reduction

RR:

```console
python3 tools/exp-sampler/cli.py reduce \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/400_rr_2of20 \
  -real 2 \
  -max 20 \
  --seed 0 \
  --policy round-robin
```

CA:

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

CA parameters:

- `--ca-span-stat max|p99`
- `--ca-unobserved-policy zero-span|min-one`

## Seed Sweep

Run both RR and CA for many seeds:

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

Outputs:

- `<name>_results.csv`: one row per policy/seed
- `<name>_summary.csv`: aggregate statistics

## Cold-Match Selection

Run a sweep and materialize the best trace per policy:

```console
python3 tools/exp-sampler/cli.py sweep \
  -t data/traces/reference/sampled_150/400 \
  -o data/traces/reference/sampled_150/seed_sweeps \
  --name 400_rr_ca_2of20_cold_match_seed_0_299 \
  -real 2 \
  -max 20 \
  --seed-start 0 \
  --seed-count 300 \
  --policy both \
  --ca-trace-csv "/home/liquid/invitro-related/simulate_result/cpu_400(in).csv" \
  --ca-span-stat max \
  --ca-unobserved-policy zero-span \
  --cold-gap-threshold 10 \
  --cold-exec-column Average \
  --select-best
```

Additional outputs:

- `<name>_best.csv`: best seed per policy
- `<output-dir>/<name>_best/round-robin/`
- `<output-dir>/<name>_best/cache-aware/`

Key columns:

- `cold_functions_before`
- `cold_functions_after`
- `cold_exec_wd`
