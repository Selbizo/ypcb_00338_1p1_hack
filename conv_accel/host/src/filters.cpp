#include "filters.hpp"

#include <cstring>

namespace accel {

// clang-format off
const Filter kFilters[] = {
    {"gauss", "размытие (Гаусс 5x5)",
     {1, 4, 6, 4, 1,
      4, 16, 24, 16, 4,
      6, 24, 36, 24, 6,
      4, 16, 24, 16, 4,
      1, 4, 6, 4, 1}, 8},
    {"sharp", "резкость",
     {0, 0, -1, 0, 0,
      0, -1, -2, -1, 0,
      -1, -2, 17, -2, -1,
      0, -1, -2, -1, 0,
      0, 0, -1, 0, 0}, 0},
    {"edge", "края (Лаплас)",
     {0, 0, 0, 0, 0,
      0, 0, -1, 0, 0,
      0, -1, 4, -1, 0,
      0, 0, -1, 0, 0,
      0, 0, 0, 0, 0}, 0},
    {"box", "равномерное размытие",
     {10, 10, 10, 10, 10,
      10, 10, 10, 10, 10,
      10, 10, 16, 10, 10,
      10, 10, 10, 10, 10,
      10, 10, 10, 10, 10}, 8},
    {"raw", "без фильтра (X = 0)",
     {0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0}, 0},
};
// clang-format on

const int kFilterCount = static_cast<int>(sizeof(kFilters) / sizeof(kFilters[0]));

const Filter* find_filter(const char* name) {
    for (int i = 0; i < kFilterCount; ++i)
        if (std::strcmp(kFilters[i].name, name) == 0) return &kFilters[i];
    return nullptr;
}

}  // namespace accel
