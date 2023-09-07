#!/bin/bash
system_profiler SPPowerDataType | grep -E "Cycle Count|Condition|Full Charge Capacity"
