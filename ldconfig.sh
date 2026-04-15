#!/bin/bash

ldconfig 2> /tmp/simbolic && rm -rf $(cat /tmp/simbolic | cut -f '2' -d ':' | cut -f '2' -d ' ') && rm -rf /tmp/simbolic && ldconfig
