#--------------------Physical Constraints-----------------

set_property BOARD_PART_PIN {GPIO_LED_R} [get_ports gpio_io_o[0]]

set_property BOARD_PART_PIN {GPIO_LED_G} [get_ports gpio_io_o[1]]

set_property BOARD_PART_PIN {GPIO_LED_Y} [get_ports gpio_io_o[2]]

set_property BOARD_PART_PIN {LM73_ALERT} [get_ports gpio2_io_i]
