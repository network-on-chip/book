# Chapter 10: Optical & Wireless Networks-on-Chip (ONoC / WNoC)

[![Companion Platform](https://img.shields.io/badge/Interactive%20Lab-Photon%20Pilot-0f766e?logo=bookstack&logoColor=white)](https://network-on-chip.github.io/learning/interactive/optical/)
[![Curriculum Track](https://img.shields.io/badge/Learning%20Track-Track%207%3A%20Emerging%20Frontiers-blue)](https://network-on-chip.github.io/learning/track7-emerging-frontiers/)
[![Simulation Model](https://img.shields.io/badge/Python%20Model-onoc__optical__loss__sim.py-blueviolet)](code/onoc_optical_loss_sim.py)
[![Hardware RTL](https://img.shields.io/badge/Verilog%20RTL-photonic__mrr__switch.v-success)](code/photonic_mrr_switch.v)

---

## 10.1 The Non-Traditional Interconnect Paradigm

As multi-core processors scale into hundreds and thousands of compute tiles, traditional electrical copper interconnects encounter severe physical barriers. Signal delay on metallic wires scales quadratically with wire length ($\tau \propto R C L^2$), while dynamic switching energy dissipation ($P \propto \alpha C V^2 f$) consumes a prohibitive fraction of the total chip thermal design power (TDP).

To escape this metallic interconnect crisis, two non-traditional physical transport paradigms have emerged:

1. **Optical Networks-on-Chip (ONoC)**: Guided lightwaves propagating through silicon nanophotonic waveguides at the phase velocity of light ($v = c / n_{\text{Si}} \approx 8.5 \times 10^7\text{ m/s}$). Photons experience near-zero data-dependent dynamic loss during transit, while **Wavelength Division Multiplexing (WDM)** allows dozens of independent parallel bitstreams to occupy a single microscopic optical waveguide simultaneously.
2. **Wireless Networks-on-Chip (WNoC)**: Millimeter-wave ($30\text{--}100\text{ GHz}$) and sub-terahertz ($100\text{--}300\text{ GHz}$) electromagnetic radiation transmitted across planar integrated antennas. Wireless links bypass multi-hop planar mesh routers entirely, delivering single-cycle global broadcast channels essential for barrier synchronization, cache invalidation, and distributed deep learning collective communication.

```
       Non-Traditional Interconnects vs. Electrical Multi-Hop NoC
       
       Conventional Electrical NoC (Multi-Hop Routing):
       [ Core 00 ] ---> [ Router ] ---> [ Router ] ---> [ Router ] ---> [ Core 63 ]
       (High RC Wire Delay, 4-Stage Pipeline per Hop, Dynamic CV^2 Switching Loss)
       
       Optical Network-on-Chip (ONoC):
       [ Laser Source ] ==> [ Modulator ] ===(Lightwave Guided Waveguide)===> [ Photodetector ]
       (Speed-of-Light Transit, Wavelength Division Multiplexing, Fixed Laser Power)
       
       Wireless Network-on-Chip (WNoC):
       [ Core 00 / RF TX ] ~ ~ ~ (Free-Space / Dielectric mmWave Broadcast) ~ ~ ~> [ Cores 01..63 ]
       (Single-Cycle Global Broadcast, Zero Buffer Latency, High-Bandwidth Aggregation)
```

---

## 10.2 Silicon Nanophotonics Physical Foundations

Silicon nanophotonics leverages standard CMOS Silicon-on-Insulator (SOI) manufacturing. An active silicon core ($n_{\text{Si}} \approx 3.48$) is surrounded by a silicon dioxide cladding layer ($\text{SiO}_2$, $n_{\text{ox}} \approx 1.45$). This large index contrast ($\Delta n \approx 2.03$) confines optical modes within sub-micron single-mode waveguides ($450\text{ nm} \times 220\text{ nm}$).

### 10.2.1 Micro-Ring Resonators (MRRs)
A **Micro-Ring Resonator (MRR)** is a circular waveguide cavity positioned adjacent to straight optical bus waveguides. Constructive interference occurs when the optical path length matches an integer multiple of the optical wavelength:
$$m \lambda_{\text{res}} = 2 \pi R \cdot n_{\text{eff}}$$
where $m$ is the resonant mode order, $R$ is the cavity radius, and $n_{\text{eff}}$ is the effective refractive index. Light matching $\lambda_{\text{res}}$ couples into the ring and diverts to the drop port; non-resonant wavelengths pass through unobstructed.

### 10.2.2 Switching Elements: Crossing (CSE) vs. Parallel (PSE)

As established by **W.-Y. Kao et al. (IEEE TCAD 2026)** and illustrated in Figure 10.1:

![Figure 10.1: MRR switching structures: (a) 90-degree Crossing Switching Element (CSE), (b) 270-degree CSE, and (c) Parallel Switching Element (PSE). [Reproduced from: W.-Y. Kao et al., "Provably Good Physically Aware WRONoC Design for Customized and Fault-Tolerant Topologies With Parallel Switching Elements and Sequence-Based Models", IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems, Vol. 45, No. 3, pp. 650-663, 2026, DOI: 10.1145/3658617.3697557. © 2026 IEEE]](figures/kao_fig01_mrr_structures.png)

1. **Crossing Switching Elements (CSEs)**: Position an MRR at an orthogonal waveguide crossing. While compatible with Manhattan grids, crossings induce severe optical scattering loss ($0.1\text{--}0.2\text{ dB/crossing}$) and crosstalk. Dropping signals through a CSE forces photons through extra internal crossings.
2. **Parallel Switching Elements (PSEs)**: Place the MRR between two parallel waveguides, eliminating internal crossings entirely.

![Figure 10.2: Add-Drop Filter (ADF) structures with default paths (straight through) and non-default paths (switched via MRR coupling). [Reproduced from: W.-Y. Kao et al., "Provably Good Physically Aware WRONoC Design for Customized and Fault-Tolerant Topologies With Parallel Switching Elements and Sequence-Based Models", IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems, Vol. 45, No. 3, pp. 650-663, 2026, DOI: 10.1145/3658617.3697557. © 2026 IEEE]](figures/kao_fig02_adf_structures.png)

By combining PSEs into **Add-Drop Filters (ADFs)** (Figure 10.2), topologies route multiple independent lightpaths while minimizing waveguide intersections.

---

## 10.3 Optical Loss Modeling, Link Budgets & Laser Power

### 10.3.1 Optical Path Loss Decomposition
The end-to-end insertion loss along an optical lightpath is:
$$L_{\text{path}}(\text{dB}) = L_{\text{prop}} + L_{\text{bend}} + L_{\text{cross}} + L_{\text{thru}} + L_{\text{drop}} + L_{\text{mod}}$$

- **Propagation Loss**: $L_{\text{prop}} = \alpha_{\text{prop}} \cdot l_{\text{wg}}$ (typically $0.2\text{--}0.5\text{ dB/cm}$).
- **Waveguide Bends**: $L_{\text{bend}} = N_{\text{bend}} \cdot \alpha_{\text{bend}}$ ($\approx 0.005\text{ dB/bend}$).
- **Waveguide Crossings**: $L_{\text{cross}} = N_{\text{cross}} \cdot \alpha_{\text{cross}}$ ($\approx 0.10\text{--}0.15\text{ dB/crossing}$).
- **MRR Through-Loss**: $L_{\text{thru}} = N_{\text{thru}} \cdot \alpha_{\text{thru}}$ ($\approx 0.015\text{ dB/MRR}$).
- **MRR Drop-Loss**: $L_{\text{drop}} = N_{\text{drop}} \cdot \alpha_{\text{drop}}$ ($\approx 0.5\text{--}1.0\text{ dB/drop}$).
- **Modulator Loss**: $L_{\text{mod}} \approx 1.2\text{ dB}$.

### 10.3.2 Laser Power & Wall-Plug Efficiency
To maintain a Bit Error Rate (BER) $\le 10^{-12}$, the received optical power must exceed photodetector sensitivity ($P_{\text{sens}} \approx -20\text{ dBm}$). The required continuous-wave (CW) laser optical power is:
$$P_{\text{laser\_opt}}(\text{dBm}) = P_{\text{sens}}(\text{dBm}) + L_{\text{max}}(\text{dB}) + M_{\text{margin}}(\text{dB})$$

Accounting for laser Wall-Plug Efficiency ($\eta_{\text{wpe}} \approx 20\%$):
$$P_{\text{laser\_elec}} = \frac{10^{(P_{\text{laser\_opt}} / 10)}}{\eta_{\text{wpe}}} \quad (\text{mW})$$

Because electrical power scales exponentially with decibel loss ($P \propto 10^{L_{\text{max}} / 10}$), every $3\text{ dB}$ reduction in insertion loss cuts off-chip laser power in half!

---

## 10.4 Thermal Drift & Microheater Tuning

![Figure 10.3: System-level thermal simulation of an Optical NoC demonstrating core active power dissipation, non-uniform temperature profiles, and resonant wavelength shifts in micro-ring resonators. [Reproduced from: Y. Ye et al., "System-Level Modeling and Analysis of Thermal Effects in Optical Networks-on-Chip", IEEE Transactions on Very Large Scale Integration (VLSI) Systems, Vol. 21, No. 2, pp. 292-305, 2013, DOI: 10.1109/TVLSI.2012.2185524. © 2013 IEEE]](figures/ye_fig01_onoc_thermal_drift.png)

Silicon has a high positive thermo-optic coefficient ($\frac{dn_{\text{Si}}}{dT} \approx 1.86 \times 10^{-4}\text{ K}^{-1}$). As demonstrated by **Y. Ye et al. (IEEE TVLSI 2013)** in Figure 10.3, processor activity variations produce on-chip thermal gradients:
$$\frac{d\lambda_{\text{res}}}{dT} = \frac{\lambda_{\text{res}}}{n_{\text{g}}} \frac{dn_{\text{Si}}}{dT} \approx 0.08\text{--}0.11\text{ nm/}^\circ\text{C}$$

With dense WDM channel spacings of $0.4\text{--}0.8\text{ nm}$ ($50\text{--}100\text{ GHz}$), a temperature shift of only $5^\circ\text{C}$ shifts the resonator entirely off its channel, extinguishing communication.

To stabilize resonance, integrated resistive microheaters heat cooler resonators to a target temperature ($T_{\text{target}} \approx 55\text{--}65^\circ\text{C}$). At a tuning cost of $15\text{--}20\text{ mW/nm}$, thermal stabilization across hundreds of MRRs can consume several watts.

---

## 10.5 Wireless Networks-on-Chip (WNoC) & Millimeter-Wave Interconnects

![Figure 10.4: Wireless Network-on-Chip (WNoC) system architecture showing the integrated RF transceiver front-end, planar antenna, and propagation channel through the lossy silicon stack. [Reproduced from: M. Shahmoradi et al., "Channel-Aware Behavioral Power Modeling of CMOS OOK Transceivers for Wireless Network-on-Chip Systems", IEEE Transactions on Circuits and Systems I: Regular Papers, Vol. 73, No. 4, pp. 1620-1633, 2026, DOI: 10.5281/zenodo.19449802. © 2026 IEEE]](figures/shahmoradi_fig01_wnoc_architecture.png)

### 10.5.1 System Architecture
As formulated by **M. Shahmoradi et al. (IEEE TCAS-I 2026)** and illustrated in Figure 10.4, an on-chip wireless link consists of:
1. **Transmitter (TX)**: Modulator, local oscillator (VCO), and RF Power Amplifier (PA). Non-coherent **On-Off Keying (OOK)** is favored for its simplicity and absence of carrier recovery overhead.
2. **Channel & Antenna**: Integrated planar dipole, zigzag, or graphene patch antennas radiating through dielectric layers. Bulk silicon conductivity ($\sigma_{\text{Si}} \approx 10\text{ S/m}$) introduces $25\text{--}35\text{ dB}$ of substrate attenuation.
3. **Receiver (RX)**: Low-Noise Amplifier (LNA), Envelope Detector (ED), and baseband comparator.

![Figure 10.5: Transceiver power consumption versus carrier frequency and received power under stringent (7 dB) and relaxed (15 dB) noise figures, highlighting optimal operating bands across 28, 60, 140, and 245 GHz. [Reproduced from: M. Shahmoradi et al., "Channel-Aware Behavioral Power Modeling of CMOS OOK Transceivers for Wireless Network-on-Chip Systems", IEEE Transactions on Circuits and Systems I: Regular Papers, Vol. 73, No. 4, pp. 1620-1633, 2026, DOI: 10.5281/zenodo.19449802. © 2026 IEEE]](figures/shahmoradi_fig11_trx_power_optima.png)

### 10.5.2 Operating Frequency Optimization
Figure 10.5 reveals that the optimal operating window for WNoC transceivers resides near **60 GHz**, balancing antenna size against power amplifier efficiency. At sub-THz frequencies ($140\text{--}245\text{ GHz}$), antennas shrink below $500\ \mu\text{m}$, but transceiver efficiency drops sharply.

---

## 10.6 Hardware Implementation: Synthesizable MRR Switch Controller

The synthesizable Verilog module [`code/photonic_mrr_switch.v`](code/photonic_mrr_switch.v) implements a 2x2 optical switching element with closed-loop proportional thermal resonance tracking and pulse-width modulated (PWM) microheater actuation.

```verilog
// Snippet from code/photonic_mrr_switch.v: Closed-Loop Thermal Tuning Loop
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        heater_power_val <= 8'd128; // Default 50% duty cycle
        optical_state    <= 1'b0;
        switch_ready     <= 1'b0;
    end else begin
        if (temp_valid) begin
            // Proportional thermal actuation
            if (measured_temp < TARGET_TEMP) begin
                if (heater_power_val < 8'd250)
                    heater_power_val <= heater_power_val + 8'd2; // Heat up
            end else begin
                if (heater_power_val > 8'd5)
                    heater_power_val <= heater_power_val - 8'd2; // Cool down
            end

            // Verify thermal lock window (+/- 0.5 deg C)
            if ((measured_temp >= (TARGET_TEMP - LOCK_TOLERANCE)) &&
                (measured_temp <= (TARGET_TEMP + LOCK_TOLERANCE)))
                switch_ready <= 1'b1;
            else
                switch_ready <= 1'b0;
        end

        // Safely route light only when resonator is locked
        if (switch_ready) optical_state <= switch_cmd;
        else              optical_state <= 1'b0;
    end
end
```

---

## 10.7 Quantitative Simulation & Experimental Results

The Python model [`code/onoc_optical_loss_sim.py`](code/onoc_optical_loss_sim.py) evaluates optical insertion loss, laser power, and thermal tuning costs in an $8 \times 8$ mesh ONoC (64 cores, $20\text{ mm} \times 20\text{ mm}$ die).

| Metric | Crossing Switching Elements (CSE) | Parallel Switching Elements (PSE) | Advantage |
| :--- | :---: | :---: | :---: |
| **Waveguide Crossings** | $62$ | **$24$** | **$-61.3\%$ crossings** |
| **Active MRR Count** | $192$ | **$112$** | **$-41.7\%$ MRRs** |
| **Worst-Case Insertion Loss** | $11.38\text{ dB}$ | **$6.38\text{ dB}$** | **$-5.00\text{ dB loss}$** |
| **Laser Optical Power** | $0.27\text{ mW}$ | **$0.09\text{ mW}$** | **$3.0\times\text{ lower power}$** |
| **Laser Wall-Plug Power** | $1.37\text{ mW}$ | **$0.43\text{ mW}$** | Sub-milliwatt source |
| **MRR Thermal Tuning Power** | $5184.0\text{ mW}$ | **$3024.0\text{ mW}$** | **$-2.16\text{ W savings}$** |
| **Total Optical Subsystem Power** | $5185.4\text{ mW}$ | **$3024.4\text{ mW}$** | **$-41.7\%\text{ total power}$** |

Eliminating waveguide crossings inside the switching elements reduces insertion loss by $5.00\text{ dB}$, cutting laser power threefold and saving over $2.1\text{ W}$ in thermal tuning dissipation.

---

## 10.8 Summary

- **High-Bandwidth Nanophotonics**: ONoCs use silicon waveguides and WDM lightwaves to transmit data at light speed with bit-rate-independent energy.
- **Crossing vs. Parallel Switching**: Parallel Switching Elements (PSEs) avoid internal crossings, reducing insertion loss by $5\text{ dB}$ and slashing laser electrical power.
- **Thermal Resonance Sensitivity**: Silicon's thermo-optic coefficient causes $0.1\text{ nm/}^\circ\text{C}$ drift, requiring active microheater closed-loop stabilization.
- **Single-Cycle Wireless Broadcast**: WNoCs deploy on-chip 60 GHz / sub-THz transceivers to deliver single-hop broadcast capabilities that bypass multi-hop mesh latency.

---

## 10.9 Exercises and Review Questions

1. **Micro-Ring Resonator Resonance**: An optical cavity has radius $R = 6.0\ \mu\text{m}$ and effective index $n_{\text{eff}} = 2.45$ at $\lambda_0 = 1550\text{ nm}$. Calculate the resonant mode order $m$ and Free Spectral Range (FSR) assuming group index $n_{\text{g}} = 4.20$.
2. **Optical Link Budget Calculation**: An optical path has $3.5\text{ cm}$ of waveguide ($0.25\text{ dB/cm}$), 16 bends ($0.005\text{ dB/bend}$), 30 crossings ($0.12\text{ dB/crossing}$), 20 unselected MRRs ($0.015\text{ dB/thru}$), and 2 drop MRRs ($0.50\text{ dB/drop}$). Modulator loss is $1.5\text{ dB}$ and receiver sensitivity is $-21.0\text{ dBm}$. Compute the total insertion loss and required laser power for a $3.0\text{ dB}$ margin.
3. **Thermal Drift Impact**: If chip temperature fluctuates by $20^\circ\text{C}$ and $d\lambda / dT = 0.10\text{ nm/}^\circ\text{C}$, compute the wavelength shift and the total power needed to stabilize 128 MRRs with $20.0\text{ mW/nm}$ microheaters.
4. **Wireless Path Loss**: Using Friis transmission formula, calculate the path loss of a $60\text{ GHz}$ wireless channel over a distance of $12\text{ mm}$ with $G_{\text{tx}} = G_{\text{rx}} = -2\text{ dBi}$ in an effective dielectric with $\epsilon_{\text{eff}} = 3.8$.
