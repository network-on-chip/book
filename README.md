# Network-on-Chip (NoC) and Advanced Interconnects: The Book

[![Learning Platform](https://img.shields.io/badge/Companion%20Platform-NoC%20Learning%20Hub-0f766e?logo=bookstack&logoColor=white)](https://network-on-chip.github.io/learning/)
[![Literature Corpus](https://img.shields.io/badge/Grounding-542%2B%20Curated%20Papers-2563eb)](https://network-on-chip.github.io/.github/)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-green?logo=creativecommons&logoColor=white)](https://creativecommons.org/licenses/by/4.0/)

An authoritative, open-access textbook synthesizing the physical fundamentals, router microarchitecture, deadlock theory, advanced packaging, and emerging frontiers of on-chip and multi-chip communication fabrics.

---

## 📖 About This Book

This textbook bridges the gap between classical computer architecture theory and silicon-proven industrial realities. Grounded directly in **542+ peer-reviewed papers** (from *IEEE TCAD, TVLSI, JSSC, TCAS-I, and TCAS-II*), this book is designed for graduate researchers, semiconductor architects, and silicon interconnect engineers.

### Core Distinctions
1. **First-Principles Rigor**: Detailed mathematical modeling of wire physics (Mayadas-Shatzkes, Elmore delay), arbitration theorems (iSLIP, wavefront), channel dependency graph (CDG) cycles, and compact thermal RC dynamics.
2. **542+ Research Papers Synthesized**: Direct dissection of state-of-the-art literature across 11 key research domains.
3. **Dual-Track Web Symbiosis**: Every chapter links directly to interactive arcade games, simulators, and live quizzes on the companion website: [network-on-chip.github.io/learning](https://network-on-chip.github.io/learning/).
4. **Reproducible Implementations**: Code artifacts provided in synthesizable Verilog, SystemVerilog, and Python.

---

## 🗺️ Master Curriculum at a Glance

For the full detailed curriculum and enhancement milestones, see the [Master Plan](PLAN.md).

- **Part I: Foundations & Router Microarchitecture**
  - **[Chapter 1: The Multi-Core Communication Crisis & Interconnect Physics](chapters/ch01-interconnect-crisis/index.md)**
  - **[Chapter 2: Switching Techniques, Flow Control & Buffer Management](chapters/ch02-switching-flow-control/index.md)**
  - **[Chapter 3: High-Performance Router Microarchitecture & Arbitration](chapters/ch03-router-microarchitecture/index.md)**
- **Part II: Topologies, Routing & Deadlock Freedom**
  - **[Chapter 4: Direct, Indirect & High-Radix Interconnect Topologies](chapters/ch04-topologies-and-metrics/index.md)**
  - **Chapter 5**: Deadlock Theory, Turn Models & Adaptive Routing
- **Part III: Physical Constraints: Power, Thermal & Reliability**
  - **Chapter 6**: Low-Power Architectures & Dark Silicon Dynamics
  - **Chapter 7**: Thermal Modeling, Hotspots & Fault-Tolerant Resilience
- **Part IV: Advanced Packaging, 3D NoC & Chiplets**
  - **Chapter 8**: Three-Dimensional Networks-on-Chip (3D-NoC) & TSVs
  - **Chapter 9**: Multi-Chiplet Interconnects, 2.5D Systems & UCIe
- **Part V: Emerging Frontiers: Optical, Wireless, Security & AI**
  - **Chapter 10**: Optical & Wireless Networks-on-Chip (ONoC / WNoC)
  - **Chapter 11**: Hardware Security & Trust in On-Chip Networks
  - **Chapter 12**: Domain-Specific NoCs for LLMs, Transformers & Neuromorphic SNNs

---

## 🖨️ Springer Nature Monograph Format & Compilation

This textbook is authored using the official **Springer Nature Monograph (`svmono` / `SNmono`)** LaTeX publishing format, compiling into a publication-grade camera-ready book.

### Directory Structure
```text
share/book/
├── SNmono.cls                # Official Springer Nature Monograph document class
├── svmono.cls                # Class alias (symlink to SNmono.cls)
├── framed.sty                # Support package for Springer graybox callouts
├── spmpsci.bst               # Springer mathematical/computer science BibTeX style
├── svind.ist                 # Springer index formatting style
├── book.tex                  # Master root document (\documentclass[graybox,envcountchap,sectrefs]{svmono})
├── book.bib                  # Unified BibTeX bibliography (TVLSI, TCAD, JSSC, TCAS)
├── book.pdf                  # Compiled 44+ page Springer monograph PDF
├── compile.sh                # 4-pass automated build pipeline (pdflatex + bibtex + makeindex)
├── Makefile                  # Build automation (make pdf, make clean)
├── frontmatter/              # Dedication, Preface, and List of Acronyms
├── parts/                    # Part title dividers (Part I: Foundations & Microarch)
├── chapters/                 # Modular chapters with LaTeX, Markdown, figures & RTL/Python code
│   ├── ch01-interconnect-crisis/      (chapter.tex, index.md, figures/, code/)
│   ├── ch02-switching-flow-control/   (chapter.tex, index.md, figures/, code/)
│   └── ch03-router-microarchitecture/ (chapter.tex, index.md, figures/, code/)
└── backmatter/               # Appendix (open-source RTL & PDKs) and Checkpoint Solutions
```

### Compiling the Book
To build the complete book from source:
```bash
bash compile.sh
# or
make pdf
```

---

## 🚀 Companion Platforms

- **Interactive Learning Hub**: [https://network-on-chip.github.io/learning/](https://network-on-chip.github.io/learning/)
- **Interactive Literature Map (542+ Papers)**: [https://network-on-chip.github.io/.github/](https://network-on-chip.github.io/.github/)
- **GitHub Organization**: [https://github.com/network-on-chip](https://github.com/network-on-chip)

---

## 📄 License

The text, figures, and curriculum are licensed under [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).  
Code artifacts are licensed under the Apache 2.0 License.
