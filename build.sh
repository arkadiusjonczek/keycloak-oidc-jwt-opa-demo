#!/bin/bash
opa build policies/ --ignore *_test.rego -o bundles/demo.tar.gz
