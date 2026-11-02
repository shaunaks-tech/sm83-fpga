// Minimal Verilator C++ harness for top_sim.
//
// Usage: sim_main [--trace]

#include <cstdint>
#include <iostream>
#include <string>

#include <verilated.h>
#if VM_TRACE
#include <verilated_vcd_c.h>
#endif

#include "Vtop_sim.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    bool trace = false;
    for (int i = 1; i < argc; ++i) {
        if (std::string(argv[i]) == "--trace") trace = true;
    }

    auto* top = new Vtop_sim;

#if VM_TRACE
    VerilatedVcdC* tfp = nullptr;
    if (trace) {
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open("waveform.vcd");
    }
#endif

    vluint64_t sim_time = 0;
    top->rst_n = 0;
    top->clk = 0;

    for (uint64_t i = 0; i < 1000000; ++i) {
        top->clk = !top->clk;
        if (i == 8) top->rst_n = 1;

        top->eval();
#if VM_TRACE
        if (tfp) tfp->dump(sim_time);
#endif
        sim_time++;

        if (top->clk && top->serial_valid) {
            std::cout << static_cast<char>(top->serial_char) << std::flush;
        }
    }

#if VM_TRACE
    if (tfp) {
        tfp->close();
        delete tfp;
    }
#endif

    top->final();
    delete top;
    return 0;
}
