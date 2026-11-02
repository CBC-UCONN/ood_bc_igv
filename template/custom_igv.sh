#!/bin/sh

# Locate the Spack IGV installation
IGV_SCRIPT=$(readlink -f "$(command -v igv.sh)")
prefix=${IGV_SCRIPT%/bin/igv.sh}

# Determine memory allocated by Slurm (in MB)
if [ -n "$SLURM_MEM_PER_NODE" ]; then
    MEM_MB=$SLURM_MEM_PER_NODE
elif [ -n "$SLURM_MEM_PER_CPU" ] && [ -n "$SLURM_CPUS_ON_NODE" ]; then
    MEM_MB=$((SLURM_MEM_PER_CPU * SLURM_CPUS_ON_NODE))
else
    echo "Warning: Slurm memory allocation not found; defaulting to 8 GB." >&2
    MEM_MB=8192
fi

# Allocate 90% of available memory to the Java heap
HEAP_MB=$((MEM_MB * 90 / 100))

echo "Slurm memory allocation: ${MEM_MB} MB"
echo "IGV Java heap: ${HEAP_MB} MB"

# Launch IGV
if [ -e "$HOME/.igv/java_arguments" ]; then
    java --module-path="${prefix}/lib" -Xmx"${HEAP_MB}m" \
        @"${prefix}/igv.args" \
        -Dsamjdk.snappy.disable=true \
        -Dapple.laf.useScreenMenuBar=true \
        -Djava.net.preferIPv4Stack=true \
        -Djava.net.useSystemProxies=true \
        @"$HOME/.igv/java_arguments" \
        --module=org.igv/org.broad.igv.ui.Main "$@"
else
    java --module-path="${prefix}/lib" -Xmx"${HEAP_MB}m" \
        @"${prefix}/igv.args" \
        -Dsamjdk.snappy.disable=true \
        -Dapple.laf.useScreenMenuBar=true \
        -Djava.net.preferIPv4Stack=true \
        -Djava.net.useSystemProxies=true \
        --module=org.igv/org.broad.igv.ui.Main "$@"
fi
