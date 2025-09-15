# GlitchSort v01b10 crash course

Paul Hertz’s GlitchSort is a full-stack glitch workstation wrapped in Processing. Use it to teach advanced image hacking: pixel sorting, FFT filtering, color quantization, snapshots, and a custom ControlP5 panel. This README condenses the sprawling manual into a classroom-friendly outline.

## Prep checklist

1. Install Processing 2.x or 3.x plus the **ControlP5** and **Minim** libraries (via Sketch → Import Library → Add Library…).【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L17-L140】
2. Run the sketch and press the spacebar to summon the control panel. Use `o` to load an image; the sketch keeps undo buffers, snapshots, and fit-to-screen versions for you.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L97-L200】
3. Keep the included PDF (`gs10b8_Manual_web.pdf`) around for deep reference—it covers every knob in excruciating detail.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L17-L44】

## Control tour

- **Sorting arsenal:** Switch between Quick, Shell, Bubble, and Insert sorters. The `SortSelector` class handles swapping strategies and sharing settings like “random break” probability—perfect for discussing design patterns.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L111-L140】【F:GlitchSort_v01b10/ControlPanelCommands.pde†L116-L146】【F:GlitchSort_v01b10/Sorting.pde†L14-L94】
- **Color experiments:** Step through component orders, channel swaps, and zigzag styles to illustrate how pixel ordering affects the “sorted” look. `CompOrder`, `SwapChannel`, and `ZigzagStyle` enums keep the permutations readable.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L165-L200】【F:GlitchSort_v01b10/ControlPanelCommands.pde†L148-L160】【F:GlitchSort_v01b10/CompOrder.java†L1-L29】
- **Degrade & munge:** The JPEG degrade slider and munge operations demonstrate lossy compression and buffer blending. Use them to talk about image formats and difference masks.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L123-L132】【F:GlitchSort_v01b10/ControlPanelCommands.pde†L62-L112】
- **FFT playground:** Keys `j`, `k`, and `)` trigger equalizer, statistical FFT, and low-pass routines courtesy of Minim. Great for introducing frequency-domain thinking in visual form.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L133-L140】【F:GlitchSort_v01b10/FFT.pde†L1-L52】

## Teaching strategies

1. **State diagrams:** Map the undo (`bakImg`), snapshot (`snapImg`), and display (`img`) buffers to reinforce how complex sketches manage memory.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L181-L188】
2. **Event routing:** Walk through `ControlPanelCommands.pde` to show how UI callbacks sanitize values, lock controls, and fan out to the core sorter. Let students trace a slider movement from ControlP5 to the actual algorithm.【F:GlitchSort_v01b10/ControlPanelCommands.pde†L12-L146】
3. **Algorithm comparisons:** Run the same glitch with Quick vs. Bubble sort while discussing Big-O behavior and why slow sorts become interesting when they purposely “break.”【F:GlitchSort_v01b10/Sorting.pde†L14-L147】
4. **Audio ↔ visuals:** Toggle the audify mode (`/` and `\`) and FFT filters to connect sound processing concepts to image mutation without leaving Processing.【F:GlitchSort_v01b10/GlitchSort_v01b10.pde†L133-L140】

## Challenge ideas

- Build presets: record command sequences and replay them as live-coding performances.
- Expose GlitchSort’s enums via a small GUI for beginners; advanced students can script automation by editing the PDE.
- Add OSC/MIDI input so musicians can trigger glitch routines during shows—great capstone project.
