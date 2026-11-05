# Chapter 9: Multi-Chiplet Interconnects, 2.5D Systems & UCIe

[![Companion Platform](https://img.shields.io/badge/Interactive%20Lab-Chiplet%20Tycoon-0f766e?logo=bookstack&logoColor=white)](https://network-on-chip.github.io/learning/interactive/chiplet/)
[![Curriculum Track](https://img.shields.io/badge/Learning%20Track-Track%206%3A%20Chiplets%20%26%203D-blue)](https://network-on-chip.github.io/learning/track6-chiplets-and-3d/)
[![Simulation Model](https://img.shields.io/badge/Python%20Model-ucie__d2d__latency__model.py-blueviolet)](code/ucie_d2d_latency_model.py)
[![Hardware RTL](https://img.shields.io/badge/Verilog%20RTL-chiplet__bridge__protocol.v-success)](code/chiplet_bridge_protocol.v)

---

## 9.1 The Chiplet Revolution & Modular Disaggregation

For over four decades, Moore's Law advanced through monolithic silicon scaling, shrinking transistor dimensions while integrating entire computing systems onto a single continuous silicon die. In advanced sub-3nm nodes, monolithic scaling has struck two intractable physical and economic boundaries:

1. **The Optical Reticle Limit**: Modern deep ultraviolet (DUV) and extreme ultraviolet (EUV) photolithography exposure scanners are optically bounded by a maximum reticle field size of approximately $26\text{ mm} \times 33\text{ mm} \approx 858\text{ mm}^2$. High-performance artificial intelligence accelerators, hyperscale datacenter server CPUs, and massive graphics processing units (GPUs) demand silicon areas exceeding $1000\text{--}1500\text{ mm}^2$, rendering monolithic fabrication physically impossible without complex, yield-killing reticle stitching.
2. **Defect Density & Exponential Yield Degradation**: Under the Murphy and Seeds yield models, die manufacturing yield $Y$ decays exponentially with active silicon area $A$:
   $$Y = \left( \frac{1 - e^{-A \cdot D_0}}{A \cdot D_0} \right)^2 \quad \text{or} \quad Y = e^{-\sqrt{A \cdot D_0}}$$
   where $D_0$ represents random defect density ($\text{defects/cm}^2$). Fabricating an $800\text{ mm}^2$ monolithic die in a leading-edge process incurs wafer yields below $20\text{--}30\%$. In contrast, disaggregating that design into four $200\text{ mm}^2$ chiplets elevates individual die yield to $>80\%$, drastically slashing net silicon cost despite packaging overheads.
3. **Process Node Heterogeneity**: Analog circuits, I/O transceivers, phase-locked loops (PLLs), and high-voltage memory interfaces scale poorly in advanced FinFET and Gate-All-Around (GAA) geometries. Disaggregation allows compute-intensive logic (tensor cores, vector units) to be fabricated in 3nm, while I/O controllers and memory interfaces reside on cost-effective 14nm or 7nm silicon tiles.

```
       Monolithic SoC vs. Multi-Chiplet Modular Disaggregation
       
       [ Monolithic Die (800 mm2) ]            [ Disaggregated Multi-Chiplet System ]
       +--------------------------+            +------------------------------------+
       | Compute Cores (3nm)      |            |  [Compute 1]     [Compute 2]       |
       | + Analog PLLs            |   ====>    |    (3nm)            (3nm)          |
       | + High-V I/O Transceivers|            |       \              /             |
       | + Memory Controllers     |            |    ==== [Active Interposer] ====   |
       | Yield: ~25% (High Cost)  |            |       /              \             |
       +--------------------------+            |  [Compute 3]     [I/O & Memory]    |
         Optical Reticle Bounded               |    (3nm)           (14nm / 7nm)    |
                                               +------------------------------------+
                                                 Yield: >82% per die (Lower Cost)
```

---

## 9.2 2.5D Packaging Taxonomies & Interposer Technologies

The mechanical and electrical foundation of multi-chiplet systems is determined by the packaging substrate. As classified by **Z. Chen et al. (IEEE TVLSI 2026)** and depicted in Figure 9.1, multi-chiplet packaging spans four distinct integration categories:

![Figure 9.1: Multi-chiplet packaging taxonomy: (a) Standard organic substrate, (b) 2.5D silicon interposer, (c) Embedded silicon bridge (e.g., Intel EMIB), and (d) 3D hybrid bonding. [Reproduced from: Z. Chen et al., "HiRe: A Hierarchical Reconfigurable Architecture for Large-Scale Multichiplet DNN Accelerators", IEEE Transactions on Very Large Scale Integration (VLSI) Systems, Vol. 34, No. 4, pp. 880-893, 2026, DOI: 10.1109/TVLSI.2026.3676552. © 2026 IEEE]](figures/chen_fig02_chiplet_packaging_taxonomy.png)

### 9.2.1 Packaging Substrate Comparison

| Packaging Technology | Bump Pitch ($\mu\text{m}$) | Channel Length | Shoreline Bandwidth Density | Energy Efficiency | Cost & Complexity |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Standard Organic Substrate** | $100\text{--}130$ | $10\text{--}25\text{ mm}$ | $100\text{--}150\text{ Gbps/mm}$ | $1.0\text{--}1.5\text{ pJ/bit}$ | Low cost, standard PCB/laminate manufacturing |
| **Passive Silicon Interposer (2.5D)** | $25\text{--}55$ | $1\text{--}3\text{ mm}$ | $700\text{--}1300\text{ Gbps/mm}$ | $0.2\text{--}0.4\text{ pJ/bit}$ | Moderate-high cost; subject to interposer reticle limit |
| **Embedded Bridge (EMIB)** | $25\text{--}45$ | $1\text{--}2\text{ mm}$ | $600\text{--}1000\text{ Gbps/mm}$ | $0.3\text{--}0.5\text{ pJ/bit}$ | Localized silicon cavities inside organic carrier |
| **Active Silicon Interposer** | $20\text{--}40$ | Distributed | $>1000\text{ Gbps/mm}$ | $0.3\text{--}0.6\text{ pJ/bit}$ | Active CMOS logic, routers, DC-DC converters in base die |

### 9.2.2 Active Silicon Interposers: The IntAct Architecture

![Figure 9.2: IntAct active interposer system architecture integrating six 16-core chiplets (96 cores total) over an active interposer 2D mesh NoC. [Reproduced from: P. Vivet et al., "IntAct: A 96-Core Processor With Six Chiplets 3D-Stacked on an Active Interposer With Distributed Interconnects and Integrated Power Management", IEEE Journal of Solid-State Circuits, Vol. 56, No. 1, pp. 79-97, Jan. 2021, DOI: 10.1109/JSSC.2020.3036341. © 2021 IEEE]](figures/vivet_fig03_active_interposer.png)

In passive interposers, the carrier wafer contains only copper wiring traces. In contrast, the **IntAct system (P. Vivet et al., IEEE JSSC 2021)**, shown in Figure 9.2, introduces an **Active Silicon Interposer**:
- Six 16-core compute chiplets (96 cores total) are 3D-stacked onto an active 28nm base die.
- The active interposer hosts a distributed $6 \times 4$ network-on-chip router fabric with integrated switched-capacitor DC-DC converters and clock management units.
- Compute chiplets communicate via asynchronous cross-die micro-bump links, isolating local compute clock domains from global inter-chiplet transport and providing $3.0\text{ Tbps}$ of total die-to-die bandwidth.

---

## 9.3 The Universal Chiplet Interconnect Express (UCIe) Standard

To establish an open, interoperable die-to-die interface standard across diverse silicon foundries and packaging vendors, the industry established **UCIe (Universal Chiplet Interconnect Express)**.

```
       UCIe Architectural Protocol Stack
       +-------------------------------------------------------+
       | Protocol Layer: PCIe 6/7 | CXL.io/cache/mem | Raw NoC |
       +-------------------------------------------------------+
                                  | Flits (68B / 256B)
       +-------------------------------------------------------+
       | Die-to-Die (D2D) Adapter Layer:                       |
       |  - Link State Management & Arbitration                |
       |  - CRC Generation & Checking (CRC-16 / CRC-32)        |
       |  - Retransmission Retry Buffer (Go-Back-N / Selective)|
       |  - Credit-Based Flow Control Turnaround               |
       +-------------------------------------------------------+
                                  | Raw Flit Stream + Credits
       +-------------------------------------------------------+
       | Physical Layer (PHY):                                 |
       |  - Mainband Data (x16/x32/x64 Single-Ended Lanes)     |
       |  - Forwarded Differential Clocks & Track Signals      |
       |  - Sideband Management Channel (800 MHz Manchester)   |
       |  - Lane Deskew, Training & Equalization               |
       +-------------------------------------------------------+
```

### 9.3.1 Layer Responsibilities
1. **Protocol Layer**: Encapsulates native processor and accelerator transactions into standard Flit formats. UCIe supports PCIe 6.0/7.0 for peripheral expandability, CXL 2.0/3.0 for cache-coherent shared memory hierarchies, and a Raw Streaming mode optimized for lightweight NoC packet transport.
2. **Die-to-Die Adapter Layer**: Manages link initialization, packet framing, CRC error detection, credit turnaround, and replay buffers for loss-free transmission over the physical medium.
3. **Physical Layer (PHY)**: Implements transmitter output drivers, receiver samplers, clock forwarding, phase deskew circuits, and lane reversal/repair logic.

---

## 9.4 Inter-Chiplet Latency, Bandwidth Density & Credit Turnaround

### 9.4.1 Die-to-Die Latency Decomposition
A flit traversing an inter-chiplet boundary incurs delays across distinct physical domains:
$$t_{\text{D2D}} = t_{\text{CDC}} + t_{\text{adapter}} + t_{\text{PHY\_tx}} + t_{\text{flight}} + t_{\text{PHY\_rx}} + t_{\text{deskew}} + t_{\text{CDC}}$$

where propagation flight time along the interposer metal trace is governed by electromagnetic phase velocity:
$$t_{\text{flight}} = \frac{L_{\text{channel}}}{v_{\text{prop}}} = \frac{L_{\text{channel}} \sqrt{\epsilon_{\text{eff}}}}{c_0}$$
For silicon dioxide dielectric ($\epsilon_r \approx 3.9$), $v_{\text{prop}} \approx 150\text{ mm/ns}$ ($6.7\text{ ps/mm}$). A $1.5\text{ mm}$ interposer bridge link adds $\approx 10\text{ ps}$ of flight time, while a $20\text{ mm}$ standard organic substrate trace contributes $>130\text{ ps}$.

### 9.4.2 Little's Law & Credit Queue Sizing
To prevent throughput throttling on multi-terabit D2D interfaces, credit tokens must return to the transmitting chiplet before transmit queues exhaust. The round-trip turnaround time ($\text{RTT}_{\text{credit}}$) is:
$$\text{RTT}_{\text{credit}} = t_{\text{forward}} + t_{\text{rx\_process}} + t_{\text{backward}} + t_{\text{tx\_process}}$$

By Little's law, the minimum receiver FIFO buffer depth $B_{\text{min}}$ (in flits) required to guarantee line-rate streaming is:
$$B_{\text{min}} \ge \left\lceil \frac{\text{RTT}_{\text{credit}}}{T_{\text{flit}}} \right\rceil = \lceil \text{RTT}_{\text{credit}} \cdot f_{\text{clk}} \rceil$$

If buffer depth $B < B_{\text{min}}$, the transmitter stalls periodically awaiting returned credits, degrading link utilization.

---

## 9.5 Deadlock in Multi-Chiplet Networks & In/Outbound Swap Recovery

### 9.5.1 The Boundary Deadlock Anomaly
In monolithic NoCs, turn models (e.g., XY Dimension-Order Routing) guarantee deadlock freedom by prohibiting turns that complete cycles in the Channel Dependency Graph (CDG). However, in multi-chiplet systems, local routing protocols are combined hierarchically:
- Each individual chiplet runs an internal routing algorithm (e.g., local 2D mesh DOR).
- Inter-chiplet traffic crosses dedicated bridge routers connecting to D2D physical interfaces.

As proven by **P. Wang et al. (IEEE TCAD 2026)**, the combination of deadlock-free local networks can create global cyclic dependencies across chiplet boundaries, as shown in Figure 9.3.

![Figure 9.3: Multi-chiplet routing deadlock scenario where local subpath dependencies cross die-to-die bridge boundaries, forming a closed resource dependency cycle across four chiplets. [Reproduced from: P. Wang et al., "In/Outbound Swap: A Backtracking-based Deadlock Recovery Mechanism for Multi-Chiplet Networks", IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems, Vol. 45, No. 5, pp. 2100-2114, 2026, DOI: 10.1109/TCAD.2026.3688573. © 2026 IEEE]](figures/wang_fig01_chiplet_deadlock_subpath.png)

### 9.5.2 In/Outbound Swap Backtracking Recovery

To resolve these deadlocks without doubling or tripling Virtual Channel buffer counts, Wang et al. developed the **In/Outbound Swap** recovery mechanism.

![Figure 9.4: Operational flow of the In/Outbound Swap deadlock recovery mechanism: stall timeout detection, swap request assertion, queue handshake, and circular dependency breaking. [Reproduced from: P. Wang et al., "In/Outbound Swap: A Backtracking-based Deadlock Recovery Mechanism for Multi-Chiplet Networks", IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems, Vol. 45, No. 5, pp. 2100-2114, 2026, DOI: 10.1109/TCAD.2026.3688573. © 2026 IEEE]](figures/wang_fig02_swap_recovery_flow.png)

As shown in Figure 9.4:
1. **Stall Timeout Monitor**: Each D2D bridge router continuously tracks flit blockage time. If a head flit is blocked for more than $\tau_{\text{stall}}$ clock cycles with zero downstream credits, a potential deadlock cycle is flagged.
2. **Backtracking Swap Handshake**: The bridge controller activates a swap signal, latching the blocked head flit into a dedicated 2-flit escape register.
3. **Dependency Cycle Severing**: By clearing the head of the blocked input FIFO, non-deadlocked trailing flits advance, severing the closed dependency loop and allowing normal credit flow to recover without dropping packets.

---

## 9.6 Hardware Implementation: Synthesizable Chiplet D2D Bridge

The accompanying synthesizable Verilog module [`code/chiplet_bridge_protocol.v`](code/chiplet_bridge_protocol.v) implements a high-throughput D2D bridge with credit-based flow control, hardware CRC-8 frame verification, and the In/Outbound Swap deadlock recovery controller.

```verilog
// Snippet from code/chiplet_bridge_protocol.v: In/Outbound Swap Recovery Logic
always @(posedge local_clk or negedge local_rst_n) begin
    if (!local_rst_n) begin
        d2d_tx_data       <= {DATA_WIDTH{1'b0}};
        d2d_tx_valid      <= 1'b0;
        stall_counter     <= 16'd0;
        swap_active       <= 1'b0;
        deadlock_detected <= 1'b0;
    end else begin
        // Monitor buffer stalls at D2D boundary
        if (tx_flit_valid && !has_tx_credit) begin
            stall_counter <= stall_counter + 1'b1;
            if (stall_counter >= STALL_TIMEOUT) begin
                deadlock_detected <= 1'b1;
                swap_active       <= 1'b1;
                // Divert blocked head flit into swap escape register
                swap_buffer       <= tx_flit_data;
                swap_buffer_valid <= 1'b1;
            end
        end else begin
            stall_counter     <= 16'd0;
            deadlock_detected <= 1'b0;
        end
    end
end
```

---

## 9.7 Quantitative Evaluation & Simulation Results

The Python model [`code/ucie_d2d_latency_model.py`](code/ucie_d2d_latency_model.py) quantitatively evaluates Standard Organic vs. Advanced Silicon Interposer packaging across latency, bandwidth, power, and buffer depths.

| Metric | Standard Organic Packaging | Advanced Silicon Interposer (UCIe-A) | Advantage |
| :--- | :---: | :---: | :---: |
| **Bump / Pad Pitch** | $110\ \mu\text{m}$ | **$45\ \mu\text{m}$** | $2.44\times\text{ finer pitch}$ |
| **Trace Channel Length** | $15.0\text{ mm}$ | **$1.8\text{ mm}$** | $8.33\times\text{ shorter wires}$ |
| **One-Way Flight Delay** | $100.0\text{ ps}$ | **$12.0\text{ ps}$** | $88\text{ ps faster transit}$ |
| **One-Way Total Latency** | $4.25\text{ ns}$ ($8.5\text{ cycles}$) | **$4.06\text{ ns}$** ($8.1\text{ cycles}$) | Low latency |
| **Credit RTT ($\text{RTT}_{\text{credit}}$)** | $8.50\text{ ns}$ ($17.0\text{ cycles}$) | **$8.11\text{ ns}$** ($16.2\text{ cycles}$) | Fast credit return |
| **Minimum Buffer Depth ($B_{\text{min}}$)** | $17\text{ flits}$ | **$17\text{ flits}$** | Prevents transmit stalling |
| **Total Raw Bandwidth** | $0.51\text{ Tbps}$ ($64\text{ GB/s}$) | **$2.05\text{ Tbps}$** ($256\text{ GB/s}$) | **$4.02\times\text{ bandwidth}$** |
| **Shoreline Bandwidth Density** | $145.5\text{ Gbps/mm}$ | **$711.1\text{ Gbps/mm}$** | **$4.88\times\text{ linear density}$** |
| **Energy Efficiency** | $1.200\text{ pJ/bit}$ | **$0.330\text{ pJ/bit}$** | **$3.64\times\text{ lower energy}$** |
| **Interface Total Power** | $614.4\text{ mW}$ | **$675.8\text{ mW}$** | $4\times$ data at equal power |

Advanced silicon interposers achieve a staggering **$4.88\times$** higher shoreline bandwidth density and **$3.64\times$** higher energy efficiency compared to standard organic laminate packaging, proving essential for modern AI accelerator chiplet complexes.

---

## 9.8 Summary

- **Economic Scaling Driver**: Multi-chiplet disaggregation breaks the monolithic optical reticle limit ($858\text{ mm}^2$) and mitigates exponential defect yield collapse.
- **Packaging Diversity**: 2.5D silicon interposers and embedded bridges provide ultra-dense micro-bump pitches ($25\text{--}55\ \mu\text{m}$) and sub-$0.4\text{ pJ/bit}$ energy metrics, outperforming organic substrates.
- **Standardized Interoperability**: UCIe defines a 3-layer architecture (Protocol, D2D Adapter, PHY) supporting PCIe, CXL, and raw streaming flit transport.
- **Hierarchical Deadlock Elimination**: Composition of deadlock-free local networks can generate cyclic cross-boundary dependencies; the In/Outbound Swap backtracking mechanism resolves stalls dynamically with minimal buffer overhead.

---

## 9.9 Exercises and Review Questions

1. **Die Yield & Cost Economics**: A target processor requires $800\text{ mm}^2$ total silicon area. Assume defect density $D_0 = 0.08\text{ defects/cm}^2$, $300\text{ mm}$ wafer cost $C_{\text{wafer}} = \$12{,}000$, and packaging costs of $\$80$ for monolithic vs. $\$160$ for a 4-chiplet 2.5D interposer assembly. Using Murphy's yield model $Y = \left(\frac{1 - e^{-A \cdot D_0}}{A \cdot D_0}\right)^2$, compute the yield and cost per good die for monolithic vs. chiplet configurations.
2. **Credit Queue Sizing**: A die-to-die bridge operates at $2.5\text{ GHz}$ ($T_{\text{clk}} = 0.4\text{ ns}$). If the forward flit latency is $3.2\text{ ns}$ and credit return latency is $3.2\text{ ns}$, calculate the minimum buffer depth $B_{\text{min}}$ required to sustain peak line-rate throughput.
3. **Deadlock in Hierarchical Topologies**: Prove why combining two 2D mesh chiplets with XY Dimension-Order Routing can produce cyclic deadlocks when connected by a bidirectional bridge link.
4. **In/Outbound Swap Recovery**: Contrast the hardware area and performance overheads of Virtual Channel isolation versus In/Outbound Swap backtracking recovery under heavy congestion.
