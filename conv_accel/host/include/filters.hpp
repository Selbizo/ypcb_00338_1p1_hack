#pragma once
#include <cstdint>

namespace accel {

// 5x5 convolution preset: coefficients, normalisation shift and display name.
struct Filter {
    const char* name;   // CLI name, e.g. "gauss"
    const char* title;  // human readable, shown in the window
    int16_t k[25];
    int shift;
};

extern const Filter kFilters[];
extern const int kFilterCount;

// nullptr if the name is unknown
const Filter* find_filter(const char* name);

}  // namespace accel
