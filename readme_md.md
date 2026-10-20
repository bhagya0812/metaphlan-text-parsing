# MetaPhlAn Taxonomic Level Extractor & Filter

A Bash and `awk` utility for cleaning raw MetaPhlAn output files, isolating specific taxonomic ranks (Kingdom through Species), and preventing double-counting or abundance inflation.

## Overview

MetaPhlAn outputs report cumulative relative abundances across nested taxonomic ranks within a single pipe-delimited column (`k__Bacteria|p__Firmicutes|...`). This structure is difficult to analyze in downstream data frames (e.g., RStudio) without extensive string splitting and memory overhead.

This CLI tool processes large MetaPhlAn `.tsv` files line-by-line directly on disk. It:
- Cleans raw header metadata and extra columns.
- Strips out placeholder bin artifacts (`GGB`, `SGB`, 'CFGB').
- Expands pipe-delimited taxonomy strings into separate columns.
- Dynamically filters and formats output down to a user-specified taxonomic depth (1–6) without double-counting.

---

## Features

- **Low Memory Footprint:** Built on Bash,`awk` and POSIX utilities to process massive datasets effortlessly.
- **Dynamic Level Selection:** Isolates any specific rank from 1 (Kingdom) to 6 (Species).
- **Artifact Cleanup:** Filters out unclassified strain and `SGB`/`GGB`/CFGB bins automatically.
- **Robust Input Validation:** Uses `getopts`  with built-in regex bounds checking for safer execution.

---

## Taxonomic Level Reference

| Level Number | Rank |
| :---: | :--- |
| **1** | Kingdom (`k__`) |
| **2** | Phylum (`p__`) |
| **3** | Class (`c__`) |
| **4** | Order (`o__`) |
| **5** | Family (`f__`) |
| **6** | Genus (`g__`) |
| **7** | Species (`s__`) |

---

## Installation

1. Save the script (e.g., `mpa-parse.sh`) to your desired directory or bin path.
2. Grant execution permissions:

```bash
chmod +x mpa-parse.sh
```

---

## Usage

```bash
./mpa-parse.sh -f <file_pattern_or_name> -l <level_number>
```

### Options

| Flag | Description | Required | Options / Range |
| :--- | :--- | :---: | :--- |
| `-f` | Input filename or glob pattern ending in `.tsv` | **Yes** | `*.tsv`, `sample1.tsv` |
| `-l` | Taxonomic classification level depth | **Yes** | Integer from `1` to `7` |

---

## Example Usage

### Extract Genus-Level Abundances (Level 6)

```bash
./process_metaphlan.sh -f "sample1.tsv" -l 6
```

**Output:** `sample1-level6-abundance.tsv` containing columns:
`Kingdom` | `Phylum` | `Class` | `Order` | `Family` | `Genus` | `rel_ab`

### Extract Phylum-Level Abundances (Level 2) across Multiple Files

```bash
./process_metaphlan.sh -f "*.tsv" -l 2
```

---

## Output Format

The generated output files strictly retain only the taxonomic ranks up to your specified level, followed by the corresponding relative abundance value (`rel_ab`):

```tsv
Kingdom	Phylum	Class	Order	Family	Genus	rel_ab
k__Bacteria	p__Firmicutes	c__Clostridia	o__Eubacteriales	f__Lachnospiraceae	g__Blautia	12.36845
k__Bacteria	p__Actinobacteria	c__Actinomycetia	o__Bifidobacteriales	f__Bifidobacteriaceae	g__Bifidobacterium	36.62452
```