{%- from 'cassandra/settings.sls' import cassandra with context %}

oracle-ppa:
  pkgrepo.managed:
    - humanname: WebUpd8 Oracle Java PPA repository
    - name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main
    - dist: trusty
    - file: /etc/apt/sources.list.d/webupd8team-java.list
    - keyid: EEA14886
    - keyserver: keyserver.ubuntu.com

oracle-license-select:
  debconf.set:
    - name: oracle-java8-installer
    - data:
        'shared/accepted-oracle-license-v1-1': {'type': 'boolean', 'value': 'true'}

oracle-java8-installer:
  pkg.installed:
    - require:
      - pkgrepo: oracle-ppa
    - require_in:
      - pkg: cassandra_package

cassandra_package:
  pkgrepo.managed:
    - humanname: Cassandra Debian Repo
    - name: deb http://debian.datastax.com/datastax-ddc 3.2 main
    - file: /etc/apt/sources.list.d/cassandra.sources.list
    - key_url: http://debian.datastax.com/debian/repo_key
  pkg.installed:
    - name: cassandra

cassandra_configuration:
  file.managed:
    - name: /etc/cassandra/cassandra.yaml
    - user: root
    - group: root
    - mode: 644
    - source: salt://cassandra/conf/cassandra_32x.yaml
    - template: jinja

{% for d in cassandra.config.data_file_directories %}
data_file_directories_{{ d }}:
  file.directory:
    - name: {{ d }}
    - user: cassandra
    - group: cassandra
    - mode: 755
    - makedirs: True
{% endfor %}

commitlog_directory:
  file.directory:
    - name: /var/lib/cassandra/commitlog
    - user: cassandra
    - group: cassandra
    - mode: 755
    - makedirs: True

saved_caches_directory:
  file.directory:
    - name: /var/lib/cassandra/saved_caches
    - user: cassandra
    - group: cassandra
    - mode: 755
    - makedirs: True

cassandra_service:
  service.running:
    - name: cassandra
    - enable: True
    - watch:
      - pkg: cassandra_package
      - file: cassandra_configuration

init_keyspace_cql:
  cmd.run:
    - name: "echo 'CREATE KEYSPACE IF NOT EXISTS {{ pillar['addkeyspace']['name'] }} WITH REPLICATION = {{ pillar['addkeyspace']['replication'] }};' > commands.cql"
    - cwd: /root
    - require:
      - salt: cassandra_service
    - require_in:
      - salt: add_keyspace

add_keyspace:
  cmd.run:
    - name: "cqlsh {{ cassandra.config.listen_address }} -f /root/commands.cql"