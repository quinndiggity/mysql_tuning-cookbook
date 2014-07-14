# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
#
# Copyright 2014, Onddo Labs, Sl.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:Mysql) do
  provides 'mysql', 'mysql/installed_version'

  def init_mysql
    mysql Mash.new
    mysql['installed_version'] = nil
    mysql
  end

  def collect_version(stdout)
    case stdout.split("\n")[0]
    when /^mysqld +Ver +([0-9][0-9.]*)[^0-9.]/
      mysql['installed_version'] = Regexp.last_match[1]
    end
  end

  collect_data do
    init_mysql
    status, stdout, _stderr = run_command(
      no_status_check: true,
      command: 'mysqld --version'
    )
    collect_version(stdout) if status == 0
  end

end
