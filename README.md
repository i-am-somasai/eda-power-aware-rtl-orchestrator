# Power-Aware RTL Orchestrator

> A Perl-Driven, Regression-Safe Power Proxy Evaluation Flow for RTL Designs

## 🚀 Overview

Power-Aware RTL Orchestrator is an automation-centric EDA infrastructure project designed to evaluate relative dynamic power behavior of RTL designs at an early stage of the design lifecycle.

**Important:** This project computes deterministic and reproducible **power proxies** derived from RTL-level switching activity—not real physical power in watts (mW / µW).

### Key Motivation

The methodology mirrors internal CAD/EDA flows used in semiconductor companies where:
- Early power trend visibility is critical
- Regression safety is mandatory
- Automation is preferred over manual analysis

### ⚠️ Disclaimer

| ❌ What This Is NOT | ✅ What This IS |
|---|---|
| Sign-off power analysis tool | Methodology-driven RTL power evaluation |
| Replacement for PrimeTime PX | Automation-first comparison framework |
| Physically accurate power calculator | Regression detection tool |

---

## ⚡ Fundamentals: Dynamic Power & Switching Activity

Dynamic power in digital circuits is fundamentally proportional to switching activity:

```
Dynamic Power ∝ Switching Activity ∝ Signal Toggles
```

### Conventional Approach ❌

Traditional power analysis relies on:
- Standard cell libraries
- Voltage / PVT corners
- Post-layout data

### This Project's Approach ✅

We enable early power visibility using:
- **VCD-based signal toggle counts**
- **RTL-level switching activity**
- **Deterministic and repeatable metrics**

### Power Proxy Benefits

With power proxies, you can:
- Compare RTL versions objectively
- Rank different architectures
- Detect early power regressions
- Avoid synthesis/layout dependencies

---

## 🏗️ High-Level Flow

```
RTL Design
    ↓
Testbench Simulation (Vivado)
    ↓
VCD Generation (switching activity)
    ↓
Switching Activity Extraction (Perl)
    ↓
Power Proxy Estimation
    ↓
Regression Analysis & Reporting
```

---

## 📁 Project Structure

```
power-aware-rtl-orchestrator/
│
├── rtl/
│   └── alu16.v                    # RTL design module
│
├── tb/
│   └── alu16_tb.v                 # Testbench stimulus
│
├── flows/
│   ├── run_sim.pl                 # Simulation orchestration
│   ├── extract_activity.pl         # VCD parsing & toggle extraction
│   ├── power_proxy.pl              # Power metric computation
│   └── regression.pl               # Baseline comparison
│
├── outputs/
│   ├── vcd/                        # Generated VCD files
│   ├── activity/                   # Toggle count summaries
│   ├── power/                      # Power proxy results
│   └── regression/                 # Comparison reports
│
├── config/
│   └── flow.conf                   # Configuration settings
│
├── scripts/
│   └── run_sim.tcl                 # Vivado TCL automation
│
└── README.md                        # This file
```

---

## 🛠️ Tools & Environment

| Tool | Purpose |
|------|---------|
| **Vivado (CLI)** | RTL simulation & VCD generation |
| **Perl** | Flow orchestration & data processing |
| **TCL** | Tool automation & scripting |
| **Verilog** | RTL & testbench design |
| **VCD** | Switching activity source format |

**Note:** The entire flow executes from the terminal—no GUI interaction required.

---

## ▶️ Quick Start

### Step 1: RTL Simulation

Run RTL simulation in batch mode to generate VCD:

```bash
vivado -mode tcl -source scripts/run_sim.tcl
```

**This step:**
- Compiles RTL and testbench
- Executes simulation
- Generates VCD switching activity file in `outputs/vcd/`

### Step 2: Switching Activity Extraction

Extract toggle counts from the VCD:

```bash
perl flows/extract_activity.pl alu16
```

**This step:**
- Parses VCD hierarchy
- Counts signal transitions
- Generates activity summary in `outputs/activity/`

### Step 3: Power Proxy Estimation

Convert switching activity into a power proxy metric:

```bash
perl flows/power_proxy.pl alu16
```

**This step:**
- Uses toggle count as relative power metric
- Normalizes results (if configured)
- Stores results in `outputs/power/`

### Step 4: Regression Analysis

Compare current results against baseline:

```bash
perl flows/regression.pl alu16
```

**This step:**
- Compares current run vs baseline
- Detects power regressions
- Reports PASS/FAIL status to `outputs/regression/`

---

## 📊 Sample Output

```
$ perl flows/extract_activity.pl alu16
Activity extraction completed for alu16
Total toggles: 5283

$ perl flows/power_proxy.pl alu16
Power proxy estimation completed for alu16
Total power proxy: 5283

$ perl flows/regression.pl alu16
Regression completed for alu16
Status: PASS
```

---

## 🧪 Troubleshooting

### Empty VCD File

**Cause:**
- Simulation time too short
- No active stimulus

**Solution:**
- Increase simulation duration in `scripts/run_sim.tcl`
- Verify clock and reset behavior

### Zero Toggle Count

**Cause:**
- Incorrect signal scope
- dumpvars misconfiguration

**Solution:**
- Fix hierarchy parsing in Perl scripts
- Ensure relevant signals are dumped in testbench

### Non-Deterministic Results

**Cause:**
- Randomized testbench stimulus

**Solution:**
- Use fixed random seeds
- Make stimulus deterministic for reproducibility

### Regression Always Passes

**Cause:**
- Baseline overwritten unintentionally

**Solution:**
- Lock baseline directory with permissions
- Separate baseline and current output directories

---

## 🧠 Design Philosophy

### Why Perl?

- Strong text and log processing capabilities
- Widely used in internal EDA infrastructure
- Fast iteration for automation flows
- Excellent regex and file handling

### Why RTL-Level Analysis?

- Enables early architectural feedback
- Avoids synthesis and layout dependencies
- Faster turnaround during design exploration
- Better for rapid design iteration

### Why Not Real Power?

- Real power requires libraries, voltage, and PVT corners
- Early-stage design benefits more from relative trends
- Reduces tool dependencies and simplifies automation
- Supports rapid exploration without sign-off complexity

---

## 🌍 Use Cases

### 🏭 Semiconductor Industry

- Early RTL power regression detection
- Design variant comparison
- Architecture trade-off evaluation
- Pre-synthesis power visibility

### 🎓 Research & Academia

- Teaching power-aware RTL design principles
- Rapid architectural experimentation
- Methodology validation and publication

### 🤖 ML + Hardware Co-Design

- Comparing ALU variants for ML workloads
- Activity-driven hardware optimization
- Architecture selection for specialized accelerators

---


## 📚 Key Concepts

### Power Proxy

A relative power metric derived from RTL switching activity, useful for:
- Comparing design variants
- Detecting power regressions
- Ranking architectural choices

### Switching Activity

The number of signal transitions (0→1 or 1→0) in a design during simulation, captured in VCD format.

### Regression Testing

Automated comparison of current metrics against a baseline to detect performance degradation or unexpected changes.

---

## 💡 Core Principles

```
Automation beats intuition
Methodology beats guesswork
Regression beats assumptions
```

This project demonstrates:
- EDA flow orchestration thinking
- Automation-first engineering discipline
- Power-aware RTL design mindset
- Regression-driven development methodology

If you can explain this project end-to-end, you're already thinking like an internal CAD/infrastructure engineer.

---

**Made with ⚡ for power-conscious RTL engineers**
