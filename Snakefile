import glob
import os

configfile: 'config.yaml'

os.environ['ROSETTABIN'] = config['ROSETTABIN']
os.environ['ROSETTADB'] = config['ROSETTADB']

envvars:
    'ROSETTABIN',
    'ROSETTADB',

pdb_dir = config['pdb_dir']
pdbs = config['target_pdbs']
relax_nstruct = config['relax_nstruct']

pdb2residues = {}
for pdb in pdbs:
    if '*' in config['mutfiles'][pdb]: # Use all mutfiles in the directory.
        residues = [os.path.basename(f).split('.')[0] for f in glob.glob(f'mutfiles/{pdb}/*.mutfile')]
    else:
        residues = []
        for mutfile in config['mutfiles'][pdb]:
            if not os.path.exists(f'mutfiles/{pdb}/{mutfile}.mutfile'):
                raise FileNotFoundError(f'No such mutfile: mutfiles/{pdb}/{mutfile}.mutfile')
            residues.append(mutfile)

    pdb2residues[pdb] = residues

ALL = []
ALL.append(expand('relaxed_pdbs/{pdb}_{i:04}.pdb', pdb=pdbs, i=range(1, relax_nstruct+1)))
for pdb in pdbs:
    ALL.append(expand(f'result/{pdb}/{{residue}}.ddg', residue=pdb2residues[pdb]))

def get_relaxed_pdb(wc):
    # The pipeline DAG will be re-evaluated after completing the `relax` rule
    # by identifying the relaxed structure with minimum score.
    scores = checkpoints.relax.get(**wc).output[0]
    fname = list(shell(f'scripts/get_pdb_with_minimum_energy.sh {scores}', iterable=True))[0]

    return f'relaxed_pdbs/{fname}.pdb'

rule all:
    input: ALL

checkpoint relax:
    input:
        pdb = os.path.join(pdb_dir, '{pdb}.pdb'),
    output:
        scores = 'relax_score/{pdb}.sc',
        relaxed_pdbs = [f'relaxed_pdbs/{{pdb}}_{i:04}.pdb' for i in range(1, relax_nstruct+1)],
    params:
        pdb_outdir = 'relaxed_pdbs',
        score_outdir = 'relax_score',
        scorefile = lambda wc: f'relax_score/{wc.pdb}.sc',
    log:
        'logs/relax/{pdb}.log'
    shell:
        'scripts/preminimize.sh {input.pdb} {params.pdb_outdir} {params.score_outdir} {params.scorefile} > {log}'

rule cartesian_ddg:
    input:
        relaxed_pdb = get_relaxed_pdb,
        mutfile = 'mutfiles/{pdb}/{residue}.mutfile',
    output:
        'result/{pdb}/{residue}.ddg'
    params:
        temp_output = lambda wc: f'{wc.residue}.ddg',
    log:
        'logs/cartesian_ddg/{pdb}_{residue}.log'
    shadow: 'shallow'  # Don't mess up root directory by shadowing execution directory.
    shell:
        'scripts/cartesian_ddg.sh {input.relaxed_pdb} {input.mutfile} > {log} && mv {params.temp_output} {output}'
