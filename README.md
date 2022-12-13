# snakemake-cartesian-ddg

Snakemake pipeline for Rosetta `cartesian-ddg` application for the prediction of protein stability change (ddG) upon mutation.

## Quickstart

1. Configure paths to your Rosetta binary (`ROSETTABIN`) and DB (`ROSETTADB`) in `config.yaml`.

2. Place your PDB file in `pdb` directory and configure `target_pdbs` in `config.yaml`.

3. Prepare mutfiles corresponding to mutations for which you want to measure ddG values.

4. Configure `mutfiles` in `config.yaml`. Note that `*` means that all mutfiles in the directory will be used.

5. Run the pipeline.

```
$ snakemake -pr -j[NUM_CORES]
```

**Pipeline overview**

![pipeline](img/pipeline.png)
