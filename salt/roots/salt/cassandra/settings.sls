{% set default_config = {
  'cluster_name': 'SaltEdu',
  'data_file_directories': ['/var/lib/cassandra/data'],
  'commitlog_directory': '/var/lib/cassandra/commitlog',
  'saved_caches_directory': '/var/lib/cassandra/saved_caches',
  'seeds': ["10.10.0.2"],
  'listen_address': '10.10.0.2',
  'rpc_address': '10.10.0.2',
  'endpoint_snitch': 'SimpleSnitch'
  }%}

{%- set config = default_config %}

{%- set cassandra = {} %}

{%- do cassandra.update({
  'config': config
   }) %}
