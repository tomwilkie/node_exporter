{
  prometheusRules+:: {
    groups+: [
      {
        name: 'node-exporter.rules',
        rules: [
          {
            // This rule gives the number of CPUs per node.
            record: 'instance:node_num_cpu:sum',
            expr: |||
              count by (instance) (
                sum by (instance, cpu) (
                  node_cpu{%(nodeExporterSelector)s}
                )
              )
            ||| % $._config,
          },
          {
            // CPU utilisation is % CPU is not idle.
            record: 'instance:node_cpu_utilisation:avg1m',
            expr: |||
              1 - avg by (instance) (
                rate(node_cpu{%(nodeExporterSelector)s,mode="idle"}[1m])
              )
            ||| % $._config,
          },
          {
            // CPU saturation is 1min avg run queue length / number of CPUs.
            // Can go over 100%.  >100% is bad.
            record: 'instance:node_cpu_saturation_load1:',
            expr: |||
              sum by (instance) (node_load1{%(nodeExporterSelector)s})
              /
              instance:node_num_cpu:sum
            ||| % $._config,
          },
          {
            // Total memory per node
            record: 'instance:node_memory_bytes_total:sum',
            expr: |||
              sum by (instance) (
                node_memory_MemTotal{%(nodeExporterSelector)s}
              )
            ||| % $._config,
          },
          {
            // Memory utilisation per node, normalized by per-node memory
            record: 'instance:node_memory_utilisation:ratio',
            expr: |||
              1 - (
                  node_memory_MemAvailable{%(nodeExporterSelector)s}
                /
                  node_memory_MemTotal{%(nodeExporterSelector)s}
              )
            ||| % $._config,
          },
          {
            record: 'instance:node_memory_swap_io_bytes:sum_rate',
            expr: |||
              1e3 * sum by (instance) (
                (rate(node_vmstat_pgpgin{%(nodeExporterSelector)s}[1m])
                 + rate(node_vmstat_pgpgout{%(nodeExporterSelector)s}[1m]))
              )
            ||| % $._config,
          },
          {
            // Disk utilisation (ms spent, 1 second irate())
            record: 'instance:node_disk_utilisation:sum_irate',
            expr: |||
              sum by (instance) (
                irate(node_disk_io_time_ms{%(nodeExporterSelector)s,device=~"(sd|xvd).+"}[1m]) / 1e3
              )
            ||| % $._config,
          },
          {
            // Disk saturation (ms spent, by rate() it's bound by 1 second)
            record: 'instance:node_disk_saturation:sum_irate',
            expr: |||
              sum by (instance) (
                irate(node_disk_io_time_weighted{%(nodeExporterSelector)s,device=~"(sd|xvd).+"}[1m]) / 1e3
              )
            ||| % $._config,
          },
          {
            record: 'instance:node_net_utilisation:sum_irate',
            expr: |||
              sum by (instance) (
                (irate(node_network_receive_bytes{%(nodeExporterSelector)s,device=~"eth[0-9]+"}[1m]) +
                 irate(node_network_transmit_bytes{%(nodeExporterSelector)s,device=~"eth[0-9]+"}[1m]))
              )
            ||| % $._config,
          },
          {
            record: 'instance:node_net_saturation:sum_irate',
            expr: |||
              sum by (instance) (
                (irate(node_network_receive_drop{%(nodeExporterSelector)s,device=~"eth[0-9]+"}[1m]) +
                 irate(node_network_transmit_drop{%(nodeExporterSelector)s,device=~"eth[0-9]+"}[1m]))
              )
            ||| % $._config,
          },
        ],
      },
    ],
  },
}
