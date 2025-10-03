
# Josephson Effect in Full-Shell Nanowires
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15432914.svg)](https://doi.org/10.5281/zenodo.15432914)
[![arXiv](https://img.shields.io/badge/arXiv-2504.16989-b31b1b.svg)](https://arxiv.org/abs/2504.16989)
[![arXiv](https://img.shields.io/badge/arXiv-2503.09756-b31b1b.svg)](https://arxiv.org/abs/2503.09756)
[![Julia v1.11+](https://img.shields.io/badge/Julia-v1.11+-blue.svg)](https://julialang.org/)
[![Quantica badge](https://raw.githubusercontent.com/pablosanjose/Quantica.jl/master/docs/src/assets/badge.svg)](https://github.com/pablosanjose/Quantica.jl)
[![License](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE.md)

This repository contains the numerical simulation code for two related papers on Josephson effects in full-shell nanowires published in *Phys. Rev. B*.

## Publications

### Paper 1: Fluxoid Valve Effect

**Title:** "Fluxoid valve effect in full-shell nanowire Josephson junctions"  
**DOI:** [10.1103/sdmw-qwcn](https://doi.org/10.1103/sdmw-qwcn)  
**arXiv:** [2504.16989](https://arxiv.org/abs/2504.16989)

**Abstract:** We introduce a new type of supercurrent valve based on full-shell nanowires. These hybrid wires consist of a semiconductor core fully wrapped in a thin superconductor shell and subjected to an axial magnetic field. Due to the tubular shape of the shell, the superconductor phase acquires an integer number $n$ of $2\pi$ twists or *fluxoids* that increases in steps with applied flux. By connecting two such hybrid wires, forming a Josephson junction (JJ), a flux-modulated supercurrent develops. If the two superconducting sections of the JJ have different radii $R_1$ and $R_2$, they can develop equal or different fluxoid numbers $n_1,n_2$ depending on the field. If $n_1\neq n_2$ the supercurrent is blocked, while it remains finite for $n_1=n_2$. This gives rise to a fluxoid valve effect controlled by the applied magnetic field or a gate voltage at the junction. We define a fluxoid-valve quality factor that is perfect for cylindrically symmetric systems and decreases as this symmetry is reduced. We further discuss the role of Majorana zero modes at the junction when the full shell-nanowires are in the topological superconducting regime.

### Paper 2: Josephson Effect in Trivial and Topological Regimes

**Title:** "Josephson effect and critical currents in trivial and topological full-shell hybrid nanowires"  
**DOI:** [10.1103/8mzs-dx7h](https://doi.org/10.1103/8mzs-dx7h)  
**arXiv:** [2503.09756](https://arxiv.org/abs/2503.09756)

**Abstract:** We perform microscopic numerical simulations of the Josephson effect through short junctions between two full-shell hybrid nanowires, comprised of a semiconductor core fully wrapped by a thin superconductor shell, both in the trivial and topological regimes. We explore the behavior of the current-phase relation and the critical current $I_c$ as a function of a threading flux for different models of the semiconductor core and different transparencies of the weak link. We find that $I_c$ is modulated with flux due to the Little-Parks (LP) effect and displays a characteristic *skewness* towards large fluxes within non-zero LP lobes, which is inherited from the skewness of a peculiar kind of subgap states known as Caroli--de Gennes--Matricon (CdGM) analogs. The appearance of Majorana zero modes at the junction in the topological phase is revealed in $I_c$ as *fin*-shaped peaks that stand out from the background at low junction transparencies. The competition between CdGMs of opposite electron- and hole-like character produces steps and dips in $I_c$. A rich phenomenology results, which includes 0-, $\pi$- and $\phi$-junction behaviors depending on the charge distribution across the wire core and the junction transparency.

## Code Structure

This Julia package provides comprehensive numerical simulations of Josephson junctions in full-shell nanowires using the [Quantica.jl](https://github.com/pablosanjose/Quantica.jl) quantum transport framework and the [FullShell.jl](https://github.com/CarlosP24/FullShell.jl) package for full-shell nanowire modeling.

### Directory Organization

```text
├── src/                    # Main source code
│   ├── main.jl            # Entry point for simulations
│   ├── models/            # Physical models and parameters
│   ├── builders/          # Josephson junction constructors
│   ├── operators/         # Green's function operators
│   ├── parallelizers/     # Parallel computation modules
│   └── calculations/      # Core calculation routines
├── bin/                   # Execution scripts
│   ├── launcher.jl        # SLURM cluster launcher
│   └── launch_*.sh        # Cluster-specific launch scripts
├── plots/                 # Figure generation scripts
│   ├── fig_valve_*.jl     # Figures for Paper 1 (fluxoid valve)
│   └── fig_jos_*.jl       # Figures for Paper 2 (Josephson effect)
├── sets/                  # System parameter sets
├── data/                  # Simulation output data
└── figures/               # Generated figures
```

### Key Components

#### Source Code (`src/`)

- **`main.jl`**: Main execution script that handles distributed computing and system selection
- **`models/`**: Defines physical parameters, wire models, junction geometries, and system configurations
- **`builders/`**: Contains the `JosephsonJunction.jl` module for constructing junction Hamiltonians
- **`operators/`**: Green's function calculations and transport operators
- **`parallelizers/`**: Parallel computation modules for LDOS, Josephson current, and transparency calculations
- **`calculations/`**: Core calculations used in the paper figures.

#### Execution Scripts (`bin/`)

- **`launcher.jl`**: SLURM-compatible distributed launcher for HPC clusters
- **`launch_*.sh`**: Cluster-specific submission scripts for different computing environments
- **`launch_local.jl`**: Local execution script for development and testing

#### Analysis and Plotting (`plots/`)

- **`fig_valve_*.jl`**: Generate figures for the fluxoid valve paper (Paper 1)
- **`fig_jos_*.jl`**: Generate figures for the Josephson effect paper (Paper 2)
- **`plotters/`**: Utility plotting functions and styling

#### System Definitions (`sets/`)

System parameter files that define different physical configurations:

- Files beginning with `valve_*`: Systems used for fluxoid valve studies (Paper 1).
- Other files: Systems used for general Josephson effect studies (Paper 2).

## Dependencies

The code requires Julia 1.6+ and the following packages:

- [Quantica.jl](https://github.com/pablosanjose/Quantica.jl): Quantum transport calculations
- [FullShell.jl](https://github.com/CarlosP24/FullShell.jl): Full-shell nanowire modeling
- CairoMakie.jl: High-quality plotting
- JLD2.jl: Data serialization
- Distributed.jl: Parallel computing
- SlurmClusterManager.jl: HPC cluster support

## Usage

### Local Execution

```julia
julia --project=. src/main.jl <system_name>
```

### Cluster Execution

For large-scale calculations on computing clusters, use a script like `launch_esbirro.sh`:

```bash
# Submit to SLURM queue
bash bin/launch_<cluster>.sh <system_name>
```

Where `<system_name>` corresponds to entries in the system definition files in `sets/`.

### Generating Figures

Navigate to the `plots/` directory and run the appropriate figure generation script.

## System Categories

- **Valve systems**: Configurations studying the fluxoid valve effect with radius mismatches
- **Standard systems**: General Josephson junction configurations in trivial and topological regimes
- **Test systems**: Development and validation configurations

## Citation

If you use this code in your research, please cite the relevant papers:

```bibtex
@misc{Paya:25d,
  title = {Fluxoid {{Valve Effect}} in {{Full-Shell Nanowire Josephson Junctions}}},
  author = {Pay{\'a}, Carlos and {Matute-Ca{\~n}adas}, F. J. and Yeyati, A. Levy and Aguado, Ram{\'o}n and {San-Jose}, Pablo and Prada, Elsa},
  year = {2025},
  month = apr,
  number = {arXiv:2504.16989},
  eprint = {2504.16989},
  primaryclass = {cond-mat},
  publisher = {arXiv},
  doi = {10.48550/arXiv.2504.16989},
  archiveprefix = {arXiv},
  keywords = {Condensed Matter - Mesoscale and Nanoscale Physics,Condensed Matter - Superconductivity},
}

@article{Paya:PRB25,
  title = {Josephson Effect and Critical Currents in Trivial and Topological Full-Shell Hybrid Nanowires},
  author = {Pay{\'a}, Carlos and Aguado, Ram{\'o}n and {San-Jose}, Pablo and Prada, Elsa},
  year = {2025},
  month = jun,
  journal = {Phys. Rev. B},
  volume = {111},
  number = {23},
  pages = {235420},
  publisher = {American Physical Society},
  doi = {10.1103/8mzs-dx7h},
}
```

and Zenodo repositories:
- [This repository](https://doi.org/10.5281/zenodo.15432914)
- [FullShell.jl](https://zenodo.org/records/15181184)

## License

This project is licensed under the terms specified in [LICENSE.md](LICENSE.md).


